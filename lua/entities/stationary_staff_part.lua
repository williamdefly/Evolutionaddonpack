--[[
	Stationary Staff Weapon
	Copyright (C) 2010 Madman07, AlexALX
]]--

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Stationary Staff Weapon"
ENT.Author = "Madman07, Rafael De Jongh"
ENT.Instructions= "Kill the Tau'ri!"
ENT.Contact = "madman097@gmail.com"
ENT.Category = Lib.Language.GetMessage("cat_weapons");

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then

AddCSLuaFile()

-----------------------------------INITIALISE----------------------------------

function ENT:Initialize()

	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE)
	self.Base = self.Base or NULL;

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then phys:EnableGravity(false); phys:SetMass(20) end

end


function ENT:Use(activator, caller, useType, value)
	self.Base:Use(activator, caller, useType, value);
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "stationary_staff_part", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = Lib.Language.GetMessage("cat_weapons");
	ENT.PrintName = SGLanguage.GetMessage("entity_staff_weapon");
end

end