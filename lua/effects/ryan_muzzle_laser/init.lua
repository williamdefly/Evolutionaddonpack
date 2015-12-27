/*---------------------------------------------------------
	EFFECT:Init(data)
---------------------------------------------------------*/
function EFFECT:Init(data)
	
	self.WeaponEnt 		= data:GetEntity()
	self.Attachment 		= data:GetAttachment()
	
	self.Position 		= self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward 		= data:GetNormal()
	self.Angle 			= self.Forward:Angle()
	self.Right 			= self.Angle:Right()
	self.Up 			= self.Angle:Up()
	

	
	local emitter 		= ParticleEmitter(self.Position)

					local particle = emitter:Add("sprites/ar2_muzzle"..math.random(3,4), self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(math.Rand(0, 0.05))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(0)
			particle:SetEndSize(15)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 92, 92)	

					local particle = emitter:Add("effects/redflare", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(5)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)
			
								local particle = emitter:Add("effects/redflare", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(15)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)
			
					local particle = emitter:Add("effects/redflare", self.Position)

			particle:SetVelocity(100 * self.Forward + 8 * VectorRand()) -- + AddVel)
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))

			particle:SetDieTime(math.Rand(0, 1))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(math.Rand(10, 13))
			particle:SetEndSize(0)

			particle:SetRoll(math.Rand(-25, 25))
			particle:SetRollDelta(math.Rand(-0.05, 0.05))

			particle:SetColor(255, 255, 255)

	emitter:Finish()
end

/*---------------------------------------------------------
	EFFECT:Think()
---------------------------------------------------------*/
function EFFECT:Think()

	return false
end

/*---------------------------------------------------------
	EFFECT:Render()
---------------------------------------------------------*/
function EFFECT:Render()
end
