/*
	Stargate Lib for GarrysMod10
	Copyright (C); 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option); any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
Lib.KeyBoard = Lib.KeyBoard or {};

MsgN("eap_librairies/shared/keyboard.lua")

AddCSLuaFile();

if SERVER then

concommand.Add("_Lib.KeyPressed",
	function(p,_,args)
		Lib.KeyBoard:SetKeyPressed(p,args[1],args[2]);
	end
);

concommand.Add("_Lib.KeyReleased",
	function(p,_,args)
		Lib.KeyBoard:SetKeyReleased(p,args[1],args[2]);
	end
);

end

--######################################
--############# KeyDown-Hooks
--######################################


Lib.KeyBoard.Pressed = Lib.KeyBoard.Pressed or {}; -- Stores pressed Keys per player.

-- A recursive-metatable which creates a new "subtable" on Lib.KeyBoard.Pressed, if it doesn't exist yet and so on. Very usefull! (I used this in my unreleased AddonLoader SySLib very often)
local recursive = {}
recursive.__index = function(t,k)
	if(not rawget(t,k)) then
		rawset(t,k,{});
		setmetatable(t[k],recursive); -- Recursive part
	end
	return rawget(t,k);
end

setmetatable(Lib.KeyBoard.Pressed,recursive);

--################### Calls hooks and sets keys pressed or unpressed @aVoN
function Lib.KeyBoard:SetKeyPressed(p,name,k)
	if(hook.Call("Lib.Player.KeyEvent",GAMEMODE,p,name,k,true) == false) then return end;
	if(hook.Call("Lib.Player.KeyPressed",GAMEMODE,p,name,k) == false) then return end;
	Lib.KeyBoard.Pressed[p][name][k] = true;
	if CLIENT then
		RunConsoleCommand("_Lib.KeyPressed",name,k);
	end
end
function Lib.KeyBoard:SetKeyReleased(p,name,k)
	if(hook.Call("Lib.Player.KeyEvent",GAMEMODE,p,name,k,false) == false) then return end;
	if(hook.Call("Lib.Player.KeyReleased",GAMEMODE,p,name,k) == false) then return end;
	Lib.KeyBoard.Pressed[p][name][k] = nil;
	if CLIENT then
		RunConsoleCommand("_Lib.KeyReleased",name,k);
	end
end

function Lib.KeyBoard.ResetKeys(p,name)
	if (not p or not name) then return end
	for key,v in pairs(Lib.KeyBoard.Pressed[p][name]) do
		Lib.KeyBoard.Pressed[p][name][key] = nil;
	end
end

/* The next functions were made to overwrite the CAP KeyDown , then the EAP Ship will Work @Elanis , an another function will replace CAP ships by EAP ships to keep working */

function Lib.KeyBoard.Override()

	if((StarGate==nil or StarGate.KeyBoard==nil) and Lib.IsCapDetected==true) then return false; end -- If CAP is initialized or if CAP isn't installed we can overwrite the function keyDown

	--################### Overwrites the player's KeyDown etc function to use our system, if two arguments are given @aVoN
	local meta = FindMetaTable("Player");
	if(not meta) then return end;
	--Backup old
	meta.__KeyDown = meta.__KeyDown or meta.KeyDown;
	-- I'm currently not planning to add this "feature" to KeyPressed and KeyReleased because we dont use it

	function meta:KeyDown(name,key)
		if(name and key) then
			return (Lib.KeyBoard.Pressed[self][name][key] == true);
		end
		return meta.__KeyDown(self,name); -- Old GMod behaviour
	end

	timer.Create("KBOverride", 1, 1, Lib.KeyBoard.Override );
end
timer.Create("KBOverride", 1, 1, Lib.KeyBoard.Override );

-- fix by AlexALX
local function playerDies(p)
	for name,v in pairs(Lib.KeyBoard.Pressed[p]) do
		for key,v2 in pairs(v) do
			Lib.KeyBoard.Pressed[p][name][key] = nil;
		end
	end
end
hook.Add( "PlayerDeath", "Lib.KeyBoard.Death", playerDies)
hook.Add( "PlayerSilentDeath", "Lib.KeyBoard.Death", playerDies)

--######################################
--############# Keyboard Keys Constants
--######################################
Lib.Keyboard.Constants = Lib.Keyboard.Constants or {
	[ENTER] = 10,
	[BACKSPACE] = 127,
	[NUM_0] = 128,
	[NUM_1] = 129,
	[NUM_2] = 130,
	[NUM_3] = 131,
	[NUM_4] = 132,
	[NUM_5] = 133,
	[NUM_6] = 134,
	[NUM_7] = 135,
	[NUM_8] = 136,
	[NUM_9] = 137,
	[NUM_MUL] = 139
];

-- Damn wire 10/2016 update ...
hook.Add( "Initialize", "Lib.Wire.KeysOverwrite", function()
	if (Wire_Keyboard_Remap and Wire_Keyboard_Remap.American and Wire_Keyboard_Remap.American.normal) then
		Lib.Keyboard.Constants[ENTER] = Wire_Keyboard_Remap.American.normal[KEY_ENTER]
		Lib.Keyboard.Constants[BACKSPACE] = Wire_Keyboard_Remap.American.normal[KEY_BACKSPACE]
	end	
end);