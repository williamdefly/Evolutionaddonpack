/*
	Stargate Lib for GarrysMod10
	Copyright (C) 2007-2009  aVoN

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

Lib.Settings = Lib.Settings or { };

function Lib.Settings.Alkesh(Panel)
	local LAYOUT = "Alkesh";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				--{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

-- function Lib.Settings.AnubisMotherShip(Panel)
-- 	local LAYOUT = "AnubisMotherShip";
-- 	local KEYS = {
-- 		{
-- 			Name = Lib.Language.GetMessage("key_move_title"),
-- 			Keys = {
-- 				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
-- 				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
-- 				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
-- 				{Lib.Language.GetMessage("key_move_back"),"BACK"},
-- 				{Lib.Language.GetMessage("key_move_up"),"UP"},
-- 				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
-- 				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
-- 			},
-- 		},
-- 		{
-- 			Name = Lib.Language.GetMessage("key_combat_title"),
-- 			Keys = {
-- 				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
-- 				{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
-- 			},
-- 		},
-- 		{
-- 			Name = Lib.Language.GetMessage("key_act_title"),
-- 			Keys = {
-- 				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
-- 				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
-- 			},
-- 		},
-- 		{
-- 			Name = Lib.Language.GetMessage("key_view_title"),
-- 			Keys = {
-- 				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
-- 				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
-- 				{Lib.Language.GetMessage("key_view_up"),"A+"},
-- 				{Lib.Language.GetMessage("key_view_down"),"A-"},
-- 			},
-- 		},
-- 	}
-- 	for _,v in pairs(KEYS) do
-- 		Panel:Help("");
-- 		Panel:Help(v.Name);
-- 		for _,v in pairs(v.Keys) do
-- 			local KEY = vgui.Create("SKeyboardKey",Panel);
-- 			KEY:SetData(LAYOUT,v[1],v[2]);
-- 			Panel:AddPanel(KEY);
-- 		end
-- 	end
-- end

function Lib.Settings.Aurora(Panel)
	local LAYOUT = "Aurora";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_drones"),"FIRE"},
				--{Lib.Language.GetMessage("key_track_drones"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Daedalus(Panel)
	local LAYOUT = "Dedale";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_shield"),"SHIELD"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.WraithDart(Panel)
	local LAYOUT = "WraithDart";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_harv"),"SUCK"},
				{Lib.Language.GetMessage("key_act_spit"),"SPIT"},
				{Lib.Language.GetMessage("key_act_dhd"),"DHD"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.DeathGlider(Panel)
	local LAYOUT = "DeathGlider";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_roll_left"),"RL"},
				{Lib.Language.GetMessage("key_roll_right"),"RR"},
				{Lib.Language.GetMessage("key_roll_reset"),"RROLL"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Destiny(Panel)
	local LAYOUT = "Destiny";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_shield"),"SHIELD"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.F302(Panel)
	local LAYOUT = "F-302";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_roll_left"),"RL"},
				{Lib.Language.GetMessage("key_roll_right"),"RR"},
				{Lib.Language.GetMessage("key_roll_reset"),"RROLL"},
				{Lib.Language.GetMessage("key_air_brake"),"BRAKE"},
				{Lib.Language.GetMessage("key_move_boost"),"BOOST"},

			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				{Lib.Language.GetMessage("key_track_missiles"),"TRACK"},
				{Lib.Language.GetMessage("key_combat_toggle"),"CHGATK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_eject"),"EJECT"},
				{Lib.Language.GetMessage("key_act_wheels"),"WHEELS"},
				{Lib.Language.GetMessage("key_act_flares"),"FLARES"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
				{Lib.Language.GetMessage("key_act_cockpit"),"COCKPIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
			--	{"Toggle thirdperson view","VIEW"},
				{Lib.Language.GetMessage("key_view_hud"),"HIDE"},
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
				{Lib.Language.GetMessage("key_view_toggle"),"FPV"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.GateGlider(Panel)
	local LAYOUT = "GateGlider";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_roll_left"),"RL"},
				{Lib.Language.GetMessage("key_roll_right"),"RR"},
				{Lib.Language.GetMessage("key_roll_reset"),"RROLL"},
			},
		},

		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				--{"Track Drones","TRACK"},
			},
		},

		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_dhd"),"DHD"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Gateseeder(Panel)
	local LAYOUT = "Gateseeder";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_shield"),"SHIELD"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Hatak(Panel)
	local LAYOUT = "Hatak";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				--{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Jumper(Panel)
	local LAYOUT = "PuddleJumper";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_roll_left"),"RL"},
				{Lib.Language.GetMessage("key_roll_right"),"RR"},
				{Lib.Language.GetMessage("key_roll_reset"),"RROLL"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_drones"),"FIRE"},
				{Lib.Language.GetMessage("key_track_drones"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_cloak"),"CLOAK"},
				{Lib.Language.GetMessage("key_act_dhd"),"DHD"},
				{Lib.Language.GetMessage("key_act_pods"),"SPD"},
				{Lib.Language.GetMessage("key_act_weapon"),"WEPPODS"},
				{Lib.Language.GetMessage("key_act_door"),"DOOR"},
				{Lib.Language.GetMessage("key_act_light"),"LIGHT"},
				{Lib.Language.GetMessage("key_act_shield"),"SHIELD"},
				{Lib.Language.GetMessage("key_act_standby"),"HOVER"},
				{Lib.Language.GetMessage("key_act_auto"),"AUTOPILOT"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_hud"),"HIDEHUD"},
				{Lib.Language.GetMessage("key_view_lsd"),"HIDELSD"},
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
				{Lib.Language.GetMessage("key_view_toggle"),"VIEW"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

-- function Lib.Settings.MALP(Panel)
-- 	local LAYOUT = "MALP";
-- 	local KEYS = {
-- 		{
-- 			Name = Lib.Language.GetMessage("key_move_title"),
-- 			Keys = {
-- 				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
-- 				{Lib.Language.GetMessage("key_turn_left"),"LEFT"},
-- 				{Lib.Language.GetMessage("key_turn_right"),"RIGHT"},
-- 				{Lib.Language.GetMessage("key_move_back"),"BACK"},
-- 			},
-- 		},

-- 		{
-- 			Name = Lib.Language.GetMessage("key_view_title"),
-- 			Keys = {
-- 				{Lib.Language.GetMessage("key_cam_view"),"VIEW"},
-- 				{Lib.Language.GetMessage("key_cam_left"),"CAMLEFT"},
-- 				{Lib.Language.GetMessage("key_cam_right"),"CAMRIGHT"},
-- 				{Lib.Language.GetMessage("key_cam_up"),"CAMUP"},
-- 				{Lib.Language.GetMessage("key_cam_down"),"CAMDOWN"},
-- 				{Lib.Language.GetMessage("key_cam_reset"),"RESETCAM"},
-- 			},
-- 		},
-- 	}
-- 	for _,v in pairs(KEYS) do
-- 		Panel:Help("");
-- 		Panel:Help(v.Name);
-- 		for _,v in pairs(v.Keys) do
-- 			local KEY = vgui.Create("SKeyboardKey",Panel);
-- 			KEY:SetData(LAYOUT,v[1],v[2]);
-- 			Panel:AddPanel(KEY);
-- 		end
-- 	end
-- end

function Lib.Settings.OriMs(Panel)
	local LAYOUT = "OriMs";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				--{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Oneill(Panel)
	local LAYOUT = "Oneill";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Promethee(Panel)
	local LAYOUT = "Promethee";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Replicator(Panel)
	local LAYOUT = "ReplicateurMS";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Shuttle(Panel)
	local LAYOUT = "Shuttle";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_shield"),"SHIELD"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.Teltak(Panel)
	local LAYOUT = "Tel_tak";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_combat_beam"),"FIRE"},
				{Lib.Language.GetMessage("key_act_cloak"),"CLOAK"},
				{Lib.Language.GetMessage("key_act_door"),"DOOR"},
				{Lib.Language.GetMessage("key_act_standby"),"LAND"},
				--{Lib.Language.GetMessage("key_act_hyper"),"HYPERSPACE"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
				{Lib.Language.GetMessage("key_view_toggle"),"FPV"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

function Lib.Settings.WraithCruiser(Panel)
	local LAYOUT = "WraithCruiser";
	local KEYS = {
		{
			Name = Lib.Language.GetMessage("key_move_title"),
			Keys = {
				{Lib.Language.GetMessage("key_move_forward"),"FWD"},
				{Lib.Language.GetMessage("key_move_left"),"LEFT"},
				{Lib.Language.GetMessage("key_move_right"),"RIGHT"},
				{Lib.Language.GetMessage("key_move_back"),"BACK"},
				{Lib.Language.GetMessage("key_move_up"),"UP"},
				{Lib.Language.GetMessage("key_move_down"),"DOWN"},
				{Lib.Language.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_combat_title"),
			Keys = {
				{Lib.Language.GetMessage("key_combat_primary"),"FIRE"},
				--{Lib.Language.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_act_title"),
			Keys = {
				{Lib.Language.GetMessage("key_act_selfdestruct"),"BOOM"},
				{Lib.Language.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = Lib.Language.GetMessage("key_view_title"),
			Keys = {
				{Lib.Language.GetMessage("key_view_zoomin"),"Z+"},
				{Lib.Language.GetMessage("key_view_zoomout"),"Z-"},
				{Lib.Language.GetMessage("key_view_up"),"A+"},
				{Lib.Language.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end