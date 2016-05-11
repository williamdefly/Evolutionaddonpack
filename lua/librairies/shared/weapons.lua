MsgN('librairies/shared/weapons.lua');

if(SERVER)then
	hook.Add("PlayerSwitchWeapon", "Lib.WeaponCheck.Changed", function(ply, weapon1, weapon2)
		if (not ply or not IsValid(ply) or not ply:IsPlayer() or not IsValid(weapon1) or not IsValid(weapon2)) then return end
		-- if we changed to weapon atanik_armband
		if (weapon2:GetClass()=="eap_atanik_armband") then
			ply:SetRunSpeed(1000)
		    ply:SetJumpPower(500)
			ply:SetArmor(200)
			ply.EAP_Atanik = true
		-- if we changed from weapon atanik_armband to another
		elseif (weapon1:GetClass()=="eap_atanik_armband") then
		    ply:SetRunSpeed(500)
			ply:SetJumpPower(200)
			ply:SetArmor(0)
			ply.EAP_Atanik = nil
		end
		-- PLEASE DO NOT EDIT! it works perfect in sp and mp! Don't touch code!
	end)
end