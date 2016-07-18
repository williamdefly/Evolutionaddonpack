/*
	Naquada Bomb
	Copyright (C) 2010  Madman07, Stargate Extras
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("stool_weapons");
TOOL.Name= Lib.Language.GetMessage("entity_asgard_ashen_def");

TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["model"] = "models/Madman07/ashen_defence/ashen_defence.mdl";
TOOL.Entity.Class = "ashendefence";
TOOL.Entity.Keys = {"autoweld"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 10;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_ashen_defence_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_ashen_defence_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_ashen_defence_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_ashen_defence_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_ashen_defence_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_ashen_defence_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_ashen_defence_limit");



function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	local c = self:Weld(e,t.Entity,weld);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end
/*
function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end
*/
function TOOL:ControlsPanel(Panel)
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"ashenweapon_autoweld");
end

TOOL:Register();