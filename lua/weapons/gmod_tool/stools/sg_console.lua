/*
	Console
	Copyright (C) 2011  Madman07
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("cat_decoration");
TOOL.Name=Lib.Language.GetMessage("stool_console");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/MarkJaw/atlantis_console/console.mdl";
TOOL.List = "ConsoleModels";
list.Set(TOOL.List,"models/MarkJaw/atlantis_console/console.mdl",{});
list.Set(TOOL.List,"models/ZsDaniel/atlantis_console/console.mdl",{});
list.Set(TOOL.List,"models/destbar.mdl",{});

TOOL.Entity.Class = "sg_console";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 50;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_console_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_console_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_console_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_console_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_console_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_console_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_console_limit");

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
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="sg_console_model",Category="",Models=self.Models});
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"sg_console_autoweld");
end

TOOL:Register();