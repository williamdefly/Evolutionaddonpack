/*   Copyright 2010 by Llapp   */
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "2010 Ramp"
ENT.Author = "Llapp"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsRamp = true

if SERVER then

AddCSLuaFile();

function ENT:Initialize()
	self.Entity:SetModel("models/MarkJaw/2010_ramp.mdl");
	--self.Entity:Fire("skin",0);
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(5000);
	end
	self.Gate=nil;
end

function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end;
	local e = ents.Create("futureramp");
	e:SetPos(t.HitPos+Vector(0,0,145));
	e:DrawShadow(true);
	e:Spawn();
	return e;
end

function ENT:Think()
    if(self.Gate!=nil)then
        self:SkinChanger();
	end
    self:GateFinder();
	self:NextThink(CurTime()+0.5);
end

function ENT:SkinChanger()
    if(self.Gate!=nil)then
        if(not self.Gate.NewActive)then
	        self.Entity:SetSkin(0);
        elseif(self.Gate.NewActive and not self.Gate.IsOpen)then
	        self.Entity:SetSkin(1);
	    elseif(self.Gate.NewActive and self.Gate.IsOpen and not self.Gate.Outbound)then
	        self.Entity:SetSkin(2);
	    elseif(self.Gate.NewActive and self.Gate.IsOpen and self.Gate.Outbound)then
	        self.Entity:SetSkin(3);
	    end
	end
end

function ENT:GateFinder()
	for _,v in pairs(Lib.GetConstrainedEnts(self.Entity,2) or {}) do
		if(IsValid(v) and v:GetClass():find("sg_*")) then
		    self.Gate = v;
		--else
		--    self.Gate = nil;
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (Lib.NotSpawnable("anim_ramps",ply,"tool") ) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("sbox_maxanim_ramps"):GetInt()
	if (IsValid(ply)) then
		if(ply:GetCount("Count_anims_ramps")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_ramp_anim_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("Count_anims_ramps", self.Entity)
	end
end

if (Lib and Lib.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "future_ramp", Lib.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
language.Add("ramp",Lib.Language.GetMessage("ramp_kill"));
end

end