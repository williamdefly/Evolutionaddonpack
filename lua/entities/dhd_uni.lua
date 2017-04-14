--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "dhdbase"
ENT.PrintName = "DHD (Universe)"
ENT.Author = "aVoN, Madman07, Llapp, Rafael De Jongh, MarkJaw, AlexALX"
ENT.Category = 	""
ENT.Spawnable = true
ENT.SkinBase = 2;

list.Set("EAP", ENT.PrintName, ENT);

ENT.Color = {
	chevron="255 255 255"
};

ENT.IsDHDUni = true

if SERVER then

--################# HEADER #################
AddCSLuaFile();

ENT.PlorkSound = "stargate/universe/chevron.mp3"; -- The old sound
ENT.LockSound = false;
ENT.SkinNumber = 4;

--################# SpawnFunction
function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local pos = tr.HitPos - Vector(0,0,7.8 + 7);
	local e = ents.Create("dhd_uni");
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 15; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:RampsDHD(tr);
	return e;
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_uni", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_BOTH -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
-- Damn u aVoN. It need to be setted to BOTH. I spend many hours on trying to fix Z-index issue. @Mad

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_stargate");
ENT.PrintName = Lib.Language.GetMessage("dhd_universe");
end

end