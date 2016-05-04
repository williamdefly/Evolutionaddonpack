AddCSLuaFile();

SWEP.PrintName = Lib.Language.GetMessage("wp_goauld_medical");
SWEP.ClassName  ="goa_medic"

SWEP.Category			= "EAP"

SWEP.Author = "Williamdefly"
SWEP.Contact = "http://sg-eap.fr"
SWEP.Purpose = "Soigner vos alliés !"
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 5;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/v_goaregen.mdl";
SWEP.WorldModel = "models/weapons/weapons/w_goamedic.mdl";
SWEP.HoldType = "normal"

SWEP.Spawnable = true

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:SecondaryAttack()
	return false
end

--################### Tell a player how to use this @aVoN

if SERVER then
	AddCSLuaFile();

	function SWEP:PrimaryAttack()
		local tr = self.Owner:GetEyeTrace();
		--if (IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 500 and tr.Entity:Health()<150) then
			tr.Entity:SetHealth(math.Clamp(tr.Entity:Health()+1, 0, 150));
			self:SetNextPrimaryFire(CurTime()+0.1);
			self:KillEffect();
		--end
	end

	function SWEP:KillEffect()
		local spectating = 1;
		if(self.Owner:IsPlayer() and self.Owner:GetViewEntity() == self.Owner) then spectating = 0 end;
		local fx = EffectData();
		fx:SetScale(spectating);
		fx:SetEntity(self.Owner);
		fx:SetOrigin(self.Owner:GetShootPos());
		util.Effect("goamedic",fx,true,true);
	end

	function SWEP:OnDrop()
		self:SetNWBool("WorldNoDraw",false);
		return true;
	end

	function SWEP:Equip()
		self:SetNWBool("WorldNoDraw",true);
		return true;
	end
else	
	function SWEP:DrawWorldModel()
		if (not self:GetNWBool("WorldNoDraw")) then
			self:DrawModel();
		end
	end
	-- Inventory Icon
	if(file.Exists("materials/VGUI/weapons/goamedic_inventory.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/goamedic_inventory");
	end
end