-- EAP <-> CAP compatibility, shared part (server and client).
-- Everything here is installed only when CAP is detected, except the wrappers of usermessage.Hook, hook.Add, net.Receive, concommand.Add
-- and vgui.Register further down: they have to be in place before the entity files of both addons load, so they are set when this file
-- loads, and only act on a fixed list of names.
-- No file of CAP is changed, and the rest of EAP does not know CAP exists.

EAP = EAP or {};
EAP.Compat = EAP.Compat or {};

-- Same entity, two class names: CAP's on the left, EAP's on the right.
local CAP_TO_EAP = {
	["stargate_sg1"]       = "sg_sg1",
	["stargate_atlantis"]  = "sg_atlantis",
	["stargate_infinity"]  = "sg_infinity",
	["stargate_movie"]     = "sg_movie",
	["stargate_orlin"]     = "sg_orlin",
	["stargate_supergate"] = "sg_supergate",
	["stargate_tollan"]    = "sg_tollan",
	["stargate_universe"]  = "sg_universe",
	["dhd_sg1"]       = "dhd_milk",
	["dhd_atlantis"]  = "dhd_atl",
	["dhd_universe"]  = "dhd_uni",
	["dhd_concept"]   = "dhd_con",
	["dhd_city"]      = "dhd_atl_city",
	["dhd_infinity"]  = "dhd_inf",
	["ring_base_ancient"] = "rg_base_ancient",
	["ring_base_goauld"]  = "rg_base_goauld",
	["ring_base_ori"]     = "rg_base_ori",
	["ring_panel_ancient"] = "rg_panel_ancient",
	["ring_panel_goauld"]  = "rg_panel_goauld",
	["ring_panel_ori"]     = "rg_panel_ori",
	["ancient_obelisk"] = "obelisk_ancient",
	["sodan_obelisk"]   = "obelisk_sodan",
	["transporter"]                 = "asgard_transporter",
	["atlantis_transporter"]        = "atlantis_trans",
	["atlantis_transporter_doors"]  = "atlantis_trans_doors",
	["sg_vehicle_daedalus"]    = "ship_daedalus",
	["sg_vehicle_dart"]        = "ship_dart",
	["sg_vehicle_f302"]        = "ship_f302",
	["sg_vehicle_glider"]      = "ship_glider",
	["sg_vehicle_gate_glider"] = "ship_gate_glider",
	["puddle_jumper"]          = "ship_puddle_jumper",
	["sg_vehicle_shuttle"]     = "ship_shuttle",
	["sg_vehicle_teltac"]      = "ship_teltak",
}

local EAP_TO_CAP = {};
for capClass, eapClass in pairs(CAP_TO_EAP) do
	EAP_TO_CAP[eapClass] = capClass;
end

EAP.Compat.CapToEap = CAP_TO_EAP;
EAP.Compat.EapToCap = EAP_TO_CAP;

-- Wildcard searches on the gate prefix ("stargate_*" / "sg_*") have to return both families too.
local GATE_PREFIX_PAIR = {
	["stargate_"] = "sg_",
	["sg_"]       = "stargate_",
};

-- Each addon looks for gates, DHDs, rings... with ents.FindByClass on its own class names, so it never saw the other addon's entities.
-- ents.FindByClass now also returns the matches for the other addon's equivalent class (exact name or gate prefix wildcard).
function EAP.Compat.InstallFindByClassBridge()
	if (EAP.Compat.FindByClassBridgeInstalled) then return end
	EAP.Compat.FindByClassBridgeInstalled = true;

	local RealFindByClass = ents.FindByClass;

	ents.FindByClass = function(classname, ...)
		local results = RealFindByClass(classname, ...);

		if (not Lib.IsCapDetected or type(classname) ~= "string") then
			return results;
		end

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

-- Installed at load when CAP is already detected, and again on InitPostEntity (see the end of this file).
if (Lib.IsCapDetected) then
	EAP.Compat.InstallFindByClassBridge();
end

-- Client GetAllGates() of both gate bases only listed its own addon's gates, so the dial menu missed the other half.
-- Both bases get the same function: every gate of both addons (the FindByClass bridge above), supergates kept apart from normal gates.
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

-- "stargate_systemtype" is sent by both addons but only one receiver stays, and each only set its own flag.
-- One receiver sets Lib.GroupSystem and StarGate.GroupSystem together, so both menus follow a Group/Galaxy switch.
function EAP.Compat.PatchClientSystemTypeReceiver()
	if (not CLIENT) then return end
	net.Receive("stargate_systemtype", function(len)
		local groupsystem = net.ReadBit();
		Lib.GroupSystem = groupsystem;
		if (StarGate) then StarGate.GroupSystem = groupsystem; end
	end);
end

-- The gate info pop-up (address / group / name) is drawn by both addons at the same place: every gate showed two overlapping boxes,
-- one of them with the other addon's layout. Each hook is now limited to the gates of its own class prefix.
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

-- Both addons override Player:KeyDown(name, key) for their ship key bindings, each reading its own Pressed table, and EAP re-installs
-- its version every second (Lib.KeyBoard.Override): CAP ships never saw a key down.
-- Lib.KeyBoard.Override is replaced by one whose KeyDown reads both tables. Each binding scheme is only active while its own ship is
-- flown, so a ship still only sees its own keys.
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
			return meta.__KeyDown(self, name);
		end

		timer.Create("KBOverride", 1, 1, Lib.KeyBoard.Override);
	end
	Lib.KeyBoard.Override();
end

-- usermessage.Hook keeps one receiver per name. These messages carry ship data that the Jumper keeps in a table local to its file, so
-- the addon whose file loaded first never got its data and its HUD stayed on the default values. They are given to every receiver.
local SHIP_DATA_MESSAGES = {
	["jumperData"] = true,
	["JumperCloakData"] = true,
	["302Data"] = true,
	["ShuttleData"] = true,
	["MALPData"] = true,
};

-- Opens a menu: only the receiver from the file of the entity's own class must run (the message starts with the entity).
local ROUTED_USERMESSAGES = {
	["DestConsole"] = true,
};

-- Full path of the file that called the wrapper (debug's short_src is cut to 60 characters, too short to tell two addons apart).
-- Used as the key that keeps one registration per file.
local function CallerSource(fallback)
	local info = debug.getinfo(3, "S");
	return string.lower((string.gsub(info and info.source or tostring(fallback), "\\", "/")));
end

-- A usermessage can only be read once (bf_read:Reset did not give the second receiver the values again).
-- Reader() wraps it: the first receiver really reads, every value is kept, and the next receivers get the same values in order.
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

-- usermessage.Hook wrapper, for the names listed above only.
if (CLIENT and usermessage and not EAP.Compat.UsermessageHookWrapped) then
	EAP.Compat.UsermessageHookWrapped = true;
	EAP.Compat.ShipDataReceivers = EAP.Compat.ShipDataReceivers or {};
	local receivers = EAP.Compat.ShipDataReceivers;
	local originalHook = usermessage.Hook;

	function usermessage.Hook(name, callback, ...)
		if (not (SHIP_DATA_MESSAGES[name] or ROUTED_USERMESSAGES[name]) or not isfunction(callback)) then
			return originalHook(name, callback, ...);
		end
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

-- Path fragment of the file owning the Jumper the local player is in (pilot or passenger): "/puddle_jumper/" or "/ship_puddle_jumper/".
local function JumperViewOwner()
	local p = LocalPlayer();
	if (not IsValid(p)) then return end
	local jumper = p:GetNetworkedEntity("jumper", NULL);
	if (not IsValid(jumper)) then jumper = p:GetNetworkedEntity("JumperSeat", NULL); end
	if (IsValid(jumper)) then return "/" .. jumper:GetClass() .. "/"; end
end

-- hook.Add replaces a hook registered under the same event and name. For most names shared by the two addons the two functions are
-- identical, so losing one changes nothing. These ones differ by the class or networked variable they test, so the addon that lost
-- the name lost the feature. JumperCalcView is identical on both sides but reads view settings local to its file: "pick" selects
-- the function of the file owning the Jumper being flown.
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

-- hook.Add wrapper: one function kept per file, one dispatcher registered under the shared name. The dispatcher returns the values of
-- the first function that returns something (a function meant for the other addon's entity returns nothing).
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
		list[CallerSource(fn)] = fn;
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

-- net.Receive keeps one receiver per name. "shieldid_sendinfo" does not have the same layout in both addons (frequency on 12 bits
-- unsigned in CAP, 32 bits signed in EAP) and "MCD" carries each addon's own device class names, in both directions.
local ROUTED_NET_MESSAGES = {
	["shieldid_sendinfo"] = true,
	["mcd"] = true,
};

-- net.Receive wrapper: the message starts with the entity, so it is read first and the receiver from the file named after its class
-- is called. That receiver reads the entity itself: its first net.ReadEntity is answered with the one already read.
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

-- Declared by both personal shield weapons, each looking for its own weapon class on the player; only the last declaration stayed.
local WEAPON_COMMANDS = {
	["pshield_engage"] = true,
	["pshield_disengage"] = true,
};

-- concommand.Add wrapper: calls the function from the file named after a weapon the player carries ("weapons/<class>.lua").
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

-- vgui.Register keeps one panel per name. Of the panels shared by the two addons, these behave differently: the Destiny console
-- answers on its own addon's net message, the MCD lists its own addon's classes, the Jumper LSD tests its own Universe gate class.
local SHARED_PANELS = {
	["DestConsoleEntry"] = true,
	["MCDEntry"] = true,
	["JumperLSD"] = true,
	["JumperHUD"] = true,
};

-- The Jumper panels are registered by each addon's library but created by its Jumper entity: { creating file, registering file }.
local PANEL_OWNER_RULES = {
	{ "/ship_puddle_jumper/", "/eap_librairies/" },
	{ "/puddle_jumper/", "/stargate/" },
};

-- vgui.Register also registers each file's panel under a name of its own; vgui.Create returns the panel registered by the calling
-- file, or by the file the rules above pair it with.
if (CLIENT and vgui and not EAP.Compat.VguiWrapped) then
	EAP.Compat.VguiWrapped = true;
	EAP.Compat.SharedPanels = EAP.Compat.SharedPanels or {};
	local panels = EAP.Compat.SharedPanels;
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

-- Both addons' entities are registered by now.
hook.Add("InitPostEntity", "EAPCompat_InstallFindByClassBridge", function()
	if (Lib.IsCapDetected) then
		EAP.Compat.InstallFindByClassBridge();
		EAP.Compat.PatchClientGetAllGates();
		EAP.Compat.PatchClientSystemTypeReceiver();
		EAP.Compat.RestrictGateInfoHooks();
		EAP.Compat.MergeKeyDown();
	end
end);
