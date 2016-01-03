SWEP.PrintName = SGLanguage.GetMessage("wp_goa_symb");
SWEP.Category = "EAP"
SWEP.ClassName  ="eap_larve"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Author = "Williamdefly"
SWEP.Contact = "http://sg-e.fr"
SWEP.Purpose = ""

SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = true;
SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false

SWEP.ViewModel      = "models/weapons/v_larve.mdl"
SWEP.WorldModel   = "models/weapons/w_larve.mdl"

SWEP.Primary.Delay			= 0.9
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 10000
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "none"

SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 110000
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

util.PrecacheSound("eap/weapons/larve.wav")
util.PrecacheSound("eap/weapons/larve.wav")
util.PrecacheSound("eap/weapons/larve.wav")
util.PrecacheSound("eap/weapons/larve.wav")
util.PrecacheSound("eap/weapons/larve.wav")
util.PrecacheSound("eap/weapons/larve.wav")
util.PrecacheSound("eap/weapons/larve.wav")

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile();
end

function SWEP:Initialize()
	self:SetWeaponHoldType( "knife" )

	self.Hit = Sound( "eap/weapons/larve.wav" );
	self.Slash = Sound( "eap/weapons/larve.wav" );
	self.FleshHit = {
		[1] = Sound( "eap/weapons/larve.wav" ),
		[2] = Sound( "eap/weapons/larve.wav" ),
		[3] = Sound( "eap/weapons/larve.wav" ),
		[4] = Sound( "eap/weapons/larve.wav" )
	};

	self.NextHit = 0;

end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 0.5 );

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );

 	local tr = self.Owner:GetEyeTrace();
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then

		if (SERVER) then
			local ent = tr.Entity
			if( ent:IsPlayer() or ent:IsNPC() or ent:GetClass()=="prop_ragdoll" ) then
				self.Owner:EmitSound(self.FleshHit[math.random(1,4)]);
			else
				self.Owner:EmitSound(self.Hit);
			end
		end
		self.Weapon:Hurt(5);

	elseif SERVER then self.Weapon:EmitSound(self.Slash) end

end

function SWEP:SecondaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 1 );

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );

 	local tr = self.Owner:GetEyeTrace();
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then

		if (SERVER) then
			local ent = tr.Entity
			if( ent:IsPlayer() or ent:IsNPC() or ent:GetClass()=="prop_ragdoll" ) then
				self.Owner:EmitSound(self.FleshHit[math.random(1,4)]);
			else
				self.Owner:EmitSound(self.Hit);
			end
		end
		self.Weapon:Hurt(10);

	elseif SERVER then self.Weapon:EmitSound(self.Slash) end


end

function SWEP:Hurt(damage)
	bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0.1, 0.1, 0)
	bullet.Tracer = 0
	bullet.Force  = 10
	bullet.Damage = damage
	self.Owner:FireBullets(bullet)
end

function SWEP:Deploy()
	self.Owner:EmitSound( "eap/weapons/larve.wav" );
	return true
end

function SWEP:Precache() end

if CLIENT then

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/larve_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/larve_inventory");
end

end