EFFECT.MaxWidth = 500

local balloon = surface.GetTextureID("effect/balloon001")
local heart = surface.GetTextureID("effect/heart")
function EFFECT:Init(data)
	self:SetPos(data:GetStart())
	self.Col = Color(math.random()*255, math.random()*255, math.random()*255)
	self.xDir = (math.random() * 0.2) - 0.1
	self.yDir = (math.random() * 0.2) - 0.1
	self.zDir = (math.random() * 0.1) + 0.1
	self.life = (math.random() * 15) + 10
	self.Popping = false
end

function EFFECT:Think()
	self.life = self.life - 0.1
	local trace = {start = self:GetPos(), endpos = self:GetPos() + Vector(0, 0, 5), filter = self}
	local tr = util.TraceEntity(trace, self)
	if (!tr.Hit) then
		self.zDir = self.zDir + (math.random() * 0.02)
	else
		self.zDir = 0
	end
	self:SetPos(self:GetPos() + Vector(self.xDir - math.sin(self.life)*(math.random()*0.2), self.yDir + math.sin(self.life)*(math.random()*0.2), self.zDir))
	if (self.life <= 0) then 
		self.Popping = true
		sound.Play("effect/balloon_pop.wav", self:GetPos())
		for i=0,10 do
			data = EffectData()
			data:SetStart(self:GetPos())
			data:SetOrigin(self:GetPos())
			data:SetEntity(self:GetOwner())
			data:SetScale(0.2)
			data:SetFlags(16)
			util.Effect("hearts", data)
		end
		return false
	end
	return true
end

function EFFECT:Render()
	local ang = LocalPlayer():EyeAngles()
	ang:RotateAroundAxis(LocalPlayer():GetForward(), 270)
	ang:RotateAroundAxis(LocalPlayer():GetRight(), -180)
	ang:RotateAroundAxis(LocalPlayer():GetUp(), 90)
	ang = Angle(0, ang.y, ang.r)

	if (!self.Popping) then
	cam.Start3D2D(self:GetPos(), ang, 0.1)
		surface.SetDrawColor(self.Col)
		surface.SetTexture(balloon)
		surface.DrawTexturedRect(-surface.GetTextureSize(balloon)/2, -surface.GetTextureSize(balloon), surface.GetTextureSize(balloon), surface.GetTextureSize(balloon))
	cam.End3D2D()
	end
end