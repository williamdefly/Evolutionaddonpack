SWEP.PrintName = Lib.Language.GetMessage("wp_ori_hand");
SWEP.ClassName  ="eap_ori_handweapon";

SWEP.Category			= "EAP"

SWEP.Author = "Elanis"
SWEP.Contact = "http://sg-e.fr"
SWEP.Purpose = "Soigner vous et devenez plus fort et resistant !"

SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = true;
SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false

SWEP.Spawnable = true

SWEP.ViewModel      = "models/weapons/v_arms2.mdl"

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 50;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "HelicopterGun";

--secondary
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 30
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

util.PrecacheSound("dagger/knife_deploy1.wav")
util.PrecacheSound("dagger/knife_hitwall1.wav")
util.PrecacheSound("dagger/knife_hit1.wav")
util.PrecacheSound("dagger/knife_hit2.wav")
util.PrecacheSound("dagger/knife_hit3.wav")
util.PrecacheSound("dagger/knife_hit4.wav")
util.PrecacheSound("dagger/knife_slash1.wav")

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile();
end

function SWEP:Deploy()
	if (IsValid(self.Weapon)) then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW); -- Animation
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( "knife" )

	self.Hit = Sound( "dagger/knife_hitwall1.wav" );
	self.Slash = Sound( "dagger/knife_slash1.wav" );
	self.FleshHit = {
		[1] = Sound( "dagger/knife_hit1.wav" ),
		[2] = Sound( "dagger/knife_hit2.wav" ),
		[3] = Sound( "dagger/knife_hit3.wav" ),
		[4] = Sound( "dagger/knife_hit4.wav" )
	};

	self.NextHit = 0;

end

function SWEP:Effects() --###### Energy Muzzle and Recoil Effect @RononDex,aVoN

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	-- Shot
	self.Weapon:SetNextPrimaryFire(CurTime()+0.5);
--	return true;
end

function IdleAnim(Owner)
	timer.Create( "remettonpoingnormal", 0.5, 1, function()

	Owner:SetAnimation( PLAYER_IDLE );
	
	local vm = Owner:GetViewModel();
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle1" ) )

	end )
end

function SWEP:PrimaryAttack() --###### Shoot @Ronondex, aVoN

	if timer.Exists("remettonpoingnormal") then
	timer.Destroy("remettonpoingnormal")
	end

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;

	self:Effects()

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	
	local vm = self.Owner:GetViewModel();
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "hitkill1" ) )

	if(SERVER) then

		local p = self.Owner;
		local multiply = 3; -- Default inaccuracy multiplier
		local aimvector = p:GetAimVector();
		local shootpos = p:GetShootPos();
		local vel = p:GetVelocity();
		local filter = {self.Owner,self.Weapon};

		-- Add inaccuracy for players!
		if(p:IsPlayer()) then
			local right = aimvector:Angle():Right();
			local up = aimvector:Angle():Up();
			-- Check, how far we can go to right (avoids exploding shots on the wall right next to you)
			local max = util.QuickTrace(shootpos,right*100,filter).Fraction*100 - 10;
			local trans = right:DotProduct(vel)*right/25
			if(p:Crouching()) then
				multiply = 0.3; -- We are in crouch - Make it really accurate!
				-- We need to adjust shootpos or it will look strange
				shootpos = shootpos + math.Clamp(15,-10,max)*right - 4*up + trans;
			else
				-- He stands
				shootpos = shootpos + math.Clamp(23,-10,max)*right - 15*up + trans;
			end
			multiply = multiply*math.Clamp(vel:Length()/500,0.3,3); -- We are moving - Make it inaccurate depending on the velocity
		else -- It's an NPC
			multiply = 0;
		end
		-- Now, we need to correct the velocity depending on the changed shootpos above.
		local trace = util.QuickTrace(p:GetShootPos(),16*1024*aimvector,filter);
		if(trace.Hit) then
			aimvector = (trace.HitPos-shootpos):GetNormalized();
		end
		local e = ents.Create("energy_pulse")
		e:SetPos(shootpos + p:GetForward()*94 + p:GetRight()*-15 + p:GetUp()*5)
		e:PrepareBullet(aimvector, multiply, 8000, 2);
		e:SetOwner(p);
		e.Owner = p;
		e.Damage = 100;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(119,176,255,215))
		p:EmitSound(Sound("pulse_weapon/ori_staff.wav"),90,math.random(90,110));
		if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	end
	
	IdleAnim(self.Owner)
	
end

function SWEP:SecondaryAttack()

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	
	local vm = self.Owner:GetViewModel();
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "hitkill2" ) )

	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 1 );

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );

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
	return true
end