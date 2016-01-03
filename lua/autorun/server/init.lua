/* Add Server Lib */
include('autorun/shared/keyboard.lua');
include('autorun/shared/tracelines.lua');

/* Function */
function StarGate.EmitHeat(pos, damage, radius, inflictor)
   if(CombatDamageSystem) then
      cds_heatpos(pos, damage, radius)
      return true
   elseif(gcombat) then
      gcombat.emitheat(pos, radius, damage, inflictor)
      return true
   else
      return false
   end
end