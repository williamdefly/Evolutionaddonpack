/*   Copyright 2010 by Llapp   */
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ramps"
ENT.Author = "Llapp"
ENT.Category = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsRamp = true

if SERVER then

AddCSLuaFile();

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
	    phys:EnableMotion(true);
		phys:Wake();
		phys:SetMass(5000);
	end
end

function ENT:SpawnFunction(p,t)   --############ @  Llapp
	if (!t.HitWorld) then return end;
	e = ents.Create("ramps") ;
	e:SetPos(t.HitPos + Vector(0,0,-10));
	ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;
	e:SetAngles(ang);
	e:DrawShadow(false);
	self.Sat = e;
	e:Spawn();
	e:Activate();
	return e;
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ramps", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
language.Add("ramp",Lib.Language.GetMessage("ramp_kill"));
end

end