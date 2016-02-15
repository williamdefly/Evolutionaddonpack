-- Global Vars
EAP = EAP or {};
Lib = Lib or {};
EAP.SpawnList = {};

-- We're including all librairies ! @Elanis

--Initializing System
IncludeCS('librairies/shared/init.lua');

-- Compatibility with Gmod 13 - Thanks to AlexALX
IncludeCS("librairies/shared/a_gmod13.lua");

if(SERVER)then
-- Wiremod
include('librairies/server/wire.lua');

-- Teleport
include('librairies/server/teleport.lua');

-- Entity
include('librairies/server/entity.lua');
end

-- Client ConVars
IncludeCS("librairies/client/clientconvars.lua");

-- Menu
IncludeCS("librairies/client/menu.lua");

-- Visual System
IncludeCS("librairies/client/visual.lua");

-- Keyboard
IncludeCS('librairies/client/keyboard.lua');

IncludeCS('librairies/shared/keyboard.lua');

IncludeCS('librairies/client/ships_settings.lua');

-- PlayerModels
IncludeCS('librairies/shared/playermodel.lua');

-- Language Libs
IncludeCS('librairies/shared/sg_language_lib.lua');

-- VGui Interface
IncludeCS('librairies/vgui/init.lua');
IncludeCS('librairies/vgui/jumperhud.lua');
IncludeCS('librairies/vgui/jumperlsd.lua');


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