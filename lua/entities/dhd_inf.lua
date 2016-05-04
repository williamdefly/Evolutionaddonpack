--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "dhdbase"
ENT.PrintName = "DHD (Infinity)"
ENT.Author = "aVoN, Madman07, Llapp, Boba Fett, MarkJaw, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);

ENT.Color = {
	chevron="80 200 200"
};

ENT.IsDHDSg1 = true

if SERVER then

--################# HEADER #################
AddCSLuaFile();

ENT.PlorkSound = "stargate/dhd_sg1.mp3"; -- The old sound
ENT.ChevSounds = {
	Sound("stargate/dhd/sg1/press.mp3"),
	Sound("stargate/dhd/sg1/press_2.mp3"),
	Sound("stargate/dhd/sg1/press_3.mp3"),
	Sound("stargate/dhd/sg1/press_4.mp3"),
	Sound("stargate/dhd/sg1/press_5.mp3"),
	Sound("stargate/dhd/sg1/press_6.mp3"),
	Sound("stargate/dhd/sg1/press_7.mp3")
}
ENT.SkinNumber = 6;

--################# SpawnFunction
function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local pos = tr.HitPos - Vector(0,0,7.8 + 7);
	local e = ents.Create("dhd_inf");
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 15; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:Fire("skin",3);
	e:CartersRampsDHD(tr);
	return e;
end

if (Lib and Lib.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_inf", Lib.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_BOTH -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
-- Damn u aVoN. It need to be setted to BOTH. I spend many hours on trying to fix Z-index issue. @Mad

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_transportation");
ENT.PrintName = Lib.Language.GetMessage("dhd_infinity");
end

end