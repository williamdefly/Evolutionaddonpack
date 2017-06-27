/*
	Stargate - Protection System for GarrysMod10
	Copyright (C) 2007  aVoN

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

--#########################################
--						Protection and Restrictions for entities
--#########################################

-- ############### Physgun/Gravgun picking up disabler @aVoN
function Lib.Hook.PhysgunPickup(p,e)
	if(IsValid(e) and (e:GetNWBool("GateSpawnerProtected",false) or e.Untouchable) and not DEBUG) then
		return false;
	end
end
hook.Add("PhysgunPickup","Lib.Hook.PhysgunPickup",Lib.Hook.PhysgunPickup);
hook.Add("CanPlayerUnfreeze","Lib.Hook.CanPlayerUnfreeze",Lib.Hook.PhysgunPickup);

if (SERVER) then

hook.Add("GravGunPunt","Lib.Hook.PhysgunPickup",Lib.Hook.PhysgunPickup);
hook.Add("GravGunPickupAllowed","Lib.Hook.PhysgunPickup",Lib.Hook.PhysgunPickup);

-- ############### Disallow toolgun @aVoN
function Lib.Hook.CanTool(p,t,m)
	local e = t.Entity;
	if(IsValid(e) and (e.GateSpawnerProtected or e.Untouchable) and not DEBUG) then
		local m = m or "";
		local allow = hook.Call("Lib.Player.CanToolOnProtectedGate",GAMEMODE,p,e,m);
		if(allow == true) then return end; -- He can!
		if(allow == false) then return false end; -- He cant!
		if(m:find("dev_link") or (m:find("link_tool") and Environments) or (m=="wire" or m=="wire_adv" or m=="wire_debugger") or (m == "goauldiris" or m == "sg_iris")) then return end;
		return false;
	end
end
hook.Add("CanTool","Lib.Hook.CanTool",Lib.Hook.CanTool);

--################# Sorry guys, this function must break all you other hooks, when he isn't allowed to spawn @aVoN
function Lib.Hook.PlayerCanSpawn(p)
	if(p and p.DisableSpawning) then return false end;
end
hook.Add("PlayerSpawnProp","Lib.Hook.PlayerCanSpawn",Lib.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnEffect","Lib.Hook.PlayerCanSpawn",Lib.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnNPC","Lib.Hook.PlayerCanSpawn",Lib.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnVehicle","Lib.Hook.PlayerCanSpawn",Lib.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnObject","Lib.Hook.PlayerCanSpawn",Lib.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnSENT","Lib.Hook.PlayerCanSpawn",Lib.Hook.PlayerCanSpawn);
hook.Add("PlayerSpawnRagdoll","Lib.Hook.PlayerCanSpawn",Lib.Hook.PlayerCanSpawn);

--################# No suicide for you @aVoN
function Lib.Hook.PlayerCanSuicide(p)
	if(p.DisableSuicide) then return false end;
end
hook.Add("CanPlayerSuicide","Lib.Hook.PlayerCanSuicide",Lib.Hook.PlayerCanSuicide);

--################# No noclip for you @aVoN
function Lib.Hook.PlayerNoClip(p)
	if(p.DisableNoclip) then return false	end;
end
hook.Add("PlayerNoClip","Lib.Hook.PlayerNoClip",Lib.Hook.PlayerNoClip);

--################# Protect a player before his own dexgun/staff blasts @aVoN
function Lib.Hook.PlayerShouldTakeDamage(p,a)
	if(p == a) then
		local w = p:GetActiveWeapon();
		if(not IsValid(w)) then return end;
		w = w:GetClass();
		if(w == "eap_weapon_dexgun" or w == "eap_weapon_staff" or w == "eap_ori_staff_weapon" or w == "eap_weapon_asura") then return false end;
	end
end
hook.Add("PlayerShouldTakeDamage","Lib.Hook.PlayerShouldTakeDamage",Lib.Hook.PlayerShouldTakeDamage);

--################# Fix for pickup disabled/disallowed swep.
function Lib.Hook.PlayerCanPickupWeapon(p,w)
	if (not IsValid(p) or not IsValid(w)) then return end
	if (Lib.CFG:Get("eap_disabled_swep",w:GetClass(),false)) then return false end
	if (Lib.CFG:Get("swep_groups_only",w:GetClass(),false)) then
		local tbl = Lib.CFG:Get("swep_groups_only",w:GetClass(),""):TrimExplode(",");
		local disallow = true;
		local exclude = false;
		if (table.HasValue(tbl,"exclude_mod")) then exclude = true; disallow = false; end
		for k,v in pairs(tbl) do
			if (v=="add_shield" or v=="exclude_mod") then continue end
			if (p:IsUserGroup(v)) then
				disallow = exclude;
				break;
			end
		end
		if (table.Count(tbl)==0) then disallow = false end
		if (disallow) then return false; end
	end
end
hook.Add("PlayerCanPickupWeapon","Lib.Hook.PlayerCanPickupWeapon",Lib.Hook.PlayerCanPickupWeapon);

if (CPPI) then
	hook.Add("Lib.Player.CanModifyGate","Lib.CPPI.CanModify.Gate",function(ply,ent)
		if not ent:CPPICanTool(ply,"stargatemodify") then return false end
	end)

	hook.Add("Lib.Player.CanModify.Ring","Lib.CPPI.CanModify.Ring",function(ply,ent)
		if not ent:CPPICanTool(ply,"ringmodify") then return false end
	end)

	hook.Add("Lib.Player.CanModify.AtlantisTransporter","Lib.CPPI.CanModify.AtlantisTransporter",function(ply,ent)
		if not ent:CPPICanTool(ply,"atlantistransportermodify") then return false end
	end)

	local function IsFriend(ply,owner)
		if (IsValid(owner) and owner.CPPIGetFriends) then
			local tbl = owner:CPPIGetFriends();
			if (type(tbl)=="table") then
				if (table.HasValue(tbl,ply)) then return true end
			end
		end
		return false
	end

	hook.Add("Lib.AntiPrior.Noclip","Lib.CPPI.AntiPrior",function(ply,ent)
		if (ent.Immunity==0 and IsFriend(ply,ent.Owner)) then return false end
	end)
	hook.Add("Lib.TollanDisabler.CanBlockWeapon","Lib.CPPI.TollanDisabler",function(ply,weapon,ent)
		if (CapIsFriend(ply,ent.Owner)) then return false end
	end)
end

end

-- disable usage C tool menu for gatespawner ents
function Lib.Hook.CanProperty(p,t,e)
	if(IsValid(e) and (e:GetNWBool("GateSpawnerProtected",false) or e.Untouchable) and not DEBUG) then
		return false;
	end
end
hook.Add("CanProperty","Lib.Hook.CanProperty",Lib.Hook.CanProperty);