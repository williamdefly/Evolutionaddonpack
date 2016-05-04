include("shared.lua");
ENT.RenderGroup = RENDERGROUP_OPAQUE -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
language.Add("sg_iris",Lib.Language.GetMessage("stool_iris"));
end