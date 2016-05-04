if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Name=Lib.Language.GetMessage("stool_gravc");
TOOL.Category=Lib.Language.GetMessage("stool_stargate");
TOOL.Tab="EAP";
TOOL.Entity.Class = "gravity_controller";
TOOL.Entity.Limit = 15;
TOOL.CustomSpawnCode = true;

TOOL.Command=nil;
TOOL.ConfigName="";
/*
models = {
	{ 'Teapot', 'models/props_interiors/pot01a.mdl' },
	{ 'Pot', 'models/props_interiors/pot02a.mdl' },
	{ 'Skull', 'models/Gibs/HGIBS.mdl' },
	{ 'Clock', 'models/props_c17/clock01.mdl' },
	{ 'Hula Doll', 'models/props_lab/huladoll.mdl' },
	{ 'Hover Drive', 'models//props_c17/utilityconducter001.mdl' },
	{ 'Big Hover Drive', 'models/props_wasteland/laundry_washer003.mdl' },
	{ 'SpacegatePowernode', 'models/Cebt/sga_pwnode.mdl' },
} */

TOOL.List = "GravControllerModels"
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{})
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{})
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{})
list.Set(TOOL.List,"models/props_wasteland/laundry_washer003.mdl",{})
list.Set(TOOL.List,"models/props_wasteland/laundry_washer001a.mdl",{})
list.Set(TOOL.List,"models/props_lab/huladoll.mdl",{})
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{})
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{})
list.Set(TOOL.List,"models/props_phx/construct/metal_plate1.mdl",{})
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{})
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{})
list.Set(TOOL.List,"models/props_interiors/pot01a.mdl",{})
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{})
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{})
list.Set(TOOL.List,"models/Cebt/sga_pwnode.mdl",{})

local loopsounds = {
	{'no sound', ''},
	{'scanner', 'npc/scanner/combat_scan_loop2.wav'},
	{'heli rotor', 'NPC_CombineGunship.RotorSound'},
	{'energy shield', 'ambient/machines/combine_shield_loop3.wav'},
	{'dog idlemode', 'npc/dog/dog_idlemode_loop1.wav'},
	{'dropship', 'npc/combine_gunship/dropship_engine_distant_loop1.wav'},
	{'subway hall 1', 'ambient/atmosphere/undercity_loop1.wav'},
	{'subway hall 2', 'ambient/atmosphere/underground_hall_loop1.wav'},
	{'forcefield', 'ambient/energy/force_field_loop1.wav'},
	{'engine rotor', 'npc/combine_gunship/engine_rotor_loop1.wav'}
}

local convtable={
	["iActivateKey"]		= {0, 0},
	["fAirbrakeX"]		= {0, 15},
	["fAirbrakeY"]		= {0, 15},
	["fAirbrakeZ"]		= {0, 15},
	["fBrakePercent"]		= {0, 10},
	["sModel"]			= {1, "models/props_c17/utilityconducter001.mdl"},
	["sSound"]			= {1, "ambient/atmosphere/underground_hall_loop1.wav"},
	["bAngularBrake"]		= {2, 0},
	["bGlobalBrake"]		= {2, 1},
	["bDrawSprite"]		= {0, 1},
	["bAlwaysBrake"]		= {0, 0},
	["bBrakeOnly"]		= {0, 0},
	["iKeyUp"]			= {0, 7},
	["iKeyDown"]			= {0, 4},
	["iKeyHover"]		= {0, 1},
	["fHoverSpeed"]		= {0, 1},
	["bSHHoverDesc"]	= {2, 1},
	["bSHLocalDesc"]		= {2, 1},
	["fAngBrakePerc"]		= {0, 20},
	["fWeight"]			= {0, 0},
	["bRelativeToGrnd"]	= {2, 0},
	["fHeightAboveGrnd"]	= {0, 30},
	["bSGAPowerNode"]	= {2, 0},
	["bLiveGravity"]		={0,0},
}

for s, v in pairs(convtable) do
	TOOL.ClientConVar[s]=v[2]
end

if (CLIENT) then
	language.Add('gravity_controller', Lib.Language.GetMessage("stool_gravc"))
	TOOL.Topic["name"] = Lib.Language.GetMessage("stool_gravitycontroller_spawner");
	TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_gravitycontroller_create");
	TOOL.Topic[0] = Lib.Language.GetMessage("stool_gravitycontroller_desc");
	TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_gravitycontroller_undone");
	TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_gravitycontroller_cleanup");
	TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_gravitycontroller_cleaned");
	TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_gravitycontroller_limit");
end

local sgapowernd={
	[1]={-135, 0, 180},
	[2]={68, 118, -60},
	[3]={68, -118, 60}
}

function TOOL:LeftClick(trace)
	if trace.Entity && (trace.Entity:IsPlayer()) then return false end
	if(CLIENT) then
		return true
	end
	if(!SERVER) then return false end
	if(not self:CheckLimit()) then return false end;
	local ply = self:GetOwner()
	local Pos = trace.HitPos
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch+90
	undo.Create('gravity_controller')
	if trace.Entity and trace.Entity:IsValid() and convtable["bSGAPowerNode"][2]==1 and trace.Entity.IsStargate and not trace.Entity.IsSupergate then
		trace.Entity.GCTable=trace.Entity.GCTable or {}
		for i=1,3 do
			if !trace.Entity.GCTable[i] or !trace.Entity.GCTable[i]:IsValid() then
				local ent=MakeGravitycontroller(ply, Ang, Pos, convtable)
				if (not IsValid(ent)) then return end
				ent:SetPos(trace.Entity:GetPos()+trace.Entity:GetUp()*(sgapowernd[i][1]) - trace.Entity:GetRight()*(sgapowernd[i][2]))
				local ang=trace.Entity:GetAngles()
				ang:RotateAroundAxis(trace.Entity:GetUp(), 90)
				ang:RotateAroundAxis(trace.Entity:GetForward(), sgapowernd[i][3])
				ent:SetAngles(ang)
				trace.Entity.GCTable[i]=ent
				undo.AddEntity(ent)
				local const=constraint.Weld(ent, trace.Entity,0, trace.PhysicsBone, 0, systemmanager)
				local nocollide=constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone)
				undo.AddEntity(const)
				undo.AddEntity(nocollide)
			end
		end
	else
		if (trace.Entity:IsValid() && trace.Entity:GetClass()=="gravity_controller") then
			trace.Entity.ConTable=table.Copy(convtable)
			if !trace.Entity.phys then
				trace.Entity.phys = trace.Entity:GetPhysicsObject()
			end
			if trace.Entity.phys:IsValid() and convtable["fWeight"][2] != 0 then
				trace.Entity.phys:SetMass(math.Clamp(convtable["fWeight"][2], 1, 500))
			end
			if trace.Entity.Sound then
				trace.Entity.Sound:Stop()
				trace.Entity.Sound=CreateSound(trace.Entity, convtable["sSound"][2])
				if trace.Entity.Active then
					trace.Entity.Sound:Play()
				end
			end
			return true
		end
		local ent=MakeGravitycontroller(ply, Ang, Pos, convtable)
		if (not IsValid(ent)) then return end
		ent:SetPos(trace.HitPos - trace.HitNormal * ent:OBBMins().z)
		if (trace.Entity:IsValid()) then
			local const=constraint.Weld(ent, trace.Entity,0, trace.PhysicsBone, 0, systemmanager)
			local nocollide=constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone)
			undo.AddEntity(const)
			undo.AddEntity(nocollide)
		end
		undo.AddEntity(ent)
	end
	undo.SetPlayer(ply)
	undo.Finish()
	return true
end

if SERVER then
    --CreateConVar('sbox_maxgravitycontroller', 15)
	function MakeGravitycontroller(ply, Ang, Pos, tbl, Data)
		if (game.SinglePlayer()) then
			ply = player.GetByID(1);
		end
		if (IsValid(ply)) then
			if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(ply); return
			elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
				Msg("Carter Addon Pack - Unknown Error\n");
				ply:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
				ply:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
				return;
			end
			if (Lib.NotSpawnable("gravity_controller",ply,"tool")) then return end

			local PropLimit = GetConVar("sbox_maxgravity_controller"):GetInt()
			if(IsValid(ply)) then
				if ply:GetCount("gravity_controller")+1 > PropLimit then
					ply:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_gravitycontroller_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
					return;
				end
			end
			
		end

		local ent=ents.Create('gravity_controller')
		if !ent:IsValid() then return false end
		ent:SetAngles(Ang)
		ent:SetPos(Pos)
		if (tbl and table.Count(tbl)>0) then
			ent.ConTable=table.Copy(tbl)
		elseif (Data and Data.ConTable) then
			ent.ConTable = Data.ConTable
			tbl = Data.ConTable;
		end

		if (Data and Data.GateSpawnerSpawned and Data.GateSpawnerID) then
			ent.GateSpawnerSpawned = true;
			ent:SetNetworkedBool("GateSpawnerSpawned",true);
			ent.GateSpawnerID = Data.GateSpawnerID;
		end

		ent:Spawn()
		if (IsValid(ply)) then
			ent:SetVar('Owner',ply)
			ply:AddCount('gravity_controller', ent)
		end

		numpad.OnDown(ply, tbl["iActivateKey"][2], 'FireGravitycontroller', ent)
		if tbl["bSGAPowerNode"][2]!=1 then
			if tbl["fWeight"][2] > 1 then
				ent:GetPhysicsObject():SetMass(tbl["fWeight"][2])
			end
			numpad.OnDown(ply, tbl["iKeyHover"][2], 'ToggleHoverMode', ent)
			numpad.OnDown(ply, tbl["iKeyUp"][2], 'GoUp', ent)
			numpad.OnDown(ply, tbl["iKeyDown"][2], 'GoDown', ent)
			numpad.OnUp(ply, tbl["iKeyUp"][2], 'GoStop', ent)
			numpad.OnUp(ply, tbl["iKeyDown"][2], 'GoStop', ent)
			ent.StartVector=ent:WorldToLocal(Pos-Vector(0,0,1))
			ent:SetNetworkedVector("startvector", ent.StartVector)
		elseif (IsValid(ent:GetPhysicsObject())) then
			ent:GetPhysicsObject():SetMass(200)
		end
		local ttable={
			Ang=Ang,
			Pos=Pos,
			ply=ply,
			tbl=tbl,
		}
		table.Merge(ent:GetTable(), ttable)
		return ent
	end
	duplicator.RegisterEntityClass("gravity_controller", MakeGravitycontroller, "Ang", "Pos", "tbl", "Data")
end

if CLIENT then
	function TOOL.BuildCPanel(CPanel)
		if (Lib.CFG:Get("eap_disabled_tool","gravity_controller",false)) then
			CPanel:Help(Lib.Language.GetMessage("stool_disabled_tool"));
			return
		end
		CPanel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_gravity_controller_wait")})
	end
	local updatetime = 0
	local function UpdatePanel()
		local CPanel = controlpanel.Get("gravity_controller")
		CPanel:Clear()

		if (Lib.CFG:Get("eap_disabled_tool","gravity_controller",false)) then
			CPanel:Help(Lib.Language.GetMessage("stool_disabled_tool"));
			return
		end

		if(Lib.HasInternet) then
			local VGUI = vgui.Create("SHelperButton",Panel);
			VGUI:SetHelp("stools/#gravity_controller");
			VGUI:SetTopic("Help: Tools - "..Lib.Language.GetMessage("stool_gravc"));
			CPanel:AddPanel(VGUI);
		end

		--CPanel:AddHeader()
		--CPanel:AddDefaultControls()
		CPanel:AddControl( "PropSelect", {
			Label = Lib.Language.GetMessage("stool_model"),
			ConVar = "gravity_controller_sModel",
			Category = "",
			Models = list.Get("GravControllerModels")
		})
		CPanel:AddControl("TextBox", {
			Label = Lib.Language.GetMessage("stool_gravitycontroller_mp"),
			MaxLength = 300,
			Text = "path_of_model.mdl",
			Command = "gravity_controller_sModel",
		})
		local combo = {}
		combo.Label = Lib.Language.GetMessage("stool_gravitycontroller_so")
		combo.MenuButton = 0
		combo.Folder = "settings/gravity_controller/"
		combo.Options = {}
		for k, v in pairs(loopsounds) do
			combo.Options[v[1]] = {gravitycontroller_sSound = v[2]}
		end
		CPanel:AddControl("Label", {Text = ""})
		CPanel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_gravitycontroller_so")})
		CPanel:AddControl('ComboBox', combo)
		CPanel:AddControl("TextBox", {
			Label = Lib.Language.GetMessage("stool_gravitycontroller_sp"),
			MaxLength = 300,
			Text = "path_of_sound",
			Command = "gravity_controller_sSound",
		})
		CPanel:AddControl("Label", {Text = ""})
		CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_ds"),"gravity_controller_bDrawSprite")
		if convtable["bSGAPowerNode"][2] != 1 then
			CPanel:AddControl('Slider', {
				Label = Lib.Language.GetMessage("stool_gravitycontroller_we"),
				Type = "Float",
				Min = 0,
				Max = 500,
				Command = 'gravity_controller_fWeight'
			}):SetToolTip(Lib.Language.GetMessage("stool_gravitycontroller_we_desc"));
			CPanel:AddControl("Label", {Text = ""})
			CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_bo"),"gravity_controller_bBrakeOnly")
			CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_ab"),"gravity_controller_bAlwaysBrake")
			CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_ga"),"gravity_controller_bGlobalBrake")
			if convtable["bGlobalBrake"][2] == 0 then
				CPanel:AddControl('Slider', {
					Label = Lib.Language.GetMessage("stool_gravitycontroller_bx"),
					Type = "Float",
					Min = 0,
					Max = 100,
					Command = 'gravity_controller_fAirbrakeX'
				})
				CPanel:AddControl('Slider', {
					Label = Lib.Language.GetMessage("stool_gravitycontroller_by"),
					Type = "Float",
					Min = 0,
					Max = 100,
					Command = 'gravity_controller_fAirbrakeY'
				})
				CPanel:AddControl('Slider', {
					Label = Lib.Language.GetMessage("stool_gravitycontroller_bz"),
					Type = "Float",
					Min = 0,
					Max = 100,
					Command = 'gravity_controller_fAirbrakeZ'
				})
			else
				CPanel:AddControl('Slider', {
					Label = Lib.Language.GetMessage("stool_gravitycontroller_gb"),
					Type = "Float",
					Min = 0,
					Max = 100,
					Command = "gravity_controller_fBrakePercent"
				})
			end
			CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_ant"),"gravity_controller_bAngularBrake")
			if convtable["bAngularBrake"][2] == 1 then
				CPanel:AddControl('Slider', {
					Label = Lib.Language.GetMessage("stool_gravitycontroller_an"),
					Type = "Float",
					Min = 0,
					Max = 100,
					Command = "gravity_controller_fAngBrakePerc"
				})
			end
			CPanel:AddControl("Label", {Text = ""})
			CPanel:AddControl("Numpad", {
				ButtonSize = "22",
				Label = Lib.Language.GetMessage("stool_activate"),
				Command = "gravity_controller_iActivateKey",
				Label2 = Lib.Language.GetMessage("stool_gravitycontroller_ho"),
				Command2 = "gravity_controller_iKeyHover",
			})
			if convtable["bRelativeToGrnd"][2]==0 then
				CPanel:AddControl('Numpad', {
					ButtonSize = '22',
					Label = Lib.Language.GetMessage("stool_gravitycontroller_hu"),
					Command = "gravity_controller_iKeyUp",
					Label2 = Lib.Language.GetMessage("stool_gravitycontroller_hd"),
					Command2 = "gravity_controller_iKeyDown",
				})
			end
			CPanel:AddControl("Slider", {
				Label = Lib.Language.GetMessage("stool_gravitycontroller_hs"),
				Type = "Float",
				Min = 0.01,
				Max = 10,
				Command = "gravity_controller_fHoverSpeed"
			})
			CPanel:CheckBox("Hover relative to ground","gravity_controller_bRelativeToGrnd")
			if convtable["bRelativeToGrnd"][2] == 1 then
				CPanel:AddControl("Slider", {
					Label = Lib.Language.GetMessage("stool_gravity_controller_ha"),
					Type = "Float",
					Min = 1,
					Max = 100,
					Command = "gravity_controller_fHeightAboveGrnd"
				}):SetToolTip(Lib.Language.GetMessage("stool_gravitycontroller_ha"));
			end
			CPanel:AddControl("Label", {Text = ""})
			CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_hmd"),"gravity_controller_bSHHoverDesc")
			if convtable["bSHHoverDesc"][2] == 1 then
				CPanel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_gravity_controller_hmd_desc")})
			end
			CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_lbd"),"gravity_controller_bSHLocalDesc")
			if convtable["bSHLocalDesc"][2] == 1 then
				CPanel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_gravity_controller_lbd_desc")})
			end
		else
			CPanel:AddControl("Label", {Text = ""})
			CPanel:AddControl("Numpad", {
				ButtonSize = "22",
				Label = Lib.Language.GetMessage("stool_activate"),
				Command = "gravity_controller_iActivateKey",
			})
		end
		CPanel:CheckBox(Lib.Language.GetMessage("stool_gravitycontroller_sga"),"gravity_controller_bSGAPowerNode")
	end
	--usermessage.Hook("UpdateGravControllerPanel", updatepanel)
	local lastupdate=0
	local firstupdate=true
	local oldvtable=table.Copy(convtable)
	function TOOL:Think()
		local crt=CurTime()
		if lastupdate<crt+0.3 then
			lastupdate=crt
			for k, v in pairs(convtable) do
				if v[1]==1 then
					v[2]=self:GetClientInfo(k)
				else
					v[2]=self:GetClientNumber(k)
				end
			end
		end
		if firstupdate then
			UpdatePanel()
			firstupdate=false
		end
		for k, v in pairs(oldvtable) do
			if v[1]==2 and v[2] != convtable[k][2] then
				UpdatePanel()
				oldvtable=table.Copy(convtable)
				break
			end
		end
		if (!self:GetClientInfo("sModel")) then return end
		local model = self:GetClientInfo("sModel")
		if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != model) then
			self:MakeGhostEntity(model, Vector(0,0,0), Angle(0,0,0))
		end
		self:UpdateSpawnGhost(self.GhostEntity, self:GetOwner())
	end
end

function TOOL:UpdateSpawnGhost(ent, player)
	if (!ent) then return end
	if (!ent:IsValid()) then return end
	local tr = util.GetPlayerTrace(player, player:GetAimVector())
	local trace = util.TraceLine(tr)
	if (!trace.Hit) then return end
	if (trace.Entity && trace.Entity:GetClass() == "gravity_controller" || trace.Entity:IsPlayer()) then
		ent:SetNoDraw(true)
		return
	end
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	ent:SetAngles( Ang )
	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos-trace.HitNormal*min.z)
	ent:SetNoDraw(false)
end

local lastupdate=0
if SERVER then
	function TOOL:Think()
		local crt=CurTime()
		if lastupdate<crt+0.3 then
			lastupdate=crt
			for k, v in pairs(convtable) do
				if v[1]==1 then
					v[2]=self:GetClientInfo(k)
				else
					v[2]=self:GetClientNumber(k)
				end
			end
		end
		if (!self:GetClientInfo("sModel")) then return end
		local model = self:GetClientInfo("sModel")
		if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != model) then
			self:MakeGhostEntity(model, Vector(0,0,0), Angle(0,0,0))
		end
		self:UpdateSpawnGhost(self.GhostEntity, self:GetOwner())
	end
end

TOOL:Register();