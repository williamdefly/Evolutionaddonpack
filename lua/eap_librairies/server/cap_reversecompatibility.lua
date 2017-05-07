/*
	Cap Reverse compatibility functions for GarrysMod13
	Copyright (C) 2017  Elanis

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	---------------------------------------------------------------------
	
	Elanis' Note:

	This functions are made to replace in most cases the CAP entities by EAP 
	equivalents. This system is made to avoid many bugs and compatibility problems
	Since the Advanced Duplicator 2 compatibility has been released, you can use 
	the EAP without the CAP and keep old CAP duplication without bugs.
*/

MsgN("eap_librairies/server/cap_reversecompatibility.lua")

Lib = Lib or {};
Lib.ReverseCompatibility = Lib.ReverseCompatibility or {};

/* All CAP ents linked to their EAP equivalent */
Lib.ReverseCompatibility.Ents = {
	-- Ships
	["sg_vehicle_daedalus"] = "ship_daedalus",
	["sg_vehicle_dart"] = "ship_dart",
	["sg_vehicle_f302"] = "ship_f302",
	["sg_vehicle_glider"] = "ship_glider",
	["sg_vehicle_gate_glider"] = "ship_gate_glider",
	["puddle_jumper"] = "ship_puddle_jumper",
	["sg_vehicle_shuttle"] = "ship_shuttle",
	["sg_vehicle_teltac"] = "ship_teltak",
	-- Stargate
	["stargate_atlantis"] = "sg_atlantis",
	["stargate_infinity"] = "sg_infinity",
	["stargate_movie"] = "sg_movie",
	["stargate_orlin"] = "sg_orlin",
	["stargate_sg1"] = "sg_sg1",
	["stargate_supergate"] = "sg_supergate",
	["stargate_tollan"] = "sg_tollan",
	["stargate_universe"] = "sg_universe",
	-- DHD
	["dhd_sg1"] = "dhd_milk",
	["dhd_atlantis"] = "dhd_atl",
	["dhd_universe"] = "dhd_uni",
	["dhd_concept"] = "dhd_con",
	["dhd_city"] = "dhd_atl_city",
	["dhd_infinity"] = "dhd_inf",
	--Ring
	["ring_base_ancient"] = "rg_base_ancient",
	["ring_base_goauld"] = "rg_base_goauld",
	["ring_base_ori"] = "rg_base_ori",
	--Ring Panel
	["ring_panel_ancient"] = "rg_panel_ancient",
	["ring_panel_goauld"] = "rg_panel_goauld",
	["ring_panel_ori"] = "rg_panel_ori",
	--Obelisk
	["ancient_obelisk"] = "obelisk_ancient",
	["sodan_obelisk"] = "obelisk_sodan",
	--Transporters
	["transporter"] = "asgard_transporter",
	["atlantis_trans"] = "atlantis_transporter",
}

/* Spawn compatibility */
local function CAPSpawnedEntDetect( ply, oldent ) -- @Elanis: Because of incompatibility between some CAP/EAP lua
	local oldclass=oldent:GetClass();

	MsgN("CAPSpawnedEntDetect")

	// Adv 2 compatibility
	if(oldclass=="gmod_contr_spawner") then
		Adv2Compat(oldent);
	end

	local newclass=Lib.ReverseCompatibility.Ents[oldclass];

	MsgN(oldclass);
	MsgN(newclass);

	// No need to replace
	if(newclass==nil || newclass=="") then return end;

	local pos = oldent:GetPos()
	local ang = oldent:GetAngles()

	oldent:Remove()

	ply:PrintMessage(HUD_PRINTTALK,oldclass..' '..Lib.Language.GetMessage("replacing_by_eap_sent"));

	local newent = ents.Create(newclass);
	newent:SetPos(pos);
	newent:SetAngles(ang);
	newent:Spawn();

	undo.Create(newclass)
   		undo.AddEntity(newent)
   		undo.SetPlayer(ply)
	undo.Finish()

	newent:Activate();
	newent.Owner = ply;
	newent:SetVar("Owner",ply);

	/* Special settings */
	if(string.sub(newclass,0, 5)=="ship_") then
		local PropLimit = GetConVar("EAP_ships_max"):GetInt()

		if(ply:GetCount("EAP_ships")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		else
			if(newclass=="ship_puddle_jumper")then
			newent:SpawnBackDoor(nil,ply)
			newent:SpawnBulkHeadDoor(nil,ply)
			newent:SpawnToggleButton(ply)
			newent:SpawnShieldGen(ply)
			end

			if(newclass=="ship_f302")then
			newent:CockpitSpawn(ply) -- Spawn the cockpit
			newent:SpawnSeats(ply); -- Spawn the seats
			newent:SpawnRocketClamps(nil,ply); -- Spawn the rocket clamps
			newent:SpawnMissile(ply); -- Spawn the missile props
			newent:Turrets(ply); -- Spawn turrets
			newent:SpawnWheels(nil,ply);
			end

			if(newclass=="ship_teltak")then
			newent:SpawnRings(ply);
			newent:SpawnRingPanel(ply);
			newent:SpawnDoor(ply)
			newent:SpawnButtons(ply);
			end

			ply:AddCount("EAP_ships", newent)
		end
	elseif(string.sub(newclass,0, 3)=="sg_") then	--Stargates
		newent:SetWire("Dialing Mode",-1);

		if(newclass=="sg_orlin" or newclass=="sg_sg1" or newclass=="sg_infinity" or newclass=="sg_movie" or newclass=="sg_tollan")then
			newent:SetGateGroup("M@");
			newent:SetLocale(true);
		elseif(newclass=="sg_atlantis")then
			newent:SetGateGroup("P@");
			newent:SetLocale(true);
		elseif(newclass=="sg_universe")then
			newent:SetGateGroup("U@#");
			newent:SetLocale(true);
		end

		if(newclass=="sg_orlin")then
			local e = ents.Create("ramps");
			e:SetModel("models/ZsDaniel/minigate-ramp/ramp.mdl");
			e:SetPos(pos);
			e:DrawShadow(true);
			e:Spawn();
			e:Activate();
			e:SetAngles(ang);
			if(CPPI and IsValid(p) and e.CPPISetOwner)then e:CPPISetOwner(p) end
			newent.Ramp = e;
			local phys = e:GetPhysicsObject();
			if(phys and phys:IsValid())then
				phys:EnableMotion(false);
			end
		end
		Lib.RandomGatesName(ply,newent,0,false,nil);
	elseif(string.sub(newclass,0, 7)=="rg_base") then	--Rings
		newent:SetModel(newent.BaseModel);
	elseif(newclass=="atlantis_transporter")then --Atlantis Transporter
		newent:CreateDoors(ply);
		newent:OnReloaded();
	end
end

if(Lib.IsCapDetected)then -- Use this only if CAP is installed
    -- Ent Spawn
	hook.Add( "PlayerSpawnedSENT", "RemoveIfCAPBlackistedSENTIsSpawn", CAPSpawnedEntDetect );
end