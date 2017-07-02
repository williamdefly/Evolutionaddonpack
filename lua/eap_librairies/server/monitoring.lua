/*
	Monitor libraries for GarrysMod13
	Copyright (C) 2017  Elanis

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
Lib = Lib or {};
Lib.Monit = Lib.Monit or {};

Lib.Monit.URL = "https://elanis.eu/gmod-addons";

function Lib.Monit.Start(addon,version) 
	if(SERVER and game.IsDedicated()) then
		local url = Lib.Monit.URL.."?";

		local hostname = string.Replace(GetHostName()," ","%20");
				hostname = string.Replace(hostname,"&","and");
				hostname = string.Replace(hostname,"?","");

		url = url.."serverName="..hostname;
		url = url.."&map="..game.GetMap();
		url = url.."&ip="..game.GetIPAddress();
		url = url.."&addon="..addon;
		url = url.."&version="..version;

		// Call website
		http.Fetch(url);
	end
end