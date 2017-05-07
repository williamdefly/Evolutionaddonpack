MsgN("eap_librairies/server/general.lua")

--CAP Compatibility
if(Lib.IsCapDetected and not ConVarExists("stargate_gatespawner_enabled"))then
   CreateConVar( "stargate_gatespawner_enabled", "0", FCVAR_ARCHIVE, "Stargate Gatespawner" )

   print('CAP Gatespawner Disabled for compatibility !')
end

if(Lib.IsCapDetected and GetConVarNumber("stargate_gatespawner_enabled")==1) then
   RunConsoleCommand("stargate_gatespawner_enabled","0")

   RunConsoleCommand("stargate_reload")

   print('CAP Gatespawner Disabled for compatibility !')
end

--No camera bugs
if(ConVarExists("mp_forcecamera"))then
   if(GetConVarNumber("mp_forcecamera")==1) then
      RunConsoleCommand("mp_forcecamera","0")

      print('mp_forcecamera was set to 0 ! Please modify this in server.cfg to hide this line in future start.')
   end
end

--Config
if (not file.IsDir("eap","DATA")) then
   file.CreateDir("eap","DATA");
end
--################# Loads the config @aVoN
function Lib.LoadConfig(p)
   if(not IsValid(p) or p:IsAdmin() or game.SinglePlayer()) then
      -- fix for cleaning old values on reload
      if (Lib.CFG.Get and type(Lib.CFG.Get)=="function") then
         local copy,dcopy = Lib.CFG.Get,Lib.CFG.DTOOL;
         Lib.CFG = {};
         Lib.CFG.Get = copy;
         Lib.CFG.DTOOL = dcopy;
      end
      Lib.CFG.SYNC = {}; -- They sync keys
      Lib.CFG.DTOOL = Lib.CFG.DTOOL or {}; -- Disabled tools fix
      -- Loads the config only ONE time and not always when I press "sent_reload" (Increases loading times)
      if(not INIParser) then include("ini_parser.lua") end;
      if(file.Exists("eap/config.txt","DATA"))then --Delete Old configs
         file.Delete( "eap/config.txt" )
         file.Delete( "eap/custom_config.txt" )
         file.Delete( "eap/how to create your own config.txt" )
      end
      if (file.Exists("lua/data/eap/config.lua","GAME")) then
         file.Write("eap/configs.txt",file.Read("lua/data/eap/config.lua","GAME"));
      end
      if (file.Exists("lua/data/eap/how to create your own config.lua","GAME")) then
         file.Write("eap/how to create your own configs.txt",file.Read("lua/data/eap/how to create your own config.lua","GAME"));
      end
      local ini = INIParser:new("eap/configs.txt",false);
      local custom_config = INIParser:new("eap/custom_configs.txt",false);
      -- Merge our custom config with the default one
      if(custom_config) then
         for node,datas in pairs(custom_config.nodes) do
            ini.nodes[node] = ini.nodes[node] or {};
            for num,data in pairs(datas) do
               ini.nodes[node][num] = ini.nodes[node][num] or {};
               for k,v in pairs(data) do
                  ini.nodes[node][num][k] = v;
               end
            end
         end
      end
      for name,cfg in pairs(ini:get()) do
         if(name ~= "config") then
            if (cfg[1]==nil) then continue; end
            Lib.CFG[name] = {};
            local sync = (cfg[1].SYNC or ""):TrimExplode(",");
            for k,v in pairs(cfg[1]) do
               v=v:Trim();
               local number = tonumber(v);
               if(number) then
                  v = number;
               elseif(v == "false" or v == "true") then
                  v = util.tobool(v);
               end
               Lib.CFG[name][k] = v;
               -- Sync the values with the Client
               if(table.HasValue(sync,k) or name:find("_groups_only") or name:find("eap_disabled_")) then
                  Lib.CFG.SYNC[name] = Lib.CFG.SYNC[name] or {};
                  Lib.CFG.SYNC[name][k] = v;
               end
               -- not sure what better - disable it from selecting or show "This tool is disabled on server!" error...
               if (name == "eap_disabled_tool") then
                  if (v) then
                     RunConsoleCommand("toolmode_allow_"..k,0)
                     Lib.CFG.DTOOL[k] = true;
                  else
                     RunConsoleCommand("toolmode_allow_"..k,1)
                     Lib.CFG.DTOOL[k] = nil;
                  end
               end
            end
         end
      end
      -- fix for tools
      local tbl = Lib.CFG.DTOOL;
      for k,v in pairs(tbl) do
         if (not Lib.CFG["eap_disabled_tool"] or not Lib.CFG["eap_disabled_tool"][k]) then
            RunConsoleCommand("toolmode_allow_"..k,1);
            Lib.CFG.DTOOL[k] = nil;
         end
      end
      --if (Lib.Hook.PlayerInitialSpawn) then timer.Simple(0,function() Lib.Hook.PlayerInitialSpawn(NULL,true) end) end -- fix for reload.
   end
end
Lib.LoadConfig();
concommand.Add("eap_reloadconfig",Lib.LoadConfig);

util.AddNetworkString( "EAP_CFG" );
--################# Starts syncing the CFG from the server to the client @aVoN
function Lib.Hook.PlayerInitialSpawn(p,reload)
   -- Now start syncing the config (also tells the client, SGPack is installed - just to be sure)
   if(p and IsValid(p) and p:IsPlayer() or reload) then
      net.Start("EAP_CFG");
      net.WriteString("_CFG_RELOAD_");
      if (reload) then
         net.Broadcast();
      else
         net.Send(p);
      end
   end
   for name,data in pairs(Lib.CFG.SYNC) do
      if(p and IsValid(p) and p:IsPlayer() or reload) then -- Prevents crashing (must be done everytime we send a umsg!)
         net.Start("EAP_CFG");
         net.WriteString(name); -- Tell the client, what CFG node
         net.WriteUInt(table.Count(data),8); -- Tell the client, how much data will follow (Char goes from -128 to 128). But you seriously shoudln't add more than 20 umsg!
         for k,v in pairs(data) do
            net.WriteString(k); -- Tell the client, what's the keys name
            if(type(v) == "boolean") then
               net.WriteUInt(0,8); -- I'm a bool
               net.WriteBit(v);
            elseif(type(v) == "string") then
               net.WriteUInt(1,8); -- I'm a string
               net.WriteString(v);
            else -- I'm a sort of number
               if(v ~= math.ceil(v)) then -- I'm a float
                  net.WriteUInt(2,8);
                  net.WriteDouble(v);
               elseif(v > -128 and v < 127) then -- I'm a Char
                  net.WriteUInt(3,8);
                  net.WriteInt(v,8);
               elseif(v > -32768 and v < 32767) then -- I'm a short
                  net.WriteUInt(4,8);
                  net.WriteInt(v,16);
               else -- I'm a long
                  net.WriteUInt(5,8);
                  net.WriteInt(v,32);
               end
            end
         end
         if (reload) then
            net.Broadcast();
         else
            net.Send(p);
         end
      end
   end
end
hook.Add("PlayerInitialSpawn","Lib.Hook.PlayerInitialSpawn",Lib.Hook.PlayerInitialSpawn);

--################# Sends NWData of the gates to a client@aVoN
--If a new player joins the server, he normally does not have Networked Data which has been set before he joined. This hook forces to resend the date to everyone if he presses
-- "MoveForward" the first time just after he joined. Before I used a Think, but I think this was useless networked data.
local joined = {};
hook.Add("KeyPress","Lib.KeyPress.SendGateData",
   function(p,key)
      if(not joined[p] and key == IN_FORWARD) then
         joined[p] = true; -- Do not call this hook twice!
         for _,v in pairs(ents.FindByClass("sg_*")) do
            if(v.IsStargate) then
               v:SetNetworkedString("Address",""); -- "Reset old value" to cause an immediate update in the next step below
               v:SetNWString("Address",v.GateAddress,true);
               v:SetNWString("Group",""); -- "Reset old value" to cause an immediate update in the next step below
               v:SetNWString("Group",v.GateGroup,true);
               v:SetNWString("Name",""); -- "Reset old value" to cause an immediate update in the next step below
               v:SetNWString("Name",v.GateName,true);
               v:SetNWBool("Private",not v.GatePrivat); -- "Reset old value" to cause an immediate update in the next step below
               v:SetNWBool("Private",v.GatePrivat,true);
               v:SetNWBool("Locale",not v.GateLocal); -- "Reset old value" to cause an immediate update in the next step below
               v:SetNWBool("Locale",v.GateLocal,true);
               v:SetNWBool("Galaxy",not v.GateGalaxy);
               v:SetNWBool("Galaxy",v.GateGalaxy,true);
               v:SetNWBool("Blocked",not v.GateBlocked);
               v:SetNWBool("Blocked",v.GateBlocked,true);
               v:SendGateInfo(p);
               v:ConvarsThink(true);
            end
         end
         for _,v in pairs(ents.FindByClass("atlantis_trans")) do
            net.Start("UpdateAtlTP")
            net.WriteInt(v:EntIndex(),16)
            net.WriteInt(3,4)
            net.WriteString(v.TName or "")
            net.WriteBit(v.TPrivate or false)
            net.Send(p)
         end
      end
   end
);

local function StarGate_CloseAll(ply)
   if (IsValid(ply) and not ply:IsAdmin()) then ply:PrintMessage( HUD_PRINTCONSOLE, "Yor are not admin!"); return end
   timer.Simple(0.1,function()
      for k,v in pairs(ents.FindByClass("sg_*")) do
         if (v.IsStargate) then
            v:AbortDialling();
         end
      end
   end);
   if (IsValid(ply)) then
      ply:PrintMessage( HUD_PRINTCONSOLE, "All gates closed! (not including blocked stargates by some devices)");
   else
      print("All gates closed! (not including blocked stargates by some devices)");
   end
end
concommand.Add("eap_close_all",StarGate_CloseAll);

local function StarGate_OpenAll(ply)
   if (IsValid(ply) and not ply:IsAdmin()) then ply:PrintMessage( HUD_PRINTCONSOLE, "Yor are not admin!"); return end
   timer.Simple(0.1,function()
      for k,v in pairs(ents.FindByClass("*_iris")) do
         if (v.IsIris) then
            v:TrueActivate(true);
         end
      end
   end);
   if (IsValid(ply)) then
      ply:PrintMessage( HUD_PRINTCONSOLE, "All iris is opened!");
   else
      print("All iris is opened!");
   end
end
concommand.Add("eap_open_all_iris",StarGate_OpenAll);

local function StarGate_ShutdownShields(ply)
   if (IsValid(ply) and not ply:IsAdmin()) then ply:PrintMessage( HUD_PRINTCONSOLE, "Yor are not admin!"); return end
   timer.Simple(0.1,function()
      for k,v in pairs(ents.FindByClass("shield_generator")) do
         if (v:Enabled()) then
            v:Status(false);
         end
      end
      for k,v in pairs(ents.FindByClass("shield_core")) do
         if (IsValid(v.Shield) and v.Shield.Enabled) then
            v:Status(false);
         end
      end
   end);
   if (IsValid(ply)) then
      ply:PrintMessage( HUD_PRINTCONSOLE, "All shields shutdown!");
   else
      print("All shields shutdown!");
   end
end
concommand.Add("eap_shutdown_shields",StarGate_ShutdownShields);

function Lib.NotSpawnable(class,player,mode,nomsg)
   if (not mode) then mode = "ent" end
   if ( Lib.CFG:Get("eap_disabled_"..mode,class,false) ) then
      if (not nomsg and IsValid(player)) then
         player:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"eap_disabled_"..mode.."\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
      end
      return true
   end
   if (not IsValid(player)) then return false end
   if (Lib.CFG:Get(mode.."_groups_only",class,false)) then
      local tbl = Lib.CFG:Get(mode.."_groups_only",class,""):TrimExplode(",");
      local disallow = true;
      local exclude = false;
      if (table.HasValue(tbl,"exclude_mod")) then exclude = true; disallow = false; end
      for k,v in pairs(tbl) do
         if (v=="add_shield" or v=="exclude_mod") then continue end
         if (player:IsUserGroup(v)) then
            disallow = exclude;
            break;
         end
      end
      if (table.Count(tbl)==0) then disallow = false end
      if (disallow) then
         if (not nomsg) then
            player:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"eap_group_"..mode.."\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
         end
         return true;
      end
   end
   return false;
end

-- added by AlexALX for nuke explosions
-- anywat it bit buggy with shield core somewhy, wrong angles or so
function Lib.IsInShield(ent)
   local pos = ent:GetPos();
   local shields = {"shields","shield_ship","shieldcore_bubble"}

   for b,s in pairs(shields) do
      for c,v in pairs(ents.FindByClass(s)) do
         local sh_dist = (pos - v:GetPos()):Length();
         if (s=="shields") then
            if (sh_dist<=v.Size and not v:IsContainment()) then
               return true;
            end
         elseif (s=="shield_ship") then
            local Size = 200;
            if (sh_dist<=Size) then
               return true;
            end
         else
            if (not v.Depleted and v.Enabled and Lib.IsInsideShieldCore(ent,v)) then
               return true;
            end
         end
      end
   end
   return false;
end


function Lib.FindShield(ent)
   local gate;
   local dist = 10000;
   local pos = ent:GetPos();
   for _,v in pairs(ents.FindByClass("shieldcore")) do
      local sg_dist = (pos - v:GetPos()):Length();
      if(dist >= sg_dist) then
         dist = sg_dist;
         gate = v;
      end
   end
   return gate;
end

function Lib.FindKino(p)
   local number = 0;
   local KinoEnt = {};
   for _,v in pairs(ents.FindByClass("kinoball*")) do
      if (v.Owner == p) then
         table.insert(KinoEnt, v)
         number = number + 1;
      end
   end
   return number, KinoEnt;
end

util.AddNetworkString("_EAPCUSTOM_GROUPS");
function Lib.LoadGroupConfig()
   if (not file.Exists("eap/custom_groups.txt","DATA") and file.Exists("lua/data/eap/custom_groups.lua","GAME")) then
      file.Write("eap/custom_groups.txt",file.Read("lua/data/eap/custom_groups.lua","GAME"))
   end

   Lib.CUSTOM_GROUPS = {};
   Lib.CUSTOM_TYPES = {};

   local ini = INIParser:new("eap/custom_groups.txt",false,false,true);
   if(ini) then
      if (ini.nodes.stargate_custom_groups and ini.nodes.stargate_custom_groups[1]) then
         for k,v in pairs(ini.nodes.stargate_custom_groups[1]) do
            Lib.CUSTOM_GROUPS[k] = {v};
         end
      end
      if (ini.nodes.stargate_custom_types and ini.nodes.stargate_custom_types[1]) then
         for k,v in pairs(ini.nodes.stargate_custom_types[1]) do
            if (v:sub(-8)==" !SHARED") then
               Lib.CUSTOM_TYPES[k] = {v:sub(0,-9),true};
            else
               Lib.CUSTOM_TYPES[k] = {v};
            end
         end
      end

      hook.Add("PlayerInitialSpawn","SG_INIT_CUSTOM_GROUPS",function(ply)
         net.Start("_EAPCUSTOM_GROUPS");
         net.WriteTable(Lib.CUSTOM_GROUPS);
         net.WriteTable(Lib.CUSTOM_TYPES);
         net.Send(ply);
      end)

      -- if reload config
      timer.Simple(1.0,function()
         net.Start("_EAPCUSTOM_GROUPS");
         net.WriteTable(Lib.CUSTOM_GROUPS);
         net.WriteTable(Lib.CUSTOM_TYPES);
         net.Broadcast();
      end)
   end
end
Lib.LoadGroupConfig();

-- From stargate group system by AlexALX
messageblock = messageblock or {};

function Lib.ReloadSystem(groupsystem)
	if (messageblock[tostring(groupsystem)]) then return; end
	local system = "Galaxy System";
	if (groupsystem) then
		system = "Group System";
	end
	for k, v in pairs(player.GetHumans()) do
		v:SendLua("LocalPlayer():ChatPrint(Lib.Language.GetMessage(\"eap_reload\",\""..system.."\"))");
	end
	RunConsoleCommand("eap_reload");
	if (tostring(groupsystem)=="true") then
		messageblock["false"] = false;
	elseif (tostring(groupsystem)=="false") then
		messageblock["true"] = false;
	end
	messageblock[tostring(groupsystem)] = true;
	timer.Remove("_Lib.ReloadSystemMessage");
	timer.Create("_Lib.ReloadSystemMessage",5.25,1,
		function()
			messageblock[tostring(groupsystem)] = false;
			Lib.ReloadedSystemMessage();
		end
	);
end

function Lib.ReloadedSystemMessage()
	for k, v in pairs(player.GetHumans()) do
		v:SendLua("LocalPlayer():ChatPrint(Lib.Language.GetMessage(\"eap_reload\",\""..system.."\"))");
	end
end

function Lib.DrawGateHeatEffects(gate)
   Lib.TintGate(gate)

   if(gate.excessPower and gate.excessPowerLimit) then
      -- The amount of excess power required to destabalise the stargate
      local destabalisingExcessPower = 3 * (gate.excessPowerLimit / 4)

      if(gate.excessPower >= destabalisingExcessPower) then
         -- Chance of the gates flickering if excessPower is at least 3/4 of the limit
         if(math.random(0, gate.excessPower) >= destabalisingExcessPower) then
            if(gate.malfunction) then
               gate.malfunction:Fire("DoSpark","",0)
            end

            Lib.MakeGateFlicker(gate)
         end
      end
   end
end

function Lib.MakeGateFlicker(gate)
   local remoteGate = Lib.GetRemoteStargate(gate)

   if(remoteGate == nil || remoteGate:IsValid() == false) then
      return false
   end

   if(gate.Flicker) then
      gate:Flicker()
      remoteGate:Flicker()
   elseif(gate.EventHorizon) then
      gate.EventHorizon:SetColor(Color(150, 150, 150, 255))
      remoteGate.EventHorizon:SetColor(Color(150, 150, 150, 255))

      local function resetColour(entity)
         if(entity && entity:IsValid()) then
            entity:SetColor(Color(255, 255, 255, 255))
         end
      end

      timer.Simple(0.5, function() resetColour(gate.EventHorizon) end)
      timer.Simple(0.5, function() resetColour(remoteGate.EventHorizon) end)
   end
end

function Lib.StopUpdateGateTemperatures(gate)
	if timer.Exists("UpdateGateTemp"..gate:EntIndex()) then timer.Destroy("UpdateGateTemp"..gate:EntIndex()) end
end

function Lib.UpdateGateTemperatures(gate)
	 timer.Create("UpdateGateTemp"..gate:EntIndex(), Lib.CYCLE_INTERVAL, 0, function()
   -- for _, gate in pairs(ents.FindByClass("sg_*")) do
      local shouldCoolGate = true

      for _, overloader in pairs(ents.FindByClass("gate_overloader")) do
         if(overloader.remoteGate == gate) then
            shouldCoolGate = false
         end
      end

      if(shouldCoolGate) then
         Lib.CoolGate(gate)
      end

      Lib.DrawGateHeatEffects(gate)
      Lib.CauseHeatDamage(gate)
   end);
end

Lib.STARGATE_DEFAULT_ENERGY_CAPACITY = Lib.CFG:Get("gate_overloader","energyCapacity",580000)
Lib.COOLING_PER_CYCLE = Lib.CFG:Get("gate_overloader","coolingPerCycle",300)

function Lib.CoolGate(gate)
   if(gate == nil) then
      Msg("Gate passed to CoolGate(gate) cannot be nil.\n")
      return flase
   elseif(gate.excessPower == nil || gate.excessPower <= 0) then
      return false
   end

   -- The amount of energy lost as the gate cools
   local energyDissipated = math.min(Lib.COOLING_PER_CYCLE, gate.excessPower)

   -- Dissipate some of the excess power
   gate.excessPower = gate.excessPower - energyDissipated

   -- What is this? it seems like CONSUME energy with LS3, so i just disable this.
   --if(Lib.HasResourceDistribution) then
      -- Reduce the amount of energy the gate can store by the amount dissipated
      -- This will result in the gate returning to its original energy capacity once it has completely cooled
      --Lib.WireRD.AddResource(gate, "energy", Lib.GetStargateEnergyCapacity(gate) - energyDissipated)
   --end

   return true
end

function Lib.TintGate(gate)
   if(gate == nil || not IsValid(gate)) then
      Msg("Gate passed to Lib.TintGate was not valid.\n")
      return
   elseif(gate.excessPower == nil or gate.excessPowerLimit==nil) then
      return
   end

   if(gate.excessPower < 0) then
      gate.excessPower = 0
   end

   local tintAmount = 255 * (gate.excessPower / gate.excessPowerLimit)

   local col = gate.OrigColor or Color(255,255,255)
   gate:SetColor(Color(math.Clamp(col.r + tintAmount,0,255), math.Clamp(col.g - tintAmount,0,255), math.Clamp(col.b - tintAmount,0,255), col.a))

   local iris = Lib.GetIris(gate)

   if(IsValid(iris)) then
      tintAmount = math.min(tintAmount * 2, 128)

      local col = iris.OrigColor or Color(255,255,255)
      iris:SetColor(Color(math.Clamp(col.r + tintAmount,0,255), math.Clamp(col.g - tintAmount,0,255), math.Clamp(col.b - tintAmount,0,255), col.a))
      iris.OrigColor = col
   end

   gate.OrigColor = col
end

function Lib.EmitHeat(pos, damage, radius, inflictor)
   if(CombatDamageSystem) then
      cds_heatpos(pos, damage, radius)
      return true
   elseif(gcombat) then
      gcombat.emitheat(pos, radius, damage, inflictor)
      return true
   else
      return false
   end
end

function Lib.HeatEntity(entity, damage, radius, inflictor)
   if(Lib.EmitHeat(entity:GetPos(), damage, radius, inflictor)) then
      return true
   else
      if(entity.burnInflictor == nil) then
         local burnInflictor = ents.Create("point_hurt")
         burnInflictor:SetOwner(inflictor)
         burnInflictor:SetPos(Lib.GetEntityCentre(entity))
         burnInflictor:SetKeyValue("DamageDelay", 0.2)
         burnInflictor:SetKeyValue("DamageType", 8) -- Burn damage

         burnInflictor:Spawn()
         burnInflictor:Activate()
         burnInflictor:SetParent(entity)

         entity.burnInflictor = burnInflictor
      end

      entity.burnInflictor:SetKeyValue("DamageRadius", radius)
      entity.burnInflictor:SetKeyValue("Damage", damage)
   end
end

function Lib.CoolEntity(entity)
   if(entity.burnInflictor) then
      entity.burnInflictor:Remove()
      entity.burnInflictor = nil
   end
end

function Lib.CauseHeatDamage(gate)
   if(gate == nil) then
      Msg("Gate passed to CauseHeatDamage(gate) cannot be nil.\n")
      return false
   elseif(gate.excessPower == nil) then
      return false
   end

   if(gate.excessPower > gate.excessPowerLimit / 2 and IsValid(gate.overloader)) then
      -- Make gate cause damage to nearby players due to extreme heat
      local heatDamage = math.Round(2 * (gate.excessPower / gate.excessPowerLimit))
      local heatRadius = 500 * (gate.excessPower / gate.excessPowerLimit)
      local overloaderOwner = gate.overloader:GetVar("Owner", gate.overloader:GetOwner())

      Lib.HeatEntity(gate, heatDamage, heatRadius, overloaderOwner)

      if(gate.excessPower > 3 * (gate.excessPowerLimit / 4) and Lib.GetEntityCentre(gate)) then
         for k, entity in pairs(ents.FindInSphere(Lib.GetEntityCentre(gate), heatRadius)) do
            if(entity ~= gate) then
               entity:Ignite(2, 25)
            end
         end
      end

      return true
   else
      Lib.CoolEntity(gate)
      return false
   end
end


function Lib.FindPlayer(pos, range)
	local ply = false;
	local dist = range;
	for _,v in pairs(player.GetAll()) do
		local p_dist = (pos - v:GetPos()):Length();
		if(dist >= p_dist) then
			dist = p_dist;
			ply = true;
		end
	end
	return ply;
end

function Lib.FindIris(gate)
	local iris;
	if (IsValid(gate) and gate.IsStargate) then
		for _,v in pairs(ents.FindInSphere(gate:GetPos(),10)) do
			if v.IsIris then
				iris = v;
			end
		end
	end
	return iris;
end

function Lib.FindGate(ent, dist, super)
   local gate;
   local pos = ent:GetPos();
   for _,v in pairs(ents.FindByClass("sg_*")) do
      if(not v.IsStargate or v.IsSupergate and not super) then continue end
      local sg_dist = (pos - v:GetPos()):Length();
      if(dist >= sg_dist) then
         dist = sg_dist;
         gate = v;
      end
   end
   return gate;
end

function Lib.GetIris(gate)
   if(gate.iris) then
      return gate.iris
   elseif(IsValid(gate.Iris)) then
      return gate.Iris
   end

   for _, entity in pairs(ents.FindInSphere(gate:GetPos(), 10)) do
      if(entity.IsIris) then
         return entity
      end
   end

   return nil
end

function Lib.IsIrisClosed(gate)
   return gate.irisclosed == true || (gate.IsBlocked && gate:IsBlocked(true) == true)
end

-- ramdom_names.lua
-- This code makes it so gates get random names when they spawn! :D
-- Created by cartman300, edited by AlexALX

local function RandomAddress(max,exclude)
    local chr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ@1234567890"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomNumber(max)
    local exclude = ""
    local chr = "0123456789"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomString(max)
    local exclude = ""
    local chr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomAll(max)
    local chr = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local ret = ""
    local exclude = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

function Lib.RandomGatesName(ply,ent,count,wire,mode)
   local conv = GetConVar("stargate_eap_random_address")
    if (conv and conv:GetBool() or wire) then
        if (IsValid(ent) and ent.IsStargate and ent:GetClass()!="sg_orlin") then
         if (mode==nil or mode<=1) then
            local randadr = "";
            if (GetConVar("stargate_group_system"):GetBool()) then
               randadr = RandomAddress(6,ent:GetGateGroup())
               else
               randadr = RandomAddress(6,"@0")
               end
            local valid = false;
            for k,v in pairs(ents.FindByClass("sg_*")) do
               if (v.IsStargate) then
                  if (v:GetGateGroup()==ent:GetGateGroup() and randadr==v:GetGateAddress()) then
                     valid = true; break;
                  end
               end
            end
            count = count or 1;
            if valid then
               if (count>5) then return end -- fix infinity loop
               Lib.RandomGatesName(ply,ent,count+1,wire,mode); return
            end
            ent:SetGateAddress(randadr);
         end
         if (mode==nil or mode<=0 or mode>=2) then
               if (ent:GetClass() == "sg_atlantis") then
                   ent:SetGateName("M"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2))
               elseif (ent:GetClass() == "sg_supergate") then
                   ent:SetGateName(RandomAll(7))
               elseif (ent:GetClass() == "sg_universe") then
                   ent:SetGateName("U-"..RandomNumber(5))
               else
                   ent:SetGateName("P"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2))
               end
            end
        end
    end
end
hook.Add( "PlayerSpawnedSENT", "RandomGatesName", Lib.RandomGatesName );