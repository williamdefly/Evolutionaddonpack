Lib.Settings = Lib.Settings or { };

MsgN("eap_librairies/shared/client_settings.lua")

function Lib.Settings.Graphic(Panel)

	local high = Lib.Language.GetMessage("vis_fps_high");
	local medium = Lib.Language.GetMessage("vis_fps_medium");
	local low = Lib.Language.GetMessage("vis_fps_low");

	Panel:ClearControls();

	Panel:Help("");
	Panel:Help(Lib.Language.GetMessage("vis_ships"));
	Panel:Help("");

	-- Configuration
	local disable = {}
	local conf = Panel:CheckBox(Lib.Language.GetMessage("vis_ships_title"),"cl_stargate_visualsship");
	conf:SetToolTip(Lib.Language.GetMessage("vis_title_desc"));
	conf.OnChange = function(self,val)
		for k,v in pairs(disable) do
			if (val) then
				v:SetDisabled(false);
			else
				v:SetDisabled(true);
			end
		end
	end
	Panel:Help("");
	-- Jumper
	Panel:Help(Lib.Language.GetMessage("ent_ship_jumper"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"), "cl_jumper_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_heatwave"), "cl_jumper_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_sprites"), "cl_jumper_sprites"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- F302
	Panel:Help(Lib.Language.GetMessage("ent_ship_f302"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_heatwave"), "cl_F302_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_sprites"), "cl_F302_sprites"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Shuttle
	Panel:Help(Lib.Language.GetMessage("ent_ship_shuttle"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_heatwave"), "cl_shuttle_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_sprites"), "cl_shuttle_sprites"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Wraith Dart
	Panel:Help(Lib.Language.GetMessage("ent_ship_dart"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_heatwave"), "cl_dart_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Control Chair
	Panel:Help(Lib.Language.GetMessage("ent_control_chair"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"), "cl_chair_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);

	Panel:Help("");
	Panel:Help(Lib.Language.GetMessage("vis_weapons"));
	Panel:Help("");

	-- Configuration
	local disable = {}
	local conf = Panel:CheckBox(Lib.Language.GetMessage("vis_weapons_title"),"cl_stargate_visualsweapon");
	conf:SetToolTip(Lib.Language.GetMessage("vis_title_desc"));
	conf.OnChange = function(self,val)
		for k,v in pairs(disable) do
			if (val) then
				v:SetDisabled(false);
			else
				v:SetDisabled(true);
			end
		end
	end
	Panel:Help("");
	-- Staff Weapon and Dexgun
	Panel:Help(Lib.Language.GetMessage("vis_weap_title"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_hit_dyn_light"),"cl_staff_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_fly_dyn_light"),"cl_staff_dynlights_flight"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_smoke"),"cl_staff_smoke"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_wall"),"cl_staff_scorch"));
	table.GetLastValue(disable):SetToolTip(low);
	-- Zat'nik'tel
	Panel:Help(Lib.Language.GetMessage("eap_weapon_zat"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"),"cl_zat_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_hit_eff"),"cl_zat_hiteffect"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_diss_eff"),"cl_zat_dissolveeffect"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Drones
	Panel:Help(Lib.Language.GetMessage("stool_drones"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_glow"),"cl_drone_glow"));
	table.GetLastValue(disable):SetToolTip(low);
	-- Naquadah Bomb
	Panel:Help(Lib.Language.GetMessage("stool_naq_bomb"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_sunbeams"), "cl_gate_nuke_sunbeams"));
	table.GetLastValue(disable):SetToolTip(Lib.Language.GetMessage("vis_sunbeams_desc",high));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_part_rings"), "cl_gate_nuke_rings"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_shield_part"), "cl_gate_nuke_shieldrings"));
	table.GetLastValue(disable):SetToolTip(Lib.Language.GetMessage("vis_shield_part_desc",high));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_plasma"), "cl_gate_nuke_plasma"));
	table.GetLastValue(disable):SetToolTip(Lib.Language.GetMessage("vis_plasma_desc",low));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_plasma_light"), "cl_gate_nuke_dynlights"));
	table.GetLastValue(disable):SetToolTip(Lib.Language.GetMessage("vis_plasma_desc",medium));
	-- Stargate Overloader
	Panel:Help(Lib.Language.GetMessage("entity_overloader"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_refl_rings"), "cl_overloader_refract"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_part_rings"), "cl_overloader_particle"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"), "cl_overloader_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Asuran Gun
	Panel:Help(Lib.Language.GetMessage("entity_asuran_weapon"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_sm_laser"), "cl_asuran_laser"));
	table.GetLastValue(disable):SetToolTip(low);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"), "cl_asuran_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Dakara Super Weapon
	Panel:Help(Lib.Language.GetMessage("entity_dakara"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_charge_up"), "cl_dakara_rings"));
	table.GetLastValue(disable):SetToolTip(low);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_refl_sphere"), "cl_dakara_refract"));
	table.GetLastValue(disable):SetToolTip(medium);

	Panel:Help("");
	Panel:Help(Lib.Language.GetMessage("vis_misc"));
	Panel:Help("");
	-- Configuration
	local disable = {}
	local conf = Panel:CheckBox(Lib.Language.GetMessage("vis_misc_title"),"cl_stargate_visualsmisc");
	conf:SetToolTip(Lib.Language.GetMessage("vis_title_desc"));
	conf.OnChange = function(self,val)
		for k,v in pairs(disable) do
			if (val) then
				v:SetDisabled(false);
			else
				v:SetDisabled(true);
			end
		end
	end

	Panel:Help("");
	-- Stargates
	table.insert(disable,Panel:Help(Lib.Language.GetMessage("stool_stargate")));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"),"cl_stargate_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	if (file.Exists("materials/zup/stargate/effect_03.vmt","GAME")) then
		table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_ripple"),"cl_stargate_ripple"));
		table.GetLastValue(disable):SetToolTip(medium);
    end
    table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_kawoosh_eff"),"cl_stargate_kenter"));
    table.GetLastValue(disable):SetToolTip(low);
	Panel:CheckBox(Lib.Language.GetMessage("vis_kawoosh_mat"), "cl_kawoosh_material"):SetToolTip(Lib.Language.GetMessage("vis_kawoosh_mat_desc"));
	Panel:CheckBox(Lib.Language.GetMessage("vis_stargate_eff"), "cl_stargate_effects"):SetToolTip(Lib.Language.GetMessage("vis_stargate_eff_desc",medium));
	-- Stargate Universe
	Panel:Help(Lib.Language.GetMessage("stargate_universe"));	
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"),"cl_stargate_un_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Stargate Wormhole
	Panel:Help(Lib.Language.GetMessage("stargate_wormhole"));
	Panel:CheckBox(Lib.Language.GetMessage("vis_stargate_wormhole"), "cl_stargate_wormhole"):SetToolTip(Lib.Language.GetMessage("vis_stargate_wormhole_desc",low));
	-- SuperGate
	Panel:Help(Lib.Language.GetMessage("stargate_supergate"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"), "cl_supergate_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Shield
	Panel:Help(Lib.Language.GetMessage("stool_shield"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"),"cl_shield_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_shield_bubble"),"cl_shield_bubble"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_hit_refl"),"cl_shield_hitradius"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_hit_eff"),"cl_shield_hiteffect"));
	table.GetLastValue(disable):SetToolTip(low);
	-- Atl Shield
	Panel:Help(Lib.Language.GetMessage("vis_atl_shield"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_refl"), "cl_shieldcore_refract"));
	table.GetLastValue(disable):SetToolTip(Lib.Language.GetMessage("vis_refl_desc",low));
	-- Harvester
	Panel:Help(Lib.Language.GetMessage("stool_harvester"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"),"cl_harvester_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Cloaking
	Panel:Help(Lib.Language.GetMessage("stool_cloak"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_cloak_pass"),"cl_cloaking_hitshader"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_cloak_eff"),"cl_cloaking_shader"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Apple Core
	Panel:Help(Lib.Language.GetMessage("entity_apple_core"));
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_dyn_light"), "cl_applecore_light"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(Lib.Language.GetMessage("vis_smoke"), "cl_applecore_smoke"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Huds
	Panel:Help(Lib.Language.GetMessage("vis_hud_title"));
	Panel:CheckBox(Lib.Language.GetMessage("vis_hud_energy"), "cl_draw_huds"):SetToolTip(Lib.Language.GetMessage("vis_hud_energy_desc",low));
	Panel:CheckBox(Lib.Language.GetMessage("vis_dhd_glyphs"), "cl_dhd_letters"):SetToolTip(Lib.Language.GetMessage("vis_dhd_glyphs_desc",low));
end
