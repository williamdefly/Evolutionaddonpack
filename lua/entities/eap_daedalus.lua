-- Prop Credit goes to MadMan07 ( Carter Addon Packs )

ENT.Base = "eap_base"
ENT.Type = "vehicle"

ENT.PrintName = "Daedalus"
ENT.Author = ""
ENT.Spawnable = true
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.Model = Model("models/ships/madman07/daedalus/daedalus.mdl")

ENT.Sounds = {
	Staff=Sound("eap/ship/armes/asgardflak.wav");
	Missile = Sound("f302/Missile_Shoot_Small.wav");
}

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(ply:GetCount("CAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("eap_daedalus")
	e:SetPos(tr.HitPos + Vector(0,0,180))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("CAP_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex
	self.BaseClass.Initialize(self);
	self.Vehicle = "daedalus"
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
				timer.Create("OneillCanShoot"..self.Pilot:EntIndex(),self.TimeBetweenEachShoot,1,function()
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
	if timer.Exists("OneillCanShoot"..self:EntIndex()) then timer.Destroy("OneillCanShoot"..self:EntIndex()); end
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
	local FiringPos = self:GetPos()+(self:GetForward()*1000);
	local ShootDir = FiringPos:GetNormal();

	local trace = {}
		trace.start = self:GetAngles():Forward()*50;
		trace.endpos = self:GetAngles():Forward()*250;
	local tr = util.TraceLine( trace );
	if(self.CanShootRails) then
			local ShootDir = (target - self:GetPos()):GetNormal();
			local ent = ents.Create("energy_beam2");
			ent.Owner = self.Entity;
			ent:SetPos(FiringPos);
			ent:Spawn();
			ent:Activate();
			ent:SetOwner(self.Entity);
			ent:Setup(FiringPos, ShootDir, 1200, 1.5, "Asgard");
		self:EmitSound(Sound("eap/ship/armes/asgardcanonbeam.mp3"),100,math.random(98,102))
		self.CanShootRails = false
		timer.Create("CanFire"..self:EntIndex().."Rails",self.TimeBetweenEachRails,0,function()
			if(!self.CanShootRails)then
				self.CanShootRails = true
			end
		end)
	end
end

function ENT:FireBlast(diff)

/* Missile launch */
		ent = ents.Create("302missile");
		ent.Parent = self;
		ent:SetPos(self:GetPos()+self:GetUp()*50);
		ent:SetAngles(self:GetAngles());
		ent:Spawn();
		ent:Activate();
		ent:SetVelocity(Vector(0,0,1)*self.MissileMaxVel);
		ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
		ent:SetOwner(self.Entity);
		ent:EmitSound(self.Sounds.Missile,100,100);
		timer.Simple( 0.2, function() if (IsValid(ent)) then ent:SetVelocity(ent:GetForward()*self.MissileMaxVel); end end)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "eap_daedalus", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.PrintName = "Daedalus";
ENT.Category = "Vaisseaux";
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (StarGate==nil or StarGate.KeyBoard==nil or StarGate.KeyBoard.New==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("daedalus")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A")
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D")
KBD:SetDefaultKey("BACK",StarGate.KeyBoard.BINDS["+back"] or "S")
KBD:SetDefaultKey("UP",StarGate.KeyBoard.BINDS["+jump"] or "SPACE")
KBD:SetDefaultKey("DOWN",StarGate.KeyBoard.BINDS["+duck"] or "CTRL")
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT")
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1")
KBD:SetDefaultKey("TRACK",StarGate.KeyBoard.BINDS["+attack2"] or "MOUSE2")
--Special Actions
KBD:SetDefaultKey("BOOM","BACKSPACE")
--View
KBD:SetDefaultKey("VIEW","1")
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")

KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("eap/ship/moteur/bc304.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "daedalus"
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
		if(p:KeyDown("daedalus","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("daedalus","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("daedalus","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("daedalus","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("daedalus","A-")) then
			self.UDist=self.UDist-5
		end
	end
end