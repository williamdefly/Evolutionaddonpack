/*
	Iris Spawn Tool for GarrysMod10
	Copyright (C) 2007  aVoN
	Updated in 2016 by Elanis 

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

--################# Header
include("weapons/gmod_tool/eap_base_tool.lua");
TOOL.Category=Lib.Language.GetMessage("stool_stargate");
TOOL.Name=Lib.Language.GetMessage("stool_iris_atlantis");

TOOL.ClientConVar["toggle"] = KEY_PAD_2;
TOOL.ClientConVar["activate"] = KEY_B;
TOOL.ClientConVar["deactivate"] = KEY_C;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/zup/Stargate/sga_shield.mdl";
TOOL.GhostExceptions = {"sg_atlantis","sg_sg1","sg_tollan","sg_infinity","sg_universe"}; -- Add your entity class to this, to stop drawing the GhostPreview on this

-- Information about the SENT to spawn
TOOL.Entity.Class = "sg_iris";
TOOL.Entity.Keys = {"model","toggle","activate","deactivate","IsActivated"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 10;

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_stargate_iris_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_stargate_iris_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_stargate_iris_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_stargate_iris_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_stargate_iris_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_stargate_iris_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_stargate_iris_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	if(not IsValid(t.Entity) or not t.Entity.IsStargate) then
	    p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_stargate_iris_err\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	if(t.Entity.IsSupergate or t.Entity:GetClass()=="sg_orlin") then
	    p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_stargate_iris_err2\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	if (t.Entity.EAPGateSpawnerSpawned and Lib.CFG and not Lib.CFG:Get("stargate_iris","gatespawner",true)) then
	    p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_stargate_iris_err3\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end
	--######## Spawn SENT
	local toggle = self:GetClientNumber("toggle");
	local activate = self:GetClientNumber("activate");
	local deactivate = self:GetClientNumber("deactivate");
	local model = self:GetClientInfo("model");
	MsgN(model);
	local e = self:SpawnSENT(p,t,model,toggle,activate,deactivate);
	if (not IsValid(e)) then return end
	if(IsValid(t.Entity) and t.Entity.IsStargate) then
		for _,v in pairs(ents.FindInSphere(t.Entity:GetPos(),10)) do
			if(v.IsIris and v ~= e) then
				if (v.EAPGateSpawnerSpawned) then
					e:Remove();
					p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"iris_gatespawner\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
					return
				else
					v:Remove(); -- Remove old, existing iri's (replace them with this new one)
				end
			end
		end
		e:SetPos(t.Entity:GetPos()+t.Entity:GetForward()*0.4); -- A little offset, or you can see the EH through iris/shield (ugly!)
		e:SetAngles(t.Entity:GetAngles());
	end
	e.GateLink = t.Entity;
	if (t.Entity.EAPGateSpawnerSpawned) then
		p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"iris_protection\"), NOTIFY_GENERIC, 5); surface.PlaySound( \"buttons/button9.wav\" )");
		e:IrisProtection();
	end
	e:Toggle(true); -- Always spawn an iris/shield closed! (true means close no matter if we have not enough energy)

	--######## Weld things?
	local c = self:Weld(e,t.Entity,true);
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,model,toggle,activate,deactivate,IsActivated)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,model,toggle,activate,deactivate,IsActivated)
	if(not IsValid(e)) then return end;
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleIris",e);
	end
	if(activate) then
		numpad.OnDown(p,activate,"ActivateIris",e);
	end
	if(deactivate) then
		numpad.OnDown(p,deactivate,"DeActivateIris",e);
	end
	if((IsActivated and not e.IsActivated) or (not IsActivated and e.IsActivated)) then
		e:Toggle();
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=Lib.Language.GetMessage("stool_toggle"),
		Command="iris_atlantis_toggle",
	});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=Lib.Language.GetMessage("stool_activate"),
		Command="iris_atlantis_activate",
		Label2=Lib.Language.GetMessage("stool_deactivate"),
		Command2="iris_atlantis_deactivate",
	});
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"iris_atlantis_autoweld");
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:Toggle();
		end
	);
	numpad.Register("ActivateIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(not e.IsActivated) then e:Toggle() end;
		end
	);
	numpad.Register("DeActivateIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e.IsActivated) then e:Toggle() end;
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();