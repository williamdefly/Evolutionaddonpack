-- Prop Credit goes to MadMan07

ENT.Base = "ship_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage("ent_ship_daedalus");
ENT.Author = ""
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/ships/madman07/daedalus/daedalus.mdl")

ENT.Sounds = {
	Staff=Sound("eap/ship/armes/asgardflak.wav");
	Missile = Sound("f302/Missile_Shoot_Small.wav");
}

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("EAP_ships_max"):GetInt()
	if(ply:GetCount("EAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("ship_daedalus")
	e:SetPos(tr.HitPos + Vector(0,0,180))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("EAP_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex
	self.BaseClass.Initialize(self);
	self.Vehicle = "Dedale"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 27000 --Health 20000 + Shield 27000
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
		if(self.Pilot:KeyDown("EAP_KEYBOARD","FIRE")) then
			if(self.CanShoot) then
				self:FireBlast(self:GetRight()*80);
				self:FireBlast(self:GetRight()*-80);
			self.CanShoot = false
				timer.Create("DedaleCanShoot"..self.Pilot:EntIndex(),self.TimeBetweenEachShoot,1,function()
					self.CanShoot = true
				end)
			end
		end
		if(self.Pilot:KeyDown("EAP_KEYBOARD","TRACK"))then
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
	if timer.Exists("DedaleCanShoot"..self:EntIndex()) then timer.Destroy("DedaleCanShoot"..self:EntIndex()); end
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

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.PrintName = Lib.Language.GetMessage("ent_ship_daedalus");
ENT.Category = Lib.Language.GetMessage("cat_ship");
end
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Sounds={
	Engine=Sound("eap/ship/moteur/bc304.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or Lib.Settings.KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "Dedale"
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

function DrawHUD() -- Draw that HUD @Elanis

local ply = LocalPlayer();
local self = ply:GetNetworkedEntity("ScriptedVehicle", NULL)
local vehicle = ply:GetNWEntity("Dedale")

local MainHud_left = surface.GetTextureID("VGUI/HUD/BC304_HUD/mainhud_left");
local MainHud_right = surface.GetTextureID("VGUI/HUD/BC304_HUD/mainhud_right");
local WeaponsHud_middle = surface.GetTextureID("VGUI/HUD/BC304_HUD/weaponshud_middle");
local WeaponsHud_left = surface.GetTextureID("VGUI/HUD/BC304_HUD/weaponshud_left");
local WeaponsHud_right = surface.GetTextureID("VGUI/HUD/BC304_HUD/weaponshud_right");
local WepBar = surface.GetTextureID("VGUI/HUD/BC304_HUD/weapons_bar");

	if (self and self:IsValid() and vehicle and vehicle:IsValid() and self==vehicle) then

		surface.SetTexture(MainHud_left);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,ScrH()-512,256,512);

		surface.SetTexture(MainHud_right);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(ScrW()-256,ScrH()-512,256,512);

		surface.SetTexture(WeaponsHud_middle);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(ScrW()/2-256,0,512,64);

		surface.SetTexture(WeaponsHud_left);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,0,256,64);

		surface.SetTexture(WeaponsHud_right);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(ScrW()-256,0,256,64);

		local yy = 55
		surface.SetTexture(WepBar);
		surface.SetDrawColor(255,255,255,255);

		surface.DrawTexturedRect(20,yy,8,8);
		surface.DrawTexturedRect(70,yy,8,8);
		surface.DrawTexturedRect(100,yy,8,8);
		surface.DrawTexturedRect(150,yy,8,8);
		surface.DrawTexturedRect(180,yy,8,8);
		surface.DrawTexturedRect(220,yy,8,8);

		surface.DrawTexturedRect(ScrW()/2+70,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2+60,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2+50,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2+40,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2+30,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2+20,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2-20,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2-30,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2-40,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2-50,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2-60,yy,8,8);
		surface.DrawTexturedRect(ScrW()/2-70,yy,8,8);

		surface.DrawTexturedRect(ScrW()-20,yy,8,8);
		surface.DrawTexturedRect(ScrW()-70,yy,8,8);
		surface.DrawTexturedRect(ScrW()-100,yy,8,8);
		surface.DrawTexturedRect(ScrW()-150,yy,8,8);
		surface.DrawTexturedRect(ScrW()-180,yy,8,8);
		surface.DrawTexturedRect(ScrW()-220,yy,8,8);
    end

end
hook.Add("HUDPaint","DrawHUDDeadalus",DrawHUD);
end