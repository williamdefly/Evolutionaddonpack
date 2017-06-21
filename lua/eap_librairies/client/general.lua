if(SERVER)then
	return false
end

MsgN("eap_librairies/client/general.lua")

Lib.HTTP = {
	NEWS = "https://github.com/williamdefly/Evolutionaddonpack/milestones",
	WIKI = "https://github.com/williamdefly/Evolutionaddonpack/wiki",
	DONATE = ""
};

--#########################################
--						Config Part
--#########################################

--################# Getting synced data from the server @aVoN
function Lib.CFG.GetSYNC(len)
	local name = net.ReadString();
	-- fix for reload
	if (name=="_CFG_RELOAD_") then
		if (Lib.CFG.Get and type(Lib.CFG.Get)=="function") then
			local copy = Lib.CFG.Get;
			Lib.CFG = {};
			Lib.CFG.Get = copy;
		end
		return
	end
	Lib.CFG[name] = {};
	local count = net.ReadUInt(8);
	for i=1,count do
		local k = net.ReadString();
		local t = net.ReadUInt(8); -- What type are we?
		if(t == 0) then
			Lib.CFG[name][k] = util.tobool(net.ReadBit());
		elseif(t == 1) then
			Lib.CFG[name][k] = net.ReadString();
		elseif(t == 2) then
			Lib.CFG[name][k] = net.ReadDouble();
		elseif(t == 3) then
			Lib.CFG[name][k] = net.ReadInt(8);
		elseif(t == 4) then
			Lib.CFG[name][k] = net.ReadInt(16);
		elseif(t == 5) then
			Lib.CFG[name][k] = net.ReadInt(32);
		end
	end
end
net.Receive("EAP_CFG",Lib.CFG.GetSYNC);