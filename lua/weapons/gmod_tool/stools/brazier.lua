/*
	Braziers
	Copyright (C) 2010  Madman07
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("cat_decoration");
TOOL.Name=Lib.Language.GetMessage("stool_braziers");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/Boba_Fett/props/brazier.mdl";
TOOL.List = "BrazierModels";
list.Set(TOOL.List,"models/Boba_Fett/props/brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/brazier2.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/goauld_brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/jaffa_brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/ori_brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/ori_brazier2.mdl",{});

TOOL.Entity.Class = "braziers";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 50;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_braziers_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_braziers_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_braziers_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_braziers_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_braziers_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_braziers_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_braziers_limit");

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

function TOOL:PreEntitySpawn(p,e,model,toggle)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="brazier_model",Category="",Models=self.Models});
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"brazier_autoweld");
end

TOOL:Register();