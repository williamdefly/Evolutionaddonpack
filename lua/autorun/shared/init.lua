--Initializing System
--Made by Elanis

EAP = EAP or { } --Init Global Var !
EAP.WebRev = "https://raw.githubusercontent.com/williamdefly/Evolutionaddonpack/master/lua/revision.lua"
EAP.LastRev = 0; --Default


if (SERVER) then
	AddCSLuaFile();
end

function GetRevision()

	if (file.Exists("lua/revision.lua","GAME")) then
			EAP.Revision = tonumber(file.Read("lua/revision.lua","GAME"));
	else
			EAP.Revision = 0 -- For no Lua Errors
	end

end

function IsUpdated()

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

function Init()

GetRevision()

IsUpdated()


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
	
MsgN("=======================================================");

end

----------------------------------------Launch !!!!!!!!!!!-------------------------------------------------------
Init()
