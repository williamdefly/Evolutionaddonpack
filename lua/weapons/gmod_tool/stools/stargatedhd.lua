/*
	Shield Spawner for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# Header
include("weapons/gmod_tool/eap_base_tool.lua");
TOOL.Category=Lib.Language.GetMessage("stool_stargate");
TOOL.Name=Lib.Language.GetMessage("stool_mdhd");

--TOOL.ClientConVar["autolink"] = 1; -- No lifesupport added yet
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["toggle"] = 7;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/props_c17/clock01.mdl";
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "MobileDHDModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{});
list.Set(TOOL.List,"models/props_interiors/pot01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});
list.Set(TOOL.List,"models/props_c17/computer01_keyboard.mdl",{});
list.Set(TOOL.List,"models/props_lab/keypad.mdl",{Angle=Angle(-90,0,0),Position=Vector(-5,0,0)});
list.Set(TOOL.List,"models/props_combine/breenconsole.mdl",{Angle=Angle(0,90,0)});
list.Set(TOOL.List,"models/zsdaniel/atlantis-dhd/dhd.mdl",{});
list.Set(TOOL.List,"models/iziraider/kinoremote/w_kinoremote.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "mobiledhd";
TOOL.Entity.Keys = {"toggle","model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 3; -- A person generally can spawn 1 mobile dhd

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = Lib.Language.GetMessage("stool_stargate_eap_dhd_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_stargate_eap_dhd_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_stargate_eap_dhd_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_stargate_eap_dhd_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_stargate_eap_dhd_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_stargate_eap_dhd_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_stargate_eap_dhd_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local model = self:GetClientInfo("model");
	--######## Spawn SENT
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true; -- We have nothing to update a mobile DHD
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,model);
	--[[ -- No life support added yet
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity); -- Link to that energy system, if valid
	end
	--]]
	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,toggle,model)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,toggle,model)
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleDHDMenu",e);
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	/*Panel:AddControl("ComboBox",{
		Label="Presets",
		MenuButton=1,
		Folder="stargatedhd",
		Options={
			Default=self:GetDefaultSettings(),
		},
		CVars=self:GetSettingsNames(),
	});*/
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=Lib.Language.GetMessage("stool_toggle"),
		Command="stargatedhd_toggle",
	});
	Panel:AddControl("PropSelect",{Label=Lib.Language.GetMessage("stool_model"),ConVar="stargatedhd_model",Category="",Models=self.Models});
	Panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"stargatedhd_autoweld");
	--[[ -- No LifeSupport added yet
	if(Lib.HasResourceDistribution) then
		Panel:CheckBox(Lib.Language.GetMessage("stool_autolink"),"stargate_eap_dhd_autolink"):SetToolTip(Lib.Language.GetMessage("stool_autolink_desc"));
	end
	--]]
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleDHDMenu",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:OpenMenu(p);
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();