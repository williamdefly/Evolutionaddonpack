--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "dhdbase"
ENT.PrintName = "DHD (Atlantis)"
ENT.Author = "aVoN, Madman07, Llapp, Boba Fett, MarkJaw, AlexALX"
ENT.Category = 	""
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);

ENT.Color = {
	chevron="30 135 180"
};

ENT.IsDHDAtl = true

if SERVER then

--################# HEADER #################
AddCSLuaFile()

ENT.PlorkSound = "stargate/dhd_atl.mp3";
ENT.LockSound = "stargate/chevron_lock_atlantis_incoming.mp3";
ENT.SkinNumber = 2;

--################# SpawnFunction
function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local pos = tr.HitPos - Vector(0,0,7.8 + 7);
	local e = ents.Create("dhd_atl");
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 15; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:Fire("skin",1);
	e:RampsDHD(tr);
	return e;
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_atl", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_BOTH -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
-- Damn u aVoN. It need to be setted to BOTH. I spend many hours on trying to fix Z-index issue. @Mad

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_stargate");
ENT.PrintName = Lib.Language.GetMessage("dhd_atl");
end

end