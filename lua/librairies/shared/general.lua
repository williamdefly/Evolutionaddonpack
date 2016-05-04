--[[
	A global library with  bunch of usefull
	functions often used in entities on both sides
	Copyright (C) 2011 Madman07
]]--

MsgN("librairies/shared/general.lua")

Lib = Lib or {}
Lib.Hook = Lib.Hook or {}

--###########
-- ramps.lua
--###########

/*
	##################################
	Ramp Offset/List file, idea by AlexALX
	##################################
	Also you can write stargate_reload (not lua_reloadents) to update ramp offsets (much faster).
	But for reload stools you still need to write restart.
	All models paths must be in LOWER case.
*/

-- ################### For stools ###################
-- For reloading the stools require writen restart.
-- All models paths must be in LOWER case.

Lib.Ramps = {} -- Remove old array if reload, idk if this needed, just added to be sure

-- For anim ramps stool
Lib.Ramps.AnimDefault = {"models/markjaw/2010_ramp.mdl","future_ramp",Vector(0,0,145)};
Lib.Ramps.Anim = {
	["models/markjaw/2010_ramp.mdl"] = {"futureramp",Vector(0,0,145)},
	["models/markjaw/sgu_ramp.mdl"] = {"sguramp",Vector(0,0,150)},
	["models/iziraider/sguramp/sgu_ramp.mdl"] = {"sguramp",Vector(0,0,41)},
	["models/iziraider/ramp2/ramp2.mdl"] = {"ramps2",Vector(0,0,-5)},
	["models/zup/ramps/sgc_ramp.mdl"] = {"sgcramp",Vector(0,0,148)},
	["models/zsdaniel/icarus_ramp/icarus_ramp.mdl"] = {"icarusramp",Vector(0,0,41)},
	["models/boba_fett/ramps/ramp8.mdl"] = {"goauldramp"},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp.mdl"] = {"sguramp"},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_old.mdl"] = {"sguramp"},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_small.mdl"] = {"sguramp"},
}

-- For non-anim ramps stool
Lib.Ramps.NonAnimDefault = "models/iziraider/ramp1/ramp1.mdl";
Lib.Ramps.NonAnim = {
	["models/iziraider/ramp1/ramp1.mdl"] = {},
	["models/iziraider/ramp2/ramp2.mdl"] = {},
	["models/iziraider/ramp3/ramp3.mdl"] = {Vector(0,0,0),Angle(0,270,0)},
	["models/iziraider/ramp4/ramp4.mdl"] = {},
	["models/iziraider/sguramp/sgu_ramp.mdl"] = {},
	["models/iziraider/sga_ramp/sga_ramp.mdl"] = {},
	["models/zup/ramps/sgc_ramp.mdl"] = {},
	["models/zup/ramps/brick_01.mdl"] = {},
	["models/markjaw/sgu_ramp.mdl"] = {},
	["models/zsdaniel/ramp/ramp.mdl"] = {},
	["models/zsdaniel/icarus_ramp/icarus_ramp.mdl"] = {},
	["models/madman07/ori_ramp/ori_ramp.mdl"] = {},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp.mdl"] = {},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_old.mdl"] = {},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_small.mdl"] = {},
	["models/boba_fett/ramps/moebius_ramp/moebius_ramp.mdl"] = {},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {},
	["models/boba_fett/ramps/ramp.mdl"] = {},
	["models/boba_fett/ramps/ramp2.mdl"] = {},
	["models/boba_fett/ramps/ramp3.mdl"] = {},
	["models/boba_fett/ramps/ramp4.mdl"] = {},
	["models/boba_fett/ramps/ramp5.mdl"] = {},
	["models/boba_fett/ramps/ramp6.mdl"] = {},
	["models/boba_fett/ramps/ramp7.mdl"] = {},
	["models/boba_fett/ramps/ramp9.mdl"] = {},
	["models/boba_fett/ramps/ramp10.mdl"] = {},
	["models/boba_fett/ramps/ramp11.mdl"] = {},
	["models/boba_fett/ramps/ramp12.mdl"] = {},
	["models/markjaw/midway/midway.mdl"] = {},
}

-- For ring ramps stool
Lib.Ramps.RingDefault = "models/madman07/spawn_ramp/spawn_ring.mdl";
Lib.Ramps.Ring = {
	["models/madman07/spawn_ramp/spawn_ring.mdl"] = {},
	["models/boba_fett/rings/ring_platform.mdl"] = {},
	["models/boba_fett/ramps/ring_ramps/ring_ramp.mdl"] = {},
	["models/boba_fett/ramps/ring_ramps/ring_ramp2.mdl"] = {},
	["models/boba_fett/ramps/ring_ramps/ring_ramp3.mdl"] = {},
}

-- ################### Offsets ###################
-- You can write stargate_reload (not lua_reloadents) to update ramp offsets (much faster).
-- All model paths must be in LOWER case.

-- Offsets for "InRamp"-Spawning

Lib.RampOffset = {} -- Remove old array if reload, idk if this needed, just added to be sure

-- For StarGates
Lib.RampOffset.Gates = {
	["models/zup/ramps/sgc_ramp.mdl"] = {Vector(0,0,0)},
	["models/zup/ramps/brick_01.mdl"] = {Vector(0,0,-10)},
	["models/iziraider/sguramp/sgu_ramp.mdl"] = {Vector(-105,0,96)},
	["models/iziraider/ramp1/ramp1.mdl"] = {Vector(-240,0,128)},
	["models/iziraider/ramp2/ramp2.mdl"] = {Vector(-270,0,138)},
	["models/iziraider/ramp3/ramp3.mdl"] = {Vector(0,-120,124.5),Angle(0,90,0)},
	["models/iziraider/ramp4/ramp4.mdl"] = {Vector(-270,0,171)},
	["models/iziraider/sga_ramp/sga_ramp.mdl"] = {Vector(-234,0,87)},
	["models/madman07/ori_ramp/ori_ramp.mdl"] = {Vector(-338,0,143)},
	["models/markjaw/2010_ramp.mdl"] = {Vector(0,0,0)},
	["models/markjaw/sgu_ramp.mdl"] = {Vector(-2,0,-1)},
	["models/zsdaniel/ramp/ramp.mdl"] = {Vector(0,0,140)},
	["models/zsdaniel/icarus_ramp/icarus_ramp.mdl"] = {Vector(-192,0,97.5)},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp.mdl"] = {Vector(-109,0,135)},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_old.mdl"] = {Vector(-109,0,135)},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_small.mdl"] = {Vector(-92.2,0,142)},
	["models/boba_fett/ramps/moebius_ramp/moebius_ramp.mdl"] = {Vector(0,0,149)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(-400,0,195)},
	["models/boba_fett/catwalk_build/gate_platform.mdl"] = {Vector(0,0,-2.5),Angle(-90,0,0)},
	["models/boba_fett/ramps/ramp.mdl"] = {Vector(-85,0,159)},
	["models/boba_fett/ramps/ramp2.mdl"] = {Vector(-65,0,145)},
	["models/boba_fett/ramps/ramp3.mdl"] = {Vector(-67,0,225)},
	["models/boba_fett/ramps/ramp4.mdl"] = {Vector(0,0,90)},
	["models/boba_fett/ramps/ramp5.mdl"] = {Vector(0,0,219)},
	["models/boba_fett/ramps/ramp6.mdl"] = {Vector(-38,0,159)},
	["models/boba_fett/ramps/ramp7.mdl"] = {Vector(0,0,110)},
	["models/boba_fett/ramps/ramp8.mdl"] = {Vector(0,0,146)},
	["models/boba_fett/ramps/ramp9.mdl"] = {Vector(-198,0,142)},
	["models/boba_fett/ramps/ramp10.mdl"] = {Vector(-184,0,133)},
	["models/boba_fett/ramps/ramp11.mdl"] = {Vector(-180,0,126)},
	["models/boba_fett/ramps/ramp12.mdl"] = {Vector(-50,0,137)},
	["models/markjaw/midway/midway.mdl"] = {Vector(675,0,0),Angle(0,-180,0),Vector(-672,0,0)}
}

-- For DHD's
Lib.RampOffset.DHD = {
	["models/iziraider/ramp1/ramp1.mdl"] = {Vector(300,0,5),Angle(15,0,0)},
	["models/iziraider/ramp2/ramp2.mdl"] = {Vector(318,0,30),Angle(15,180,0)},
	["models/iziraider/ramp3/ramp3.mdl"] = {Vector(0,165,13),Angle(0,90,0)}, --,Angle(15,90,0)},
	["models/iziraider/ramp4/ramp4.mdl"] = {Vector(95,5,11),Angle(15,0,0)},
	["models/iziraider/sga_ramp/sga_ramp.mdl"] = {Vector(-160,-163,-7),Angle(15,35,0)},
	["models/madman07/ori_ramp/ori_ramp.mdl"] = {Vector(100,0,39),Angle(15,0,0)},
	["models/boba_fett/ramps/ramp10.mdl"] = {Vector(-10,-110,56),Angle(15,35,0)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(-290,-140,97),Angle(15,35,0)},
}

-- For Concept DHD's
Lib.RampOffset.DHDC = {
	["models/boba_fett/ramps/ramp9.mdl"] = {Vector(20,0,20)},
}

-- For Rings
Lib.RampOffset.Ring = {
	["models/madman07/spawn_ramp/spawn_ring.mdl"] = {Vector(8,0,12)},
	["models/boba_fett/rings/ring_platform.mdl"] = {Vector(0,0,20)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp.mdl"] = {Vector(0,0,23)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp2.mdl"] = {Vector(0,0,20)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp3.mdl"] = {Vector(0,0,14)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(270,0,112.5)},
	["models/boba_fett/catwalk_build/hiding_circle_rings.mdl"] = {Vector(0,0,0)},
}

-- For Ring Panels
Lib.RampOffset.RingP = {
	["models/madman07/spawn_ramp/spawn_ring.mdl"] = {Vector(-98,0,57.5)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp.mdl"] = {Vector(0,-96.5,69),Angle(0,90,0)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp2.mdl"] = {Vector(-98.5,0,58)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp3.mdl"] = {Vector(-88.5,0,47)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(369.5,0,162.5),Angle(0,180,0)},
	["models/boba_fett/catwalk_build/hiding_circle_rings.mdl"] = {Vector(88,0,21),Angle(0,180,0)},
}

--#########################################
--						String Functions
--#########################################

Lib.String = {};
--################# Explodes a string and trims the results @aVoN
function Lib.String.TrimExplode(s,sep)
	if(sep and s:find(sep)) then
		if(type(s) == "string") then
			s=s:gsub("^[%s]+","");
		end
		local r = string.Explode(sep,s);
		for k,v in pairs(r) do
			if(type(v) == "string") then
				r[k] = v:Trim();
			end
		end
		return r;
	else
		return {s};
	end
end
string.TrimExplode = Lib.String.TrimExplode;

function Lib.GetEntityCentre(entity)
   if(entity == nil or not IsValid(entity)) then
      Msg("Entity passed to GetEntityCentre(entity) cannot be nil.\n")
      return
   end

   return entity:LocalToWorld(entity:OBBCenter())
end

function Lib.FindEntInsideSphere(pos, rad, class) -- Made my own because the other one can't be called client side :(
	local ent = {}
	for _,v in pairs(ents.FindByClass(class)) do
		local dis = v:GetPos():Distance(pos)
		if dis < rad then
			table.insert(ent, v)
		end
	end
	return ent
end

function Lib.LOSVector(startpos, endpos, filter, radius)
	if (not startpos or not endpos) then return false end
	local tracedata = {
		start = startpos,
		endpos = endpos,
		filter = filter,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER + CONTENTS_WINDOW//clever tracer, we can see trough glass
	}
	local trace = util.TraceLine(tracedata);

	local x = math.abs(endpos.x-trace.HitPos.x) < radius; // way faster than P1:Distance(P2)  (no roots, etc)
	local y = math.abs(endpos.y-trace.HitPos.y) < radius;
	local z = math.abs(endpos.z-trace.HitPos.z) < radius;

	return x and y and z;
end

--Stargates 

function Lib.IsIrisClosed(gate)
   return gate.irisclosed == true || (gate.Iris ~= nil && gate.Iris.IsActivated == true)
end

--#########################################
--						Config Part
--#########################################
Lib.CFG = Lib.CFG or {};
--################# Gets a value from the config. When none exists, the default value will be returend @aVoN
function Lib.CFG:Get(node,key,default)
	if(Lib.CFG[node] and Lib.CFG[node][key] ~= nil) then
		return Lib.CFG[node][key];
	end
	return default;
end

if(CLIENT)then
	--################# Getting synced data from the server @aVoN
	function Lib.CFG.GetSYNC(len)
		local name = net.ReadString();
		-- fix for reload
		if (name=="_CFG_RELOAD_") then
			if (Lib.CFG.Get and type(Lib.CFG.Get)=="function") then
				local copy = Lib.CFG.Get;
				Lib.CFG = {};
				Lib.CFG.Get = copy;
			end
			return
		end
		Lib.CFG[name] = {};
		local count = net.ReadUInt(8);
		for i=1,count do
			local k = net.ReadString();
			local t = net.ReadUInt(8); -- What type are we?
			if(t == 0) then
				Lib.CFG[name][k] = util.tobool(net.ReadBit());
			elseif(t == 1) then
				Lib.CFG[name][k] = net.ReadString();
			elseif(t == 2) then
				Lib.CFG[name][k] = net.ReadDouble();
			elseif(t == 3) then
				Lib.CFG[name][k] = net.ReadInt(8);
			elseif(t == 4) then
				Lib.CFG[name][k] = net.ReadInt(16);
			elseif(t == 5) then
				Lib.CFG[name][k] = net.ReadInt(32);
			end
		end
	end
	net.Receive("EAP_CFG",Lib.CFG.GetSYNC);
end