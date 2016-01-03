include('shared.lua')

function ENT:Draw()
    self:DrawModel() -- Draws Model Client Side
    //surface.SetDrawColor(0,0,0,255) -- Try to add White screen where we are inside
end

function DrawHUD() -- Draw that HUD @Elanis

	local ply = LocalPlayer();
    local sarcophage = ply:GetNWEntity("sarcophagus")
	local self = ply:GetNetworkedEntity("ScriptedVehicle", NULL)

	if (self and self:IsValid() and sarcophage and sarcophage:IsValid()) then

		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,0,ScrW(),ScrH());

		draw.SimpleText( SGLanguage.GetMessage("health").." : "..ply:Health(),"CloseCaption_Normal",ScrW()*0.46, 50, Color(0,0,0) )
		draw.SimpleText( SGLanguage.GetMessage("ent_sarco_exit") ,"CloseCaption_Normal",ScrW()*0.39, 100, Color(0,0,0) )
	end

end
hook.Add("HUDPaint","DrawHUDSarcophage",DrawHUD);