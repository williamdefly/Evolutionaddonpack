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

--Functions by @aVon

function Lib.VisualsWeapons(str)
	if(LocalPlayer() and LocalPlayer().GetInfo and util.tobool(LocalPlayer():GetInfo("cl_visualsweapon_active")) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

function Lib.VisualsShips(str)
	if(LocalPlayer() and LocalPlayer().GetInfo and util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsship")) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

function Lib.VisualsMisc(str,ignore)
	if(LocalPlayer() and LocalPlayer().GetInfo and (util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsmisc")) or ignore) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

--################# Creates a copy of an existing Material and returns it @aVoN
function Lib.MaterialCopy(name,filename)
	if(type(filename) ~= "string" or type(name) ~= "string") then return Material(" ") end; -- Return a dummy Material
	filename = "materials/"..filename:Trim():gsub(".vmt$","")..".vmt";
	return Lib.MaterialFromVMT(name,file.Read(filename,"GAME"));
end