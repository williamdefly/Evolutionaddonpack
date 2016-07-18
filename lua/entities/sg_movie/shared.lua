ENT.Type = "anim"
ENT.Base = "sg_base"
ENT.PrintName = "Stargate (Movie)"
ENT.Author = "aVoN, Madman07, Llapp, Boba Fett, AlexALX"
ENT.Category = ""
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Movie"

function ENT:GetRingAng()
	if not IsValid(self.EntRing) then self.EntRing=self:GetNWEntity("EntRing") if not IsValid(self.EntRing) then return end end   -- Use this trick beacause NWVars hooks not works yet...
	local angle = tonumber(math.NormalizeAngle(self.EntRing:GetLocalAngles().r));
	return (angle<0) and angle+360 or angle
end

properties.Add( "Lib.MChevL.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_16"),
	Order		=	-145,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_movie" || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("ActMChevL",false)) then return false end
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

						ent:TriggerInput("Chevron Light",1);
					end

});

properties.Add( "Lib.MChevL.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_16d"),
	Order		=	-145,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_movie" || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("ActMChevL",false)) then return false end
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

						ent:TriggerInput("Chevron Light",0);
					end

});

properties.Add( "Lib.MCl.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_15"),
	Order		=	-144,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_movie" || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("ActMCl",false)) then return false end
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

						ent:TriggerInput("Classic Mode",1);
					end

});

properties.Add( "Lib.MCl.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_15d"),
	Order		=	-144,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"sg_movie","sg_sg1","sg_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="sg_movie" || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("ActMCl",false)) then return false end
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

						ent:TriggerInput("Classic Mode",0);
					end

});