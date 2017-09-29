/*
	Modul for GarrysMod10
	Copyright (C) 2011  Llapp
*/

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_gmodentity" --gmodentity
ENT.PrintName = "CFD"
ENT.Author = "Llapp"
ENT.WireDebugName = "Call Forwarding Device"
ENT.Category = ""
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);

if CLIENT then
	if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
		ENT.Category = Lib.Language.GetMessage("cat_others");
		ENT.PrintName = Lib.Language.GetMessage("entity_cfd");
		language.Add("call_forwarding_device", Lib.Language.GetMessage("entity_cfd_full"));
	end
end

if SERVER then

--if (Lib==nil or Lib.CheckModule==nil or not Lib.CheckModule("extra")) then return end

AddCSLuaFile();

function ENT:Initialize()
	self.Entity:SetModel("models/Assassin21/dial_device/dial_device.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Activated = false;
	self.Unlock = nil;
	self:CreateWireInputs("Activate","Unlock Code [STRING]");
	self:CreateWireOutputs("Active");
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid())then
		phys:EnableMotion(false);
		phys:SetMass(50);
	end
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local ang = p:GetAimVector():Angle(); ang.p = (90) % 360; ang.r = 0; ang.y = (ang.y+180) % 360;
	local pos = t.HitPos+Vector(0,0,1);
	local e = ents.Create("call_forwarding_device");
	e:SetPos(pos);
	e:SetAngles(ang);
	e:DrawShadow(true);
	e:SetVar("Owner",p)
	e:SetUseType(SIMPLE_USE)
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Use()
	if(not self.Activated)then
      self.Activated = true;
	elseif(self.Activated)then
	    self.Activated = false;
	end
end

function ENT:Window(v,unlockcode,force)
	local add = "(Offline)";
	local c = "can";
	if(v)then
	  add = "(Online)"
		c = "can't";
	end;
	self:SetOverlayText("Module "..add.."\nHumans "..c.." go through the Gate!\nUnlock Code ("..unlockcode..")");
end

function ENT:Think()
    local letters = {"A","B","C","D","E","F"};
	local c = {};
    for i=1,8 do
        c[i] = math.random(0,15);
	    if(c[i] > 9)then c[i] = letters[c[i]-9] end;
    end
	local unlockcode = tostring(c[1]..""..c[2]..""..c[3]..""..c[4]..""..c[5]..""..c[6]..""..c[7]..""..c[8]);
	if(self.Unlock == unlockcode)then
	    self.Activated = false;
	end
    self:Window(self.Activated, unlockcode);
	self:SetWire("Active",self.Activated);
	self.Entity:NextThink(CurTime()+0.5);
	return true;
end

function ENT:TriggerInput(k,v)
	if(k == "Activate")then
		if (v>0) then
	    	self.Activated = true;
		else
	   		self.Activated = false;
		end
	end
	if(k == "Unlock Code")then
	    if(v ~= "")then
	        self.Unlock = v;
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "call_forwarding_device", Lib.EAP_GmodDuplicator, "Data" )
end

end
