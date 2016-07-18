--################################ DON'T EDIT THIS FILE YOU CAN MAKE CHANGES IN THE GAME!!!!!!!!!!!!!

MsgN("eap_librairies/server/convar.lua")

-- All convars !
CreateConVar( "sbox_maxanim_ramps", "10", FCVAR_ARCHIVE, "Max Animated Ramps" )

-- Finally all default convar values in one file! @AlexALX

-- Arrays for save default values, used in cap settings menu.
Lib.EAP_Convars = {};
Lib.EAP_SGConvars = {};

local limits = {
	{"Destiny Small Turret", "destsmall", 4},
	{"Destiny Medium Turret", "destmedium", 2},
	{"Destiny MainWeapon", "destmain", 1},
	{"Tollana Ion Cannon", "ioncannon", 6},
	{"Ship Railgun", "shiprail", 6},
	{"Stationary Railgun", "statrail", 2},
	{"Ashend Defence System", "ashen", 20},
	{"Drone Launcher", "launchdrone", 2},
	{"MiniDrone Platform", "minidrone", 2},
	{"Asgard Turret", "asgbeam", 2},
	{"AG-3 Sattelites", "ag3", 6},
	{"Gate Overloader", "overloader", 1},
	{"Asuran Gate Weapon", "asuran_beam", 1},
	{"Ori Beam Weapon", "ori_beam", 2},
	{"Dakara Device", "dakara", 1},
	{"Shaped Charge", "dirn", 1},
	{"Horizon Platform", "horizon", 1},
	{"Ori Sattelite", "ori", 1},
	{"Staff Stationary", "staffstat", 2},
	--{"KINO Dispenser", "dispenser", 1},
	--{"Destiny Console", "destcon", 5},
	--{"Destiny Apple Core", "applecore", 1},
	--{"Lantean Holo Device", "lantholo", 1},
	--{"Shield Core", "shieldcore",1},
	{"Sodan Obelisk", "obelisk_sodan", 4},
	{"Ancient Obelisk", "obelisk_ancient", 4},
	--{"MCD", "mcd", 1},
	{"Ships", "ships", 10},
	{"Iris Computer", "iris_computer", 2},
	{"AGV", "agv", 2},
}

for _,val in pairs(limits) do
	CreateConVar("EAP_"..val[2].."_max", tostring(val[3]), {FCVAR_NEVER_AS_STRING});
	Lib.EAP_Convars["EAP_"..val[2].."_max"] = val[3];
end

-- From stargate group system by AlexALX

local sgconvars = {
	{"stargate_eap_candial_groups_dhd",1},
	{"stargate_eap_candial_groups_menu",1},
	{"stargate_eap_candial_groups_wire",1},
	{"stargate_sgu_find_range",16000},
	{"stargate_eap_energy_dial",1},
	{"stargate_eap_energy_dial_spawner",0},
	{"stargate_eap_dhd_protect",0},
	{"stargate_eap_dhd_protect_spawner",0},
	{"stargate_eap_dhd_destroyed_energy",1},
	{"stargate_eap_dhd_close_incoming",1},
	{"stargate_show_inbound_address",2},
	{"stargate_eap_protect",0},
	{"stargate_eap_protect_spawner",1},
	{"stargate_block_address",2},
	{"stargate_eap_dhd_letters",1},
	{"stargate_eap_energy_target",1},
	{"stargate_vgui_glyphs",2},
	{"stargate_eap_dhd_menu",1},
	{"stargate_eap_atlantis_override",1},
	{"stargate_eap_dhd_ring",1},
	{"stargate_eap_different_dial_menu",0},
	{"stargate_eap_gatespawner_enabled",1},
	{"stargate_eap_random_address",1},
	{"stargate_eap_gatespawner_protect",1},
	{"stargate_eap_physics_clipping",1},
	{"stargate_eap_model_clipping",1},
	{"stargate_group_system",1},
}

-- Convars
for _,val in pairs(sgconvars) do
	local flags = {FCVAR_ARCHIVE};
	if (val[1]=="stargate_group_system") then flags = {FCVAR_NOTIFY, FCVAR_GAMEDLL, FCVAR_ARCHIVE}; end
	CreateConVar(val[1], tostring(val[2]), flags);
	Lib.EAP_SGConvars[val[1]] = val[2];
end

local count = cvars.GetConVarCallbacks("stargate_eap_gatespawner_enabled") or {}; -- add callback only once
if (table.Count(count)==0) then
	cvars.AddChangeCallback("stargate_eap_gatespawner_enabled", function(CVar, PreviousValue, NewValue)
		if (util.tobool(tonumber(PreviousValue))==util.tobool(tonumber(NewValue)) or not (Lib and Lib.GateSpawner and Lib.GateSpawner.InitialSpawn)) then return end
		timer.Remove("stargate_eap_gatespawner_reload");
		timer.Create("stargate_eap_gatespawner_reload",0.5,1,function() Lib.GateSpawner.InitialSpawn(true) end);
	end);
end

local count = cvars.GetConVarCallbacks("stargate_eap_gatespawner_protect") or {}; -- add callback only once
if (table.Count(count)==0) then
	cvars.AddChangeCallback("stargate_eap_gatespawner_protect", function(CVar, PreviousValue, NewValue)
		if (util.tobool(tonumber(PreviousValue))==util.tobool(tonumber(NewValue))) then return end
		if (Lib and Lib.GateSpawner and Lib.GateSpawner.Spawned) then
			local protect = util.tobool(tonumber(NewValue));
			for k,v in pairs(Lib.GateSpawner.Ents) do
				if(v.Entity and IsValid(v.Entity)) then
					v.Entity.EAPGateSpawnerProtected = protect;
					v.Entity:SetNetworkedBool("EAPGateSpawnerProtected",protect);
				end
			end
		end
	end);
end

local count = cvars.GetConVarCallbacks("stargate_group_system") or {}; -- add callback only once
if (table.Count(count)==0) then
	cvars.AddChangeCallback("stargate_group_system", function(CVar, PreviousValue, NewValue)
		net.Start("stargate_systemtype");
		net.WriteBit(util.tobool(NewValue));
		net.Broadcast();
	end);
end
util.AddNetworkString( "stargate_systemtype" )

-- send system type to client
local function FirstSpawn( ply )
	net.Start("stargate_systemtype");
	net.WriteBit(util.tobool(GetConVarNumber("stargate_group_system")));
	net.Send(ply);
end
hook.Add("PlayerInitialSpawn", "Lib.SystemType", FirstSpawn)

function Lib.LoadConvars()
	if (not file.Exists("eap/convars.txt","DATA")) then return end

	local ini = INIParser:new("eap/convars.txt",false);
	if(ini) then
		if (ini.nodes.eap_convars and ini.nodes.eap_convars[1]) then
			for k,v in pairs(ini.nodes.eap_convars[1]) do
				if (Lib.EAP_Convars[k] or k:find("sbox_max")) then -- for security
					RunConsoleCommand(k,v);
				end
			end
		end
	end
end
Lib.LoadConvars();