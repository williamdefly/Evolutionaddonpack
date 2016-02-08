if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Model = "models/elanis/sarcophage/sarcophage_goauld.mdl";
ENT.Sounds = {
	Enter = Sound("eap/entities/sarcophage.wav"),
	Exit = Sound("eap/entities/sarcophage.wav"),
}
 
function ENT:Initialize()

	self.Heal = 1
	self.OpenSound = self.OpenSound or CreateSound(self.Entity,"eap/entities/sarcophage.wav");
	self.CloseSound = self.CloseSound or CreateSound(self.Entity,"eap/entities/sarcophage.wav");
	self.SoundOn = false;
 
	self:SetModel(self.Model);
	self:PhysicsInit(SOLID_VPHYSICS)      -- Make us work with physics,
	self:SetMoveType(MOVETYPE_VPHYSICS)   -- after all, gmod is a physics
	self:SetSolid(SOLID_VPHYSICS)         -- Toolbox
	
	self:SetUseType(SIMPLE_USE);

	self.EntHealth = 200
	self:SetNetworkedInt("health",self.EntHealth);

	self.HealthDelay = 2
	self.MaxHealth = 150
	self.health = 1
	self.HealthNumber = 1
	self.DisableSound = false
	self.NextHealth = true
 
	local phys = self.Entity:GetPhysicsObject()
	phys:SetMass(10000)
	self:SetTable(true)
	if(phys:IsValid()) then
		phys:Wake()
	end
	self.PlayerWeapons = {}
	self.PlayerActiveWeapon = NULL
	self.Active = false
	self.Pilot = NULL
	self.EntityLife = 0
	self.NextUse = CurTime()
	self:CreateWireInputs("DisableSounds")
	self:CreateWireOutputs("Health","Active","Player Health","Player Health [STRING]","Entity [ENTITY]")
	self:SetWireOutputs("Health", self:GetNetworkedInt("health"))
	self:SetWireOutputs("Player Health (Text)","")
end

function ENT:TriggerInput(variable, value)
	if variable == "DisableSounds" then
		if value == 1 then
			self.DisableSound = true
		else
			self.DisableSound = false
		end
	end
end

function ENT:PlaySound(sound)
	if not self.DisableSound then
		self:EmitSound(sound,100,100);
	end
end

function ENT:StopSound(sound)
	if not self.DisableSound then
		self:StopSound(sound)
	end
end

function ENT:SpawnFunction( ply, tr)
	if (!tr.Hit) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;
	local ent = ents.Create("eap_sarcophage");
	ent:SetPos(tr.HitPos+Vector(0,0,30));
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;
	return ent
end

function ENT:OnTakeDamage(dmg)
	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	self:SetWireOutputs("Health", self:GetNetworkedInt("health"))
	if((health-dmg:GetDamage())<=0) then
		self:Bang(); -- Go boom
	end
end

function ENT:Bang(p)
	self:EmitSound(Sound("jumper/JumperExplosion.mp3"),100,100); --Play the jumper's explosion sound(Only good explosion sound i have)
	local fx = EffectData();
		fx:SetOrigin(self:GetPos());
		util.Effect("dirtyxplo",fx);

	if(self.Active) then
		self:Exit(true); --Let the player out...
	end
	self:Remove(); --Get rid of the vehicle
end

 
function ENT:Use(ply)
	if self.Active and self.Pilot != nil then
		if self.Pilot == ply then
			self:Exit()
		else
			ply:PrintMessage(HUD_PRINTTALK,Lib.Language.GetMessage("ent_sarco_god_inside"));
			self.Pilot:PrintMessage(HUD_PRINTTALK,ply:Nick()..""..Lib.Language.GetMessage("ent_sarco_enter"));
		end
	else
		if ply:Health() < self.MaxHealth then
			self:Enter(ply);
		else
			ply:PrintMessage(HUD_PRINTTALK,Lib.Language.GetMessage("ent_sarco_full"));
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if self.Active and IsValid(self.Pilot) then
		if self.Pilot:KeyDown(IN_USE) then
			self:Exit()
		elseif self.Pilot:Health() >= self.MaxHealth then
			self:Exit()
		else
			self:HealPlayer(self.Pilot)
		end
	else
		self:SetWireOutputs("Active",0)
	end
	self:NextThink(CurTime()+0.5)
	return true;
end

function ENT:HealPlayer(ply)
	if ply:Health() < self.MaxHealth then
		ply:SetHealth(ply:Health()+self.HealthNumber);
		if ply:Health() > self.MaxHealth then ply:SetHealth(self.MaxHealth) end
		self.health = ply:Health()
	end
end

function ENT:Enter(ply) --############### Get in the jumper @ RononDex
	self:GetPhysicsObject():Wake()
	self.Active = true
	self:SetWireOutputs("Active",1)
	self:SetWireOutputs("Entity",ply)
	self.Pilot = ply
	self.health = ply:Health()
	self.armor = ply:Armor()
	self.PlayerActiveWeapon = ply:GetActiveWeapon()
	ply:SetPos(self:GetPos())
	ply:SetNWEntity("sarcophagus",self)
	ply:Spectate(OBS_MODE_CHASE); --Spectate the vehicle
	ply:DrawWorldModel(false);
	ply:DrawViewModel(false);
	ply:SetMoveType(MOVETYPE_OBSERVER);
	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	for _,v in pairs(ply:GetWeapons()) do
		table.insert(self.PlayerWeapons, v:GetClass())
	end
	if(ply:FlashlightIsOn()) then
		ply:Flashlight(false); --Turn the plylayer's flashlight off when Flying
	end
	ply:SetViewEntity(self)
	ply:StripWeapons()
	ply:SetNetworkedEntity("ScriptedVehicle", self)
	ply:SetViewEntity(self)
	self.StartPos = self:GetPos()
	self:SetNWBool("healing",true);
	ply:SetEyeAngles(self:GetAngles());
	self:PlaySound(self.Sounds.Enter)
end

function ENT:Exit(kill) --################# Get out the jumper@RononDex
		local ply = self.Pilot
		ply:UnSpectate()
		ply:DrawViewModel(true)
		ply:DrawWorldModel(true)
		ply:SetNWBool("healing",false)
		ply:SetNetworkedEntity( "ScriptedVehicle", NULL )
		ply:Spawn()
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetViewEntity(NULL)
		ply:SetHealth(self.health)
		ply:SetPos(self:GetPos()+Vector(0,0,40));
		ply:SetParent()
		ply:SetMoveType(MOVETYPE_WALK);
		ply:SetCollisionGroup(COLLISION_GROUP_PLAYER);
		ply:DrawViewModel(true)
		ply:DrawWorldModel(true)
		for k,v in pairs(self.PlayerWeapons) do
			ply:Give(tostring(v))
		end
		table.Empty(self.PlayerWeapons);
		ply:SetHealth(self.health);
		ply:SetArmor(self.armor);
		//ply:SetActiveWeapon(self.PlayerActiveWeapon)
		// Kill Player if was in sarcophagus when it was detroy
		if (kill) then ply:Kill(); end
		// Global Variable definitions
		self:SetNWEntity("sarcophagus",nil)
		self.Active = false
		self.Pilot = NULL
		self:PlaySound(self.Sounds.Exit)
		// Wire Outputs definitions
		self:SetWireOutputs("Active",0)
		self:SetWireOutputs("Entity",NULL)
		self:SetWireOutputs("Player Health",0)
		self:SetWireOutputs("Player Health (Text)","")
end

function ENT:OnRemove()
	if(self.Active and self.Pilot)then
		self:Exit()
	end
	if timer.Exists("SarcophagusHealth"..self:EntIndex()) then timer.Destroy("SarcophagusHealth"..self:EntIndex()); end
	self:Remove()
end

function ENT:CreateWireInputs(...)
	self.Inputs = Wire_CreateInputs(self,{...});
end

function ENT:CreateWireOutputs(...)
	self.Outputs = Wire_CreateOutputs(self,{...}); -- Old way, kept if I need to revert
end

function ENT:SetWireOutputs(name,value)
	Wire_TriggerOutput(self,name,value)
end