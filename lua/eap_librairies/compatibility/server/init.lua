--[[
	===========================================================================
	 EAP <-> CAP Compatibility Bridge - Server-side targeted patches
	===========================================================================
	This file is the ONLY place where EAP reaches into a handful of CAP's own
	tools/weapons/entities to patch them in memory, AFTER they have already
	been registered by CAP itself. It never edits a CAP file on disk, and it
	never runs at all unless CAP is detected (Lib.IsCapDetected) - with CAP
	absent, every function below either isn't called or is a silent no-op.

	Four different, narrowly-scoped techniques are used here, all cheaper
	than a global GetClass() override (rejected earlier for this project -
	see shared/init.lua's header):

	1. Per-call GetClass() spoofing (EAP.Compat.WithSpoofedClass)
	   A handful of CAP stools/weapons decide what to do by comparing
	   t.Entity:GetClass() (or a traced entity's GetClass()) against a CAP
	   literal such as "stargate_universe" or "stargate_orlin". We wrap just
	   that one call (one LeftClick, one SpawnProp) so the entity reports its
	   CAP-equivalent class ONLY for the duration of that single call, then
	   restores its real GetClass immediately after. The entity's class is
	   never actually changed, and nothing else observing it during that
	   frame is affected. The exact same technique is also applied in the
	   OTHER direction (section 4b): several of EAP's OWN stools gate on an
	   EAP class literal the same way, so they get the mirrored spoof too
	   (CAP entity -> reports its EAP-equivalent class for that one call).

	2. Static data-table extension (EAP.Compat.ExtendArrayField / ExtendMapField)
	   A couple of CAP entities keep a plain Lua list/map of "classes I
	   recognize" as instance data (ENT.GateList, ENT.ValidGates, etc). These
	   aren't functions, so there's nothing to wrap - we just add the EAP
	   equivalents directly into that same table once, after CAP registers
	   it, via scripted_ents.GetStored(class).t.

	3. Function replacement (EAP.Compat.PatchRampGateFinder)
	   The CAP ramp entities' GateFinder() method uses a hand-rolled pattern
	   match (v:GetClass():find("stargate_*")) that only ever matches CAP's
	   own "stargate_..." classes. We replace that one method (same
	   scripted_ents.GetStored(class).t mechanism) with an equivalent version
	   that also recognizes EAP's "sg_..." classes, keeping every other
	   behavior of the entity untouched.

	4. Scripting-backend registry merges (section 6 below)
	   EAP's and CAP's E2/ExpAdv2/Wire-gate/Starfall stargate extension
	   files live at the same path in both addons, so only one of them ever
	   actually loads - the other is fully shadowed, not just overridden
	   function-by-function. For the one function in all four that breaks
	   because of this (stargateGetRingAngle), we reach into whichever
	   backend's own registry ends up holding it (wire_expression2_funcs,
	   GateActions, the ExpAdv2 "stargate" component, Starfall's
	   SF.Entities.Methods) and overwrite that one entry with a version
	   that recognizes both class families - same "patch the registry after
	   the fact" principle as the other three techniques, just applied to a
	   table slot instead of a Lua method.

	Known, accepted limitation: a few places inside CAP's own Think()/logic
	compare an entity's class directly in-line against a CAP literal in a way
	that can't be patched by any of the three techniques above without
	reimplementing that function's full body (e.g. gate_nuke's supergate
	shutdown branch: `elseif class == "stargate_supergate" then`). Those are
	left as-is: they simply won't trigger for an EAP supergate caught in a
	CAP gate_nuke's blast radius. This is a deliberate trade-off to avoid
	duplicating CAP's internal logic inside this bridge.
]]--

EAP = EAP or {};
EAP.Compat = EAP.Compat or {};

-- Reuses the two-way class map built in shared/init.lua (loaded before this
-- file - see eap_include.lua).
local CAP_TO_EAP = EAP.Compat.CapToEap or {};
local EAP_TO_CAP = EAP.Compat.EapToCap or {};

-- ===========================================================================
-- 1. Per-call GetClass() spoofing helper
-- ===========================================================================

-- IMPORTANT: a per-instance assignment (`ent.GetClass = function() ... end`)
-- has ZERO effect in GMod - `Entity:GetClass()` is resolved through the
-- shared Entity metatable at the engine level, not through per-instance Lua
-- table storage the way an ordinary custom field (`ent.Foo = 123`) is. This
-- was confirmed empirically (diagnostic logging showed ent:GetClass() still
-- returning the real class immediately after the per-instance assignment),
-- and is why every tool/weapon patch in this file that relies on this
-- helper previously had no effect in-game despite installing with no
-- warnings.
--
-- The fix has to replace the function slot on the METATABLE itself
-- (FindMetaTable("Entity").GetClass), which is what :GetClass() actually
-- resolves through for every entity. To keep this as narrowly-scoped as
-- the global override already rejected for this project (see this file's
-- header), the replacement:
--   - only returns the spoofed class for the ONE entity passed in (an
--     identity check - `self == ent`), every other entity's GetClass() is
--     untouched and goes straight to the previous implementation;
--   - is installed and removed strictly around the single synchronous
--     pcall(fn, ...) below (one LeftClick, one SpawnProp) - there is no
--     ongoing per-frame cost, unlike a persistent hook;
--   - saves and restores whatever was on the metatable slot at entry/exit
--     (`previousGetClass`), rather than assuming it's always the engine's
--     own original function. This makes nested/re-entrant calls (e.g. one
--     spoofed LeftClick that itself triggers another spoofed call before
--     returning - same entity or a different one) resolve correctly: each
--     call's wrapper falls back to exactly what was installed before it,
--     so unwinding always peels back to the right layer instead of two
--     nested calls clobbering a single shared "real function" variable.
function EAP.Compat.WithSpoofedClass(ent, spoofedClass, fn, ...)
	if (not IsValid(ent)) then return fn(...) end

	local entMeta = FindMetaTable("Entity");
	local previousGetClass = entMeta.GetClass;

	entMeta.GetClass = function(self)
		if (self == ent) then return spoofedClass end
		return previousGetClass(self);
	end

	local results = { pcall(fn, ...) };

	entMeta.GetClass = previousGetClass;

	if (not results[1]) then
		error(results[2], 0);
	end

	return unpack(results, 2);
end

-- Same call-scoped Entity-metatable technique, generalized: some of EAP's
-- and CAP's own dialing functions (FindGate's Atlantis tie-break,
-- WormHoleJump's Orlin/Supergate checks, the DHD's PressButton) don't test
-- ONE already-known entity against ONE literal - they run their own
-- internal ents.FindByClass() loop and GetClass()-compare MANY candidate
-- entities at once. WithSpoofedClass doesn't fit that shape (it only knows
-- about a single `ent`), so this version instead spoofs by CLASS: any
-- entity whose real class is a key in `classMap` reports the mapped value
-- instead, for the duration of fn(...). Passing the bridge's own
-- CapToEap/EapToCap maps (already built in compatibility/shared/init.lua)
-- means every gate-type pair this bridge has ever been told about is
-- covered automatically, including stargate types no section of this file
-- had to special-case by hand. Same cost/safety profile as WithSpoofedClass
-- (temporary, call-scoped, synchronous, nested-safe save/restore) - see
-- that function's header comment for the full risk discussion.
function EAP.Compat.WithSpoofedClassFamilies(classMap, fn, ...)
	local entMeta = FindMetaTable("Entity");
	local previousGetClass = entMeta.GetClass;

	entMeta.GetClass = function(self)
		local real = previousGetClass(self);
		return classMap[real] or real;
	end

	local results = { pcall(fn, ...) };

	entMeta.GetClass = previousGetClass;

	if (not results[1]) then
		error(results[2], 0);
	end

	return unpack(results, 2);
end

-- ===========================================================================
-- 2. Static data-table extension helpers
-- ===========================================================================

function EAP.Compat.ExtendArrayField(classname, fieldname, extraValues)
	local stored = scripted_ents.GetStored(classname);
	if (not stored or not stored.t or not stored.t[fieldname]) then
		MsgN("[EAP Compat] WARNING: couldn't find CAP entity '"..classname.."' (field '"..fieldname.."') to extend - was it really registered yet?");
		return;
	end

	local list = stored.t[fieldname];
	for _, v in ipairs(extraValues) do
		if (not table.HasValue(list, v)) then
			table.insert(list, v);
		end
	end
end

function EAP.Compat.ExtendMapField(classname, fieldname, extraKeys)
	local stored = scripted_ents.GetStored(classname);
	if (not stored or not stored.t or not stored.t[fieldname]) then
		MsgN("[EAP Compat] WARNING: couldn't find CAP entity '"..classname.."' (field '"..fieldname.."') to extend - was it really registered yet?");
		return;
	end

	local map = stored.t[fieldname];
	for _, k in ipairs(extraKeys) do
		map[k] = true;
	end
end

-- ===========================================================================
-- 3. Ramp GateFinder() replacement
-- ===========================================================================
-- Same behavior as CAP's own GateFinder (self.Gate = the last matching gate
-- found among constrained ents), just matching "sg_..." in addition to
-- "stargate_...". `excludeClass`, when given, is skipped exactly like CAP's
-- own ramp_2 skips "stargate_dhd" (there is no EAP equivalent to exclude).

local function IsBridgedGateClass(class, excludeClass)
	if (excludeClass and class == excludeClass) then return false end
	return class:find("stargate") ~= nil or class:find("^sg_") ~= nil;
end

function EAP.Compat.PatchRampGateFinder(classname, excludeClass)
	local stored = scripted_ents.GetStored(classname);
	if (not stored or not stored.t) then
		MsgN("[EAP Compat] WARNING: couldn't find CAP entity '"..classname.."' to patch its GateFinder() - was it really registered yet?");
		return;
	end

	stored.t.GateFinder = function(self)
		for _, v in pairs(StarGate.GetConstrainedEnts(self.Entity, 2) or {}) do
			if (IsValid(v) and IsBridgedGateClass(v:GetClass(), excludeClass)) then
				self.Gate = v;
			end
		end
	end
end

-- ===========================================================================
-- 4. CAP stool LeftClick patch (uses the spoofing helper from section 1)
-- ===========================================================================
-- Covers every CAP stool confirmed to gate its LeftClick behavior on
-- t.Entity:GetClass() matching a CAP gate literal: bearing, floorchevron
-- (both check for "stargate_universe"), goauld_iris and stargate_iris (both
-- exclude "stargate_orlin" - without this patch, an EAP Orlin gate is NOT
-- excluded, which is a minor permissiveness bug this patch also fixes), and
-- supergate_dhd (checks for "stargate_supergate"). stargate_dhd.lua was
-- checked and does NOT need this (its LeftClick doesn't compare classes).

local SPOOFED_TOOLS = { "bearing", "floorchevron", "goauld_iris", "stargate_iris", "supergate_dhd" };

-- Shared by both directions (section 4 and 4b below), and also by the
-- InitializeTools/existing-weapon re-patching in section 4c: wraps a given
-- TOOL object's LeftClick (whichever table it lives in - the class-level
-- template, or a per-weapon-instance copy) using the given class map.
local function WrapToolLeftClickObj(TOOL, classMap)
	if (not TOOL) then return end
	if (TOOL.EAPCompatPatched) then return end
	local RealLeftClick = TOOL.LeftClick;
	if (not RealLeftClick) then return end

	TOOL.LeftClick = function(self, t, ...)
		if (t and IsValid(t.Entity)) then
			local mappedClass = classMap[t.Entity:GetClass()];
			if (mappedClass) then
				return EAP.Compat.WithSpoofedClass(t.Entity, mappedClass, RealLeftClick, self, t, ...);
			end
		end
		return RealLeftClick(self, t, ...);
	end
	TOOL.EAPCompatPatched = true;
end

function EAP.Compat.PatchToolLeftClick(toolname)
	local stored = weapons.GetStored("gmod_tool");
	if (not stored or not stored.Tool or not stored.Tool[toolname]) then
		MsgN("[EAP Compat] WARNING: couldn't find CAP tool '"..toolname.."' to patch - was it really registered yet?");
		return;
	end
	WrapToolLeftClickObj(stored.Tool[toolname], EAP_TO_CAP);
end

-- ===========================================================================
-- 4b. EAP stool LeftClick patch (mirror of section 4, other direction)
-- ===========================================================================
-- Section 4 above only covers CAP's OWN stools gating on a CAP class
-- literal. EAP ships several of its own stools that independently gate on
-- an EAP class literal the exact same way - these were never patched
-- before, which is why e.g. EAP's own "gatebearing" tool refuses an EAP
-- Universe gate's CAP counterpart with its "not a Universe stargate" error
-- (t.Entity:GetClass():find("sg_universe") - confirmed in
-- weapons/gmod_tool/stools/gatebearing.lua). Exact same spoofing
-- technique, just mirrored: CAP_TO_EAP instead of EAP_TO_CAP, and EAP's own
-- tool names instead of CAP's.
--
-- Confirmed by grepping every EAP stool under weapons/gmod_tool/stools/:
--   - gatebearing, floor_chevron: hard-require the target class to contain
--     "sg_universe" - blocking bug, fixed by this patch.
--   - supergatedhd: hard-require the target class to equal "sg_supergate"
--     exactly - blocking bug, fixed by this patch.
--   - goauldiris, iris_sgc, iris_atlantis, iris_infinity: accept any
--     t.Entity.IsStargate (already addon-agnostic - CAP entities set that
--     flag too), but exclude only the literal "sg_orlin" - without this
--     patch, a CAP Orlin gate (stargate_orlin) is NOT excluded, mirroring
--     the same minor permissiveness bug section 4's comment already
--     documents for CAP's own iris tools. Included here for parity.
--   - stargatedhd: no gate-class literal at all - already addon-agnostic,
--     nothing to patch.

local SPOOFED_EAP_TOOLS = {
	"gatebearing", "floor_chevron", "supergatedhd",
	"goauldiris", "iris_sgc", "iris_atlantis", "iris_infinity",
};

function EAP.Compat.PatchEapToolLeftClick(toolname)
	local stored = weapons.GetStored("gmod_tool");
	if (not stored or not stored.Tool or not stored.Tool[toolname]) then
		MsgN("[EAP Compat] WARNING: couldn't find EAP tool '"..toolname.."' to patch - was it really registered yet?");
		return;
	end
	WrapToolLeftClickObj(stored.Tool[toolname], CAP_TO_EAP);
end

-- ===========================================================================
-- 4c. Re-patch on InitializeTools + sweep existing toolguns
-- ===========================================================================
-- Sections 4 and 4b above only patch the CLASS-LEVEL template stored at
-- weapons.GetStored("gmod_tool").Tool[toolname]. That template is NOT what
-- LeftClick actually runs on at click time: Facepunch's own
-- gmod_tool/shared.lua SWEP:InitializeTools() - called every time a player
-- is given/re-equips the tool gun - does
--     temp[k] = table.Copy(v); ... self.Tool = temp
-- i.e. makes a FRESH per-weapon-instance COPY of every entry in the
-- class-level template, once, at that moment, and from then on LeftClick is
-- called on that per-instance copy, never on the template again.
--
-- table.Copy() copies a function VALUE by reference (Lua functions aren't
-- deep-cloned), so a copy made AFTER our class-level patch above still
-- points at our wrapper - fine. But a copy made BEFORE our patch (e.g. the
-- local player's tool gun, handed to them during their own spawn/loadout,
-- which can easily happen earlier than our InitPostEntity-timed install)
-- keeps the ORIGINAL, unpatched LeftClick forever for that weapon
-- instance - which is exactly why bearing/floorchevron/etc. kept failing
-- in both directions even though the template patch installed with no
-- warning. Two extra steps close this gap:
--
--   a) wrap SWEP:InitializeTools itself, so every COPY made from now on
--      (every future tool-gun pickup/respawn) gets re-wrapped right after
--      the copy is made, regardless of whether the template was patched
--      in time;
--   b) immediately sweep every "gmod_tool" weapon entity that already
--      exists right now (e.g. already in a player's hands) and re-wrap its
--      current per-instance copy directly, so weapons handed out before
--      this file ran are fixed retroactively too.

local TOOLNAME_TO_MAP = {};
for _, toolname in ipairs(SPOOFED_TOOLS) do TOOLNAME_TO_MAP[toolname] = EAP_TO_CAP; end
for _, toolname in ipairs(SPOOFED_EAP_TOOLS) do TOOLNAME_TO_MAP[toolname] = CAP_TO_EAP; end

function EAP.Compat.PatchToolInitializeTools()
	local stored = weapons.GetStored("gmod_tool");
	if (not stored) then
		MsgN("[EAP Compat] WARNING: couldn't find 'gmod_tool' SWEP table to patch InitializeTools - was it really registered yet?");
		return;
	end
	if (stored.EAPCompatInitPatched) then return end

	local RealInitializeTools = stored.InitializeTools;
	if (RealInitializeTools) then
		stored.InitializeTools = function(self, ...)
			RealInitializeTools(self, ...);
			if (self.Tool) then
				for toolname, classMap in pairs(TOOLNAME_TO_MAP) do
					if (self.Tool[toolname]) then
						WrapToolLeftClickObj(self.Tool[toolname], classMap);
					end
				end
			end
		end
	end

	stored.EAPCompatInitPatched = true;
end

function EAP.Compat.RepatchExistingToolguns()
	for _, wep in ipairs(ents.FindByClass("gmod_tool")) do
		if (IsValid(wep) and wep.Tool) then
			for toolname, classMap in pairs(TOOLNAME_TO_MAP) do
				if (wep.Tool[toolname]) then
					WrapToolLeftClickObj(wep.Tool[toolname], classMap);
				end
			end
		end
	end
end

-- ===========================================================================
-- 5. v_virus (Gate Virus) weapon patch
-- ===========================================================================
-- SpawnProp() traces where the player is looking and only proceeds if the
-- traced entity's class contains "stargate_". We re-run the same trace
-- ahead of the real call (same inputs, same result - a trace has no side
-- effects) purely to know whether to spoof, then spoof only for that call.

function EAP.Compat.PatchVirusWeapon()
	local stored = weapons.GetStored("v_virus");
	if (not stored) then
		MsgN("[EAP Compat] WARNING: couldn't find CAP weapon 'v_virus' to patch - was it really registered yet?");
		return;
	end
	if (stored.EAPCompatPatched) then return end
	local RealSpawnProp = stored.SpawnProp;
	if (not RealSpawnProp) then return end

	stored.SpawnProp = function(self, ...)
		local p = self.Owner;
		if (IsValid(p)) then
			local tr = util.TraceLine(util.GetPlayerTrace(p));
			if (IsValid(tr.Entity)) then
				local capClass = EAP_TO_CAP[tr.Entity:GetClass()];
				if (capClass) then
					return EAP.Compat.WithSpoofedClass(tr.Entity, capClass, RealSpawnProp, self, ...);
				end
			end
		end
		return RealSpawnProp(self, ...);
	end
	stored.EAPCompatPatched = true;
end

-- ===========================================================================
-- 6. Scripting-backend function merges (E2 / ExpAdv2 / Wire gates / Starfall)
-- ===========================================================================
-- EAP's and CAP's own extension files for these 4 scripting backends
-- (lua/entities/gmod_wire_expression2/core/custom/stargate.lua,
-- lua/expadv/components/custom/stargate.lua, lua/wire/gates/stargate.lua,
-- lua/starfall/libs_sv/stargate.lua) live at the EXACT SAME path in both
-- addons. Garry's Mod's virtual filesystem only exposes ONE file per
-- addon-relative path across every mounted addon - whichever addon wins
-- the mount-order priority is the only one that ever actually runs; the
-- other addon's identically-named file is fully invisible and never
-- executes at all. This is NOT a "last one registered wins" clash (which
-- would already be a pointer we could wrap, like ents.FindByClass) - it's
-- a full file-level shadow, so there is nothing of the losing addon's to
-- wrap directly.
--
-- Both files are near-identical (EAP's is historically a fork of CAP's),
-- and grepping both confirms only ONE function in all four actually
-- hard-codes a literal class whitelist: stargateGetRingAngle() (entity +
-- wirelink variants, x1 for the Wire gate node). Every other function only
-- checks the addon-agnostic `this.IsStargate` flag, so it keeps working no
-- matter which file wins the shadow.
--
-- The fix stays true to the same principle as the ents.FindByClass wrap in
-- shared/init.lua: reach into whichever registry each backend keeps its
-- registered functions in, AFTER it has been populated (InitPostEntity,
-- same as the rest of this file), and overwrite just that one entry with a
-- version that recognizes both class families - entirely from this file,
-- no new file added anywhere in CAP's, Wire's, ExpAdv2's or Starfall's own
-- folders.

local MERGED_RING_ANGLE_CLASSES = {
	sg_movie = true, sg_sg1 = true, sg_infinity = true, sg_universe = true,
	stargate_movie = true, stargate_sg1 = true, stargate_infinity = true, stargate_universe = true,
};

-- Shared implementation of stargateGetRingAngle() for every backend below.
-- Returns the ring angle (0-360), or nil when the entity's class has no ring
-- or the ring/gate part isn't available; each backend maps nil to its own
-- failure value (-1 for E2/ExpAdv2/Wire, false for Starfall).
local function GetMergedRingAngle(ent)
	local class = ent:GetClass();
	if (not MERGED_RING_ANGLE_CLASSES[class]) then return nil end
	local part = (class == "sg_universe" or class == "stargate_universe") and ent.Gate or ent.Ring;
	if (not IsValid(part)) then return nil end
	local angle = tonumber(math.NormalizeAngle(part:GetLocalAngles().r));
	if (angle < 0) then angle = angle + 360; end
	return angle;
end

-- 6a. Expression 2: wire_expression2_funcs[signature][3] is the actual
-- Lua function E2 chips call for that signature. "e:" = entity this-arg,
-- "xwl:" = wirelink this-arg (Wire's own type codes).
function EAP.Compat.MergeE2StargateGetRingAngle()
	if (not wire_expression2_funcs) then return end

	local entityEntry = wire_expression2_funcs["stargateGetRingAngle(e:)"];
	if (entityEntry) then
		entityEntry[3] = function(self, args)
			local this = args[1];
			if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
			return GetMergedRingAngle(this) or -1;
		end
	else
		MsgN("[EAP Compat] WARNING: E2 function 'stargateGetRingAngle(e:)' not found to merge - was Wire/E2 loaded yet?");
	end

	local wirelinkEntry = wire_expression2_funcs["stargateGetRingAngle(xwl:)"];
	if (wirelinkEntry) then
		wirelinkEntry[3] = function(self, args)
			local this = args[1];
			if not IsValid(this) or not this.IsStargate then return -1 end
			return GetMergedRingAngle(this) or -1;
		end
	else
		MsgN("[EAP Compat] WARNING: E2 function 'stargateGetRingAngle(xwl:)' not found to merge - was Wire/E2 loaded yet?");
	end
end

-- 6b. Wire gates: GateActions is the global, shared registry both addons'
-- "wire/gates/stargate.lua" write their gate node definitions into.
function EAP.Compat.MergeWireGateGetRingAngle()
	if (not GateActions or not GateActions["GetRingAngle"]) then
		MsgN("[EAP Compat] WARNING: wire gate 'GetRingAngle' not found to merge - was Wire loaded yet?");
		return;
	end

	GateActions["GetRingAngle"].output = function(gateself, Ent)
		if not IsValid(Ent) or not Ent.IsStargate then return -1 end
		return GetMergedRingAngle(Ent) or -1;
	end
end

-- 6c. Expression Advanced 2: fetch the already-registered "stargate"
-- component and re-add the two VM functions onto it - AddVMFunction()
-- itself just overwrites the entry for that name+signature, same as E2's
-- registerFunction() does, so calling it again from here is the merge.
function EAP.Compat.MergeExpAdv2StargateGetRingAngle()
	if (not WireLib or not EXPADV) then return end
	local Component = EXPADV.GetComponent("stargate");
	if (not Component) then
		MsgN("[EAP Compat] WARNING: ExpAdv2 'stargate' component not found to merge - was ExpAdv2 loaded yet?");
		return;
	end

	Component:AddVMFunction( "stargateGetRingAngle", "e:", "n", function( Context, Trace, Entity )
		if not IsValid(Entity) or not Entity.IsStargate or not EXPADV.PPCheck(Context,Entity) then return -1 end
		return GetMergedRingAngle(Entity) or -1;
	end)
	Component:AddFunctionHelper( "stargateGetRingAngle", "e:", "Returns stargate ring angle." )

	Component:AddVMFunction( "stargateGetRingAngle", "wl:", "n", function( Context, Trace, Entity )
		if not IsValid(Entity) or not Entity.IsStargate then return -1 end
		return GetMergedRingAngle(Entity) or -1;
	end)
	Component:AddFunctionHelper( "stargateGetRingAngle", "wl:", "Returns stargate ring angle." )
end

-- 6d. Starfall: SF.Entities.Methods (entity variant) and SF.Wire.WlMethods
-- (wirelink variant) are the shared methods tables both addons'
-- "starfall/libs_sv/stargate.lua" write stargateGetRingAngle() into -
-- reassigning them here overwrites them exactly the same way loading a
-- second file would.
function EAP.Compat.MergeStarfallStargateGetRingAngle()
	if (not SF or not SF.Entities) then return end

	local ents_metatable = SF.Entities.Metatable;
	local ents_methods = SF.Entities.Methods;
	local unwrap = SF.Entities.Unwrap;

	if (not ents_methods or not ents_methods.stargateGetRingAngle) then
		MsgN("[EAP Compat] WARNING: Starfall 'stargateGetRingAngle' method not found to merge - was Starfall loaded yet?");
		return;
	end

	local function canModify(ply, ent)
		return SF.Entities.GetOwner(ent) == ply or game.SinglePlayer() and ent.GateSpawnerSpawned;
	end

	ents_methods.stargateGetRingAngle = function(self)
		SF.CheckType( self, ents_metatable );
		local this = unwrap( self );
		if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
		if not this.IsStargate then return false, "entity is not stargate" end
		if (not MERGED_RING_ANGLE_CLASSES[this:GetClass()]) then return false, "Stargate should be sg1, movie, infinity or universe class" end
		return GetMergedRingAngle(this) or false;
	end

	-- Wirelink variant (was not merged before: only the entity variant was).
	local wl_methods = SF.Wire and SF.Wire.WlMethods;
	if (wl_methods and wl_methods.stargateGetRingAngle) then
		local wl_metatable = SF.Wire.WlMetatable;
		local wl_unwrap = SF.Wire.WlUnwrap;
		wl_methods.stargateGetRingAngle = function(self)
			SF.CheckType( self, wl_metatable );
			local this = wl_unwrap( self );
			if not SF.Permissions.check( SF.instance.player, nil, "wire.wirelink.read" ) then return false, "Insufficient permissions" end
			if not this.IsStargate then return false, "entity is not stargate" end
			if (not MERGED_RING_ANGLE_CLASSES[this:GetClass()]) then return false, "Stargate should be sg1, movie, infinity or universe class" end
			return GetMergedRingAngle(this) or false;
		end
	end
end

-- 6e. CAP's own sequences (stargate_base/modules/events.lua, DialFail and
-- Shutdown, and the supergate's own dialling) queue stargate_supergate's
-- DisActivateLights()/LightUp()/LightUps() with the *sequence table* as
-- `self` instead of the gate entity, so the call dies on `self:EntIndex()`
-- ("calling 'EntIndex' on bad self") and the rest of the package never runs. EAP's
-- copy of that bug is fixed in its own sequences; for CAP we can't touch the files, so resolve the entity here.
function EAP.Compat.PatchSupergateLightsSelf()
	local stored = scripted_ents.GetStored("stargate_supergate");
	if (not stored or not stored.t) then return end
	if (stored.t.EAPCompatLightsSelfPatched) then return end
	-- Same bug for the light effects queued by its dialling sequences.
	for _, name in ipairs({ "DisActivateLights", "LightUp", "LightUps" }) do
		local Real = stored.t[name];
		if (Real) then
			stored.t[name] = function(self, ...)
				if (type(self) == "table" and IsValid(self.Entity)) then self = self.Entity; end
				return Real(self, ...);
			end
		end
	end
	stored.t.EAPCompatLightsSelfPatched = true;
end

-- ===========================================================================
-- 6f. E2 stargateGlyphIsActivated(n) for CAP's Pegasus gates
-- ===========================================================================
-- EAP's sg_atlantis keeps track of the lit ring glyph(s) itself (ENT:GlyphIsLit)
-- and EAP's E2 extension exposes it as stargateGlyphIsActivated(n). CAP's
-- stargate_atlantis has no such state and its files are not ours to edit, so:
--   a) its RingLight() (same maths as EAP's: the "Active Glyph" wire) is wrapped to
--      remember the lit glyph, or "all lit" for the instant open
--      (Sequence:InstantOpen's RingLight(36,true) step, marked here) and for the
--      "Turn on ring light" input (TriggerInput, flagged while it runs);
--   b) the E2 function is wrapped (EAP's extension loaded) or registered (CAP's
--      extension file won the shadowing, see section 6) so that it answers for
--      CAP Pegasus gates and hands every other gate to EAP's own function.

local function ThisGate(self)
	return (isentity(self.Entity) and self.Entity) or self;
end

local function WithCapGlyphTracking(Real)
	return function(self, light, inbound, shutdown, atlantis, all, ...)
		local ent = ThisGate(self);
		local previous = ent.SpinLight;
		local result = Real(self, light, inbound, shutdown, atlantis, all, ...);
		local part, l = 1, tonumber(light) or 0;
		if (l < 0) then l = l + 36 elseif (l > 36) then l = l - 36 end
		if (l > 18) then part = 2; l = l - 18 end
		if (l == 0 and previous == 17 and not shutdown) then part = 2; l = 18 end -- "36 glyph fix", as in the ring light itself
		local glyph = (part == 2) and l + 18 or l;
		-- Same rules as EAP's sg_atlantis: incoming ring = glyphs stay lit until the ring is turned off, dialing ring = the spinning one.
		if (inbound) then
			if (glyph == 0) then
				ent.EAPCompatGlyphsOn = {};
				ent.EAPCompatGlyphAll = false;
			elseif (all == true or ent.EAPCompatRingOn == true or (atlantis and glyph == 36)) then
				ent.EAPCompatGlyphAll = true;
			else
				ent.EAPCompatGlyphsOn = ent.EAPCompatGlyphsOn or {};
				ent.EAPCompatGlyphsOn[glyph] = true;
			end
		else
			ent.EAPCompatGlyphDial = glyph;
		end
		return result;
	end
end

local function WithCapRingOnFlag(Real)
	return function(self, k, ...)
		if (k ~= "Turn on ring light") then return Real(self, k, ...) end
		local ent = ThisGate(self);
		ent.EAPCompatRingOn = true;
		local ok, result = pcall(Real, self, k, ...);
		ent.EAPCompatRingOn = nil;
		if (not ok) then error(result, 0) end
		return result;
	end
end

local function WithAllLitInstantOpen(Real)
	return function(self, ...)
		local result = Real(self, ...);
		if (type(result) == "table") then
			for _, step in ipairs(result) do
				if (step.f == self.RingLight and type(step.v) == "table" and step.v[2] == 36 and step.v[3] == true and step.v[4] == nil) then
					step.v = { step.v[1], 36, true, false, false, true };
				end
			end
		end
		return result;
	end
end

function EAP.Compat.PatchAtlantisGlyphTracking()
	local stored = scripted_ents.GetStored("stargate_atlantis");
	if (not stored or not stored.t or not stored.t.RingLight or not stored.t.TriggerInput
		or not stored.t.Sequence or not stored.t.Sequence.InstantOpen) then
		MsgN("[EAP Compat] WARNING: couldn't find 'stargate_atlantis' RingLight/TriggerInput/InstantOpen to track the lit glyphs - were they really registered yet?");
		return;
	end
	if (stored.t.EAPCompatGlyphTrackingPatched) then return end
	stored.t.RingLight = WithCapGlyphTracking(stored.t.RingLight);
	stored.t.TriggerInput = WithCapRingOnFlag(stored.t.TriggerInput);
	stored.t.Sequence.InstantOpen = WithAllLitInstantOpen(stored.t.Sequence.InstantOpen);
	-- Gates already spawned run on their own copies of the class table / sequence table.
	for _, ent in ipairs(ents.FindByClass("stargate_atlantis")) do
		if (IsValid(ent) and ent.IsStargate and ent:GetClass() == "stargate_atlantis") then
			ent.RingLight = WithCapGlyphTracking(ent.RingLight);
			ent.TriggerInput = WithCapRingOnFlag(ent.TriggerInput);
			local sequence = ent.Sequence;
			if (sequence and rawget(sequence, "InstantOpen")) then
				sequence.InstantOpen = WithAllLitInstantOpen(rawget(sequence, "InstantOpen"));
			end
		end
	end
	stored.t.EAPCompatGlyphTrackingPatched = true;
end

-- Glyphs on the Pegasus ring, read from the ring model like EAP does: each of its 2 parts has a bodygroup with
-- one state per glyph, plus "off". 36 is only the fallback if the model can't be read.
local CAP_GLYPH_COUNT = 36;
local function CapGlyphCount(ent)
	local ring = ent.Ring and ent.Ring.Incoming;
	local part = ring and ring[1];
	if (IsValid(part)) then
		local count = part:GetBodygroupCount(0);
		if (count and count > 1) then return 2*(count-1) end
	end
	return CAP_GLYPH_COUNT;
end

-- Returns true/false for a CAP Pegasus gate, nil for any other gate.
local function CapGlyphIsLit(ent, n)
	if (ent:GetClass() ~= "stargate_atlantis") then return nil end
	n = tonumber(n);
	if (not n or n ~= math.floor(n) or n < 1 or n > CapGlyphCount(ent)) then return false end
	return ent.EAPCompatGlyphAll == true or (ent.EAPCompatGlyphsOn ~= nil and ent.EAPCompatGlyphsOn[n] == true) or ent.EAPCompatGlyphDial == n;
end

function EAP.Compat.MergeE2StargateGlyphIsActivated()
	if (not wire_expression2_funcs or not registerFunction) then
		MsgN("[EAP Compat] WARNING: Expression 2 isn't loaded yet - 'stargateGlyphIsActivated' not merged.");
		return;
	end
	local changed = false;

	-- Each signature: the entity variant checks ownership like the rest of the extension, the wirelink one doesn't.
	for _, def in ipairs({ { "e:", true }, { "xwl:", false } }) do
		local signature = "stargateGlyphIsActivated(" .. def[1] .. "n)";
		local checkOwner = def[2];
		local entry = wire_expression2_funcs[signature];
		if (entry and entry.EAPCompatGlyph) then continue end -- Already merged (E2 keeps the same entry until it is reloaded)
		local Original = entry and entry[3];
		local function Merged(self, args)
			local this, n = args[1], args[2];
			if (not IsValid(this) or not this.IsStargate) then return -1 end
			if (checkOwner and not (isOwner(self, this) or self.player:IsAdmin())) then return -1 end
			if (n ~= n or n ~= math.floor(n) or n < 1 or n > CapGlyphCount(this)) then
				if (this:GetClass() == "stargate_atlantis") then return -1 end -- Out of range for CAP's Pegasus
			end
			local lit = CapGlyphIsLit(this, n);
			if (lit ~= nil) then return lit and 1 or 0 end
			if (Original) then return Original(self, args) end
			-- EAP's extension is shadowed by CAP's: answer for EAP's Pegasus gates ourselves.
			if (not this.GlyphIsLit or not this.GetGlyphCount or n ~= n or n ~= math.floor(n) or n < 1 or n > this:GetGlyphCount()) then return -1 end
			return this:GlyphIsLit(n) and 1 or 0;
		end
		if (entry) then
			entry[3] = Merged;
		else
			registerFunction("stargateGlyphIsActivated", def[1] .. "n", "n", Merged, 5, { "this", "glyph" }, { legacy = false });
			entry = wire_expression2_funcs[signature];
		end
		if (entry) then entry.EAPCompatGlyph = true end
		changed = true;
		MsgN("[EAP Compat] E2 function '" .. signature .. "' merged for CAP Pegasus gates.");
	end
	-- The editor (client side) only knows the functions the server sent when the player joined: send them again.
	if (changed and wire_expression2_sendfunctions) then
		for _, ply in ipairs(player.GetAll()) do wire_expression2_sendfunctions(ply); end
	end
end

-- Expression 2 rebuilds its function registry on "wire_expression2_reload": merge again afterwards, and once more a
-- few seconds after the map started in case E2 was not ready when the patches were installed.
hook.Add("Expression2Reloaded", "EAPCompat_E2GlyphIsActivated", function()
	if (Lib.IsCapDetected) then
		EAP.Compat.MergeE2StargateGetRingAngle();
		EAP.Compat.MergeE2StargateGlyphIsActivated();
		EAP.Compat.MergeE2StargateTargetAddress();
		EAP.Compat.MergeE2StargateInHorizon();
	end
end);

-- ===========================================================================
-- 6g. stargateTargetAddress() / stargateTargetGroup() / stargateTargetDialingAddress() for every scripting backend
-- ===========================================================================
-- What the gate dialling a destination looks like, handed to scripts only once the destination has activated itself (see
-- Lib.RecordInboundSource / Lib.GetInboundSourceInfo in server/general.lua, which only rely on the addon-agnostic .IsStargate / .Target /
-- .Active / .Outbound / GetGateAddress() / GetGateGroup()).
--   a) CAP's FindGate (the code telling the destination who is calling) is wrapped to take the snapshot EAP's own takes (PatchCapInboundSource);
--   b) EAP's extension files define the functions (E2, ExpAdv2, Starfall). When CAP's identically-named files are the ones that run
--      (see section 6), they don't exist: they are registered here, with the same behaviour, so they work on EAP and CAP gates alike.

local INBOUND_FUNCTIONS = {
	{ "stargateTargetAddress", "address", "Returns the address of the gate dialling this one (empty until this gate has activated itself, or if hidden)." },
	{ "stargateTargetGroup", "group", "Returns the group of the gate dialling this one (empty until this gate has activated itself, or if hidden)." },
	{ "stargateTargetDialingAddress", "dialing", "Returns the dialling address as sent to the Dialing Address output (address + point of origin + 8th/9th chevron), all at once, once this gate has activated itself." },
};

function EAP.Compat.PatchCapInboundSource()
	local stored = scripted_ents.GetStored("stargate_base");
	if (not stored or not stored.t or not stored.t.FindGate or not Lib.RecordInboundSource) then
		MsgN("[EAP Compat] WARNING: couldn't find 'stargate_base' FindGate to track the inbound source gate - was it really registered yet?");
		return;
	end
	if (stored.t.EAPCompatInboundSourcePatched) then return end
	stored.t.FindGate = Lib.RecordInboundSource(stored.t.FindGate);
	-- Gates already spawned run on their own copy of the class table.
	for _, ent in ipairs(ents.FindByClass("stargate_*")) do
		if (IsValid(ent) and ent.IsStargate and ent.FindGate and string.sub(ent:GetClass(), 1, 9) == "stargate_" and not ent.EAPCompatInboundSourcePatched) then
			ent.FindGate = Lib.RecordInboundSource(ent.FindGate);
			ent.EAPCompatInboundSourcePatched = true;
		end
	end
	stored.t.EAPCompatInboundSourcePatched = true;
end

function EAP.Compat.MergeE2StargateTargetAddress()
	if (not wire_expression2_funcs or not registerFunction) then return end
	local changed = false;
	for _, def in ipairs({ { "e:", true }, { "xwl:", false } }) do
		local checkOwner = def[2];
		for _, fn in ipairs(INBOUND_FUNCTIONS) do
			local signature = fn[1] .. "(" .. def[1] .. ")";
			if (wire_expression2_funcs[signature]) then continue end -- EAP's extension is the one running (or already merged)
			local field = fn[2];
			registerFunction(fn[1], def[1], "s", function(self, args)
				local this = args[1];
				if (not IsValid(this) or not this.IsStargate) then return "" end
				if (checkOwner and not (isOwner(self, this) or self.player:IsAdmin())) then return "" end
				return Lib.GetInboundSourceField(this, field);
			end, 5, { "this" }, { legacy = false });
			changed = true;
			MsgN("[EAP Compat] E2 function '" .. signature .. "' registered.");
		end
	end
	if (changed and wire_expression2_sendfunctions) then
		for _, ply in ipairs(player.GetAll()) do wire_expression2_sendfunctions(ply); end
	end
end

-- ExpAdv2: re-adding a VM function with the same name and signature overwrites it (same as in section 6c), with the same behaviour as EAP's.
function EAP.Compat.MergeExpAdv2StargateTargetAddress()
	if (not WireLib or not EXPADV) then return end
	local Component = EXPADV.GetComponent("stargate");
	if (not Component) then return end

	for _, fn in ipairs(INBOUND_FUNCTIONS) do
		local field = fn[2];
		Component:AddVMFunction( fn[1], "e:", "s", function( Context, Trace, Entity )
			if (not IsValid(Entity) or not Entity.IsStargate or not EXPADV.PPCheck(Context, Entity)) then return "" end
			return Lib.GetInboundSourceField(Entity, field);
		end)
		Component:AddFunctionHelper( fn[1], "e:", fn[3] )

		Component:AddVMFunction( fn[1], "wl:", "s", function( Context, Trace, Entity )
			if (not IsValid(Entity) or not Entity.IsStargate) then return "" end
			return Lib.GetInboundSourceField(Entity, field);
		end)
		Component:AddFunctionHelper( fn[1], "wl:", fn[3] )
	end
end

-- Starfall: only defined when the method is missing (same shared methods tables as section 6d).
function EAP.Compat.MergeStarfallStargateTargetAddress()
	if (not SF or not SF.Entities) then return end

	local function canModify(ply, ent)
		return SF.Entities.GetOwner(ent) == ply or game.SinglePlayer() and ent.GateSpawnerSpawned;
	end

	local ents_methods = SF.Entities.Methods;
	local wl_methods = SF.Wire and SF.Wire.WlMethods;
	for _, fn in ipairs(INBOUND_FUNCTIONS) do
		local name, field = fn[1], fn[2];
		if (ents_methods and not ents_methods[name]) then
			local ents_metatable = SF.Entities.Metatable;
			local unwrap = SF.Entities.Unwrap;
			ents_methods[name] = function(self)
				SF.CheckType( self, ents_metatable );
				local this = unwrap( self );
				if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
				if not this.IsStargate then return false, "entity is not stargate" end
				return Lib.GetInboundSourceField(this, field);
			end
		end
		if (wl_methods and not wl_methods[name]) then
			local wl_metatable = SF.Wire.WlMetatable;
			local wl_unwrap = SF.Wire.WlUnwrap;
			wl_methods[name] = function(self)
				SF.CheckType( self, wl_metatable );
				local this = wl_unwrap( self );
				if not SF.Permissions.check( SF.instance.player, nil, "wire.wirelink.read" ) then return false, "Insufficient permissions" end
				if not this.IsStargate then return false, "entity is not stargate" end
				return Lib.GetInboundSourceField(this, field);
			end
		end
	end
end

-- ===========================================================================
-- 6h. stargateInHorizon() / stargateInHorizonCount() for every scripting backend
-- ===========================================================================
-- Entities (even partly) inside a gate's event horizon (see Lib.GetEntitiesInHorizon in server/general.lua, which only relies on the
-- addon-agnostic .IsStargate / .EventHorizon, so it answers for CAP gates too). Same rule as 6g: EAP's extension files define the functions;
-- when CAP's identically-named files are the ones that run, they don't exist and are registered here with the same behaviour.

local HORIZON_HELP = {
	array = "Returns the entities that are, even partly, inside the event horizon of the gate (anything still inside when it closes is destroyed).",
	count = "Returns how many entities are, even partly, inside the event horizon of the gate (anything still inside when it closes is destroyed).",
};

function EAP.Compat.MergeE2StargateInHorizon()
	if (not wire_expression2_funcs or not registerFunction) then return end
	local changed = false;
	for _, def in ipairs({ { "e:", true }, { "xwl:", false } }) do
		local checkOwner = def[2];
		for _, fn in ipairs({ { "stargateInHorizon", "r", {} }, { "stargateInHorizonCount", "n", 0 } }) do
			local signature = fn[1] .. "(" .. def[1] .. ")";
			if (wire_expression2_funcs[signature]) then continue end -- EAP's extension is the one running (or already merged)
			local isList = fn[2] == "r";
			registerFunction(fn[1], def[1], fn[2], function(self, args)
				local this = args[1];
				if (not IsValid(this) or not this.IsStargate) then return isList and {} or 0 end
				if (checkOwner and not (isOwner(self, this) or self.player:IsAdmin())) then return isList and {} or 0 end
				local list = Lib.GetEntitiesInHorizon(this);
				return isList and list or #list;
			end, 5, { "this" }, { legacy = false });
			changed = true;
			MsgN("[EAP Compat] E2 function '" .. signature .. "' registered.");
		end
	end
	if (changed and wire_expression2_sendfunctions) then
		for _, ply in ipairs(player.GetAll()) do wire_expression2_sendfunctions(ply); end
	end
end

function EAP.Compat.MergeExpAdv2StargateInHorizon()
	if (not WireLib or not EXPADV) then return end
	local Component = EXPADV.GetComponent("stargate");
	if (not Component) then return end

	for _, kind in ipairs({ "e:", "wl:" }) do
		local checkOwner = (kind == "e:");
		Component:AddVMFunction( "stargateInHorizon", kind, "ar", function( Context, Trace, Entity )
			local result = { __type = "e" };
			if (not IsValid(Entity) or not Entity.IsStargate or (checkOwner and not EXPADV.PPCheck(Context, Entity))) then return result end
			for _, e in ipairs(Lib.GetEntitiesInHorizon(Entity)) do result[#result + 1] = e end
			return result;
		end)
		Component:AddFunctionHelper( "stargateInHorizon", kind, HORIZON_HELP.array )

		Component:AddVMFunction( "stargateInHorizonCount", kind, "n", function( Context, Trace, Entity )
			if (not IsValid(Entity) or not Entity.IsStargate or (checkOwner and not EXPADV.PPCheck(Context, Entity))) then return 0 end
			return #Lib.GetEntitiesInHorizon(Entity);
		end)
		Component:AddFunctionHelper( "stargateInHorizonCount", kind, HORIZON_HELP.count )
	end
end

function EAP.Compat.MergeStarfallStargateInHorizon()
	if (not SF or not SF.Entities) then return end

	local function canModify(ply, ent)
		return SF.Entities.GetOwner(ent) == ply or game.SinglePlayer() and ent.GateSpawnerSpawned;
	end

	local wrap = SF.Entities.Wrap;
	local function build(this)
		local out = {};
		for i, e in ipairs(Lib.GetEntitiesInHorizon(this)) do out[i] = wrap(e) end
		return out;
	end

	local ents_methods = SF.Entities.Methods;
	local wl_methods = SF.Wire and SF.Wire.WlMethods;
	if (ents_methods) then
		local ents_metatable = SF.Entities.Metatable;
		local unwrap = SF.Entities.Unwrap;
		if (not ents_methods.stargateInHorizon) then
			ents_methods.stargateInHorizon = function(self)
				SF.CheckType( self, ents_metatable );
				local this = unwrap( self );
				if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
				if not this.IsStargate then return false, "entity is not stargate" end
				return build(this);
			end
		end
		if (not ents_methods.stargateInHorizonCount) then
			ents_methods.stargateInHorizonCount = function(self)
				SF.CheckType( self, ents_metatable );
				local this = unwrap( self );
				if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
				if not this.IsStargate then return false, "entity is not stargate" end
				return #Lib.GetEntitiesInHorizon(this);
			end
		end
	end
	if (wl_methods) then
		local wl_metatable = SF.Wire.WlMetatable;
		local wl_unwrap = SF.Wire.WlUnwrap;
		if (not wl_methods.stargateInHorizon) then
			wl_methods.stargateInHorizon = function(self)
				SF.CheckType( self, wl_metatable );
				local this = wl_unwrap( self );
				if not SF.Permissions.check( SF.instance.player, nil, "wire.wirelink.read" ) then return false, "Insufficient permissions" end
				if not this.IsStargate then return false, "entity is not stargate" end
				return build(this);
			end
		end
		if (not wl_methods.stargateInHorizonCount) then
			wl_methods.stargateInHorizonCount = function(self)
				SF.CheckType( self, wl_metatable );
				local this = wl_unwrap( self );
				if not SF.Permissions.check( SF.instance.player, nil, "wire.wirelink.read" ) then return false, "Insufficient permissions" end
				if not this.IsStargate then return false, "entity is not stargate" end
				return #Lib.GetEntitiesInHorizon(this);
			end
		end
	end
end

-- ===========================================================================
-- 7. Dialing-UI address-list bridge (cross-addon net messages)
-- ===========================================================================
-- Each addon's dial/computer/DHD menu (lua/.../vgui/stargatemenus.lua) keeps
-- its OWN private client-side table of known gates (a local upvalue, not a
-- global - not reachable from here), populated only by listening for its
-- OWN net messages. A gate's ENT:SendGateInfo()/ENT:RefreshGateList() (one
-- call per field: address, group, name, private, blocked, locale, galaxy,
-- class, pos) broadcasts those net messages - but EAP and CAP picked
-- DIFFERENT net-string names for the exact same mechanism:
--   EAP: "RefreshGatesList" / "RemoveGatesFromList" / "RemoveGatesList"
--   CAP: "RefreshGateList"  / "RemoveGateFromList"   / "RemoveGateList"
-- (names, payload layout - EntIndex/Class/IsGroupStargate/field/type/value -
-- and call sites confirmed identical in both addons' sg_base/stargate_base
-- modules/lib.lua and server/spawner.lua). So a CAP gate's broadcast is
-- never heard by EAP's client code (wrong net-string name) and vice versa:
-- the FindByClass bridge (shared/init.lua) already made each addon's code
-- SEE the other's gates, but this networking layer is a second, separate
-- hop that bridge never touched, which is why no address from the other
-- addon ever reaches either side's dial UI.
--
-- Since the wire format is identical, the fix doesn't need to touch either
-- vgui file (would mean editing EAP's own non-compatibility code, and we
-- have no legal access to CAP's client table anyway): we wrap each addon's
-- ENT:RefreshGateList/ENT:RemoveGateFromList to ALSO re-send the exact same
-- payload under the OTHER addon's net-string name, right after the real
-- call. Both addons already register all four net-strings themselves
-- (util.AddNetworkString, called unconditionally by each addon's own
-- lib.lua) whenever they're both loaded, so there's nothing new to
-- register here.

function EAP.Compat.PatchGateAddressBroadcast()
	local eapStored = scripted_ents.GetStored("sg_base");
	local capStored = scripted_ents.GetStored("stargate_base");
	if (not eapStored or not eapStored.t or not capStored or not capStored.t) then
		MsgN("[EAP Compat] WARNING: couldn't find 'sg_base' and/or 'stargate_base' to bridge the address-list net messages - were they really registered yet?");
		return;
	end
	if (eapStored.t.EAPCompatAddressBridgePatched) then return end

	-- The client dial menus filter gates by class literal (e.g. the supergate
	-- menu only lists v.class == its own addon's supergate class), so the class
	-- is sent translated into the receiving addon's namespace.
	local function ResendRefresh(netName, classMap, self, type, value, typ, pl)
		if (not IsValid(self.Entity)) then return end
		local class = self.Entity:GetClass();
		net.Start(netName);
		net.WriteInt(self.Entity:EntIndex(), 16);
		net.WriteString(classMap[class] or class);
		net.WriteBit(self.IsGroupStargate);
		net.WriteString(type);
		net.WriteString(typ or "");
		if (typ == "bool") then
			net.WriteBit(value);
		elseif (typ == "vector") then
			net.WriteVector(value);
		else
			net.WriteString(value);
		end
		if (pl) then
			net.Send(pl);
		else
			net.Broadcast();
		end
	end

	local RealEapRefresh = eapStored.t.RefreshGateList;
	if (RealEapRefresh) then
		eapStored.t.RefreshGateList = function(self, type, value, typ, pl)
			RealEapRefresh(self, type, value, typ, pl);
			ResendRefresh("RefreshGateList", EAP_TO_CAP, self, type, value, typ, pl); -- CAP's name
		end
	end

	local RealCapRefresh = capStored.t.RefreshGateList;
	if (RealCapRefresh) then
		capStored.t.RefreshGateList = function(self, type, value, typ, pl)
			RealCapRefresh(self, type, value, typ, pl);
			ResendRefresh("RefreshGatesList", CAP_TO_EAP, self, type, value, typ, pl); -- EAP's name
		end
	end

	local function ResendRemove(netName, self)
		if (not IsValid(self.Entity)) then return end
		net.Start(netName);
		net.WriteInt(self.Entity:EntIndex(), 16);
		net.Broadcast();
	end

	local RealEapRemove = eapStored.t.RemoveGateFromList;
	if (RealEapRemove) then
		eapStored.t.RemoveGateFromList = function(self)
			RealEapRemove(self);
			ResendRemove("RemoveGateFromList", self); -- CAP's name
		end
	end

	local RealCapRemove = capStored.t.RemoveGateFromList;
	if (RealCapRemove) then
		capStored.t.RemoveGateFromList = function(self)
			RealCapRemove(self);
			ResendRemove("RemoveGatesFromList", self); -- EAP's name
		end
	end

	eapStored.t.EAPCompatAddressBridgePatched = true;
	capStored.t.EAPCompatAddressBridgePatched = true;
end

-- Rarer case: the gatespawner's "Restored" full-list-reset broadcast (map
-- save/load edge case, lua/.../server/spawner.lua), a plain global function
-- rather than an ENT method - same "wrap, call through, also re-fire under
-- the other name" principle, just without the metatable/BaseClass angle.
function EAP.Compat.PatchGateSpawnerRestoredBroadcast()
	if (not Lib.GateSpawner or not StarGate.GateSpawner) then
		MsgN("[EAP Compat] WARNING: couldn't find Lib.GateSpawner and/or StarGate.GateSpawner to bridge the gatespawner-restore net messages - were they really loaded yet?");
		return;
	end
	if (EAP.Compat.EAPCompatGateSpawnerRestoredPatched) then return end

	local RealEapRestored = Lib.GateSpawner.Restored;
	if (RealEapRestored) then
		Lib.GateSpawner.Restored = function(...)
			RealEapRestored(...);
			net.Start("RemoveGateList"); -- CAP's name
			net.WriteBit(true);
			net.Broadcast();
		end
	end

	local RealCapRestored = StarGate.GateSpawner.Restored;
	if (RealCapRestored) then
		StarGate.GateSpawner.Restored = function(...)
			RealCapRestored(...);
			net.Start("RemoveGatesList"); -- EAP's name
			net.WriteBit(true);
			net.Broadcast();
		end
	end

	EAP.Compat.EAPCompatGateSpawnerRestoredPatched = true;
end

-- ===========================================================================
-- 7b. Pegasus gate, inbound slow dial: normal Pegasus inbound animation (CAP)
-- ===========================================================================
-- When a gate using the "new slow dial" (SG1, Movie, Infinity, Universe, ...)
-- dials a Pegasus gate in slow mode, CAP's stargate_atlantis does not run its
-- normal inbound sequence but Sequence:InstantOpen(): the whole ring and all the
-- chevrons light up at once, so "Active Glyph" jumps straight to 36 and wire
-- scripts never see the glyphs one after the other, as they do for a
-- Pegasus -> Pegasus dial. EAP's own sg_atlantis plays its normal inbound
-- sequence in that case; CAP's files are not ours to edit, so here:
--   a) stargate_atlantis' Sequence:Dial() is wrapped: for that call only, the
--      source gate is made to look like a "classic" one (IsNewSlowDial off), so
--      the normal inbound sequence is built; its length ("lead") is remembered on the
--      Pegasus gate and a wait for the source's lock is appended to it;
--   b) the source gate's RunActions() is wrapped: its action list holds the step
--      that resumes the paused destination right before the last chevron locks.
--      Lib.ShiftTargetUnpause() adds an earlier resume (the length of the animation
--      before it, computed from both action lists - no chevron count involved)
--      and turns the original one into the release the destination waits for at
--      the end of its animation (Lib.SlowDialBarrier), so both event horizons
--      still open together whatever the ring spin times were.
-- A dial from a DHD button by button doesn't go through any of this.

-- ("InboundSlowLead" is the same field EAP's own sg_atlantis sets, so EAP <-> CAP pairs work in both directions.)

local function WithClassicInboundSlowDial(Real)
	return function(self, inbound, fast, ...)
		local ent = self.Entity;
		local t = IsValid(ent) and ent.Target;
		if (not (inbound and not fast and t and IsValid(t) and t.IsNewSlowDial)) then
			if (IsValid(ent)) then ent.InboundSlowLead = nil; end
			return Real(self, inbound, fast, ...);
		end
		local tbl = t:GetTable();
		local oldFlag, oldSlowTime = rawget(tbl, "IsNewSlowDial"), rawget(tbl, "DialSlowTime");
		tbl.IsNewSlowDial = false;
		tbl.DialSlowTime = function() return 0 end;
		local ok, result = pcall(Real, self, inbound, fast, ...);
		tbl.IsNewSlowDial, tbl.DialSlowTime = oldFlag, oldSlowTime;
		if (not ok) then error(result, 0) end

		ent.InboundSlowLead = nil;
		ent.InboundSlowReleased = nil;
		ent.InboundSlowReady = nil;
		ent.InboundSlowWaitingSource = nil;
		if (type(result) == "table") then
			-- Same as EAP's sg_atlantis: our animation is over after "total" seconds, of which 0.5 passed before the source paused us.
			local total = 0;
			for _, step in ipairs(result) do total = total + (tonumber(step.d) or 0) end
			ent.InboundSlowLead = total - 0.5 + 0.2;
			ent.InboundSlowReleased = false;
			ent.InboundSlowReady = false;
			-- Wait for the source's lock, then open after what the former instant sequence still took after its resume
			table.insert(result, { f = Lib.SlowDialBarrier, v = { ent }, d = ent:CalcDelaySlow(t, true) + 0.1 });
		end
		return result;
	end
end

local function WithTargetUnpauseShift(Real)
	return function(self, action, ...)
		local target = self.Target;
		if (type(action) == "table" and target and IsValid(target) and target.InboundSlowLead) then
			-- Other action lists (no resume step) can pass through here first: the lead is kept until the dial list is seen
			-- (Lib.SlowDialBarrier's timeout is the safety net if it never comes).
			if (Lib.ShiftTargetUnpause(self, action, target.InboundSlowLead)) then
				target.InboundSlowLead = nil;
			end
		end
		return Real(self, action, ...);
	end
end

function EAP.Compat.PatchAtlantisInboundSlowDial()
	local atlantis = scripted_ents.GetStored("stargate_atlantis");
	local base = scripted_ents.GetStored("stargate_base");
	if (not atlantis or not atlantis.t or not atlantis.t.Sequence or not atlantis.t.Sequence.Dial
		or not base or not base.t or not base.t.RunActions) then
		MsgN("[EAP Compat] WARNING: couldn't find 'stargate_atlantis' Sequence.Dial and/or 'stargate_base' RunActions to play the Pegasus inbound sequence - were they really registered yet?");
		return;
	end
	if (atlantis.t.EAPCompatInboundSlowDialPatched) then return end
	atlantis.t.Sequence.Dial = WithClassicInboundSlowDial(atlantis.t.Sequence.Dial);
	base.t.RunActions = WithTargetUnpauseShift(base.t.RunActions);
	-- Gates already spawned run on their own copies (ENT:RegisterSequenceTable for the sequences, a copy of the class table for the methods).
	for _, ent in ipairs(ents.FindByClass("stargate_*")) do
		if (IsValid(ent) and ent.IsStargate and string.sub(ent:GetClass(), 1, 9) == "stargate_") then
			local sequence = ent.Sequence;
			if (ent:GetClass() == "stargate_atlantis" and sequence and rawget(sequence, "Dial")) then
				sequence.Dial = WithClassicInboundSlowDial(rawget(sequence, "Dial"));
			end
			if (ent.RunActions) then ent.RunActions = WithTargetUnpauseShift(ent.RunActions); end
		end
	end
	atlantis.t.EAPCompatInboundSlowDialPatched = true;
end

-- ===========================================================================
-- 8. Cross-addon gate-type recognition (dialing/activation)
-- ===========================================================================
-- sg_base and stargate_base are near-line-for-line forks of the same
-- original code: the core dial/link/open sequence (FindGate locating the
-- target entity, self.Target <-> target.Target, ActivateStargate, the
-- event horizon) works cross-addon already - plain Lua field writes and
-- identically-named methods, nothing to patch. What's left are a handful
-- of places where that shared code asks "is THIS CANDIDATE GATE a
-- supergate/Orlin/Atlantis/etc." by comparing GetClass() to ONE addon's
-- own literal, so a candidate from the OTHER addon silently fails the
-- check:
--   - GetAllGates() (modules/lib.lua): supergates get sorted into the
--     wrong bucket during address resolution if the candidate is the
--     other addon's supergate class. Fixed by reimplementing this one
--     (short, simple) using the already-correct .IsSupergate flag instead
--     of a class-literal compare - true in both addons for their own
--     supergate type (sg_supergate/shared.lua, stargate_supergate/shared.lua).
--   - WormHoleJump() (modules/lib.lua): Orlin exclusion and supergate
--     light-up/sequence choice, when the jump TARGET is the other addon's
--     gate.
--   - FindGate()/FindGateGalaxy() (modules/lib.lua): the "prefer an
--     Atlantis gate among several address matches" tie-break, when one of
--     the matches is the other addon's Atlantis gate.
--   - PressButton() (dhdbase/dhd_base init.lua): random-dial's Universe
--     guard, the Orlin-already-open guard, and the ring-rotation visual
--     sync, all keyed off the DHD's currently locked gate's class.
-- These last three are large, complex functions - reimplementing them
-- here would freeze a copy that stops tracking future EAP/CAP updates
-- (the same "loses dynamism" trade-off discussed for the stools earlier
-- in this project). Instead we wrap just their entry point with
-- WithSpoofedClassFamilies (section 1): for the duration of the real
-- call, every candidate entity of a class the bridge already knows about
-- reports its opposite-addon equivalent class, so the real function's own
-- GetClass()==literal checks inside just work, unmodified and uncopied.

function EAP.Compat.PatchGetAllGatesSupergate()
	local eapStored = scripted_ents.GetStored("sg_base");
	local capStored = scripted_ents.GetStored("stargate_base");
	if (not eapStored or not eapStored.t or not capStored or not capStored.t) then
		MsgN("[EAP Compat] WARNING: couldn't find 'sg_base' and/or 'stargate_base' to fix GetAllGates() - were they really registered yet?");
		return;
	end
	if (eapStored.t.EAPCompatGetAllGatesPatched) then return end

	local function FixedGetAllGates(self, closed)
		local sg = {};
		local selfIsSuper = self.Entity.IsSupergate or false;
		for _, v in pairs(ents.FindByClass("sg_*")) do -- bridged: also returns CAP's stargate_*
			if (v.IsStargate and not (closed and (v.IsOpen or v.Dialling))) then
				if ((v.IsSupergate or false) == selfIsSuper) then
					table.insert(sg, v);
				end
			end
		end
		return sg;
	end

	eapStored.t.GetAllGates = FixedGetAllGates;
	capStored.t.GetAllGates = FixedGetAllGates; -- ents.FindByClass("sg_*")/("stargate_*") are both bridged to the same merged result, so one implementation serves both addons
	eapStored.t.EAPCompatGetAllGatesPatched = true;
	capStored.t.EAPCompatGetAllGatesPatched = true;
end

function EAP.Compat.PatchGateTypeAwareDialing()
	local eapStored = scripted_ents.GetStored("sg_base");
	local capStored = scripted_ents.GetStored("stargate_base");
	local eapDhdStored = scripted_ents.GetStored("dhdbase");
	local capDhdStored = scripted_ents.GetStored("dhd_base");
	if (not eapStored or not eapStored.t or not capStored or not capStored.t or not eapDhdStored or not eapDhdStored.t or not capDhdStored or not capDhdStored.t) then
		MsgN("[EAP Compat] WARNING: couldn't find sg_base/stargate_base/dhdbase/dhd_base to patch gate-type-aware dialing - were they really registered yet?");
		return;
	end
	if (eapStored.t.EAPCompatDialingPatched) then return end

	local function WrapWithFamilies(stored, methodName, classMap)
		local RealFn = stored.t[methodName];
		if (not RealFn) then return end
		stored.t[methodName] = function(self, ...)
			return EAP.Compat.WithSpoofedClassFamilies(classMap, RealFn, self, ...);
		end
	end

	for _, methodName in ipairs({ "WormHoleJump", "FindGate", "FindGateGalaxy" }) do
		WrapWithFamilies(eapStored, methodName, CAP_TO_EAP);
		WrapWithFamilies(capStored, methodName, EAP_TO_CAP);
	end

	WrapWithFamilies(eapDhdStored, "PressButton", CAP_TO_EAP);
	WrapWithFamilies(capDhdStored, "PressButton", EAP_TO_CAP);

	eapStored.t.EAPCompatDialingPatched = true;
end

-- ===========================================================================
-- 9. Cross-addon slow-dial synchronisation (action-timer pause routing)
-- ===========================================================================
-- Slow dialing started from the dialing UI (gate/DHD menu) makes the SOURCE
-- gate's own dial sequence pause, then resume, the DESTINATION gate's
-- pending "open" sequence so both event horizons open together:
--
--     action:Add({ f = self.PauseActions, v = { t, false, true }, d = 0 })
--     ...
--     action:Add({ f = self.PauseActions, v = { t, true,  true }, d = 0 })
--
-- Note what that really is: the SOURCE gate's PauseActions *function*,
-- called with the DESTINATION gate (t) as its "self". PauseActions finds
-- the timers to (un)pause by name, and that name is built from an
-- addon-specific prefix hard-coded in the function ("StarGate_<idx>_<n>"
-- in CAP, "Lib_<idx>_<n>" in EAP - the same prefix RunActions/StopActions
-- use to create/remove them). Between two gates of the SAME addon this is
-- harmless; across addons the source looks for timers named with ITS OWN
-- prefix, finds none of the destination's (named with the other prefix),
-- and silently pauses nothing - so the destination just runs its
-- "inbound slow dial" sequence unpaused and opens (event horizon)
-- immediately, while the source is still dialing chevron by chevron.
-- Dialing from a DHD button by button never goes through that pause
-- (nothing is pre-queued on the destination), and Atlantis/Pegasus never
-- pauses the destination - which matches what is observed in game.
--
-- Fix: route PauseActions to the function of the addon the entity being
-- (un)paused really belongs to. Both original function bodies are kept and
-- still do all the real work, so changes upstream stay picked up
-- automatically.

function EAP.Compat.PatchGateActionPause()
	local eapStored = scripted_ents.GetStored("sg_base");
	local capStored = scripted_ents.GetStored("stargate_base");
	if (not eapStored or not eapStored.t or not capStored or not capStored.t) then
		MsgN("[EAP Compat] WARNING: couldn't find 'sg_base' and/or 'stargate_base' to route PauseActions - were they really registered yet?");
		return;
	end
	if (eapStored.t.EAPCompatPauseActionsPatched) then return end

	local EapPauseActions = eapStored.t.PauseActions;
	local CapPauseActions = capStored.t.PauseActions;
	if (not EapPauseActions or not CapPauseActions) then
		MsgN("[EAP Compat] WARNING: sg_base and/or stargate_base have no PauseActions - nothing to route.");
		return;
	end

	-- NOTE: "self" is not always the entity itself. A gate pausing ITS OWN
	-- timers (v = { self, false } in the dial sequences) passes the sequence
	-- helper table, which only proxies to the gate through its .Entity
	-- field, whereas pausing the DESTINATION gate passes the entity (t).
	-- The original functions only ever use self.Entity, which works for
	-- both - so resolve the real entity the same way before asking for its
	-- class (calling GetClass() directly on that table is an error).
	local function MakeRouter(OwnFn)
		return function(self, ...)
			local ent = self.Entity;
			if (ent == nil) then ent = self; end
			if (isentity(ent) and ent:IsValid()) then
				local class = ent:GetClass();
				if (string.sub(class, 1, 9) == "stargate_") then
					local unpause, target = ...;
					if (not target) then Lib.TrackSlowDialWait(ent, unpause) end -- Own sequence waiting for the ring (slow dial), as in EAP's PauseActions
					return CapPauseActions(self, ...);
				elseif (string.sub(class, 1, 3) == "sg_") then
					return EapPauseActions(self, ...);
				end
			end
			return OwnFn(self, ...);
		end
	end

	eapStored.t.PauseActions = MakeRouter(EapPauseActions);
	capStored.t.PauseActions = MakeRouter(CapPauseActions);
	eapStored.t.EAPCompatPauseActionsPatched = true;
	capStored.t.EAPCompatPauseActionsPatched = true;
end

-- ===========================================================================
-- 10. Gate-list resync after a Group <-> Galaxy system switch (CAP gates)
-- ===========================================================================
-- Switching "stargate_group_system" makes every gate re-run its own
-- ChangeSystemType(), but nothing re-sends the gate info to the clients'
-- dial-menu caches, which keep entries cached while the other mode was active
-- (GetGateGroup() is "" in Galaxy mode ...): back in Group mode the menu
-- filters those gates out (it needs a non-empty group) although dialing still
-- works. EAP re-sends its own gates' info itself (Lib.ResyncGateList in
-- server/general.lua, called from Lib.ReloadSystem); CAP's equivalent
-- (StarGate.ReloadSystem) has the very same gap and is not ours to edit, so
-- CAP's gates are re-sent from here, once the switch has settled. Only CAP
-- classes are handled, so nothing is sent twice. Going through
-- ENT:SendGateInfo() -> ENT:RefreshGateList() also feeds the cross-addon
-- bridge of section 7, so both addons' menus are refreshed.

local SYSTEM_SWITCH_RESYNC_DELAY = 8; -- > ConvarsThink's 5s detection delay

function EAP.Compat.ResyncCapGateListAfterSystemSwitch()
	for _, ent in ipairs(ents.FindByClass("stargate_*")) do
		if (IsValid(ent) and ent.IsStargate and ent.SendGateInfo and string.sub(ent:GetClass(), 1, 9) == "stargate_") then
			ent:SendGateInfo();
		end
	end
end

function EAP.Compat.PatchSystemTypeResync()
	cvars.AddChangeCallback("stargate_group_system", function()
		timer.Create("EAPCompat_ResyncGateList", SYSTEM_SWITCH_RESYNC_DELAY, 1, function()
			EAP.Compat.ResyncCapGateListAfterSystemSwitch();
		end);
	end, "EAPCompat_ResyncGateList"); -- same identifier = replaced, never stacked
end

-- ===========================================================================
-- 11. Install everything
-- ===========================================================================

function EAP.Compat.InstallServerPatches()
	-- gate_nuke: let it recognize EAP gates/DHDs the same way it already
	-- recognizes CAP's own (its hard-coded "stargate_supergate" branch is
	-- the one known limitation documented in this file's header).
	EAP.Compat.ExtendArrayField("gate_nuke", "GateList", {
		"sg_sg1", "sg_atlantis", "sg_universe", "sg_orlin", "sg_movie", "sg_tollan", "sg_infinity",
	});
	EAP.Compat.ExtendArrayField("gate_nuke", "DHDList", {
		"dhd_milk", "dhd_atl", "dhd_uni", "dhd_inf",
	});

	-- sgc_server: ValidGates is the "this class can register with an SGC
	-- Server" allow-list.
	EAP.Compat.ExtendMapField("sgc_server", "ValidGates", {
		"sg_sg1", "sg_infinity", "sg_movie",
	});

	-- Ramps: GateFinder() replacement so each ramp also recognizes an EAP
	-- gate parked/constrained on it.
	EAP.Compat.PatchRampGateFinder("future_ramp");
	EAP.Compat.PatchRampGateFinder("goauld_ramp");
	EAP.Compat.PatchRampGateFinder("icarus_ramp");
	EAP.Compat.PatchRampGateFinder("sgc_ramp");
	EAP.Compat.PatchRampGateFinder("ramp_2", "stargate_dhd");
	-- ramp.lua and sgu_ramp.lua were checked and have no GateFinder to patch.

	-- Stools (CAP's own, patched to recognize EAP gates)
	for _, toolname in ipairs(SPOOFED_TOOLS) do
		EAP.Compat.PatchToolLeftClick(toolname);
	end

	-- Stools (EAP's own, patched to recognize CAP gates - mirror direction)
	for _, toolname in ipairs(SPOOFED_EAP_TOOLS) do
		EAP.Compat.PatchEapToolLeftClick(toolname);
	end

	-- Stools: make sure the patch actually reaches weapons already in
	-- players' hands, and every future tool-gun pickup from now on (see
	-- section 4c's header comment for why the two patches above, by
	-- themselves, are not enough).
	EAP.Compat.PatchToolInitializeTools();
	EAP.Compat.RepatchExistingToolguns();

	-- Weapon
	EAP.Compat.PatchVirusWeapon();

	-- Scripting backends (E2 / ExpAdv2 / Wire gates / Starfall)
	EAP.Compat.MergeE2StargateGetRingAngle();
	EAP.Compat.MergeE2StargateGlyphIsActivated();
	timer.Simple(5, EAP.Compat.MergeE2StargateGlyphIsActivated);
	EAP.Compat.PatchAtlantisGlyphTracking();
	EAP.Compat.MergeWireGateGetRingAngle();
	EAP.Compat.MergeExpAdv2StargateGetRingAngle();
	EAP.Compat.MergeStarfallStargateGetRingAngle();
	EAP.Compat.PatchCapInboundSource();
	EAP.Compat.MergeE2StargateTargetAddress();
	timer.Simple(5, EAP.Compat.MergeE2StargateTargetAddress);
	EAP.Compat.MergeExpAdv2StargateTargetAddress();
	EAP.Compat.MergeStarfallStargateTargetAddress();
	EAP.Compat.MergeE2StargateInHorizon();
	timer.Simple(5, EAP.Compat.MergeE2StargateInHorizon);
	EAP.Compat.MergeExpAdv2StargateInHorizon();
	EAP.Compat.MergeStarfallStargateInHorizon();

	-- Dialing UI: make each addon's gate address broadcasts also reach the
	-- other addon's client-side dial/computer/DHD menu (see section 7's
	-- header comment - different net-string names for an identical wire
	-- format).
	EAP.Compat.PatchGateAddressBroadcast();
	EAP.Compat.PatchGateSpawnerRestoredBroadcast();

	-- Dialing/activation: make the supergate/Orlin/Atlantis/etc. special
	-- cases inside GetAllGates/WormHoleJump/FindGate/FindGateGalaxy/
	-- PressButton recognize the other addon's gate types too (see
	-- section 8's header comment).
	EAP.Compat.PatchGetAllGatesSupergate();
	EAP.Compat.PatchGateTypeAwareDialing();
	EAP.Compat.PatchSupergateLightsSelf();

	-- Pegasus gate as the destination of a slow dial from another gate type:
	-- light the ring glyph by glyph (see section 7b).
	EAP.Compat.PatchAtlantisInboundSlowDial();

	-- Slow dial started from the dialing UI: make the source gate's pause of
	-- the destination gate's pending sequence also work across addons (see
	-- section 9's header comment).
	EAP.Compat.PatchGateActionPause();

	-- Dialing UI: refresh the clients' CAP gate list after a Group <-> Galaxy
	-- system switch (see section 10).
	EAP.Compat.PatchSystemTypeResync();
end

-- Unlike shared/init.lua's ents.FindByClass wrap (which only touches a
-- function pointer and works no matter when it runs), everything in this
-- file reaches into CAP's own tools/weapons/entities via
-- scripted_ents.GetStored()/weapons.GetStored() - which only returns
-- something once CAP has actually registered them. Per Garry's Mod's
-- documented Lua loading order, lua/autorun/* (which is where this file is
-- loaded from, through eap_include.lua) runs BEFORE lua/weapons/* and
-- lua/entities/* are scanned and registered - so calling
-- InstallServerPatches() immediately here would always find CAP's tools
-- and entities missing and silently do nothing.
-- So the patches are only installed on InitPostEntity, which fires after every
-- entity on the map - and therefore every addon's registration - is done.
hook.Add("InitPostEntity", "EAPCompat_InstallServerPatches", function()
	if (Lib.IsCapDetected) then
		EAP.Compat.InstallServerPatches();
	end
end);
