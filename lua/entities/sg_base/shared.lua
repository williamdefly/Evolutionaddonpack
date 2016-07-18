/*
	Stargate SENT for GarrysMod10
	Copyright (C) 2007  aVoN

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
if (Lib!=nil and Lib.Wiremod!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.LifeSupport!=nil) then Lib.LifeSupport(ENT); end
--################# HEADER #################
ENT.Type = "anim";
ENT.Author = "aVoN, AlexALX";
ENT.PrintName = "stargate_base_entity";
ENT.Category = "";

ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.WireDebugName = "Stargate";
ENT.IsStargate = true;
ENT.IsGroupStargate = true;

--################# SENT CODE ###############
--################# Defines
-- Stores the chevron positions for the dyn-lights
ENT.chev_pos = {
	Vector(2.1883,56.8480,117.1900), -- Chevron 1
	Vector(2.1906,84.8159,68.0387), -- 2
	Vector(2.1935,74.0602,7.2254), -- 3
	Vector(2.1952,-75.2123,8.8901), -- 4
	Vector(2.1949,-85.7819,66.1261), -- 5
	Vector(2.1921,-56.6188,118.2584), -- 6
	Vector(2.1837,-0.3143,138.8647), -- 7 (normal travel)
	Vector(2.1905,27.5605,-30.0398), -- 8 (intergalactic travel - later for server-to-server travel)
	Vector(2.1964,-32.0372,-28.7796), -- 9 The chevron 9, nobody knows, for what reason it is good for. Alternative universes?
}

ENT.GalaxyConsumption = 4;
ENT.GalaxyAdd = 50000;
ENT.SGUConsumption = 40;
ENT.SGUAdd = 800000;
ENT.ChevConsumption = 10;
ENT.ChevAdd = 2000;

properties.Add( "Lib.AutoClose.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_03d"),
	Order		=	-109,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("DisAutoClose",false)) then return false end
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

						ent.DisAutoClose = true
						ent:SetNWBool("DisAutoClose",true);
					end

});

properties.Add( "Lib.AutoClose.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_03"),
	Order		=	-109,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("DisAutoClose",false)) then return false end
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

						ent.DisAutoClose = false
						ent:SetNWBool("DisAutoClose",false);
					end

});

properties.Add( "Lib.DisableMenu.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_07d"),
	Order		=	-108,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate and !ent.IsDHD || ent.IsStargateOrlin || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("DisMenu",false)) then return false end
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

						ent.DisMenu = true
						ent:SetNWBool("DisMenu",true);
					end

});

properties.Add( "Lib.DisableMenu.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_07"),
	Order		=	-108,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate and !ent.IsDHD || ent.IsStargateOrlin || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("DisMenu",false)) then return false end
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

						ent.DisMenu = false
						ent:SetNWBool("DisMenu",false);
					end

});

properties.Add( "Lib.ChevronLight.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_09"),
	Order		=	-111,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent.IsSupergate || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("ActChevronsL",false)) then return false end
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

						if (ent:GetClass()=="sg_universe") then
 							ent:TriggerInput("Activate Chevrons",1);
						else
							ent:TriggerInput("Activate chevron numbers","111111111");
						end
					end

});

properties.Add( "Lib.ChevronLight.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_09d"),
	Order		=	-111,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent.IsSupergate || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("ActChevronsL",false)) then return false end
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

						if (ent:GetClass()=="sg_universe") then
 							ent:TriggerInput("Activate Chevrons",0);
						else
							ent:TriggerInput("Activate chevron numbers","");
						end
					end

});

properties.Add( "Lib.RingRotate.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_11"),
	Order		=	-110,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"sg_movie","sg_sg1","sg_infinity","sg_universe"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("ActRotRingL",false)) then return false end
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

						ent:TriggerInput("Rotate Ring",1);
					end

});

properties.Add( "Lib.RingRotate.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_11d"),
	Order		=	-110,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"sg_movie","sg_sg1","sg_infinity","sg_universe"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("ActRotRingL",false)) then return false end
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

						ent:TriggerInput("Rotate Ring",0);
					end

});

properties.Add( "Lib.InfinityEH.On",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_17"),
	Order		=	-110,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						local vg = {"sg_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("EAPGateSpawnerProtected",false) || ent:GetNWBool("ActInf_SG1_EH",false)) then return false end
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

						ent:TriggerInput("SG1 Event Horizon",1);
					end

});

properties.Add( "Lib.InfinityEH.Off",
{
	MenuLabel	=	Lib.Language.GetMessage("stargate_c_tool_17d"),
	Order		=	-110,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"sg_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("EAPGateSpawnerProtected",false) || !ent:GetNWBool("ActInf_SG1_EH",false)) then return false end
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

						ent:TriggerInput("SG1 Event Horizon",0);
					end

});