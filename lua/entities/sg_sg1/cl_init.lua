include("shared.lua");
ENT.ChevronColor = Color(200,65,0);
if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_transportation");
ENT.PrintName = Lib.Language.GetMessage("stargate_sg1");
end