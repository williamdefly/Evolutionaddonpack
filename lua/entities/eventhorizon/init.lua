/*
	Stargate Eventhorizon for GarrysMod10
	Copyright (C) 2007-2009  aVoN
	Modification to add WormHole Animation and travel security Copyright (C) 2016-2017 Elanis

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

--################# HEADER #################
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("modules/bullets.lua");
AddCSLuaFile("modules/collision.lua");
include("shared.lua");
include("modules/teleport.lua");
include("modules/bullets.lua");
include("modules/collision.lua");

local BUFFER = {InBuffer = {}};

--################# Defines
ENT.IgnoreTouch = true; -- This tells the physical objects like drones or staff not to collide with the eventhorizon (= no explode on them)
ENT.CDSIgnore = true; -- Fixes Combat Damage System destroying this entity
ENT.DrawEnterEffectTime = 0;
ENT.EAP_NotSave = true;
ENT.DoNotDuplicate = true

ENT.DefModel = Model("models/zup/stargate/stargate_horizon.mdl");
ENT.Sounds = {
	Idle=Sound("stargate/wormhole_loop.wav"),
	Teleport={Sound("stargate/teleport.mp3"),Sound("stargate/teleport_2.mp3"),Sound("stargate/teleport_3.mp3"),Sound("stargate/teleport_4.mp3"),Sound("stargate/teleport_5.mp3"),Sound("stargate/teleport_6.mp3"),Sound("stargate/teleport_7.mp3"),Sound("stargate/teleport_8.mp3")},
	Close=Sound("stargate/gate_close.mp3"),
	Open=Sound("stargate/gate_open.mp3"),  -- You can manually change this later when you spawn the event horizon in the SpawnFunction!
	OpenNox=Sound("stargate/hand_gateopen_device.wav"),
}

ENT.NoTouchTeleport = {
	"kino_ball",
	"npc_grenade_frag",
	"rpg_missile",
	"grenade_ar2",
	"crossbow_bolt",
	"prop_combine_ball",
	"energy_pulse",
	"energy_pulse_stun",
	"drones",
	"npc_satchel",
	"hunter_flechette",
	"grenade_helicopter",
	"weapon_striderbuster",
	"grenade_spit",
	"prop_ragdoll",
	"horizon_missile",
}

-- These entities are immune against autoclose and should also never avoid an autoclose event if to near to a gate
ENT.AutocloseImmunity = {
	"npc_grenade_frag",
	"rpg_missile",
	"grenade_ar2",
	"crossbow_bolt",
	"npc_satchel",
	"prop_combine_ball",
	"hunter_flechette",
	"grenade_helicopter",
	"weapon_striderbuster",
	"grenade_spit", -- Antlion poison blasts
	"cloaking",
	"shield",
	"sg_iris",
	"goauld_iris",
	"gmod_ghost", -- AdvDupe/Dupe ghostpreview - For some obvious reason, it's having a physics object...
	"prop_dynamic",
	"kino_ball",
}

BUFFER.ClipIgnore = {
	"eventhorizon",
	"dakara_building",
	"anim_ramps",
	"ramp",
	"ramp_2",
	"goauld_iris",
	"ramp",
	"kino_ball",
	"models/madman07/stargate/ring_sg1.mdl",
	"energy_pulse",
	"energy_pulse_stun",
	"rpg_missile",
	"grenade_ar2",
	"npc_grenade_frag",
	"prop_combine_ball",
	"grenade_helicopter",
	"prop_ragdoll",
	"black_hole_power",
	"shield_core_buble",
}

--################# SENT CODE ###############

--################# Init @aVoN
function ENT:Initialize()
	-- We need a "fresh" copy of sounds for this entity. Otherwise "SGA-opening-sounds" might overwrite "SG1-opening-sounds", because ENT.Sounds is global!
	self.Sounds = table.Copy(self.Sounds);
	local parent = self.Entity:GetParent();

	if(IsValid(parent)) then
		if(parent.Sounds and parent.Sounds.Open) then
			self.Sounds.Open = parent.Sounds.Open;
		end
		if(parent.Sounds and parent.Sounds.OpenNox) then
			self.Sounds.OpenNox = parent.Sounds.OpenNox;
		end
		if(parent.Sounds and parent.Sounds.Close) then
			self.Sounds.Close = parent.Sounds.Close;
		end
		if (parent.EAPGateSpawnerSpawned) then
			self.EAPGateSpawnerSpawned = true;
		end
		if (parent.EHColor) then
			self.EHColor = parent.EHColor
  		end
	end

	self.Material = ""
	self.UnstableMaterial = ""
	self.Model = self.DefModel
	self.Entity:EHType()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_NONE);
	self.Entity:SetTrigger(true); -- The most important thing: Makes the EH trigger Touch() events, even when it's not solid
	self.Entity:SetNotSolid(true);
	self.Entity:DrawShadow(false);
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	-- Do not draw the model now (Alpha must be 1 because for some mystical reason, setting this to 0 makes effects not draw on it. Seems like Valva/garry added stuff not to draw things which actually have alpha = 0 to save performance) -- STILL? I've seen, it works with 0 now too
	local col = table.Copy(self.EHColor or self.DefColor)
	self:SetEHColor(col);
	col = table.Copy(col)
	col.a = 0
	self:SetColor(col)
	self.Created = CurTime();
	self.AutoClose = Lib.CFG:Get("stargate","autoclose",true);
	self.WaterNoClose = Lib.CFG:Get("stargate","water_noclose",true);
	self.HorizonRadius = self.Entity:BoundingRadius(); -- Just needed for effects
	self.OpeningDelay = 1.5; -- This time decides when the script starts it's opening effect after it played the opening sound
	self.OpenTime = 2.2;
	self.Holding = {}; -- A player holds this Entity: We are not going to teleport it until he stopped holding it!
	self.DoNotDestroy = {}; -- A contraption just got teleported to this event horizon but hasn't exited it yet. This prevents the receiving EH from destroying this contraption!
	self.OpenEffect = true; -- Need to place up here so we have the variable ready
	self:Open(); -- Let us open :D

	self.Ents={};
	self.CollisionGroup = {};
	self.Buffer = {};
	self.AllBuffer = {};
	self.ClipBuffer = {};
	self.GravBuffer = {};
	self.Opened = false;
	self.ValidOpen = false;
	self.ModelClip = GetConVar("stargate_eap_model_clipping"):GetBool();

	if self.ModelClip then
		self.PhysClip = GetConVar("stargate_eap_physics_clipping"):GetBool();
		if (self.PhysClip) then
			hook.Add( "ShouldCollide", "ShouldEHEntitiesCollide", ShouldEHEntitiesCollide )
		else
			hook.Remove( "ShouldCollide", "ShouldEHEntitiesCollide" )
		end
	else
		self.PhysClip = false;
		hook.Remove( "ShouldCollide", "ShouldEHEntitiesCollide" )
	end

	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableCollisions(false);
	end

	if (pewpew and pewpew.NeverEverList and not table.HasValue(pewpew.NeverEverList,self.Entity:GetClass())) then table.insert(pewpew.NeverEverList,self.Entity:GetClass()); end -- pewpew support
end

function ENT:EHType(reset)
	if (reset) then
		self.Material = ""
		self.UnstableMaterial = ""
		self.Model = self.DefModel
	end

	local parent = self:GetParent()
	local type = parent.EventHorizonType;
	local Data = Lib.EventHorizonTypes[type] or {}

	self.DefColor = table.Copy(Data.Color) or Color(255,255,255)

	if (Data.LightColor) then
		self.Entity:SetNWVector("LightColR",Data.LightColor.r);
		if (not Data.LightColor.sync) then
			self.Entity:SetNWVector("LightColG",Data.LightColor.g);
			self.Entity:SetNWVector("LightColB",Data.LightColor.b);
		end
		self.Entity:SetNWBool("LightSync",Data.LightColor.sync);
	end

	if (Data.Material) then self.Material = Data.Material end
	self.Entity:SetMaterial(self.Material);
	if (Data.UnstableMaterial) then self.UnstableMaterial = Data.UnstableMaterial end

	if (parent.EventHorizonData.Model) then self.Model = parent.EventHorizonData.Model end
	self.Entity:SetModel(self.Model);

	if (parent.OnEventHorizonType) then
		parent:OnEventHorizonType(self,reset,type,Data)
	end
end

function ENT:SetEHColor(col)
	self.Color = col
	self:SetColor(self.Color)
	if (self.Color.r!=self.DefColor.r or self.Color.g!=self.DefColor.g or self.Color.b!=self.DefColor.b) then
	    self.Entity:SetNWBool("LightCustom",true);
		--self.Entity:SetNWVector("LightColor",self.Color)
	else
	    self.Entity:SetNWBool("LightCustom",false);
	end
end

function ENT:Flicker(reset)
	if (reset) then
		if (self.UnstableMaterial!="") then
			self:SetMaterial(self.Material);
		else
		    self:SetNWBool("Flicker",false);
		end
		--self:SetColor(Color(255,255,255,255)); -- fix invisible eh sometimes in mp
		self:SetColor(self.Color)
		self.Unstable = false;
	else
		if (self.UnstableMaterial!="") then
			self:SetMaterial(self.UnstableMaterial);
		else
			local col = table.Copy(self.Color)
			col.a = math.random(55,165)
		    self:SetColor(col) -- legacy
			self:SetNWBool("Flicker",true);
		end
		if not self.ShuttingDown then
			self:EmitSound(self:GetParent().UnstableSound,90,math.random(97,103));
		end
		self.Unstable = true;
		self:BufferEmpty();
	end
end
--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
--function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# OnRemove @aVoN
function ENT:OnRemove()
	-- Kill wormhole idle sound
	if(self.IdleSound)then
	    self.IdleSound:Stop();
	end
	-- Remove no-collide from our gate
	local parent = self.Entity:GetParent();
	if(IsValid(parent)) then
		parent:SetCollisionGroup(COLLISION_GROUP_NONE);
	end

	self:EndTouch()
end

--################# Set the target GATE (not Event Horizon!!!!!) we are linked to. We need to retrieve the target Horizon later manually
function ENT:SetTarget(e)
	self.TargetGate = e;
end

--################# Are we opened? @aVoN
function ENT:IsOpen()
	if(not self.Opened and self.Created + self.OpenTime + self.OpeningDelay > CurTime()) then
		return false; -- We havent opened yet;
	end
	self.Opened = true; -- Do not calculate this above. This saves performance, even when it's really less. But coding performance saving is always good
	self.ValidOpen = true; -- just to be sure
	return true;
end

-- Just for DEBUG so I can spawn it from the SENT menu
-- FIXME: Remove this function later
function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end
	local e = ents.Create("eventhorizon");
	e:SetPos(t.HitPos+Vector(0,0,90));
	e:SetAngles(Angle(0,p:GetAimVector():Angle().y,0));
	e:Spawn();
	e:Activate();
	return e;
end

--################# The openeing effect @aVoN
function ENT:Open()
        self.Attached = {}; -- These entities won't be dissolveable when the EH openes (Welded/Attached props)
        local parent = self.Entity:GetParent();
        if(IsValid(parent)) then
            self.Attached[parent] = true;
            if(IsValid(parent.Target)) then
           		self.Attached[parent.Target] = true;
            end
            self.Attached[self.Entity] = true;
			for _,v in pairs(Lib.GetConstrainedEnts(parent,10) or {}) do
				self.Attached[v] = true; -- Instead of doing a table.HasValue() everytime we do this - Much faster!
           end
        end
        local e = self.Entity;
		local gt = 0;

		local class = self:GetParent():GetClass();
		local nox_type = self:GetParent().NoxDialingType; // let it spawn without kawoosh, like nox/asgard/cassandra can do
    	if (nox_type) then
			self.OpeningDelay = 0.87;
			self.OpenTime = 0.9;
    	else
    		local EHData = self:GetParent().EventHorizonData
			self.OpeningDelay = EHData.OpeningDelay;
			self.OpenTime = EHData.OpenTime;
			gt = 1;
		end

        --##### This effect simply is the eventhorizon creation effect. It's NOT the kawoosh!
		if self.OpenEffect then
			local fx = EffectData();
			fx:SetEntity(e);
			fx:SetRadius(gt or 0);
			fx:SetOrigin(e:GetPos());
			fx:SetScale(self.OpeningDelay+0.2); -- The additional delay stops the effect from stopping to early so the other (below) is getting started to late (Noticabel by a short flicker)
			util.Effect("event_horizon_open",fx,true,true);
		end
		if (nox_type) then
			self.Entity:EmitSound(self.Sounds.OpenNox,90,math.random(98,102));
		else
			self.Entity:EmitSound(self.Sounds.Open,90,math.random(98,102));
		end

		local Gate = self.Entity:GetParent()
 		local Data = self.KawooshTypes[Gate.EventHorizonKawoosh or "sg1"];
		self.KawooshData = Data.KawooshDmg;

        timer.Create("EventHorizonOpening"..self.Entity:EntIndex(),self.OpeningDelay,1,
                function()
                        if(IsValid(e)) then
                                local blocked = false;
                                if(IsValid(parent) and parent.IsStargate) then
                                        blocked = parent:IsBlocked();
                                end
                                --##### Now, we will FIRST OF ALL get the corresponding event horizon!
                                if(not IsValid(self.Target) and IsValid(self.TargetGate)) then
                                        self.Target = self.TargetGate.EventHorizon;
                                elseif(not IsValid(self.TargetGate) and IsValid(parent) and IsValid(parent.Target) and parent.Outbound) then
                                	-- neuroplanes fix
									self.TargetGate = parent.Target;
									self.Target = self.TargetGate.EventHorizon;
                                end
                                --##### Start opening
                                e:SetNWEntity("Target",self.Target); -- Tell clientside what our target is (Necessary for the ENT:GetTeleportedVector function, if used clientside)
                                local pos = e:GetPos();
                                e:SetColor(e.Color); -- Draw model now
                                -- May fixes this bug where the EH is invisible
                                timer.Simple(e.OpenTime+0.3, -- Compensates up to a ping of 300 ms
                                        function()
                                                if(IsValid(e)) then
                                                        e:SetColor(e.Color); -- Draw model (just to be sure)
                                                end
                                        end
                                );
                                e:SetNWBool("activate_lights",true); -- Tell the event horizon to activate his dynamic lights!
                                if (not nox_type) then
                                	util.ScreenShake(pos,2,2.5,3,1000); -- Add the earth quake when the gate openes!
                                end
                                -- The lovely idle sound
                                e.IdleSound = CreateSound(e,e.Sounds.Idle);
                                e.IdleSound:Play();
                                --##### Do the "gate stabilize" effect. When you watch stargate, youll always see a quite brighter overlay just shortly after the EH has been established
                                local fx = EffectData();
                                fx:SetEntity(e);
                                fx:SetOrigin(pos);
                                if (nox_type) then
                                	fx:SetScale(0.8); -- Time in seconds until it dies
                                else
                                	fx:SetScale(e.OpenTime); -- Time in seconds until it dies
                                end
                                timer.Simple(0.6,function() if(IsValid(self)) then self.Entity:SetColor(self.Color); end end)
                                timer.Simple(e.OpenTime,function()
									if(IsValid(self)) then
										self.ValidOpen = true;
										self:SetColor(self.Color);
										self:SetNWBool("AllowBacksideDrawing",true);
									end
								end);
								if not nox_type then
									if not blocked then
										timer.Simple(e.OpenTime - 0.5, function()
											if (IsValid(self)) then
												self:EnterEffect(self:GetPos(),300,true);
											end
										end);
									end
								end
								if self.OpenEffect then
									-- proper rendering fix
									fx:SetOrigin(pos+e:GetForward()*0.3);
									fx:SetRadius(0)
									util.Effect("eventhorizon_stabilize",fx);
									fx:SetOrigin(pos-e:GetForward()*0.3);
									fx:SetRadius(1)
									util.Effect("eventhorizon_stabilize",fx);
								end
                                --##### The Kawoosh (Yeah, that thing which comes out the gate and kills peopl/stuff)
					if (not blocked and not nox_type) then -- gate is not blocked - Add kawoosh
					local fx = EffectData();
					fx:SetEntity(e);
					--##################### @ Llapp
					-- recode by AlexALX
					local Gate = self.Entity:GetParent()
					local Data = self.KawooshTypes[Gate.EventHorizonKawoosh or "sg1"];
					self.KawooshData = Data.KawooshDmg;
					fx:SetRadius(Gate.EventHorizonType=="universe" and 1 or 0);
					fx:SetMagnitude(Data.ID)
					util.Effect("sg_kawoosh",fx,true,true);
					-- This will kill people
					local pos = self.Entity:GetPos();
					local normal = self.Entity:GetForward();
					local radius = self.Entity:BoundingRadius()*Data.KawooshDmg[1];
					if (Data.BackKawooshTime) then
						timer.Simple(Data.BackKawooshTime,function()
							if (IsValid(self)) then
								self:EHDissolve(pos-radius*normal,radius);
								local fx = EffectData()
								fx:SetEntity(e);
								fx:SetRadius(Gate.EventHorizonType=="universe" and 1 or 0);
								util.Effect("sg_kawoosh_movie",fx,true,true);
							end
						end);
					end
					self:EHDissolve(pos+radius*normal,radius);
					self:EHDissolve(pos+3*radius*normal,radius);
					self:EHDissolve(pos+5*radius*normal,radius);
				end
                                --##### Refract to the event horizon (Because people complained it's to less)
                                local fx = EffectData();
                                fx:SetEntity(e);
                                fx:SetOrigin(pos);
                                if self.OpenEffect then
                                	util.Effect("eventhorizon_refract",fx,true,true);
                                end
                        end
                end
        );
end

--################# The dissolve function of the kawoosh. MOST LEET FUNCTION EVER! @TetaBonita & aVoN
-- Some sort of inspired by TetaBonitas Strider Cannon: His dissolving way is much cuter than my crappy "Lasers". This thing isn't a complete copy and paste
-- The way he does it is already the only way to do it. So I mentioned him "for being the first" who has done this.
function ENT:EHDissolve(pos,radius)
	-- The hurt will actually kill things and give credits to the stargate as killer
	local e = ents.Create("kawooshhurt");
	e:SetOwner(self.Entity);
	e:SetKeyValue("Damage",10000);
	e:SetKeyValue("DamageRadius",radius);
	e:SetKeyValue("DamageType",bit.bor(DMG_DISSOLVE, DMG_BLAST));
	e:SetPos(pos);
	e:SetParent(self.Entity);
	if (self.GateSpawnerSpawned) then e.GateSpawnerSpawned = true; end
	e:Spawn();
	local Data = self.KawooshData;
	for i=0,Data[2] do
		e:Fire("hurt","",0.12*i);
	end
	e:Fire("kill","",Data[3]);
	-- Start dissolving the crap!
	if(Lib.CFG:Get("stargate","disintegrate",true)) then
		timer.Simple(0.01,function() if IsValid(self.Entity) then self:DissolveEntities(pos,radius) end end);
	end
end

--################# Dissolving entities @TetaBonita & aVoN
function ENT:DissolveEntities(pos,radius)
	if (self.Attached==nil) then return end
	local name = "EH_DISSOLVE_"..self:EntIndex();
	for _,v in pairs(ents.FindInSphere(pos,radius)) do
		/*if v.IsGroupStargate then
			v:Remove()
			if IsValid(v) then
				local e = ents.Create("gatenuke");
				e:Setup(self.Entity:GetPos(), 100)
				e:SetVar("owner",self.Owner)
				e:Spawn()
				e:Activate()
			end
			v:Remove();
		end*/
		if(not (self.Attached[v] or v.EAPGateSpawnerSpawned or v.NoDissolve)) then
			if(v:GetMoveType() == 6 and not self.Attached[v:GetParent()] and not self.Attached[v:GetDerive()]) then
				if (constraint.HasConstraints(v)) then
					local entities = Lib.GetConstrainedEnts(v,2);
					local cont = false;
					if(entities) then
						for c,b in pairs(entities) do
							if(b:IsWorld()) then
								cont = true;
								break;
							end
						end
					end
					if (cont) then continue end
				end
				local phys = v:GetPhysicsObject();
				local class = v:GetClass();
				local mdl = v:GetModel(); -- We are searching e.g. for map entities (func_brush etc): Models with an "*" in it's modelname are such things

				--[[
				if v:GetClass()=="sg_*" then
					v:Remove()
					if IsValid(v) then
						local e = ents.Create("gatenuke");
						e:Setup(self.Entity:GetPos(), 100)
						e:SetVar("owner",self.Owner)
						e:Spawn()
						e:Activate()
					end
					self.Parent:Remove();
				end
				]]--

				-- Do not dissolve crap!
				if(phys:IsValid() and (class == "phys_magnet" or not class:find("phys_[^m]")) and mdl ~= "" and not mdl:find("*")) then
					phys:EnableMotion();
					v:SetKeyValue("targetname",name);
					for bone=0,v:GetPhysicsObjectCount()-1 do
						local phys = v:GetPhysicsObjectNum(bone);
						if(phys:IsValid()) then
							phys:SetVelocity(phys:GetVelocity()*0.04);
							phys:EnableGravity(false);
						end
					end
				end
			end
		end
	end
	-- Start the real cool dissolving effect
	local e = ents.Create("env_entity_dissolver");
	e:SetKeyValue("dissolvetype",3);
	e:SetKeyValue("magnitude",0);
	e:SetPos(pos);
	e:SetKeyValue("target",name);
	e:Spawn();
	e:Fire("Dissolve",name,0);
	e:Fire("kill","",0.1);
end


--################# Shutting down the event horizon @aVoN
function ENT:Shutdown(override)
	if(self.ShuttingDown or (not self:IsOpen() and not override)) then return end; -- Aready shutting down or not opened yets
	--self:StopSound(self.Sounds.Idle,0.4);
	--self.Entity:SetColor(Color(255,255,255,255));
	if (self.IdleSound) then self.IdleSound:Stop() end
	timer.Remove("EventHorizonEffect"..self.Entity:EntIndex());
	timer.Remove("EventHorizonOpening"..self.Entity:EntIndex());
	self.ShuttingDown = true;
	self.ShuttingDownKill = true;
	if self.OpenEffect then
		local fx = EffectData();
		fx:SetEntity(self.Entity);
		fx:SetOrigin(self.Entity:GetPos());
		util.Effect("event_horizon_collapse",fx,true,true);
	end
	if(IsValid(self.Target)) then
		self.Target:Shutdown(override);
	end
	self.Entity:EmitSound(self.Sounds.Close,90,math.random(97,103));
	local e = self.Entity;
	for k,v in pairs(self.AllBuffer) do
		if (IsValid(v)) then
			self:EHDissolve(v:GetPos(),5)
			if(v:IsPlayer()) then
				umsg.Start("Lib.EventHorizon.WormHoleStop",k);
				umsg.End();
			end
		end
	end
	-- Let the light fade away!
	timer.Simple(2,
		function()
			if(IsValid(e)) then
				e:SetNWBool("activate_lights",false);
				e.ShuttingDownKill = false;
			end
		end
	);
	-- Make sure, it will be deleted!
	timer.Simple(4,
		function()
			if(IsValid(e)) then
				e:Remove();
			end
		end
	);
end

function ENT:BufferEmpty()
	if(self.ShuttingDown or not self:IsOpen()) then return end; -- Aready shutting down or not opened yets
	for k,v in pairs(self.AllBuffer) do
		if (IsValid(v)) then
			self:CleanBufferVars(v) -- may prevent physics crash
			self:EHDissolve(v:GetPos(),5)
		end
	end
	self.AllBuffer = {};
	self.ClipBuffer = {};
	self.Buffer = {};
end

--################# Hit @aVoN
function ENT:Hit()
	if(self.ShuttingDown) then return end;
	-- This basically is the same as the establish effect until someone else does a better one
	local fx = EffectData();
	fx:SetEntity(self.Entity);
	fx:SetOrigin(self.Entity:GetPos());
	fx:SetScale(0.5); -- Time in seconds until it dies
	util.Effect("event_horizon_establish",fx);
end

--################# Draws an entering effect on the event horizon @aVoN
function ENT:EnterEffect(pos,size,kawoosh)
	local diff = self:WorldToLocal(pos); diff.x = 0;
	local thresold = (self.HorizonRadius - diff:Length()/1.3);
	local effect_radius = size*2;
	effect_radius = math.Clamp(effect_radius,0,thresold);
	-- This effect isnt perfect or looks like the original one. Sometimes you event can't see it. But I dont mind.
	local fx = EffectData();
	-- This is, so the effect will be drawn always on the frontside of the event horizon
	local dist = self:WorldToLocal(self:NearestPoint(pos));
	fx:SetOrigin(self:LocalToWorld(dist)); -- I love this freaking "NearestPoint" function
	fx:SetEntity(self);
	fx:SetScale(effect_radius);
	if (kawoosh) then
		if (IsValid(self:GetParent()) and self:GetParent():GetClass()=="sg_supergate") then
			util.Effect("gate_enter_super",fx,true,true);
		else
			util.Effect("gate_enter_kawoosh",fx,true,true);
		end
	else
		util.Effect("gate_enter",fx,true,true);
	end
end

--################# This is a wrapper for entities entering the EH @aVoN
function ENT:EnterEffectEntity(e)
	local pos = e:LocalToWorld(e:OBBCenter());
	local radius = e:BoundingRadius();
	self:EnterEffect(pos,radius);
end

--################# The most important part - Recognizes entering props and teleports them @RononDex
function ENT:StartTouch(e)
	local class = e:GetClass();
 	--if (e:GetClass() == "kino_ball") then self:StartTouchPlayersNPCs(e) end
	if self.ModelClip then
		if(not self:GetParent().IsSupergate) then
			if(not IsValid(self.Target)) then
				if(class=="ship_puddle_jumper" and not self.ShuttingDown) then
					if(e.Exiting) then
						e:SetPos(self:GetPos());
					end
				end
			end
		end

		if (self.PhysClip) then
			e:SetCustomCollisionCheck(true);
		end
		if(not e:IsPlayer() and not e:IsNPC() and not string.find(e:GetClass(),"grenade") and not e:IsWeapon() and not string.find(e:GetClass(),"rpg") and not table.HasValue(self.NoTouchTeleport,e:GetClass()) and not e.EAP_EH_NoTouchTeleport) then
			if not table.HasValue(BUFFER.ClipIgnore,e:GetClass()) then
				BUFFER:StartTouch(self.Entity,e)
			end
		else
			self:StartTouchPlayersNPCs(e)
		end
	else
		self:StartTouchPlayersNPCs(e);
	end
end

--################# Keeps clipping plane up to date @RononDex
function ENT:Touch(e)
	local class = e:GetClass();
	if self.ModelClip then
		if not table.HasValue(BUFFER.ClipIgnore,e:GetClass()) then
			BUFFER:Touch(self.Entity,e)
		end
		if(not self:GetParent().IsSupergate) then
			if(class=="ship_puddle_jumper" and not self.ShuttingDown) then
				if(not IsValid(self.Target)) then
					e.Exiting = true;
					if(IsValid(e.Pilot)) then
						e.Pilot:SetEyeAngles(self:GetParent():GetAngles());
					end
					e:SetAngles(self:GetParent():GetAngles()+Angle(0,0,0));
				end
			end
		end
	end
end

function ENT:StartTouchPlayersNPCs(e,ignore)
	if(self.Attached[e]) then return end; -- Attached props
	if(self.ShuttingDown and not self.ShuttingDownKill) then return; end
	if(not IsValid(e)) then return end; -- Not valid
	if(e:IsPlayer() and (IsValid(e:GetParent()) or IsValid(e:GetVehicle()) or IsValid(e:GetNetworkedEntity("ScriptedVehicle", NULL)))) then return end; -- No teleport/kill of parented players
	if(e.NotTeleportable) then return end; -- Does not want to be teleported!
	local class = e:GetClass();
	if(class:find("sg")) then return end;
	local parent = self.Entity:GetParent();
	--################# This fixes props, which not have exited the receiving EH yet are getting deleted
	if(e.__StargateTeleport and e.__StargateTeleport.__TARGET == self.Entity) then
		-- Start the check
		local add = false;
		if(e.__StargateTeleport.__LastTeleport + 0.5 > CurTime()) then -- GraceTime says: "Add this entity to DoNotDestroy list!"
			add = true;
		else -- GraceTime is over. But do we still have entities in our DoNotDestroy list which belong to this entity? If so, DO NOT DESTROY!
			for k,_ in pairs(self.DoNotDestroy) do
				if(e.__StargateTeleport[k]) then
					add = true;
					break;
				end
			end
		end
		if(add) then
			-- Nocollide the gate as long as something is in it!
			if(IsValid(parent)) then
				-- If a nocollide timer has been started, stop it so it won't interfere
				timer.Remove("Lib.SetReceivingGateCollide"..parent:EntIndex());
				parent:SetCollisionGroup(COLLISION_GROUP_WORLD);
			end
			self.DoNotDestroy[e] = true;
			return;
		end
	end
	-- Makes the prop getting teleported as soon as the player stops holding it
	if(e:IsPlayerHolding()) then
		self.Holding[e] = true;
	else
		--################# Is our receiving gate blocked?
		local block = false;
		local target_gate; -- Used in here and a bit lower later (for the iris hit sounds)
		if(not self:IsOpen() or self.ShuttingDownKill) then block = true end; -- We havent opened yet. Kill people!
		-- Are we entering the eventhorizon from the wrong side? Kill us!
		local dir = (self.Entity:GetVelocity()-e:GetVelocity()):GetNormalized();

		if(self.Entity:GetForward():DotProduct(dir) < 0) then
			block = true
		else
			-- Our iris prvents us from getting in "from the front" (but not from the back aka "die"
			if (not ignored and IsValid(parent) and parent:IsBlocked(true)) then
				if (not self.SecretDial or not e:IsPlayer()) then
					self.DoNotDestroy[e] = true;
					return;
				end
			end
		end
		if(not block and not IsValid(self.Target)) then block = true end; -- Do we have a valid target? If not, we are inbound
		if (self.Unstable) then
			block = true
		end
		local bcfd = false;
		-- Not yet getting killed? So check, if the otherside has an iris activated
		if(not block) then
			target_gate = self.Target:GetParent();
			if(IsValid(target_gate) and target_gate.IsStargate) then
				block = target_gate:IsBlocked();
			end
			if (self:BlockedCFD(target_gate,e)) then block = false; bcfd = true; end
		end
		--################# Get attachments, mainly for the hook below but we need it anyway
		local attached = self:GetEntitiesForTeleport(e);
		if(attached) then
			local allow_teleport = hook.Call("Lib.Teleport",GAMEMODE,e,self.Entity,attached,blocked);
			if(allow_teleport ~= nil and not allow_teleport) then return end; -- Someone does not want to teleport us! Shame on him
			--################# Just for the show - The "gulping" effect
			-- Before we teleport, draw the entering effect on out event horizon
			if (not ignore) then
				self:EnterEffectEntity(e);
				self.Entity:EmitSound(self.Sounds.Teleport[math.random(1,#self.Sounds.Teleport)],90,math.random(90,110));
			end
			if (e:IsPlayer() and self.SecretDial and not ignore and self.Entity:GetForward():DotProduct(dir) >= 0) then
				self:DoSecret(e);
			else
				self:DoWormHole(e,block,attached,bcfd);
			end
		end
	end
end

--################# Stops being in the eventhorizon @aVoN
function ENT:EndTouchPlayersNPCs(e)
	self.DoNotDestroy[e] = nil;
	if(e.__StargateTeleport) then
		e.__StargateTeleport.__LastTeleport = CurTime(); -- Avoids a bug where parts of a contraption has holes between each other. This results into not destroying the object.
	end
	if(table.Count(self.DoNotDestroy) == 0) then
		-- Remove the nocollide again (but delayed)
		local parent = self.Entity:GetParent();
		timer.Create("Lib.SetReceivingGateCollide"..parent:EntIndex(),1,1,
			function()
				if(IsValid(parent)) then
					parent:SetCollisionGroup(COLLISION_GROUP_NONE);
				end
			end
		);
	end
	self.Holding[e] = nil;
end

--ENT.Buffer = {}
--################# Stops being in the eventhorizon @aVoN,RononDex
function ENT:EndTouch(e)
	if(self.ShuttingDown) then return end; -- We are shutting down
	if(not IsValid(e)) then return end; -- Not valid or ignore
	if(e:IsPlayer() and (IsValid(e:GetParent()) or IsValid(e:GetVehicle()) or IsValid(e:GetNetworkedEntity("ScriptedVehicle",NULL)))) then return end;  -- No teleport/kill of parented players
	if(e.NotTeleportable) then return end; -- Does not want to be teleported!

	local parent = self.Entity:GetParent();

	if(e:IsPlayer() or e:IsNPC() or table.HasValue(self.NoTouchTeleport,e:GetClass()) or string.find(e:GetClass(),"grenade") or string.find(e:GetClass(),"rpg") or e:IsWeapon()) then
		self:EndTouchPlayersNPCs(e)
		return
	elseif not self.ModelClip then
		self:EndTouchPlayersNPCs(e)
		return;
	end

	if(not self:GetParent().IsSupergate) then
		if(e:GetClass()=="ship_puddle_jumper") then
			if(not IsValid(self.Target)) then
				e.Exiting = false;
				e.Exited = true;
				timer.Simple(1,function()
					e.Exited = false;
				end);
			end
		end
	end

	local dir = (self:GetPos()-e:GetPos()):GetNormalized();

	local temp_dir = 0;
	if(self:GetForward():DotProduct(dir) < 0) then
		temp_dir = -1;
	else
		temp_dir = 1;
	end

	if self.ModelClip then
		if (self.PhysClip) then
			e:SetCustomCollisionCheck(false);
		end
		if not table.HasValue(BUFFER.ClipIgnore,e:GetClass()) then
			BUFFER:EndTouch(self.Entity,e,nil,temp_dir)
		end
	end

	-- If the ent came out the way it was going in, don't destroy/teleport
	if(e.___EventHorizon != self or temp_dir != e.dir) then
		e.___InBuffer = false;
		e.___EventHorizon = nil;
		return;
	else
		e.___InBuffer = true;
		e.___EventHorizon = self;
	end

	if(self.Holding[e]) then
		if(not IsValid(e)) then
			self.Holding[e] = nil;
			return;
		end
		if(not e:IsPlayerHolding()) then
			self.Holding[e] = nil;
			self:EndTouch(e);
		end
	end

	local attached = self:GetEntitiesForTeleport(e);
	if(attached) then
		for _,v in pairs(attached.Attached) do
			if (IsValid(v) and v:IsPlayerHolding()) then
				self.Holding[v] = true;
				--self:EndTouch(v,true);
			elseif (not IsValid(v)) then
				self.Holding[v] = nil;
			end
		end
	end

	-- TELEPORT CODE
	--################# This fixes props, which not have exited the receiving EH yet are getting deleted
	if(e.__StargateTeleport and e.__StargateTeleport.__TARGET == self.Entity) then
		-- Start the check
		local add = false;
		if(e.__StargateTeleport.__LastTeleport + 0.5 > CurTime()) then -- GraceTime says: "Add this entity to DoNotDestroy list!"
			add = true;
		else -- GraceTime is over. But do we still have entities in our DoNotDestroy list which belong to this entity? If so, DO NOT DESTROY!
			for k,_ in pairs(self.DoNotDestroy) do
				if(e.__StargateTeleport[k]) then
					add = true;
					break;
				end
			end
		end
		if(add) then
			-- Nocollide the gate as long as something is in it!
			if(IsValid(parent)) then
				-- If a nocollide timer has been started, stop it so it won't interfere
				timer.Remove("Lib.SetReceivingGateCollide"..parent:EntIndex());
				parent:SetCollisionGroup(COLLISION_GROUP_WORLD);
			end
			self.DoNotDestroy[e] = true;
			return;
		end
	end
	-- Makes the prop getting teleported as soon as the player stops holding it
	if(e:IsPlayerHolding()) then
		self.Holding[e] = true;
	else
		--################# Is our receiving gate blocked?
		local block = false;
		local target_gate; -- Used in here and a bit lower later (for the iris hit sounds)
		if(not self:IsOpen()) then block = true end; -- We havent opened yet. Kill people!
		-- Are we entering the eventhorizon from the wrong side? Kill us!
		local dir = (self.Entity:GetVelocity()-e:GetVelocity()):GetNormalized();

		if(self.Entity:GetForward():DotProduct(dir) < 0) then
			block = true
		else
			-- Our iris prvents us from getting in "from the front" (but not from the back aka "die"
			if(IsValid(parent) and parent:IsBlocked(true)) then
				self.DoNotDestroy[e] = true;
				return;
			end
		end
		if(not block and not IsValid(self.Target)) then block = true end; -- Do we have a valid target? If not, we are inbound
		if (self.Unstable) then
			block = true
		end
		-- Not yet getting killed? So check, if the otherside has an iris activated
		if(not block) then
			target_gate = self.Target:GetParent();
			if(IsValid(target_gate) and target_gate.IsStargate) then
				block = target_gate:IsBlocked();
			end
		end
		--################# Get attachments, mainly for the hook below but we need it anyway
		local attached = self:GetEntitiesForTeleport(e);
		if(attached) then
			for _,v in pairs(attached.Attached) do
				if(not v.___InBuffer or self.Holding[v]) then return end;
			end
			local allow_teleport = hook.Call("Lib.Teleport",GAMEMODE,e,self.Entity,attached,blocked);
			if(allow_teleport ~= nil and not allow_teleport) then return end; -- Someone does not want to teleport us! Shame on him
			--################# Just for the show - The "gulping" effect
			-- Before we teleport, draw the entering effect on out event horizon
			self:EnterEffectEntity(e);
			self.Entity:EmitSound(self.Sounds.Teleport[math.random(1,#self.Sounds.Teleport)],90,math.random(90,110));
			--################# Teleport us
			self:Teleport(e,block,attached);
			--################# Blocked or not? Either make iris play the "blocked" sound or draw the gulping at the other end
			local class = e:GetClass();
			if(block) then
				if (not self.Unstable) then
					-- Iris blocked us. Make hut-noise
					if(IsValid(target_gate) and IsValid(target_gate.Iris) and target_gate.Iris.IsActivated) then
						target_gate.Iris:HitIris(self:GetTeleportedVector(e:GetPos(),e:GetVelocity())); -- Tell that we hit and where and how fast
					end
				end
				e.___InBuffer = false;
				e.___EventHorizon = nil;
			else
				-- Needs to be delayed, or you wont hear the teleporting gulp if your a player
				local t = self.Target
				timer.Simple(0.05,
					function()
						if(IsValid(t) and IsValid(e)) then
							e.___dir = nil;
							for _,v in pairs(attached.Attached) do
								if (IsValid(v)) then
									local dir = (t:GetPos()-v:GetPos()):GetNormalized();
									local temp_dir = 0;
									if(t:GetForward():DotProduct(dir) < 0) then
										temp_dir = -1;
									else
										temp_dir = 1;
									end
                                    if (temp_dir==1) then
										t:StartTouch(v);
									end
									v.___dir = nil;
								end
							end
							t:EmitSound(self.Sounds.Teleport[math.random(1,#self.Sounds.Teleport)],90,math.random(90,110));
							-- Draw the effect on the other eventhorizon
							t:EnterEffectEntity(e);
						end
					end
				);
				if(
					self.AutoClose and -- Disabled by config - Overrides every other setting
					not (
						e.NoAutoClose or -- Disabled by SENT Writer
						table.HasValue(self.AutocloseImmunity,class) or -- Disabled by me
						(IsValid(parent) and parent.DisAutoClose) -- Wire forbids it
					)
				) then
					--################# Autoclose the gate after a delay
					self.DoAutoClose = true;
					self.Entity:NextThink(CurTime()+3); -- Trigger autoclose in the next 3 seconds
				end
			end
		end
	end
	-- END TELEPORT CODE

	self.DoNotDestroy[e] = nil;
	if(e.__StargateTeleport) then
		e.__StargateTeleport.__LastTeleport = CurTime(); -- Avoids a bug where parts of a contraption has holes between each other. This results into not destroying the object.
	end
	if(table.Count(self.DoNotDestroy) == 0) then
		-- Remove the nocollide again (but delayed)
		local parent = self.Entity:GetParent();
		timer.Create("Lib.SetReceivingGateCollide"..parent:EntIndex(),1,1,
			function()
				if(IsValid(parent)) then
					parent:SetCollisionGroup(COLLISION_GROUP_NONE);
				end
			end
		);
	end
	self.Holding[e] = nil;
end

--################# For the autoclose @aVoN
function ENT:Think()
	if(self.DoAutoClose) then
		if(not self.WaterNoClose or self:WaterLevel() < 1) then
			-- FIXME: Add config for the autoclose
			local gate = self.Entity:GetParent();
			if(IsValid(gate)) then
				-- Prevents some bugs
				if(not IsValid(self.Target)) then
					gate:DeactivateStargate();
					return;
				end
				local close = true;
				for k,v in pairs(self.Buffer) do
					if (IsValid(v)) then
						close = false;
						break;
					else
						self.Buffer[k] = nil;
					end
				end
				if (IsValid(self.Target)) then
					for k,v in pairs(self.Target.Buffer) do
						if (IsValid(v)) then
							close = false;
							break;
						else
							self.Target.Buffer[k] = nil;
						end
					end
				end
				for _,e in pairs({self.Entity}) do
					if(close) then
						local parent = e:GetParent();
						if(IsValid(parent)) then
							local constrained = (Lib.GetConstrainedEnts(parent,3) or {}); -- Constrained props to a stargate SHOULD NEVER keep it open!
							for _,v in pairs(ents.FindInSphere(e:GetPos(),e:BoundingRadius())) do
								local class = v:GetClass();
								if(not table.HasValue(constrained,v) and not table.HasValue(self.AutocloseImmunity,class)) then
									local vp = v:GetParent(); -- Parents of the object we found
									local phys = v:GetPhysicsObject();
									if(
										(phys:IsValid() and phys:IsMoveable()) and -- Has to be unfrozen/Movable
										(v ~= e and v ~= parent and not v.IsStargate and not v.IsDHD and not v.EAPGateSpawnerSpawned) and -- General entities
										(not IsValid(vp) or (vp ~= parent and not vp.IsDHD and not vp.IsStargate and not vp.EAPGateSpawnerSpawned))
									) then
										-- Keep the EH open!
										if(not v:IsPlayer() or v:Alive()) then -- Only if it's a player who is alive
											close = false;
											break;
										end
									end
								end
							end
						end
					end
					if(close)then
						gate:DeactivateStargate();
					else
						-- Check a bit more frequently now!
						self.Entity:NextThink(CurTime()+0.5);
						return true;
					end
				end
			end
		end
	end
	self.Entity:NextThink(CurTime()+3);
	return true;
end


--[[
	Beyond here is all model clipping related code
]]--

local KeyValue1 = {"xfriction","yfriction","zfriction","forcelimit","torquelimit"};
local MaxValue = {"xmax","ymax","zmax"};
local MinValue = {"xmin","ymin","zmin"};
--############### What happens when we first touch the EH? Clip maybe? @RononDex
function BUFFER:StartTouch(EventHorizon,e)

	if(not IsValid(e) or self:ClipShouldIgnore(e,true)) then return end; -- Not valid or ignore
	if(not IsValid(e.___EventHorizon)) then e.___EventHorizon = EventHorizon end;
	if(not IsValid(EventHorizon)) then return end;
	if(EventHorizon.ShuttingDown and not EventHorizon.ShuttingDownKill) then return; end
	local attached = EventHorizon:GetEntitiesForTeleport(e);
	if(EventHorizon.Attached[e]) then return end
	if (EventHorizon.AllBuffer[e:EntIndex()]) then return end

	local dir = (e:GetPos()-EventHorizon:GetPos()):GetNormalized();

	if(EventHorizon:GetForward():DotProduct(dir) < 0 and e.___dir==nil) then
		e.dir = -1;
	else
		e.dir = 1;
		EventHorizon.Buffer[e:EntIndex()] = e
		e.___dir = nil;
	end

	EventHorizon.AllBuffer[e:EntIndex()] = e
    /*if (IsValid(e:GetParent())) then
		table.insert(e:GetParent().___Parents,e);
	end */

	if(not e:IsPlayer() and not e:IsNPC()) then
		e.gate = EventHorizon;
		e.gate.agate = EventHorizon:GetParent();
		if (EventHorizon.PhysClip) then
			e:SetNWBool("PhysBuffered",true);
			e:SetNWInt("PhysBufferedDir",e.dir);
			e:SetNWEntity("PhysEntity",e.gate);
		end
		//e:SetNWEntity("PhysEntityGate",e.gate.agate);
	end

	umsg.Start("Lib.EventHorizon.ClipStart");
		umsg.Short(e.dir)
		umsg.Entity(e);
		umsg.Entity(EventHorizon);
	umsg.End();

	if(not(e:GetClass()=="kino_ball")) then
		if(IsValid(e:GetPhysicsObject())) then
			EventHorizon.GravBuffer[e:EntIndex()] = e:GetPhysicsObject():IsGravityEnabled();
			e:GetPhysicsObject():EnableGravity(false);
		end
	end

	if(attached) then
		for _,v in pairs(attached.Attached) do
			if (IsValid(v)) then
				if(IsValid(phys) and v:GetSolid()!=SOLID_NONE) then
					v.dir = e.dir
					v:SetNWInt("PhysBufferedDir",e.dir);
					local phys = v:GetPhysicsObject();
					EventHorizon.GravBuffer[v:EntIndex()] = phys:IsGravityEnabled();
					phys:EnableGravity(false);
				end
			end
		end
	end

	e.EventHorizonNoCollide = ents.Create("phys_ragdollconstraint");
	e.EventHorizonNoCollide:SetKeyValue("spawnflags",3);
	for _,v in pairs(MaxValue) do
		e.EventHorizonNoCollide:SetKeyValue(v, 180 );
	end
	for _,v in pairs(MinValue) do
		e.EventHorizonNoCollide:SetKeyValue(v, -180 );
	end
	for _,v in pairs(KeyValue1) do
		e.EventHorizonNoCollide:SetKeyValue(v,0);
	end
	e.EventHorizonNoCollide:SetPhysConstraintObjects(game.GetWorld():GetPhysicsObject(),e:GetPhysicsObject());
	e.EventHorizonNoCollide:Spawn();
	e.EventHorizonNoCollide:Activate();

end

function BUFFER:Touch(EventHorizon,e)

	if(not IsValid(e) or self:ClipShouldIgnore(e)) then return end; -- Not valid or ignore
	if(not IsValid(EventHorizon)) then return end;
	if(not e:GetPhysicsObject():IsValid()) then return end;
	if(EventHorizon.Attached[e]) then return end
	if(EventHorizon.ShuttingDown and not EventHorizon.ShuttingDownKill) then return; end
	if(e:IsPlayer()) then return end
	if (e.___LastCurTime!=nil and e.___LastCurTime==CurTime()) then return end -- PREVENT FUCKING DISCONNECT ON PAUSE IN SP WHEN SOMETHING TOUCH EH!!! Damn it...
	e.___LastCurTime = CurTime();

	-- Draw the enter effect every 20th frame, @Deathmaker
	if (e.___DrawEnterEffectTime!=nil and e.___DrawEnterEffectTime>20) then
		EventHorizon:EnterEffectEntity(e)
		e.___DrawEnterEffectTime=0
	else
		e.___DrawEnterEffectTime = (e.___DrawEnterEffectTime or 0)+1
	end
	-- damn, with old code at same time can be only one effect displaying, fixed by AlexALX

	--########### This handle's what happens when an object is touching the EH and shutsdown
	if(EventHorizon.ShuttingDownKill or EventHorizon.Unstable or not EventHorizon.ValidOpen) then
		if(e.IsJumper) then
			e:DoKill(e.Pilot) -- Jumpers and Vehicles are destroyed
		elseif(e.IsSGVehicle) then
			e:Bang(e.Pilot)
		else
			for _,v in pairs(constraint.GetAllConstrainedEntities(e)) do
				if(IsValid(v)) then
					BUFFER:EndTouch(EventHorizon,v,true)
				end
			end
			if(not(EventHorizon.Attached[e])) then
				EventHorizon:EHDissolve(e:GetPos(),5)
			end
		end
	end

	umsg.Start("Lib.EventHorizon.ClipStart")
		umsg.Short(e.dir)
		umsg.Entity(e)
		umsg.Entity(EventHorizon)
	umsg.End()
end

function ENT:CleanBufferVars(e)
	self.Buffer[e:EntIndex()] = nil
	self.AllBuffer[e:EntIndex()] = nil
	self.ClipBuffer[e:EntIndex()] = nil
	self.GravBuffer[e:EntIndex()] = nil
	e:SetNWBool("PhysBuffered",false);
	e:SetNWInt("PhysBufferedDir",0);
	e.gate = nil;
	e:SetNWEntity("PhysEntity",NULL);
	//e:SetNWEntity("PhysEntityGate",NULL);
	/*if(not nograv and IsValid(e:GetPhysicsObject())) then
		e:GetPhysicsObject():EnableGravity(true);
	end*/

	if(IsValid(e.EventHorizonNoCollide)) then
		e.EventHorizonNoCollide:Remove();
	end

	umsg.Start("Lib.EventHorizon.ClipStop");
		umsg.Entity(e);
	umsg.End()

	e.IsInGate = false;
	BUFFER.InBuffer[e] = nil;
	e.___InBuffer = false;
	e.___dir = nil;
end

--############# What happens when we have stopped touching the gate? Stop Clipping? @RononDex
function BUFFER:EndTouch(EventHorizon,e,ignore,tdir)

	local attached = EventHorizon:GetEntitiesForTeleport(e);
	if(not(IsValid(e))) then return end;
	if(not IsValid(EventHorizon)) then return end;
	if(self:ClipShouldIgnore(e,true)) then return end;
    local notouch = false;

	for k,v in pairs (EventHorizon.ClipBuffer) do
		if (not v:IsValid()) then
			EventHorizon.ClipBuffer[k] = nil;
		end
	end

	//print_r(EventHorizon.ClipBuffer)
	--if (attached==false) then return end
	if(attached and not ignore) then
		for _,v in pairs(attached.Attached) do

			-- less buggy, but still...
			if (IsValid(v) and IsValid(v:GetPhysicsObject()) and v:GetSolid()!=SOLID_NONE) then
				local tvdir = 0;
				local dir = (v:GetPos()-EventHorizon:GetPos()):GetNormalized(); --(EventHorizon:GetVelocity()-e:GetVelocity()):GetNormalized();
				if(EventHorizon:GetForward():DotProduct(dir) < 0) then
					tvdir = -1;
				else
					tvdir = 1;
				end
				if (tdir==1 and tvdir!=tdir and not EventHorizon.ClipBuffer[v:EntIndex()]) then
					EventHorizon.ClipBuffer[v:EntIndex()] = v
					v.___InBuffer = true;
					--return
				elseif (tdir==1 and tvdir==tdir and EventHorizon.ClipBuffer[v:EntIndex()]) then
					EventHorizon.ClipBuffer[v:EntIndex()] = nil
					v.___InBuffer = nil;
					--return
				elseif (tdir==-1 and tvdir!=tdir and not EventHorizon.AllBuffer[v:EntIndex()]) then
					EventHorizon.AllBuffer[v:EntIndex()] = v
					v.___InBuffer = nil;
					self:EndTouch(EventHorizon,v,true,tdir);
					--return
				--elseif (tdir==-1 and tvdir==tdir and not EventHorizon.ClipBuffer[v:EntIndex()]) then
					--EventHorizon.ClipBuffer[v:EntIndex()] = v
					--v.___InBuffer = true;
					--self:EndTouch(EventHorizon,v,true,tdir);
					--return
				end
			end

		end

		for _,v in pairs(attached.Attached) do

			if (IsValid(v) and IsValid(v:GetPhysicsObject()) and v:GetSolid()!=SOLID_NONE) then
				if (v.dir==tdir and not EventHorizon.ClipBuffer[v:EntIndex()]) then
					EventHorizon.ClipBuffer[v:EntIndex()] = v
					return
				elseif (v.dir!=tdir and EventHorizon.AllBuffer[v:EntIndex()]) then
					EventHorizon.ClipBuffer[v:EntIndex()] = nil
					notouch = true;
				end
			end
		end
	end

	if(IsValid(e.EventHorizonNoCollide)) then
		e.EventHorizonNoCollide:Remove();
	end

	if(e.___InBuffer and e.dir==tdir) then
		self.InBuffer[e] = true;
	else
		e.IsInGate = false;
		self.InBuffer[e] = nil;
	end

	EventHorizon.Buffer[e:EntIndex()] = nil
	EventHorizon.AllBuffer[e:EntIndex()] = nil
	EventHorizon.ClipBuffer[e:EntIndex()] = nil
	e:SetNWBool("PhysBuffered",false);
	e:SetNWInt("PhysBufferedDir",0);
	e.gate = nil;
	e:SetNWEntity("PhysEntity",NULL);
	//e:SetNWEntity("PhysEntityGate",NULL);
	--e.dir = nil;

	e.___dir = nil;

	umsg.Start("Lib.EventHorizon.ClipStop");
		umsg.Entity(e);
	umsg.End();

	if (not notouch) then
		if(IsValid(e:GetPhysicsObject())) then
			if (EventHorizon.GravBuffer[e:EntIndex()]!=nil) then
				e:GetPhysicsObject():EnableGravity(EventHorizon.GravBuffer[e:EntIndex()]);
				EventHorizon.GravBuffer[e:EntIndex()] = nil;
			end
		end
	end

	if(attached and not notouch) then
		/*local ents = {e};
		local nograv = false;
		for _,v in pairs(attached.Attached) do
			if (IsValid(v)) then
				if (EventHorizon.AllBuffer[v:EntIndex()]) then
					nograv = true;
				else
					table.insert(ents,v);
				end
			end
		end
		if (not nograv) then
			for _,v in pairs(ents) do
				if(IsValid(v)) then
					if(IsValid(v:GetPhysicsObject())) then
						v:GetPhysicsObject():EnableGravity(true);
					end
				end
			end
		end*/
		for _,v in pairs(attached.Attached) do
			if (IsValid(v) and EventHorizon.AllBuffer[v:EntIndex()]) then
				self:EndTouch(EventHorizon,v,true)
			end
			if(not EventHorizon.AllBuffer[v:EntIndex()] and IsValid(v)) then
				if(IsValid(v:GetPhysicsObject())) then
					if (EventHorizon.GravBuffer[v:EntIndex()]!=nil) then
						v:GetPhysicsObject():EnableGravity(EventHorizon.GravBuffer[v:EntIndex()]);
						EventHorizon.GravBuffer[v:EntIndex()] = nil;
					end
				end
			end
		end
	end
end

--################ Destroy anthing in the EH's buffer @RononDex
function BUFFER:EmptyBuffer(EventHorizon)
	if(IsValid(EventHorizon)) then
		for k,v in pairs(self.InBuffer) do
			if(IsValid(k)) then
				if(k:IsPlayer() and not k:HasGodMode() or k:IsNPC()) then
					k:KillSilent();
				else
					k:Remove();
				end
			end
		end
	end
end

--############### What should we ignore @RononDex
function BUFFER:ClipShouldIgnore(ent,reset_cache)
	local class = ent:GetClass()
	if (table.HasValue(self.ClipIgnore,class) || table.HasValue(self.ClipIgnore,ent:GetModel()) || Lib.RampOffset.Gates[ent:GetModel()] || ent.EAPGateSpawnerSpawned || string.find(class,"sg_") || ent.EAP_EH_NoTouch) then return true end
	if (reset_cache) then ent.__EHConstCache = nil; end
	if (ent.__EHConstCache!=nil) then return ent.__EHConstCache end
	-- adding cache for save performance
	ent.__EHConstCache = false;
	if (constraint.HasConstraints(ent)) then
		local entities = Lib.GetConstrainedEnts(ent,2);
		if(entities) then
			for k,v in pairs(entities) do
				if(v:IsWorld()) then
					ent.__EHConstCache = true;
					return true;
				end
			end
		end
	end

	return false
end

local hook_added = false

function ENT:DoSecret(v)

	if (not hook_added) then
		hook.Add("PostPlayerDeath","Lib.EH.Secret",function(ply)
			umsg.Start("Lib.EventHorizon.SecretStop",ply);
			umsg.End();
		end)
		hook_added = true
	end

	umsg.Start("Lib.EventHorizon.SecretStart",v);
	umsg.End();

	local old_pos = v:GetPos();
	local old_angles = v:EyeAngles();
	local old_velocity = v:GetVelocity();

	-- Store restore informations
	local restore ={
		MoveType=v:GetMoveType(),
		Solid=v:GetSolid(),
		Color = v:GetColor(),
		Bones = self:GetBones(v),
		RenderMode = v:GetRenderMode(),
		God = v:HasGodMode(),
	};
	-- Attach the Entity to the harvester
	v:SetRenderMode( RENDERMODE_TRANSALPHA );
	v:SetColor(Color(0,0,0,0));
	v:SetSolid(SOLID_NONE);
	v:SetMoveType(MOVETYPE_NONE);
	--v:SetPos(pos);
	--v:SetParent(self.Entity);
	-- Now, let's change the bone's positions!
	--for _,bone in pairs(restore.Bones) do
	--	bone.Entity:SetPos(v:LocalToWorld(bone.Position));
	--end
	-- Make players spectate the harvester
	if(v:IsPlayer()) then
		v.DisableSpawning = true; -- Can't spawn props
		v.DisableSuicide = true; -- Can't suicide
		v.DisableNoclip = true; -- Disallows him to move or change his movetypez
		v:Spectate(OBS_MODE_CHASE);
		v:SpectateEntity(self.Entity);
		v:DrawViewModel(false);
		v:DrawWorldModel(false);
		restore.Weapons={};
		for _,w in pairs(v:GetWeapons()) do
			table.insert(restore.Weapons,w:GetClass());
		end
		local w = v:GetActiveWeapon();
		if(w and w:IsValid()) then
			restore.ActiveWeapon = w:GetClass();
		end
		v:StripWeapons();
	end
	self.Ents[v] = restore;

	local k = v;
	local v = self.Ents[k];

	timer.Create("Lib.EH.Secret.Out"..k:EntIndex(),7.0,1,function()
		if (not IsValid(k)) then return end

		if (not IsValid(self) or self.ShuttingDown and not self.ShuttingDownKill) then
			if (not k:HasGodMode()) then
				k:SetColor(v.Color);
				k:SetRenderMode(v.RenderMode);
				k:UnSpectate();
				k:DrawViewModel(true);
				k:DrawWorldModel(true);
				k:StripWeapons();
				k:KillSilent();
				timer.Simple(0.2,
					function()
						if(k and IsValid(k)) then
							k:SetColor(v.Color);
							k:SetRenderMode(v.RenderMode);
						end
					end
				);
				k.DisableSpawning = nil; -- Allow him again to spawn things
				k.DisableSuicide = nil; -- Allow him to commit suicide again
				k.DisableNoclip = nil;
				umsg.Start("Lib.EventHorizon.SecretReset",k);
				umsg.End();
				umsg.Start("Lib.EventHorizon.PlayerKill");
				umsg.Entity(k);
				umsg.End();
				return
			end
		end

		umsg.Start("Lib.EventHorizon.SecretOut",k);
		umsg.End();

		-- Special settings for a player
		if(k:IsPlayer()) then
			k:SetParent(nil);
			k.DisableSpawning = nil; -- Allow him again to spawn things
			k.DisableSuicide = nil; -- Allow him to commit suicide again
			k.DisableNoclip = nil;
			k:UnSpectate();
			k:DrawViewModel(true);
			k:DrawWorldModel(true);
			k:Spawn();
			if (v.God) then k:GodEnable() end

			-- FIXME: Does sometimes not work. Timer is NO SOLUTION as the fucking timer lags players
			for _,w in pairs(v.Weapons) do
				if(not k:HasWeapon(w)) then
					k:Give(w);
				end
			end
			-- This is a workaround for my own scripts. Using SelectWeapon two times (or just frequently) results into a spawnlag
			if(v.ActiveWeapon) then
				k.DefaultWeapon = v.ActiveWeapon;
				timer.Simple(0,
					function()
						-- We found out, WeaponManager is either in the wrong addon-load-order or not installed. So select it this way!
						if(k:IsValid() and k.DefaultWeapon) then
							k:SelectWeapon(k.DefaultWeapon);
							k.DefaultWeapon = nil;
						end
					end
				);
			end
		end
		-- General settings
		k:SetMoveType(v.MoveType);
		k:SetSolid(v.Solid);
		k:SetParent(nil); -- Again!
		k:SetPos(old_pos);
		k:SetEyeAngles(old_angles);
		k:SetColor(v.Color);
		k:SetRenderMode(v.RenderMode);
		local e = k;
		--k:SetVelocity(old_velocity);
		--Failsafe
		timer.Simple(0.2,
			function()
				if(e and IsValid(e)) then
					e:SetColor(v.Color);
					e:SetRenderMode(v.RenderMode);
				end
			end
		);
		-- Fix up the bones
		-- Now, let's change the bone's positions!
		/*for _,bone in pairs(v.Bones) do
			if(bone.Entity:IsValid()) then
				bone.Entity:SetPos(k:LocalToWorld(bone.Position));
			end
		end*/
		-- Wake the entity up
		if(v.MoveType==MOVETYPE_VPHYSICS) then
			local phys=k:GetPhysicsObject();
			if(phys:IsValid()) then
				phys:EnableMotion(true);
				phys:Wake();
			end
		end

		if (IsValid(self)) then
			self:StartTouchPlayersNPCs(k,true)
	           /*
			local normal = (k:GetPos()-self:GetPos()):GetNormal();

			k:SetLocalVelocity(normal*600);
			k:SetVelocity(normal*600);
	             */
			self.Ents[k]=nil;
		end
	end)

end

function ENT:DoWormHole(v,block,attached,bcfd) --Let's do travel animation ! @Elanis

	if(v:IsPlayer() and not v:Alive()) then return end -- If the player die on enter in the gate don't do all stuff or he will be blocked !
	if(string.sub(v:GetClass(), 1, 5 )=="ship_" and v:GetOwner():IsPlayer() and not v:GetOwner():Alive()) then return end -- Same if he die in the ship !
	if(table.HasValue(self.NoTouchTeleport,v:GetClass())) then return end

	-- Kill if shutting down
	if(self.ShuttingDown) then
		if(v:IsPlayer()) then
			v:Kill();
		else
			v:Remove();
		end
		return;
	end

	-- Check the convars to know if we need to do the animation
	local haveTowait = false;
	local clientConvar = 0
	-- ClientSide Convar
	if(v:IsPlayer())then
		clientConvar = v:GetInfoNum("cl_stargate_wormhole", 0 );
	elseif(IsValid(v:GetOwner())) then
		clientConvar = v:GetOwner():GetInfoNum("cl_stargate_wormhole", 0 );
	end
	-- ServerSide Convar
	if(Lib.CFG:Get("stargate","wormhole_animation",false)==true) then -- Does the server force animation ?
		clientConvar = 1;
	end

	-- Prepare to transport
	local target_gate;
	-- Not yet getting killed? So check, if the otherside has an iris activated
	if(not block) then
		target_gate = self.Target:GetParent();
		if(IsValid(target_gate) and target_gate.IsStargate) then
			block = target_gate:IsBlocked();
		end
		if (self:BlockedCFD(target_gate,v)) then block = false; bcfd = true; end
	end

	if(self.Target==nil)then --You go in on the wrong gate so you die or will be removed
		if(v:IsPlayer())then v:Kill(); else v:Remove() end
		return
	end

	target_pos = self.Target:GetParent():GetPos();
	target_ang = self.Target:GetParent():GetAngles();

	-- Get informations about the entity to readd them while spawning
	local restore ={
		MoveType=v:GetMoveType(),
		Solid=v:GetSolid(),
		Color = v:GetColor(),
		Bones = self:GetBones(v),
		RenderMode = v:GetRenderMode(),
		Vel = v:GetVelocity(),
		Health = v:Health(),
	};

	if(v:IsPlayer())then --If this is a player
		if ((not hook_added) and (clientConvar==1)) then -- Hook if you die in the gate
			hook.Add("PostPlayerDeath","Lib.EH.WormHole",function(ply)
				umsg.Start("Lib.EventHorizon.WormHoleStop",ply);
				umsg.End();
			end)
			hook_added = true
		end

		if(clientConvar==1)then
			umsg.Start("Lib.EventHorizon.WormHoleStart",v); --Start Animation !
			umsg.End();
		end
		restore.God = v:HasGodMode();

		-- Make players spectate the gate
		v.DisableSpawning = true; -- Can't spawn props
		v.DisableSuicide = true; -- Can't suicide
		v.DisableNoclip = true; -- Disallows him to move or change his movetypez
		v:GodEnable() -- Can't be killed
		v:Freeze(true) -- Can't move
		v:DrawViewModel(false); --Hide weapons
		v:DrawWorldModel(false); --Hide weapons

		--Keep in mind what weapons we have, and strip them
		restore.Weapons={};
		for _,w in pairs(v:GetWeapons()) do
			table.insert(restore.Weapons,w:GetClass());
		end
		local w = v:GetActiveWeapon();
		if(w and w:IsValid()) then
			restore.ActiveWeapon = w:GetClass();
		end
		v:StripWeapons();

		if (clientConvar==1) then
			haveTowait = true;
		end
	elseif(string.sub(v:GetClass(), 1, 5 )=="ship_")then --If it's a ship

		if ((not hook_added) and (clientConvar==1)) then -- Hook if you die in the gate
			hook.Add("PostPlayerDeath","Lib.EH.WormHole",function(v)
				umsg.Start("Lib.EventHorizon.WormHoleStop",v:GetOwner());
				umsg.End();
			end)
			hook_added = true
		end

		if(clientConvar==1)then
			umsg.Start("Lib.EventHorizon.WormHoleStart",v:GetOwner()); --Start Animation !
			umsg.End();
		end

		v:SetHealth(2147483648); -- Max Gmod Life

		if (clientConvar==1) then
			haveTowait = true;
		end
	elseif (v:GetClass()=="prop_physics") then --If it's a prop
		v:SetHealth(2147483648); -- Max Gmod Life

		haveTowait = true;
	end


	-- The entity can't be see or touched
	v:SetRenderMode( RENDERMODE_TRANSALPHA );
	v:SetColor(Color(0,0,0,0));
	v:SetSolid(SOLID_NONE);
	v:SetMoveType(MOVETYPE_NONE);

	--We keep this informations in memory
	self.Ents[v] = restore;

	local k = v;
	local v = self.Ents[k];

	if(k:IsPlayer() and not k:Alive()) then -- If the player dies at the very very wrong moment !
		haveTowait = false;
	end

	/* It's time to move ! */
	if(haveTowait)then
		--Wait after the animation end
		timer.Create("Lib.EH.WormHoleOut"..k:EntIndex(),4.16,1,function() self:MoveToTarget(k,v,block,attached,bcfd) end);
	else
		self:MoveToTarget(k,v,block,attached,bcfd);
	end
end

function ENT:MoveToTarget(k,v,block,attached,bcfd)
	if (not IsValid(k)) then return end

	local class = k:GetClass();
	local ent;

	if(string.sub(class, 1, 5 )=="ship_")then --Set entity owner as current entity
		ent = k;
		k = ent:GetOwner()
	end

	if(k:IsPlayer())then
		if (not IsValid(self) or not k:Alive() or self.ShuttingDown and not self.ShuttingDownKill)then
			if (not v.God) then
				k:GodDisable()
			end

			k:SetColor(v.Color);
			k:SetRenderMode(v.RenderMode);
			k:Freeze(false)
			k:DrawViewModel(true);
			k:DrawWorldModel(true);
			k:StripWeapons();
			k:KillSilent();
			timer.Simple(0.2,
				function()
					if(k and IsValid(k)) then
						k:SetColor(v.Color);
						k:SetRenderMode(v.RenderMode);
					end
				end
			);
			k.DisableSpawning = nil; -- Allow him again to spawn things
			k.DisableSuicide = nil; -- Allow him to commit suicide again
			k.DisableNoclip = nil;

			umsg.Start("Lib.EventHorizon.WormHoleReset",k);
			umsg.End();
			umsg.Start("Lib.EventHorizon.PlayerKill");
			umsg.Entity(k);
			umsg.End();

			if(ent!=nil) then
				ent:Remove(); --Delete the ship if the owner is in
			end
			return
		end
	elseif(self.ShuttingDown) then
		k:Remove();
	end
	if(ent!=nil) then
		k = ent; -- Back to the real entity if needed
	end

	if(k:IsPlayer())then
		umsg.Start("Lib.EventHorizon.WormHoleOut",k);
		umsg.End();
	elseif(string.sub(class, 1, 5 )=="ship_")then
		umsg.Start("Lib.EventHorizon.WormHoleOut",k:GetOwner());
		umsg.End();
	end

	-- Special settings for a player
	if(k:IsPlayer()) then
		k:Freeze(false)
		k:DrawViewModel(true);
		k:DrawWorldModel(true);
		k.DisableSpawning = nil; -- Allow him again to spawn things
		k.DisableSuicide = nil; -- Allow him to commit suicide again
		k.DisableNoclip = nil;
		k:GodDisable()

		if (v.God) then k:GodEnable() end

		-- FIXME: Does sometimes not work. Timer is NO SOLUTION as the fucking timer lags players
		for _,w in pairs(v.Weapons) do
			if(not k:HasWeapon(w)) then
				k:Give(w);
			end
		end
		-- This is a workaround for my own scripts. Using SelectWeapon two times (or just frequently) results into a spawnlag
		if(v.ActiveWeapon) then
			k.DefaultWeapon = v.ActiveWeapon;
			timer.Simple(0,
				function()
					-- We found out, WeaponManager is either in the wrong addon-load-order or not installed. So select it this way!
					if(k:IsValid() and k.DefaultWeapon) then
						k:SelectWeapon(k.DefaultWeapon);
						k.DefaultWeapon = nil;
					end
				end
			);
		end
	end

	k:SetHealth(v.Health); --Reset it to its normal life

	-- General settings
	k:SetMoveType(v.MoveType);
	k:SetSolid(v.Solid);
	k:SetColor(v.Color);
	k:SetRenderMode(v.RenderMode);
	k:SetParent(nil);

	-- Wake the entity up
	if(v.MoveType==MOVETYPE_VPHYSICS) then
		local phys=k:GetPhysicsObject();
		if(phys:IsValid()) then
			phys:EnableMotion(true);
			phys:Wake();
		end
	end

	if (IsValid(self)) then
		self.Ents[k]=nil;
	end

	self:Teleport(k,block,attached);

	if(not k:IsPlayer()) then k:SetVelocity(v.Vel); end --Reset his normal velocity

	--################# Blocked or not? Either make iris play the "blocked" sound or draw the gulping at the other end
	local t = self.Target
	if(block) then
		if (not self.Unstable) then
			-- Iris blocked us. Make hut-noise
			if(IsValid(t) and IsValid(t.Iris) and t.Iris.IsActivated) then
				t.Iris:HitIris(self:GetTeleportedVector(k:GetPos(),k:GetVelocity())); -- Tell that we hit and where and how fast
			end
		end
	else
		-- Needs to be delayed, or you wont hear the teleporting gulp if your a player
		local t = self.Target
		if (not bcfd) then
			timer.Simple(0.05,
				function()
					if(IsValid(t) and IsValid(e)) then
						t:EmitSound(self.Sounds.Teleport[math.random(1,#self.Sounds.Teleport)],90,math.random(90,110));
						-- Draw the effect on the other eventhorizon
						t:EnterEffectEntity(k);
					end
				end
			);
		end
		if(
			self.AutoClose and -- Disabled by config - Overrides every other setting
			not (
				k.NoAutoClose or -- Disabled by SENT Writer
				table.HasValue(self.AutocloseImmunity,class) or class:find("grenade") or class:find("rpg") or k:IsWeapon() or -- Disabled by me
				(IsValid(parent) and parent.DisAutoClose) -- Wire forbids it
			)
		) then
			--################# Autoclose the gate after a delay
			self.DoAutoClose = true;
			self.Entity:NextThink(CurTime()+3); -- Trigger autoclose in the next 3 seconds
		end
	end
end
