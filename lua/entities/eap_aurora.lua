ENT.Base = "eap_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage("ent_ship_aurora");
ENT.Author = ""
ENT.WireDebugName = Lib.Language.GetMessage("ent_ship_aurora");
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/ship/aurore.mdl")


function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("Count_ships_max"):GetInt()
	if(ply:GetCount("Count_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("eap_aurora")
	e:SetPos(ply:GetPos() + Vector(50,50,200))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("Count_ships", e)
	return e

end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self.BaseClass.Initialize(self);

	self.Vehicle = "Aurora"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 15000
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetNWInt("maxEntHealth",self.EntHealth)
	self:SetNWInt("CanFire",1)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()
	self:SetSkin(1);

	--####### Attack vars
	self.LastBlast=0
	self.CanShootStuff = true
	self.CanShootBomb = true
	self.TimeBetweenEachStuffShoot = 1
	self.TimeBetweenEachBombShoot = 1

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

	--Drones
	self.DroneMaxSpeed= 6000;
	self.TrackTime = 3;
	self.Drones = {};
	self.DroneCount = 0;
	self.MaxDrones = 6;

	local phys = self:GetPhysicsObject()
	self:GetPhysicsObject():EnableMotion(false)

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
end

function ENT:ToggleShield()

	if(IsValid(self)) then
		if(not(self.Shielded)) then
			self.Shields:Status(true)
			self.Shielded=true
		else
			self.Shields:Status(false)
			self.Shielded=false
		end
	end
end

function ENT:Think()

	self.BaseClass.Think(self);
	self.ExitPos = self:GetPos()+self:GetForward()*75;

	if(IsValid(self.Pilot)) then

		if(self.Pilot:KeyDown(self.Vehicle,"FIRE")) then
			if(self.CanShootStuff) then
				self:FireBlast(self:GetRight()*80);
				self:FireBlast(self:GetRight()*-80);
				self.CanShootStuff = false
				timer.Create("AuroraCanShoot"..self:EntIndex(),self.TimeBetweenEachStuffShoot,1,function()
					self.CanShootStuff = true
				end)
			end
		end
	end
end

function ENT:OnRemove()
	if timer.Exists("AuroraCanShoot"..self:EntIndex()) then timer.Destroy("AuroraCanShoot"..self:EntIndex()); end
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

function ENT:FireBlast(diff)
	/* Drone launch */
	ent = ents.Create("drone");
	ent.Parent = self;
	ent:SetPos(self:GetPos()+self:GetUp()*100);
	ent:SetAngles(self:GetAngles());
	ent:Spawn();
	ent:Activate();
	ent:SetVelocity((self:GetUp()-self:GetPos())*self.MissileMaxVel);
	ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	ent:SetOwner(self.Entity);
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_ship");
ENT.PrintName = Lib.Language.GetMessage("ent_ship_aurora");
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (Lib==nil or Lib.KeyBoard==nil or Lib.KeyBoard.New==nil) then return end

--########## Keybinder stuff
local KBD = Lib.KeyBoard:New("Aurora")
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
	Engine=Sound("glider/deathglideridleoutside.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "Aurora"
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
		if(p:KeyDown("Aurora","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Aurora","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Aurora","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("Aurora","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Aurora","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

end