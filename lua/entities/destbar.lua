ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Destiny Bar"
ENT.WireDebugName = "Destiny Bar"
ENT.Author = "Elanis"
ENT.Instructions= ""
ENT.Contact = "contact@elanistudio.eu"

list.Set("EAP", ENT.PrintName, ENT);

if SERVER then
AddCSLuaFile();

function ENT:Initialize()
	util.PrecacheModel("models/destbar.mdl");
	self.Entity:SetModel("models/destbar.mdl");
	self.Entity:SetName("Destiny Bar");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
end

end

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("destbar");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos + Vector(0,0,49));
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent;
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "destinytimer", Lib.EAP_GmodDuplicator, "Data" )
end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_others");
ENT.PrintName = Lib.Language.GetMessage("entity_dest_bar");
end

end