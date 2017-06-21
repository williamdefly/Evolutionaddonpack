if(SERVER)then
	return false
end

MsgN("eap_librairies/client/menu.lua")

EAP.SpawnList.Props = {
"models/props_lodka/ori_bucher.mdl",
"models/atero.mdl",
"models/yorkus/transporter/tray.mdl",
"models/ships/madman07/daedalus/daedalus.mdl",
"models/ship/alkesh.mdl",
"models/ship/aurore.mdl",
"models/ship/destiny.mdl",
"models/ship/doors_setter.mdl",
"models/ship/oneil.mdl",
"models/ship/ori.mdl",
"models/ship/petheship.mdl",
"models/ship/rship01.mdl",
"models/ship/sgw_hatak.mdl",
"models/ship/wraith.mdl",
"models/elanis/container/hatak_container.mdl",
"models/elanis/sarcophage/sarcophage_goauld.mdl",
"models/destbar.mdl"
}

spawnmenu.AddContentType( "eap_entity", function( container, obj )

	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end

	local icon = vgui.Create( "ContentIcon", container )
		icon:SetContentType( "entity" )
		icon:SetSpawnName( obj.spawnname )
		icon:SetName( obj.nicename )
		icon:SetMaterial( obj.material )
		icon:SetAdminOnly( obj.admin )

	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon;

end )

local function AddToTab(Categorised, pnlContent, tree, node)
	--
	-- Add a tree node for each category
	--
	for CategoryName, v in SortedPairs( Categorised ) do
		-- Add a node to the tree
		local icon = "icon16/bricks.png";

			local node = tree:AddNode( CategoryName, icon );

				-- When we click on the node - populate it using this function
			node.DoPopulate = function( self )

				-- If we've already populated it - forget it.
				if ( self.PropPanel ) then return end

				-- Create the container panel
				self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
				self.PropPanel:SetVisible( false )
				self.PropPanel:SetTriggerSpawnlistChange( false )

				for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
					local adm_only = false;
					spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "entity", self.PropPanel,
					{
						nicename	= ent.PrintName or ent.__ClassName,
						spawnname	= ent.ClassName,
						material	= "entities/"..ent.ClassName..".png",
						admin		= adm_only,
						author		= ent.Author,
						info		= ent.Instructions,
					})

				end
			end

			-- If we click on the node populate it and switch to it.
			node.DoClick = function( self )

				self:DoPopulate()
				pnlContent:SwitchPanel( self.PropPanel );

			end
    end

end

hook.Add( "EAPTab", "AddEAPEntity", function( pnlContent, tree, node )
	local Categorised = {}

	-- Add this list into the tormoil
	local SpawnableEntities = list.Get( "EAP" )
	if ( SpawnableEntities ) then
		for k, v in pairs( SpawnableEntities ) do
			v.Category = v.Category or "Other"
			v.__ClassName = k;
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			table.insert( Categorised[ v.Category ], v )
		end
	end

	AddToTab(Categorised, pnlContent, tree, node)
	Categorised = {}
	
	-- Loop through the weapons and add them to the menu
	local Weapons = list.Get( "Weapon" )
	local Categorised = {}
		
	-- Build into categories
	for k, weapon in pairs( Weapons ) do
		Categorised[ weapon.Category ] = Categorised[ weapon.Category ] or {}
		table.insert( Categorised[ weapon.Category ], weapon )
	end


	Weapons = nil

	-- Loop through each category
	for CategoryName, v in SortedPairs( Categorised ) do
	
		if(CategoryName=="EAP") then
		
		-- Add a node to the tree
		local node = tree:AddNode( Lib.Language.GetMessage("cat_swep"), "icon16/gun.png" );
				
		-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )
	
			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end
		
			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )
		
			for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
									
				spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "weapon", self.PropPanel, 
				{ 
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.ClassName,
					material	= "entities/"..ent.ClassName..".png",
					admin		= ent.AdminOnly
				})
			
			end
	
		end
		
		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel );
	
		end
		
		end
		
	end

	local node = tree:AddNode( Lib.Language.GetMessage("cat_props"), "icon16/folder.png", true );

	node.DoPopulate = function(self)

		-- If we've already populated it - forget it.
		if ( self.PropPanel ) then return end

		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		--self.PropPanel:SetTriggerSpawnlistChange( false )

		local lines = EAP.SpawnList.Props;
		for _,l in pairs(lines) do
		if (not l or l=="") then continue; end
		local cp = spawnmenu.GetContentType( "model" );
		if ( cp ) then
		cp( self.PropPanel, { model = l } )
		end
		end
		
	end
	
	-- If we click on the node populate it and switch to it.
	node.DoClick = function( self )

		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel );

	end
	local node = tree:AddNode( Lib.Language.GetMessage("spawninfo_title"), "icon16/information.png", true );

	local cats = {
		{Lib.Language.GetMessage("spawninfo_news"),Lib.HTTP.NEWS,"icon16/newspaper.png"},
		{Lib.Language.GetMessage("spawninfo_wiki"),Lib.HTTP.WIKI,"icon16/page_white_text.png"},
		--{Lib.Language.GetMessage("spawninfo_donate"),Lib.HTTP.DONATE,"icon16/money_add.png"},
	}

	for k,v in pairs(cats) do
		local panel = node:AddNode( v[1], v[3] );
		-- this code is buggy, can't understand why i can't enter data into textbox, so using steam browser instead.
		/*panel.DoPopulate = function(self)
			if ( self.PropPanel ) then return end
			self.PropPanel = vgui.Create("EditablePanel",pnlContent);
			self.PropPanel:Dock(FILL);
			self.PropPanel.Label = vgui.Create("DLabel",self.PropPanel);
			self.PropPanel.Label:SetText(Lib.Language.GetMessage("spawninfo_load"));
			self.PropPanel.Label:SetColor(Color(0,0,0,255));
			self.PropPanel.Label:SizeToContents();
			self.PropPanel.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,Color(255,255,255,255));
				self.Label:SetPos(w/2-10,h/2-10);
			end
			self.HTML = vgui.Create("DHTML",self.PropPanel);
			self.HTML:Dock(FILL);
			self.HTML:SetKeyBoardInputEnabled(true);
			self.HTML:SetMouseInputEnabled(true);
		end*/
		panel.DoClick = function( self )
			--self:DoPopulate()
			--self.HTML:OpenURL(v[2]);
			--pnlContent:SwitchPanel( self.PropPanel );
			gui.OpenURL(v[2]);
		end
	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end

end )

spawnmenu.AddCreationTab("EAP",function()
		local ctrl = vgui.Create( "SpawnmenuContentPanel" )
		ctrl:CallPopulateHook( "EAPTab" );
		return ctrl
	end, "img/eap_logo", 60 )
	
function EAPTool()
	spawnmenu.AddToolTab( "EAP", "EAP", "img/eap_logo" )
	spawnmenu.AddToolCategory("EAP","settings",Lib.Language.GetMessage("stool_settings"));
	spawnmenu.AddToolMenuOption("EAP","settings",Lib.Language.GetMessage("stool_settings")," "..Lib.Language.GetMessage("stool_settings"),"","",Lib.Settings.General);
end

-- Hook the Tab to the Spawn Menu
hook.Add( "AddToolMenuTabs", "EAPTool", EAPTool)

--##############
-- settings.lua
--##############
Lib.Settings = Lib.Settings or {}
/*
	Created by AlexALX (c) 2012
	Small settings tab
	For some functions what come from my addon
*/

function Lib.Settings.General(Panel)
	local LAYOUT = "Convars/Limits/Language";
	local GREEN = Color(0,255,0,255);
	local ORANGE = Color(255,128,0,255);
	local RED = Color(255,0,0,255);
	local DGREEN = Color(0,182,0,255);

	--General Settings
	if (LocalPlayer():IsAdmin()) then
		local convarsmenu = vgui.Create("DButton", Panel);
	    convarsmenu:SetText(Lib.Language.GetMessage("stargate_settings_01"));
	    convarsmenu:SetSize(150, 25);
	    convarsmenu:SetImage("icon16/wrench.png");
		convarsmenu.DoClick = function ( btn )
			RunConsoleCommand("eap_settings");
		end
		Panel:AddPanel(convarsmenu);
	end

	Panel:Help("");

	--Keyboard Settings
	local keymenu = vgui.Create("DButton", Panel);
	keymenu:SetText(Lib.Language.GetMessage("stargate_settings_02"));
	keymenu:SetSize(150, 25);
	keymenu:SetImage("icon16/keyboard.png");
	keymenu.DoClick = function ( btn )
		concommand.Run( LocalPlayer(), "keyboard_settings")
	end
	Panel:AddPanel(keymenu);

	Panel:Help("");

	--Lang Choice
	Panel:Help(Lib.Language.GetMessage("stargate_settings_03")):SetTextColor(DGREEN);
	local clientlang = vgui.Create("DMultiChoice",Panel);
	clientlang:SetSize(50,20);
	local lg = Lib.Language.GetLanguageName(Lib.Language.GetClientLanguage());
	if (lg!="Error") then
		clientlang:SetText(lg);
	else
		clientlang:SetText(Lib.Language.GetClientLanguage());
	end
	clientlang.TextEntry:SetTooltip(Lib.Language.GetMessage("stargate_settings_04"));
	clientlang.TextEntry.OnTextChanged = function(TextEntry)
		local pos = TextEntry:GetCaretPos();
		local text = TextEntry:GetValue();
		local len = text:len();
		local letters = text:lower():gsub("[^a-z-]",""); -- Lower, remove invalid chars and split!
		TextEntry:SetText(letters);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-letters:len()),0,text:len())); -- Reset the caretpos!
		timer.Remove("EAP.lang_check");
		timer.Create("EAP.lang_check",0.4,1,function()
			local lg = Lib.Language.GetLanguageName(letters);
			if (IsValid(TextEntry) and lg!="Error") then
				TextEntry:SetText(lg);
				TextEntry:SetCaretPos(lg:len()); -- Reset the caretpos!
			end
			if (letters!="") then Lib.Language.SetClientLanguage(letters); end
		end)
	end
	clientlang.OnSelect = function(panel,index,value)
		if (value!="") then
			local lg = Lib.Language.GetLanguageFromName(value);
			Lib.Language.SetClientLanguage(lg);
		end
	end
	-- add exists languages
	local _,langs = file.Find("lua/data/language_data/*","GAME");
	local en_count,en_msgs = Lib.Language.CountMessagesInLanguage("en",true);
	local lng_arr = {}
	for i,lang in pairs(langs) do
		local count,msgs = Lib.Language.CountMessagesInLanguage(lang,true);
		if (lang!="en"/* and (not msgs["global_lang_similar"] or msgs["global_lang_similar"]=="false")*/) then
			for k,v in pairs(msgs) do
				if (not en_msgs[k]/* or v==en_msgs[k]*/) then count = count-1; end -- stop cheating!
			end
		end
		count = math.Round(count*100/en_count);
		lng_arr[lang] = {Lib.Language.GetLanguageName(lang),count};
		clientlang:AddChoice(Lib.Language.GetLanguageName(lang));
	end
	Panel:AddPanel(clientlang);
	Panel:Help(Lib.Language.GetMessage("stargate_settings_04"));
	Panel:Help(Lib.Language.GetMessage("stargate_settings_05")):SetTextColor(DGREEN);
	local VGUI = vgui.Create("DPanel");
	VGUI:SetBackgroundColor(Color(120,120,120));
	local i = 5;
	for k,v in SortedPairs(lng_arr) do
		local count = v[2];
		local col = HSVToColor((count/100)*120,1,0.9);
		local p = vgui.Create("DLabel",VGUI);
		p:SetPos(10,i);
		p:SetText(v[1].." ("..k..") - "..count.."%");
		p:SetSize(150,15);
		p:SetAutoStretchVertical(true);
		p:SetTextColor(col);
		p:SetTall(10);
		p:DockMargin(0,0,0,0);
		i = i+15;
	end
	VGUI:SetSize(150,i+5);
	Panel:AddPanel(VGUI);
	Panel:Help(Lib.Language.GetMessage("stargate_settings_06"));
	Panel:Help("");

	--Client Settings
	local client = vgui.Create("DButton", Panel);
	client:SetText(Lib.Language.GetMessage("stargate_settings_08"));
	client:SetSize(150, 25);
	client:SetImage("icon16/wrench_orange.png");
	client.DoClick = function ( btn )
		concommand.Run( LocalPlayer(), "client_settings")
	end
	Panel:AddPanel(client);

	Panel:Help("");

	--Forum
	local forum = vgui.Create("DButton", Panel);
	forum:SetText(Lib.Language.GetMessage("stargate_settings_09"));
	forum:SetSize(150, 25);
	forum:SetImage("icon16/comments.png");
	forum.DoClick = function(btn)
		local help = vgui.Create("SHTMLHelper");
		help:SetURL(Lib.HTTP.WIKI);
		help:SetText(Lib.Language.GetMessage("stargate_settings_09"));
		help:SetVisible(true);
	end
	Panel:AddPanel(forum);

	Panel:Help("");

	--Credits
	Panel:Help(Lib.Language.GetMessage("stargate_settings_07"));
end