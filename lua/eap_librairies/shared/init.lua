--EAP Initializing System
--Made by Elanis

EAP = EAP or {} --Init Global Var !

Lib = Lib or {} --Init Global Var !

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
	--Check Version
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

	--Check Addons
	MsgN("Searching Addons ...");

	addons = { "EAP_Base", "EAP_Models", "EAP_Sounds"}
	local materialsNumbers = 9;
	local errors = 0;
	EAP.MissingAddons = {};
	EAP.AddonsInstalled = {};

	for i=1,materialsNumbers do 
		table.insert( addons, "EAP_Materials_"..i )
	end

	for _, addon in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do
		if (addon.title==addons[1]) then EAP.AddonsInstalled[1]=true; end
	end
	EAP.Workshop = EAP.AddonsInstalled[1];

	if(true) then
		MsgN("Workshop Version Launch !")

		for i=2,table.Count(addons) do
			for _, addon in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do	
				if (addon.title==addons[i]) then 
					EAP.AddonsInstalled[i] = true
					MsgN(addons[i].." found !")
				end
			end

			if(EAP.AddonsInstalled[i]!=true) then
				MsgN(addons[i].." NOT found !")
				errors=errors+1;
				table.insert(EAP.MissingAddons,addons[i]);
			end
		end
	else
		MsgN("Git/Files Version Found !")
	end

	EAP.IsCapDetected()
	EAP.IsWireDetected()
	EAP.IsRDDetected()

	if(Lib.HasWire==false) then 
		errors=errors+1;
		table.insert(EAP.MissingAddons,"Wiremod");
	end
	
	if(errors>0 && CLIENT) then
		MsgN("ERRORS");
		MsgN(errors);
		hook.Add( "PlayerInitialSpawn", "InstallProblems", function()
			MsgN("InstallProblem")

			local ErrorFrame = vgui.Create("DFrame");
			ErrorFrame:SetPos(50, 50);
			ErrorFrame:SetSize(ScrW()-100,ScrH()-100);
			ErrorFrame:SetTitle("Error");
			ErrorFrame:SetVisible(true);
			ErrorFrame:SetDraggable(false);
			ErrorFrame:ShowCloseButton(true);
			ErrorFrame:SetBackgroundBlur(false);
			ErrorFrame:MakePopup();

			ErrorFrame.Paint = function()
				// Background
				surface.SetMaterial( "pp/blurscreen" )
				surface.SetDrawColor( 255, 255, 255, 255 )

				matBlurScreen:SetFloat( "$blur", 5 )
				render.UpdateScreenEffectTexture()

				surface.DrawTexturedRect( -ScrW()/10, -ScrH()/10, ScrW(), ScrH() )

				surface.SetDrawColor( 100, 100, 100, 150 )
				surface.DrawRect( 0, 0, ScrW(), ScrH() )

				// Border
				surface.SetDrawColor( 50, 50, 50, 255 )
				surface.DrawOutlinedRect( 0, 0, ErrorFrame:GetWide(), ErrorFrame:GetTall() )

				surface.SetDrawColor( 50, 50, 50, 255 )
				surface.DrawRect( 20, 35, ErrorFrame:GetWide() - 40, ErrorFrame:GetTall() - 55 )

			end

			local ErrorText = "These following addons are missing: \n"

			for i=1,table.Count(EAP.MissingAddons) do
				ErrorText = ErrorText..""..EAP.MissingAddons[i].."\n"
			end

			local DLabel = vgui.Create( "DLabel", Panel )
			DLabel:SetPos( 40, 30 )
			DLabel:SetText( ErrorText )
		end);
	end

	MsgN("Loading Librairies ...")
end

----------------------------------------Launch !!!!!!!!!!!-------------------------------------------------------
EAP.Init()