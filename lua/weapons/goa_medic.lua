SWEP.PrintName = SGLanguage.GetMessage("wp_goauld_medical");
SWEP.ClassName  ="goauld_medic"

SWEP.Category			= "EAP"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Author = "Williamdefly"
SWEP.Contact = "http://sg-e.fr"
SWEP.Purpose = "Soigner vos alliés !"
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 5;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/v_goaregen.mdl";
SWEP.WorldModel = "models/weapons/weapons/w_goamedic.mdl";
SWEP.HoldType = "normal"

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

--################### Open Gate dialogue and overwrite default method @Madman07
function SWEP:PrimaryAttack()
	if(CLIENT) then return end;

	local tr = self.Owner:GetEyeTrace();
	if (IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 500 and tr.Entity:Health()<150) then
		tr.Entity:SetHealth(math.Clamp(tr.Entity:Health()+1, 0, 150));
		local fx = EffectData();
		fx:SetScale(spectating);
		fx:SetEntity(self.Owner);
		fx:SetOrigin(self.Owner:GetShootPos());
		util.Effect("hd_kill",fx,true,true);
	end
	self:SetNextSecondaryFire(CurTime()+0.1);
end

function SWEP:SecondaryAttack()
	return false
end

--################### Tell a player how to use this @aVoN

if SERVER then

function SWEP:OnDrop()
	self:SetNWBool("WorldNoDraw",false);
	return true;
end

function SWEP:Equip()
	self:SetNWBool("WorldNoDraw",true);
	return true;
end

end

if CLIENT then

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