if(SERVER)then
	return false
end

MsgN("eap_librairies/client/general.lua")

Lib.HTTP = {
	FORUM = "http://www.stargate-evolutionaddonpack.com/forum",
	SITE = "http://www.stargate-evolutionaddonpack.com/",
	NEWS = "http://www.stargate-evolutionaddonpack.com/",
	WIKI = "", --No wiki yet
	MULTI = "",
	FACEPUNCH = "",
	CREDITS = "https://github.com/williamdefly/Evolutionaddonpack/blob/master/credits.txt",
	DONATE = "https://www.paypal.com/fr/cgi-bin/webscr?cmd=_flow&SESSION=0XQRvDFmvStncmnKSn6J8NbwuSV8DiuYGX_Ce2heEJmS-576wKb1EM-GLH0&dispatch=5885d80a13c0db1f8e263663d3faee8d6625bf1e8bd269586d425cc639e26c6a"
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