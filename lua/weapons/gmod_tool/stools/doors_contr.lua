/*
	Door Controller
	Copyright (C) 2011  Madman07
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("cat_decoration");
TOOL.Name=Lib.Language.GetMessage("stool_door_c");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/iziraider/destinybutton/destinybutton.mdl";
TOOL.List = "ControllerModels";
list.Set(TOOL.List,"models/iziraider/destinybutton/destinybutton.mdl",{});
list.Set(TOOL.List,"models/boba_fett/props/buttons/atlantis_button.mdl",{});
list.Set(TOOL.List,"models/madman07/ring_panel/goauld_panel.mdl",{Angle=Angle(270,0,0),Position=Vector(0,0,-12)});
list.Set(TOOL.List,"models/zsdaniel/ori-ringpanel/panel.mdl",{Angle=Angle(270,0,0),Position=Vector(0,0,-5)});
list.Set(TOOL.List,"models/madman07/ring_panel/ancient/panel.mdl",{Angle=Angle(270,0,0),Position=Vector(0,0,-10)});

TOOL.Entity.Class = "doors_contr";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 10;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_cap_door_contr_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_cap_door_contr_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_cap_door_contr_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_cap_door_contr_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_cap_door_contr_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_cap_door_contr_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_cap_door_contr_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");

	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model);
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="doors_contr_model",Category="",Models=self.Models});
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"doors_contr_autoweld");
end

TOOL:Register();