-- Global Vars
EAP = EAP or {};
Lib = Lib or {};
EAP.SpawnList = {};

-- We're including all librairies ! @Elanis

--Initializing System
IncludeCS('librairies/shared/init.lua');

-- Compatibility with Gmod 13 - Thanks to AlexALX
IncludeCS("librairies/shared/a_gmod13.lua");

-- Many Functions
IncludeCS('librairies/shared/general.lua');

--Weapons 
IncludeCS('weapons/gmod_tool/eap_base_tool.lua');

if(SERVER)then
-- Wiremod
include('librairies/server/wire.lua');

-- Ressource Distribution : LS / CAF / SB / ENV / SL
include('librairies/server/rd.lua');

-- Tool
include('librairies/server/tool.lua');

-- Teleport
include('librairies/server/teleport.lua');

-- Entity
include('librairies/server/entity.lua');

-- Many Functions
include('librairies/server/general.lua');

-- GateSpawner
include('librairies/server/spawner.lua');

--INI Parser
include('librairies/server/ini_parser.lua')

end

-- Many Functions
IncludeCS('librairies/client/general.lua');

-- Client ConVars
IncludeCS("librairies/client/clientconvars.lua");

-- Menu
IncludeCS("librairies/client/menu.lua");

-- Keyboard
IncludeCS('librairies/client/keyboard.lua');

IncludeCS('librairies/shared/keyboard.lua');

--Settings
IncludeCS("librairies/shared/general_settings.lua")
IncludeCS('librairies/shared/ships_settings.lua');

-- Visual System
IncludeCS("librairies/client/visual.lua");

-- PlayerModels
IncludeCS('librairies/shared/playermodel.lua');

-- Matrix
IncludeCS('librairies/shared/matrix.lua');

-- Language Libs
IncludeCS('librairies/shared/sg_language_lib.lua');

if(SERVER)then
AddCSLuaFile('librairies/vgui/init.lua');
AddCSLuaFile('librairies/vgui/dmultichoice.lua');
AddCSLuaFile('librairies/vgui/doldnumslider.lua');
AddCSLuaFile('librairies/vgui/jumperhud.lua');
AddCSLuaFile('librairies/vgui/jumperlsd.lua');
AddCSLuaFile('librairies/vgui/stargatemenus.lua');
end

if(CLIENT)then
-- VGui Interface
IncludeCS('librairies/vgui/init.lua');
IncludeCS('librairies/vgui/dmultichoice.lua');
IncludeCS('librairies/vgui/doldnumslider.lua');
IncludeCS('librairies/vgui/jumperhud.lua');
IncludeCS('librairies/vgui/jumperlsd.lua');
IncludeCS('librairies/vgui/stargatemenus.lua');
end

if(SERVER)then
-- ConVars
include('librairies/server/convar.lua');

-- Chat
include('librairies/server/chat.lua');

-- Combat
include('librairies/server/combat_function.lua');
end

-- Traceline
IncludeCS('librairies/shared/tracelines.lua');

MsgN("=======================================================");