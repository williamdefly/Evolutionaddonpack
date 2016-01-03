SWEP.PrintName  = SGLanguage.GetMessage("wp_mimetisor");
SWEP.ClassName  ="eap_mimetisor";

SWEP.Author = "Matspyder"
SWEP.Contact = "http://sg-e.fr"
SWEP.Purpose = "Take Apparence of someone"
SWEP.Instructions = ""
SWEP.Base = "weapon_base";
SWEP.Slot = 2;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/c_arms_animations.mdl";
SWEP.WorldModel = "models/roltzy/w_sodan.mdl";

SWEP.Category			= "EAP"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.AdminOnly = false
SWEP.HoldType = "normal"


-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "none";
SWEP.Primary.Automatic = false


-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

-- Add weapon for NPCs
//list.Add("NPCUsableWeapons", {class = "weapon_kull", title = SWEP.PrintName or ""});

function SWEP:Initialize()
	self.Weapon:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
	//if SERVER and IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound(self.Sounds.Deploy,math.random(90,110),math.random(90,110)) end;
	return true;
end

--################### Dummys for the client @ aVoN
function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end

-- to cancel out default reload function
function SWEP:Reload() return end

if SERVER then

local Sounds = {
	Engage=Sound("npc/strider/striderx_alert4.wav"),
	Disengage=Sound("npc/turret_floor/die.wav"),
	Hurt=Sound("player/death5.wav"),
	Fail=Sound("buttons/button19.wav")
}


AddCSLuaFile();

local function GetPlayers()
	local plys = {}
	for k,v in pairs(player.GetAll()) do
		if (v:IsConnected()) then
			if(v:GetActiveWeapon():GetClass()~="eap_mimetisor") then
				table.insert(plys,{v:EntIndex(),v:Name()});
			end
		end
	end
	return plys;
end

util.AddNetworkString("EAP.ChangeApparence");

function SWEP:PrimaryAttack()
	if(not IsValid(self.Owner) or not self.Owner:IsPlayer()) then return end;
	net.Start("EAP.ChangeApparence");
	net.WriteEntity(self);
	net.WriteInt(0,8);
	net.WriteTable(GetPlayers());
	net.Send(self.Owner);
end

/*function SWEP:Reload()
	if (self.Owner.CanChange) then
		local trace = self.Owner:GetEyeTrace()
		if (trace.Entity:IsPlayer()) then
			self:TakeApparence(trace.Entity)
			self.Owner.CanChange = false
			timer.Create("CanChangeModel"..self.Owner:Nick(),1,1, function()
				self.Owner.CanChange = true
			end)
		end
	end
end*/

net.Receive("EAP.ChangeApparence",function(len,ply)
	local self = net.ReadEntity();
	if (not IsValid(self)) then return end
	local tent = Entity(net.ReadInt(16));
	if (IsValid(tent)) then
		self:TakeApparence(tent);
	else
	   ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"asgardtp_error\"), NOTIFY_ERROR, 3); surface.PlaySound( \"buttons/button2.wav\" )");
	end
end)

function SWEP:SecondaryAttack()
	self:ResetModel()
	return true
end

function SWEP:TakeApparence(entity)
	if(self.Owner.HaveChangeModel) then
		self.Owner:PrintMessage(HUD_PRINTTALK,"Vous avez déjà configurer ce mimétiseur")
		self.Owner:EmitSound(Sounds.Fail,100,100)
	else
		self.Owner.BaseModel = self.Owner:GetModel()
		self.Owner:SetModel(entity:GetModel());
		self.Owner:EmitSound(Sounds.Engage,100,100)
		self.Owner:ChatPrint("Vous avez maintenant l'apparence de "..entity:Nick())
		self.Owner.HaveChangeModel = true
		self.Owner.PlayerSkin = entity:GetModel()
	end
end

function SWEP:ResetModel()
	if(self.Owner.HaveChangeModel)then
		self.Owner:SetModel(self.Owner.BaseModel)
		self.Owner:EmitSound(Sounds.Disengage,100,100)
		self.Owner:ChatPrint("Vous avez retrouvé votre apparence normale")
		self.Owner.HaveChangeModel = false
		self.Owner.PlayerSkin = nil
	end
end

hook.Add("PlayerSpawn","EAP.MimetisorSpawn",function(player)
	player.HaveChangeModel = false
	player.BaseModel = nil
	player.PlayerSkin = nil
	if(player:IsAdmin())then
		player:Give("eap_mimetisor")
	end
end)

--################### Holster @aVoN
function SWEP:Holster()
	//self.Owner:EmitSound(self.Sounds.Holster,90,math.random(90,110));
	return true;
end

end

if CLIENT then
-- Inventory Icon
if(file.Exists("materials/VGUI/kullweapon.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/kullweapon");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/staff_killicon.vmt","GAME")) then
	killicon.Add("weapon_staff","VGUI/weapons/staff_killicon",Color(255,255,255));
	killicon.Add("staff_pulse","VGUI/weapons/staff_killicon",Color(255,255,255));
end

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - a:Up() - 2*a:Forward() + a:Right();
	a:RotateAroundAxis(a:Right(),5);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

net.Receive("EAP.ChangeApparence",function(len)
	local ent = net.ReadEntity();
	if (not IsValid(ent)) then return end

	local type = net.ReadInt(8);

	/*if (type==1) then
		if (DermaPanel and DermaPanel:IsValid()) then
			local list = DermaPanel.targetList;
			local ents = net.ReadTable();
			list:Clear();
			for k,v in pairs(ents) do
				list:AddLine(v[2],v[1]);
			end
		end
	elseif (type==0) then*/

	if (DermaPanel and DermaPanel:IsValid()) then DermaPanel:Close() end

	local plys = net.ReadTable();

	DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetSize(300, 300)
	DermaPanel:Center()
	DermaPanel:SetTitle("")
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel.Paint = function(self,w,h)
		surface.SetDrawColor( 80, 80, 80, 185 )
		surface.DrawRect( 0, 0, w, h )
	end

  	local title = vgui.Create( "DLabel", DermaPanel );
 	title:SetText("Mimetisor Select Target");
  	title:SetPos( 25, 0 );
 	title:SetSize( 400, 25 );

 	local image = vgui.Create("DImage" , DermaPanel);
    image:SetSize(16, 16);
    image:SetPos(5, 5);
    image:SetImage("img/eap_logo");

	local targetList = vgui.Create( "DListView", DermaPanel )
	targetList:SetMultiSelect(false)
	targetList:SetPos(75, 55)
	targetList:SetSize(160, 200)
	targetList:AddColumn("Cible")
	targetList:SortByColumn(1, true)
	DermaPanel.targetList = targetList;

	local ents = plys;
	for k,v in pairs(ents) do
		targetList:AddLine(v[2],v[1])
	end

	local sendButton = vgui.Create("DButton" , DermaPanel )
	sendButton:SetParent( DermaPanel )
	sendButton:SetText("Changer d'apparence")
	sendButton:SetPos(75, 260)
	sendButton:SetSize(160, 25)
	sendButton.DoClick = function ( btn )
		if (not IsValid(ent)) then return end
		local target = targetList:GetSelectedLine();
		if (target) then
			local tent = targetList:GetLine(target):GetColumnText(2);
			net.Start("EAP.ChangeApparence");
			net.WriteEntity(ent);
			//net.WriteInt(0,4);
			net.WriteInt(tent,16);
			//net.WriteBit(ents);
			net.WriteBit(true);
			net.SendToServer();
			DermaPanel:Close()
		else
			GAMEMODE:AddNotify("Pas de cible valide", NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" );
		end
	end

	//end

end)

end
