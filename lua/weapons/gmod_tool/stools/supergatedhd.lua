--[[
	DHD Supergate
	Copyright (C) 2011 Assasin21
]]--

--################# Header
include("weapons/gmod_tool/eap_base_tool.lua");
TOOL.Category=Lib.Language.GetMessage("stool_stargate");
TOOL.Name=Lib.Language.GetMessage("stool_sdhd");

--TOOL.ClientConVar["autolink"] = 1; -- No lifesupport added yet
--TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["toggle"] = KEY_PAD_8;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/Madman07/supergate_dhd/supergate_dhd.mdl";
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview

-- Information about the SENT to spawn
TOOL.Entity.Class = "supergatedhd";
TOOL.Entity.Keys = {"toggle","model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 2;

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_supergate_dhd_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_supergate_dhd_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_supergate_dhd_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_supergate_dhd_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_supergate_dhd_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_supergate_dhd_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_supergate_dhd_limit");
--################# Code
TOOL.Seg = Angle(0,0,0);
--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local model = self:GetClientInfo("model");
	local seg
	for _,v in pairs(ents.FindByClass("supergatedhd")) do
		if v:GetParent() != nil then
			if v:GetParent() == t.Entity then
				 p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_supergate_dhd_exs\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return
			end
		end
	end
	if (t.Entity and t.Entity:GetClass() == "sg_supergate") then
		seg = t.Entity.Segments[1]
		self.Seg = seg;
	else
		return
		 p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_supergate_dhd_err\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	end
	--######## Spawn SENT
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,model);
	if (not IsValid(e)) then return end
	seg = t.Entity.Segments[1]
	e:SetAngles(seg:GetAngles() + Angle(90,0,0));
	e:SetPos(seg:GetPos() + seg:GetUp()*66.2 + seg:GetForward()*23.8);
	e:SetParent(t.Entity)
	--######## Weld things?
	local c = self:Weld(e,t.Entity,true);
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,toggle,model)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,toggle,model)
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleDHDMenu",e);
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=Lib.Language.GetMessage("stool_toggle"),
		Command="supergatedhd_toggle",
	});
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleDHDMenu",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:OpenMenu(p);
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();