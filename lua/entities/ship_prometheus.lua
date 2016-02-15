ENT.Base = "ship_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage('ent_ship_prometheus');
ENT.Author = ""
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/ship/petheship.mdl")


function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("Count_ships_max"):GetInt()
	if(ply:GetCount("Count_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("ship_prometheus")
	e:SetPos(tr.HitPos + Vector(0,0,180))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("Count_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex
	self.BaseClass.Initialize(self);
	self.Vehicle = "Promethee"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 25000
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetNetworkedInt("maxEntHealth",self.EntHealth)
	self:SetNWInt("CanFire",1)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()

	--####### Attack vars
	self.LastBlast=0
	self.CanShoot = true
	self.CanShootRails = true
	self.TimeBetweenEachShoot = 2
	self.TimeBetweenEachRails = 3
	self.TrackTime = 0

	--######### Flight Vars
	self.Accel = {}
	self.Accel.FWD = 0
	self.Accel.RIGHT = 0
	self.Accel.UP = 0
	self.ForwardSpeed = 1500
	self.BackwardSpeed = -750
	self.UpSpeed=600
	self.MaxSpeed = 2000
	self.RightSpeed = 750
	self.Accel.SpeedForward = 10
	self.Accel.SpeedRight = 7
	self.Accel.SpeedUp = 7
	self.RollSpeed = 5
	self.num = 0
	self.num2 = 0
	self.num3 =0
	self.Roll=0
	self.Hover=true
	self.GoesRight=true
	self.GoesUp=true
	self.CanRoll=true
	self:CreateWireOutputs("Health");
	self.MissileMaxVel=10000000

	self.Target = Vector(0,0,0)

	local phys = self:GetPhysicsObject()
	self:GetPhysicsObject():EnableMotion(false)
	

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
	
	self.CanPrimary = true

end

function ENT:Think()

	self.BaseClass.Think(self);
	self.ExitPos = self:GetPos()+self:GetForward()*75;

	if(IsValid(self.Pilot)) then
		if(self.Pilot:KeyDown(self.Vehicle,"FIRE")) then
			if(self.CanShoot) then
				self:FireBlast(self:GetRight()*80);
				self:FireBlast(self:GetRight()*-80);
			self.CanShoot = false
				timer.Create("PtCanShoot"..self.Pilot:EntIndex(),self.TimeBetweenEachShoot,1,function()
					self.CanShoot = true
				end)
			end
		end
		if(self.Pilot:KeyDown(self.Vehicle,"TRACK"))then
			if(self.CanShootRails) then
				local trace = {}
					trace.start = self.Pilot:GetPos();
					trace.endpos = self.Pilot:GetAimVector() * 10^14;
					trace.filter = {self.Entity, self.Pilot};
				local tr = util.TraceLine(trace);
				self:FireRails(tr.HitPos);
			end
		end
	end
end

function ENT:OnRemove()
	if timer.Exists("CanFire"..self:EntIndex().."Rails") then timer.Destroy("CanFire"..self:EntIndex().."Rails"); end
	if timer.Exists("PtCanShoot"..self:EntIndex()) then timer.Destroy("PtCanShoot"..self:EntIndex()); end
	self.BaseClass.OnRemove(self)
end

function ENT:OnTakeDamage(dmg) --########## Gliders aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if((health-dmg:GetDamage())<=0) then
		self:Bang() -- Go boom
	end
end

function ENT:FireRails(target)

	if(self.CanPrimary) then
		bullet = {}
		bullet.Num=1
		bullet.Src=self.Entity:GetPos()+self:GetUp()*50+Vector( 0, -10, 0 )
		bullet.Dir=self:GetForward()-self:GetUp()-self:GetPos():GetNormalized();
		bullet.Spread=Vector(0.04,0.04,0)
		bullet.Tracer=1
		bullet.Force=1
		bullet.Damage=12
		bullet.TracerName = "AirboatGunTracer"

		self.Entity:FireBullets(bullet)
		
		bullet2 = {}
		bullet2.Num=1
		bullet2.Src=self.Entity:GetPos()+self:GetUp()*50+Vector( 0, -10, 0 )
		bullet2.Dir=self:GetForward()-self:GetUp()-self:GetPos():GetNormalized();
		bullet2.Spread=Vector(0.04,0.04,0)
		bullet2.Tracer=1
		bullet2.Force=1
		bullet2.Damage=12
		bullet2.TracerName = "AirboatGunTracer"

		self.Entity:FireBullets(bullet2)

		self.Entity:EmitSound("eap/ship/armes/heavyrail.wav") 
		
		self.CanPrimary = false
				
		timer.Simple(0.1,function() self.CanPrimary = true end)
		
	end
	
end

function ENT:FireBlast(diff)
	/* Missile launch */
	ent = ents.Create("prometheus_missile");
	ent.Parent = self;
	ent:SetPos(self:GetPos()+self:GetUp()*50);
	ent:SetAngles(self:GetAngles());
	ent:Spawn();
	ent:Activate();
	ent:StopSound("weapons/drone_flyby.mp3"); //Stop Drone Sound @Elanis
	ent:SetVelocity(Vector(0,0,1)*self.MissileMaxVel);
	ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	ent:SetOwner(self.Entity);
	ent:EmitSound("eap/ship/armes/firemissile2.wav",100,100);
	timer.Simple( 0.2, function() if (IsValid(ent)) then ent:SetVelocity(ent:GetForward()*self.MissileMaxVel); end end)
end

end

if CLIENT then

ENT.PrintName = Lib.Language.GetMessage('ent_ship_prometheus');
ENT.Category = Lib.Language.GetMessage('cat_ship');
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (Lib==nil or Lib.KeyBoard==nil or Lib.KeyBoard.New==nil) then return end

--########## Keybinder stuff
local KBD = Lib.KeyBoard:New("Promethee")
--Navigation
KBD:SetDefaultKey("FWD",Lib.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("LEFT",Lib.KeyBoard.BINDS["+moveleft"] or "A")
KBD:SetDefaultKey("RIGHT",Lib.KeyBoard.BINDS["+moveright"] or "D")
KBD:SetDefaultKey("BACK",Lib.KeyBoard.BINDS["+back"] or "S")
KBD:SetDefaultKey("UP",Lib.KeyBoard.BINDS["+jump"] or "SPACE")
KBD:SetDefaultKey("DOWN",Lib.KeyBoard.BINDS["+duck"] or "CTRL")
KBD:SetDefaultKey("SPD",Lib.KeyBoard.BINDS["+speed"] or "SHIFT")
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",Lib.KeyBoard.BINDS["+attack"] or "MOUSE1")
KBD:SetDefaultKey("TRACK",Lib.KeyBoard.BINDS["+attack2"] or "MOUSE2")
--Special Actions
KBD:SetDefaultKey("BOOM","BACKSPACE")
--View
KBD:SetDefaultKey("VIEW","1")
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")

KBD:SetDefaultKey("EXIT",Lib.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("eap/ship/moteur/bc303.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "Promethee"
end

--[[

function SGGGCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	--self.BaseClass.CalcView(self,Player, Origin, Angles, FieldOfView)
	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if(IsValid(self) and self:GetClass()=="sg_vehicle_gate_glider") then
		if(self.FirstPerson) then
			local pos = self:GetPos()+self:GetUp()*20+self:GetForward()*70;
			local angle = self:GetAngles( );
				view.origin = pos		;
				view.angles = angle;
				view.fov = FieldOfView + 20;
			return view;
		else
			local pos = self:GetPos()+self:GetUp()*self.Udist+Player:GetAimVector():GetNormal()*-self.Dist;
			local face = ( ( self.Entity:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle() + Angle(0,180,0);
				view.origin = pos;
				view.angles = face;
			return view;
		end
	end
end
hook.Add("CalcView", "SGGGCalcView", SGGGCalcView)
]]--

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local GateGlider = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((GateGlider)and((GateGlider)==self)and(GateGlider:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((GateGlider)and((GateGlider)==self)and(GateGlider:IsValid())) then
		if(p:KeyDown("Promethee","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Promethee","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Promethee","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("Promethee","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Promethee","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

/*if(CLIENT)then

local ATTACHMENTS = {"EngineR","EngineL"};

	function ENT:Effects(b)

		local p = LocalPlayer();
		if(not b) then return end;
		local prometheus = p:GetNetworkedEntity("ScriptedVehicle", NULL);
		local roll = math.Rand(-90,90);
		local normal = (self.Entity:GetForward() * -1):GetNormalized();
		local drawfx;

		if Boost then return end;

		for k,v in pairs(ATTACHMENTS) do
			local attach = self:GetAttachment(self:LookupAttachment(v));
			local pos = attach.Pos;

			if((prometheus)and(prometheus:IsValid()and(prometheus==self))) then
				if(v=="EngineR" and p.MissilesDisabled) then
					drawfx = false;
				else
					drawfx = true;
				end
				if((p:KeyDown("prometheus","FWD")) and drawfx) then


						local aftbrn = self.FXEmitter:Add("effects/fire_cloud1",pos);
						aftbrn:SetVelocity(normal*2);
						aftbrn:SetDieTime(0.1);
						aftbrn:SetStartAlpha(255);
						aftbrn:SetEndAlpha(100);
						aftbrn:SetStartSize(30);
						aftbrn:SetEndSize(9);
						aftbrn:SetColor(math.Rand(220,255),math.Rand(220,255),185);
						aftbrn:SetRoll(roll);

						local aftbrn2 = self.FXEmitter:Add("sprites/orangecore1",pos);
						aftbrn2:SetVelocity(normal*2);
						aftbrn2:SetDieTime(0.1);
						aftbrn2:SetStartAlpha(255);
						aftbrn2:SetEndAlpha(100);
						aftbrn2:SetStartSize(30);
						aftbrn2:SetEndSize(9);
						aftbrn2:SetColor(math.Rand(220,255),math.Rand(220,255),185);
						aftbrn2:SetRoll(roll);
				end
			end
		end
		self.FXEmitter:Finish();
	end

	function ENT:Draw()

		local vehicle = LocalPlayer():GetNetworkedEntity("ScriptedVehicle", NULL);

		self.BaseClass.Draw(self);

		if(IsValid(vehicle)and(vehicle==self))then

		self:Effects(true);
		else
		
		self.Effects(false);
		
		end

	end
*/
