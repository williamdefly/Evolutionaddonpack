ENT.Base = "ship_base"
ENT.Type = "vehicle"
ENT.Spawnable = true

ENT.PrintName = Lib.Language.GetMessage("ent_ship_alkesh");
ENT.Author = "Elanis, Lilou"
ENT.WireDebugName = Lib.Language.GetMessage("ent_ship_alkesh");
list.Set("EAP", ENT.PrintName, ENT);

--ENT.IsSGVehicleCustomView = true

if SERVER then

--########Header########--
AddCSLuaFile()

ENT.Model = Model("models/ship/alkesh.mdl")

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

	local e = ents.Create("ship_alkesh")
	e:SetPos(tr.HitPos + Vector(0,0,250))
	e:SetAngles(ply:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("EAP_ships", e)
	return e

end

function ENT:SpawnRings()
	local e = ents.Create("rg_base_goauld");
	e:SetModel(e.BaseModel);
	e:SetPos(self:LocalToWorld(Vector(125,0,-63)));
	e:Spawn();
	e:Activate();
	e:SetAngles(self:GetAngles()+Angle(180,0,0));
	constraint.Weld(self,e,0,0,0,true)
	e:SetParent(self);
	e.DirOverride = true
	e.Dir = -1;
	self.OutRing = e;
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

	local e = ents.Create("rg_base_goauld");
	e:SetModel(e.BaseModel);
	e:SetPos(self:LocalToWorld(Vector(125,0,-35)));
	e:Spawn();
	e:Activate();
	e:SetAngles(self:GetAngles()+Angle(0,0,0));
	constraint.Weld(self,e,0,0,0,true)
	e:SetParent(self)
	e.DirOverride = true
	e.Dir = -1
	self.InRing = e
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end
end

function ENT:DialRing()
	self.OutRing:Dial(self.InRing:GetNWString("address",""))
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self.BaseClass.Initialize(self);

	self.Vehicle = "Alkesh"
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.EntHealth = 18000 --Health 15000 + Shield 3000
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

	//self:SpawnRings()
	//self.OutRing:Dial("")

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
				self:FireBlast(self:GetRight()*-80);
				self.CanShootStuff = false
				timer.Create("AlkeshCanShoot"..self:EntIndex(),self.TimeBetweenEachStuffShoot,1,function()
					self.CanShootStuff = true
				end)
			end
		end
	end
end

function ENT:OnRemove()
	if timer.Exists("AlkeshCanShoot"..self:EntIndex()) then timer.Destroy("AlkeshCanShoot"..self:EntIndex()); end
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

	if( not self.Entity ) then return false end

	local e = ents.Create("energy_pulse_alkesh");
	e:PrepareBullet(self:GetForward(), 10, 16000, 6, {self.Entity});
	e:SetPos(self:GetPos()+diff);
	e:SetOwner(self);
	e.Owner = self;
	e:Spawn();
	e:Activate();
	self:EmitSound(self.Sounds.Staff,90,math.random(90,110))
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_small_ship");
ENT.PrintName = Lib.Language.GetMessage("ent_ship_alkesh");
end
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Sounds={
	Engine=Sound("eap/ship/alkesh.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or Lib.Settings.KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "Alkesh"
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
	end
end

local hudpos = {
	healthw = (ScrW()/10*3),
	healthh = (ScrH()/10*9),
}

function DrawHUD() -- Draw that HUD @Elanis

	local ply = LocalPlayer();
	local self = ply:GetNetworkedEntity("ScriptedVehicle", NULL)
    local vehicle = ply:GetNWEntity("Alkesh")

	if (self and self:IsValid() and vehicle and vehicle:IsValid() and self==vehicle) then

		local MainHud = surface.GetTextureID("vgui/hud/alkeshhud/alkeshhud");

		surface.SetTexture(MainHud);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,0,ScrW(),ScrH());
			local health = math.Round(self:GetNetworkedInt("health")/18000*100) -- test fix
			draw.WordBox(8,hudpos.healthw,hudpos.healthh, Lib.Language.GetMessage("health")..": "..health.."%","ScoreboardText",Color(50,50,75,0), Color(255,255,0,255))

	end

end
hook.Add("HUDPaint","DrawHUDAlkesh",DrawHUD);

end