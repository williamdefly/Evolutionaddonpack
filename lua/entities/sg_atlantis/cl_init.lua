include("shared.lua");
ENT.ChevronColor = Color(30,135,180);
if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_transportation");
ENT.PrintName = Lib.Language.GetMessage("stargate_atlantis");
end