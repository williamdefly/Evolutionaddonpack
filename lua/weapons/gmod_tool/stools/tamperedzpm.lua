/*
	Tampered ZPM
	Copyright (C) 2010  Llapp
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category="Weapons";
TOOL.Name=Lib.Language.GetMessage("stool_tzpm");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["model"] = "models/pg_props/pg_zpm/pg_zpm.mdl";
TOOL.Entity.Class = "tamperedzpm";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 3;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_tampered_zpm_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_tampered_zpm_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_tampered_zpm_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_tampered_zpm_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_tampered_zpm_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_tampered_zpm_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_tampered_zpm_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	if(SERVER and t.Entity and t.Entity.ZPMHub) then
		t.Entity:Touch(e);
		weld = false;
	elseif(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,weld);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"tamperedzpm_autoweld");
	if(Lib.HasResourceDistribution) then
		Panel:CheckBox(Lib.Language.GetMessage("stool_autolink"),"tamperedzpm_autolink"):SetToolTip(Lib.Language.GetMessage("stool_autolink_desc"));
	end
	Panel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_tampered_zpm_fulldesc"),})
	Panel:AddControl("Label", {Text = "\n"..Lib.Language.GetMessage("stool_desc").."\n\n"..Lib.Language.GetMessage("stool_tampered_zpm_fulldesc2"),})
end

TOOL:Register();