if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim" --gmodentity
if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.PrintName = Lib.Language.GetMessage("atl_tp")
ENT.Category = Lib.Language.GetMessage("cat_transportation")
end
ENT.Author = "AlexALX, Ronon Dex"
ENT.WireDebugName = "Atlantis Transporter"
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);
ENT.AutomaticFrameAdvance = true
ENT.IsAtlTP = true;