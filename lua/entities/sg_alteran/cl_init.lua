include("shared.lua");
ENT.ChevronColor = Color(132,98,24);
if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_stargate");
ENT.PrintName = Lib.Language.GetMessage("stargate_alteran");
end