/*
	Tokra Shield Emmiter
	Copyright (C) 2011  Madman07
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("stool_tech")
TOOL.Name=Lib.Language.GetMessage("stool_tshield");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/Madman07/tokra_shield/generator.mdl";

TOOL.Entity.Class = "tokra_shield_emmiter";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 2;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_tokra_shield_emmiter_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_tokra_shield_emmiter_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_tokra_shield_emmiter_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_tokra_shield_emmiter_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_tokra_shield_emmiter_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_tokra_shield_emmiter_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_tokra_shield_emmiter_limit");

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
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"tokrashield_emmiter_autoweld");
end

TOOL:Register();