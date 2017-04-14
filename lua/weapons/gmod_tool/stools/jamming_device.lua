/*
	Jamming Device
	Copyright (C) 2010  Madman07
*/
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("stool_tech");
TOOL.Name=Lib.Language.GetMessage("stool_jamming");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["immunity"] = 0;
TOOL.ClientConVar["size"] = 100;
TOOL.ClientConVar["toggle"] = KEY_PAD_2;

TOOL.ClientConVar["model"] = "models/micropro/shield_gen.mdl";
TOOL.List = "JammModels";
list.Set(TOOL.List,"models/micropro/shield_gen.mdl",{}); -- Thanks micropro for this model!
list.Set(TOOL.List,"models/props_combine/weaponstripper.mdl",{Angle=Angle(-90,0,0),Position=Vector(15,0,-60)});
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{});
if (file.Exists("models/props_c17/pottery08a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery08a.mdl",{});
end
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{});
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});

TOOL.Entity.Class = "jammingdevice";
TOOL.Entity.Keys = {"model","toggle","size","immunity"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 5;
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_jamming_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_jamming_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_jamming_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_jamming_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_jamming_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_jamming_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_jamming_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local toggle = self:GetClientNumber("toggle");
	local size = math.Clamp(self:GetClientNumber("size"),1,1024);
	local immunity = self:GetClientNumber("immunity");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		t.Entity:Setup(size, util.tobool(immunity));
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model,toggle, size, immunity);
	if (not IsValid(e)) then return end
	e:Setup(size, util.tobool(immunity));
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model,toggle, size, immunity)
	e:SetModel(model);
end

function TOOL:PostEntitySpawn(p,e,model,toggle, size, immunity)
	e:Setup(size or 100, util.tobool(immunity));
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleJamming",e);
	end
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="jamming_device_model",Category="",Models=self.Models});
	Panel:NumSlider(Lib.Language.GetMessage("stool_size"),"jamming_device_size",100,1024,0);
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=Lib.Language.GetMessage("stool_toggle"),
		Command="jamming_device_toggle",
	});
	Panel:CheckBox(Lib.Language.GetMessage("stool_immunity"),"jamming_device_immunity"):SetToolTip(Lib.Language.GetMessage("stool_jamming_imm_desc"));
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"jamming_device_autoweld");
end

if SERVER then
	numpad.Register("ToggleJamming",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e.IsEnabled) then
				e.IsEnabled = false;
			else
				e.IsEnabled = true;
			end
		end
	);
end

TOOL:Register();