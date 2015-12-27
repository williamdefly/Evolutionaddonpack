CSR = {}
if (!ConVarExists("sv_csr_breakdoors")) then
	CSR.BreakDoors = CreateConVar("sv_csr_breakdoors", "1", {FCVAR_ARCHIVE})
end