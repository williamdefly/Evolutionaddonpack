/*
	SGC ZPM Hub
	Copyright (C) 2010  Llapp
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=Lib.Language.GetMessage("stool_asuran_hub");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/pg_props/pg_stargate/pg_asuran_hub.mdl";
TOOL.List = "ASURANZPMHUB";
list.Set(TOOL.List,"models/pg_props/pg_stargate/pg_asuran_hub.mdl",{Angle=Angle(0,0,0),Position=Vector(0,0,0)});
TOOL.Entity.Class = "asuran_zpmhub";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 5;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_asuran_zpm_hub_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_asuran_zpm_hub_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_asuran_zpm_hub_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_asuran_zpm_hub_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_asuran_zpm_hub_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_asuran_zpm_hub_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_asuran_zpm_hub_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return false;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return end
	local pos = t.HitPos+Vector(0,0,0);
	e:SetPos(pos)
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
    Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"asuran_zpmhub_autoweld");
	Panel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_asuran_zpm_hub_fulldesc")})
end

TOOL:Register();