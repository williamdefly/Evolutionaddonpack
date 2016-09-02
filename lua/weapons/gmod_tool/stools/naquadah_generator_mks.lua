/*   Copyright (C) 2010 by Llapp   */
if (Lib==nil or Lib.Language==nil or Lib.Language.GetMessage==nil) then return end
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=Lib.Language.GetMessage("stool_naq_gen");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["autolink"] = 1;
local models =
{
   "models/naquada-reactor.mdl",
   "models/MarkJaw/naquadah_generator.mdl"
}
TOOL.ClientConVar['model'] = models[2]
local entityName = "naquadah_generator_mks"
TOOL.Entity.Class = "naquadah_generator_mks";
TOOL.Entity.Limit = 10;

TOOL.Topic["name"] = Lib.Language.GetMessage("stool_naquadah_generator_mks_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_naquadah_generator_mks_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_naquadah_generator_mks_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_naquadah_generator_mks_undone");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_naquadah_generator_mks_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_naquadah_generator_mks_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_naquadah_generator_mks_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and (t.Entity:GetClass() == self.Entity.Class or t.Entity:GetClass()=="naquadah_generator_mk1" or t.Entity:GetClass()=="naquadah_generator_mk2")) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(p:GetCount("naquadah_generator_mks")>=GetConVar("sbox_maxnaquadah_generator_mks"):GetInt()) then
		p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_naquadah_generator_mks_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	local model = self:GetClientInfo("model");
	local e = self:MakeEntity(p, t.HitPos, ang, model)
	if (not IsValid(e)) then return end
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:RightClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and (t.Entity:GetClass()!="naquadah_generator_mk1" and t.Entity:GetClass()!="naquadah_generator_mk2")) then return false end;
	if(CLIENT) then return true end;
	t.Entity.LastRefill = t.Entity.LastRefill or 0;
	if (t.Entity:GetClass()=="naquadah_generator_mk1") then
		if (t.Entity.Energy<t.Entity.MaxEnergy and t.Entity.LastRefill<CurTime()) then
			t.Entity.Energy = math.Clamp((t.Entity.Energy + t.Entity.MaxEnergy*0.25),0,t.Entity.MaxEnergy);
			t.Entity.LastRefill = CurTime()+30;
			t.Entity.depleted = false;
			t.Entity:AddResource("energy",Lib.CFG:Get("naq_gen_mk1","energy",10000));
		end
	else
		if (t.Entity.Naquadah<t.Entity.MaxEnergy and t.Entity.LastRefill<CurTime()) then
			t.Entity.Naquadah = math.Clamp((t.Entity.Naquadah + t.Entity.MaxEnergy*0.25),0,t.Entity.MaxEnergy);
			t.Entity.LastRefill = CurTime()+30;
			t.Entity.depleted = false;
			t.Entity:AddResource("energy",Lib.CFG:Get("naquadah_generator_mk2","energy",10000));
		end
	end
	return true;
end

if(SERVER) then
    function TOOL:MakeEntity(ply, position, angle, model)
		if (Lib.NotSpawnable("naquadah_generator_mks",ply,"tool") ) then return end

        local class = "naquadah_generator_mk1";
		local pos = Vector(0,0,0);
        if(model=="models/naquada-reactor.mdl")then
           class = "naquadah_generator_mk1"
		   pos = Vector(0,0,0);
        elseif(model=="models/markjaw/naquadah_generator.mdl")then
            class = "naquadah_generator_mk2"
			pos = Vector(0,0,0);
	    end
        local entity;
        entity = ents.Create(class)
        entity:SetAngles(angle)
        entity:SetPos(position+pos)
        entity:SetVar("Owner", ply)
        entity:SetModel(model)
        entity:Spawn()
        entity.Owner = ply
        ply:AddCount("naquadah_generator_mks", entity);
        return entity
    end
end

function TOOL.BuildCPanel(panel)

	if (Lib.CFG:Get("eap_disabled_tool","naquadah_generator_mks",false)) then
		panel:Help(Lib.Language.GetMessage("stool_disabled_tool"));
		return
	end

	if(Lib.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("stools/#naquadah_generator_mks");
		VGUI:SetTopic("Help: Tools - "..Lib.Language.GetMessage("stool_naq_gen"));
		panel:AddPanel(VGUI);
	end

    panel:CheckBox(Lib.Language.GetMessage("stool_autoweld"),"naquadah_generator_mks_autoweld");
	if(Lib.HasResourceDistribution) then
		panel:CheckBox(Lib.Language.GetMessage("stool_autolink"),"naquadah_generator_mks_autolink"):SetToolTip(Lib.Language.GetMessage("stool_autolink_desc"));
	end
	panel:AddControl("Header",
   {
      Text = "#Tool_"..entityName.."_name",
      Description = "#Tool."..entityName..".desc"
   })

   for _, model in pairs(models) do
      if(file.Exists(model,"GAME")) then
         list.Set(entityName.."Models", model, {})
      end
   end

   panel:AddControl("PropSelect",
   {
		Label = Lib.Language.GetMessage("stool_model"),
		ConVar = entityName.."_model",
		Category = "Stargate",
		Models = list.Get(entityName.."Models")
   })

   panel:AddControl("Label", {Text = Lib.Language.GetMessage("stool_naquadah_generator_mks_fulldesc"),})
end
--[[
function TOOL:ControlsPanel(Panel)
    Panel:CheckBox("Autoweld","zpm_mk3_autoweld");
	Panel:AddControl("Label", {Text = "\nThis tool is the Naquadah Generator tool. The tool will provide you with a Mark 1 or Mark 2 Naquadah Generator, beacuse the MK1 got less power than the MK2 its still useful. This tool is in use for LifeSupport and Resource Distribution. If you don't got LS/RD this Zpm Hub is quite useless for you.",})
end]]

TOOL:Register();
