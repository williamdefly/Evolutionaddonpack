if(SERVER)then
	return false
end

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
			if not v.AdminShowOnly then
				v.Category = v.Category or "Other"
				v.__ClassName = k;
				Categorised[ v.Category ] = Categorised[ v.Category ] or {}
				table.insert( Categorised[ v.Category ], v )
			else
				if LocalPlayer():IsAdmin() then
					v.Category = v.Category or "Other"
					v.__ClassName = k;
					Categorised[ v.Category ] = Categorised[ v.Category ] or {}
					table.insert( Categorised[ v.Category ], v )
				end
			end
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
		local node = tree:AddNode( Lib.Language.GetMessage("cat_weapons"), "icon16/gun.png" );
				
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

	local node = tree:AddNode( "Props", "icon16/folder.png", true );

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
	spawnmenu.AddToolCategory("EAP","ships",Lib.Language.GetMessage("cat_ship"));
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_alkesh"),"Alkesh Settings","","",Lib.Settings.Alkesh)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_aurora"),"Aurora Settings","","",Lib.Settings.Aurora)
	--spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_anubisms"),"Anubis Mothership Settings","","",Lib.Settings.AnubisMotherShip)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_destiny"),"Destiny Settings","","",Lib.Settings.Destiny)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_hatak"),"Hatak Settings","","",Lib.Settings.Hatak)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_oneill"),"Oneill Settings","","",Lib.Settings.Oneill)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_orims"),"Ori Mothership Settings","","",Lib.Settings.OriMs)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_wraithcruiser"),"Wraith Cruiser Settings","","",Lib.Settings.WraithCruiser)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_gateseeder"),"GateSeeder Settings","","",Lib.Settings.Gateseeder)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_prometheus"),"Promethee Settings","","",Lib.Settings.Promethee)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_replicator"),"Replicator Settings","","",Lib.Settings.Replicator)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_daedalus"),"Deadalus Settings","","",Lib.Settings.Daedalus)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_dart"),"Dart Settings","","",Lib.Settings.WraithDart)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_gateglider"),"Gate Glider Settings","","",Lib.Settings.GateGlider)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_f302"),"F-302 Settings","","",Lib.Settings.F302)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_jumper"),"Jumper Settings","","",Lib.Settings.Jumper)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_shuttle"),"Destiny Shuttle Settings","","",Lib.Settings.Shuttle)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_deathglider"),"DeathGlider Settings","","",Lib.Settings.DeathGlider)
	spawnmenu.AddToolMenuOption("EAP","ships",Lib.Language.GetMessage("ent_ship_teltak"),"TelTak Settings","","",Lib.Settings.Teltak)
end

-- Hook the Tab to the Spawn Menu
hook.Add( "AddToolMenuTabs", "EAPTool", EAPTool)