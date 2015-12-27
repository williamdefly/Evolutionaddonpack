

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.PrintName = "Stargate Vehicle Base"
ENT.Author = "RononDex"
ENT.Base = "base_anim"
ENT.Type = "vehicle"
ENT.Category = "Stargate Carter Addon Pack: Ships"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsSGVehicle = true;

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile();

ENT.NextExit = CurTime();
ENT.num = 0;
ENT.num2 = 0;
ENT.num3 = 0;
ENT.Roll = 0;
ENT.Accel = {
	FWD = 0;
	RIGHT = 0;
	UP = 0;
};
ENT.CanUse = true;
// ENT.Passengers = {
// 	Seat1 = nil,
// 	Seat2 = nil,
// 	Seat3 = nil,
// 	Seat4 = nil,
// }
// ENT.CanHavePassengers = false
// ENT.MaxPassengers = 1

ENT.WeaponsTable={}; --Make the table for weapons out here, this when a player enters stores there weapons which we give back when they exit

function ENT:Initialize()

	self:SetModel(self.Model);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:StartMotionController();
	self.HoverPos = self:GetPos();

	self.EntitiesNotAllowed = {
		"launcher_drones",
		"sg_turret_destmain",
		"sg_turret_destmed",
		"sg_turret_destsmall",
		"sg_turret_shiprail",
		"sg_turret_tollan",
		"sg_turret_deadalus",
		"sg_turret_base",
		"aschen_defence",
		"asgard_beam",
		"ori_beam_cannon"
	}
end

function ENT:Bang(p) --######## The effect, and killing the player if they're flying @RononDex

	self:EmitSound(Sound("jumper/JumperExplosion.mp3"),100,100); --Play the jumper's explosion sound(Only good explosion sound i have)
	local ang = Angle(math.Rand(115,255), math.random(0,360), 0)
	local fx = EffectData();
		fx:SetMagnitude(100)
		fx:SetAngles(ang)
		fx:SetOrigin(self.Entity:GetPos())
	util.Effect("dirtyxplo",fx);

	if(self.Inflight) then
		self:Exit(true); --Let the player out...
	end
	self.Done = true;
	self:Remove(); --Get rid of the vehicle

end

function ENT:OnRemove(p)
	timer.Destroy(self.Entity:GetClass()..self.Entity:EntIndex().."HaveOtherWeapons");
	if (self.EngineSound) then
		self.EngineSound:Stop();
	end
	if(self.Inflight and not self.Done) then
		self:Exit(); -- Let the player out
	end
end

--####### Standard stargate vehicle stuff @RononDex
function ENT:Think()

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(self.Vehicle,"BOOM")) then
				self:Bang(); return
			end

			if(self.NextExit<CurTime()) then
				if(self.Pilot:KeyDown(self.Vehicle,"EXIT")) then
					self.NextExit = CurTime()+1;
					self:Exit();
				end
			end
		end
	end

	if(self.RunningAnim) then
		self:NextThink(CurTime());
		return true;
	end

	if !timer.Exists(self.Entity:GetClass()..self.Entity:EntIndex().."HaveOtherWeapons") then
		timer.Create(self.Entity:GetClass()..self.Entity:EntIndex().."HaveOtherWeapons",2.5,0,function()
			local count = false;
			for _, Entity in pairs( constraint.GetAllConstrainedEntities(self.Entity) ) do
				for i,v in pairs(self.EntitiesNotAllowed) do
					if Entity:GetClass() == v then
						Entity:Remove()
						count = true
					end
				end
			end
			if count then
				self.Owner:ChatPrint(Entity:GetClass().." Ce vaisseau est déjà armé")
			end
		end)
	end
end

function ENT:Enter(p) --####### Get in @RononDex

	if(not(self.Inflight) and self.CanUse) then
		p:SetNetworkedEntity(self.Vehicle,self); --Set a networked entity as the name of the vehicle
		p:SetNetworkedBool("Flying"..self.Vehicle,true); --Set a bool on the player
		p:Spectate(OBS_MODE_CHASE); --Spectate the vehicle
		p:DrawWorldModel(false);
		p:DrawViewModel(false);
		p:SetMoveType(MOVETYPE_OBSERVER);
		p:SetCollisionGroup(COLLISION_GROUP_WEAPON);
		for _,v in pairs(p:GetWeapons()) do
			table.insert(self.WeaponsTable, v:GetClass());
		end
		p:StripWeapons();
		self.PlayerHealth=p:Health();
		if(p:FlashlightIsOn()) then
			p:Flashlight(false); --Turn the player's flashlight off when Flying
		end
		--p:SetScriptedVehicle(self);
		p:SetNetworkedEntity("ScriptedVehicle", self)
		p:SetViewEntity(self)
		self:GetPhysicsObject():Wake();
		self:GetPhysicsObject():EnableMotion(true); --UnFreeze us
		if(self.ShouldRotorwash) then
			self:Rotorwash(true);
		end
		self.Inflight = true;
		self.Pilot = p;
		self.NextExit = CurTime()+1;
	end
end

function ENT:Exit(kill) --####### Get out @RononDex

	if (IsValid(self.Pilot)) then
		StarGate.KeyBoard.ResetKeys(self.Pilot,self.Vehicle);
		self.Pilot:UnSpectate();
		self.Pilot:DrawViewModel(true);
		self.Pilot:DrawWorldModel(true);
		self.Pilot:Spawn();
		self.Pilot:SetNetworkedBool("Flying"..self.Vehicle,false);
		self.Pilot:SetPos(self.ExitPos or self:GetPos());
		self.Pilot:SetParent();
		self.Pilot:SetMoveType(MOVETYPE_WALK);
		self.Pilot:SetCollisionGroup(COLLISION_GROUP_PLAYER);
	end
	if(self.ShouldRotorwash) then
		self:Rotorwash(false);
	end
	self.Inflight = false;
	self:SetNetworkedEntity(self.Vehicle,nil);
	if (IsValid(self.Pilot)) then
		--self.Pilot:SetScriptedVehicle(NULL);
		self.Pilot:SetNetworkedEntity( "ScriptedVehicle", NULL )
		self.Pilot:SetViewEntity( NULL )
		self.Pilot:SetHealth(self.PlayerHealth);
		for _,v in pairs(self.WeaponsTable) do
			self.Pilot:Give(tostring(v));
		end
		if (kill) then self.Pilot:Kill(); end
	end
	self.Pilot = NULL;
	self.Accel.FWD = 0;
	self.Accel.RIGHT = 0;
	self.Accel.UP = 0;
	table.Empty(self.WeaponsTable); --Get rid of our old weapons
	self.HoverPos = self:GetPos();
end

function ENT:Use(p) --####### When you press E on it @RononDex

	if(not(self.CanUse)) then return end;

	if(not(self.Inflight)) then
		self:Enter(p); --Get in
	/*else
		if (self.CanHavePassengers) then
			if (self.Passengers:Length() < self.MaxPassengers) then
				
			end
		end*/
	end
end

local FlightPhys={ -- Make the table of constants out here, to stop creating garbage.
	secondstoarrive	= 1;
	maxangular		= 9000;
	maxangulardamp	= 1000;
	maxspeed			= 1000000;
	maxspeeddamp		= 500000;
	dampfactor		= 1;
	teleportdistance	= 5000;
};
local ZAxis = Vector(0,0,1);
function ENT:PhysicsSimulate( phys, deltatime )--############## Flight code@ RononDex
	local FWD = self.Entity:GetForward();
	local UP = ZAxis;
	local RIGHT = FWD:Cross(UP):GetNormalized();

	if(self.Inflight and IsValid(self.Pilot)) then
		-- Accelerate
		if not self.AirBrake and not self.Boost then
			if((self.Pilot:KeyDown(self.Vehicle,"FWD"))and(self.Pilot:KeyDown(self.Vehicle,"SPD"))) then
				self.num = self.MaxSpeed;
				self.Entity:SetSkin(0);
			elseif((self.Pilot:KeyDown(self.Vehicle,"FWD"))) then
				self.num = self.ForwardSpeed;
				self.Entity:SetSkin(0);
			elseif(self.Pilot:KeyDown(self.Vehicle,"BACK")) then
				self.num = self.BackwardSpeed;
			else
				self.Entity:SetSkin(1);
				self.num = 0;
			end
		end
		self.Accel.FWD = math.Approach(self.Accel.FWD,self.num,self.Accel.SpeedForward);

		-- Strafe
		if(self.GoesRight) then
			if(self.Pilot:KeyDown(self.Vehicle,"RIGHT")) then
				self.num2 = self.RightSpeed;
			elseif(self.Pilot:KeyDown(self.Vehicle,"LEFT")) then
				self.num2 = -self.RightSpeed;
			else
				self.num2 = 0;
			end
		end
		self.Accel.RIGHT = math.Approach(self.Accel.RIGHT,self.num2,self.Accel.SpeedRight);

		-- Up and Down
		if(self.GoesUp) then
			if(self.Pilot:KeyDown(self.Vehicle,"UP")) then
				self.num3 = self.UpSpeed;
			elseif(self.Pilot:KeyDown(self.Vehicle,"DOWN")) then
				self.num3 = -self.UpSpeed;
			else
				self.num3 = 0;
			end
		end
		self.Accel.UP = math.Approach(self.Accel.UP,self.num3,self.Accel.SpeedUp);

		if(self.CanRoll and not self.LandingMode) then
			if(self.Pilot:KeyDown(self.Vehicle,"RL")) then
				self.Roll = self.Roll - 5;
			elseif(self.Pilot:KeyDown(self.Vehicle,"RR")) then
				self.Roll = self.Roll + 5;
			elseif(self.Pilot:KeyDown(self.Vehicle,"RROLL")) then
				self.Roll = 0;
			end
		end

		phys:Wake();
		if(not(self.Hover)) then
			if self.Accel.FWD>-200 and self.Accel.FWD < 200 then return end; --with these you float and won't move
			if(self.GoesUp) then
				if self.Accel.UP>-200 and self.Accel.UP < 200 then return end;
			end
			if(self.GoesRight) then
				if self.Accel.RIGHT>-200 and self.Accel.RIGHT < 200 then return end;
			end
		end

		local pos = self:GetPos();

		--######### Do a tilt when turning, due to aerodynamic effects @aVoN
		local velocity = self:GetVelocity();
		local aim = self.Pilot:GetAimVector();
		local ang = aim:Angle();
		local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(pos + aim).y)),-25,25); -- Extra-roll - When you move into curves, make the shuttle do little curves too according to aerodynamic effects
		local mul = math.Clamp((velocity:Length()/1700),0,1); -- More roll, if faster.
		local oldRoll = ang.Roll;
		ang.Roll = (ang.Roll + self.Roll - ExtraRoll*mul) % 360;
		if (ang.Roll!=ang.Roll) then ang.Roll = oldRoll; end -- fix for nan values what cause despawing/crash.

		if(self.Pilot:KeyDown(self.Vehicle,"LAND")) then
			self.LandingMode = true;
			self:SetAngles(Angle(0,self:GetAngles().Yaw,self.Roll));
		else
			self.LandingMode = false;
		end

		--##### Calculate our new angles and position based on speed
		if(not(self.LandingMode)) then
			FlightPhys.angle = ang; --+ Vector(90 0, 0)
		end
		FlightPhys.deltatime = deltatime;
		FlightPhys.pos = self:GetPos()+(FWD*self.Accel.FWD)+(UP*self.Accel.UP)+(RIGHT*self.Accel.RIGHT);

		self.Pilot:SetPos(pos);
		phys:ComputeShadowControl(FlightPhys);
	end
	if (not self.Inflight and self.HoverAlways) then
		phys:Wake();
		FlightPhys.angle = Angle(0, self:GetAngles().y, 0);
		FlightPhys.deltatime = deltatime;
		FlightPhys.pos = self.HoverPos;
		phys:ComputeShadowControl(FlightPhys);
	end
end


--############## Collison Dammage @ WeltEntSturm
function ENT:PhysicsCollide(cdat, phys)

	if cdat.DeltaTime > 0.5 then --0.5 seconds delay between taking physics damage
		local mass = (cdat.HitEntity:GetClass() == "worldspawn") and 1000 or cdat.HitObject:GetMass(); --if it's worldspawn use 1000 (worldspawns physobj only has mass 1), else normal mass
		self:TakeDamage((cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 1000))/9000000);
		if((self.Accel.FWD or self.Accel.RIGHT or self.Accel.UP)>500) then
			self.Accel.FWD = math.Approach(self.Accel.FWD,0,30);
		end
	end
end


 --################# After teleporting it, fix the angles of a player @aVoN
function ENT.FixAngles(self,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	-- Move a players view
	local diff = Angle(0,ang_delta.y+180,0);
	if(IsValid(self.Pilot)) then
		self.Pilot:SetEyeAngles(self.Pilot:GetAimVector():Angle() + diff);
	end
end

-- damn, this not work with mask...
for k,v in pairs({sg_vehicle_dart,"sg_vehicle_gate_glider","sg_vehicle_glider","sg_vehicle_shuttle","sg_vehicle_f302","sg_vehicle_teltac","eap_destiny","eap_cruiser","eap_alkesh"}) do
	StarGate.Teleport:Add(v,ENT.FixAngles);
end

--########## Run the anim that's set in the arguements @RononDex
function ENT:Anims(e,anim,playback_rate,delay,nosound,sound)

	if(e.CanDoAnim) then
		self:NextThink(CurTime());
		e.CanDoAnim = false;
		e.RunningAnim = true;
		e.Anim = e:LookupSequence(anim); -- The anim, set anim as the name of the anim in a string in the arguements
		if(not(nosound)) then --Set false to allow sound
			e:EmitSound(Sound(sound),100,100); --create sound as a string in the arguements
		end
		--e:SetPlaybackRate(0.00001);
		e:SetSequence(e.Anim); -- play the sequence
		--e:Fire("setanimation",anim,"0")
		timer.Simple(delay,function() --How long until we can do the anim again?
			e.CanDoAnim = true;
			e.RunningAnim = false;
		end);
	end
end

function ENT:Rotorwash(b) --########## Toggle the rotorwash @RononDex

	if(b) then
		local e = ents.Create("env_rotorwash_emitter");
		e:SetPos(self:GetPos());
		e:SetParent(self);
		e:Spawn();
		e:Activate();
		self.RotorWash = e;
	else
		if(IsValid(self.RotorWash)) then
			self.RotorWash:Remove();
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_ships_max"):GetInt()
		if(ply:GetCount("CAP_ships")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			Ent:Remove();
			return
		end
		ply:AddCount("CAP_ships", Ent);
		Ent.Owner = ply;
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

function playerDies( victim, weapon, killer )
	if (IsValid(victim:GetNetworkedEntity("ScriptedVehicle", NULL))) then
          local veh = victim:GetNetworkedEntity("ScriptedVehicle", NULL);
          if (veh:GetClass()!="puddle_jumper" and veh:GetClass()!="sg_vehicle_daedalus" and veh.Bang) then
			veh:Bang();
          end
     end
end
hook.Add( "PlayerDeath", "SG.VEH.playerDies", playerDies )
hook.Add( "PlayerSilentDeath", "SG.VEH.playerDies", playerDies )

end

if CLIENT then

function ENT:Initialize( )
	--self:SetShouldDrawInViewMode( true )
	self.FXEmitter = ParticleEmitter( self:GetPos())
	self.SoundsOn = {}
	if (self.Sounds and self.Sounds.Engine) then
		self.EngineSound = self.EngineSound or CreateSound(self.Entity,self.Sounds.Engine);
	end
end

function SGVehBaseCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	local p = Player
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((self)and(self:IsValid()) and self.IsSGVehicle and not self.IsSGVehicleCustomView) then
		local pos = self:GetPos()+self:GetUp()*self.UDist+LocalPlayer():GetAimVector():GetNormal()*self.Dist
		local face = ( ( self:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle()
			view.origin = pos
			view.angles = face
		return view
	end
end
hook.Add("CalcView", "SGVehBaseCalcView", SGVehBaseCalcView)

function ENT:Draw()
	self:DrawModel()
end

function ENT:CreateHyperspaceWindow(pos,angle,scale)
	local e = ents.Create("hyperspace_window")
	e:SetPos(pos)
	e:SetAngles(angle)
	e:Spawn()
	e:Activate()
	timer.Create("WindowOpenAnimation"..self:EntIndex(),0.0001,30,function()
		e:SetModelScale(e:GetModelScale()+scale)
	end)
	return e
end

function ENT:CloseHyperspaceWindow(entity)
	entity:EmitSound(Sound("/eap/hyperespace/hyper_window_close.wav"))
	timer.Create("WindowCloseAnimation"..self:EntIndex(),0.0001,32,function()
		entity:SetModelScale(self:GetModelScale()-0.5)
	end)
	timer.Create("WindowRemove"..self:EntIndex(),1,1,function()
		entity:Remove()
	end)
end

function ENT:HyperspaceAccelerate()
	local forward = self.Entity:GetForward()
	local speed = 150
	local angles = self.Entity:GetAngles()
	local increment = 2
	timer.Create("HyperspaceAccelerate"..self:EntIndex(),0.000001,50,function()
		self.Entity:SetAngles(angles)
		self.Entity:SetPos(self:GetPos()+(forward*speed))
	end)
end

function ENT:HyperspaceDeaccelerate()
	local forward = self:GetForward()
	local speed = 150
	local angles = self:GetAngles()
	local increment = 102
	timer.Create("HyperspaceDeaccelerate"..self:EntIndex(),0.000001,50,function()
		self.Entity:SetAngles(angles)
		self.Entity:SetPos(self:GetPos()+(forward*speed))
	end)
end

function ENT:HyperspaceTeleport(position,angle)
	self:SetPos(position)
	self:SetAngles(angle)
end

function ENT:Think()

	local p = LocalPlayer()
	local IsDriver = (p:GetNetworkedEntity(self.Vehicle,NULL) == self.Entity);
	local IsFlying = p:GetNWBool("Flying"..self.Vehicle,false);

	--######### Handle engine sound
	if(IsFlying) then
		-- Normal behaviour for Pilot or people who stand outside
		self:StartClientsideSound("Engine");
		--#########  Now add Pitch etc
		local velo = self.Entity:GetVelocity();
		local pitch = self.Entity:GetVelocity():Length();
		local doppler = 0;
		-- For the Doppler-Effect!
		if(not IsDriver) then
			-- Does the vehicle fly to the player or away from him?
			local dir = (p:GetPos() - self.Entity:GetPos());
			doppler = velo:Dot(dir)/(150*dir:Length());
		end
		if(self.SoundsOn.Engine) then
			self.EngineSound:ChangePitch(math.Clamp(60 + pitch/25,75,100) + doppler,0);
		end
	else
		self:StopClientsideSound("Engine");
	end
end

--################# Starts a sound clientside @aVoN
function ENT:StartClientsideSound(mode)
	if(not self.SoundsOn[mode]) then
		if(mode == "Engine" and self.EngineSound) then
			self.EngineSound:Stop();
			self.EngineSound:SetSoundLevel(90);
			self.EngineSound:PlayEx(1,100);
		end
		self.SoundsOn[mode] = true;
	end
end

--################# Stops a sound clientside @aVoN
function ENT:StopClientsideSound(mode)
	if(self.SoundsOn[mode]) then
		if(mode == "Engine" and self.EngineSound) then
			self.EngineSound:FadeOut(2);
		end
		self.SoundsOn[mode] = nil;
	end
end
function PrintHUD()
	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local vehicle = p:GetNWEntity("GateGlider")
	if(IsValid(self)) then
		if((IsValid(vehicle))and(vehicle==self)) then
			if(vehicle:GetModel()!="models/Iziraider/gateglider/gateglider.mdl")then

				local texture = "vgui/hud/hud_nav/j_hud"
				local vehicleType = "default"

				local EntHealth = vehicle:GetNWInt("maxEntHealth",-1)
				local EntShields = vehicle:GetNWInt("maxEntShields",-1)
				local health = math.Round(vehicle:GetNWInt("health",-1)/EntHealth*100) -- test fix
				local shields = math.Round(vehicle:GetNWInt("shields",-1)/EntShields*100)
				local texture = surface.GetTextureID(texture)
				local CanFire = vehicle:GetNWInt("CanFire",-1)
				local x = ScrW()/4*0;
				local y = ScrH()/4*3;
				local w = ScrW()*0.99;
				local h = (w/4096)*512*(3/4);

				local font = {
					font = "Default",
					size = (w/1024)*30,
					weight = 400,
					antialias = true,
					additive = false,
				}
				surface.CreateFont("JumperFont", font);


				local hudpos = {
					healthw = (ScrW()/10*0.75),
					healthh = (ScrH()/10*8),
					weaponsdw = (ScrW()/10*7.5),
					weaponsdh = (ScrH()/10*8),
					shieldsdw = (ScrW()/10*2.5),
					shieldsdh = (ScrH()/10*2),
				}


				surface.SetTexture(texture)
				surface.SetDrawColor(255,255,255,255) -- Colour of the HUD
				surface.DrawTexturedRect(x,y,w,h) -- Position, Size

				if(CanFire==1)then
					draw.WordBox(8,hudpos.weaponsdw, hudpos.weaponsdh, "Armes: Activées", "JumperFont", Color(50,50,75,0), Color(0,255,0,255))
				elseif CanFire == 0 then
					draw.WordBox(8,hudpos.weaponsdw-20, hudpos.weaponsdh, "Armes: "..math.Round(vehicle:GetNWInt("WeaponsTimer",0)).." Secondes", "JumperFont", Color(50,50,75,0), Color(255,0,0,255))
				elseif CanFire == 3 then
					draw.WordBox(8,hudpos.weaponsdw-20, hudpos.weaponsdh, "Armes: Détruites", "JumperFont", Color(50,50,75,0), Color(255,0,0,255))
				elseif CanFire == -1 then
					draw.WordBox(8,hudpos.weaponsdw, hudpos.weaponsdh, "Aucune Arme détécté", "JumperFont", Color(50,50,75,0), Color(255,255,255,255))
				end
				if health != -1 then
					if health > 50 then
						draw.WordBox(8,hudpos.healthw,hudpos.healthh, "Vie: "..health.."%","JumperFont",Color(50,50,75,0), Color(0,255,0,255))
					elseif health <=50 then
						draw.WordBox(8,hudpos.healthw,hudpos.healthh, "Vie: "..health.."%","JumperFont",Color(50,50,75,0), Color(255,135,0,255))
					elseif health <= 25 then
						draw.WordBox(8,hudpos.healthw,hudpos.healthh, "Vie: "..health.."%","JumperFont",Color(50,50,75,0), Color(255,0,0,255))
					end
				end
			end
		end
	end
end
//hook.Add("HUDPaint","ShipsHUD",PrintHUD)


end