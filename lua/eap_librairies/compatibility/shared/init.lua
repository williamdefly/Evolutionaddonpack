--[[
	===========================================================================
	 EAP <-> CAP Compatibility Bridge
	===========================================================================
	This folder (lua/eap_librairies/compatibility/) is the ONLY part of EAP
	that is aware CAP (Carter's Addon Pack, github.com/RafaelDeJongh/cap)
	might also be installed. Nothing outside this folder references CAP in
	any way: the rest of EAP is 100% self-contained and works identically
	whether this folder exists or not, and whether CAP is installed or not.

	This bridge NEVER modifies a single file belonging to CAP, and NEVER
	modifies EAP's own class-comparison logic either (no "or X=='stargate_...'"
	added anywhere in sg_base/dhdbase/etc.) - the base stays exactly as clean
	as it was before this folder existed. It works purely by:
	  1. Wrapping the engine's `ents.FindByClass` so a search for one
	     addon's class also returns matches from the other addon, for every
	     entity family we know about (stargates, DHDs, rings, ring panels,
	     obelisks, transporters, ships).
	  2. Doing nothing at all if CAP isn't detected (see Lib.IsCapDetected
	     in eap_librairies/shared/init.lua) - zero overhead, zero behavior
	     change, when EAP runs alone.

	It deliberately does NOT try to make `entity:GetClass()` lie depending
	on who's asking (CAP vs EAP) globally - that would require inspecting
	the Lua call stack on every single GetClass() call in the game (GetClass()
	is called constantly, including in Think() hooks), which is not an
	acceptable performance trade-off on a live server. The practical
	consequence: CAP's own type-specific behavior (Universe 3-char
	addressing, Orlin always-fast-dial, Atlantis no-ring, etc.) will not
	automatically trigger when CAP's code is looking at an EAP entity found
	through this bridge, since CAP will still see it report its real EAP
	class - and the reverse is also true (EAP's own type-specific checks,
	e.g. sg_base's "self.Entity:GetClass()=='sg_universe'", will not trigger
	for a CAP Universe gate either). The one narrow exception is the handful
	of CAP tools patched in server/init.lua, where the "lie" is scoped to a
	single entity for a single click (see that file's header comment).

	This whole folder is written so it could be lifted out and shipped as
	its own standalone addon later, if someone wants to maintain it that
	way - it has no dependency on anything else in eap_librairies/ beyond
	Lib.IsCapDetected and the EAP/Lib globals already set up before this
	file loads.
]]--

EAP = EAP or {};
EAP.Compat = EAP.Compat or {};

-- ===========================================================================
-- 1. Class family map (two-way)
-- ===========================================================================
-- Every pair of (CAP class, EAP class) that represents "the same kind of
-- thing". Every class name below was checked against both repositories'
-- actual lua/entities/ folder names (which is what GMod registers as the
-- scripted-ent classname) rather than assumed - a few pairs from an earlier
-- draft of this file turned out to be wrong (notably the Atlantis
-- transporter) and are corrected here.
--
-- Stargates are also covered by a prefix rule below (so any new gate type
-- added to either addon under the usual stargate_*/sg_* naming is picked up
-- automatically), but we still list them here explicitly so exact
-- (non-wildcard) ents.FindByClass("stargate_universe") calls are bridged
-- too, not just ents.FindByClass("stargate_*"). DHDs happen to share the
-- same "dhd_" prefix convention on both sides already (no bridge needed for
-- the wildcard case there), so only the exact pairs matter for them.
--
-- Not every class has a counterpart and that's fine - a class only on one
-- side (EAP's sg_alteran, CAP's stargate_asuran, CAP's many DHD/ramp/turret
-- variants EAP doesn't have, EAP's many ship variants CAP doesn't have) is
-- simply not bridged, which is the correct behavior: there's nothing on the
-- other side to find.

local CAP_TO_EAP = {
	-- Stargates
	["stargate_sg1"]       = "sg_sg1",
	["stargate_atlantis"]  = "sg_atlantis",
	["stargate_infinity"]  = "sg_infinity",
	["stargate_movie"]     = "sg_movie",
	["stargate_orlin"]     = "sg_orlin",
	["stargate_supergate"] = "sg_supergate",
	["stargate_tollan"]    = "sg_tollan",
	["stargate_universe"]  = "sg_universe",
	-- DHDs
	["dhd_sg1"]       = "dhd_milk",
	["dhd_atlantis"]  = "dhd_atl",
	["dhd_universe"]  = "dhd_uni",
	["dhd_concept"]   = "dhd_con",
	["dhd_city"]      = "dhd_atl_city",
	["dhd_infinity"]  = "dhd_inf",
	-- Rings
	["ring_base_ancient"] = "rg_base_ancient",
	["ring_base_goauld"]  = "rg_base_goauld",
	["ring_base_ori"]     = "rg_base_ori",
	-- Ring panels
	["ring_panel_ancient"] = "rg_panel_ancient",
	["ring_panel_goauld"]  = "rg_panel_goauld",
	["ring_panel_ori"]     = "rg_panel_ori",
	-- Obelisks
	["ancient_obelisk"] = "obelisk_ancient",
	["sodan_obelisk"]   = "obelisk_sodan",
	-- Transporters
	["transporter"]                 = "asgard_transporter",
	["atlantis_transporter"]        = "atlantis_trans",       -- corrected: CAP's folder is "atlantis_transporter", EAP's is "atlantis_trans" (the earlier draft had this backwards)
	["atlantis_transporter_doors"]  = "atlantis_trans_doors", -- was missing from the earlier draft entirely
	-- Ships
	["sg_vehicle_daedalus"]    = "ship_daedalus",
	["sg_vehicle_dart"]        = "ship_dart",
	["sg_vehicle_f302"]        = "ship_f302",
	["sg_vehicle_glider"]      = "ship_glider",
	["sg_vehicle_gate_glider"] = "ship_gate_glider",
	["puddle_jumper"]          = "ship_puddle_jumper",
	["sg_vehicle_shuttle"]     = "ship_shuttle",
	["sg_vehicle_teltac"]      = "ship_teltak", -- note the spelling difference between the two addons (teltac vs teltak) - intentional, both are correct for their own addon
}

local EAP_TO_CAP = {};
for capClass, eapClass in pairs(CAP_TO_EAP) do
	EAP_TO_CAP[eapClass] = capClass;
end

EAP.Compat.CapToEap = CAP_TO_EAP;
EAP.Compat.EapToCap = EAP_TO_CAP;

-- Prefix rule for stargates: lets ents.FindByClass("stargate_*") and
-- ents.FindByClass("sg_*") find each other's gates even for a gate type
-- that isn't explicitly listed above (future-proofing against either
-- addon adding a new gate type later, and already covers CAP's
-- "stargate_asuran" and EAP's "sg_alteran" for generic "any gate" searches
-- even though they have no direct counterpart).
local GATE_PREFIX_PAIR = {
	["stargate_"] = "sg_",
	["sg_"]       = "stargate_",
};

-- ===========================================================================
-- 2. ents.FindByClass bridge
-- ===========================================================================
-- Only installed, and only does anything, once CAP is actually detected.
-- When CAP isn't installed, ents.FindByClass is left completely untouched.

function EAP.Compat.InstallFindByClassBridge()
	if (EAP.Compat.FindByClassBridgeInstalled) then return end
	EAP.Compat.FindByClassBridgeInstalled = true;

	local RealFindByClass = ents.FindByClass;

	ents.FindByClass = function(classname, ...)
		local results = RealFindByClass(classname, ...);

		if (not Lib.IsCapDetected or type(classname) ~= "string") then
			return results;
		end

		-- Wildcard gate search: "sg_*" or "stargate_*"
		local prefix = classname:match("^(sg_)%*$") or classname:match("^(stargate_)%*$");
		if (prefix) then
			local otherPrefix = GATE_PREFIX_PAIR[prefix];
			if (otherPrefix) then
				local extra = RealFindByClass(otherPrefix .. "*", ...);
				if (extra and #extra > 0) then
					local merged = {};
					for _, v in ipairs(results) do merged[#merged + 1] = v; end
					for _, v in ipairs(extra) do merged[#merged + 1] = v; end
					return merged;
				end
			end
			return results;
		end

		-- Exact class search for anything in our two-way map
		local mapped = CAP_TO_EAP[classname] or EAP_TO_CAP[classname];
		if (mapped) then
			local extra = RealFindByClass(mapped, ...);
			if (extra and #extra > 0) then
				local merged = {};
				for _, v in ipairs(results) do merged[#merged + 1] = v; end
				for _, v in ipairs(extra) do merged[#merged + 1] = v; end
				return merged;
			end
		end

		return results;
	end
end

-- Install immediately if CAP is already known to be present (shared/init.lua
-- runs EAP.IsCapDetected() on PlayerInitialSpawn / at startup; this file is
-- loaded after that detection in eap_include.lua, see below), and again on
-- InitPostEntity as a safety net in case detection resolves slightly later
-- than this file loading.
if (Lib.IsCapDetected) then
	EAP.Compat.InstallFindByClassBridge();
end

-- ===========================================================================
-- 3. Client-side ENT:GetAllGates() fix
-- ===========================================================================
-- The client copy of GetAllGates() (sg_base / stargate_base cl_init.lua) is
-- used to decide which DHD / ramp belongs to which gate. Like the server one
-- (see server/init.lua), it buckets supergates with a class-literal compare
-- that doesn't recognise the other addon's supergate class. Reimplemented here
-- with the addon-agnostic .IsSupergate flag. ents.FindByClass("sg_*") is
-- already bridged above, so it returns both addons' gates.

function EAP.Compat.PatchClientGetAllGates()
	if (not CLIENT) then return end
	local eapStored = scripted_ents.GetStored("sg_base");
	local capStored = scripted_ents.GetStored("stargate_base");
	if (not eapStored or not eapStored.t or not capStored or not capStored.t) then
		MsgN("[EAP Compat] WARNING: couldn't find 'sg_base' and/or 'stargate_base' to fix the client GetAllGates() - were they really registered yet?");
		return;
	end
	if (eapStored.t.EAPCompatClientGetAllGatesPatched) then return end

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
	eapStored.t.EAPCompatClientGetAllGatesPatched = true;
	capStored.t.EAPCompatClientGetAllGatesPatched = true;
end

-- ===========================================================================
-- 4. Client-side system type receiver ("stargate_systemtype")
-- ===========================================================================
-- Both addons' servers send the same "stargate_systemtype" net message (1 bit,
-- Group/Galaxy system) and both clients register a receiver for it - but a
-- net message has a single receiver, so whichever addon loaded last would
-- silently stop the other one from ever seeing a system switch. One receiver
-- reading the bit once and updating both addons' variable replaces them.

function EAP.Compat.PatchClientSystemTypeReceiver()
	if (not CLIENT) then return end
	net.Receive("stargate_systemtype", function(len)
		local groupsystem = net.ReadBit();
		Lib.GroupSystem = groupsystem;
		if (StarGate) then StarGate.GroupSystem = groupsystem; end
	end);
end

-- ===========================================================================
-- 5. Client-side gate info pop-up (address / group / name under the crosshair)
-- ===========================================================================
-- Both addons draw that pop-up from their own HUDPaint hook, at the same place, and each one tests its own class names (the Universe
-- gate's label for instance). With both loaded, a gate was drawn by both hooks: the other addon's one with the wrong layout, and the two
-- boxes overlapped. Each hook now only runs for the gates of its own addon: EAP's for "sg_*", CAP's for "stargate_*".

local GATE_INFO_HOOKS = {
	{ name = "Lib.Hook.HUDPaint.ShowAddressAndGroupAndName", prefix = "sg_" },
	{ name = "StarGate.Hook.HUDPaint.ShowAddressAndGroupAndName", prefix = "stargate_" },
};

local wrappedGateInfoHooks = {};

function EAP.Compat.RestrictGateInfoHooks()
	if (not CLIENT) then return end
	local hooks = hook.GetTable()["HUDPaint"] or {};
	for _, info in ipairs(GATE_INFO_HOOKS) do
		local original = hooks[info.name];
		if (original and not wrappedGateInfoHooks[info.name]) then
			wrappedGateInfoHooks[info.name] = true;
			hook.Add("HUDPaint", info.name, function()
				local p = LocalPlayer();
				if (not IsValid(p)) then return end
				local e = p:GetEyeTrace().Entity;
				if (IsValid(e) and string.sub(e:GetClass(), 1, #info.prefix) == info.prefix) then
					return original();
				end
			end);
		end
	end
end

-- ===========================================================================
-- 6. Player:KeyDown(name, key) for the ships of both addons
-- ===========================================================================
-- Both addons replace Player:KeyDown so that their ships can read their own key bindings with KeyDown(name, key): CAP's version reads
-- StarGate.KeyBoard.Pressed, EAP's reads Lib.KeyBoard.Pressed. CAP installs its version once; EAP re-installs its own every second
-- (Lib.KeyBoard.Override, eap_librairies/shared/keyboard.lua), so EAP's always ended up in place and a CAP ship never saw a key pressed:
-- no controls on the server, and a HUD stuck on its initial state on the client (CAP's Jumper tracks its systems from those keys).
-- Lib.KeyBoard.Override is replaced by a version that installs a KeyDown reading both tables. A binding is pressed in the table of the
-- addon that owns it only, so each ship keeps seeing its own keys exactly as before.

function EAP.Compat.MergeKeyDown()
	if (not Lib.KeyBoard or not StarGate or not StarGate.KeyBoard or not StarGate.KeyBoard.Pressed) then return end

	function Lib.KeyBoard.Override()
		local meta = FindMetaTable("Player");
		if (not meta) then return end
		meta.__KeyDown = meta.__KeyDown or meta.KeyDown;

		function meta:KeyDown(name, key)
			if (name and key) then
				return (Lib.KeyBoard.Pressed[self][name][key] == true) or (StarGate.KeyBoard.Pressed[self][name][key] == true);
			end
			return meta.__KeyDown(self, name); -- Old GMod behaviour
		end

		timer.Create("KBOverride", 1, 1, Lib.KeyBoard.Override);
	end
	Lib.KeyBoard.Override();
end

-- ===========================================================================
-- 7. Ship HUD data: one usermessage name, one receiver per addon
-- ===========================================================================
-- CAP's and EAP's ships send their HUD data (drones, cloak, shield, health, engine...) to the client with the same usermessage names, and
-- each addon's client file keeps what it receives in a table local to that file. usermessage.Hook only keeps ONE receiver per name, so the
-- addon whose entity file loads last (EAP: "ship_*" sorts after CAP's names) took every message and the other addon's ships never got
-- their data: their HUD stayed on its default values (systems shown OFF) while the ship itself worked.
-- usermessage.Hook is wrapped, for these names only, so that every file registering one of them is kept, and the message is handed to each
-- of them in turn (see Reader below: a message can only be read once). Both addons use the same layout for these messages. With a single
-- receiver (CAP not installed) the receiver is called exactly as before.
-- This has to be in place before the entity files load, so it is installed when this file loads, not on InitPostEntity.

local SHIP_DATA_MESSAGES = {
	["jumperData"] = true,
	["JumperCloakData"] = true,
	["302Data"] = true,
	["ShuttleData"] = true,
	["MALPData"] = true,
};

-- A message that opens a menu is different: only the menu of the addon owning the entity must open. "DestConsole" (Destiny console)
-- starts with the console entity; the receiver from the file of that entity's class ("entities/<class>/...") is the one called.
local ROUTED_USERMESSAGES = {
	["DestConsole"] = true,
};

-- Source file of the code that called the function calling this one, in full ("@addons/x/lua/entities/y.lua"). debug's short_src is cut
-- to 60 characters, which is not enough to tell two long paths apart.
local function CallerSource(fallback)
	local info = debug.getinfo(3, "S");
	return string.lower((string.gsub(info and info.source or tostring(fallback), "\\", "/")));
end

-- A usermessage can only be read once, in order. Reader() gives each receiver an object with the usual Read* methods: the first receiver
-- really reads the message and every value is kept; the next ones are given the same values in the same order.
local READ_METHODS = { "ReadAngle", "ReadBool", "ReadChar", "ReadEntity", "ReadFloat", "ReadLong", "ReadShort", "ReadString", "ReadVector", "ReadVectorNormal" };

local function Reader(um, values)
	local reader = { position = 0 };
	for _, method in ipairs(READ_METHODS) do
		reader[method] = function(self)
			self.position = self.position + 1;
			local i = self.position;
			if (i > values.count) then
				values[i] = um[method](um);
				values.count = i;
			end
			return values[i];
		end
	end
	function reader:Reset() self.position = 0; end
	return reader;
end

if (CLIENT and usermessage and not EAP.Compat.UsermessageHookWrapped) then
	EAP.Compat.UsermessageHookWrapped = true;
	EAP.Compat.ShipDataReceivers = EAP.Compat.ShipDataReceivers or {};
	local receivers = EAP.Compat.ShipDataReceivers;
	local originalHook = usermessage.Hook;

	function usermessage.Hook(name, callback, ...)
		if (not (SHIP_DATA_MESSAGES[name] or ROUTED_USERMESSAGES[name]) or not isfunction(callback)) then
			return originalHook(name, callback, ...);
		end
		-- One receiver per source file: a file that is reloaded replaces its own receiver instead of adding one
		receivers[name] = receivers[name] or {};
		receivers[name][CallerSource(callback)] = callback;

		if (ROUTED_USERMESSAGES[name]) then
			return originalHook(name, function(um, ...)
				local values = { count = 0 };
				local ent = Reader(um, values):ReadEntity();
				local chosen = callback;
				if (IsValid(ent)) then
					local class = string.lower(ent:GetClass());
					for src, receiver in pairs(receivers[name]) do
						if (string.find(src, "/" .. class .. "/", 1, true) or string.find(src, "/" .. class .. ".lua", 1, true)) then
							chosen = receiver;
							break;
						end
					end
				end
				return chosen(Reader(um, values), ...);
			end, ...);
		end

		return originalHook(name, function(um, ...)
			local values = { count = 0 };
			for _, receiver in pairs(receivers[name]) do
				local ok, err = pcall(receiver, Reader(um, values), ...);
				if (not ok) then ErrorNoHalt("[EAP Compat] " .. name .. ": " .. tostring(err) .. "\n") end
			end
		end, ...);
	end
end

-- ===========================================================================
-- 8. Hooks registered under the same name by both addons
-- ===========================================================================
-- hook.Add(event, name, fn) replaces any hook already registered under that event and name. CAP and EAP share many hook names (EAP's
-- files started as copies of CAP's), so for each of them only the addon whose file loads last keeps its hook. For most of them the two
-- functions are the same and work for the entities of both addons, so nothing is lost. The ones listed below are different: each addon's
-- function tests its own class name or its own networked variable, or reads a table local to its own file, so the addon that lost the
-- name lost the feature (custom view and HUD of the F-302, the Tel'tak, the MALP, the control chair, the Destiny console buttons, the
-- anti-prior device's noclip block, the custom groups sent on spawn).
-- For these names only, hook.Add is wrapped so that the function of each file is kept and one dispatcher is registered under the name:
-- it calls each function in turn and returns the values of the first one that returns something. A function meant for the other addon's
-- entity returns nothing, as it did before.
-- "pick" is for the Jumper's view: the two functions are identical and would both answer, but each reads the view settings (distance,
-- first person...) local to its own file, the ones its own Jumper changes from the keys. The function from the file of the Jumper being
-- flown is the one called.

local function JumperViewOwner()
	local p = LocalPlayer();
	if (not IsValid(p)) then return end
	local jumper = p:GetNetworkedEntity("jumper", NULL);
	if (not IsValid(jumper)) then jumper = p:GetNetworkedEntity("JumperSeat", NULL); end
	if (IsValid(jumper)) then return "/" .. jumper:GetClass() .. "/"; end
end

local SHARED_HOOKS = {
	["CalcView"] = {
		["ControlCHCalcView"] = true,
		["SGF302CalcView"] = true,
		["SGTeltakCalcView"] = true,
		["JumperCalcView"] = { pick = JumperViewOwner },
	},
	["HUDPaint"] = {
		["Console.Hook.HUDPaint.ShowButtons"] = true,
		["F302HUD"] = true,
		["RenderMALPHud"] = true,
		["TeltakHUD"] = true,
	},
	["PlayerNoClip"] = {
		["AntiPrior.DisableNoclip"] = true,
	},
	["PlayerInitialSpawn"] = {
		["SG_INIT_CUSTOM_GROUPS"] = true,
	},
};

if (not EAP.Compat.HookAddWrapped) then
	EAP.Compat.HookAddWrapped = true;
	EAP.Compat.SharedHookFunctions = EAP.Compat.SharedHookFunctions or {};
	local functions = EAP.Compat.SharedHookFunctions;
	local originalAdd = hook.Add;

	function hook.Add(event, name, fn, ...)
		local options = SHARED_HOOKS[event] and isstring(name) and SHARED_HOOKS[event][name];
		if (not options or not isfunction(fn)) then
			return originalAdd(event, name, fn, ...);
		end
		local key = event .. "/" .. name;
		functions[key] = functions[key] or {};
		local list = functions[key];
		list[CallerSource(fn)] = fn; -- a reloaded file replaces its own function
		local pick = istable(options) and options.pick;

		return originalAdd(event, name, function(...)
			local wanted = pick and pick();
			if (wanted) then
				for source, f in pairs(list) do
					if (string.find(source, wanted, 1, true)) then return f(...); end
				end
			end
			for _, f in pairs(list) do
				local a, b, c, d, e, g = f(...);
				if (a ~= nil) then return a, b, c, d, e, g; end
			end
		end, ...);
	end
end

-- ===========================================================================
-- 9. Shield identifier menu (net message "shieldid_sendinfo")
-- ===========================================================================
-- Both addons use this net message, in both directions, but not with the same layout (the frequency is 12 bits unsigned in CAP, 32 bits
-- signed in EAP), and net.Receive keeps one receiver per name: the identifier of the addon that lost it got or sent a wrong frequency.
-- The message starts with the identifier entity in both layouts. For this name, net.Receive is wrapped: the receiver of each file is
-- kept, the entity is read first, and the receiver from the file named after the entity's class ("entities/<class>.lua") is called. That
-- receiver reads the entity itself, so the first net.ReadEntity it makes is answered with the entity already read.

-- "MCD" (molecular construction device) is routed the same way, in both directions: each addon's menu and server code list their own
-- class names for what the device can build.
local ROUTED_NET_MESSAGES = {
	["shieldid_sendinfo"] = true,
	["mcd"] = true,
};

if (not EAP.Compat.NetReceiveWrapped) then
	EAP.Compat.NetReceiveWrapped = true;
	EAP.Compat.RoutedNetReceivers = EAP.Compat.RoutedNetReceivers or {};
	local receivers = EAP.Compat.RoutedNetReceivers;
	local originalReceive = net.Receive;

	function net.Receive(name, fn, ...)
		local key = isstring(name) and string.lower(name);
		if (not key or not ROUTED_NET_MESSAGES[key] or not isfunction(fn)) then
			return originalReceive(name, fn, ...);
		end
		receivers[key] = receivers[key] or {};
		local list = receivers[key];
		list[CallerSource(fn)] = fn;

		return originalReceive(name, function(...)
			local ent = net.ReadEntity();
			local chosen;
			if (IsValid(ent)) then
				local class = string.lower(ent:GetClass());
				for source, f in pairs(list) do
					if (string.find(source, "/" .. class .. ".lua", 1, true) or string.find(source, "/" .. class .. "/", 1, true)) then
						chosen = f;
						break;
					end
				end
			end
			if (not chosen) then chosen = fn; end

			local originalReadEntity = net.ReadEntity;
			local given = false;
			net.ReadEntity = function(...)
				if (not given) then given = true; return ent; end
				return originalReadEntity(...);
			end
			local ok, err = pcall(chosen, ...);
			net.ReadEntity = originalReadEntity;
			if (not ok) then ErrorNoHalt("[EAP Compat] " .. name .. ": " .. tostring(err) .. "\n") end
		end, ...);
	end
end

-- ===========================================================================
-- 10. Personal shield console commands (pShield_Engage / pShield_Disengage)
-- ===========================================================================
-- Both addons' personal shield weapons declare these two commands, each one looking for its own weapon class on the player. Only the last
-- one declared stayed, so the other addon's shield could not be switched with them. For these names, concommand.Add is wrapped: the
-- function of each file is kept, and the one from the file named after a weapon the player carries ("weapons/<class>.lua") is called.

local WEAPON_COMMANDS = {
	["pshield_engage"] = true,
	["pshield_disengage"] = true,
};

if (SERVER and not EAP.Compat.ConCommandAddWrapped) then
	EAP.Compat.ConCommandAddWrapped = true;
	EAP.Compat.WeaponCommandFunctions = EAP.Compat.WeaponCommandFunctions or {};
	local functions = EAP.Compat.WeaponCommandFunctions;
	local originalAdd = concommand.Add;

	function concommand.Add(name, fn, ...)
		local key = isstring(name) and string.lower(name);
		if (not key or not WEAPON_COMMANDS[key] or not isfunction(fn)) then
			return originalAdd(name, fn, ...);
		end
		functions[key] = functions[key] or {};
		local list = functions[key];
		list[CallerSource(fn)] = fn;

		return originalAdd(name, function(ply, ...)
			if (not IsValid(ply)) then return end
			for source, f in pairs(list) do
				local class = string.match(source, "([^/]+)%.lua$");
				if (class and ply:HasWeapon(class)) then f(ply, ...); end
			end
		end, ...);
	end
end

-- ===========================================================================
-- 11. Menus (vgui panels) registered under the same name by both addons
-- ===========================================================================
-- vgui.Register keeps one panel per name, so both addons' entities opened the panel of whichever file loaded last. Compared one by one,
-- the 14 shared panels only differ by their logo or a label, except these, where the difference changes what the panel does:
--   DestConsoleEntry  sends its answer on the net message of its own addon ("destiny_console" / "destinyconsole")
--   MCDEntry          lists and sends the class names of its own addon's devices
--   JumperLSD         tests its own addon's Universe gate class
--   JumperHUD         kept with JumperLSD (both are created together by the Jumper)
-- For these names, vgui.Register also registers each file's panel under a name of its own, and vgui.Create gives the panel registered by
-- the file that asks for it. The Jumper's two panels are registered by each addon's library and created by its Jumper entity, hence the
-- two rules below. Sections 7 and 9 make sure the code asking for a menu is the one of the entity's addon.

local SHARED_PANELS = {
	["DestConsoleEntry"] = true,
	["MCDEntry"] = true,
	["JumperLSD"] = true,
	["JumperHUD"] = true,
};

-- { text found in the file creating the panel, text found in the file that registered it }
local PANEL_OWNER_RULES = {
	{ "/ship_puddle_jumper/", "/eap_librairies/" },
	{ "/puddle_jumper/", "/stargate/" },
};

if (CLIENT and vgui and not EAP.Compat.VguiWrapped) then
	EAP.Compat.VguiWrapped = true;
	EAP.Compat.SharedPanels = EAP.Compat.SharedPanels or {};
	local panels = EAP.Compat.SharedPanels; -- [name][source file] = name of that file's own copy
	local originalRegister = vgui.Register;
	local originalCreate = vgui.Create;

	function vgui.Register(name, tbl, base, ...)
		if (isstring(name) and SHARED_PANELS[name] and istable(tbl)) then
			local source = CallerSource(name);
			panels[name] = panels[name] or {};
			local own = name .. "@" .. source;
			panels[name][source] = own;
			originalRegister(own, table.Copy(tbl), base, ...);
		end
		return originalRegister(name, tbl, base, ...);
	end

	function vgui.Create(name, ...)
		local list = isstring(name) and SHARED_PANELS[name] and panels[name];
		if (list) then
			local source = CallerSource(name);
			local own = list[source];
			if (not own) then
				for _, rule in ipairs(PANEL_OWNER_RULES) do
					if (string.find(source, rule[1], 1, true)) then
						for registered, copy in pairs(list) do
							if (string.find(registered, rule[2], 1, true)) then own = copy; break; end
						end
						break;
					end
				end
			end
			if (own) then return originalCreate(own, ...); end
		end
		return originalCreate(name, ...);
	end
end

hook.Add("InitPostEntity", "EAPCompat_InstallFindByClassBridge", function()
	if (Lib.IsCapDetected) then
		EAP.Compat.InstallFindByClassBridge();
		EAP.Compat.PatchClientGetAllGates();
		EAP.Compat.PatchClientSystemTypeReceiver();
		EAP.Compat.RestrictGateInfoHooks();
		EAP.Compat.MergeKeyDown();
	end
end);
