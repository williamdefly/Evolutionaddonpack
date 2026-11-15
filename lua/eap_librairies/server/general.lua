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
	-- The dial menus keep a client copy of every gate's info, and the switch did not refresh it: entries taken in Galaxy mode have an
	-- empty group, so back in Group mode the menu hid those gates. Sent again once every gate has changed system (each one notices
	-- within 5 seconds).
	timer.Create("_Lib.ResyncGateList",6.0,1,Lib.ResyncGateList);
end

-- Sends the info of every EAP gate to the clients again.
function Lib.ResyncGateList()
	for _, v in pairs(ents.FindByClass("sg_*")) do
		if (IsValid(v) and v.IsStargate) then
			v:SendGateInfo();
		end
	end
end

-- Slow dial towards a gate that plays a full inbound animation (Pegasus). The source pauses the destination's queued sequence when
-- it starts dialling and resumes it right before its last chevron locks, so the destination had no time to play its animation.
-- The functions below resume the destination early and make each gate wait for the other, so both vortices still open together.
--
-- Seconds the destination is expected to wait at the end of its animation.
local SLOW_DIAL_MARGIN = 1.0;

-- Rewrites the source's dial action list. The step resuming the destination becomes Lib.ReleaseSlowDialTarget, and an earlier resume
-- (Lib.StartSlowDialTarget) is inserted where the source starts waiting for its ring on the last symbol. "lead" is the length of
-- the destination's animation. Returns true when the list contained the resume step.
function Lib.ShiftTargetUnpause(ent, action, lead)
	local pausefn = ent.PauseActions;
	local pause, unpause;
	for i, step in ipairs(action) do
		if (step.f == pausefn and type(step.v) == "table" and step.v[3] == true) then
			if (step.v[2] == true) then
				unpause = i;
				break;
			elseif (not pause) then
				pause = i;
			end
		end
	end
	if (not unpause or not pause or unpause <= pause + 1) then return false end

	local target = action[unpause].v[1];
	-- The step where the source pauses its own timers to wait for its ring on the last symbol.
	local ringwait;
	for i = unpause - 1, pause + 1, -1 do
		local step = action[i];
		if (step.f == pausefn and type(step.v) == "table" and step.v[1] ~= target and step.v[2] == false and step.v[3] == nil) then
			ringwait = i;
			break;
		end
	end

	local function StartOf(index)
		local time = 0;
		for i = 1, index - 1 do time = time + (tonumber(action[i].d) or 0) end
		return time;
	end

	-- A delay above 0 ends the step's timer package: the lock that follows is a separate timer, which can be paused.
	action[unpause].f = Lib.ReleaseSlowDialTarget;
	action[unpause].v = { target, ent };
	action[unpause].d = math.max(tonumber(action[unpause].d) or 0, 0.01);

	ent.SlowDialWaits = {};
	ent.SlowDialWaitStart = nil;
	if (ringwait) then
		local remaining = StartOf(unpause) - StartOf(ringwait);
		table.insert(action, ringwait, { f = Lib.StartSlowDialTarget, v = { ent, target, lead, remaining }, d = 0 });
	end
	return true;
end

-- Measures how long the source waited for its ring on each symbol of this dial (pause -> resume of its own timers).
function Lib.TrackSlowDialWait(ent, unpause)
	if (not ent.SlowDialWaits) then return end
	if (unpause) then
		if (ent.SlowDialWaitStart) then table.insert(ent.SlowDialWaits, CurTime() - ent.SlowDialWaitStart) end
		ent.SlowDialWaitStart = nil;
	else
		ent.SlowDialWaitStart = CurTime();
	end
end

-- Source, starting to wait for its ring on the last symbol: resumes the destination so that its animation ends about when the lock
-- happens. The ring time is estimated from the waits measured on the previous symbols, not from a chevron count.
function Lib.StartSlowDialTarget(source, target, lead, remaining)
	local ent = source.Entity or source;
	if (not IsValid(ent) or not IsValid(target) or target.InboundSlowReleased ~= false) then return end
	local delay = 0;
	local waits = ent.SlowDialWaits or {};
	if (#waits > 0) then
		local sum = 0;
		for _, wait in ipairs(waits) do sum = sum + wait end
		delay = math.max(sum / #waits + remaining - lead - SLOW_DIAL_MARGIN, 0);
	end
	local function Resume()
		if (IsValid(ent) and IsValid(target) and target.InboundSlowReleased == false and target.Target == ent) then
			target:PauseActions(true, true);
		end
	end
	if (delay < 0.05) then Resume() else timer.Simple(delay, Resume) end
end

-- Seconds a gate waits for the other one before giving up.
local SLOW_DIAL_WAIT_LIMIT = 60;

-- Destination whose source stopped dialling: fails the dial instead of opening on nothing.
function Lib.AbortSlowDialTarget(ent)
	ent.InboundSlowLead = nil;
	ent.InboundSlowReleased = nil;
	ent.InboundSlowReady = nil;
	ent.InboundSlowWaitingSource = nil;
	ent:StopActions();
	ent.OnButtLock = false;
	ent:RunActions(ent.Sequence:DialFail(nil, true));
end

-- Source, at its last chevron lock: lets the destination open. If the destination has not finished its animation, the source pauses
-- its own sequence until Lib.SlowDialBarrier resumes it. Checked every second: shut down if the destination is gone, resumed anyway
-- after the time limit.
function Lib.ReleaseSlowDialTarget(target, source)
	if (not IsValid(target)) then return end
	target.InboundSlowReleased = true;
	target:PauseActions(true, true);
	local ent = source and (source.Entity or source);
	if (target.InboundSlowReady == false and IsValid(ent)) then
		target.InboundSlowWaitingSource = ent;
		ent:PauseActions(false);
		local name, ticks = "_Lib.SlowDialWatchSource_" .. ent:EntIndex(), 0;
		timer.Create(name, 1, 0, function()
			ticks = ticks + 1;
			if (not IsValid(ent)) then timer.Remove(name) return end
			if (IsValid(target) and target.InboundSlowWaitingSource ~= ent) then timer.Remove(name) return end
			if (not IsValid(target) or target.Target ~= ent) then
				timer.Remove(name);
				ent:EmergencyShutdown(true);
			elseif (ticks >= SLOW_DIAL_WAIT_LIMIT) then
				timer.Remove(name);
				target.InboundSlowWaitingSource = nil;
				ent:PauseActions(true);
			end
		end);
	end
end

-- Destination, end of its animation: resumes a source that was waiting for it, or waits for the source's lock if it has not happened
-- yet. Checked every second: the dial is aborted if the source stopped, and the gate opens anyway after the time limit.
function Lib.SlowDialBarrier(gate)
	local ent = gate and (gate.Entity or gate);
	if (not IsValid(ent)) then return end
	ent.InboundSlowReady = true;
	local source = ent.InboundSlowWaitingSource;
	if (IsValid(source)) then
		ent.InboundSlowWaitingSource = nil;
		source:PauseActions(true);
	end
	if (ent.InboundSlowReleased ~= false) then return end
	ent:PauseActions(false);
	local name, ticks = "_Lib.SlowDialWatch_" .. ent:EntIndex(), 0;
	timer.Create(name, 1, 0, function()
		ticks = ticks + 1;
		if (not IsValid(ent) or ent.InboundSlowReleased ~= false) then timer.Remove(name) return end
		local src = ent.Target;
		if (not (IsValid(src) and src.Target == ent and src.Dialling)) then
			timer.Remove(name);
			Lib.AbortSlowDialTarget(ent);
		elseif (ticks >= SLOW_DIAL_WAIT_LIMIT) then
			timer.Remove(name);
			ent.InboundSlowReleased = true;
			ent:PauseActions(true);
		end
	end);
end

function Lib.ReloadedSystemMessage()
	for k, v in pairs(player.GetHumans()) do
		-- The "eap_reload" language key does not exist: the chat showed an error instead of the message.
		v:SendLua("LocalPlayer():ChatPrint(\"Evolution Addon Pack: system successfully reloaded.\")");
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

-- Is this class in the EAP spawn list, with a SpawnFunction of its own?
function Lib.IsEAPSpawnable(EntityName)
	if (EntityName == nil) then return false end
	local found = false;
	for _,v in pairs(list.Get("EAP") or {}) do
		if (v.ClassName == EntityName) then found = true; break; end
	end
	if (not found) then return false end
	local sent = scripted_ents.GetStored(EntityName);
	return (sent and sent.t and sent.t.SpawnFunction) and true or false;
end

-- The sandbox's spawn function calls TryFixPropPosition() after SpawnFunction(), which pushes out anything partly inside the world.
-- Gates are spawned slightly sunk into the ground on purpose, so they came out about 50 units too high. Same steps as the stock
-- function (checks, SpawnFunction, hooks, undo, cleanup) without that repositioning. Other classes go to the stock function.
function EAP_Spawn_SENT(ply, EntityName, tr)
	if (EntityName == nil or not IsValid(ply)) then return end

	if (not Lib.IsEAPSpawnable(EntityName)) then
		local stock = Lib.StockSpawn_SENT or Spawn_SENT;
		if (stock) then stock(ply, EntityName, tr); end
		return;
	end

	local sent = scripted_ents.GetStored(EntityName).t;

	if (sent.AdminOnly and not ply:IsAdmin()) then return end

	if (not gamemode.Call("PlayerSpawnSENT", ply, EntityName)) then return end

	if (not tr) then
		tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos()+(ply:GetAimVector()*4096),
			filter = ply,
		});
	end

	ClassName = EntityName;
	local entity = sent:SpawnFunction(ply, tr, EntityName);
	ClassName = nil;

	if (not IsValid(entity)) then return end

	gamemode.Call("PlayerSpawnedSENT", ply, entity);

	undo.Create("SENT");
		undo.SetPlayer(ply);
		undo.AddEntity(entity);
		if (sent.PrintName) then
			undo.SetCustomUndoText("Undone "..sent.PrintName);
		end
	undo.Finish("Scripted Entity ("..tostring(EntityName)..")");

	ply:AddCleanup("sents", entity);
	entity:SetVar("Player", ply);
end
concommand.Add("eap_spawnsent", function(ply, cmd, args) EAP_Spawn_SENT(ply, args[1]); end);

-- The Entities tab, favourites, console command and creator tool all call the global Spawn_SENT: EAP's classes are sent to the
-- function above. Done on Initialize because the gamemode defines Spawn_SENT after the autorun files.
hook.Add("Initialize", "EAP.SpawnSENTRouting", function()
	if (Lib.StockSpawn_SENT or not isfunction(Spawn_SENT)) then return end
	Lib.StockSpawn_SENT = Spawn_SENT;
	Spawn_SENT = function(ply, EntityName, tr)
		if (IsValid(ply) and Lib.IsEAPSpawnable(EntityName)) then
			return EAP_Spawn_SENT(ply, EntityName, tr);
		end
		return Lib.StockSpawn_SENT(ply, EntityName, tr);
	end
end);

-- Gate dialling this one, for stargateTargetAddress / Group / DialingAddress. FindGate writes the caller's address into the
-- destination's DialledAddress; a copy is taken at that moment and only handed out once the destination has activated itself.
-- A hidden inbound address gives empty strings, like the wire outputs.
--
-- Wrappers already made, so a FindGate is never wrapped twice.
local InboundRecorders = setmetatable({}, { __mode = "k" });
-- Wraps a gate's FindGate to record the source on the destination it found.
function Lib.RecordInboundSource(FindGateReal)
	if (InboundRecorders[FindGateReal]) then return FindGateReal end
	local Recorder = function(self, no_target, ...)
		local result = FindGateReal(self, no_target, ...);
		local dest = self.Target;
		if (not no_target and IsValid(dest) and dest ~= self.Entity and dest.IsStargate) then
			dest.InboundSourceInfo = nil;
			local dialled = dest.DialledAddress;
			local source = self.Entity;
			local address = source:GetGateAddress() or "";
			if (type(dialled) == "table" and #dialled >= 8 and dialled[#dialled] == "DIAL" and address:len() == 6) then
				local first = table.concat(dialled, "", 1, 6);
				if (first == address or first == "") then
					local count = #(self.DialledAddress or {});
					local chevs = (count >= 8 and count <= 10) and count - 1 or 7;
					dest.InboundSourceInfo = {
						source = source,
						address = first,
						group = (first == "") and "" or (source:GetGateGroup() or ""),
						dialing = table.concat(dialled, "", 1, math.min(chevs, #dialled - 1)),
					};
				end
			end
		end
		return result;
	end
	InboundRecorders[Recorder] = true;
	return Recorder;
end

-- The recorded info, or nil while the gate is not an active inbound gate. Kept until the gate is no longer Active, so it also covers
-- the closing animation.
function Lib.GetInboundSourceInfo(dest)
	if (not IsValid(dest) or not dest.IsStargate or dest.Outbound or not dest.Active) then return nil end
	return dest.InboundSourceInfo;
end

-- "address", "group" or "dialing" of the gate dialling dest ("" when there is none).
function Lib.GetInboundSourceField(dest, field)
	local info = Lib.GetInboundSourceInfo(dest);
	return info and info[field] or "";
end

-- Parts of the gate itself, which always touch the horizon.
local function IsGateOrHorizonPart(e, gate, horizon)
	if (e == horizon or e == gate or e == gate.Iris) then return true end
	local c = e:GetClass();
	return string.sub(c, 1, 3) == "sg_" or string.sub(c, 1, 9) == "stargate_" or string.find(c, "eventhorizon", 1, true) ~= nil
		or string.find(c, "event_horizon", 1, true) ~= nil or string.find(c, "kawoosh", 1, true) ~= nil or string.find(c, "iris", 1, true) ~= nil;
end

-- Entities at least partly inside the gate's event horizon (anything still inside when the gate closes is destroyed): those the
-- horizon tracks in its buffers, plus those whose bounding box crosses its thickness within its radius. Parented and non-solid
-- entities are left out. Only uses .IsStargate and .EventHorizon, so it also works on CAP gates.
function Lib.GetEntitiesInHorizon(gate)
	local out = {};
	if (not IsValid(gate) or not gate.IsStargate) then return out end
	local horizon = gate.EventHorizon;
	if (not IsValid(horizon)) then return out end

	local seen = {};
	local function add(e)
		if (IsValid(e) and not seen[e] and not e:IsWorld() and not IsValid(e:GetParent()) and not IsGateOrHorizonPart(e, gate, horizon)) then
			seen[e] = true;
			out[#out + 1] = e;
		end
	end

	for _, buffer in ipairs({ horizon.AllBuffer, horizon.Buffer, horizon.ClipBuffer }) do
		if (istable(buffer)) then
			for _, e in pairs(buffer) do
				if (isentity(e)) then add(e) end
			end
		end
	end

	local thickness = math.max(horizon:OBBMaxs().x, -horizon:OBBMins().x, 20) + 10;
	local radius = horizon:BoundingRadius();
	for _, e in ipairs(ents.FindInSphere(horizon:GetPos(), radius + 300)) do
		if (not seen[e] and IsValid(e) and not e:IsWorld() and e:GetSolid() ~= SOLID_NONE and not IsValid(e:GetParent())
			and not IsGateOrHorizonPart(e, gate, horizon)) then
			local a, b = e:OBBMins(), e:OBBMaxs();
			local minx, maxx, near = math.huge, -math.huge, false;
			for _, x in ipairs({ a.x, b.x }) do
				for _, y in ipairs({ a.y, b.y }) do
					for _, z in ipairs({ a.z, b.z }) do
						local l = horizon:WorldToLocal(e:LocalToWorld(Vector(x, y, z)));
						if (l.x < minx) then minx = l.x end
						if (l.x > maxx) then maxx = l.x end
						if (l.y * l.y + l.z * l.z < radius * radius) then near = true end
					end
				end
			end
			if (near and minx < thickness and maxx > -thickness) then add(e) end
		end
	end
	return out;
end
