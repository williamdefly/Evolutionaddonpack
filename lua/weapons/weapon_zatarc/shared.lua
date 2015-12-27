-- Read the weapon_real_base if you really want to know what each action does

local LaserHitImpact = function(attacker, tr, dmginfo)

	local laserhit = EffectData()
	laserhit:SetOrigin(tr.HitPos)
	laserhit:SetNormal(tr.HitNormal)
	laserhit:SetScale(30)
	util.Effect("effect_ryan_laser_hit", laserhit)

	return true
end

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "pistol"
end

if (CLIENT) then
	SWEP.PrintName 			= "Zatarc goauld"
	SWEP.Slot 				= 2
end

SWEP.EjectDelay				= 0

SWEP.Author = "Williamdefly"
SWEP.Contact = "http://sg-e.fr"
SWEP.Purpose = "Tuer les tous les autres races sur votre passage !"

SWEP.Base 					= "zatarc_gun_base"
SWEP.Category				= "EAP"
SWEP.MuzzleEffect			= "ryan_muzzle_laser" -- This is an extra muzzleflash effect


SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.UseHands 				= true
SWEP.HoldType 				= "pistol"
SWEP.ViewModelFlip 			= true
SWEP.ViewModelFOV			= 60

SWEP.ViewModel				= "models/weapons/v_models/v_zatarc.mdl"
SWEP.WorldModel				= "models/weapons/w_zatarc.mdl"

SWEP.Primary.Sound 			= Sound("eap/weapons/zar.wav")
SWEP.Primary.Recoil 		= 1.4
SWEP.Primary.Damage 		= math.Rand(23,48)
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= math.Rand(0.01,0.044)
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip    = 60
SWEP.Primary.Delay 			= 0.19
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Primary.AmountOfBullet = 1

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos = Vector(4.349, -1.331, 2.973)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	

		timer.Create( "laser_timer", 0.05, 1, function()
		self:RecoilPower()
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end )

	self:TakePrimaryAmmo(1)
	self.Weapon:EmitSound(self.Primary.Sound)

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

function SWEP:CSShootBullet(dmg, recoil, numbul, cone)

	numbul 			= self.Primary.AmountOfBullet or 1
	cone 			= self.Primary.Cone or 0.11

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Source
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Aim Cone
	bullet.Tracer 	= 1       									-- Show a tracer on every x bullets
	bullet.TracerName 	= "effect_ryan_laser"
	bullet.Force 	= 0.5 * dmg     								-- Amount of force to give to phys objects
	bullet.Damage 	= dmg										-- Amount of damage to give to the bullets
	bullet.Callback 	= LaserHitImpact
	
	self.Owner:FireBullets(bullet)					-- Fire the bullets
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)      	-- View model animation
	self.Owner:MuzzleFlash()        					-- Crappy muzzle light

	self.Owner:SetAnimation(PLAYER_ATTACK1)       			-- 3rd Person Animation

	local fx 		= EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.MuzzleAttachment)
	util.Effect(self.MuzzleEffect,fx)					-- Additional muzzle effects
	
	timer.Simple( self.EjectDelay, function()
		if  not IsFirstTimePredicted() then 
			return
		end

			local fx 	= EffectData()
			fx:SetEntity(self.Weapon)
			fx:SetNormal(self.Owner:GetAimVector())
			fx:SetAttachment(self.ShellEjectAttachment)

			util.Effect(self.ShellEffect,fx)				-- Shell ejection
	end)

	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end

function SWEP:RecoilPower()
	if(self.Owner:IsValid() and self.Owner:Alive()) then
			if not self.Owner:IsOnGround() then
				if (self:GetIronsights() == true) then
					self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
				else
					self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * math.Rand(-2.5,2.5), self.Primary.NumShots, self.Primary.Cone)
				end

			elseif self.Owner:KeyDown(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT) then
				if (self:GetIronsights() == true) then
					self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
			
				else
					self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 1.5, self.Primary.NumShots, self.Primary.Cone)
			
				end

			elseif self.Owner:Crouching() then
				if (self:GetIronsights() == true) then
					self:CSShootBullet(self.Primary.Damage, 0, self.Primary.NumShots, self.Primary.Cone)
				else
					self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
				end
			else
				if (self:GetIronsights() == true) then
					self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 6, self.Primary.NumShots, self.Primary.Cone)
			
				else
					self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
				
				end
			end
	else end
end

if CLIENT then

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/zatarc_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/zatarc_inventory");
end

end