include('shared.lua')

function ENT:Draw()
    self:DrawModel() -- Draws Model Client Side
    //surface.SetDrawColor(0,0,0,255) -- Try to add White screen where we are inside
end