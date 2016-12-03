if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim" --gmodentity
ENT.PrintName = "MCD"
ENT.Author = "Llapp, Boba Fett, Markjaw, AlexALX"
ENT.WireDebugName = "Molecular Construction Device"

list.Set("EAP", ENT.PrintName, ENT);