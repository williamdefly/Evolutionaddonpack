SWEP.PrintName  = Lib.Language.GetMessage("wp_m9_berreta");
SWEP.ClassName  ="weapon_beretta";

SWEP.Author = "Matspyder"
SWEP.Contact = "http://sg-e.fr"
SWEP.Purpose = "Kill Goauld, Wraith and Ori"
SWEP.Instructions = ""
SWEP.Base = "weapon_base";
SWEP.Slot = 2;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/m9/v_pist_fiveseven.mdl";
SWEP.WorldModel = "models/weapons/m9/w_pist_fiveseven.mdl";
SWEP.HoldType = "SMG"

SWEP.Spawnable = true

SWEP.Category			= "EAP"


-- primary.
SWEP.Primary.ClipSize = 16;
SWEP.Primary.DefaultClip = 48;
SWEP.Primary.Ammo	= "pistol";
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil 		= 1
SWEP.Primary.Damage 		= 25
SWEP.Primary.NumShots 		= 1	
SWEP.Primary.Cone 		= 0.0135 
SWEP.Primary.Delay 		= 0.5


-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:PrimaryAttack()
	if ( self.Weapon:Clip1() > 0) then
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:TakePrimaryAmmo(1)
		self:RecoilPower()
		self.Weapon:EmitSound(Sound("eap/weapons/fiveseven/fiveseven-1.wav"),50,math.random(90,125));
		if (self.Weapon:Clip1() - 1) <= 0 then self.Weapon:SendWeaponAnim(ACT_VM_IDLE_EMPTY) end
	else
		self:Reload()
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:RecoilPower()
	if (not IsValid(self.Owner) or not self.Owner:IsPlayer() and not self.Owner:IsNPC()) then return end
	if not self.Owner:IsOnGround() then
		self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
		-- Recoil * 2.5

		if (self.Owner.ViewPunch) then self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil * 2.5), math.Rand(-1,1) * (self.Primary.Recoil * 2.5), 0)) end
		-- Punch the screen * 2.5
	elseif self.Owner:IsPlayer() and self.Owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * self.Primary.Recoil, math.Rand(-1,1) * (self.Primary.Recoil * 1.5), 0))
	elseif self.Owner:IsPlayer() and self.Owner:Crouching() then
		self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 3.0, self.Primary.NumShots, self.Primary.Cone)
		-- Recoil / 3

		self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 3), math.Rand(-1,1) * (self.Primary.Recoil / 2), 0))
		-- Screenpunch / 3
	else
		self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2.5, self.Primary.NumShots, self.Primary.Cone)
		-- Put normal recoil when you're not in ironsight mod

		if (self.Owner:IsPlayer()) then
			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * self.Primary.Recoil / 2.5, math.Rand(-1,1) *self.Primary.Recoil, 0))
		end
		-- Punch the screen
	end
end

function SWEP:CSShootBullet(dmg, recoil, numbul, cone)

	numbul 		= numbul or 1
	cone 			= cone or 0.01

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Bullet Source (start pos)
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Vector/direction of the bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Bullet Spread
	bullet.Tracer 	= 1       									-- Tracers per bullet
	bullet.Force 	= 0.65 * dmg     								-- Amount of force to apply to physical objects.
	bullet.Damage 	= dmg										-- Amount of bullet damage
	bullet.Callback 	= HitImpact
 	-- bullet.Callback	= function ( a, b, c ) BulletPenetration( 0, a, b, c ) end


	self.Owner:FireBullets(bullet)					-- Fire the round

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)   	-- View model animation

	self.Owner:MuzzleFlash()        					-- Default Muzzle flash

	self.Owner:SetAnimation(PLAYER_ATTACK1)       			-- World animation (3rd person)


	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		if (self.Owner:IsPlayer()) then
			self.Owner:SetEyeAngles(eyeang)
		end
	end
end