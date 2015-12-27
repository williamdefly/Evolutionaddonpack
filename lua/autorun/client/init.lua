EAP = {};
EAP.KeyBoard = EAP.KeyBoard or {}
EAP.SpawnList = {};

EAP.SpawnList.Props = {
"models/abydos/claypot/claypot_01.mdl",
"models/abydos/claypot/claypot_02.mdl",
"models/abydos/claypot/claypot_03.mdl",
"models/abydos/hatakcontainer/hatakcontainer.mdl",
"models/abydos/raeye/raeye.mdl",
"models/abydos/sarcophagus/sarcophagus.mdl",
"models/props_lodka/ori_bucher.mdl",
"models/ship/destiny.mdl",
"models/ship/oneil.mdl",
"models/ship/wraith.mdl",
"models/atero.mdl",
"models/skybox/mship2.mdl",
"models/ship/ori.mdl",
"models/ship/alkesh.mdl",
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
			
		if ( !weapon.Spawnable ) then continue end

		Categorised[ weapon.Category ] = Categorised[ weapon.Category ] or {}
		table.insert( Categorised[ weapon.Category ], weapon )
		
	end

	Weapons = nil

	-- Loop through each category
	for CategoryName, v in SortedPairs( Categorised ) do
	
		if(CategoryName=="EAP") then
		
		-- Add a node to the tree
		local node = tree:AddNode( "Armes", "icon16/gun.png" );
				
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
	spawnmenu.AddToolCategory("EAP","ships","Vaisseaux");
	spawnmenu.AddToolMenuOption("EAP","ships","Alkesh","Alkesh Settings","","",StarGate.AlkeshSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","Anubis","Anubis Mothership Settings","","",StarGate.AnubisMotherShipSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","Destiny","Destiny Settings","","",StarGate.DestinySettings)
	spawnmenu.AddToolMenuOption("EAP","ships","Hatak","Hatak Settings","","",StarGate.HatakSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","Oneill","Oneill Settings","","",StarGate.OneillSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","Ori","Ori Mothership Settings","","",StarGate.OriSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","WraithCruiser","Wraith Cruiser Settings","","",StarGate.WraithCruiserSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","Gateseeder","Poseur de portes Settings","","",StarGate.GateseederSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","Navigator","Navigateur Settings","","",StarGate.NavigatorSettings)
	spawnmenu.AddToolMenuOption("EAP","ships","daedalus","Deadalus Settings","","",StarGate.daedalusSettings)
end

-- Hook the Tab to the Spawn Menu
hook.Add( "AddToolMenuTabs", "EAPTool", EAPTool )