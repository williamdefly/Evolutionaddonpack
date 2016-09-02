/*
	ZPM MK III Spawn Tool for GarrysMod10
	Copyright (C) 2010 Llapp
*/

if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=Lib.Language.GetMessage("stool_zpm_mk3");

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["capacity"] = 100;
TOOL.ClientConVar["model"] = "models/pg_props/pg_zpm/pg_zpm.mdl";
TOOL.Entity.Class = "zpmmk3";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 6;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_zpm_mk3_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_zpm_mk3_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_zpm_mk3_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_zpm_mk3_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_zpm_mk3_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_zpm_mk3_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_zpm_mk3_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return false end
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(SERVER and t.Entity and t.Entity.ZPMHub) then
		t.Entity:Touch(e);
		weld = false;
	elseif(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,weld);
	local capacity = tonumber(self:GetClientInfo("capacity"));
	e.Energy = (e.Energy / 100) * math.Clamp(capacity,1,100)
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:NumSlider(Lib.Language.GetMessage("stool_zpm_mk3_capacity"),"zpmmk3_capacity",1,100,0);
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"zpmmk3_autoweld");
	if(Lib.HasResourceDistribution) then
		Panel:CheckBox(Lib.Language.GetMessage("stool_autolink"),"zpmmk3_autolink"):SetToolTip(Lib.Language.GetMessage("stool_autolink_desc"));
	end
	Panel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_zpm_mk3_fulldesc")})
end

TOOL:Register();