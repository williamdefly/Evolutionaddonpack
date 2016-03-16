ENT.Base = "ship_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage("ent_ship_destiny");
ENT.Author = ""
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/ship/destiny.mdl")

ENT.Sounds = {
	Staff=Sound("weapons/dest_main_cannon.wav")
}

function ENT:SpawnFunction(ply, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end

	local PropLimit = GetConVar("Count_ships_max"):GetInt()
	if(ply:GetCount("Count_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("ship_destiny")
	e:SetPos(tr.HitPos + Vector(0,0,150))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("Count_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex
	self.BaseClass.Initialize(self)
	self.TimeBetweenRafale = 5
	self.NumberOfShootByRafale = 3

	self.Vehicle = "Destiny"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 27000 --Health 18000 + Shield 9000
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetNWInt("maxEntHealth",self.EntHealth)
	self:SetNWInt("CanFire",1)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()

	--####### Attack vars
	self.LastBlast=0
	self.Delay=10
	self.CanShoot = true
	self.TimeBetweenEachShoot = 1.5
	self.CanShootSmallTurrets = true

	self.Shield = NULL;
	self.Shielded = false;

	self.Destination = Vector(200000,0,0)


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

	self.CanShield = true;

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
				self:FireBlast(self:GetRight()*0);
			end
		end
		if(self.Pilot:KeyDown(self.Vehicle,"TRACK")) then
			if self.CanShootSmallTurrets then
				self:FireSmallTurrets(self:GetRight()*0);
				self.CanShootSmallTurrets = false
				timer.Create("DestinyCanFireSmallTurrets"..self:EntIndex(),0.75	,1,function()
					self.CanShootSmallTurrets = true
				end)
			end
		end

		if(self.Pilot:KeyDown(self.Vehicle,"SHIELD")) then
			self:ToggleShield();
		end
	end
end

function ENT:SpawnShield()
	local ent = ents.Create("ship_shield_generator");
	ent:SetPos(self:GetPos());
	ent:SetAngles(self:GetAngles());
	ent:SetParent(self);
	ent:Spawn();
	ent:Activate();
	ent:AddFlags(FL_DONTTOUCH);
	ent:SetSolid(SOLID_NONE)
	ent:SetColor(Color(255,255,255,0))
	ent:SetRenderMode( RENDERMODE_TRANSALPHA );
	self.Shield = ent;
	e.StrengthMultiplier={0.1,0.5,-5}
	e:SetShieldColor(1,0.98,0.94)
end

function ENT:ToggleShield()
	if IsValid(self) then
		if self.CanShield then
			if self.Shielded then
				self.Shield:Status(false);
				self.Shielded = false;
			else
				self.Shield:Status(true);
				self.Shielded = true;
			end
		end
	end
end

function ENT:OnRemove()
	if timer.Exists("DestinyCanShoot"..self:EntIndex()) then timer.Destroy("DestinyCanShoot"..self:EntIndex()); end
	if timer.Exists("DestinyCanFireSmallTurrets"..self:EntIndex()) then timer.Destroy("DestinyCanFireSmallTurrets"..self:EntIndex()); end
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
	if(self.CanShoot) then
		local e = ents.Create("energy_pulse_destiny");
		e:PrepareBullet(self:GetForward(), 10, 12000, 25, {self.Entity});
		e:SetPos(self:GetPos()+diff);
		e:SetOwner(self);
		e.Owner = self;
		e:Spawn();
		e:Activate();
		self:EmitSound(self.Sounds.Staff,90,math.random(90,110))
		self.CanShoot = false
		timer.Create("DestinyCanShoot"..self:EntIndex(),self.TimeBetweenEachShoot,1,function()
			self.CanShoot = true
		end)
	end
end

function ENT:FireSmallTurrets(diff)
	local e = ents.Create("energy_pulse_destiny");
	e:PrepareBullet(self:GetForward(), 10, 12000, 12, {self.Entity});
	e:SetPos(self:GetPos()+self:GetRight()*250+self:GetForward()*-900);
	e:SetOwner(self);
	e.Owner = self;
	e:Spawn();
	e:Activate();
	self:EmitSound(self.Sounds.Staff,90,math.random(90,110))
	local e2 = ents.Create("energy_pulse_destiny");
	e2:PrepareBullet(self:GetForward(), 10, 12000, 12, {self.Entity});
	e2:SetPos(self:GetPos()+self:GetRight()*-250+self:GetForward()*-900);
	e2:SetOwner(self);
	e2.Owner = self;
	e2:Spawn();
	e2:Activate();
	self:EmitSound(self.Sounds.Staff,90,math.random(90,110))
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_ship");
ENT.PrintName = Lib.Language.GetMessage("ent_ship_destiny");
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (Lib==nil or Lib.KeyBoard==nil or Lib.KeyBoard.New==nil) then return end

--########## Keybinder stuff
local KBD = Lib.KeyBoard:New("Destiny")
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
KBD:SetDefaultKey("SHIELD","R")
--View
KBD:SetDefaultKey("VIEW","1")
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")

KBD:SetDefaultKey("EXIT",Lib.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("eap/ship/moteur/destiny.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "Destiny"
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
		if(p:KeyDown("Destiny","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Destiny","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Destiny","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("Destiny","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Destiny","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

function DrawHUD() -- Draw that HUD @Elanis

	local ply = LocalPlayer();
	local self = ply:GetNetworkedEntity("ScriptedVehicle", NULL)
    local vehicle = ply:GetNWEntity("Destiny")

	if (self and self:IsValid() and vehicle and vehicle:IsValid() and self==vehicle) then

		local MainHud = surface.GetTextureID("vgui/hud/destiny_hud/main_hud");

		surface.SetTexture(MainHud);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,0,ScrW(),ScrH());
	end

end
hook.Add("HUDPaint","DrawHUDDestiny",DrawHUD);

end