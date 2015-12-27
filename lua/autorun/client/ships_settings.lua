function StarGate.daedalusSettings(Panel)
	local LAYOUT = "daedalus";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Canon Principal","FIRE"},
				{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Bouclier","SHIELD"},
				{"Sortir","EXIT"},
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
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Canon Principal","FIRE"},
				{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Bouclier","SHIELD"},
				{"Sortir","EXIT"},
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
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Canon Principal","FIRE"},
				{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Bouclier","SHIELD"},
				{"Sortir","EXIT"},
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

function StarGate.NavigatorSettings(Panel)
	local LAYOUT = "Navigator";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				//{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Clique Gauche","FIRE"},
				{"Clique Droit","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Sortir","EXIT"},
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
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Sortir","EXIT"},
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
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Sortir","EXIT"},
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
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Sortir","EXIT"},
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
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Sortir","EXIT"},
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

function StarGate.OriSettings(Panel)
	local LAYOUT = "Ori";
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
				{"Boost","SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{"Tirer","FIRE"},
				//{"Canons Secondaire","TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{"Autodestruction","BOOM"},
				{"Sortir","EXIT"},
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
				{"Avancer","FWD"},
				{"Aller à gauche","LEFT"},
				{"Aller à droite","RIGHT"},
				{"Reculer","BACK"},
				{"Monter","UP"},
				{"Descendre","DOWN"},
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
				{"Autodestruction","BOOM"},
				{"Sortir","EXIT"},
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