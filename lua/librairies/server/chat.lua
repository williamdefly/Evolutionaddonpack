--CAP

hook.Add("PlayerAuthed","CAP_PlayerAuthedMSG",function(ply)
	if (game.SinglePlayer()) then return nil end
	local tbl = {"STEAM_0:0:15310103","STEAM_0:1:44681506","STEAM_0:0:30148988"};
	if (table.HasValue(tbl,ply:SteamID())) then
		PrintMessage( HUD_PRINTTALK, ply:Name()..", one of the creators of the deceased Carter Addon Pack has joined the game. This was an unforgettable addon." );
	end
end)

--EAP

hook.Add("PlayerAuthed","EAP_PlayerAuthedMSG",function(ply)
	if (game.SinglePlayer()) then return nil end
	local tbl = {"STEAM_0:0:44570515","STEAM_0:0:56878593","STEAM_0:0:8026971"};
	if (table.HasValue(tbl,ply:SteamID())) then
		PrintMessage( HUD_PRINTTALK, ply:Name()..", one of the creators of the Evolution Addon Pack has joined the game." );
		PrintMessage( HUD_PRINTTALK, "Ask him question about the addon." );
	end
end)