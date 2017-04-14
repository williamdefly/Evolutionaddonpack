ENT.Type = "anim";
ENT.Base = "sg_base";
ENT.PrintName = "Stargate (Atlantis)";
ENT.Author = "aVoN, Madman07, Llapp, Rafael De Jongh, AlexALX";
ENT.Category = ""
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Atlantis"

ENT.EventHorizonData = {
	OpeningDelay = 0.9,
	OpenTime = 2.2,
	NNFix = 0,
	Type = "atlantis",
}

Lib.RegisterEventHorizon("atlantis",{
	ID=4,
	Name=Lib.Language.GetMessage("stargate_c_tool_21_atl"),
	Material="sgorlin/effect_01.vmt",
	UnstableMaterial="sgorlin/effect_shock.vmt",
	LightColor={
		r = Vector(20,40),
		g = Vector(60,80),
		b = Vector(150,230),
		sync = false, -- sync random (for white), will be used only first value from this table (r)
	},
	Color=Color(255,255,255),
})

-- this names should be unique for each option!
-- if you using this code as base for another gate please change this names to new one!
-- also you need to change class name in this checks
properties.Add( "Lib.Atl.RingLight.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_08"),
	Order		=	-120,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_atlantis" || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("ActRingL",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Turn on ring light",2);
					end

});

properties.Add( "Lib.Atl.RingLight.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_08d"),
	Order		=	-120,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_atlantis" || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("ActRingL",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Turn on ring light",0);
					end

});

properties.Add( "Lib.Atl.AtlType.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_19"),
	Order		=	-125,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_atlantis" || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("AtlType",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Atlantis Type",1);
					end

});

properties.Add( "Lib.Atl.AtlType.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_19d"),
	Order		=	-125,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_atlantis" || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("AtlType",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Atlantis Type",0);
					end

});

properties.Add( "Lib.Atl.AtlType.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_22"),
	Order		=	-130,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_atlantis" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("FasterDial",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Alternative Slow Dial",1);
					end

});

properties.Add( "Lib.Atl.AtlType.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_22d"),
	Order		=	-130,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_atlantis" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("FasterDial",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Alternative Slow Dial",0);
					end

});