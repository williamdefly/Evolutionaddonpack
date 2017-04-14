--[[
	Arthurs Mantle
	Copyright (C) 2010 Madman07
	Secret Code added by AlexALX
]]--

if (Lib!=nil and Lib.Wire!=nil) then Lib.Wiremod(ENT); end
if (Lib!=nil and Lib.RD!=nil) then Lib.LifeSupport(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Arthurs Mantle"
ENT.WireDebugName = "Arthurs Mantle"
ENT.Author = "Madman07, Rafael De Jongh"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"

list.Set("EAP", ENT.PrintName, ENT);

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

ENT.TFont = "Anquietas"
ENT.GFont = "Stargate Address Glyphs Concept"