
ACF = ACF or {}

local cat = ((ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction");

TOOL.Category		= cat
TOOL.Name			= "#Tool.acfsound.name"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar["pitch"] = "1"
if CLIENT then
	language.Add( "Tool.acfsound.name", ACFTranslation.SoundToolText[1] )
	language.Add( "Tool.acfsound.desc", ACFTranslation.SoundToolText[2] )
	language.Add( "Tool.acfsound.0", ACFTranslation.SoundToolText[3] )
end

if CLIENT then

	TOOL.Information = {

		{ name = "left", icon = "gui/lmb.png" },
		{ name = "right", icon = "gui/rmb.png" },
		{ name = "reload", icon = "gui/r.png" },

	}

	language.Add( "Tool.acfsound.name", ACFTranslation.SoundToolText[1] )
	language.Add( "Tool.acfsound.desc", ACFTranslation.SoundToolText[2] )
	--language.Add( "Tool.acfsound.0", ACFTranslation.SoundToolText[3] )

	language.Add( "Tool.acfsound.left", "Apply the new sound. You can use empty sounds too." )
	language.Add( "Tool.acfsound.right", "Copy the sound." )
	language.Add( "Tool.acfsound.reload", "Reset to default sound." )

end

local GunClasses = ACF.Classes.GunClass
local GunTable = ACF.Weapons.Guns

local EngineTable = ACF.Weapons.Engines

ACF.SoundToolSupport = {

	acf_gun = {

		GetSound = function(ent) return { Sound = ent.Sound, Pitch = ent.SoundPitch or 100 } end,

		SetSound = function(ent, soundData)
			ent.Sound = soundData.Sound
			ent.SoundPitch = soundData.Pitch
			ent:SetNWString( "Sound", soundData.Sound )
			ent:SetNWInt( "SoundPitch", soundData.Pitch )
		end,

		ResetSound = function(ent)

			local Class = ent.Class
			local lookup = GunTable[ent.Id]

			local sound = lookup.sound or GunClasses[Class]["sound"]

			local soundData = { Sound = sound, Pitch = 100 }

			local setSound = ACF.SoundToolSupport["acf_gun"].SetSound
			setSound( ent, soundData )
		end,

		NewFormat = function()
		end
	},

	acf_engine = {

		GetSound = function(ent) return { Sound = ent.SoundPath, Pitch = ent.SoundPitch or 100 } end,

		SetSound = function(ent, soundData)
			ent.SoundPath = soundData.Sound
			ent.SoundPitch = soundData.Pitch
		end,

		ResetSound = function(ent)

			local Id = ent.Id
			local pitch = EngineTable[Id]["pitch"] or 1
			local sound = EngineTable[Id]["sound"] or ""

			local soundData = { Sound = sound, Pitch = pitch }

			local setSound = ACF.SoundToolSupport["acf_engine"].SetSound
			setSound( ent, soundData )
		end
	},

	acf_rack = {

		GetSound = function(ent) return { Sound = ent.Sound, Pitch = ent.SoundPitch or 100 } end,

		SetSound = function(ent, soundData)

			ent.Sound = soundData.Sound
			ent.SoundPitch = soundData.Pitch
			ent:SetNWString( "Sound", soundData.Sound )
			ent:SetNWInt( "SoundPitch",  soundData.Pitch )
		end,

		ResetSound = function(ent)

			local Class = ent.Class
			local sound = GunClasses[Class]["sound"] or ""

			local soundData = { Sound = sound, Pitch = 100 }

			local setSound = ACF.SoundToolSupport["acf_rack"].SetSound
			setSound( ent, soundData )
		end,

		NewFormat = function()
		end

	},

	acf_missileradar = {

		GetSound = function(ent) return { Sound = ent.Sound or ACFM.DefaultRadarSound, Pitch = ent.SoundPitch or 100 } end,

		SetSound = function(ent, soundData)
			ent.Sound = soundData.Sound
			ent.SoundPitch = soundData.Pitch
			ent:SetNWString( "Sound", soundData.Sound )
			ent:SetNWInt( "SoundPitch",  soundData.Pitch )
		end,

		ResetSound = function(ent)
			local soundData = {Sound = ACFM.DefaultRadarSound, Pitch = 100}

			local setSound = ACF.SoundToolSupport["acf_missileradar"].SetSound
			setSound( ent, soundData )
		end
	},

	NewFormat = function()
	end

}

local function ReplaceSound( _ , Entity , data)
	if not IsValid( Entity ) then return end
	local sound = data[1]
	local pitch = tonumber(data[2]) or 100
	local isNew = data[3]

	if pitch < 10 then
		pitch = pitch * 100
	end

	local class = Entity:GetClass()
	local support = ACF.SoundToolSupport[class]

	if support then

		-- Before to the implementation, sounds were still being granted with the pitch you had on the slider,
		-- making that the official integration makes it to use it, altering the supposed non pitch it had before
		-- This should fix it, making sure to tag it with a new format in future applications.
		if support.NewFormat and not isNew then
			pitch = 100
		end

		local newdata = {sound, pitch, true}
		support.SetSound(Entity, {Sound = sound, Pitch = pitch})
		duplicator.StoreEntityModifier( Entity, "acf_replacesound", newdata )
	end
end

duplicator.RegisterEntityModifier( "acf_replacesound", ReplaceSound )

local function IsReallyValid(trace, ply)
	if not trace.Entity:IsValid() then return false end
	if trace.Entity:IsPlayer() then return false end
	if SERVER and not trace.Entity:GetPhysicsObject():IsValid() then return false end

	local class = trace.Entity:GetClass()
	if not ACF.SoundToolSupport[class] then

		if string.StartWith(class, "acf_") then
			ACF_SendNotify( ply, false, class .. ACFTranslation.SoundToolText[4] )
		else
			ACF_SendNotify( ply, false, ACFTranslation.SoundToolText[5] )
		end

		return false
	end

	return true

end

function TOOL:LeftClick( trace )
	if CLIENT then return true end
	if not IsReallyValid( trace, self:GetOwner() ) then return false end

	local sound = self:GetOwner():GetInfo("wire_soundemitter_sound")
	local pitch = self:GetOwner():GetInfo("acfsound_pitch")
	ReplaceSound( self:GetOwner(), trace.Entity, {sound, pitch, true} )
	return true
end

function TOOL:RightClick( trace )
	if CLIENT then return true end
	if not IsReallyValid( trace, self:GetOwner() ) then return false end

	local class = trace.Entity:GetClass()
	local support = ACF.SoundToolSupport[class]
	if not support then return false end

	local soundData = support.GetSound(trace.Entity)

	self:GetOwner():ConCommand("wire_soundemitter_sound " .. soundData.Sound);

	if soundData.Pitch then
		self:GetOwner():ConCommand("acfsound_pitch " .. soundData.Pitch);
	end

	return true
end

function TOOL:Reload( trace )
	if CLIENT then return true end
	if not IsReallyValid( trace, self:GetOwner() ) then return false end

	local class = trace.Entity:GetClass()
	local support = ACF.SoundToolSupport[class]
	if not support then return false end

	support.ResetSound(trace.Entity)

	duplicator.ClearEntityModifier( trace.Entity, "acf_replacesound" )

	return true
end

if CLIENT then

	function TOOL.BuildCPanel(panel)
		local wide = panel:GetWide()

		panel:Help( "Replaces default sounds of certain ACE entities with this tool. You can replace the sounds of cannons, racks, engines and Anti-Missile Radar.\n" )

		local SoundNameText = vgui.Create("DTextEntry", ValuePanel)
		SoundNameText:SetText("")
		SoundNameText:SetWide(wide - 20)
		SoundNameText:SetTall(20)
		SoundNameText:SetMultiline(false)
		SoundNameText:SetConVar("wire_soundemitter_sound")
		SoundNameText:SetVisible(true)
		SoundNameText:Dock(LEFT)
		panel:AddItem(SoundNameText)

		local SoundBrowserButton = vgui.Create("DButton")
		SoundBrowserButton:SetText("Open Sound Browser")
		SoundBrowserButton:SetWide(wide)
		SoundBrowserButton:SetTall(20)
		SoundBrowserButton:SetVisible(true)
		SoundBrowserButton:SetIcon( "icon16/application_view_list.png" )
		SoundBrowserButton.DoClick = function()
			RunConsoleCommand("wire_sound_browser_open", SoundNameText:GetValue(), "1")
		end
		panel:AddItem(SoundBrowserButton)

		local SoundPre = vgui.Create("DPanel")
		SoundPre:SetWide(wide)
		SoundPre:SetTall(20)
		SoundPre:SetVisible(true)

		local SoundPreWide = SoundPre:GetWide()

		local SoundPrePlay = vgui.Create("DButton", SoundPre)
		SoundPrePlay:SetText("Play")
		SoundPrePlay:SetWide(SoundPreWide / 2)
		SoundPrePlay:SetPos(0, 0)
		SoundPrePlay:SetTall(20)
		SoundPrePlay:SetVisible(true)
		SoundPrePlay:SetIcon( "icon16/sound.png" )
		SoundPrePlay.DoClick = function()
			RunConsoleCommand("play",SoundNameText:GetValue())
		end

		local SoundPreStop = vgui.Create("DButton", SoundPre)
		SoundPreStop:SetText("Stop")
		SoundPreStop:SetWide(SoundPreWide / 2)
		SoundPreStop:SetPos(SoundPreWide / 2, 0)
		SoundPreStop:SetTall(20)
		SoundPreStop:SetVisible(true)
		SoundPreStop:SetIcon( "icon16/sound_mute.png" )
		SoundPreStop.DoClick = function()
			RunConsoleCommand("play", "common/NULL.WAV") --Playing a silent sound will mute the preview but not the sound emitters.
		end
		panel:AddItem(SoundPre)
		SoundPre:InvalidateLayout(true)
		SoundPre.PerformLayout = function()
			local SoundPreWide = SoundPre:GetWide()
			SoundPrePlay:SetWide(SoundPreWide / 2)
			SoundPreStop:SetWide(SoundPreWide / 2)
			SoundPreStop:SetPos(SoundPreWide / 2, 0)
		end

		local CopyButton = vgui.Create("DButton")
		CopyButton:SetText("Copy to clipboard")
		CopyButton:SetWide(wide)
		CopyButton:SetTall(20)
		CopyButton:SetIcon( "icon16/page_copy.png" )
		CopyButton:SetVisible(true)
		CopyButton.DoClick = function()
			SetClipboardText( SoundNameText:GetValue())
		end
		panel:AddItem(CopyButton)

		local ClearButton = vgui.Create("DButton")
		ClearButton:SetText("Clear Sound")
		ClearButton:SetWide(wide)
		ClearButton:SetTall(20)
		ClearButton:SetIcon( "icon16/cancel.png" )
		ClearButton:SetVisible(true)
		ClearButton.DoClick = function()
			SoundNameText:SetValue("")
			RunConsoleCommand("wire_soundemitter_sound", "")
		end
		panel:AddItem(ClearButton)

		panel:NumSlider( "Pitch", "acfsound_pitch", 10, 255, 0 )
		panel:ControlHelp( "Adjust the pitch of the sound. Currently supports engines, guns, racks and missile radars. \n\nNote: This will not work with dynamic sounds atm." )
	end

	--[[
		This is another dirty hack that prevents the sound emitter tool from automatically equipping when a sound is selected in the sound browser.
		However, this hack only applies if the currently equipped tool is the sound replacer and you're trying to switch to the wire sound tool.
		Additionally, if you're using a weapon instead of a tool and you choose a sound while the sound replacer menu is displayed, you will be redirected to it.

		The sound emitter will be equipped normally when switching to any other tool at the time of the change.
	]]

	spawnmenu.ActivateToolLegacy = spawnmenu.ActivateToolLegacy or spawnmenu.ActivateTool

	function spawnmenu.ActivateTool( tool, bool_menu, ... )

		local CurTool = LocalPlayer():GetTool()

		if CurTool and CurTool.Mode then

			local CurMode = isstring(CurTool.Mode) and CurTool.Mode or ""

			if tool == "wire_soundemitter" and CurMode == "acfsound" then
				tool = CurMode
			end

		end

		spawnmenu.ActivateToolLegacy( tool, bool_menu, ... )
	end

end
