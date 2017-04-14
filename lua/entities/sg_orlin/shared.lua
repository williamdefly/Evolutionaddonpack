ENT.Type = "anim"
ENT.Base = "sg_base"
ENT.PrintName = "Stargate (Orlin)"
ENT.Author = "aVoN, Madman07, Llapp, Rafael De Jongh, Assassin21, AlexALX"
ENT.Category = ""
ENT.Spawnable = true

list.Set("EAP", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Orlin"
ENT.IsStargateOrlin = true

ENT.EventHorizonData = {
	OpeningDelay = 0.8,
	OpenTime = 2.2,
	NNFix = 0,
	Model = "models/sgorlin/stargate_horizon_orlin.mdl",
	Kawoosh = "orlin",
}