Lib.Settings = Lib.Settings or { };

function Lib.Settings.Daedalus(Panel)
	local LAYOUT = "daedalus";
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