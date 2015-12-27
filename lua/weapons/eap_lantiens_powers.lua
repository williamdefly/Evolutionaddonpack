SWEP.PrintName = "Lantiens Powers"
SWEP.Category = "EAP"
SWEP.ClassName = "eap_lantiens_powers"

SWEP.Spawnable = true

SWEP.Author = "Matspyder"
SWEP.Contact = "http://sg-e.org/forum/"

SWEP.DrawAmmo 				= false
SWEP.DrawCrosshair 			= false

SWEP.ViewModel = "models/Weapons/V_hands.mdl";
SWEP.WorldModel = "models/weapons/w_bugbait.mdl";

SWEP.Primary.Ammo 			= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo 			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic = false

SWEP.Power = 0;
SWEP.MaxPower = 100;
SWEP.IncrementPower = 0.10;
SWEP.Used = false;

if SERVER then AddCSLuaFile(); end;

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
	self.Owner:SetNWInt("LantiensPowers",self.Power);
	self.Owner:SetNWInt("LantiensMaxPowers",self.MaxPower);
	self.Owner:SetNWInt("IncrementPowers",self.IncrementPowers);
	self.Mode = 1;
	if not self.Owner:GetNWBool("HaveTheLantiensPowers",false) then
		self.Owner:SetNWBool("HaveTheLantiensPowers",true);
	end
	self:NextThink(CurTime()+1)
end

timer.Create("EAP.LantiensPowers.Think",0.1,0,
	function()
		for _,v in pairs(player.GetAll()) do
			local valid = v:IsValid()
			local hw = v:HasWeapon("eap_lantiens_powers")
			local nhw = v:GetNWBool("HaveTheLantiensPowers", false)

			if valid then
				if hw then
					if v:GetNWInt("LantiensPowers") < v:GetNWInt("LantiensMaxPowers") then
						if not v.Used then
							v:SetNWInt("LantiensPowers",v:GetNWInt("LantiensPowers")+v:GetNWInt("IncrementPowers"));
							v:SetNWInt("LantiensPowers",v:GetNWInt("LantiensPowers"));
						end
					end
					if not nhw then
						v:SetNWBool("HaveTheLantiensPowers", true)
					end
				elseif nhw then
					v:SetNWBool("HaveTheLantiensPowers", false)
				end
			end
		end
	end
)

-- function SWEP:OnDrop()
-- 	if self.Owner:GetNWBool("HaveTheLantiensPowers",false) then
-- 		self.Owner:SetNWBool("HaveTheLantiensPowers",false);
-- 		self.Owner:SetNWBool("HaveTheLantiensPowers",nil);
-- 	end
-- end

function SWEP:PrimaryAttack()
	if self.Mode == 1 then
		local AimTrace = self.Owner:GetEyeTrace();
		if AimTrace.Hit then
			if AimTrace.Entity:IsPlayer() or AimTrace.Entity:IsNPC() then
				local ply = AimTrace.Entity;
				if ply:Health() <= ply:GetMaxHealth() then
					if self.Power >= 5 then
						ply:SetHealth(ply:Health()+1);
						self.Owner:PrintMessage(HUD_PRINTCENTER,/*"Vie de "..ply:Nick().." : "..*/ply:Health());
						self.Power = self.Power - 5;
						self.Used = true;
						timer.Create("InUsed",0.5,1,function()
							self.Used = false;
						end)
					else
						ply:SetHealth(ply:Health()+1);
						self.Owner:PrintMessage(HUD_PRINTCENTER,/*"Vie de "..ply:Nick().." : "..*/ply:Health());
						self.Owner:SetHealth(self.Owner:Health()-1)
						self.Used = true;
						timer.Create("InUsed",0.5,1,function()
							self.Used = false;
						end)
					end
					self:SetNextPrimaryFire(CurTime()+0.5);
				else
					//self.Owner:ChatPrint(ply:Nick().." à déjà sa vie au maximum");
				end
			end
		end
	end
end

if CLIENT then
	function HUDPaint()
		local ply = LocalPlayer();
		if not(ply:IsValid() and ply:GetNWBool("HaveTheLantiensPowers",false))then return end

		local a = 150;
		local strength = ply:GetNWInt("LantiensPowers",0)

		draw.RoundedBox(8,ScrW()/6,ScrH()/2-160,23,160,Color(255,0,0,a))
		draw.RoundedBox(8,ScrW()/6,ScrH()/2-1.6*strength,23,1.6*strength, Color(255,190,0,a*1.7))
		draw.DrawText(math.Round(strength).."%","Default",ScrW()/6,ScrH()/2-80,Color(255,255,255,255));
	end
	hook.Add("HUDPaint","EAP.LantiensPowers.HUD",HUDPaint)
end