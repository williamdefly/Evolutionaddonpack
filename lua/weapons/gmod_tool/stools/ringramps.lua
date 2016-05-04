/*   Copyright (C) 2010 by Llapp   */
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("stool_stargate");
TOOL.Name=Lib.Language.GetMessage("stool_ring_ramps");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = Lib.Ramps.RingDefault;
TOOL.List = "RingRampModels";
for k,v in pairs(Lib.Ramps.Ring) do
	if (v[1]&&v[2]) then
		list.Set(TOOL.List,k,{Position=v[1],Angle=v[2]});
	elseif (v[1]) then
		list.Set(TOOL.List,k,{Position=v[1]});
	else
		list.Set(TOOL.List,k,{});
	end
end

TOOL.Entity.Class = "ramps";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 50;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_ring_ramps_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_ring_ramps_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_ring_ramps_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_ring_ramps_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_ring_ramps_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_ring_ramps_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_ring_ramps_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="ringramps_model",Category="",Models=self.Models});
end

TOOL:Register();