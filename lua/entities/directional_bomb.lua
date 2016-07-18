--[[
	Shaped Charge
	Copyright (C) 2010 Madman07
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Shaped Charge"
ENT.Author = "Madman07, Boba Fett"
ENT.Category = Lib.Language.GetMessage("cat_weapons");
ENT.WireDebugName = "Shaped Charge"
ENT.Spawnable = true
ENT.AdminSpawnable = true

list.Set("EAP", ENT.PrintName, ENT);

if SERVER then

AddCSLuaFile();

ENT.Sounds = {
	Tick = Sound("tech/bomb_tick.wav"),
	Explode = Sound("weapons/dir_nuke.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/directional_nuke/directional_nuke.mdl");

	self.Entity:SetName("Shaped Charge");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self:SetNetworkedInt("Timer",0);
	self:SetNWBool("ShouldCount",false);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("EAP_dirn_max"):GetInt()
	if(ply:GetCount("EAP_dirn")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_shaped\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("directional_bomb");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,20));
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("EAP_dirn", ent)
	return ent
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (Lib.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("EAP_dirn_max"):GetInt()
	if (IsValid(ply)) then
		if(ply:GetCount("EAP_dirn")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"entity_limit_shaped\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("EAP_dirn", self.Entity)
	end
	Lib.Wire.PostEntityPaste(self,ply,Ent,CreatedEntities)
	Lib.RD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	if (self.Owner == ply) then
		umsg.Start("DirectTimer",ply)
		umsg.Entity(self.Entity);
		umsg.End()
		if timer.Exists("Count"..self:EntIndex()) then timer.Destroy("Count"..self:EntIndex()); end
		if timer.Exists("Tick"..self:EntIndex()) then timer.Destroy("Tick"..self:EntIndex()); end
		self:SetNWBool("ShouldCount",false);
	end
end

-----------------------------------OTHER CRAP----------------------------------

function ENT:Think(ply)
	concommand.Add("DN_Set"..self:EntIndex(),function(ply,cmd,args)
		self:SetNWBool("ShouldCount",false);
		local time = tonumber(args[1]);
		self:SetNWInt("Timer",time+1);
		self:SetNWBool("ShouldCount",true);
		if timer.Exists("Count"..self:EntIndex()) then timer.Destroy("Count"..self:EntIndex()); end
		timer.Create( "Count"..self:EntIndex(), time, 1, function()
			self:SetNWBool("ShouldCount",false);
			if IsValid(self) then self:DoExplosion(); end
		end);
		if timer.Exists("Tick"..self:EntIndex()) then timer.Destroy("Tick"..self:EntIndex()); end
		if (time > 1) then
			timer.Create( "Tick"..self:EntIndex(), 1, time-1, function()
				self:EmitSound(self.Sounds.Tick,100,100);
			end);
		end
		self:EmitSound(self.Sounds.Tick,100,100);
    end);
end

function ENT:DoExplosion()
	local a  = Lib.FindGate(self, 600)
	if IsValid(a) then a:WormHoleJump(true) end

	self:EmitSound(self.Sounds.Explode,100,100);

	local b = self:GetAttachment(self:LookupAttachment("Front"))
	if(not (b and b.Pos)) then return end
	local attacker,owner = Lib.GetAttackerAndOwner(self.Entity);
	util.ScreenShake(b.Pos,2,2.5,1,700);
	util.BlastDamage(owner, attacker, b.Pos, 250, 250)

	local effectdata = EffectData()
		effectdata:SetStart(b.Pos) // not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin(b.Pos)
		effectdata:SetScale( 1 )
	util.Effect( "HelicopterMegaBomb", effectdata )
	self.Entity:Remove();
end

function ENT:OnRemove()
	if timer.Exists("Count"..self:EntIndex()) then timer.Destroy("Count"..self:EntIndex()); end
	if timer.Exists("Tick"..self:EntIndex()) then timer.Destroy("Tick"..self:EntIndex()); end
end

if (Lib and Lib.EAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "directional_nuke", Lib.EAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (Lib.Language!=nil and Lib.Language.GetMessage!=nil) then
	ENT.Category = Lib.Language.GetMessage("cat_weapons");
	ENT.PrintName = Lib.Language.GetMessage("entity_directional_nuke");
end

local font = {
	font = "quiver",
	size = ScreenScale(20),
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("Digital2", font)

function ENT:Initialize()
	self.Started = false;
end

function ENT:Draw()
	self.Entity:DrawModel();

	local shouldcount = self:GetNetworkedBool("ShouldCount",false);
	if (shouldcount and not self.Started) then
		self.Started = true;
		self.TargetTime = CurTime() + self:GetNWInt("Timer",0);
	end
	if not shouldcount then
		self.Started = false;
	end

	local data = self:GetAttachment(self:LookupAttachment("Screen"))
	if not (data and data.Pos and data.Ang) then return end
	local ang = data.Ang;
	ang:RotateAroundAxis(self.Entity:GetForward(),-90);

	local time = 0;
	if shouldcount then
		time = self.TargetTime - CurTime();
		if (time<0) then time = 0; end
	end

	local str = string.FormattedTime(time, "%02i:%02i")

	cam.Start3D2D(data.Pos,ang,0.08);
		surface.SetDrawColor(255,0,0,255)
		local col = Color(255,0,0);
		draw.SimpleText(str,"Digital2",0,0,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
	cam.End3D2D();
end

local VGUI = {}
function VGUI:Init()

	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos(ScrW()/2-115, ScrH()/2-60)
   	DermaPanel:SetSize(230, 120)
	DermaPanel:SetTitle( Lib.Language.GetMessage("directional_nuke_menu_t") )
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( false )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function()
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
    end

	local image = vgui.Create("DImage" , DermaPanel);
    image:SetSize(10, 10);
    image:SetPos(10, 10);
    image:SetImage("img/eap_logo");

	local timlab = vgui.Create('DLabel')
	timlab:SetParent( DermaPanel )
	timlab:SetPos(20, 40)
	timlab:SetText(Lib.Language.GetMessage("directional_nuke_menu_d"))
	timlab:SizeToContents()

	local timr = vgui.Create('DNumberWang')
	timr:SetParent( DermaPanel )
	timr:SetPos(145, 38)
	timr:SetDecimals(0)
	timr:SetFloatValue(0)
	timr:SetFraction(0)
	timr:SetValue('1')
	timr:SetMinMax(1, 120)

	local cancel = vgui.Create('DButton')
	cancel:SetParent( DermaPanel )
	cancel:SetSize(70, 25)
	cancel:SetPos(130, 80)
	cancel:SetText(Lib.Language.GetMessage("directional_nuke_menu_c"))
	cancel.DoClick = function()
		DermaPanel:Remove();
	end

	local OK = vgui.Create('DButton')
	OK:SetParent( DermaPanel )
	OK:SetSize(70, 25)
	OK:SetPos(30, 80)
	OK:SetText('OK')
	OK.DoClick = function()
		LocalPlayer():ConCommand("DN_Set"..e:EntIndex().." "..timr:GetValue());
		DermaPanel:Remove();
	end

end
vgui.Register( "DirectTimerEntry", VGUI )

function DirectTimer(um)
	local Window = vgui.Create( "DirectTimerEntry" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	e = um:ReadEntity();
	if(not IsValid(e)) then return end;
end
usermessage.Hook("DirectTimer", DirectTimer)

end