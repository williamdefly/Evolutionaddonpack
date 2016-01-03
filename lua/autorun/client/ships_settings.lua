function StarGate.daedalusSettings(Panel)
	local LAYOUT = "daedalus";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
				{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_shield"),"SHIELD"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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


function StarGate.GateseederSettings(Panel)
	local LAYOUT = "Gateseeder";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
				{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_shield"),"SHIELD"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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


function StarGate.DestinySettings(Panel)
	local LAYOUT = "Destiny";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
				{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_shield"),"SHIELD"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.AlkeshSettings(Panel)
	local LAYOUT = "Alkesh";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.WraithCruiserSettings(Panel)
	local LAYOUT = "WraithCruiser";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.AnubisMotherShipSettings(Panel)
	local LAYOUT = "AnubisMotherShip";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.HatakSettings(Panel)
	local LAYOUT = "Hatak";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.OriMsSettings(Panel)
	local LAYOUT = "OriMs";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{SGLanguage.GetMessage("key_combat_secondary"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.OneillSettings(Panel)
	local LAYOUT = "Oneill";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirs energétiques","FIRE"},
				{"Rayon Asgard","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.PrometheeSettings(Panel)
	local LAYOUT = "Promethee";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirs energétiques","FIRE"},
				{"Rayon Asgard","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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

function StarGate.ReplicatorSettings(Panel)
	local LAYOUT = "ReplicateurMS";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirs energétiques","FIRE"},
				{"Rayon Asgard","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_selfdestruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_out"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
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