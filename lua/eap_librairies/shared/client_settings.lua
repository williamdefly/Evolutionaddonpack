Lib.Settings = Lib.Settings or { };

MsgN("eap_librairies/shared/client_settings.lua")

function Lib.Settings.Client()
	if(SERVER)then return end

	local sizew,sizeh = 600,460;

	ClientPanel = vgui.Create( "EditablePanel" );
	ClientPanel:SetPaintBackgroundEnabled( false );
	ClientPanel:SetPaintBorderEnabled( false );
	ClientPanel:SetSize(sizew+10,sizeh+10);
	ClientPanel:Center();
	ClientPanel:MakePopup();

	local ClientSheet = vgui.Create( "DPropertySheet", ClientPanel )
	ClientSheet:SetPos( 5, 5 )
	ClientSheet:SetSize( sizew, sizeh )
	ClientSheet.tabScroller:DockMargin( 0, 0, 20, 0 )

	ClientSheet.CrossFade = function(self, anim, delta, data )

		local old = data.OldTab:GetPanel()
		local new = data.NewTab:GetPanel()
		if ( anim.Finished ) then

			old:SetVisible( false )
			new:SetAlpha( 255 )

			old:SetZPos( 0 )
			new:SetZPos( 0 )
			return
		end

		if ( anim.Started ) then

			old:SetZPos( 0 )
			new:SetZPos( 1 )

			old:SetAlpha( 255 )
			new:SetAlpha( 0 )

		end

		old:SetVisible( true )
		new:SetVisible( true )

		old:SetAlpha( 255 * (1-delta) )
		new:SetAlpha( 255 * delta )

	end
	ClientSheet.animFade = Derma_Anim( "Fade", ClientSheet, ClientSheet.CrossFade )

	ClientSheet.CloseButton = vgui.Create( "DImageButton", ClientPanel)
	ClientSheet.CloseButton:SetImage( "icon16/cross.png" )
	ClientSheet.CloseButton:SetSize( 16, 16 )
	ClientSheet.CloseButton:SetPos(sizew-12,7);
	ClientSheet.CloseButton.DoClick = function() ClientPanel:Remove() end

	--Ships
	local ShipSettings = vgui.Create("DPanel", ClientSheet)
	ShipSettings:SetSize( sizew-10, sizeh-10 )
	ShipSettings:Center();
	ShipSettings:SetBackgroundColor(Color(150,150,150,150))
	ClientSheet:AddSheet( Lib.Language.GetMessage("client_settings_ships"), ShipSettings, "icon16/world.png" )

	local JumperTitle = vgui.Create("DLabel", ShipSettings)
	JumperTitle:SetPos(10,15)
	JumperTitle:SetText(Lib.Language.GetMessage("ent_ship_jumper"))
	JumperTitle:SizeToContents()

	local JumperDynLights = vgui.Create("DCheckBoxLabel",ShipSettings)
	JumperDynLights:SetPos(10,45)
	JumperDynLights:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	JumperDynLights:SetConVar("cl_jumper_dynlights")
	JumperDynLights:SetValue(GetConVar("cl_jumper_dynlights"):GetInt())

	local JumperSprites = vgui.Create("DCheckBoxLabel",ShipSettings)
	JumperSprites:SetPos(10,75)
	JumperSprites:SetText(Lib.Language.GetMessage("vis_sprites"))
	JumperSprites:SetConVar("cl_jumper_sprites")
	JumperSprites:SetValue(GetConVar("cl_jumper_sprites"):GetInt())

	local JumperHeatWave = vgui.Create("DCheckBoxLabel",ShipSettings)
	JumperHeatWave:SetPos(10,105)
	JumperHeatWave:SetText(Lib.Language.GetMessage("vis_heatwave"))
	JumperHeatWave:SetConVar("cl_jumper_heatwave")
	JumperHeatWave:SetValue(GetConVar("cl_jumper_heatwave"):GetInt())

	local F302Title = vgui.Create("DLabel", ShipSettings)
	F302Title:SetPos(10,135)
	F302Title:SetText(Lib.Language.GetMessage("ent_ship_f302"))
	F302Title:SizeToContents()

	local F302HeatWave = vgui.Create("DCheckBoxLabel",ShipSettings)
	F302HeatWave:SetPos(10,165)
	F302HeatWave:SetText(Lib.Language.GetMessage("vis_heatwave"))
	F302HeatWave:SetConVar("cl_F302_heatwave")
	F302HeatWave:SetValue(GetConVar("cl_F302_heatwave"):GetInt())

	local F302Sprites = vgui.Create("DCheckBoxLabel",ShipSettings)
	F302Sprites:SetPos(10,195)
	F302Sprites:SetText(Lib.Language.GetMessage("vis_sprites"))
	F302Sprites:SetConVar("cl_F302_sprites")
	F302Sprites:SetValue(GetConVar("cl_F302_sprites"):GetInt())

	local ShuttleTitle = vgui.Create("DLabel", ShipSettings)
	ShuttleTitle:SetPos(10,225)
	ShuttleTitle:SetText(Lib.Language.GetMessage("ent_ship_shuttle"))
	ShuttleTitle:SizeToContents()

	local ShuttleHeatWave = vgui.Create("DCheckBoxLabel",ShipSettings)
	ShuttleHeatWave:SetPos(10,255)
	ShuttleHeatWave:SetText(Lib.Language.GetMessage("vis_heatwave"))
	ShuttleHeatWave:SetConVar("cl_shuttle_heatwave")
	ShuttleHeatWave:SetValue(GetConVar("cl_shuttle_heatwave"):GetInt())

	local ShuttleSprites = vgui.Create("DCheckBoxLabel",ShipSettings)
	ShuttleSprites:SetPos(10,285)
	ShuttleSprites:SetText(Lib.Language.GetMessage("vis_sprites"))
	ShuttleSprites:SetConVar("cl_shuttle_sprites")
	ShuttleSprites:SetValue(GetConVar("cl_shuttle_sprites"):GetInt())

	local DartTitle = vgui.Create("DLabel", ShipSettings)
	DartTitle:SetPos(10,315)
	DartTitle:SetText(Lib.Language.GetMessage("ent_ship_dart"))
	DartTitle:SizeToContents()

	local DartHeatWave = vgui.Create("DCheckBoxLabel",ShipSettings)
	DartHeatWave:SetPos(10,345)
	DartHeatWave:SetText(Lib.Language.GetMessage("vis_heatwave"))
	DartHeatWave:SetConVar("cl_dart_heatwave")
	DartHeatWave:SetValue(GetConVar("cl_dart_heatwave"):GetInt())

	--Weapons
	local WeaponsSettings = vgui.Create("DPanel", ClientSheet)
	WeaponsSettings:SetSize( sizew-10, sizeh-10 )
	WeaponsSettings:Center();
	WeaponsSettings:SetBackgroundColor(Color(150,150,150,150))
	ClientSheet:AddSheet( Lib.Language.GetMessage("client_settings_weapons").." (1/3)", WeaponsSettings, "icon16/bomb.png" )

	local Drones = vgui.Create("DLabel", WeaponsSettings)
	Drones:SetPos(10,15)
	Drones:SetText(Lib.Language.GetMessage("stool_drones"))
	Drones:SizeToContents()

	local DronesGlow = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	DronesGlow:SetPos(10,45)
	DronesGlow:SetText(Lib.Language.GetMessage("vis_glow"))
	DronesGlow:SetConVar("cl_drone_glow")
	DronesGlow:SetValue(GetConVar("cl_drone_glow"):GetInt())

	local NaqBomb = vgui.Create("DLabel", WeaponsSettings)
	NaqBomb:SetPos(10,75)
	NaqBomb:SetText(Lib.Language.GetMessage("stool_naq_bomb"))
	NaqBomb:SizeToContents()

	local NaqBombSunBeams = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	NaqBombSunBeams:SetPos(10,105)
	NaqBombSunBeams:SetText(Lib.Language.GetMessage("vis_sunbeams"))
	NaqBombSunBeams:SetConVar("cl_gate_nuke_sunbeams")
	NaqBombSunBeams:SetValue(GetConVar("cl_gate_nuke_sunbeams"):GetInt())

	local NaqBombRings = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	NaqBombRings:SetPos(10,135)
	NaqBombRings:SetText(Lib.Language.GetMessage("vis_part_rings"))
	NaqBombRings:SetConVar("cl_gate_nuke_rings")
	NaqBombRings:SetValue(GetConVar("cl_gate_nuke_rings"):GetInt())

	local NaqBombShieldRings = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	NaqBombShieldRings:SetPos(10,165)
	NaqBombShieldRings:SetText(Lib.Language.GetMessage("vis_shield_part"))
	NaqBombShieldRings:SetConVar("cl_gate_nuke_shieldrings")
	NaqBombShieldRings:SetValue(GetConVar("cl_gate_nuke_shieldrings"):GetInt())

	local NaqBombPlasma = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	NaqBombPlasma:SetPos(10,195)
	NaqBombPlasma:SetText(Lib.Language.GetMessage("vis_plasma"))
	NaqBombPlasma:SetConVar("cl_gate_nuke_plasma")
	NaqBombPlasma:SetValue(GetConVar("cl_gate_nuke_plasma"):GetInt())

	local NaqBombPlasmaLight = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	NaqBombPlasmaLight:SetPos(10,225)
	NaqBombPlasmaLight:SetText(Lib.Language.GetMessage("vis_plasma_light"))
	NaqBombPlasmaLight:SetConVar("cl_gate_nuke_dynlights")
	NaqBombPlasmaLight:SetValue(GetConVar("cl_gate_nuke_dynlights"):GetInt())

	local Overloader = vgui.Create("DLabel", WeaponsSettings)
	Overloader:SetPos(10,255)
	Overloader:SetText(Lib.Language.GetMessage("entity_overloader"))
	Overloader:SizeToContents()

	local OverloaderRefract = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	OverloaderRefract:SetPos(10,285)
	OverloaderRefract:SetText(Lib.Language.GetMessage("vis_refl_rings"))
	OverloaderRefract:SetConVar("cl_overloader_refract")
	OverloaderRefract:SetValue(GetConVar("cl_overloader_refract"):GetInt())

	local Overloaderparticle = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	Overloaderparticle:SetPos(10,315)
	Overloaderparticle:SetText(Lib.Language.GetMessage("vis_part_rings"))
	Overloaderparticle:SetConVar("cl_overloader_particle")
	Overloaderparticle:SetValue(GetConVar("cl_overloader_particle"):GetInt())

	local OverloaderDynLight = vgui.Create("DCheckBoxLabel",WeaponsSettings)
	OverloaderDynLight:SetPos(10,345)
	OverloaderDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	OverloaderDynLight:SetConVar("cl_overloader_dynlights")
	OverloaderDynLight:SetValue(GetConVar("cl_overloader_dynlights"):GetInt())

	local WeaponsSettings2 = vgui.Create("DPanel", ClientSheet)
	WeaponsSettings2:SetSize( sizew-10, sizeh-10 )
	WeaponsSettings2:Center();
	WeaponsSettings2:SetBackgroundColor(Color(150,150,150,150))
	ClientSheet:AddSheet( Lib.Language.GetMessage("client_settings_weapons").." (2/3)", WeaponsSettings2, "icon16/bomb.png" )

	local AsuranWeapon = vgui.Create("DLabel", WeaponsSettings2)
	AsuranWeapon:SetPos(10,15)
	AsuranWeapon:SetText(Lib.Language.GetMessage("entity_asuran_weapon"))
	AsuranWeapon:SizeToContents()

	local AsuranWeaponLaser = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	AsuranWeaponLaser:SetPos(10,45)
	AsuranWeaponLaser:SetText(Lib.Language.GetMessage("vis_sm_laser"))
	AsuranWeaponLaser:SetConVar("cl_asuran_laser")
	AsuranWeaponLaser:SetValue(GetConVar("cl_asuran_laser"):GetInt())

	local AsuranWeaponDynLight = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	AsuranWeaponDynLight:SetPos(10,75)
	AsuranWeaponDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	AsuranWeaponDynLight:SetConVar("cl_asuran_dynlights")
	AsuranWeaponDynLight:SetValue(GetConVar("cl_asuran_dynlights"):GetInt())

	local Dakara = vgui.Create("DLabel", WeaponsSettings2)
	Dakara:SetPos(10,105)
	Dakara:SetText(Lib.Language.GetMessage("entity_dakara"))
	Dakara:SizeToContents()

	local DakaraChargeUp = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	DakaraChargeUp:SetPos(10,135)
	DakaraChargeUp:SetText(Lib.Language.GetMessage("vis_charge_up"))
	DakaraChargeUp:SetConVar("cl_dakara_rings")
	DakaraChargeUp:SetValue(GetConVar("cl_dakara_rings"):GetInt())

	local DakaraRefract = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	DakaraRefract:SetPos(10,165)
	DakaraRefract:SetText(Lib.Language.GetMessage("vis_refl_sphere"))
	DakaraRefract:SetConVar("cl_dakara_refract")
	DakaraRefract:SetValue(GetConVar("cl_dakara_refract"):GetInt())

	local WeaponsTitle = vgui.Create("DLabel", WeaponsSettings2)
	WeaponsTitle:SetPos(10,195)
	WeaponsTitle:SetText(Lib.Language.GetMessage("vis_weap_title"))
	WeaponsTitle:SizeToContents()

	local StaffHitDynLights = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	StaffHitDynLights:SetPos(10,225)
	StaffHitDynLights:SetText(Lib.Language.GetMessage("vis_hit_dyn_light"))
	StaffHitDynLights:SetConVar("cl_staff_dynlights")
	StaffHitDynLights:SetValue(GetConVar("cl_staff_dynlights"):GetInt())

	local StaffFlyDynLights = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	StaffFlyDynLights:SetPos(10,255)
	StaffFlyDynLights:SetText(Lib.Language.GetMessage("vis_fly_dyn_light"))
	StaffFlyDynLights:SetConVar("cl_staff_dynlights_flight")
	StaffFlyDynLights:SetValue(GetConVar("cl_staff_dynlights_flight"):GetInt())

	local StaffSmoke = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	StaffSmoke:SetPos(10,285)
	StaffSmoke:SetText(Lib.Language.GetMessage("vis_smoke"))
	StaffSmoke:SetConVar("cl_staff_smoke")
	StaffSmoke:SetValue(GetConVar("cl_staff_smoke"):GetInt())

	local StaffScorch = vgui.Create("DCheckBoxLabel",WeaponsSettings2)
	StaffScorch:SetPos(10,315)
	StaffScorch:SetText(Lib.Language.GetMessage("vis_wall"))
	StaffScorch:SetConVar("cl_staff_scorch")
	StaffScorch:SetValue(GetConVar("cl_staff_scorch"):GetInt())

	local WeaponsSettings3 = vgui.Create("DPanel", ClientSheet)
	WeaponsSettings3:SetSize( sizew-10, sizeh-10 )
	WeaponsSettings3:Center();
	WeaponsSettings3:SetBackgroundColor(Color(150,150,150,150))
	ClientSheet:AddSheet( Lib.Language.GetMessage("client_settings_weapons").." (3/3)", WeaponsSettings3, "icon16/bomb.png" )

	local ZatTitle = vgui.Create("DLabel", WeaponsSettings3)
	ZatTitle:SetPos(10,15)
	ZatTitle:SetText(Lib.Language.GetMessage("eap_weapon_zat"))
	ZatTitle:SizeToContents()

	local ZatHitDynLights = vgui.Create("DCheckBoxLabel",WeaponsSettings3)
	ZatHitDynLights:SetPos(10,45)
	ZatHitDynLights:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	ZatHitDynLights:SetConVar("cl_zat_dynlights")
	ZatHitDynLights:SetValue(GetConVar("cl_zat_dynlights"):GetInt())

	local ZatHitEffect = vgui.Create("DCheckBoxLabel",WeaponsSettings3)
	ZatHitEffect:SetPos(10,75)
	ZatHitEffect:SetText(Lib.Language.GetMessage("vis_hit_eff"))
	ZatHitEffect:SetConVar("cl_zat_hiteffect")
	ZatHitEffect:SetValue(GetConVar("cl_zat_hiteffect"):GetInt())

	local ZatDissEffect = vgui.Create("DCheckBoxLabel",WeaponsSettings3)
	ZatDissEffect:SetPos(10,105)
	ZatDissEffect:SetText(Lib.Language.GetMessage("vis_diss_eff"))
	ZatDissEffect:SetConVar("cl_zat_dissolveeffect")
	ZatDissEffect:SetValue(GetConVar("cl_zat_dissolveeffect"):GetInt())

	--Stargates
	local StargateSettings = vgui.Create("DPanel", ClientSheet)
	StargateSettings:SetSize( sizew-10, sizeh-10 )
	StargateSettings:Center();
	StargateSettings:SetBackgroundColor(Color(150,150,150,150))
	ClientSheet:AddSheet( Lib.Language.GetMessage("client_settings_stargates"), StargateSettings, "img/eap_logo" )

	local Stargate = vgui.Create("DLabel", StargateSettings)
	Stargate:SetPos(10,15)
	Stargate:SetText(Lib.Language.GetMessage("stool_stargate"))
	Stargate:SizeToContents()

	local StargateDynLight = vgui.Create("DCheckBoxLabel",StargateSettings)
	StargateDynLight:SetPos(10,45)
	StargateDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	StargateDynLight:SetConVar("cl_stargate_dynlights")
	StargateDynLight:SetValue(GetConVar("cl_stargate_dynlights"):GetInt())

	if (file.Exists("materials/zup/stargate/effect_03.vmt","GAME")) then
		local StargateRipple = vgui.Create("DCheckBoxLabel",StargateSettings)
		StargateRipple:SetPos(10,75)
		StargateRipple:SetText(Lib.Language.GetMessage("vis_ripple"))
		StargateRipple:SetConVar("cl_stargate_ripple")
		StargateRipple:SetValue(GetConVar("cl_stargate_ripple"):GetInt())
	end
	
	local StargateKenter = vgui.Create("DCheckBoxLabel",StargateSettings)
	StargateKenter:SetPos(10,105)
	StargateKenter:SetText(Lib.Language.GetMessage("vis_kawoosh_eff"))
	StargateKenter:SetConVar("cl_stargate_kenter")
	StargateKenter:SetValue(GetConVar("cl_stargate_kenter"):GetInt())

	local StargateKMaterial = vgui.Create("DCheckBoxLabel",StargateSettings)
	StargateKMaterial:SetPos(10,135)
	StargateKMaterial:SetText(Lib.Language.GetMessage("vis_kawoosh_mat"))
	StargateKMaterial:SetConVar("cl_kawoosh_material")
	StargateKMaterial:SetValue(GetConVar("cl_kawoosh_material"):GetInt())

	local StargateEffects = vgui.Create("DCheckBoxLabel",StargateSettings)
	StargateEffects:SetPos(10,165)
	StargateEffects:SetText(Lib.Language.GetMessage("vis_stargate_eff"))
	StargateEffects:SetConVar("cl_stargate_effects")
	StargateEffects:SetValue(GetConVar("cl_stargate_effects"):GetInt())

	local StargateWormholeAnim = vgui.Create("DCheckBoxLabel",StargateSettings)
	StargateWormholeAnim:SetPos(10,195)
	StargateWormholeAnim:SetText(Lib.Language.GetMessage("vis_stargate_wormhole"))
	StargateWormholeAnim:SetConVar("cl_stargate_wormhole")
	StargateWormholeAnim:SetValue(GetConVar("cl_stargate_wormhole"):GetInt())

	local StargateU = vgui.Create("DLabel", StargateSettings)
	StargateU:SetPos(10,225)
	StargateU:SetText(Lib.Language.GetMessage("stargate_universe"))
	StargateU:SizeToContents()

	local StargateUDynLight = vgui.Create("DCheckBoxLabel",StargateSettings)
	StargateUDynLight:SetPos(10,255)
	StargateUDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	StargateUDynLight:SetConVar("cl_stargate_un_dynlights")
	StargateUDynLight:SetValue(GetConVar("cl_stargate_un_dynlights"):GetInt())

	local SuperGate = vgui.Create("DLabel", StargateSettings)
	SuperGate:SetPos(10,285)
	SuperGate:SetText(Lib.Language.GetMessage("stargate_supergate"))
	SuperGate:SizeToContents()

	local SuperGateDynLight = vgui.Create("DCheckBoxLabel",StargateSettings)
	SuperGateDynLight:SetPos(10,315)
	SuperGateDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	SuperGateDynLight:SetConVar("cl_supergate_dynlights")
	SuperGateDynLight:SetValue(GetConVar("cl_supergate_dynlights"):GetInt())

	--Shields
	local ShieldSettings = vgui.Create("DPanel", ClientSheet)
	ShieldSettings:SetSize( sizew-10, sizeh-10 )
	ShieldSettings:Center();
	ShieldSettings:SetBackgroundColor(Color(150,150,150,150))
	ClientSheet:AddSheet( Lib.Language.GetMessage("client_settings_shields"), ShieldSettings, "icon16/shield.png" )

	local Shield = vgui.Create("DLabel", ShieldSettings)
	Shield:SetPos(10,15)
	Shield:SetText(Lib.Language.GetMessage("stool_shield"))
	Shield:SizeToContents()

	local ShieldDynLight = vgui.Create("DCheckBoxLabel",ShieldSettings)
	ShieldDynLight:SetPos(10,45)
	ShieldDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	ShieldDynLight:SetConVar("cl_shield_dynlights")
	ShieldDynLight:SetValue(GetConVar("cl_shield_dynlights"):GetInt())

	local ShieldBubble = vgui.Create("DCheckBoxLabel",ShieldSettings)
	ShieldBubble:SetPos(10,75)
	ShieldBubble:SetText(Lib.Language.GetMessage("vis_shield_bubble"))
	ShieldBubble:SetConVar("cl_shield_bubble")
	ShieldBubble:SetValue(GetConVar("cl_shield_bubble"):GetInt())
	
	local ShieldHitRefl = vgui.Create("DCheckBoxLabel",ShieldSettings)
	ShieldHitRefl:SetPos(10,105)
	ShieldHitRefl:SetText(Lib.Language.GetMessage("vis_hit_refl"))
	ShieldHitRefl:SetConVar("cl_shield_hitradius")
	ShieldHitRefl:SetValue(GetConVar("cl_shield_hitradius"):GetInt())

	local ShieldHitEffect = vgui.Create("DCheckBoxLabel",ShieldSettings)
	ShieldHitEffect:SetPos(10,135)
	ShieldHitEffect:SetText(Lib.Language.GetMessage("vis_hit_eff"))
	ShieldHitEffect:SetConVar("cl_shield_hiteffect")
	ShieldHitEffect:SetValue(GetConVar("cl_shield_hiteffect"):GetInt())

	local AtlShield = vgui.Create("DLabel", ShieldSettings)
	AtlShield:SetPos(10,165)
	AtlShield:SetText(Lib.Language.GetMessage("vis_atl_shield"))
	AtlShield:SizeToContents()

	local AtlShieldRefl = vgui.Create("DCheckBoxLabel",ShieldSettings)
	AtlShieldRefl:SetPos(10,195)
	AtlShieldRefl:SetText(Lib.Language.GetMessage("vis_refl"))
	AtlShieldRefl:SetConVar("cl_shieldcore_refract")
	AtlShieldRefl:SetValue(GetConVar("cl_shieldcore_refract"):GetInt())

	--Other
	local OtherSettings = vgui.Create("DPanel", ClientSheet)
	OtherSettings:SetSize( sizew-10, sizeh-10 )
	OtherSettings:Center();
	OtherSettings:SetBackgroundColor(Color(150,150,150,150))
	ClientSheet:AddSheet( Lib.Language.GetMessage("client_settings_others"), OtherSettings, "icon16/tux.png" )

	local Harvester = vgui.Create("DLabel", OtherSettings)
	Harvester:SetPos(10,15)
	Harvester:SetText(Lib.Language.GetMessage("stool_harvester"))
	Harvester:SizeToContents()

	local HarvDynLight = vgui.Create("DCheckBoxLabel",OtherSettings)
	HarvDynLight:SetPos(10,45)
	HarvDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	HarvDynLight:SetConVar("cl_harvester_dynlights")
	HarvDynLight:SetValue(GetConVar("cl_harvester_dynlights"):GetInt())

	local Cloak = vgui.Create("DLabel", OtherSettings)
	Cloak:SetPos(10,75)
	Cloak:SetText(Lib.Language.GetMessage("stool_cloak"))
	Cloak:SizeToContents()

	local CloakPass = vgui.Create("DCheckBoxLabel",OtherSettings)
	CloakPass:SetPos(10,105)
	CloakPass:SetText(Lib.Language.GetMessage("vis_cloak_pass"))
	CloakPass:SetConVar("cl_cloaking_hitshader")
	CloakPass:SetValue(GetConVar("cl_cloaking_hitshader"):GetInt())

	local CloakEff = vgui.Create("DCheckBoxLabel",OtherSettings)
	CloakEff:SetPos(10,135)
	CloakEff:SetText(Lib.Language.GetMessage("vis_cloak_eff"))
	CloakEff:SetConVar("cl_cloaking_shader")
	CloakEff:SetValue(GetConVar("cl_cloaking_shader"):GetInt())

	local AppleCore = vgui.Create("DLabel", OtherSettings)
	AppleCore:SetPos(10,165)
	AppleCore:SetText(Lib.Language.GetMessage("entity_apple_core"))
	AppleCore:SizeToContents()

	local ACDynLight = vgui.Create("DCheckBoxLabel",OtherSettings)
	ACDynLight:SetPos(10,195)
	ACDynLight:SetText(Lib.Language.GetMessage("vis_dyn_light"))
	ACDynLight:SetConVar("cl_applecore_light")
	ACDynLight:SetValue(GetConVar("cl_applecore_light"):GetInt())

	local ACSmoke = vgui.Create("DCheckBoxLabel",OtherSettings)
	ACSmoke:SetPos(10,225)
	ACSmoke:SetText(Lib.Language.GetMessage("vis_smoke"))
	ACSmoke:SetConVar("cl_applecore_smoke")
	ACSmoke:SetValue(GetConVar("cl_applecore_smoke"):GetInt())

	local HUD = vgui.Create("DLabel", OtherSettings)
	HUD:SetPos(10,255)
	HUD:SetText(Lib.Language.GetMessage("vis_hud_title"))
	HUD:SizeToContents()

	local HUDEnergy = vgui.Create("DCheckBoxLabel",OtherSettings)
	HUDEnergy:SetPos(10,285)
	HUDEnergy:SetText(Lib.Language.GetMessage("vis_hud_energy"))
	HUDEnergy:SetConVar("cl_draw_huds")
	HUDEnergy:SetValue(GetConVar("cl_draw_huds"):GetInt())

	local HUDDHDGlyph = vgui.Create("DCheckBoxLabel",OtherSettings)
	HUDDHDGlyph:SetPos(10,315)
	HUDDHDGlyph:SetText(Lib.Language.GetMessage("vis_dhd_glyphs"))
	HUDDHDGlyph:SetConVar("cl_dhd_letters")
	HUDDHDGlyph:SetValue(GetConVar("cl_dhd_letters"):GetInt())

	local MenuReset = vgui.Create( "DButton", OtherSettings)
	MenuReset:SetText(" "..Lib.Language.GetMessage("vis_menu_reset").." ");
	MenuReset:SetSize( sizew-40, 32 )
	MenuReset:SetPos(10,345)
	MenuReset.DoClick = function() 
		LocalPlayer():ConCommand("eap_reset_menu")
	end
end
concommand.Add("client_settings",Lib.Settings.Client)