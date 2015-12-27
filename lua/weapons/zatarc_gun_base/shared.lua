-- English is not my first language, so sorry if I did some errors in my little "tutorial"

/*---------------------------------------------------------*/
local HitImpact = function(attacker, tr, dmginfo)

	local hit = EffectData()
	hit:SetOrigin(tr.HitPos)
	hit:SetNormal(tr.HitNormal)
	hit:SetScale(30)
	util.Effect("effect_fo3_hit", hit)

	return true
end
/*---------------------------------------------------------*/

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight 		= 5
	SWEP.HoldType		= "ar2"		-- Hold type style ("ar2" "pistol" "shotgun" "rpg" "normal" "melee" "grenade" "smg")
end


if (CLIENT) then
	SWEP.DrawAmmo		= true		-- Should we draw the number of ammos and clips?
	SWEP.DrawCrosshair	= false		-- Should we draw the half life 2 crosshair?
	SWEP.ViewModelFOV		= 50			-- "Y" position of the sweps
	SWEP.ViewModelFlip	= true		-- Should we flip the sweps?
	SWEP.CSMuzzleFlashes	= false		-- Should we add a CS Muzzle Flash?

surface.CreateFont( "Firemode", {
	font 		= "HalfLife2",
	size 		= 60,
	weight 		= 500,
	antialias 	= true,
	underline 	= true
} )
	
surface.CreateFont( "CSSelectIcons", {
	font 		= "csd",
	size 		= 60,
	weight 		= 500,
	antialias 	= true,
	underline 	= true
} )

surface.CreateFont( "CSKillIcons", {
	font 		= "csd",
	size 		= 30,
	weight 		= 500,
	antialias 	= true,
	underline 	= true
} )
end

/*---------------------------------------------------------
Muzzle Effect + Shell Effect
---------------------------------------------------------*/
SWEP.MuzzleEffect			= "fo3_muzzle_rifle" -- This is an extra muzzleflash effect
-- Available muzzle effects: rg_muzzle_grenade, rg_muzzle_highcal, rg_muzzle_hmg, rg_muzzle_pistol, rg_muzzle_rifle, rg_muzzle_silenced, none

SWEP.ShellEffect			= "rg_shelleject_rifle" -- This is a shell ejection effect
-- Available shell eject effects: rg_shelleject, rg_shelleject_rifle, rg_shelleject_shotgun, none

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" -- Should be "2" for CSS models or "1" for hl2 models
/*-------------------------------------------------------*/

SWEP.Category			= ""		-- Swep Category (You can type what your want)

SWEP.DrawWeaponInfoBox  	= true					-- Should we draw a weapon info when you're selecting your swep?

SWEP.Author 			= ""		-- Author Name
SWEP.Contact 			= ""						-- Author E-Mail
SWEP.Purpose 			= ""						-- Author's Informations
SWEP.Instructions 		= ""	
SWEP.Spawnable 			= false					-- Everybody can spawn this swep
SWEP.AdminSpawnable 		= false					-- Admin can spawn this swep

SWEP.Weight 			= 5						-- Weight of the swep
SWEP.AutoSwitchTo 		= false
SWEP.AutoSwitchFrom 		= false

SWEP.Primary.Sound 		= Sound("Weapon_AK47.Single")		-- Sound of the gun
SWEP.Primary.Recoil 		= 0						-- Recoil of the gun
SWEP.Primary.Damage 		= 0						-- Damage of the gun
SWEP.Primary.NumShots 		= 0						-- How many bullet(s) should be fired by the gun at the same time
SWEP.Primary.Cone 		= 0						-- Precision of the gun
SWEP.Primary.ClipSize 		= 0						-- Number of bullets in 1 clip
SWEP.Primary.Delay 		= 0						-- Exemple: If your weapon shoot 800 bullets per minute, this is what you need to do: 1 / (800 / 60) = 0.075
SWEP.Primary.DefaultClip 	= 0						-- How many ammos come with your weapon (ClipSize + "The number of ammo you want"). If you don't want to add additionnal ammo with your weapon, type the ClipSize only!
SWEP.Primary.Automatic 		= false					-- Is the weapon automatic? 
SWEP.Primary.Ammo 		= "none"					-- Type of ammo ("pistol" "ar2" "grenade" "smg1" "xbowbolt" "rpg_round" "351")

SWEP.SprintPos = Vector(-2,2,0) 
SWEP.SprintAng = Vector(-10,-30,10) 

SWEP.NewAngle = Vector(0,0,0)		--Define Idle position
SWEP.NewAngleAng = Vector(0,0,0)	--Define Idle Angle
SWEP.WalkAngle = Vector(0,0,0.5) 	--Define Idle position while moving

SWEP.Secondary.ClipSize 	= 0
SWEP.Secondary.DefaultClip 	= 0
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.data 				= {}
SWEP.mode 				= "semi" 					-- The starting firemode
SWEP.data.ironsights		= 1

SWEP.data.semi 			= {}
SWEP.data.semi.FireMode		= "p"

SWEP.data.auto 			= {}
SWEP.data.auto.FireMode		= "ppppp"

SWEP.data.burst			= {}
SWEP.data.burst.FireMode	= "ppp"

/*---------------------------------------------------------
Auto/Semi/Burst Configuration
---------------------------------------------------------*/
function SWEP.data.semi.Init(self)

	self.Primary.Automatic = false
	self.Weapon:EmitSound("eap/weapons/zar.wav")
	self.Weapon:SetNetworkedInt("firemode", 3)
end

function SWEP.data.auto.Init(self)

	self.Primary.Automatic = true
	self.Weapon:EmitSound("eap/weapons/zar.wav")
	self.Weapon:SetNetworkedInt("firemode", 1)
end

function SWEP.data.burst.Init(self)

	self.Primary.Automatic = false
	self.Weapon:EmitSound("eap/weapons/zar.wav")
	self.Weapon:SetNetworkedInt("firemode", 2)
end

/*---------------------------------------------------------
IronSight
---------------------------------------------------------*/
function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Ironsights", b )
self.Owner:SetFOV( 65, 0.15 )

end


SWEP.NextSecondaryAttack = 0

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
self:SetWeaponHoldType( self.HoldType )
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
/*
function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firering, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.15 )
		-- Zoom = 0

		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end
*/
/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying

	self.Reloadaftershoot = CurTime() + 1
	-- Can't shoot while deploying

	self:SetIronsights(false)
	-- Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	return true
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	-- If your gun have a problem or if you are under water, you'll not be able to fire

	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	-- Set the reload after shoot to be not able to reload when firering

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	-- Set next secondary fire after your fire delay

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	-- Set next primary fire after your fire delay

	self.Weapon:EmitSound(self.Primary.Sound)
	-- Emit the gun sound when you fire

	self:RecoilPower()

	self:TakePrimaryAmmo(1)
	-- Take 1 ammo in you clip

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

if !self.Owner:KeyDown(IN_USE) then

	
	bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
	
	self:SetIronsights( bIronsights )
	
	self.NextSecondaryAttack = CurTime() + 0.3
	end
end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) and self.Primary.ClipSize > -1 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("weapons/stunstick/spark1.wav")
		return false
	end
	return true
end

/*---------------------------------------------------------
GetViewModelPosition
---------------------------------------------------------*/
local IRONSIGHT_TIME = 0.25
-- Time to enter in the ironsight mod

function SWEP:GetViewModelPosition(pos, ang)

	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNWBool("Ironsights")

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if (bIron) then
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 1.8
			self.BobScale 	= 2.0
		end
	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

/*---------------------------------------------------------
SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights(b)

	self.Weapon:SetNetworkedBool("Ironsights", b)
end

function SWEP:GetIronsights()

	return self.Weapon:GetNWBool("Ironsights")
end

/*---------------------------------------------------------
RecoilPower
---------------------------------------------------------*/
function SWEP:RecoilPower()

	if not self.Owner:IsOnGround() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 2.5, self.Primary.NumShots, self.Primary.Cone)
		end

	elseif self.Owner:KeyDown(IN_FORWARD , IN_BACK , IN_MOVELEFT , IN_MOVERIGHT) then
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
end

function SWEP:Holster( wep )
	return true
end

/*---------------------------------------------------------
ShootBullet
---------------------------------------------------------*/
function SWEP:CSShootBullet(dmg, recoil, numbul, cone)

	numbul 		= numbul or 1
	cone 			= cone or 0.01

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Source
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Aim Cone
	bullet.Tracer 	= 1       									-- Show a tracer on every x bullets
	bullet.Force 	= 0.5 * dmg     								-- Amount of force to give to phys objects
	bullet.Damage 	= dmg										-- Amount of damage to give to the bullets
	bullet.Callback 	= HitImpact
-- 	bullet.Callback	= function ( a, b, c ) BulletPenetration( 0, a, b, c ) end 	-- CALL THE FUNCTION BULLETPENETRATION

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

if( CLIENT ) then

    local SparkMaterial = CreateMaterial( "ignv/bullet", "UnlitGeneric", {
        [ "$basetexture" ]    = "sprites/orangeflare1",
        [ "$brightness" ]    = "effects/spark_brightness",
        [ "$additive" ]        = "1",
        [ "$vertexcolor" ]    = "1",
        [ "$vertexalpha" ]    = "1",
    } );
    
    local EFFECT = {};
    
    
    --[[------------------------------------
        Init()
    ------------------------------------]]
    function EFFECT:Init( data )
    
        local weapon = data:GetEntity();
        local attachment = data:GetAttachment();
                
        local startPos = GetMuzzlePosition( weapon, attachment );
        local endPos = data:GetOrigin();
        local distance = ( startPos - endPos ):Length();
        
        self.StartPos = startPos;
        self.EndPos = endPos;
        self.Normal = ( endPos - startPos ):GetNormal();
        self.Length = math.random( 128, 500 );
        self.Magnitude = 50;
        self.StartTime = CurTime();
        self.DieTime = CurTime() + ( distance + self.Length ) / 15000;
        
    end
    
    
    --[[------------------------------------
        Think()
    ------------------------------------]]
    function EFFECT:Think()
        
        return self.DieTime >= CurTime();
        
    end
    
    
    --[[------------------------------------
        Render()
    ------------------------------------]]
    function EFFECT:Render()
    
        local time = CurTime() - self.StartTime;
    
        local endDistance = 15000 * time;
        local startDistance = endDistance - self.Length;
        
        // clamp the start distance so we don't extend behind the weapon
        startDistance = math.max( 0, startDistance );
        
        local startPos = self.StartPos + self.Normal * startDistance;
        local endPos = self.StartPos + self.Normal * endDistance;
        
        // draw the beam
        render.SetMaterial( SparkMaterial );
        render.DrawBeam( startPos, endPos, 25, 0, 1, Color( 255, 255, 255, 255 ) );
    
    end
    
    effects.Register( EFFECT, "HardcoreBullet" );
    
end