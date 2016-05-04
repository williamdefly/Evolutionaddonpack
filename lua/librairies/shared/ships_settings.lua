/*
	Keyboard Settings for Evolution Addon Pack
	Copyright (C) made by Elanis

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

Lib.Settings = Lib.Settings or { };

MsgN("librairies/shared/ship_settings.lua")

function Lib.Settings.Keyboard()

	if(SERVER)then return end

	local sizew,sizeh = 600,460;

	KeyboardPanel = vgui.Create( "EditablePanel" );
	KeyboardPanel:SetPaintBackgroundEnabled( false );
	KeyboardPanel:SetPaintBorderEnabled( false );
	KeyboardPanel:SetSize(sizew+10,sizeh+10);
	KeyboardPanel:Center();
	KeyboardPanel:MakePopup();

	local KeyboardSheet = vgui.Create( "DPropertySheet", KeyboardPanel )
	KeyboardSheet:SetPos( 5, 5 )
	KeyboardSheet:SetSize( sizew, sizeh )
	KeyboardSheet.tabScroller:DockMargin( 0, 0, 20, 0 )

	KeyboardSheet.CrossFade = function(self, anim, delta, data )

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
	KeyboardSheet.animFade = Derma_Anim( "Fade", KeyboardSheet, KeyboardSheet.CrossFade )

	KeyboardSheet.CloseButton = vgui.Create( "DImageButton", KeyboardPanel)
	KeyboardSheet.CloseButton:SetImage( "icon16/cross.png" )
	KeyboardSheet.CloseButton:SetSize( 16, 16 )
	KeyboardSheet.CloseButton:SetPos(sizew-12,7);
	KeyboardSheet.CloseButton.DoClick = function() KeyboardPanel:Remove() end

	--Moving
	local KeyboardMvm = vgui.Create("DPanel", KeyboardSheet)
	KeyboardMvm:SetSize( sizew-10, sizeh-10 )
	KeyboardMvm:Center();
	KeyboardSheet:AddSheet( Lib.Language.GetMessage("key_move_title"), KeyboardMvm, "icon16/arrow_out.png" )

	local Fwd = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Fwd:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_forward"),"FWD")
	Fwd:SetPos(10,15)

	local Back = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Back:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_back"),"BACK")
	Back:SetPos(10,45)

	local Left = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Left:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_left"),"LEFT")
	Left:SetPos(10,75)

	local Right = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Right:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_right"),"RIGHT")
	Right:SetPos(10,105)

	local Up = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Up:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_up"),"UP")
	Up:SetPos(10,135)

	local Down = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Down:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_down"),"DOWN")
	Down:SetPos(10,165)

	local Speed = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Speed:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_boost"),"SPD")
	Speed:SetPos(10,195)

	local Standby = vgui.Create("SetKeyboardKey",KeyboardMvm)
	Standby:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_move_standby"),"HOVER")
	Standby:SetPos(10,225)

	local RollLeft = vgui.Create("SetKeyboardKey",KeyboardMvm)
	RollLeft:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_roll_left"),"RL")
	RollLeft:SetPos(10,255)

	local RollRight = vgui.Create("SetKeyboardKey",KeyboardMvm)
	RollRight:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_roll_right"),"RR")
	RollRight:SetPos(10,285)

	local ResetRoll = vgui.Create("SetKeyboardKey",KeyboardMvm)
	ResetRoll:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_roll_reset"),"RROLL")
	ResetRoll:SetPos(10,315)

	--Combat
	local KeyboardCombat = vgui.Create("DPanel", KeyboardSheet)
	KeyboardCombat:SetSize( sizew-10, sizew-10 )
	KeyboardCombat:Center();
	KeyboardSheet:AddSheet( Lib.Language.GetMessage("key_combat_title"), KeyboardCombat, "icon16/bomb.png" )

	local MainWep = vgui.Create("SetKeyboardKey",KeyboardCombat)
	MainWep:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_combat_primary"),"FIRE")
	MainWep:SetPos(10,15)

	local SecWeap = vgui.Create("SetKeyboardKey",KeyboardCombat)
	SecWeap:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_combat_secondary"),"TRACK")
	SecWeap:SetPos(10,45)

	local Shield = vgui.Create("SetKeyboardKey",KeyboardCombat)
	Shield:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_combat_shield"),"SHIELD")
	Shield:SetPos(10,75)

	local SelfD = vgui.Create("SetKeyboardKey",KeyboardCombat)
	SelfD:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_combat_selfdestruct"),"BOOM")
	SelfD:SetPos(10,105)

	local ToggleW = vgui.Create("SetKeyboardKey",KeyboardCombat)
	ToggleW:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_combat_toggle"),"CHGATK")
	ToggleW:SetPos(10,135)

	local WPods = vgui.Create("SetKeyboardKey",KeyboardCombat)
	WPods:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_combat_weaponpods"),"WEPPODS")
	WPods:SetPos(10,165)

	--Viewing
	local KeyboardView = vgui.Create("DPanel", KeyboardSheet)
	KeyboardView:SetSize( sizew-10, sizew-10 )
	KeyboardView:Center();
	KeyboardSheet:AddSheet( Lib.Language.GetMessage("key_view_title"), KeyboardView, "icon16/eye.png" )

	local Zin = vgui.Create("SetKeyboardKey",KeyboardView)
	Zin:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_view_zoomin"),"Z+")
	Zin:SetPos(10,15)

	local Zout = vgui.Create("SetKeyboardKey",KeyboardView)
	Zout:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_view_zoomout"),"Z-")
	Zout:SetPos(10,45)

	local Vup = vgui.Create("SetKeyboardKey",KeyboardView)
	Vup:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_view_up"),"A+")
	Vup:SetPos(10,75)

	local Vdown = vgui.Create("SetKeyboardKey",KeyboardView)
	Vdown:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_view_down"),"A-")
	Vdown:SetPos(10,105)

	local ToggleV = vgui.Create("SetKeyboardKey",KeyboardView)
	ToggleV:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_view_toggle"),"VIEW")
	ToggleV:SetPos(10,135)	

	local HUD = vgui.Create("SetKeyboardKey",KeyboardView)
	HUD:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_view_hud"),"HIDEHUD")
	HUD:SetPos(10,165)

	local LSD = vgui.Create("SetKeyboardKey",KeyboardView)
	LSD:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_view_lsd"),"HIDELSD")
	LSD:SetPos(10,195)

	--Other
	local KeyboardOther = vgui.Create("DPanel", KeyboardSheet)
	KeyboardOther:SetSize( sizew-10, sizew-10 )
	KeyboardOther:Center();
	KeyboardSheet:AddSheet( Lib.Language.GetMessage("key_other_title"), KeyboardOther, "icon16/tux.png" )

	local Out = vgui.Create("SetKeyboardKey",KeyboardOther)
	Out:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_out"),"EXIT")
	Out:SetPos(10,15)

	local DHD = vgui.Create("SetKeyboardKey",KeyboardOther)
	DHD:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_dhd"),"DHD")
	DHD:SetPos(10,45)

	local Hyper = vgui.Create("SetKeyboardKey",KeyboardOther)
	Hyper:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_hyper"),"HYPERSPACE")
	Hyper:SetPos(10,75)

	local Door = vgui.Create("SetKeyboardKey",KeyboardOther)
	Door:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_door"),"DOOR")
	Door:SetPos(10,105)

	local Light = vgui.Create("SetKeyboardKey",KeyboardOther)
	Light:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_light"),"LIGHT")
	Light:SetPos(10,135)

	local Pods = vgui.Create("SetKeyboardKey",KeyboardOther)
	Pods:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_pods"),"PODS")
	Pods:SetPos(10,165)

	local AutoPilot = vgui.Create("SetKeyboardKey",KeyboardOther)
	AutoPilot:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_auto"),"AUTOPILOT")
	AutoPilot:SetPos(10,195)

	local Eject = vgui.Create("SetKeyboardKey",KeyboardOther)
	Eject:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_eject"),"EJECT")
	Eject:SetPos(10,225)

	local Wheels = vgui.Create("SetKeyboardKey",KeyboardOther)
	Wheels:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_wheels"),"WHEELS")
	Wheels:SetPos(10,255)

	local Flares = vgui.Create("SetKeyboardKey",KeyboardOther)
	Flares:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_flares"),"FLARES")
	Flares:SetPos(10,285)

	local Spit = vgui.Create("SetKeyboardKey",KeyboardOther)
	Spit:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_spit"),"SPIT")
	Spit:SetPos(10,315)

	local Harvest = vgui.Create("SetKeyboardKey",KeyboardOther)
	Harvest:SetData("EAP_KEYBOARD",Lib.Language.GetMessage("key_other_harv"),"SUCK")
	Harvest:SetPos(10,345)

	--Restore Button
	local restore = vgui.Create("DButton", KeyboardPanel);
	restore:SetText(Lib.Language.GetMessage("key_restore"))
	restore:SetImage("icon16/arrow_refresh.png");
	restore:SetPos(20, sizeh-40);
	restore:SetSize(sizew-30, 28);
	restore.DoClick = function() Lib.Settings.ResetKeyboard() end
end
concommand.Add("keyboard_settings",Lib.Settings.Keyboard)

function Lib.Settings.ResetKeyboard()

	if(KeyboardPanel!=nil) then
		KeyboardPanel:Remove()
	end

	file.Delete("eap/eap_keyboard.txt")

	Lib.Settings.KeyboardInit();

	hook.Call("SetKeyboardKey.Initialize")

	timer.Create( "ReOpenPanel", 0.2, 1, Lib.Settings.Keyboard)
end

function Lib.Settings.KeyboardInit()

	if(SERVER)then return end

	if (Lib==nil or Lib.KeyBoard==nil or Lib.KeyBoard.New==nil) then return end

	--########## Keybinder stuff
	local KBD = Lib.KeyBoard:New("EAP_KEYBOARD")
	--Navigation
	KBD:SetDefaultKey("FWD",Lib.KeyBoard.BINDS["+forward"] or "W") -- Forward
	KBD:SetDefaultKey("LEFT",Lib.KeyBoard.BINDS["+moveleft"] or "A")
	KBD:SetDefaultKey("RIGHT",Lib.KeyBoard.BINDS["+moveright"] or "D")
	KBD:SetDefaultKey("BACK",Lib.KeyBoard.BINDS["+back"] or "S")
	KBD:SetDefaultKey("UP",Lib.KeyBoard.BINDS["+jump"] or "SPACE")
	KBD:SetDefaultKey("DOWN",Lib.KeyBoard.BINDS["+duck"] or "CTRL")
	KBD:SetDefaultKey("SPD",Lib.KeyBoard.BINDS["+speed"] or "SHIFT")
	KBD:SetDefaultKey("BOOST","B")
	KBD:SetDefaultKey("HOVER","J")	
	--Roll
	KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
	KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
	KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
	--Attack
	KBD:SetDefaultKey("FIRE",Lib.KeyBoard.BINDS["+attack"] or "MOUSE1")
	KBD:SetDefaultKey("TRACK",Lib.KeyBoard.BINDS["+attack2"] or "MOUSE2")
	--Special Actions
	KBD:SetDefaultKey("BOOM","BACKSPACE")
	KBD:SetDefaultKey("CHGATK","R")
	KBD:SetDefaultKey("WEPPODS","KEY_NONE")
	KBD:SetDefaultKey("DOOR","2")
	KBD:SetDefaultKey("LIGHT","F")
	KBD:SetDefaultKey("PODS","X")
	KBD:SetDefaultKey("AUTOPILOT","K")
	KBD:SetDefaultKey("EJECT","3")
	KBD:SetDefaultKey("FLARES","4")
	KBD:SetDefaultKey("WHEELS","5")
	KBD:SetDefaultKey("SPIT","C")
	KBD:SetDefaultKey("SUCK","I")
	KBD:SetDefaultKey("LAND","ENTER");
	--Other Specials
	KBD:SetDefaultKey("CLOAK","ALT")
	KBD:SetDefaultKey("SHIELD","G")
	KBD:SetDefaultKey("HYPERSPACE","J")
	KBD:SetDefaultKey("DHD","0")
	--HUD/LSD
	KBD:SetDefaultKey("HIDEHUD","H")
	KBD:SetDefaultKey("HIDELSD","L")
	--View
	KBD:SetDefaultKey("VIEW","1")
	KBD:SetDefaultKey("Z+","UPARROW")
	KBD:SetDefaultKey("Z-","DOWNARROW")
	KBD:SetDefaultKey("A+","LEFTARROW")
	KBD:SetDefaultKey("A-","RIGHTARROW")
	--Exit
	KBD:SetDefaultKey("EXIT",Lib.KeyBoard.BINDS["+use"] or "E")

	Lib.Settings.KBD = KBD;
end
Lib.Settings.KeyboardInit()