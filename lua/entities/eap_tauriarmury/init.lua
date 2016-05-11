AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self.hasZat =false
	self.hasStaff = false
	self.ZatClass = "eap_weapon_zat"
	self.P90 = "eap_fnp90"
	self.GDO = "eap_weapon_gdo"
	self.beretta = "weapon_beretta"
	self.Adrenaline = "eap_sg_adrenaline"

	self.PlayerWeapons = {}
	self.EntityLife = 200
	self.NextUse = CurTime()

	self:SetModel("models/Items/ammocrate_smg1.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)      -- Make us work with physics,
	self:SetMoveType(MOVETYPE_VPHYSICS)   -- after all, gmod is a physics
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	phys:SetMass(10000)
	self:SetTable(true)
	if(phys:IsValid()) then
		phys:Wake()
	end

	self:SetNWInt("health",self.EntityLife)
end

function ENT:SpawnFunction(ply,tr)
	if (!tr.Hit) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;
	local ent = ents.Create("eap_tauriarmury");
	ent:SetPos(tr.HitPos+Vector(0,0,30));
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;
	return ent
end

function ENT:OnTakeDamage(dmg)
	local health=self:GetNWInt("health")
	self:SetNWInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	if((health-dmg:GetDamage())<=0) then
		self:Bang(); -- Go boom
	end
end

function ENT:Bang(p)
	self:EmitSound(Sound("jumper/JumperExplosion.mp3"),100,100); --Play the jumper's explosion sound(Only good explosion sound i have)
	local fx = EffectData();
		fx:SetOrigin(self:GetPos());
		util.Effect("Explosion",fx);

	if(self.Active) then
		self:Exit(true); --Let the player out...
	end
	self:Remove(); --Get rid of the vehicle
end

function ENT:Use(ply)
	if(self.NextUse<CurTime())then
		for _,v in pairs(ply:GetWeapons()) do
			table.insert(self.PlayerWeapons, v:GetClass())
		end
		for k,v in pairs(self.PlayerWeapons) do
			if(v==self.ZatClass)then
				self.hasZat = true
			elseif(v==self.P90)then
				self.hasStaff = true
			end
		end

		self:GiveWeapon(ply)
		self.NextUse = CurTime()+1
	end
end

function ENT:GiveWeapon(p)
		p:Give(self.ZatClass)
		p:Give(self.P90)
		p:Give(self.GDO)
		p:Give(self.beretta)
		p:Give(self.Adrenaline)
		if(p:GetAmmoCount("GaussEnergy")<150)then
			p:GiveAmmo(50,"GaussEnergy",false)
		end
		if(p:GetAmmoCount("pistol")<300)then
			p:GiveAmmo(50,"pistol",false)
		end
end