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
--############# Key enumerations
--######################################

/* Now not needed, because now you can use any key with autodetection @ AlexALX

-- Source of the below keycodes: SENT gmod_wire_keyboard
Lib.KeyBoard.Keys = {}

-- Mouse -- input.IsMouseDown() must be used on those
Lib.KeyBoard.Keys["MOUSE1"] 				= MOUSE_LEFT;
Lib.KeyBoard.Keys["MOUSE2"] 				= MOUSE_RIGHT;
Lib.KeyBoard.Keys["MOUSE3"] 				= MOUSE_MIDDLE;
Lib.KeyBoard.Keys["MOUSE4"] 				= MOUSE_4;
Lib.KeyBoard.Keys["MOUSE5"] 				= MOUSE_5;
-- These two do not work with input.IsMouseDown. We "hack" into them, with BindPressed and "invnext" and "invprev"
Lib.KeyBoard.Keys["MWHEELDOWN"] 		= MOUSE_WHEEL_DOWN;
Lib.KeyBoard.Keys["MWHEELUP"] 			= MOUSE_WHEEL_UP;

-- Keyboard -- input.IsKeyDown() must be used on those
Lib.KeyBoard.Keys["KEY_NONE"] 				= KEY_NONE;
Lib.KeyBoard.Keys["0"] 							= KEY_0;
Lib.KeyBoard.Keys["1"] 							= KEY_1;
Lib.KeyBoard.Keys["2"] 							= KEY_2;
Lib.KeyBoard.Keys["3"] 							= KEY_3;
Lib.KeyBoard.Keys["4"] 							= KEY_4;
Lib.KeyBoard.Keys["5"] 							= KEY_5;
Lib.KeyBoard.Keys["6"] 							= KEY_6;
Lib.KeyBoard.Keys["7"] 							= KEY_7;
Lib.KeyBoard.Keys["8"] 							= KEY_8;
Lib.KeyBoard.Keys["9"] 							= KEY_9;
Lib.KeyBoard.Keys["A"] 							= KEY_A;
Lib.KeyBoard.Keys["B"] 							= KEY_B;
Lib.KeyBoard.Keys["C"] 							= KEY_C;
Lib.KeyBoard.Keys["D"] 							= KEY_D;
Lib.KeyBoard.Keys["E"] 							= KEY_E;
Lib.KeyBoard.Keys["F"] 							= KEY_F;
Lib.KeyBoard.Keys["G"] 							= KEY_G;
Lib.KeyBoard.Keys["H"] 							= KEY_H;
Lib.KeyBoard.Keys["I"]							= KEY_I;
Lib.KeyBoard.Keys["J"]							= KEY_J;
Lib.KeyBoard.Keys["K"] 							= KEY_K;
Lib.KeyBoard.Keys["L"] 							= KEY_L;
Lib.KeyBoard.Keys["M"] 						= KEY_M;
Lib.KeyBoard.Keys["N"] 							= KEY_N;
Lib.KeyBoard.Keys["O"] 						= KEY_O;
Lib.KeyBoard.Keys["P"] 							= KEY_P;
Lib.KeyBoard.Keys["Q"] 						= KEY_Q;
Lib.KeyBoard.Keys["R"] 							= KEY_R;
Lib.KeyBoard.Keys["S"] 							= KEY_S;
Lib.KeyBoard.Keys["T"] 							= KEY_T;
Lib.KeyBoard.Keys["U"] 							= KEY_U;
Lib.KeyBoard.Keys["V"] 							= KEY_V;
Lib.KeyBoard.Keys["W"] 						= KEY_W;
Lib.KeyBoard.Keys["X"] 							= KEY_X;
Lib.KeyBoard.Keys["Y"] 							= KEY_Y;
Lib.KeyBoard.Keys["Z"] 							= KEY_Z;
Lib.KeyBoard.Keys["KP_INS"] 					= KEY_PAD_0;
Lib.KeyBoard.Keys["KP_END"] 				= KEY_PAD_1;
Lib.KeyBoard.Keys["KP_DOWNARROW"] 	= KEY_PAD_2;
Lib.KeyBoard.Keys["KP_PGDN"] 				= KEY_PAD_3;
Lib.KeyBoard.Keys["KP_LEFTARROW"] 		= KEY_PAD_4;
Lib.KeyBoard.Keys["KP_5"] 					= KEY_PAD_5;
Lib.KeyBoard.Keys["KP_RIGHTARROW"] 	= KEY_PAD_6;
Lib.KeyBoard.Keys["KP_HOME"] 				= KEY_PAD_7;
Lib.KeyBoard.Keys["KP_UPARROW"] 			= KEY_PAD_8;
Lib.KeyBoard.Keys["KP_PGUP"] 				= KEY_PAD_9;
Lib.KeyBoard.Keys["KP_SLASH"] 				= KEY_PAD_DIVIDE;
Lib.KeyBoard.Keys["KP_MULTIPLY"]			= KEY_PAD_MULTIPLY;
Lib.KeyBoard.Keys["KP_MINUS"] 				= KEY_PAD_MINUS;
Lib.KeyBoard.Keys["KP_PLUS"] 				= KEY_PAD_PLUS;
Lib.KeyBoard.Keys["KP_ENTER"] 				= KEY_PAD_ENTER; -- Seems not to work. If I press KP_ENTER, it simply sends reacts as ENTER
Lib.KeyBoard.Keys["KP_DEL"] 					= KEY_PAD_DECIMAL;
Lib.KeyBoard.Keys["["] 							= KEY_LBRACKET;
Lib.KeyBoard.Keys["]"] 							= KEY_RBRACKET;
Lib.KeyBoard.Keys[";"] 							= KEY_SEMICOLON;
Lib.KeyBoard.Keys["\""] 						= KEY_APOSTROPHE;
Lib.KeyBoard.Keys["`"] 							= KEY_BACKQUOTE;
Lib.KeyBoard.Keys[","] 							= KEY_COMMA;
Lib.KeyBoard.Keys["."] 							= KEY_PERIOD;
Lib.KeyBoard.Keys["/"] 							= KEY_SLASH;
Lib.KeyBoard.Keys["\\"] 						= KEY_BACKSLASH;
Lib.KeyBoard.Keys["-"] 							= KEY_MINUS;
Lib.KeyBoard.Keys["="] 							= KEY_EQUAL;
Lib.KeyBoard.Keys["ENTER"] 					= KEY_ENTER;
Lib.KeyBoard.Keys["SPACE"] 					= KEY_SPACE;
Lib.KeyBoard.Keys["BACKSPACE"] 			= KEY_BACKSPACE;
Lib.KeyBoard.Keys["TAB"] 						= KEY_TAB;
Lib.KeyBoard.Keys["CAPSLOCK"] 				= KEY_CAPSLOCK;
Lib.KeyBoard.Keys["NUMLOCK"] 				= KEY_NUMLOCK;
--Lib.KeyBoard.Keys["ESC"] 						= KEY_ESCAPE; -- This does not count as valid key to bind! It is used by the engine
Lib.KeyBoard.Keys["SCROLLLOCK"] 			= KEY_SCROLLLOCK;
Lib.KeyBoard.Keys["INS"] 						= KEY_INSERT;
Lib.KeyBoard.Keys["DEL"] 						= KEY_DELETE;
Lib.KeyBoard.Keys["HOME"] 					= KEY_HOME;
Lib.KeyBoard.Keys["END"] 						= KEY_END;
Lib.KeyBoard.Keys["PGUP"] 					= KEY_PAGEUP;
Lib.KeyBoard.Keys["PGDOWN"] 				= KEY_PAGEDOWN;
Lib.KeyBoard.Keys["BREAK"] 					= KEY_BREAK;
Lib.KeyBoard.Keys["SHIFT"] 					= KEY_LSHIFT; -- For some, LSHIFT is evaluated, even if you pressed RSHIFT. So call LSHIFT simply "SHIFT" and keep RSHIFT for those who "really" have RSHIFT
Lib.KeyBoard.Keys["RSHIFT"] 					= KEY_RSHIFT;
Lib.KeyBoard.Keys["ALT"] 						= KEY_LALT;
Lib.KeyBoard.Keys["RALT"] 					= KEY_RALT;
Lib.KeyBoard.Keys["CTRL"] 					= KEY_LCONTROL;
Lib.KeyBoard.Keys["RCTRL"] 					= KEY_RCONTROL;
--Lib.KeyBoard.Keys["LWIN"] 					= KEY_LWIN; -- This does not count as valid key to bind!
--Lib.KeyBoard.Keys["RWIN"] 					= KEY_RWIN; -- This does not count as valid key to bind!
--Lib.KeyBoard.Keys["APP"] 						= KEY_APP;
Lib.KeyBoard.Keys["UPARROW"] 				= KEY_UP;
Lib.KeyBoard.Keys["LEFTARROW"] 			= KEY_LEFT;
Lib.KeyBoard.Keys["DOWNARROW"] 			= KEY_DOWN;
Lib.KeyBoard.Keys["RIGHTARROW"] 			= KEY_RIGHT;
Lib.KeyBoard.Keys["F1"] 						= KEY_F1;
Lib.KeyBoard.Keys["F2"] 						= KEY_F2;
Lib.KeyBoard.Keys["F3"] 						= KEY_F3;
Lib.KeyBoard.Keys["F4"] 						= KEY_F4;
Lib.KeyBoard.Keys["F5"] 						= KEY_F5;
Lib.KeyBoard.Keys["F6"] 						= KEY_F6;
Lib.KeyBoard.Keys["F7"] 						= KEY_F7;
Lib.KeyBoard.Keys["F8"] 						= KEY_F8;
Lib.KeyBoard.Keys["F9"] 						= KEY_F9;
Lib.KeyBoard.Keys["F10"] 						= KEY_F10;
Lib.KeyBoard.Keys["F11"] 						= KEY_F11;
Lib.KeyBoard.Keys["F12"] 						= KEY_F12;
--Lib.KeyBoard.Keys["CAPSLOCK"]				= KEY_CAPSLOCKTOGGLE;
--Lib.KeyBoard.Keys["NUMLOCK"]			= KEY_NUMLOCKTOGGLE;
--Lib.KeyBoard.Keys["SCROLLLOCK"]		= KEY_SCROLLLOCKTOGGLE;
*/

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

/* The next functions were made to overwrite the CAP KeyDown , then the EAP Ship will Work @Elanis */

function Lib.KeyBoard.Override()

	if(StarGate==nil and Stargate.Keyboard==nil and Lib.IsCapDetected==true) then return false; end -- If CAP is initialized or if CAP isn't installed we can overwrite the function keyDown

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