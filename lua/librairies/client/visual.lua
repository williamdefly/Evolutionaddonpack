-- This is an EAP library file --
-- Function made/updated by aVon / AlexALX / Elanis --

--################# Creates a new Material according to a given VMT String @aVoN
-- This is necessary, because sometimes you need to edit a material in an effect which results into conflicts with other scripts using that material too
function Lib.MaterialFromVMT(name,VMT)
	if(type(VMT) ~= "string" or type(name) ~= "string") then return Material(" ") end; -- Return a dummy Material
	local t = util.KeyValuesToTable("\"material\"{"..VMT.."}");
	for shader,params in pairs(t) do
		return CreateMaterial(name,shader,params);
	end
end

--Function by @aVon

function Lib.VisualsWeapons(str)
	if(LocalPlayer() and LocalPlayer().GetInfo and util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsweapon")) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end