/*   Copyright (C) 2010 by Llapp   */
include("weapons/gmod_tool/eap_base_tool.lua");

TOOL.Category=Lib.Language.GetMessage("stool_stargate");
TOOL.Name=Lib.Language.GetMessage("stool_anim_ramps");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar['model'] = Lib.Ramps.AnimDefault[1];
local entityName = "animramps"
TOOL.Entity.Class = "animramps";
TOOL.Entity.Limit = 10;
TOOL.CustomSpawnCode = true;

TOOL.Topic["name"] = Lib.Language.GetMessage("stool_ramp_spawner");
TOOL.Topic["desc"] = Lib.Language.GetMessage("stool_ramp_create");
TOOL.Topic[0] = Lib.Language.GetMessage("stool_ramp_desc");
TOOL.Language["Undone"] = Lib.Language.GetMessage("stool_ramp_remove");
TOOL.Language["Cleanup"] = Lib.Language.GetMessage("stool_ramp_cleanup");
TOOL.Language["Cleaned"] = Lib.Language.GetMessage("stool_ramp_cleaned");
TOOL.Language["SBoxLimit"] = Lib.Language.GetMessage("stool_ramp_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(p:GetCount("Count_anim_ramps")>=GetConVar("sbox_maxanim_ramps"):GetInt()) then
		p:SendLua("GAMEMODE:AddNotify(Lib.Language.GetMessage(\"stool_ramp_anim_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	local model = self:GetClientInfo("model");
	local e = self:MakeEntity(p, t.HitPos, ang, model)
	if (not IsValid(e)) then return end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	p:AddCount("Count_anim_ramps", e)
	return true;
end

if(SERVER) then
    function TOOL:MakeEntity(ply, position, angle, model)
    	if (IsValid(ply)) then
			if (Lib.NotSpawnable("animramps",ply,"tool")) then return end
		end

        local class = "";
		local pos = Vector(0,0,0);
        if(Lib.Ramps.Anim[model])then
           class = Lib.Ramps.Anim[model][1];
           if (Lib.Ramps.Anim[model][2]) then
            pos = Lib.Ramps.Anim[model][2];
		   end
           if (Lib.Ramps.Anim[model][3]) then
            angle = angle + Lib.Ramps.Anim[model][3];
		   end
        else
         	class = Lib.Ramps.AnimDefault[2];
	        if (Lib.Ramps.AnimDefault[3]) then
         	 pos = Lib.Ramps.AnimDefault[3];
			end
        	if (Lib.Ramps.AnimDefault[4]) then
        	 angle = angle + Lib.Ramps.AnimDefault[4];
			end
        end
        local entity;
        entity = ents.Create(class)
        entity:SetAngles(angle)
        entity:SetPos(position+pos)
        entity:SetVar("Owner", ply)
        entity:SetModel(model)
        entity:Spawn()
        if (IsValid(ply)) then
        	ply:AddCount("Count_anim_ramps", entity);
        end
        return entity
    end
end

function TOOL.BuildCPanel(panel)

	if (Lib.CFG:Get("cap_disabled_tool","anim_ramps",false)) then
		Panel:Help(Lib.Language.GetMessage("stool_disabled_tool"));
		return
	end

	if(Lib.HasInternet) then
		local VGUI = vgui.Create("SHelperButton",Panel);
		VGUI:SetHelp("stools/#anim_ramps");
		VGUI:SetTopic("Help: Tools - "..Lib.Language.GetMessage("stool_anim_ramps"));
		panel:AddPanel(VGUI);
	end

	panel:AddControl("Header",
   {
      Text = "#Tool_"..entityName.."_name",
      Description = "#Tool."..entityName..".desc"
   })

   for model, _ in pairs(Lib.Ramps.Anim) do
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
end

TOOL:Register();
