--[[
	Hangar Button
	Copyright (C) 2011 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Hangar Buttons"
ENT.Author = "Madman07"
ENT.Category = ""
ENT.WireDebugName = "Hangar Weapon"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

AddCSLuaFile();

ENT.Sounds = {
	Button1=Sound("button/button_hangar1.wav"),
	Button2=Sound("button/button_hangar2.wav"),
}

function ENT:Initialize()

	self.Entity:SetName("Hangar Button");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.NextUse = CurTime();

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1000) -- make it more solid
	end

end

function ENT:Use(ply)
	if (self.ID == 5) then
		self:EmitSound(self.Sounds.Button2,100,math.random(95,105));
	else
		self:EmitSound(self.Sounds.Button1,100,math.random(95,105));
	end
	if self.NextUse < CurTime() then
		if (IsValid(self.Parent)) then
			self.Parent:ButtonPressed(self.ID, ply);
		end
		self.NextUse = CurTime() + 1;
	end
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "hangar_button", Lib.EAP_GmodDuplicator, "Data" )
end

end