if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type 			= "anim"

ENT.PrintName	= "Ringtransporter"
ENT.Author	= "Catdaemon"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= "Place where desired, USE to set its address."

ENT.Category		= "Stargate"

ENT.Spawnable	= false
ENT.AdminSpawnable = false

ENT.IsRings = true;

properties.Add( "Lib.Ring.Unusable.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_04"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("Busy",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "ringmodify", ent ) ) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent.Busy = true
						ent:SetNWBool("Busy",true);
					end

});

properties.Add( "Lib.Unusable.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_04d"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("Busy",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "ringmodify", ent ) ) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent.Busy = false
						ent:SetNWBool("Busy",false);
					end

});

properties.Add( "Lib.Ring.DialClosest",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_05"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_go.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("Busy",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "ringmodify", ent ) ) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:Dial("");
					end

});

properties.Add( "Lib.Ring.DialMenu",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_06"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("Busy",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "ringmodify", ent ) ) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						umsg.Start("RingTransporterShowWindowCap", player)
						umsg.End()
						player.RingDialEnt = ent;
					end

});