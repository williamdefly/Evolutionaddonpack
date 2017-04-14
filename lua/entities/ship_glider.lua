--[[
	DeathGlider for GarrysMod 10
	Copyright (C) 2009 RononDex

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Type = "vehicle"
ENT.Base = "ship_base"

ENT.PrintName = "Death Glider"
ENT.Author	= "RononDex, Iziraider, Rafael De Jongh"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= ""
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);

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
	e:SetPos(tr.HitPos + Vector(0,0,90))
	e:Spawn()
	e:Activate()
	e:SetWire("Health",e:GetNetworkedInt("health"));
	ply:AddCount("EAP_ships", e)
	return e
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:StartMotionController()

	self.Vehicle = "DeathGlider";
	--self.BaseClass.Initialize(self,self.Vehicle,self.FlightVars,self.FlightPhys,self.Accel)
	self.EntHealth = 300
	self.BlastMaxVel = 10000000;
	self.Blasts = {};
	self.BlastCount = 0;
	self.MaxBlasts = (4);
	self.BlastsFired = 0;
	self:SetNetworkedInt("health",self.EntHealth);
	self.Delay = 10;

	--######### Flight Vars
	self.Accel = {};
	self.Accel.FWD = 0;
	self.Accel.RIGHT = 0;
	self.Accel.UP = 0;
	self.ForwardSpeed = 2000;
	self.BackwardSpeed = 0;
	self.UpSpeed = 0;
	self.MaxSpeed = 2750;
	self.RightSpeed = 0;
	self.Accel.SpeedForward = 20;
	self.Accel.SpeedRight = 0;
	self.Accel.SpeedUp = 0;
	self.RollSpeed = 5;
	self.num = 0;
	self.num2 = 0;
	self.num3 = 0
	self.Roll = 0;
	self.Hover = false;
	self.GoesRight = false;
	self.GoesUp = false;
	self.CanRoll = true;
	self:CreateWireOutputs("Health");

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
end

function ENT:OnTakeDamage(dmg) --########## Gliders aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health-dmg:GetDamage());

	if((health-dmg:GetDamage())<=0) then
		self:Bang() -- Go boom
	end
end

function ENT:OnRemove()

	self.BaseClass.OnRemove(self)

end

function ENT:Think()

	self.BaseClass.Think(self)

	if(self.StartDelay) then
		self.Delay=math.Approach(self.Delay,10,3)
	end

	if(self.Delay>=10) then
		self.StartDelay=false
	end

	if(IsValid(self.Pilot)) then
		if((self.Pilot:KeyDown("EAP_KEYBOARD","FIRE"))) then
			if(self.Delay>=10) then
				self:FireBlast(self:GetRight()*-130)
				self:FireBlast(self:GetRight()*130)
				self.Delay=0
			end
			self.StartDelay=true
		end
	end
end

function ENT:Exit(kill)

	self.BaseClass.Exit(self,kill)
	self.ExitPos = self:GetPos()+Vector(0,0,100);
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

ENT.Sounds = {
	Engine=Sound("glider/deathglideridleoutside.wav"),
}

function ENT:Initialize()
	self.Dist=-850
	self.UDist=250
	self.FirstPerson=false
	self.lastswitch = CurTime();
	self.on1=0;
	self.KBD = self.KBD or Lib.Settings.KBD:CreateInstance(self)
	self.BaseClass.Initialize(self)
	self.Vehicle = "DeathGlider";
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