ENT.Base = "ship_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage("ent_ship_aurora");
ENT.Author = "Elanis, Lilou"
ENT.WireDebugName = Lib.Language.GetMessage("ent_ship_aurora");
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/ship/aurore.mdl")


function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("EAP_ships_max"):GetInt()
	if(ply:GetCount("EAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("ship_aurora")
	e:SetPos(ply:GetPos() + Vector(50,50,200))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("EAP_ships", e)
	return e

end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self.BaseClass.Initialize(self);

	self.Vehicle = "Aurora"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 30000 	--Health 20000 + Shield 10000
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
	self.MissileMaxVel = 1

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
	self:CreateWireInputs("X","Y","Z","Target [VECTOR]");
	self:CreateWireOutputs("Health");

	--Drones
	self.Target=Vector(0,0,0);
	self.DroneMaxSpeed= 6000;
	self.TrackTime = 3;
	self.Drones = {};
	self.DroneCount = 0;
	self.MaxDrones = 6;
	self.Track = false;

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

		if(self.Pilot:KeyDown("EAP_KEYBOARD","FIRE")) then
			if(self.CanShootStuff) then
				self:FireBlast(self:GetRight()*80);
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
	ent = ents.Create("aurora_drone");
	ent.Parent = self;
	ent:SetPos(self:GetPos()+self:GetUp()*110-self:GetForward()*100);
	ent:SetAngles(self:GetAngles());
	ent:Spawn();
	ent:Activate();
	ent:SetVelocity((self:GetUp()-self:GetPos())*self.MissileMaxVel);
	ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	ent:SetOwner(self.Entity);

	timer.Create("AuroraShoot2"..self:EntIndex(),self.TimeBetweenEachStuffShoot/8,1,function()

	/* Drone launch */
	ent2 = ents.Create("aurora_drone");
	ent2.Parent = self;
	ent2:SetPos(self:GetPos()+self:GetUp()*110+self:GetForward()*100);
	ent2:SetAngles(self:GetAngles());
	ent2:Spawn();
	ent2:Activate();
	ent2:SetVelocity((self:GetUp()-self:GetPos())*self.MissileMaxVel);
	ent2:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	ent2:SetOwner(self.Entity);

	end)

	timer.Create("AuroraShoot3"..self:EntIndex(),self.TimeBetweenEachStuffShoot/4,1,function()

	/* Drone launch */
	ent3 = ents.Create("aurora_drone");
	ent3.Parent = self;
	ent3:SetPos(self:GetPos()+self:GetUp()*110-self:GetForward()*200);
	ent3:SetAngles(self:GetAngles());
	ent3:Spawn();
	ent3:Activate();
	ent3:SetVelocity((self:GetUp()-self:GetPos())*self.MissileMaxVel);
	ent3:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	ent3:SetOwner(self.Entity);

	end)

	timer.Create("AuroraShoot4"..self:EntIndex(),self.TimeBetweenEachStuffShoot/6,1,function()

	/* Drone launch */
	ent4 = ents.Create("aurora_drone");
	ent4.Parent = self;
	ent4:SetPos(self:GetPos()+self:GetUp()*110+self:GetForward()*200);
	ent4:SetAngles(self:GetAngles());
	ent4:Spawn();
	ent4:Activate();
	ent4:SetVelocity((self:GetUp()-self:GetPos())*self.MissileMaxVel);
	ent4:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	ent4:SetOwner(self.Entity);

	end)
end

--############## Add wire inputs
function ENT:TriggerInput(k,v)

	if(not self.EyeTrack and k == "X") then
		self.PositionSet = true
		self.Target.x = v
	elseif(not self.EyeTrack and k == "Y") then
		self.PositionSet = true
		self.Target.y = v
	elseif(not self.EyeTrack and k == "Z") then
		self.PositionSet = true
		self.Target.z = v
	elseif(not self.EyeTrack and k =="Target") then
		self.PositionSet = true;
		self.Target = v;
	end
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_capital_ship");
ENT.PrintName = Lib.Language.GetMessage("ent_ship_aurora");
end
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Sounds={
	Engine=Sound("eap/ship/moteur/aurora.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or Lib.Settings.KBD:CreateInstance(self)
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
		if(p:KeyDown("EAP_KEYBOARD","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("EAP_KEYBOARD","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("EAP_KEYBOARD","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("EAP_KEYBOARD","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("EAP_KEYBOARD","A-")) then
			self.UDist=self.UDist-5
		end

		if(p:KeyDown("EAP_KEYBOARD","TRACK")) then -- TRACK!!!!!!
			self.Track = true
		else
			self.Track = false
		end
	end
end

local hudpos = {
	healthw = (ScrW()/10*7.7),
	healthh = (ScrH()/10*7.6),
}

function DrawHUD() -- Draw that HUD @Elanis

	local ply = LocalPlayer();
	local self = ply:GetNetworkedEntity("ScriptedVehicle", NULL)
    local vehicle = ply:GetNWEntity("Aurora")

	if (self and self:IsValid() and vehicle and vehicle:IsValid() and self==vehicle) then

		local MainHud = surface.GetTextureID("vgui/hud/aurora_hud/main_hud");

		surface.SetTexture(MainHud);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,0,ScrW(),ScrH());
			local health = math.Round(self:GetNetworkedInt("health")/30000*100) -- test fix
			draw.WordBox(8,hudpos.healthw,hudpos.healthh, Lib.Language.GetMessage("health")..": "..health.."%","ScoreboardText",Color(50,50,75,0), Color(200, 173, 127,255))
	end

end
hook.Add("HUDPaint","DrawHUDAurora",DrawHUD);

end