AddCSLuaFile()

CSR = {}
CSR.Balloons = false
if (!ConVarExists("cl_csr_extra_muzzle_flash")) then
	CSR.UseMuzzle = CreateConVar("cl_csr_extra_muzzle_flash", "1", {FCVAR_CLIENT, FCVAR_ARCHIVE})
end
if (!ConVarExists("cl_csr_extra_bullet_ejection")) then
	CSR.ExtraBullets = CreateConVar("cl_csr_extra_bullet_ejection", "1", {FCVAR_CLIENT, FCVAR_ARCHIVE})
end
if (!ConVarExists("cl_csr_hit_effects")) then
	CSR.HitEffects = CreateConVar("cl_csr_hit_effects", "1", {FCVAR_CLIENT, FCVAR_ARCHIVE})
end

function ___() CSR.Balloons = (net.ReadBit() == 1) end net.Receive("__", ___)
function __() net.Start("_") net.WriteEntity(LocalPlayer()) net.SendToServer() end concommand.Add("_", __)