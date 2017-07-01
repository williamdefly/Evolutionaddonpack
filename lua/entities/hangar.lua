--[[
	Ships Hangar
	Copyright (C) 2010 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ships Hangar"
ENT.Author = "Madman07, Rafael De Jongh"
ENT.Category = ""
ENT.WireDebugName = "Ships Hangar"

ENT.AdminSpawnable   = true
ENT.Spawnable        = true

list.Set("EAP", ENT.PrintName, ENT);

if SERVER then

AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Iziraider/capbuild/hangar.mdl")
	self.Entity:SetModel("models/Iziraider/capbuild/hangar.mdl");

	self.Entity:SetName("Ships Hangar");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	if (IsValid(self:GetPhysicsObject())) then
		self:GetPhysicsObject():SetMass(500000);
	end

	if (WireAddon) then
		self:CreateWireInputs("Next Ship", "Prev Ship", "Spawn Ship", "Lock Doors", "Toggle Doors");
		self:CreateWireOutputs("Doors Open");
	end

	self.ShipCount = 0;
	self.ShipClass = {
		"ship_f302",
		"ship_puddle_jumper",
		"ship_glider",
		"ship_gate_glider",
		"ship_dart",
	}

	self.Pressed = false;
	self.Range = 1000;
	self.LockedDoor = false;

end

function ENT:TriggerInput(key,value)
	if (key=="Next Ship" and value>0) then
		self:ButtonPressed(1)
	elseif (key=="Prev Ship" and value>0) then
		self:ButtonPressed(2)
	elseif (key=="Spawn Ship" and value>0) then
		self:ButtonPressed(3,self.Owner) -- it will spawn it like by owner of hangar
	elseif (key=="Lock Doors" and value>0) then
		self:ButtonPressed(4)
	elseif (key=="Toggle Doors" and value>0) then
		self:ButtonPressed(5)
	end
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("hangar");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,100));
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	ent:SpawnDoors(ply);
	ent:SpawnButtons(ply);

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

function ENT:SpawnDoors(p)
	util.PrecacheModel("models/Iziraider/capbuild/hangardoor.mdl")

	local ent = ents.Create("hangar_door");
	ent:SetAngles(self.Entity:GetAngles());
	ent:SetPos(self.Entity:GetPos());
	ent.Parent = self;
	ent.Factor = 1;
	ent:Spawn();
	ent:Activate();
	ent:GetPhysicsObject():EnableMotion(false);
	ent:GetPhysicsObject():Wake();
	constraint.NoCollide( ent, self, 0, 0 );
	self.Door1 = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end

	local ent2 = ents.Create("hangar_door");
	ent2:SetAngles(self.Entity:GetAngles()+Angle(0,180,0));
	ent2:SetPos(self.Entity:GetPos());
	ent2.Parent = self;
	ent2.Factor = -1;
	ent2:Spawn();
	ent2:Activate();
	ent2:GetPhysicsObject():EnableMotion(false);
	ent2:GetPhysicsObject():Wake();
	constraint.NoCollide( ent2, self, 0, 0 );
	self.Door2 = ent2;
	if CPPI and IsValid(p) and ent2.CPPISetOwner then ent2:CPPISetOwner(p) end
	constraint.NoCollide( ent, ent2, 0, 0 );
end

function ENT:SpawnButtons(p)

	entt = entt or {};

	local ang = self:GetAngles();

	util.PrecacheModel("models/beer/wiremod/numpad.mdl")

	local ent = ents.Create("hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-469.94, -622.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent:SetParent(self);
	ent.ID = 1;
	self.ButtonL = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end

	ent = ents.Create("hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-457.69, -622.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent:SetParent(self);
	ent.ID = 2;
	self.ButtonR = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end

	ent = ents.Create("hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-444.71, -622.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent:SetParent(self);
	ent.ID = 3;
	self.ButtonSP = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end

	ent = ents.Create("hangar_button");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-422.40, -621.5, 48)));
	ent:SetModel("models/beer/wiremod/numpad.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetColor(Color(0,0,0,0));
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent.Parent = self;
	ent:SetParent(self);
	ent.ID = 4;
	self.ButtonLock = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end

	ent = ents.Create("hangar_button");
	ent:SetAngles(ang+Angle(0,0,0));
	ent:SetPos(self:LocalToWorld(Vector(77,-459,-42)));
	ent:SetModel("models/props_lab/freightelevatorbutton.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Parent = self;
	ent:SetParent(self);
	ent.ID = 5;
	self.ButtonT1 = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end

	ent = ents.Create("hangar_button");
	ent:SetAngles(ang+Angle(0,180,0));
	ent:SetPos(self:LocalToWorld(Vector(-24,-473,-28)));
	ent:SetModel("models/props_lab/freightelevatorbutton.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Parent = self;
	ent:SetParent(self);
	ent.ID = 5;
	self.ButtonT2 = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end

	ent = ents.Create("prop_physics");
	ent:SetAngles(ang+Angle(35,-90,0));
	ent:SetPos(self:LocalToWorld(Vector(-430, -621.5, 49)));
	ent:SetModel("models/led2.mdl");
	ent:Spawn();
	ent:Activate();
	ent:SetParent(self);
	ent:SetMaterial("models/debug/debugwhite");
	ent:SetColor(Color( 20, 50, 20, 255));
	self.LED = ent;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
end

function ENT:OnRemove()
	if IsValid(self.Door1) then self.Door1:Remove(); end
	if IsValid(self.Door2) then self.Door2:Remove(); end
end

function ENT:ButtonPressed(id, ply)
	if (id == 2) then
		self.ShipCount = self.ShipCount + 1;
		if (self.ShipCount > 4) then self.ShipCount = 0; end
		self.Entity:Fire("skin",self.ShipCount);
	elseif (id == 1) then
		self.ShipCount = self.ShipCount - 1;
		if (self.ShipCount < 0) then self.ShipCount = 4; end
		self.Entity:Fire("skin",self.ShipCount);
	elseif (id == 3) then
		if (not IsValid(ply)) then return end
		if (Lib.NotSpawnable(self.ShipClass[self.ShipCount+1],ply)) then return end

		local PropLimit = GetConVar("EAP_ships_max"):GetInt()
		if(ply:GetCount("EAP_ships")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return
		end

		local e = ents.Create(self.ShipClass[self.ShipCount+1]);
		undo.Create("Ship")
			undo.AddEntity(e)
			undo.SetPlayer(ply)
		undo.Finish()
		e:SetPos(self.Entity:GetPos() + Vector(0,0,30) - self.Entity:GetForward()*400);
		e:SetAngles(Angle(0,self.Entity:GetAngles().Yaw,0));
		e:Spawn();
		e:Activate();
		e.Owner = ply;
		if (e.HangarSpawn) then e:HangarSpawn(ply) end
		e:SetWire("Health",e:GetNetworkedInt("health"));
		if CPPI and IsValid(ply) and e.CPPISetOwner then e:CPPISetOwner(ply) end
		ply:AddCount("EAP_ships", e)
	elseif (id == 4) then
		-- Toggle
		self.LockedDoor = not self.LockedDoor;
		-- Change LED Color
		if self.LockedDoor then self.LED:SetColor(Color(0, 255, 0, 255));
		else self.LED:SetColor( Color(20, 50, 20, 255)); end
		-- if we lock and the doors are open, close it @Elanis
		if(self.LockedDoor and self.Door1.Open) then 
			self.Door1:Toggle();
			self.Door2:Toggle();
		end
	elseif (id == 5) then
		if not self.LockedDoor and IsValid(self.Door1) and IsValid(self.Door2) and not self.Door1.Anim then
			self.Door1:Toggle();
			self.Door2:Toggle();
			if (self.Door1.Opened) then
				self:SetWire("Doors Open",1);
			else
				self:SetWire("Doors Open",0);
			end
		end
	end
end

function ENT:Think(ply)

	local pos = self.Entity:GetPos();

	for _,v in pairs(ents.FindByClass("sg_vehicle_*")) do
		local ship_dist = (pos - v:GetPos()):Length();
		if(ship_dist < self.Range) then
			local health = v:GetNetworkedInt("health");
			health = health + 5;
			if (v.EntHealth) then
				if (health > v.EntHealth) then health = v.EntHealth; end
			else
				if (health > 300) then health = 300; end
			end
			v:SetNetworkedInt("health", health);
			v:SetWire("Health",health);
		end
	end

	for _,v in pairs(ents.FindByClass("puddle_jumper")) do
		local ship_dist = (pos - v:GetPos()):Length();
		if(ship_dist < self.Range) then
			local health = v:GetNetworkedInt("health");
			health = health + 5;
			if (health > 500) then health = 500; end
			v:SetNetworkedInt("health", health);
			v:SetWire("Health",health);
		end
	end

	self.Entity:NextThink(CurTime()+1);
	return true
end
function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	if IsValid(self.Door1) then dupeInfo.Door1 = self.Door1:EntIndex(); end
	if IsValid(self.Door2) then dupeInfo.Door2 = self.Door2:EntIndex(); end

	duplicator.StoreEntityModifier(self, "HangarConDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "HangarConDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	local dupeInfo = Ent.EntityMods.HangarConDupeInfo

	if(Ent.EntityMods and Ent.EntityMods.HangarConDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.HangarConDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	if dupeInfo.Door1 then self.Door1 = CreatedEntities[dupeInfo.Door1]; self.Door1.Parent = self.Entity; self.Door1.Factor = 1; end
	if dupeInfo.Door2 then self.Door2 = CreatedEntities[dupeInfo.Door2]; self.Door2.Parent = self.Entity; self.Door2.Factor = -1; end
	if (Lib.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	if (IsValid(ply)) then
		self.Owner = ply;
	elseif (game.SinglePlayer()) then
		self.Owner = player.GetByID(1)
	end

	self:SpawnButtons(self.Owner);
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "hangar", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
ENT.Category = Lib.Language.GetMessage("cat_others");
ENT.PrintName = Lib.Language.GetMessage("entity_hangar");
end

end