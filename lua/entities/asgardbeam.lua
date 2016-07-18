--[[
	Asgard Beam Weapon
	Copyright (C) 2010 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Asgard Beam Weapon"
ENT.Author = "Madman07, Boba Fett"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = Lib.Language.GetMessage("cat_weapons");
ENT.Spawnable = true
ENT.AdminSpawnable = true

list.Set("EAP", ENT.PrintName, ENT);

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
	ENT.Category = Lib.Language.GetMessage("cat_weapons");
	ENT.PrintName = Lib.Language.GetMessage("entity_asgard_beam");
end

end

if SERVER then

AddCSLuaFile()

ENT.Sounds={
	Shoot=Sound("eap/ship/armes/asgardcanonbeam.mp3"),
}

ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/asgard_turret/asgard_turret.mdl");

	self.Entity:SetName("Asgard Beam Weapon");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	if WireAddon then
		self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire [NORMAL]", "Active [NORMAL]", "Vector [VECTOR]", "Entity [ENTITY]"});
		self.Outputs = WireLib.CreateOutputs( self.Entity, {"Charged % [NORMAL]"});
	end

	self.WireShoot = nil;
	self.WireEnt = nil;
	self.WireVec = nil;
	self.WireActive = nil;

	self.APC = nil;
	self.APCply = nil;
	self.Target = Vector(0,0,0);
	self.Power = 0;

	local ChargingTime = 8;
	self.ChargingTime = math.random(ChargingTime-2,ChargingTime+2);

	self:AddResource("energy",2000);
	self.energy_drain = 1000
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("EAP_asgbeam_max"):GetInt()
	if(ply:GetCount("EAP_asgbeam")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_asgard_beam\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	ent = ents.Create("asgardbeam");
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("EAP_asgbeam", ent)
	return ent
end

-----------------------------------DIFFERENT CRAP----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Vector") then self.WireVec = value;
	elseif (variable == "Entity") then self.WireEnt = value;
	elseif (variable == "Fire") then self.WireShoot = value;
	elseif (variable == "Active") then self.WireActive = value;	end
end

function ENT:StartTouch( ent )
	if IsValid(ent) and ent:IsVehicle() then
		if (self.APC != ent) then
			local ed = EffectData()
				ed:SetEntity( ent )
			util.Effect( "old_propspawn", ed, true, true )
		end
		self.APC = ent;
	end
end


-----------------------------------THINK----------------------------------

function ENT:Think(ply)
	self.Power = math.Clamp(self.Power + 25/self.ChargingTime, 0, 100);
	Wire_TriggerOutput(self.Entity, "Charged %", self.Power);

	if IsValid(self.APC) then
		self.APCply = self.APC:GetPassenger(0)
		if IsValid(self.APCply) then

			self.APCply:CrosshairEnable();
			self.Target = self.APCply:GetEyeTrace().HitPos;

			if (self.APCply:KeyDown( IN_ATTACK ) and (self.Power == 100)) then
				self:Shoot();
			end
		end
	elseif (self.WireActive == 1) then
		if ((self.WireShoot == 1) and (self.Power == 100)) then
			self:Shoot();
		end

		if IsValid(self.WireEnt) then
			self.Target = self.WireEnt:LocalToWorld(self.WireEnt:OBBCenter());
		elseif (self.WireVec) then
			self.Target = self.WireVec;
		end
	end

end

function ENT:Shoot()
	local energy = self:GetResource("energy");

	if(energy > self.energy_drain or !self.HasRD) then

		local FiringPos = self.Entity:GetPos() + self.Entity:GetUp()*70;
		local ShootDir = (self.Target - FiringPos):GetNormal();
		local trace = util.TraceLine({start = FiringPos, endpos = self.Target, ignoreworld = true});

		if (IsValid(trace.Entity) and trace.Entity==self) then return end

		self:ConsumeResource("energy",self.energy_drain);

		self.Power = 0;
		self.Entity:EmitSound(self.Sounds.Shoot,100,math.random(98,102));

		local ent = ents.Create("energy_beams2");
		ent.Owner = self.Entity;
		ent:SetPos(FiringPos);
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		ent:Setup(FiringPos, ShootDir, 1200, 1.5, "Asgard");

		local glow = EffectData();
			glow:SetEntity(self.Entity);
			glow:SetStart(Vector(0,0,70));
			glow:SetAngles(Angle(120,175,255));
			glow:SetScale(30);
			glow:SetMagnitude(1.5);
		util.Effect("energy_glow", glow);
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntityID = self.Entity:EntIndex()
	end
	if IsValid(self.APC) then
	    dupeInfo.APCID = self.APC
	end    /*
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end      */
	duplicator.StoreEntityModifier(self, "AsgardDupeInfo", dupeInfo)
	Lib.Wire.PreEntityCopy(self,ply,Ent,CreatedEntities)
	Lib.RD.PreEntityCopy(self,ply,Ent,CreatedEntities)
end
duplicator.RegisterEntityModifier( "AsgardDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (Lib.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("EAP_asgbeam_max"):GetInt()
	if (IsValid(ply)) then
		if(ply:GetCount("EAP_asgbeam")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_asgard_beam\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("EAP_asgbeam", self.Entity)
	end

	local dupeInfo = Ent.EntityMods.AsgardDupeInfo

	if dupeInfo.EntityID then
		self.Entity = CreatedEntities[ dupeInfo.EntityID ]
	end
	if dupeInfo.APCID then
		self.APC = dupeInfo.APCID
	end
         /*
	if(Ent.EntityMods and Ent.EntityMods.AsgardDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.AsgardDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end    */
	Lib.Wire.PostEntityPaste(self,ply,Ent,CreatedEntities)
	Lib.RD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "asgard_beam", Lib.EAP_GmodDuplicator, "Data" )
end

end