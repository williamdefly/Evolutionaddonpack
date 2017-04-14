ENT.Type = "anim"
ENT.Base = "rg_base"
ENT.PrintName = "Rings (Goauld)"
ENT.Author = "Catdaemon, Madman07, Rafael De Jongh"
ENT.Instructions = "Place where desired, USE to set its address."
ENT.Category = 	""
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);

ENT.IsRings = true;

if SERVER then

AddCSLuaFile();

ENT.RingModel = "models/Madman07/ancient_rings/ring.mdl";
ENT.BaseModel = "models/Madman07/ancient_rings/ring.mdl";

ENT.OriFix = 0;

function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local e = ents.Create("rg_base_goauld");
	e:SetModel(e.BaseModel);
	e:SetPos(tr.HitPos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	local phys = e:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false) end
	e:RampsRing(tr);
	return e;
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "rg_base_goauld", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_transportation");
ENT.PrintName = Lib.Language.GetMessage("ring_goauld");
end

end