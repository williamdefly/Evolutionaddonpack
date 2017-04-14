ENT.Base = "ship_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage("ent_ship_wraithcruiser");
ENT.Author = "RononDex, Iziraider, Rafael De Jongh, Elanis"

list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/Iziraider/Deathglider/deathglider.mdl")

ENT.Sounds = {
	Staff=Sound("pulse_weapon/staff_weapon.mp3")
}

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("EAP_ships_max"):GetInt()
	if(ply:GetCount("EAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("ship_glider")
	e:SetPos(tr.HitPos)
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("EAP_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex
	self.BaseClass.Initialize(self);
	self.Vehicle = "DeathGlider"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 300
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetNWInt("maxEntHealth",self.EntHealth)
	self:SetNWInt("CanFire",1)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()

	--####### Attack vars
	self.BlastMaxVel = 10000000;
	self.Blasts = {};
	self.BlastCount = 0;
	self.MaxBlasts = (4);
	self.BlastsFired = 0;
	self.Delay=10

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

	local phys = self:GetPhysicsObject()
	self:GetPhysicsObject():EnableMotion(false)

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
end

function ENT:Think()
	self.BaseClass.Think(self);
	self.ExitPos = self:GetPos()+self:GetForward()*200;
	

	if(self.StartDelay) then
		self.Delay = math.Approach(self.Delay,10,3);
	end

	if(self.Delay>=10) then
		self.StartDelay = false;
	end

	if(IsValid(self.Pilot)) then
		if(self.Pilot:KeyDown("EAP_KEYBOARD","FIRE")) then
			if(self.Delay>=0) then
				self:FireBlast(self:GetRight()*80);
				self:FireBlast(self:GetRight()*-80);
				self.Delay = 10;
			end
			self.StartDelay = true;
		end
	else
		self.StartDelay = false;
	end
end

function ENT:OnRemove()	self.BaseClass.OnRemove(self) end

function ENT:OnTakeDamage(dmg) --########## Gliders aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if((health-dmg:GetDamage())<=0) then
		self:Bang() -- Go boom
	end
end

function ENT:FireBlast(diff)
	local e = ents.Create("energypulse");
	e:PrepareBullet(self:GetForward(), 10, 16000, 6, {self.Entity});
	e:SetPos(self:GetPos()+diff);
	e:SetOwner(self);
	e.Owner = self;
	e:Spawn();
	e:Activate();
	self:EmitSound(self.Sounds.Staff,90,math.random(90,110))
end

function ENT:ShowOutput()
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ship_glider", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage('cat_small_ship');
ENT.PrintName = Lib.Language.GetMessage('ent_ship_deathglider');
end
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Sounds = {
	Engine=Sound("glider/deathglideridleoutside.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-850
	self.UDist=250
	self.KBD = self.KBD or Lib.Settings.KBD:CreateInstance(self)
	self.FirstPerson=false
	self.lastswitch = CurTime();
	self.on1=0;
	self.Vehicle = "DeathGlider"
end

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local vehicle = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((vehicle)and((vehicle)==self)and(vehicle:IsValid())) then
		self.KBD:SetActive(true)
		self:StartClientsideSound("Normal")
	else
		self.KBD:SetActive(false)
		self:StopClientsideSound("Normal")
	end

	if((vehicle)and((vehicle)==self)and(vehicle:IsValid())) then
		if(p:KeyDown("EAP_KEYBOARD","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("EAP_KEYBOARD","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("EAP_KEYBOARD","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("EAP_KEYBOARD","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

end