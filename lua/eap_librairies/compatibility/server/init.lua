-- EAP <-> CAP compatibility, server part. Loaded after compatibility/shared/init.lua, installed only when CAP is detected.
-- CAP's code is never edited: its registered entity, tool and weapon tables are patched once both addons have loaded.

EAP = EAP or {};
EAP.Compat = EAP.Compat or {};

local CAP_TO_EAP = EAP.Compat.CapToEap or {};
local EAP_TO_CAP = EAP.Compat.EapToCap or {};

-- CAP's tools test the exact CAP class of the entity they are used on, so they refused EAP's equivalents.
-- Runs fn while ent:GetClass() answers spoofedClass, for that one entity and that one call, then restores GetClass (also on error).
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

-- Same, for code that tests the class of several entities: every class found in classMap is answered with its mapped name.
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

-- Some CAP entities keep the class names they accept in a table on their registered ENT. Adds EAP's class names to such a list...
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

-- ...or to such a set (class name = true).
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

-- CAP ramps found their gate with a test on CAP's class names only, so an EAP gate welded on a CAP ramp was ignored.
local function IsBridgedGateClass(class, excludeClass)
	if (excludeClass and class == excludeClass) then return false end
	return class:find("stargate") ~= nil or class:find("^sg_") ~= nil;
end

-- Replaces the ramp's GateFinder() by one that accepts the gates of both addons (excludeClass: a class that must not count as a gate).
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

-- CAP tools whose LeftClick tests the CAP class of the entity aimed at.
local SPOOFED_TOOLS = { "bearing", "floorchevron", "goauld_iris", "stargate_iris", "supergate_dhd" };

-- Wraps a tool's LeftClick: when the entity aimed at has an equivalent in classMap, the original runs with that entity's class spoofed.
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

-- Patches a CAP tool so it also works on EAP's entities.
function EAP.Compat.PatchToolLeftClick(toolname)
	local stored = weapons.GetStored("gmod_tool");
	if (not stored or not stored.Tool or not stored.Tool[toolname]) then
		MsgN("[EAP Compat] WARNING: couldn't find CAP tool '"..toolname.."' to patch - was it really registered yet?");
		return;
	end
	WrapToolLeftClickObj(stored.Tool[toolname], EAP_TO_CAP);
end

-- EAP has the same class tests in its own tools: same fix the other way round, so they also work on CAP's entities.
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

-- Patching the stored tool table is not enough: every toolgun gets its own copy of the tools in InitializeTools, and toolguns that
-- already exist keep the unpatched copy.
local TOOLNAME_TO_MAP = {};
for _, toolname in ipairs(SPOOFED_TOOLS) do TOOLNAME_TO_MAP[toolname] = EAP_TO_CAP; end
for _, toolname in ipairs(SPOOFED_EAP_TOOLS) do TOOLNAME_TO_MAP[toolname] = CAP_TO_EAP; end

-- Re-applies the LeftClick wrap on the copies each new toolgun creates.
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

-- Applies it to the toolguns already handed out.
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

-- CAP's gate virus weapon tests the CAP class of the DHD or gate aimed at in SpawnProp: same spoofing as for the tools.
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

-- Scripting functions. Both addons ship their E2 / Wire gate / ExpAdv2 / Starfall stargate extensions under the same file paths, and
-- Garry's Mod only loads one file per path: the functions of the addon that won the path are the only ones registered, and they
-- test that addon's class names. The functions below are replaced, or added, so they answer for the gates of both addons.
--
-- stargateGetRingAngle: gate classes that have a ring, in both addons.
local MERGED_RING_ANGLE_CLASSES = {
	sg_movie = true, sg_sg1 = true, sg_infinity = true, sg_universe = true,
	stargate_movie = true, stargate_sg1 = true, stargate_infinity = true, stargate_universe = true,
};

-- Ring angle in degrees (0-360), read from the ring part (the gate itself for Universe), or nil if the gate has no ring.
local function GetMergedRingAngle(ent)
	local class = ent:GetClass();
	if (not MERGED_RING_ANGLE_CLASSES[class]) then return nil end
	local part = (class == "sg_universe" or class == "stargate_universe") and ent.Gate or ent.Ring;
	if (not IsValid(part)) then return nil end
	local angle = tonumber(math.NormalizeAngle(part:GetLocalAngles().r));
	if (angle < 0) then angle = angle + 360; end
	return angle;
end

-- E2: the function body is slot [3] of its entry in wire_expression2_funcs.
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

-- Wire gates: GateActions is the registry shared by both addons.
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

-- ExpAdv2: re-declares the function on the already registered "stargate" component.
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

-- Starfall: entity and wirelink methods.
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

-- CAP's sequences queue the supergate's DisActivateLights / LightUp / LightUps with the sequence table as self instead of the gate, so
-- the call failed on self:EntIndex() and the rest of the sequence never ran. The entity is resolved before the real function runs.
function EAP.Compat.PatchSupergateLightsSelf()
	local stored = scripted_ents.GetStored("stargate_supergate");
	if (not stored or not stored.t) then return end
	if (stored.t.EAPCompatLightsSelfPatched) then return end
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

-- stargateGlyphIsActivated(n) for CAP's Pegasus gate. EAP's sg_atlantis remembers which ring glyphs are lit (GlyphIsLit); CAP's
-- stargate_atlantis keeps no such state, so its ring functions are wrapped to record it.
--
-- The gate entity, whether self is the entity or a table holding it.
local function ThisGate(self)
	return (isentity(self.Entity) and self.Entity) or self;
end

-- Wraps RingLight(): same glyph maths as the ring light itself. On the incoming ring a glyph stays lit until the ring is turned off
-- (glyph 0); on the dialling ring only the spinning glyph counts. "all" marks every glyph lit at once.
local function WithCapGlyphTracking(Real)
	return function(self, light, inbound, shutdown, atlantis, all, ...)
		local ent = ThisGate(self);
		local previous = ent.SpinLight;
		local result = Real(self, light, inbound, shutdown, atlantis, all, ...);
		local part, l = 1, tonumber(light) or 0;
		if (l < 0) then l = l + 36 elseif (l > 36) then l = l - 36 end
		if (l > 18) then part = 2; l = l - 18 end
		if (l == 0 and previous == 17 and not shutdown) then part = 2; l = 18 end
		local glyph = (part == 2) and l + 18 or l;
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

-- Wraps TriggerInput(): the "Turn on ring light" input lights the whole ring through RingLight, flagged while it runs.
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

-- Wraps Sequence:InstantOpen(): its RingLight(36, true) step lights the whole ring, so the step is given the "all" argument.
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

-- Installs the three wraps on the registered class and on the Pegasus gates already spawned.
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

-- Number of glyphs on the ring, from the ring model's bodygroups (36 when it cannot be read).
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

-- true / false for a CAP Pegasus gate, nil for any other gate (left to EAP's own function).
local function CapGlyphIsLit(ent, n)
	if (ent:GetClass() ~= "stargate_atlantis") then return nil end
	n = tonumber(n);
	if (not n or n ~= math.floor(n) or n < 1 or n > CapGlyphCount(ent)) then return false end
	return ent.EAPCompatGlyphAll == true or (ent.EAPCompatGlyphsOn ~= nil and ent.EAPCompatGlyphsOn[n] == true) or ent.EAPCompatGlyphDial == n;
end

-- E2: wraps the existing function when EAP's extension is the one loaded, registers it when CAP's is. CAP Pegasus gates are answered
-- here, every other gate goes to the original function. The function list is sent again to the players when something changed.
function EAP.Compat.MergeE2StargateGlyphIsActivated()
	if (not wire_expression2_funcs or not registerFunction) then
		MsgN("[EAP Compat] WARNING: Expression 2 isn't loaded yet - 'stargateGlyphIsActivated' not merged.");
		return;
	end
	local changed = false;

	for _, def in ipairs({ { "e:", true }, { "xwl:", false } }) do
		local signature = "stargateGlyphIsActivated(" .. def[1] .. "n)";
		local checkOwner = def[2];
		local entry = wire_expression2_funcs[signature];
		if (entry and entry.EAPCompatGlyph) then continue end
		local Original = entry and entry[3];
		local function Merged(self, args)
			local this, n = args[1], args[2];
			if (not IsValid(this) or not this.IsStargate) then return -1 end
			if (checkOwner and not (isOwner(self, this) or self.player:IsAdmin())) then return -1 end
			if (n ~= n or n ~= math.floor(n) or n < 1 or n > CapGlyphCount(this)) then
				if (this:GetClass() == "stargate_atlantis") then return -1 end
			end
			local lit = CapGlyphIsLit(this, n);
			if (lit ~= nil) then return lit and 1 or 0 end
			if (Original) then return Original(self, args) end
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
	if (changed and wire_expression2_sendfunctions) then
		for _, ply in ipairs(player.GetAll()) do wire_expression2_sendfunctions(ply); end
	end
end

-- An E2 reload registers the extension functions again and drops the merges.
hook.Add("Expression2Reloaded", "EAPCompat_E2GlyphIsActivated", function()
	if (Lib.IsCapDetected) then
		EAP.Compat.MergeE2StargateGetRingAngle();
		EAP.Compat.MergeE2StargateGlyphIsActivated();
		EAP.Compat.MergeE2StargateTargetAddress();
		EAP.Compat.MergeE2StargateInHorizon();
	end
end);

-- stargateTargetAddress / Group / DialingAddress: { function name, field of the inbound source info, help text }.
local INBOUND_FUNCTIONS = {
	{ "stargateTargetAddress", "address", "Returns the address of the gate dialling this one (empty until this gate has activated itself, or if hidden)." },
	{ "stargateTargetGroup", "group", "Returns the group of the gate dialling this one (empty until this gate has activated itself, or if hidden)." },
	{ "stargateTargetDialingAddress", "dialing", "Returns the dialling address as sent to the Dialing Address output (address + point of origin + 8th/9th chevron), all at once, once this gate has activated itself." },
};

-- The source gate is recorded when a gate looks up its target (Lib.RecordInboundSource, server/general.lua). CAP gates get the same
-- wrap on FindGate, on the registered base and on the gates already spawned.
function EAP.Compat.PatchCapInboundSource()
	local stored = scripted_ents.GetStored("stargate_base");
	if (not stored or not stored.t or not stored.t.FindGate or not Lib.RecordInboundSource) then
		MsgN("[EAP Compat] WARNING: couldn't find 'stargate_base' FindGate to track the inbound source gate - was it really registered yet?");
		return;
	end
	if (stored.t.EAPCompatInboundSourcePatched) then return end
	stored.t.FindGate = Lib.RecordInboundSource(stored.t.FindGate);
	for _, ent in ipairs(ents.FindByClass("stargate_*")) do
		if (IsValid(ent) and ent.IsStargate and ent.FindGate and string.sub(ent:GetClass(), 1, 9) == "stargate_" and not ent.EAPCompatInboundSourcePatched) then
			ent.FindGate = Lib.RecordInboundSource(ent.FindGate);
			ent.EAPCompatInboundSourcePatched = true;
		end
	end
	stored.t.EAPCompatInboundSourcePatched = true;
end

-- E2: registered only when missing, i.e. when CAP's extension file is the one loaded.
function EAP.Compat.MergeE2StargateTargetAddress()
	if (not wire_expression2_funcs or not registerFunction) then return end
	local changed = false;
	for _, def in ipairs({ { "e:", true }, { "xwl:", false } }) do
		local checkOwner = def[2];
		for _, fn in ipairs(INBOUND_FUNCTIONS) do
			local signature = fn[1] .. "(" .. def[1] .. ")";
			if (wire_expression2_funcs[signature]) then continue end
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

-- ExpAdv2.
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

-- Starfall: added only when missing.
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

-- stargateInHorizon / stargateInHorizonCount (Lib.GetEntitiesInHorizon, server/general.lua, works on the gates of both addons).
local HORIZON_HELP = {
	array = "Returns the entities that are, even partly, inside the event horizon of the gate (anything still inside when it closes is destroyed).",
	count = "Returns how many entities are, even partly, inside the event horizon of the gate (anything still inside when it closes is destroyed).",
};

-- E2: registered only when missing.
function EAP.Compat.MergeE2StargateInHorizon()
	if (not wire_expression2_funcs or not registerFunction) then return end
	local changed = false;
	for _, def in ipairs({ { "e:", true }, { "xwl:", false } }) do
		local checkOwner = def[2];
		for _, fn in ipairs({ { "stargateInHorizon", "r", {} }, { "stargateInHorizonCount", "n", 0 } }) do
			local signature = fn[1] .. "(" .. def[1] .. ")";
			if (wire_expression2_funcs[signature]) then continue end
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

-- ExpAdv2: the entity array is a table tagged with its element type.
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

-- Starfall: added only when missing; entities are wrapped before being returned.
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

-- Each addon's dial menu fills its own client list of gates from its own net messages, and the two addons named the same messages
-- differently (EAP "RefreshGatesList" / "RemoveGatesFromList", CAP "RefreshGateList" / "RemoveGateFromList"), with the same layout.
-- A gate of one addon therefore never appeared in the other addon's menu. RefreshGateList and RemoveGateFromList of both gate bases
-- also send the same data under the other addon's message name.
function EAP.Compat.PatchGateAddressBroadcast()
	local eapStored = scripted_ents.GetStored("sg_base");
	local capStored = scripted_ents.GetStored("stargate_base");
	if (not eapStored or not eapStored.t or not capStored or not capStored.t) then
		MsgN("[EAP Compat] WARNING: couldn't find 'sg_base' and/or 'stargate_base' to bridge the address-list net messages - were they really registered yet?");
		return;
	end
	if (eapStored.t.EAPCompatAddressBridgePatched) then return end

	-- The menus filter gates by class name, so the class is sent as the receiving addon's equivalent.
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
			ResendRefresh("RefreshGateList", EAP_TO_CAP, self, type, value, typ, pl);
		end
	end

	local RealCapRefresh = capStored.t.RefreshGateList;
	if (RealCapRefresh) then
		capStored.t.RefreshGateList = function(self, type, value, typ, pl)
			RealCapRefresh(self, type, value, typ, pl);
			ResendRefresh("RefreshGatesList", CAP_TO_EAP, self, type, value, typ, pl);
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
			ResendRemove("RemoveGateFromList", self);
		end
	end

	local RealCapRemove = capStored.t.RemoveGateFromList;
	if (RealCapRemove) then
		capStored.t.RemoveGateFromList = function(self)
			RealCapRemove(self);
			ResendRemove("RemoveGatesFromList", self);
		end
	end

	eapStored.t.EAPCompatAddressBridgePatched = true;
	capStored.t.EAPCompatAddressBridgePatched = true;
end

-- Same for the gate spawner's "list reset" message ("RemoveGatesList" in EAP, "RemoveGateList" in CAP).
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
			net.Start("RemoveGateList");
			net.WriteBit(true);
			net.Broadcast();
		end
	end

	local RealCapRestored = StarGate.GateSpawner.Restored;
	if (RealCapRestored) then
		StarGate.GateSpawner.Restored = function(...)
			RealCapRestored(...);
			net.Start("RemoveGatesList");
			net.WriteBit(true);
			net.Broadcast();
		end
	end

	EAP.Compat.EAPCompatGateSpawnerRestoredPatched = true;
end

-- CAP Pegasus gate dialled in slow mode by a gate using the new slow dial: CAP plays InstantOpen (whole ring lit at once) instead of
-- its inbound animation, so the glyphs are never seen one by one. EAP's sg_atlantis plays the animation in that case.
--
-- Wraps stargate_atlantis Sequence:Dial(): for that call the source gate is shown as a classic one, so the normal inbound sequence is
-- built. Its length is kept on the gate (InboundSlowLead, the field EAP's sg_atlantis uses) and a wait for the source's last chevron
-- is appended, so both event horizons still open together.
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
			local total = 0;
			for _, step in ipairs(result) do total = total + (tonumber(step.d) or 0) end
			ent.InboundSlowLead = total - 0.5 + 0.2;
			ent.InboundSlowReleased = false;
			ent.InboundSlowReady = false;
			table.insert(result, { f = Lib.SlowDialBarrier, v = { ent }, d = ent:CalcDelaySlow(t, true) + 0.1 });
		end
		return result;
	end
end

-- Wraps the source gate's RunActions(): moves the step that resumes the paused destination earlier by the length of that animation
-- (Lib.ShiftTargetUnpause). The length is kept until the dial action list is the one passing through.
local function WithTargetUnpauseShift(Real)
	return function(self, action, ...)
		local target = self.Target;
		if (type(action) == "table" and target and IsValid(target) and target.InboundSlowLead) then
			if (Lib.ShiftTargetUnpause(self, action, target.InboundSlowLead)) then
				target.InboundSlowLead = nil;
			end
		end
		return Real(self, action, ...);
	end
end

-- Installs both wraps on the registered classes and on the gates already spawned (they run on their own copies).
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

-- Server GetAllGates() told supergates apart with its own addon's class name, so the other addon's supergate was listed with the
-- normal gates. Both bases get one function using the IsSupergate flag, set by both addons.
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
		for _, v in pairs(ents.FindByClass("sg_*")) do
			if (v.IsStargate and not (closed and (v.IsOpen or v.Dialling))) then
				if ((v.IsSupergate or false) == selfIsSuper) then
					table.insert(sg, v);
				end
			end
		end
		return sg;
	end

	eapStored.t.GetAllGates = FixedGetAllGates;
	capStored.t.GetAllGates = FixedGetAllGates;
	eapStored.t.EAPCompatGetAllGatesPatched = true;
	capStored.t.EAPCompatGetAllGatesPatched = true;
end

-- WormHoleJump, FindGate, FindGateGalaxy and the DHD's PressButton test the class of the other gate against their own addon's names
-- (Orlin, supergate, Atlantis, Universe), so a gate of the other addon failed those tests. They are not copied here: each runs with
-- every known class answered as its equivalent in the addon the function belongs to.
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

-- Slow dial from a menu: the source gate pauses then resumes the destination's queued sequence by calling its own PauseActions on
-- the destination. PauseActions finds the timers by a name prefix of its own addon, so across addons it paused nothing and the
-- destination opened at once. PauseActions of both bases now calls the function of the addon the paused gate belongs to.
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

	-- self is the gate, or a sequence table holding it in .Entity. A CAP gate pausing itself is also recorded for the slow dial barrier.
	local function MakeRouter(OwnFn)
		return function(self, ...)
			local ent = self.Entity;
			if (ent == nil) then ent = self; end
			if (isentity(ent) and ent:IsValid()) then
				local class = ent:GetClass();
				if (string.sub(class, 1, 9) == "stargate_") then
					local unpause, target = ...;
					if (not target) then Lib.TrackSlowDialWait(ent, unpause) end
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

-- Switching stargate_group_system does not send the gates' info again, so the menus kept entries from the other mode (empty group)
-- and hid those gates. EAP re-sends its own gates (Lib.ResyncGateList); CAP's gates are re-sent here once the switch has settled.
local SYSTEM_SWITCH_RESYNC_DELAY = 8;

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
	end, "EAPCompat_ResyncGateList");
end

-- Everything above, applied once both addons' entities, tools and weapons are registered.
function EAP.Compat.InstallServerPatches()
	-- Class lists of CAP's gate nuke and SGC server.
	EAP.Compat.ExtendArrayField("gate_nuke", "GateList", {
		"sg_sg1", "sg_atlantis", "sg_universe", "sg_orlin", "sg_movie", "sg_tollan", "sg_infinity",
	});
	EAP.Compat.ExtendArrayField("gate_nuke", "DHDList", {
		"dhd_milk", "dhd_atl", "dhd_uni", "dhd_inf",
	});

	EAP.Compat.ExtendMapField("sgc_server", "ValidGates", {
		"sg_sg1", "sg_infinity", "sg_movie",
	});

	EAP.Compat.PatchRampGateFinder("future_ramp");
	EAP.Compat.PatchRampGateFinder("goauld_ramp");
	EAP.Compat.PatchRampGateFinder("icarus_ramp");
	EAP.Compat.PatchRampGateFinder("sgc_ramp");
	EAP.Compat.PatchRampGateFinder("ramp_2", "stargate_dhd");

	for _, toolname in ipairs(SPOOFED_TOOLS) do
		EAP.Compat.PatchToolLeftClick(toolname);
	end

	for _, toolname in ipairs(SPOOFED_EAP_TOOLS) do
		EAP.Compat.PatchEapToolLeftClick(toolname);
	end

	EAP.Compat.PatchToolInitializeTools();
	EAP.Compat.RepatchExistingToolguns();

	EAP.Compat.PatchVirusWeapon();

	EAP.Compat.MergeE2StargateGetRingAngle();
	EAP.Compat.MergeE2StargateGlyphIsActivated();
	-- Again a few seconds later: E2 can register its extensions after this point.
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

	EAP.Compat.PatchGateAddressBroadcast();
	EAP.Compat.PatchGateSpawnerRestoredBroadcast();

	EAP.Compat.PatchGetAllGatesSupergate();
	EAP.Compat.PatchGateTypeAwareDialing();
	EAP.Compat.PatchSupergateLightsSelf();

	EAP.Compat.PatchAtlantisInboundSlowDial();

	EAP.Compat.PatchGateActionPause();

	EAP.Compat.PatchSystemTypeResync();
end

hook.Add("InitPostEntity", "EAPCompat_InstallServerPatches", function()
	if (Lib.IsCapDetected) then
		EAP.Compat.InstallServerPatches();
	end
end);
