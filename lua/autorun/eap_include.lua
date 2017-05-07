-- Global Vars
EAP = EAP or {};
Lib = Lib or {};
EAP.SpawnList = {};

-- We're including all librairies ! @Elanis

--Initializing System
IncludeCS('eap_librairies/shared/init.lua');

-- Compatibility with Gmod 13 - Thanks to AlexALX
IncludeCS("eap_librairies/shared/a_gmod13.lua");

-- Many Functions
IncludeCS('eap_librairies/shared/general.lua');

--Weapons 
IncludeCS('weapons/gmod_tool/eap_base_tool.lua');

if(SERVER)then
--CAP Reverse compatibility
include('eap_librairies/server/cap_reversecompatibility.lua')

-- Wiremod
include('eap_librairies/server/wire.lua');

-- Ressource Distribution : LS / CAF / SB / ENV / SL
include('eap_librairies/server/rd.lua');

-- Tool
include('eap_librairies/server/tool.lua');

-- Teleport
include('eap_librairies/server/teleport.lua');

-- Entity
include('eap_librairies/server/entity.lua');

-- Many Functions
include('eap_librairies/server/general.lua');

-- GateSpawner
include('eap_librairies/server/spawner.lua');

--INI Parser
include('eap_librairies/server/ini_parser.lua')

end

-- Many Functions
IncludeCS('eap_librairies/client/general.lua');

-- Client ConVars
IncludeCS("eap_librairies/client/clientconvars.lua");


-- Keyboard
IncludeCS('eap_librairies/client/keyboard.lua');

IncludeCS('eap_librairies/shared/keyboard.lua');

--Settings
IncludeCS("eap_librairies/shared/general_settings.lua")
IncludeCS('eap_librairies/shared/ships_settings.lua');
IncludeCS('eap_librairies/shared/client_settings.lua');

-- Menu
IncludeCS("eap_librairies/client/menu.lua");

-- Visual System
IncludeCS("eap_librairies/client/visual.lua");

-- PlayerModels
IncludeCS('eap_librairies/shared/playermodel.lua');

-- Matrix
IncludeCS('eap_librairies/shared/matrix.lua');

-- Weapons
IncludeCS('eap_librairies/shared/weapons.lua');

-- Language Libs
IncludeCS('eap_librairies/shared/sg_language_lib.lua');

if(SERVER)then
AddCSLuaFile('eap_librairies/vgui/init.lua');
AddCSLuaFile('eap_librairies/vgui/dmultichoice.lua');
AddCSLuaFile('eap_librairies/vgui/doldnumslider.lua');
AddCSLuaFile('eap_librairies/vgui/jumperhud.lua');
AddCSLuaFile('eap_librairies/vgui/jumperlsd.lua');
AddCSLuaFile('eap_librairies/vgui/stargatemenus.lua');
end

if(CLIENT)then
-- VGui Interface
IncludeCS('eap_librairies/vgui/init.lua');
IncludeCS('eap_librairies/vgui/dmultichoice.lua');
IncludeCS('eap_librairies/vgui/doldnumslider.lua');
IncludeCS('eap_librairies/vgui/jumperhud.lua');
IncludeCS('eap_librairies/vgui/jumperlsd.lua');
IncludeCS('eap_librairies/vgui/stargatemenus.lua');
end

if(SERVER)then
-- ConVars
include('eap_librairies/server/convar.lua');

-- Chat
include('eap_librairies/server/chat.lua');

-- Combat
include('eap_librairies/server/combat_function.lua');
end

-- Traceline
IncludeCS('eap_librairies/shared/tracelines.lua');

MsgN("=======================================================");