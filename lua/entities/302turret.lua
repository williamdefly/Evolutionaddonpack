ENT.PrintName = "302 Turret"
ENT.Author = "Shadow"
ENT.Spawnable = false
ENT.Type = "anim"
ENT.Base = "base_anim"

if CLIENT then

if (Lib.language!=nil and Lib.language.GetMessage!=nil) then
	language.Add("f302", Lib.language.GetMessage("entity_ship_f302"))
end

end

if SERVER then

AddCSLuaFile()

ENT.Railgunsound = Sound("f302/f302_railgun.wav")

function ENT:Initialize()
	self:SetModel("models/sandeno/naquadah_bottle.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Firing=false
	self:SetColor(Color(255,255,255,0))
end

function ENT:Think()
	if(self.Firing) then
		self:Bullets()
		self:EmitSound(self.Railgunsound,100,100)
	end
end

function ENT:Bullets()
	bullet = {}
	bullet.Src		= self:GetPos()
	bullet.Attacker = self
	if(self.Turret==1) then
		bullet.Dir		= self:GetAngles():Forward() +	self:GetAngles():Right()*0.1;
	elseif(self.Turret==2) then
		bullet.Dir		= self:GetAngles():Forward() +	self:GetAngles():Right()*-0.1;
	end
	bullet.Spread		= Vector(0.01,0.01,0.01)
	bullet.Num		= 3
	bullet.Damage		= 60
	bullet.Force		= 55
	bullet.Tracer		= 4
	bullet.TracerName	= "AR2Tracer"

	self:FireBullets(bullet)
end

end