/*
	Stargate Auto-Spawner for GarrysMod10
	Copyright (C) 2007  aVoN

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
*/

MsgN("eap_librairies/server/spawner.lua")

if not SERVER then return end; -- Just to be sure

--##################################
--#### Spawning
--##################################

Lib.GateSpawner = {};
Lib.GateSpawner.Props = {}; -- Any props, attached to a stargate/ring
Lib.GateSpawner.Gates = {}; -- Gates
Lib.GateSpawner.Iris = {}; -- Iris
Lib.GateSpawner.DHDs = {}; -- DHDs
Lib.GateSpawner.MDHDs = {}; -- Mobile DHDs
Lib.GateSpawner.Ents = {};
Lib.GateSpawner.RingBase = {}; -- Carter Stuff
Lib.GateSpawner.RingPanel = {};
Lib.GateSpawner.DestinyTimer = {};
Lib.GateSpawner.SGULightUp = {};
Lib.GateSpawner.FloorChev = {};
Lib.GateSpawner.KinoDispenser = {};
Lib.GateSpawner.DestinyConsole = {};
Lib.GateSpawner.Ramp = {};
Lib.GateSpawner.Brazier = {};
Lib.GateSpawner.gravity_controller = {};
Lib.GateSpawner.AtlantisLight = {}
Lib.GateSpawner.AtlantisTransporter = {};
Lib.GateSpawner.Spawned = false;
Lib.GateSpawner.Block = false;
Lib.GateSpawner.Doors = {};
Lib.GateSpawner.DoorButtons = {};
Lib.GateSpawner.Console = {};

-- ############### Load config @aVoN
function Lib.GateSpawner.LoadConfig()
	local map = game.GetMap();
	local file = "lua/data/gatespawner/"..map..".lua"
	if (GetConVar("stargate_group_system"):GetBool()) then
		file = "lua/data/gatespawner_group/"..map..".lua"
	end
	local ini = INIParser:new(file,false,true);
	-- FIXME: Add config for Enabled/Disabled again
	if(ini) then
		Lib.GateSpawner.Version = ((ini.gatespawner or {})[1] or {}).version; -- To determine the spawnheight
		Lib.GateSpawner.Props = ini.prop_physics or {};
		Lib.GateSpawner.Gates = ini.stargate or {};
		Lib.GateSpawner.Iris = ini.iris or {};
		Lib.GateSpawner.DHDs = ini.dhd or {};
		Lib.GateSpawner.MDHDs = ini.mobiledhd or {};
		Lib.GateSpawner.DestinyTimer = ini.destiny_timer or {}; -- Carter Stuff
		Lib.GateSpawner.DestinyConsole = ini.destiny_console or {};
		Lib.GateSpawner.KinoDispenser = ini.kino_dispenser or {};
		Lib.GateSpawner.RingBase = ini.rg_base or {};
		Lib.GateSpawner.RingPanel = ini.rg_panel or {};
		Lib.GateSpawner.SGULightUp = ini.sgu_stuff or {};
		Lib.GateSpawner.FloorChev = ini.floor_chevron or {};
		Lib.GateSpawner.Ramp = ini.ramp or {};
		Lib.GateSpawner.Brazier = ini.brazier or {};
		Lib.GateSpawner.gravity_controller = ini.gravity_controller or {};
		Lib.GateSpawner.AtlantisLight = ini.atlantis_light or {};
		Lib.GateSpawner.AtlantisTransporter = ini.atlantis_transporter or {};
		Lib.GateSpawner.Doors = ini.eap_doors or {};
		Lib.GateSpawner.DoorButtons = ini.doors_contr or {};
		Lib.GateSpawner.Console = ini.eap_console or {};
		return true;
	end
	return false;
end

/* This code is for workshop, it is disabled.
local types = {
	base = {"sg_sg1","sg_atlantis","sg_universe","dhd_milk","dhd_atl","dhd_uni","dhd_atl_city"},
}
local function GateSpawner_CheckModule(class,model)
	if (model and model!="" and not file.Exists("models/"..model,"GAME")) then return false end
	for k,v in pairs(types) do
		if (not Lib.CheckModule(k)) then continue end
		for k2,v2 in pairs(v) do
			if (class:find(v2)) then return true end
		end
	end
	return false;
end  */

-- ############### Spawning function @aVoN
function Lib.GateSpawner.Spawn(v,protect,k,k2)
	if (Lib.GateSpawner.Block) then return nil end
	if(v.position and v.classname) then
		--if (not GateSpawner_CheckModule(v.classname,v.model)) then return end
		if (Lib.CFG:Get("eap_disabled_ent",v.classname,false)) then return end
		local e = ents.Create(v.classname);
		if (not IsValid(e)) then return nil end
		e.EAPGateSpawnerSpawned = true;
		e:SetNetworkedBool("EAPGateSpawnerSpawned",true);
		e.EAPGateSpawnerProtected = protect;
		e:SetNetworkedBool("EAPGateSpawnerProtected",protect);
		local pos = Vector(unpack(v.position:TrimExplode(" ")));
		local IsGate = v.classname:find("sg_") and not v.classname:find("sg_iris");
		local IsGroupGate = (v.classname:find("sg_") and v.classname != "sg_supergate");
		local IsIris = v.classname:find("sg_iris");
		local IsDHD = v.classname:find("dhd_");
		local IsRing = v.classname:find("rg_base_");
		local IsRingP = v.classname:find("rg_panel_");
		local IsRingAncient = v.classname:find("rg_base_ancient");
		local IsRingOri = v.classname:find("rg_base_ori");
		local IsRingGoauld = v.classname:find("rg_base_goauld");
		local Isgravity_controller = string.lower(v.classname):find("gravity_controller");
		local IsAtlantisLight = string.lower(v.classname):find("atlantis_light");
		local IsAtlantisTransporter = string.lower(v.classname):find("atlantis_trans");
		local IsDoors = string.lower(v.classname):find("eap_doors_frame");
		local IsDoorsButton = string.lower(v.classname):find("doors_contr");
		local IsConsole = string.lower(v.classname):find("eap_console");

		if (IsIris and Lib.CFG and not Lib.CFG:Get("sg_iris","sv_gatespawner",true)) then e:Remove(); return end

		local IsSGULightUp = v.classname:find("gatebearing") or v.classname:find("floor_chevron");

		e.CDSIgnore = true; -- Fixes Combat Damage System destroying Ramps - http://mantis.39051.vs.webtropia.com/view.php?id=45
		e:SetPos(pos);
		-- Set model (if not a gate and valid key exists)
		if(not IsGate and v.model) then
			e:SetModel(v.model);
		end

		-- Enable gravity controllers
		if(Isgravity_controller) then
			local convtable={
				["iActivateKey"]		= {0, 0},
				["fAirbrakeX"]		= {0, 15},
				["fAirbrakeY"]		= {0, 15},
				["fAirbrakeZ"]		= {0, 15},
				["fBrakePercent"]		= {0, 10},
				["sModel"]			= {1, v.model},
				["sSound"]			= {1, v.sound},
				["bAngularBrake"]		= {2, 0},
				["bGlobalBrake"]		= {2, 1},
				["bDrawSprite"]		= {0, 1},
				["bAlwaysBrake"]		= {0, 0},
				["bBrakeOnly"]		= {0, 0},
				["iKeyUp"]			= {0, 7},
				["iKeyDown"]			= {0, 4},
				["iKeyHover"]		= {0, 1},
				["fHoverSpeed"]		= {0, 1},
				["bSHHoverDesc"]	= {2, 1},
				["bSHLocalDesc"]		= {2, 1},
				["fAngBrakePerc"]		= {0, 20},
				["fWeight"]			= {0, 0},
				["bRelativeToGrnd"]	= {2, 0},
				["fHeightAboveGrnd"]	= {0, 30},
				["bSGAPowerNode"]	= {2, 1},
				["bLiveGravity"]		={0,0},
			}
			e.ConTable=table.Copy(convtable)
		end

		-- Need to set some stuff for rings, just like with stargates
		if(IsRingAncient) then
			e:SetModel("models/Madman07/ancient_rings/cover.mdl");
			e.RingModel = "models/Madman07/ancient_rings/ring.mdl";
			e.BaseModel = "models/Madman07/ancient_rings/cover.mdl";
			e.OriFix = 0;
		end
		if(IsRingOri) then
			e:SetModel("models/Boba_Fett/rings/ori_base.mdl");
			e.RingModel = "models/Boba_Fett/rings/ori_ring.mdl";
			e.BaseModel = "models/Boba_Fett/rings/ori_base.mdl";
			e.OriFix = 1;
		end
		if(IsRingGoauld) then
			e:SetModel("models/Madman07/ancient_rings/ring.mdl");
			e.RingModel = "models/Madman07/ancient_rings/ring.mdl";
			e.BaseModel = "models/Madman07/ancient_rings/ring.mdl";
			e.OriFix = 0;
		end
		if(Isgatebearing) then
			e:SetModel("models/Iziraider/gatebearing/gatebearing.mdl");
		end
		if(IsDoors) then
			if (v.doormodel) then
				e.DoorModel = v.doormodel;
			end
			if (v.diffmat!=nil and v.diffmat!="" and util.tobool(v.diffmat)) then
				e:SetMaterial("madman07/doors/atlwall_red");
			end
		end

		if (k2) then
			e.GateSpawnerID = k2;
		else
			e.GateSpawnerID = k+1;
		end

		-- Spawn the gate a bit later. And we need to spawn it before anyone sets the angles, or it will look weird
		timer.Simple(0.1*k,
			function()
				if(not IsValid(e)) then return end; -- WHY DID THIS HAPPEN? SHOULD NEVER!
				e:Spawn();
				-- Set angles only AFTER we spawned the prop to avoid chevrons being added incorrectly
				if(v.angles) then
					local p,y,r = unpack(v.angles:TrimExplode(" "));
					e:SetAngles(Angle(tonumber(p),tonumber(y),tonumber(r)));
				end
				-- freeze stuff now
				local phys = e:GetPhysicsObject();
				if(IsValid(phys)) then phys:EnableMotion(false); end
				-- Set the address of a gate
				if (IsGate) then
					if(v.address and v.address ~= "") then
						e:SetGateAddress(v.address:upper());
					end
					if (IsGroupGate and GetConVar("stargate_group_system"):GetBool()) then
						if(v.group and v.group ~= "") then
							e:SetGateGroup(string.Replace(v.group:upper(),"!","#"));
						end
						if(v.locale ~= nil and v.locale ~= "") then
							e:SetLocale(util.tobool(v.locale));
						end
					elseif (IsGroupGate) then
						if(v.galaxy ~= nil and v.galaxy ~= "") then
							e:SetGalaxy(util.tobool(v.galaxy));
						end
					end
					if(v.name and v.name ~= "") then
						e:SetGateName(v.name);
					end
					if(v.private ~= nil and v.private ~= "") then
						e:SetPrivate(util.tobool(v.private));
					end
					if(v.blocked ~= nil and v.blocked ~= "") then
						e:SetBlocked(util.tobool(v.blocked));
					end
					e:CheckRamp();
					if(v.chevdestroyed ~= nil and v.chevdestroyed ~= "" and v.chevdestroyed) then
						e.ChevDestroyed = util.tobool(v.chevdestroyed);
					end
					-- damn, i should make it manualy...
					for c=1,9 do
						if(v["chevdestroyed"..c] ~= nil and v["chevdestroyed"..c] ~= "" and v["chevdestroyed"..c]) then
							e.chev_destroyed[c] = util.tobool(v["chevdestroyed"..c]);
							e.Chevron[c]:Remove();
						end
					end
					if (v.sgctype ~= nil and v.sgctype~="" and util.tobool(v.sgctype)==true) then
						e.RingInbound = true;
						e:SetNWBool("ActSGCT",true);
					end
					if (v.classname=="sg_infinity" and v.sg1eh ~= nil and v.sg1eh~="" and util.tobool(v.sg1eh)==true) then
						e.InfDefaultEH = true;
						e:SetNWBool("ActInf_SG1_EH",true);
					end
					if (v.chevlight ~= nil and v.chevlight ~="" and util.tobool(v.chevlight)==true) then
						e.ChevLight = true;
						e:SetNWBool("ActMChevL",true);
					end
					if (v.classic ~= nil and v.classic ~="" and util.tobool(v.classic)==true) then
						e.Classic = true;
						e:SetNWBool("ActMCl",true);
					end
					if (v.atltype ~= nil and v.atltype ~="" and util.tobool(v.atltype)==true) then
						e.AtlType = true;
						e:SetNWBool("AtlType",true);
					end
				elseif (IsIris) then
					for _,v in pairs(ents.FindInSphere(e:GetPos(),10)) do
						if(v.IsStargate) then
							local const=constraint.Weld(e, v, 0, 0, 0, false);
							e.GateLink = v;
						elseif(v.IsIris and not v.EAPGateSpawnerSpawned) then
							v:Remove();
						end
					end
					e.NextAction = CurTime();
					e:SetTrigger(false);
					e:SetNoDraw(true);
					e.LastMoveable = false;
					e:SetCollisionGroup(COLLISION_GROUP_WORLD);
					e:SetSolid(SOLID_NONE);
					e:IrisProtection();
				elseif (IsDHD) then
					if(v.destroyed ~= nil and v.destroyed ~= "" and util.tobool(v.destroyed)==true and e:GetClass() != "dhd_con" and e:GetClass() != "dhd_atl_city") then
						e.Healthh = 0;
						e:DestroyEffect(true);
					end
					if (v.slowmode ~= nil and v.slowmode ~= "" and util.tobool(v.slowmode)==true and (e:GetClass()=="dhd_atl_city" or e:GetClass()=="dhd_atl")) then
						e.DisRingRotate = true;
						e:SetNWBool("DisRingRotate",true);
					end
					if (v.disablering ~= nil and v.disablering ~= "" and util.tobool(v.disablering)==true and e:GetClass()!="dhd_atl_city" and e:GetClass()!="dhd_atl" and e:GetClass()!="dhd_universe") then
						e.DisRingRotate = true;
						e:SetNWBool("DisRingRotate",true);
					end
				elseif (IsRingAncient or IsRingOri or IsRingGoauld) then
					e:CheckRamp();
					-- And rings Rings
					if(v.address and v.address ~= "") then
						e.Address = v.address;
						e:SetNetworkedString("address",v.address);
					end
				elseif (IsSGULightUp) then -- Weld sgu stuff to nearest gates
					for _,v in pairs(ents.FindInSphere(pos, 200)) do
						if (IsValid(v) and v.IsStargate and v:GetClass() == "sg_universe") then
							local const=constraint.Weld(e, v, 0, 0, 0);
						end
					end
				elseif(Isgravity_controller) then
					local phys = e:GetPhysicsObject(); -- hey, unfreeze me!
					if IsValid(phys) then phys:SetMass(200); phys:EnableMotion(true); end

					// weld to the gates
					for _,sg in pairs(ents.FindInSphere(pos, 200)) do
						if (IsValid(sg) and sg.IsStargate) then
							local const=constraint.Weld(e, sg, 0, 0, 0, false)
							local nocollide=constraint.NoCollide( e, sg, 0, 0)
							-- fix by AlexALX
							e:SetParent(sg)
							sg.GateSpawnerGrav = sg.GateSpawnerGrav or {};
							table.insert(sg.GateSpawnerGrav,e);
							if (table.Count(sg.GateSpawnerGrav)==3) then
								local phys = sg:GetPhysicsObject();
								if IsValid(phys) then phys:EnableMotion(true); end
								for _,grav in pairs(sg.GateSpawnerGrav) do
									if (IsValid(grav)) then
										grav:ActivateIt(true);
									end
								end
								sg.GateSpawnerGrav = nil;
							end
						end
					end
				elseif(IsAtlantisTransporter) then
					e:CreateDoors(nil,true,protect);
					if (v.name ~= nil and v.name ~="") then
                		e:SetAtlName(v.name,true);
                	end
					if (v.group ~= nil and v.group ~="") then
                		e:SetAtlGrp(v.group,true);
                	end
					if (v.private ~= nil and v.private ~="" and util.tobool(v.private)==true) then
                		e:SetAtlPrivate(v.private);
                	end
					if (v.locale ~= nil and v.locale ~="" and util.tobool(v.locale)==true) then
                		e:SetAtlLocal(v.locale);
                	end
					if (v.onlyclosed ~= nil and v.onlyclosed ~="" and util.tobool(v.onlyclosed)==true) then
                		e.OnlyClosed = true;
                	end
					if (v.autoopen ~= nil and v.autoopen ~="" and util.tobool(v.autoopen)==false) then
                		e.NoAutoOpen = true;
                	end
					if (v.autoclose ~= nil and v.autoclose ~="" and util.tobool(v.autoclose)==false) then
                		e.NoAutoClose = true;
                	end
				elseif(IsAtlantisLight) then
					if (v.brightness ~= nil and v.brightness ~="") then
                		e:SetBrightness(tonumber(v.brightness));
                	end
					if (v.size ~= nil and v.size ~="") then
                		e:SetLightSize(tonumber(v.size));
                	end
					if (v.size ~= nil and v.size ~="") then
                		e:SetLightSize(tonumber(v.size));
                	end
					if(v.color) then
						local r,g,b = unpack(v.color:TrimExplode(" "));
						e:SetLightColour(tonumber(r),tonumber(g),tonumber(b));
					end
				end
				if(IsDoors and IsValid(e.Door)) then
					if (v.model and v.model == "models/madman07/doors/dest_frame.mdl") then
					e:SoundType(1); else e:SoundType(2); end
					if(v.angles) then
						local p,y,r = unpack(v.angles:TrimExplode(" "));
						e.Door:SetAngles(Angle(tonumber(p),tonumber(y),tonumber(r)));
					end
					e.Door.EAPGateSpawnerSpawned = true;
					e.Door:SetNetworkedBool("EAPGateSpawnerSpawned",true);
					e.Door.EAPGateSpawnerProtected = protect;
					e.Door:SetNetworkedBool("EAPGateSpawnerProtected",protect);
				end
				if (v.__id and e:GetClass()=="prop_physics") then
					duplicator.StoreEntityModifier(e, "GateSpawnerProp", {GateSpawner=true,ID=e.GateSpawnerID} )
					for _,vv in pairs(ents.FindByClass("sg_*")) do
						if(vv.__id == v.__id) then
							constraint.Weld(e,vv,0,0,0,true);
							break;
						end
					end
					for _,vv in pairs(ents.FindByClass("rg_base_*")) do
						if(vv.__id == v.__id) then
							constraint.Weld(e,vv,0,0,0,true);
							break;
						end
					end
					for _,vv in pairs(ents.FindByClass("rg_panel_*")) do
						if(vv.__id == v.__id) then
							constraint.Weld(e,vv,0,0,0,true);
							break;
						end
					end
				elseif(v.__id and (IsGate or IsRing or IsRingP)) then
					e.__id = v.__id;
				end
			end
		);
		return e;
	end
	return nil;
end

-- ############### Reset gatespawner by AlexALX
function Lib.GateSpawner.Reset()
	Lib.GateSpawner.Props = {};
	Lib.GateSpawner.Gates = {}; -- Gates
	Lib.GateSpawner.Iris = {}; -- Iris
	Lib.GateSpawner.DHDs = {}; -- DHDs
	Lib.GateSpawner.MDHDs = {}; -- Mobile DHDs
	Lib.GateSpawner.Ents = {};
	Lib.GateSpawner.RingBase = {}; -- Carter Stuff
	Lib.GateSpawner.RingPanel = {};
	Lib.GateSpawner.DestinyTimer = {};
	Lib.GateSpawner.SGULightUp = {};
	Lib.GateSpawner.FloorChev = {};
	Lib.GateSpawner.KinoDispenser = {};
	Lib.GateSpawner.DestinyConsole = {};
	Lib.GateSpawner.Ramp = {};
	Lib.GateSpawner.Brazier = {};
	Lib.GateSpawner.gravity_controller = {};
	Lib.GateSpawner.AtlantisLight = {};
	Lib.GateSpawner.AtlantisTransporter = {};
	Lib.GateSpawner.Spawned = false;
	Lib.GateSpawner.Doors = {};
	Lib.GateSpawner.DoorButtons = {};
	Lib.GateSpawner.Console = {};
end

-- ############### Initial spawn handling @aVoN
function Lib.GateSpawner.InitialSpawn(reload)
	if (not Lib.GateSpawner.Block) then
		-- First, remove all previous gate_spawner gates.
		local remove = {
			ents.FindByClass("sg_*"),
			ents.FindByClass("goauldiris"),
			ents.FindByClass("dhd_*"),
			ents.FindByClass("mobiledhd"),
			ents.FindByClass("rg_*"),
			ents.FindByClass("gatebearing"),
			ents.FindByClass("brazier"),
			ents.FindByClass("floor_chevron"),
			ents.FindByClass("destiny_timer"),
			ents.FindByClass("destiny_console"),
			ents.FindByClass("kino_dispenser"),
			ents.FindByClass("ramps"),
			ents.FindByClass("ramps2"),
			ents.FindByClass("futureramp"),
			ents.FindByClass("sgcramp"),
			ents.FindByClass("icarusramp"),
			ents.FindByClass("sguramp"),
			ents.FindByClass("goauldramp"),
			ents.FindByClass("gravity_controller"),
			ents.FindByClass("atlantis_light"),
			ents.FindByClass("atlantis_trans"),
			ents.FindByClass("prop_physics"),
			ents.FindByClass("eap_doors*"),
			ents.FindByClass("eap_console"),
		};
		for _,v in pairs(remove) do
			for _,e in pairs(v) do
				if(e.EAPGateSpawnerSpawned) then
					e:Remove();
				end
			end
		end
	end
	if(not Lib.GateSpawner.Spawned or reload) then
		if (reload) then Lib.GateSpawner.Reset(); end
		if (GetConVar("stargate_eap_gatespawner_enabled"):GetBool() and Lib.GateSpawner.LoadConfig()) then
			Lib.GateSpawner.Spawned = true;
			-- sorry old or wrong gatespawner
			local groupsystem = GetConVar("stargate_group_system"):GetBool();
			if (Lib.GateSpawner.Version == "3" and groupsystem) then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is for Galaxy System, it is not compatible with Group System.\nPlease create new gatespawner or switch to Galaxy System.\n"); return
			elseif (Lib.GateSpawner.Version == "3 Group" and not groupsystem) then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is for Group System, it is not compatible with Galaxy System.\nPlease create new gatespawner or switch to Group System.\n"); return
			elseif (Lib.GateSpawner.Version == "2" or Lib.GateSpawner.Version == "1") then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is for old aVoN stargate addon, it is not compatible with EAP.\nPlease create new gatespawner.\n"); return
			elseif (Lib.GateSpawner.Version != "3" and Lib.GateSpawner.Version != "3 Group") then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is invalid.\nPlease create new gatespawner.\n"); return
			end

			local protect = GetConVar("stargate_eap_gatespawner_protect"):GetBool();
			local i = 0; -- For delayed spawning

			local tbl = {
				Lib.GateSpawner.Ramp,
				Lib.GateSpawner.Gates,
				Lib.GateSpawner.Iris,
				Lib.GateSpawner.DHDs,
				Lib.GateSpawner.MDHDs,
				Lib.GateSpawner.DestinyTimer,
				Lib.GateSpawner.DestinyConsole,
				Lib.GateSpawner.KinoDispenser,
				Lib.GateSpawner.RingBase,
				Lib.GateSpawner.RingPanel,
				Lib.GateSpawner.Brazier,
				Lib.GateSpawner.SGULightUp,
				Lib.GateSpawner.gravity_controller,
				Lib.GateSpawner.AtlantisLight,
				Lib.GateSpawner.AtlantisTransporter,
				Lib.GateSpawner.Props,
				Lib.GateSpawner.Doors,
				Lib.GateSpawner.DoorButtons,
				Lib.GateSpawner.Console,
			}

			for k,t in pairs(tbl) do
				for _,v in pairs(t) do
					table.insert(Lib.GateSpawner.Ents,{Entity=Lib.GateSpawner.Spawn(v,protect,i),SpawnData=v});
					i = i + 1;
				end
			end
		end
	end
end

-- ############### Auto Respawner @aVoN
function Lib.GateSpawner.AutoRespawn()
	-- FIXME: Add config for enabled/disabled again
	if(DEBUG) then return end;
	--if(Lib.spawner_enabled and Lib.spawner_autorespawn) then
	if (Lib.GateSpawner.Spawned) then
		--local add = {};
		local i = 0; -- For delayed spawning
		for k,v in pairs(Lib.GateSpawner.Ents) do
			local protect = GetConVar("stargate_eap_gatespawner_protect"):GetBool();
			if(not v.Entity or not v.Entity:IsValid()) then
				Lib.GateSpawner.Ents[k] = {Entity=Lib.GateSpawner.Spawn(v.SpawnData,protect,i,k),SpawnData=v.SpawnData};
				i = i + 1;
			end
		end
		/*for _,v in pairs(add) do
			table.insert(Lib.GateSpawner.Ents,v);
		end*/
	end
end

-- ############### Init @aVoN
timer.Simple(2,function() Lib.GateSpawner.InitialSpawn() end); -- Spawn them, 2 seconds after the map start
timer.Create("Lib.GateSpawner.AutoRespawn",3,0,function() Lib.GateSpawner.AutoRespawn() end); -- Check for existance every 3 seconds

--##################################
--#### Creating of spawnfils
--##################################


-- This script works the following way: Spawn your gates and DHDs, set the addrese and run this script by console with the following command: stargate_creategatespawner_file
-- Now, a new file called <the name of the map>.txt has been created in garrysmod/data/
-- Copy this file to garrysmod/addons/stargate/data/gatespawner_group and remove the .txt extension so it only looks up like <the name of the map>.ini
-- Now your gates will autospawn on that specific map
-- YOU NEED TO BE ADMIN TO PERFORM THIS COMMAND!

-- ############### Gatespawner creation command @aVoN
function Lib.GateSpawner.CreateFile(p)
	if(not IsValid(p) or p:IsAdmin()) then
		local f = "[gatespawner]\nversion = 3\n\n\n";
		local gatefolder = "gatespawner";
		local groupsystem = false;
		if (GetConVar("stargate_group_system"):GetBool()) then
			f = "[gatespawner]\nversion = 3 Group\n\n\n";
			gatefolder = "gatespawner_group";
			groupsystem = true;
		end
		-- Gates and Attachments
		local already_added = {};

		local props = "";

		-- Gates
		for _,v in pairs(ents.FindByClass("sg_*")) do
			if(v.IsStargate) then
				local blocked = "";
				if (v:GetBlocked()) then blocked="blocked=true\n"; end
				if (v.IsGroupStargate and groupsystem) then
					f = f .. "[stargate]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..v:GetGateAddress().."\ngroup="..string.Replace(v:GetGateGroup(),"#","!").."\nname="..v:GetGateName().."\nprivate="..tostring(v:GetPrivate()).."\nlocale="..tostring(v:GetLocale()).."\n"..blocked;
					if (v.ChevDestroyed) then f = f .. "chevdestroyed="..tostring(v.ChevDestroyed).."\n"; end
					for i=1,9 do
						if (v.chev_destroyed and v.chev_destroyed[i]) then
							f = f .. "chevdestroyed"..i.."="..tostring(v.chev_destroyed[i]).."\n";
						end
					end
				elseif (v.IsGroupStargate) then
					f = f .. "[stargate]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..v:GetGateAddress().."\nname="..v:GetGateName().."\nprivate="..tostring(v:GetPrivate()).."\ngalaxy="..tostring(v:GetGalaxy()).."\n"..blocked;
					if (v.ChevDestroyed) then f = f .. "chevdestroyed="..tostring(v.ChevDestroyed).."\n"; end
					for i=1,9 do
						if (v.chev_destroyed and v.chev_destroyed[i]) then
							f = f .. "chevdestroyed"..i.."="..tostring(v.chev_destroyed[i]).."\n";
						end
					end
				else
					f = f .. "[stargate]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..v:GetGateAddress().."\nname="..v:GetGateName().."\nprivate="..tostring(v:GetPrivate()).."\n";
				end
				if (v.IsStargate) then
					local gate = v;
					local first = true
					for _,v in pairs(Lib.GetConstrainedEnts(v,2) or {}) do
						if(v ~= gate and v:GetClass() == "prop_physics" and IsValid(v)) then
							if (first) then
								f = f .."__id="..gate:EntIndex().."\n"
								first = false
							end
							already_added[v] = true;
							props = props.."[prop_physics]\nclassname=prop_physics\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..v:GetModel().."\n__id="..gate:EntIndex().."\n";
						end
					end
				end
				if (v.RingInbound) then
					f = f .. "sgctype=true\n";
				end
				if (v:GetClass()=="sg_infinity" and v.InfDefaultEH) then
					f = f .. "sg1eh=true\n";
				end
				if (v.ChevLight) then
					f = f .. "chevlight=true\n";
				end
				if (v.Classic) then
					f = f .. "classic=true\n";
				end
				if (v.AtlType) then
					f = f .. "atltype=true\n";
				end
			end
		end
		for _,v in pairs(ents.FindByClass("*_iris")) do
			if (v.IsIris) then
				f = f .. "[iris]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end
		end
		for _,v in pairs(ents.FindByClass("dhd_*")) do
			if (v:GetClass()!="dhd_atl_city" and v:GetClass()!="dhd_con") then
				f = f .. "[dhd]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\ndestroyed="..tostring(v.Destroyed).."\n";
			else
				f = f .. "[dhd]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			end
			if (v.DisRingRotate) then
				if (v:GetClass()=="dhd_atl_city" or v:GetClass()=="dhd_atl") then
					f = f .. "slowmode=true\n"
				else
					f = f .. "disablering=true\n"
				end
			end
		end

		-- Mobile DHDs
		for _,v in pairs(ents.FindByClass("mobiledhd")) do
			f = f .. "[mobiledhd]\nclassname=mobiledhd\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end

		-- Carter Stuff
		for _,v in pairs(ents.FindByClass("gatebearing")) do
			f = f .. "[sgu_stuff]\nclassname=gatebearing\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end
		for _,v in pairs(ents.FindByClass("floor_chevron")) do
			f = f .. "[sgu_stuff]\nclassname=floor_chevron\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end
		for _,v in pairs(ents.FindByClass("destiny_timer")) do
			f = f .. "[destiny_timer]\nclassname=destiny_timer\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
		end
		for _,v in pairs(ents.FindByClass("destiny_console")) do
			f = f .. "[destiny_console]\nclassname=destiny_console\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
		end
		for _,v in pairs(ents.FindByClass("kino_dispenser")) do
			f = f .. "[kino_dispenser]\nclassname=kino_dispenser\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
		end

		-- Rings
		for _,v in pairs(ents.FindByClass("rg_panel_*")) do
			f = f .. "[rg_panel]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			local ringp = v;
			local first = true
			for _,v in pairs(Lib.GetConstrainedEnts(v,2) or {}) do
				if(v ~= ringp and v:GetClass() == "prop_physics" and IsValid(v)) then
					if (first) then
						f = f .."__id="..ringp:EntIndex().."\n"
						first = false
					end
					already_added[v] = true;
					props = props.."[prop_physics]\nclassname=prop_physics\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..v:GetModel().."\n__id="..ringp:EntIndex().."\n";
				end
			end
		end
		for _,v in pairs(ents.FindByClass("rg_base_*")) do
			f = f .. "[rg_base]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..(v.Address or "").."\n";
			local ring = v;
			local first = true
			for _,v in pairs(Lib.GetConstrainedEnts(v,2) or {}) do
				if(v ~= ring and v:GetClass() == "prop_physics" and IsValid(v)) then
					if (first) then
						f = f .."__id="..ring:EntIndex().."\n"
						first = false
					end
					already_added[v] = true;
					props = props.."[prop_physics]\nclassname=prop_physics\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..v:GetModel().."\n__id="..ring:EntIndex().."\n";
				end
			end
		end

		for _,v in pairs(ents.FindByClass("brazier")) do
			f = f .. "[brazier]\nclassname=brazier\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end

		-- Ramps
		for _,v in pairs(ents.FindByClass("ramps")) do
			f = f .. "[ramps]\nclassname=ramps\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end
		for _,v in pairs(ents.FindByClass("ramps_2")) do
			f = f .. "[ramps]\nclassname=ramps_2\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end
		for _,v in pairs(ents.FindByClass("sguramp")) do
			f = f .. "[ramps]\nclassname=sguramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end
		for _,v in pairs(ents.FindByClass("sgcramp")) do
			f = f .. "[ramps]\nclassname=sgcramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
		end
		for _,v in pairs(ents.FindByClass("icarusramp")) do
			f = f .. "[ramps]\nclassname=icarusramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
		end
		for _,v in pairs(ents.FindByClass("futureramp")) do
			f = f .. "[ramps]\nclassname=futureramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
		end
		for _,v in pairs(ents.FindByClass("goauldramp")) do
			f = f .. "[ramps]\nclassname=goauldramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
		end
		for _,v in pairs(ents.FindByClass("gravity_controller")) do
			if v.ConTable["bSGAPowerNode"][2]==1 then //only nodes with SGAPowerNode Type
				f = f .. "[gravity_controller]\nclassname=gravity_controller\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\nsound="..tostring(v.ConTable["sSound"][2]).."\n";
			end
		end
		for _,v in pairs(ents.FindByClass("atlantis_light")) do
			f = f .. "[atlantis_light]\nclassname=atlantis_light\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\nbrightness="..v.Brightness.."\n".."size="..v.LightSize.."\n".."color="..v.LightColour.r.." "..v.LightColour.g.." "..v.LightColour.b.."\n";
		end
		for _,v in pairs(ents.FindByClass("atlantis_trans")) do
			f = f .. "[atlantis_trans]\nclassname=atlantis_trans\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nname="..v.TName.."\n".."group="..v.TGroup.."\n".."private="..tostring(v.TPrivate).."\n".."locale="..tostring(v.TLocal).."\n";
			if (v.OnlyClosed) then
              		f = f .. "onlyclosed=true\n";
              	end
			if (v.NoAutoOpen) then
              		f = f .. "autoopen=false\n";
              	end
			if (v.NoAutoClose) then
              		f = f .. "autoclose=false\n";
              	end
		end
		for _,v in pairs(ents.FindByClass("eap_doors_*")) do
			local class = v:GetClass();
			if (class=="eap_doors_frame") then
				f = f .. "[eap_doors]\nclassname=eap_doors_frame\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\ndoormodel="..tostring(v.DoorModel).."\n";
				if (v:GetMaterial()=="madman07/doors/atlwall_red") then f = f .. "diffmat=true\n"; end
			elseif (class=="doors_contr" and not v.Atlantis) then
				f = f .. "[doors_contr]\nclassname=doors_contr\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end
		end
		for _,v in pairs(ents.FindByClass("eap_console")) do
			f = f .. "[eap_console]\nclassname=eap_console\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
		end
		f = f .. props

		file.Write(game.GetMap():lower()..".txt",f);
		MsgN("=======================");
		MsgN("Gatespawner successfully created!");
		MsgN("File: garrysmod\\data\\"..game.GetMap():lower()..".txt");
		MsgN("Rename this file to "..game.GetMap():lower()..".lua and move it to garrysmod\\lua\\data\\"..gatefolder.." to make it work.");
		MsgN("Do not forget to reload the gatespawner or restart the map to have it take effect!");
		MsgN("=======================");
		if (IsValid(p)) then
			net.Start("EAP_GATESPAWNER");
			net.WriteString(game.GetMap():lower());
			net.WriteString(gatefolder);
			net.Send(p);
		end
	end
end
concommand.Add("stargate_eap_gatespawner_createfile",Lib.GateSpawner.CreateFile);

util.AddNetworkString("EAP_GATESPAWNER");

concommand.Add("stargate_eap_gatespawner_reload",
	function(p)
		if(not IsValid(p) or game.SinglePlayer() or p:IsAdmin()) then
			timer.Remove("stargate_eap_gatespawner_reload");
			timer.Create("stargate_eap_gatespawner_reload",0.5,1,function() Lib.GateSpawner.InitialSpawn(true) end);
		end
	end
);

util.AddNetworkString("RemoveGatesList")
util.AddNetworkString("RemoveAtlTPsList")

-- so much time spend for fix gatespawner with gmod saving system...
function Lib.GateSpawner.Restored()
	-- fix for addresses
	net.Start( "RemoveGatesList" )
		net.WriteBit(true)
	net.Broadcast()
	net.Start( "RemoveAtlTPsList" )
		net.WriteBit(true)
	net.Broadcast()

	local dly = 0.15;
	if (not Lib.GateSpawner.Spawned) then
		dly = 3.5;
		Lib.GateSpawner.Block = true;
	end
	Lib.GateSpawner.Spawned = false;
	timer.Simple(dly,function()
		local check = {
			ents.FindByClass("sg_*"),
			ents.FindByClass("goauld_iris"),
			ents.FindByClass("dhd_*"),
			ents.FindByClass("mobiledhd"),
			ents.FindByClass("rg_*"),
			ents.FindByClass("gatebearing"),
			ents.FindByClass("brazier"),
			ents.FindByClass("floor_chevron"),
			ents.FindByClass("destiny_timer"),
			ents.FindByClass("destiny_console"),
			ents.FindByClass("kino_dispenser"),
			ents.FindByClass("ramps"),
			ents.FindByClass("ramps_2"),
			ents.FindByClass("futureramp"),
			ents.FindByClass("sgcramp"),
			ents.FindByClass("icarusramp"),
			ents.FindByClass("sguramp"),
			ents.FindByClass("goauldramp"),
			ents.FindByClass("gravity_controller"),
			ents.FindByClass("atlantis_light"),
			ents.FindByClass("atlantis_trans"),
			ents.FindByClass("prop_physics"),
			ents.FindByClass("eap_doors*"),
			ents.FindByClass("eap_console"),
		};
		local protect = GetConVar("stargate_eap_gatespawner_protect"):GetBool();
		for _,v in pairs(check) do
			for _,e in pairs(v) do
				if (e:GetClass()=="prop_physics") then
					local tbl = e.EntityMods;
					if (tbl and tbl.GateSpawnerProp) then
						tbl = tbl.GateSpawnerProp;
						if(tbl.GateSpawner and tbl.ID) then
							if (Lib.GateSpawner.Ents[tbl.ID]) then
								Lib.GateSpawner.Ents[tbl.ID].Entity = e;
								e.EAPGateSpawnerSpawned = true;
								e:SetNetworkedBool("EAPGateSpawnerSpawned",true);
								e.GateSpawnerID = tbl.ID;
								e.EAPGateSpawnerProtected = protect;
								e:SetNetworkedBool("EAPGateSpawnerProtected",protect);
							end
						end
					end
				else
					if(e.EAPGateSpawnerSpawned and e.GateSpawnerID) then
						if (Lib.GateSpawner.Ents[e.GateSpawnerID]) then
							Lib.GateSpawner.Ents[e.GateSpawnerID].Entity = e;
							e.EAPGateSpawnerProtected = protect;
							e:SetNetworkedBool("EAPGateSpawnerProtected",protect);
						end
					end
					if (e.IsIris and IsValid(e.GateLink) and (e.EAPGateSpawnerSpawned or e.GateLink.EAPGateSpawnerSpawned)) then
						e:IrisProtection();
					end
				end
			end
		end
		Lib.GateSpawner.Spawned = true;
		Lib.GateSpawner.Block = false;
	end);
end