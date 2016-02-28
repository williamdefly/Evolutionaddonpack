if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end


ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "base_anim"
ENT.Type = "vehicle"

ENT.PrintName = Lib.Language.GetMessage('ent_ship_jumper');
ENT.Author = "RononDex, Iziraider, Boba Fett"
ENT.Category = Lib.Language.GetMessage("cat_ship");
ENT.AutomaticFrameAdvance = true

list.Set("EAP", ENT.PrintName, ENT);

function ENT:InJumper(p)
	local bound1,bound2 = self:GetCollisionBounds();
	local pos = self:WorldToLocal(p:GetPos());
	if((pos.x > bound1[1]+20) and (pos.x < bound2[1]-100) and (pos.y > bound1[2]+70) and (pos.y < bound2[2]-70) and (pos.z > bound1[3]) and (pos.z < bound2[3])) then
		return true;
	end
	return false;
end