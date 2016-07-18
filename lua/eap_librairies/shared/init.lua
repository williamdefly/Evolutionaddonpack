--EAP Initializing System
--Made by Elanis

EAP = EAP or { } --Init Global Var !

Lib = Lib or { } --Init Global Var !

EAP.WebRev = "https://raw.githubusercontent.com/williamdefly/Evolutionaddonpack/master/lua/eap_revision.lua"
EAP.LastRev = 0; --Default

Lib.CYCLE_INTERVAL = 0.2

Lib.IsCapDetected = false;


if (SERVER) then
	AddCSLuaFile();
end

function EAP.GetRevision()

	if (file.Exists("lua/eap_revision.lua","GAME")) then
			EAP.Revision = tonumber(file.Read("lua/eap_revision.lua","GAME"));
	else
			EAP.Revision = 0 -- For no Lua Errors
	end

end

function EAP.IsUpdated()

	http.Fetch(EAP.WebRev,
		function(html,size)
			local version = tonumber(html);
			if(version) then
				EAP.LastRev = version;

				if (EAP.LastRev > EAP.Revision) then
					EAP.Outdated = true
				end
			end
		end
	);
	
end

function EAP.IsCapDetected() --Detect if the Carter Addon Pack is installed , in other files , this info can help

	if (file.Exists("lua/stargate/shared/cap.lua","GAME")) then

		Lib.IsCapDetected = true

		MsgN("Carter Addon Pack detected : Compatibility Mode Activated");

	end
end

function EAP.IsWireDetected()
	-- Wire?
	if(WireAddon or file.Exists("weapons/gmod_tool/stools/wire_adv.lua","LUA")) then
		Lib.HasWire = true;
		if (file.IsDir("expression2","DATA") and not file.IsDir("expression2/eap_shared","DATA")) then
			file.CreateDir("expression2/eap_shared");
		end
		if (file.IsDir("starfall","DATA") and not file.IsDir("starfall/eap_shared","DATA")) then
			file.CreateDir("starfall/eap_shared");
		end
	else
		Lib.HasWire = false;
	end
end

function EAP.IsRDDetected()
	-- Resource Distribution Installed?
	-- fix for client/server energy will be later @ AlexALX
	if((Environments or #file.Find("weapons/gmod_tool/environments_tool_base.lua","LUA") == 1 or Dev_Link or rd3_dev_link or #file.Find("weapons/gmod_tool/stools/dev_link.lua","LUA") == 1 or #file.Find("weapons/gmod_tool/stools/rd3_dev_link.lua","LUA") == 1 or Spacelife or #file.Find("weapons/gmod_tool/stools/sl_link_tool.lua","LUA") == 1)) then //Thanks to mercess2911: http://www.facepunch.com/showpost.php?p=15508150&postcount=10070
		Lib.HasResourceDistribution = true;
	else
		Lib.HasResourceDistribution = false;
	end
end

function EAP.Init()

EAP.GetRevision()

EAP.IsUpdated()


MsgN("=======================================================");
if(EAP.Revision==0) then
MsgN("Initializing Evolution Addon Pack Revision : UNKNOWN");
else
MsgN("Initializing Evolution Addon Pack Revision "..EAP.Revision);
end

if(EAP.Outdated)then
MsgN("Your Version of Evolution Addon Pack is outdated ! Please Update it.");
else
MsgN("Your Version of Evolution Addon Pack is up to date !");
end

MsgN("Searching Addons ...");

	for _, addon in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do
	
		if (addon.title=="EAP_Base") then EAP.Workshop = true else EAP.Workshop = false end

		if (addon.title=="EAP_Ressources") then EAP.Res = true else EAP.Res = false end

		if (addon.title=="EAP_ressources_2") then EAP.Res2 = true else EAP.Res2 = false end

		if (addon.title=="EAP_Ressources_3") then EAP.Res3 = true else EAP.Res3 = false end

		if (addon.title=="EAP_Ressources_3") then EAP.Res4 = true else EAP.Res4 = false end
	
	end

	if(EAP.Workshop) then 
	
		MsgN("Workshop Version Launch !")
	
		if(EAP.Res) then MsgN("EAP Ressources 1 found !") else MsgN("EAP Ressources 1 NOT found") end
		
		if(EAP.Res2) then MsgN("EAP Ressources 2 found !") else MsgN("EAP Ressources 2 NOT found") end

		if(EAP.Res3) then MsgN("EAP Ressources 3 found !") else MsgN("EAP Ressources 3 NOT found") end

		if(EAP.Res44) then MsgN("EAP Ressources 4 found !") else MsgN("EAP Ressources 4 NOT found") end
	
	else
	
		MsgN("Git/SVN/Zip Version Found !")
	
	end

	EAP.IsCapDetected()
	EAP.IsWireDetected()
	EAP.IsRDDetected()
	
			MsgN("Loading Librairies ...")

end

----------------------------------------Launch !!!!!!!!!!!-------------------------------------------------------
EAP.Init()