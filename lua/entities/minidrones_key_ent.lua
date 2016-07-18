--[[
	Minidrone Platform Key
	Copyright (C) 2010 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Minidrone Platform Key"
ENT.Author = "Madman07, Boba Fett"
ENT.Category = ""
ENT.WireDebugName = "Minidrone Platform Key"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Minidrone Platform Key");
	self.Entity:SetModel("models/Madman07/minidrone_platform/key_w.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.CanTouch = false;
	timer.Create(self.Entity:EntIndex().."Touch", 1, 1, function() self.CanTouch  = true; end);

end

-----------------------------------Touch----------------------------------

function ENT:StartTouch(ply)
	if (self.CanTouch and ply:IsPlayer() and not ply:HasWeapon("minidrones_key")) then
		ply.MiniDronePlatform = self.MiniDronePlatform;
		ply:SetNetworkedEntity("DronePlatform", self.MiniDronePlatform);
		ply:Give("minidrones_key");
		self:Remove();
	end
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "minidrones_key_ent", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

local default = Material("madman07/minidrone_platform/key");
local noglow = Material("madman07/minidrone_platform/key"):GetTexture("$basetexture");

function ENT:Initialize() //shutdown old effect if needed
	default:SetTexture( "$basetexture", noglow);
	default:SetInt( "$selfillum", 0);
end

function ENT:Draw()
	local mat = Matrix()
	mat:Scale(Vector(2,2,2))
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Entity:DrawModel();
end

end