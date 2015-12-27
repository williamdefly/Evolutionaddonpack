ENT.Base = "eap_base"
ENT.Type = "vehicle"

ENT.PrintName = "Navigateur"
ENT.Author = ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Technologie"
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--Header--
AddCSLuaFile()

ENT.Model = Model("models/slyfo/consolechair.mdl")

ENT.Sounds = {
	Staff=Sound("weapons/dest_main_cannon.wnav")
}

function ENT:SpawnFunction(ply, tr) 
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(ply:GetCount("CAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("eap_navigateur")
	e:SetPos(tr.HitPos + Vector(0,0,50))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("CAP_ships", e)
	return e
end

function ENT:Initialize() 
	self.BaseClass.Initialize(self);
	self.TimeBetweenRafale = 5
	self.NumberOfShootByRafale = 3

	self.Vehicle = "Navigator"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 100000
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetNWInt("maxEntHealth",self.EntHealth)
	self:SetNWInt("CanFire",1)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()

	--####### Attack vars
	self.LastBlast=0
	self.Delay=10
	self.CanShoot = false
	self.TimeBetweenEachShoot = 1.5
	self.CanShootSmallTurrets = false

	self.Shielded = false
	self.ShieldOffline = false

	self.LastAngles = Angle(0,0,0);


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
	self:CreateWireOutputs("Health","Left Click", "Right Click");

	local phys = self:GetPhysicsObject()
	self:GetPhysicsObject():EnableMotion(false)
	
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end

	self.EntitiesNotAllowed = {};
end

function ENT:Think()
	self.BaseClass.Think(self);
	self.ExitPos = self:GetPos()+self:GetForward()*75;

	self:SetWire("Left Click",0);
	self:SetWire("Right Click",0);

	if IsValid(self.Pilot) then
		if self.Pilot:KeyDown("Navigator","FIRE") then
			self:SetWire("Left Click",1)
		end

		if self.Pilot:KeyDown("Navigator","FIRE2") then
			self:SetWire("Right Click",1)
		end
	end
end

function ENT:Enter(ply)
	local ConstrainedEntities = constraint.GetAllConstrainedEntities(self);
	for _,ent in pairs(ConstrainedEntities) do
		ent:GetPhysicsObject():EnableMotion(true);
	end
	/*if self.LastAngles ~= Angle(0,0,0) then
		for _,ent in pairs(ConstrainedEntities) do
			ent:SetAngles(self.LastAngles);
		end
	end*/
	self.BaseClass.Enter(self,ply);
end

function ENT:Exit(kill)
	if not kill then
		//self.LastAngles = self:GetAngles();
		local ConstrainedEntities = constraint.GetAllConstrainedEntities(self);
		for _,ent in pairs(ConstrainedEntities) do
			ent:GetPhysicsObject():EnableMotion(false);
			//ent:SetAngles(Angle(0,0,0));
		end
	end
	self.BaseClass.Exit(self,kill);
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

function ENT:OnTakeDamage(dmg) 

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if((health-dmg:GetDamage())<=0) then
		self:Bang() -- Go boom
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "eap_navigateur", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = "Technologie";
ENT.PrintName = "Navigateur";
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (StarGate==nil or StarGate.KeyBoard==nil or StarGate.KeyBoard.New==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("Navigator")
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
KBD:SetDefaultKey("FIRE2",StarGate.KeyBoard.BINDS["+attack2"] or "MOUSE2")
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
	Engine=Sound("eap/ship/moteur/destiny.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "Navigator"
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

--######## Mainly Keyboard stuff 
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
		if(p:KeyDown("Navigator","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Navigator","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Navigator","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("Navigator","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Navigator","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

end