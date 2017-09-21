--[[
	A global library with  bunch of usefull
	functions often used in entities on both sides
	Copyright (C) 2011 Madman07
]]--

MsgN("eap_librairies/shared/general.lua")

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

function Lib.CallReload(p) -- Override is called in sg_base/init.lua if someone calls lua_reloadents
   if(not IsValid(p) or game.SinglePlayer() or p:IsAdmin()) then
      EAP.Init();
      for _,v in pairs(player.GetAll()) do
         v:SendLua("EAP.Init()");
      end
   else
      p:SendLua("EAP.Init()");
      timer.Simple(0,function() Lib.Hook.PlayerInitialSpawn(p) end); -- fix for reload cfg
   end
end

if SERVER then
   concommand.Add("eap_reload",Lib.CallReload);
end

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

function Lib.IsStargateOpen(gate)
   return gate.open == true || gate.IsOpen == true
end

function Lib.IsStargateOutbound(gate)
   return Lib.IsStargateOpen(gate) == true && (gate.outbound == true || gate.Outbound == true)
end

function Lib.GetRemoteStargate(localGate)
   return localGate.other_gate || localGate.Target
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
Lib.EventHorizonTypes = Lib.EventHorizonTypes or {}
function Lib.RegisterEventHorizon(type,data)
   Lib.EventHorizonTypes[type] = data
end

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

-- Jams the given gate, preventing it from closing the current connection
-- Also overrides USE key behaviour on the gate so that this key instead toggles the iris
-- Returns: whether the gate could be jammed
function Lib.JamRemoteGate(gate)
   if(gate == nil || gate:IsValid() == false) then
      Msg("The stargate passed to JamRemoteGate(gate) is not valid.\n")
      return false
   elseif(Lib.IsStargateOpen(gate) == false ||
          Lib.IsStargateOutbound(gate)) then
      Msg("The stargate passed to JamRemoteGate(gate) does not have an outbound wormhole open.\n")
      return false
   elseif(gate.jammed == true) then
      return true
   end

   function DummyFunction(...)
      return false
   end

   -- Override remote gate's functions to prevent shutdown

   gate.backups = {}

   gate.backups.AcceptInput = gate.AcceptInput
   gate.AcceptInput = DummyFunction

   -- Do not simply disable pressing the 'use' key on a gate - instead make this toggle the iris (the one function of the remote gate that should not be disabled)
   /*gate.backups.Use = gate.Use
   gate.Use = function()
      if(gate.Iris) then -- If new iris exists on gate
         gate.Iris:Toggle()
      elseif(gate.irisclosed == true) then -- If old gate and iris is closed
         gate:OpenIris(true)
      elseif(gate.irisclosed == false) then -- If old gate and iris is open
         gate:OpenIris(false)
      end
   end */

   gate.backups.EmergencyShutdown = gate.EmergencyShutdown
   gate.EmergencyShutdown = DummyFunction

   gate.backups.DeactivateStargate = gate.DeactivateStargate
   gate.DeactivateStargate = DummyFunction

   gate.backups.Close = gate.Close
   gate.Close = DummyFunction

   gate.backups.ActivateStargate = gate.ActivateStargate
   gate.ActivateStargate = DummyFunction

   gate.backups.Open = gate.Open
   gate.Open = DummyFunction

   gate.backups.auto_close = gate.auto_close
   gate.auto_close = false

   gate.jammed = true

   local localGate = Lib.GetRemoteStargate(gate)

   localGate.backups = {}

   -- Override local gate's functions to un-jam the remote gate when the connection is closed locally

   localGate.backups.AcceptInput = localGate.AcceptInput
   localGate.AcceptInput = function(name, activator, caller)
      if(activator == "Use" || name == nil) then
         return
      end

      Lib.UnJamGate(localGate)
      localGate:AcceptInput(name, activator, caller)
   end

   -- For compatibility with UnJamGate
   --localGate.backups.Use = localGate.Use

   localGate.backups.EmergencyShutdown = localGate.EmergencyShutdown
   localGate.EmergencyShutdown = DummyFunction

   localGate.backups.DeactivateStargate = localGate.DeactivateStargate
   localGate.DeactivateStargate = DummyFunction

   localGate.backups.ActivateStargate = localGate.ActivateStargate
   localGate.ActivateStargate = function(inbound, fast)
      Lib.UnJamGate(Lib.GetRemoteStargate(localGate))
      localGate:ActivateStargate(inbound, fast)
   end

   localGate.backups.Open = localGate.Open
   localGate.Open = DummyFunction

   localGate.backups.Close = localGate.Close
   localGate.Close = DummyFunction

   localGate.backups.auto_close = localGate.auto_close
   localGate.auto_close = false

   localGate.jammed = true

   return true
end

function Lib.UnJamGate(gate)
   if(gate == nil) then
      Msg("The stargate passed to UnJamGate(gate) cannot be nil.\n")
      return false
   elseif(gate:IsValid() == false) then
      return false
   elseif(gate.jammed ~= true || gate.backups == nil) then
      return true
   end

   gate.AcceptInput = gate.backups.AcceptInput
   --gate.Use = gate.backups.Use -- create crash now when activate gate after UnJamGate, havn't ideas why
   gate.EmergencyShutdown = gate.backups.EmergencyShutdown
   gate.DeactivateStargate = gate.backups.DeactivateStargate
   gate.Close = gate.backups.Close
   gate.ActivateStargate = gate.backups.ActivateStargate
   gate.Open = gate.backups.Open
   gate.auto_close = gate.backups.auto_close

   gate.jammed = false

   return Lib.UnJamGate(Lib.GetRemoteStargate(gate))
end


function Lib.JamDHD(dhd, duration)
   if(dhd == nil) then
      Msg("The DHD passed to JamDHD(dhd) cannot be nil.\n")
      return false
   elseif(dhd:IsValid() == false) then
      return false
   end

   if(dhd.SetBusy) then
      dhd:SetBusy(duration)
   else
      dhd.busy = true
   end

   return true
end

function Lib.UnJamDHD(dhd)
   if(dhd == nil) then
      Msg("The DHD passed to UnJamDHD(dhd) cannot be nil.\n")
      return false
   elseif(dhd:IsValid() == false) then
      return false
   end

   dhd.busy = false
   return true
end

function Lib.GetGateMarker(gate)
   if(gate == nil) then
      Msg("Gate passed to GetGateMarker(gate) cannot be nil.\n")
      return
   end

   if(gate.centreMarker == nil) then
      gate.centreMarker = ents.Create("info_target")
      gate.centreMarker:SetPos(Lib.GetEntityCentre(gate))
      gate.centreMarker:SetName("GateMarker"..gate:EntIndex())
      gate.centreMarker:Spawn()
      gate.centreMarker:SetParent(gate)
   end

   return gate.centreMarker
end

function Lib.GetStargateEnergyCapacity(gate)
   if(Lib.HasResourceDistribution && (gate.resources || gate.resources2)) then
      return Lib.RD.GetUnitCapacity(gate, "energy")
   else
      return gate.capacity
   end
end

function Lib.SetStargateEnergyCapacity(gate, capacity)
   if(Lib.HasResourceDistribution) then
      Lib.RD.AddResource(gate, "energy", capacity)
   end

   gate.capacity = capacity
end

function Lib.MakeStargateUseEnergy(gate)
   if(gate.IsStargate ~= true) then
      return
   end

   local gateCapacity = Lib.STARGATE_DEFAULT_ENERGY_CAPACITY
   local energyDrain = Lib.STARGATE_DEFAULT_ENERGY_DRAIN
   local rechargeTime = 300

   Lib.SetStargateEnergyCapacity(gate, gateCapacity)

   gate.backups.Think = gate.Think
   gate.Think = function()
      if(Lib.IsStargateOutbound(gate)) then
         local energyConsumed = 0

         if(Lib.HasResourceDistribution) then
            energyConsumed = Lib.RD.ConsumeResource(gate, "energy", energyDrain)
         else
            energyConsumed = math.min(energyDrain, gate.energy)
            gate.energy = gate.energy - energyConsumed
         end

         if(energyConsumed < energyDrain) then
            gate:DeactivateStargate()
         end
      elseif(!Lib.HasResourceDistribution) then
         gate.energy = math.min(gate.energy + (gateCapacity * Lib.CYCLE_INTERVAL / rechargeTime), gateCapacity)
      end

      gate.backups.Think(gate)
      gate:SetNextThink(CurTime() + Lib.CYCLE_INTERVAL)
   end

   gate.backups.ActivateStargate = gate.ActivateStargate
   gate.ActivateStargate = function(...)
      gate.backups.ActivateStargate(gate, ...)

      if((Lib.HasResourceDistribution && Lib.RD.GetResource(gate, "energy") <= 0) ||
         (gate.energy && gate.energy <= 0)) then
         if (IsValid(gate.overloader)) then
         	gate.overloader:StopFiring();
         end
         gate:EmergencyShutdown()
      end
   end
end

-- Credit to aVoN for this function originally
-- Has since been cleaned up and modified to work with both old and new gates
function Lib.DestroyStargate(gate)
	if(!Lib.IsStargateDialling(gate) &&
      (gate.last_vaporize == nil || gate.last_vaporize + 10 < CurTime())) then
		gate.last_vaporize = CurTime()

		if(gate.use_nuke == nil || gate.use_nuke == true) then
         local nuke = ents.Create("gate_nuke")

         if(nuke and nuke:IsValid()) then
            nuke:Setup(Lib.GetEntityCentre(gate), 100)
            nuke:Spawn()
            nuke:Activate()
         end
      else
			local gatePos = Lib.GetEntityCentre(gate)

         local fx = EffectData()
   		fx:SetOrigin(gatePos)
   		util.Effect("Unstable_Explosion", fx)

         util.BlastDamage(gate.Entity, gate, gatePos, 2048, 1000)
		end

    Lib.UnJamGate(gate)
    if (IsValid(Lib.GetRemoteStargate(gate))) then
   		Lib.GetRemoteStargate(gate):DeactivateStargate(true)
    end
		gate:DeactivateStargate(true)

		if(Lib.IsProtectedByGateSpawner(gate) == false) then
			for _, dhd in pairs(gate:FindDHD(true)) do
				if(Lib.IsProtectedByGateSpawner(dhd) == false) then
					dhd:Remove()
				end
			end

         timer.Simple(1, function() if (IsValid(gate)) then gate:Remove() end end, nil)
		else
         gate.excessPower = 0
         gate.isOverloading = false -- Reset this so that the gate can be overloaded again in the future
		end
	end
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

function Lib.FindInsideRotatedBox(centre, min, max, ang) 	-- THANK YOU aVoN!!!!!!! :}}}) <<<This one gets 3 moustaches.
	local entities = ents.FindInSphere(centre,(min-max):Length()/2)
	local directions = {}
	local RotationMatrix = MMatrix.EulerRotationMatrix(ang.p,ang.y,ang.r)
	for _,v in pairs(entities) do
		directions[v] = RotationMatrix*(v:GetPos()-centre)
	end
	for k,v in pairs(entities) do
		local pos = directions[v];
		-- Snipplet taken from aVoN's tracelin-class of the stargatepack
		if not (
			(pos.x >= min.x and pos.x <= max.x) and
			(pos.y >= min.y and pos.y <= max.y) and
			(pos.z >= min.z and pos.z <= max.z)
		) then
			entities[k] = nil;
		end
	end
	return entities
end

-- ent1 = The ent where seeing has line of sight
-- enttab = the table of ents your trying to see
-- postab = the corosponding table of positions
function Lib.LOS(ent1, enttab, postab)
	local num = table.getn(enttab)
	local hitent = {}
	local hitentpos = {}
	local trace = {
		start = ent1.SplodePos,
		filter = ent1,
		mask = MASK_NPCWORLDSTATIC
	}

	for i=1,num do
		trace.endpos = postab[i]
		local tr = util.TraceLine(trace)
		if (tr.Fraction > 0.99) then
			table.insert(hitent, enttab[i])
			table.insert(hitentpos, postab[i])
		end
	end

	local size = table.getn(hitent)
	local inshield = Lib.ArePointsInsideAShield(hitentpos, 50)

	for i=1,size do
		if inshield[i] then
			hitent[i] = nil
			hitentpos[i] = nil
		end
	end

	return hitent,hitentpos
end

function Lib.ShieldTrace(pos, dir, filter)
	local tr = Lib.Trace:New(pos, dir, filter)
	local aim = (dir-pos):GetNormal()
	tr.HitShield = false

	if(IsValid(tr.Entity)) then 		-- special execption for when hitting avon's shield
		local class = tr.Entity:GetClass()
		if(class == "shield") then 	--This is a  ridiculously complex way of actually finding where the spherical shield is and not the cubic bounding box if anybody knows of a better way PLEASE tell me
			local pos2 = tr.Entity:GetPos()
			local rad = tr.Entity:GetNetworkedInt("size",0)
			local relpos = tr.HitPos-pos2
			local a = aim.x^2+aim.y^2+aim.z^2
			local b = 2*(relpos.x*aim.x+relpos.y*aim.y+relpos.z*aim.z)
			local c = relpos.x^2+relpos.y^2+relpos.z^2-rad^2
			local dist = (-1*b-(b^2-4*a*c)^0.5)/(2*a)	-- Thank god for Brahmagupta

			if tostring(dist) == "-1.#IND" then 	-- Sometimes the trace will hit the bounding box but end up not actually hitting the round shield and this should mean that dist is a non-real number
				tr = Lib.ShieldTrace(tr.HitPos, dir, tr.Entity, true)
			elseif dist < 0 then -- If the trace starts in the sphere the dist will be negative.
				dist = (-1*b+(b^2-4*a*c)^0.5)/(2*a)
				tr.HitPos = tr.HitPos+aim*dist
				tr.HitNormal = (tr.HitPos-pos2):GetNormal()
				tr.HitShield = true
			else
				tr.HitPos = tr.HitPos+aim*dist
				tr.HitNormal = (tr.HitPos-pos2):GetNormal()
				tr.HitShield = true
			end
		end
	end

	return tr
end

function Lib.ArePointsInsideAShield(points) -- Thanks PyroSpirit for the help :})<<<(P.S. It has a moustache).
	local IsInShield = {}
	local num = table.getn(points)
	for i=1,num do
		IsInShield[i] = false
	end

	for _,v in pairs (ents.FindByClass("shields")) do
		local Pos = v:GetPos()
		local rad = v:GetNWInt("size")+200
		if ((not v:GetNWBool("depleted", false)) and (not v:GetNWBool("containment",false))) then
			for i=1,num do
				local dis = points[i]:Distance(Pos)
				if dis <= rad then
				 	IsInShield[i] = true
				end
			end
		end
	end

	for _,v in pairs (ents.FindByClass("shieldcore_bubble")) do
		local Pos = v:GetPos()
		local rad = v:GetNWInt("SGESize")+200
		if not v:GetNWBool("depleted", false) then
			for i=1,num do
				local dis = points[i]:Distance(Pos)
				if dis <= rad then
				 	IsInShield[i] = true
				end
			end
		end
	end


	return IsInShield
end

function Lib.IsInEllipsoid(pos, ent, dimension)
   local pos2 = ent:WorldToLocal(pos);

   local d = pos2.x^2/dimension.x^2;
   local e = pos2.y^2/dimension.y^2;
   local f = pos2.z^2/dimension.z^2;

   return d+e+f<1;
end

function Lib.IsInCuboid(pos, ent, dimension)
   local pos2 = ent:WorldToLocal(pos);

   local d = math.abs(pos2.x/dimension.x);
   local e = math.abs(pos2.y/dimension.y);
   local f = math.abs(pos2.z/dimension.z);

   return not (d<1 and e<1 and f<1);
end

function Lib.IsInAltantisoid(pos, ent, dimension)
   local pos2 = ent:WorldToLocal(pos);
   local is_in;

   // if its higher than 2/5 c
   if (pos2.z > (2*dimension.z/5)) then
      is_in = Lib.IsInEllipsoid(pos, ent, dimension);
   else
      dimension.z = dimension.z/2;
      is_in = Lib.IsInEllipsoid(pos, ent, dimension); // lower than 2/5c its flatened
   end

   return is_in;
end

function Lib.IsInsideShieldCore(ent, core)
   if (core.ShShap == 1) then
      return Lib.IsInEllipsoid(ent:GetPos(), core, core.Size);
   elseif (core.ShShap == 2) then
      return not Lib.IsInCuboid(ent:GetPos(), core, core.Size); -- why NOT?? onclient it work correct, strange.
   elseif (core.ShShap == 3) then
      return Lib.IsInAltantisoid(ent:GetPos(), core, core.Size);
   end
end

function Lib.RayPhysicsPluckerIntersect(trace, dir, ent, in_shape)
   local hitted, hitpos, hitnorm, fraction;
   local TA, TB, TC;
   local a0, a1, a2, a3, a4, a5;
   local b0, b1, b2, b3, b4, b5;
   local c0, c1, c2, c3, c4, c5;
   local A, B;

   local LA = ent:WorldToLocal(trace.StartPos);
   local LB = ent:WorldToLocal(trace.HitPos)

   // Plucker ray coefs.
   local r0 = LA.x*LB.y - LB.x*LA.y;
   local r1 = LA.x*LB.z - LB.x*LA.z;
   local r2 = LA.x      - LB.x;
   local r3 = LA.y*LB.z - LB.y*LA.z;
   local r4 = LA.z      - LB.z;
   local r5 = LB.y      - LA.y;

   local hit; //imaginary variable

   // ran over every triangle in physics
   for i=1, table.getn(ent.RayModel), 3 do

      if in_shape then // if in shield then counter clock wise order
         TA = ent.RayModel[i];
         TB = ent.RayModel[i+1];
         TC = ent.RayModel[i+2];
      else
         TA = ent.RayModel[i+2];
         TB = ent.RayModel[i+1];
         TC = ent.RayModel[i];
      end

      // Plucker triangle coefs.
      a0 = TA.x*TB.y - TB.x*TA.y;
      a1 = TA.x*TB.z - TB.x*TA.z;
      a2 = TA.x      - TB.x;
      a3 = TA.y*TB.z - TB.y*TA.z;
      a4 = TA.z      - TB.z;
      a5 = TB.y      - TA.y;

      b0 = TB.x*TC.y - TC.x*TB.y;
      b1 = TB.x*TC.z - TC.x*TB.z;
      b2 = TB.x      - TC.x;
      b3 = TB.y*TC.z - TC.y*TB.z;
      b4 = TB.z      - TC.z;
      b5 = TC.y      - TB.y;

      c0 = TC.x*TA.y - TA.x*TC.y;
      c1 = TC.x*TA.z - TA.x*TC.z;
      c3 = TC.y*TA.z - TA.y*TC.z;

      // helper coefs.
      A = r0 * a4 + r1 * a5 + r3 * a2;
      B = r0 * b4 + r1 * b5 + r3 * b2;

      // calculate intersection (only true, false)
      if (A + r2 * a3 + r4 * a0 + r5 * a1 < 0) then hit = false;
      elseif (B + r2 * b3 + r4 * b0 + r5 * b1 < 0) then hit = false;
      elseif (r2 * c3 + r4 * c0 + r5 * c1 - A - B < 0) then hit = false;
      else
         local aa = ent:LocalToWorld(TA);
         local bb = ent:LocalToWorld(TB);
         local cc = ent:LocalToWorld(TC);

         // calculate intersection point for our triangle, there will be just one triangle so dont worry
         hitted, hitpos, hitnorm, fraction = Lib.RayTriangleIntersect(trace.StartPos, dir, aa, bb, cc);
         break;
      end

   end

   //return data or nil
   if hitted then
      return {HitPos=hitpos, Fraction=fraction, HitNormal=hitnorm};
   else
      return nil;
   end
end

function Lib.RayTriangleIntersect(start, dir, v1, v2, v3)
   local norm = (v2-v1):Cross(v3-v2):GetNormal(); // get normal of the triangle
   local dot = norm:DotProduct(v2-v1); // get dot product for further use

   // Now find plane (defined by DISTANCE, NORMAL) from three points
   local dist = -1*(v1:DotProduct(norm));

   // Find line/plane intersection
   local den = norm:DotProduct(dir);

   // If den is 0 line is parallel to plane
   if (den == 0) then return false end

   // trace fraction
   local t = (-1*(norm:DotProduct(start) + dist)) / den;

   // and our point
   local p = start+dir*t;

   debugoverlay.Line(v1, v2, 2, Color(255,255,255), true);
   debugoverlay.Line(v2, v3, 2, Color(255,255,255), true);
   debugoverlay.Line(v1, v3, 2, Color(255,255,255), true);

   //is it really intersecting?
   if Lib.PointInTriangle(p, v1,v2,v3) then
      norm = (v2-v1):Cross(v3-v2):GetNormal(); // do one more time jsut to be sure
      return true, p, norm, t;
   else return false, nil, nil, nil;
   end
end

function Lib.SameSide(p1,p2, a,b)
    local cp1 = (b-a):Cross(p1-a);
    local cp2 = (b-a):Cross(p2-a);
   if (cp1:DotProduct(cp2) >=0) then return true;
    else return false end
end

function Lib.PointInTriangle(p, a,b,c)
    if (Lib.SameSide(p,a, b,c) and Lib.SameSide(p,b, a,c) and Lib.SameSide(p,c, a,b)) then return true
    else return false end
end

function Lib.IsRayBoxIntersect(start, hit, ent)
   local box_size = ent:GetTraceSize();

   // Put line in box space
   local new_start = ent:WorldToLocal(start);
   local new_end = ent:WorldToLocal(hit);

   // Get line midpoint and extent
   local LMid = (new_start + new_end) / 2;
   local L = (new_start - LMid);
   local LExt = Vector(math.abs(L.x), math.abs(L.y), math.abs(L.z));

   // Use Separating Axis Test
   // Separation vector from box center to line center is LMid, since the line is in box space
   if (math.abs(LMid.x) > (box_size.x + LExt.x)) then return false end
   if (math.abs(LMid.y) > (box_size.y + LExt.y)) then return false end
   if (math.abs(LMid.z) > (box_size.z + LExt.z)) then return false end

   // Crossproducts of line and each axis
   if (math.abs(LMid.y*L.z - LMid.z*L.y)  >  (box_size.y*LExt.z + box_size.z*LExt.y) ) then return false end
   if (math.abs(LMid.x*L.z - LMid.z*L.x)  >  (box_size.x*LExt.z + box_size.z*LExt.x) ) then return false end
   if (math.abs(LMid.x*L.y - LMid.y*L.x)  >  (box_size.x*LExt.y + box_size.y*LExt.x) ) then return false end

   // No separating axis, the line intersects
   return true;
end

--################# Instead of overwriting the FireBullets function twice (shield/eventhorizon) to recognize bullets, we create a customhook here @aVoN
--################# I know that hooks are good way of doing that, but some gmod update broke then and i had nbo idea how to fix them, so i turend it ent side into a function @Mad
Lib.Bullets = Lib.Bullets or {};


hook.Add("EntityFireBullets","Lib.EntityFireBullets",function(self,bullet)
   if(not bullet) then return end;
   local original_bullet = table.Copy(bullet);
   local override = false; -- If set to true, we will shoot the bullets instead of letting the engine decide
   -- The modified part now, to determine if we hit a shield!
   local spread = bullet.Spread or Vector(0,0,0); bullet.Spread = Vector(0,0,0);
   local direction = (bullet.Dir or Vector(0,0,0));
   local pos = bullet.Src or self:GetPos();
   local rnd = {};
   rnd = {math.Rand(-1,1),math.Rand(-1,1)};
   --################# If we hit anything, run the hook
   local dir = Vector(direction.x,direction.y,direction.z); -- We need a "new fresh" vector
   --Calculate Bullet-Spread!
   if(spread and spread ~= Vector(0,0,0)) then
      -- Two perpendicular vectors to the direction vector (to calculate the spread-cone)
      local v1 = (dir:Cross(Vector(1,1,1))):GetNormalized();
      local v2 = (dir:Cross(v1)):GetNormalized();
      dir = dir + v1*spread.x*rnd[1] + v2*spread.y*rnd[2];
      -- Instead letting the engine decide to add randomness, we are doing it (Just for the trace)
      bullet.Dir = dir;
   end
   local trace = Lib.Trace:New(pos,dir*16*1024,{self,self:GetParent()});
   if(hook.Call("Lib.Bullet",GAMEMODE,self,bullet,trace)) then
      return false
   else
      return
   end
end)

local function InitPostEntity( )

   // get existing
   local settings = physenv.GetPerformanceSettings();

   // change velocity for bullets
   settings.MaxVelocity = 20000;

   // set
   physenv.SetPerformanceSettings( settings );


end
hook.Add( "InitPostEntity", "LoadPhysicsModule", InitPostEntity );
