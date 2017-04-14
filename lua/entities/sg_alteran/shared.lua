ENT.Type = "anim"
ENT.Base = "sg_base"
ENT.PrintName = "Stargate (ALTERAN)"
ENT.Author = "aVoN, Madman07, Llapp, Rafael De Jongh, AlexALX"
ENT.Category = ""
ENT.Spawnable = true

ENT.WireDebugName = "Stargate ALTERAN"
list.Set("EAP", ENT.PrintName, ENT);

ENT.EventHorizonData = {
	OpeningDelay = 0.9,
	OpenTime = 2.2,
	NNFix = 0,
	Type = "atlantis",
}

function ENT:GetRingAng()
	if not IsValid(self.EntRing) then self.EntRing=self:GetNWEntity("EntRing") if not IsValid(self.EntRing) then return end end   -- Use this trick beacause NWVars hooks not works yet...
	local angle = tonumber(math.NormalizeAngle(self.EntRing:GetLocalAngles().r));
	return (angle<0) and angle+360 or angle
end