/*
	Stargate Wire Lib for GarrysMod10
	Copyright (C) 2007-2009  aVoN

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

--################# Adds WireSupport to an entity when getting called - HAS TO BE CALLED BEFORE ANY OTHERTHING IS DONE IN A SENT (like includes) @aVoN
-- My suggestion is to put this on the really top of the shared.lua
Lib.Wire = {};
function Lib.Wiremod(ENT)
	ENT.WireDebugName = ENT.WireDebugName or "No Name";
	ENT.HasWire = Lib.HasWire;

	-- General handlers
	ENT.OnRemove = Lib.Wire.OnRemove;
	ENT.OnRestore = Lib.Wire.OnRestore;

	-- Wire Handlers
	ENT.CreateWireOutputs = Lib.Wire.CreateWireOutputs;
	ENT.CreateWireInputs = Lib.Wire.CreateWireInputs;
	ENT.SetWire = Lib.Wire.SetWire;
	ENT.GetWire = Lib.Wire.GetWire;

	-- For LifeSupport and Resource Distribution and Wire - Makes all connections savable with Duplicator
	ENT.PreEntityCopy = Lib.Wire.PreEntityCopy;
	ENT.PostEntityPaste = Lib.Wire.PostEntityPaste;
end

--################# OnRemove @aVoN
--added compatiblity with RD3 @JDM12989
function Lib.Wire.OnRemove(self,only_rd,only_wire)
	if(not only_rd and WireAddon and (self.Outputs or self.Inputs)) then
		Wire_Remove(self.Entity);
	end
end

--################# OnRestore @aVoN
function Lib.Wire.OnRestore(self)
	if(WireAddon) then
		Wire_Restored(self.Entity);
	end
end

--##############################
-- Wire handling
--##############################

--################# Creates Wire Outputs @aVoN
-- Allows special datatypes now. Valid are NORMAL,VECTOR,ANGLE,COLOR,ENTITY,STRING,TABLE,ANY,BIDIRTABLE,HOVERDATAPORT
function Lib.Wire.CreateWireOutputs(self,...)
	if(WireAddon) then
		local data = {};
		local types = {};
		for k,v in pairs({...}) do
			if(type(v) == "table") then
				types[k] = v.Type;
				data[k] = v.Name;
			else
				data[k] = v;
			end
		end
		--self.Outputs = Wire_CreateOutputs(self.Entity,{...}); -- Old way, kept if I need to revert
		self.Outputs = WireLib.CreateSpecialOutputs(self.Entity,data,types);
	end
end

--################# Creates Wire Inputs @aVoN
-- Allows special datatypes now. Valid are NORMAL,VECTOR,ANGLE,COLOR,ENTITY,STRING,TABLE,ANY,BIDIRTABLE,HOVERDATAPORT
function Lib.Wire.CreateWireInputs(self,...)
	if(WireAddon) then
		local data = {};
		local types = {};
		for k,v in pairs({...}) do
			if(type(v) == "table") then
				types[k] = v.Type;
				data[k] = v.Name;
			else
				data[k] = v;
			end
		end
		--self.Inputs = Wire_CreateInputs(self.Entity,{...}); -- Old way, kept if I need to revert
		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,data,types);
	end
end

--################# Sets a Wire value @aVoN
function Lib.Wire.SetWire(self,key,value,inp)
	if(WireAddon) then
		if (inp) then
			-- Special interaction to modify datatypes
			if(self.Inputs and self.Inputs[key]) then
				local datatype = self.Inputs[key].Type;
				if(datatype == "NORMAL") then
					-- Supports bools and converts them to numbers
					if(value == true) then
						value = 1;
					elseif(value == false) then
						value = 0;
					end
					-- If still not a number, make it a num now!
					value = tonumber(value);
				elseif(datatype == "STRING") then
					value = tostring(value);
				end
			end
			if(value ~= nil) then
				WireLib.TriggerInput(self.Entity,key,value);
			end
		else
			-- Special interaction to modify datatypes
			if(self.Outputs and self.Outputs[key]) then
				local datatype = self.Outputs[key].Type;
				if(datatype == "NORMAL") then
					-- Supports bools and converts them to numbers
					if(value == true) then
						value = 1;
					elseif(value == false) then
						value = 0;
					end
					-- If still not a number, make it a num now!
					value = tonumber(value);
				elseif(datatype == "STRING") then
					value = tostring(value);
				end
			end
			if(value ~= nil) then
				WireLib.TriggerOutput(self.Entity,key,value);
				if(self.WireOutput) then
					self:WireOutput(key,value);
				end
			end
		end
	end
end

--################# Gets a Wire value @aVoN
function Lib.Wire.GetWire(self,key,default,out)
	if(WireAddon) then
		if (out) then
			if(self.Outputs and self.Outputs[key] and self.Outputs[key].Value) then
				return self.Outputs[key].Value or default or WireLib.DT[self.Outputs[key].Type].Zero;
			end
		else
			if(self.Inputs and self.Inputs[key] and self.Inputs[key].Value) then
				return self.Inputs[key].Value or default or WireLib.DT[self.Inputs[key].Type].Zero;
			end
		end
	end
	return default or 0; -- Error. Either wire is not installed or the input is not SET. Return the default value instead
end

--################# Store Entity modifiers @aVoN
function Lib.Wire.PreEntityCopy(self)
	if(WireAddon) then
		local data = WireLib.BuildDupeInfo(self.Entity);
		if(data) then
			duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",data);
		end
	end
end

--################# Restore entity modifiers @aVoN
function Lib.Wire.PostEntityPaste(self,Player,Ent,CreatedEntities)
	if(WireAddon) then
		if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
			WireLib.ApplyDupeInfo(Player,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end);
		end
	end
end
