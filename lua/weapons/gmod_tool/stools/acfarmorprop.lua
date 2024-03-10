
local cat = ((ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction");

TOOL.Category	= cat
TOOL.Name	= "#tool.acfarmorprop.name"
TOOL.Command	= nil
TOOL.ConfigName = ""

TOOL.ClientConVar["thickness"]  = 1
TOOL.ClientConVar["ductility"]  = 0
TOOL.ClientConVar["material"]	= "RHA"

--Used by the panel. If i can to use the TOOL itself for this, i would be really appreciated
local ToolPanel = ToolPanel or {}

CreateClientConVar( "acfarmorprop_area", 0, false, true ) -- we don't want this one to save

-- Calculates mass, armor, and health given prop area and desired ductility and thickness.
local function CalcArmor( Area, Ductility, Thickness, Mat )

	Mat = Mat or "RHA"

	local MatData	= ACE_GetMaterialData( Mat )
	local MassMod	= MatData.massMod

	local mass		= Area * ( 1 + Ductility ) ^ 0.5 * Thickness * 0.00078 * MassMod
	local armor		= ACF_CalcArmor( Area, Ductility, mass / MassMod )
	local health		= ( Area + Area * Ductility ) / ACF.Threshold

	return mass, armor, health

end

if CLIENT then

	language.Add( "tool.acfarmorprop.name", ACFTranslation.ArmorPropertiesText[1] )
	language.Add( "tool.acfarmorprop.desc", ACFTranslation.ArmorPropertiesText[2] )
	language.Add( "tool.acfarmorprop.0", ACFTranslation.ArmorPropertiesText[3] )

	surface.CreateFont( "Torchfont", { size = 40, weight = 1000, font = "arial" } )

	--Required in order to update material data inserted in client convars
	local function ACE_MaterialCheck( Material )

		--Convert old numeric IDs to the new string IDs
		local BackCompMat = {
			"RHA",
			"CHA",
			"Cer",
			"Rub",
			"ERA",
			"Alum",
			"Texto"
		}

		--Refreshing the data, so we can replace non valid data with the callback.
		if isnumber(tonumber(Material)) then

			local Mat_ID = math.Clamp(Material + 1, 1,7)
			Material = BackCompMat[Mat_ID]

			--Updates the convar with the proper material
			RunConsoleCommand( "acfarmorprop_material", Material )
		end
	end

	--Looks like client convars are not initialized very quickly, so we will wait a bit until they become valid.
	timer.Simple(0.1, function()
		ACE_MaterialCheck( GetConVar("acfarmorprop_material"):GetString() )
	end )

	--Replicated from PANEL:CPanelText(Name, Desc, Font). No idea why this doesnt work with this function out of this file
	local function ArmorPanelText( name, panel, desc, font )

		if not PanelTxt then PanelTxt = {} end

		if not PanelTxt[name .. "_aText"] then
			PanelTxt[name .. "_aText"] = panel:Help(desc)
			PanelTxt[name .. "_aText"]:SetContentAlignment( TEXT_ALIGN_CENTER )
			PanelTxt[name .. "_aText"]:SetAutoStretchVertical(true)
			if font then PanelTxt[name .. "_aText"]:SetFont( font ) end
			PanelTxt[name .. "_aText"]:SizeToContents()

			panel:AddItem(PanelTxt[name .. "_aText"])

		end

		PanelTxt[name .. "_aText"]:SetText( desc )
		PanelTxt[name .. "_aText"]:SetSize( panel:GetWide(), 10 )
		PanelTxt[name .. "_aText"]:SizeToContentsY()

	end

	-- Material ComboBox creation
	local function MaterialTable( panel )

		local MaterialTypes = ACE.ArmorTypes
		if not MaterialTypes then return end

		local Material = GetConVar("acfarmorprop_material"):GetString()
		local MaterialData  = MaterialTypes[Material] or MaterialTypes["RHA"]

		ArmorPanelText( "ComboBox", panel, "Material" )

		if not ToolPanel.ComboMat then

			ToolPanel.panel = panel

			ToolPanel.ComboMat = vgui.Create( "DComboBox" )
			ToolPanel.ComboMat:SetPos( 5, 30 )
			ToolPanel.ComboMat:SetSize( 100, 20 )
			ToolPanel.ComboMat:SetValue( MaterialData.sname )
			ToolPanel.panel:AddItem(ToolPanel.ComboMat)

			for _, Mat  in pairs(MaterialTypes) do
				if ACF.Year >= Mat.year then
					ToolPanel.ComboMat:AddChoice(Mat.sname, Mat.id )
				end
			end

			ArmorPanelText( "ComboTitle", ToolPanel.panel, MaterialData.name , "DermaDefaultBold" )
			ArmorPanelText( "ComboDesc" , ToolPanel.panel, MaterialData.desc .. "\n" )

			ArmorPanelText( "ComboCurve", ToolPanel.panel, "Curve : " .. MaterialData.curve )
			ArmorPanelText( "ComboMass" , ToolPanel.panel, "Mass : " .. MaterialData.massMod .. "x RHA" )
			ArmorPanelText( "ComboKE"	, ToolPanel.panel, "KE protection : " .. MaterialData.effectiveness .. "x RHA" )
			ArmorPanelText( "ComboCHE"  , ToolPanel.panel, "CHEMICAL protection : " .. (MaterialData.HEATeffectiveness or MaterialData.effectiveness) .. "x RHA" )
			ArmorPanelText( "ComboYear" , ToolPanel.panel, "Year : " .. (MaterialData.year or "unknown") )

			function ToolPanel.ComboMat:OnSelect(self, _, value )

				RunConsoleCommand( "acfarmorprop_material", value )
			end
		end
	end

	--Main menu building
	function TOOL.BuildCPanel( panel )
		local Presets = vgui.Create( "ControlPresets" )

		Presets:AddConVar( "acfarmorprop_thickness" )
		Presets:AddConVar( "acfarmorprop_ductility" )
		Presets:AddConVar( "acfarmorprop_material" )
		Presets:SetPreset( "acfarmorprop" )

		panel:AddItem( Presets )

		panel:NumSlider( ACFTranslation.ArmorPropertiesText[4], "acfarmorprop_thickness", 1, 5000 )
		panel:ControlHelp( ACFTranslation.ArmorPropertiesText[5] )

		panel:NumSlider( ACFTranslation.ArmorPropertiesText[6], "acfarmorprop_ductility", -80, 80 )
		panel:ControlHelp( ACFTranslation.ArmorPropertiesText[7] )

		MaterialTable(panel)

	end

	-- clamp thickness if the change in ductility puts mass out of range
	cvars.AddChangeCallback( "acfarmorprop_ductility", function( _, _, value )

		local area = GetConVar( "acfarmorprop_area" ):GetFloat()

		-- don't bother recalculating if we don't have a valid ent
		if area == 0 then return end

		local ductility = math.Clamp( ( tonumber( value ) or 0 ) / 100, -0.8, 0.8 )
		local thickness = math.Clamp( GetConVar( "acfarmorprop_thickness" ):GetFloat(), 0.1, 5000 )
		local material  = GetConVar( "acfarmorprop_material" ):GetString() or "RHA"

		local mass		= CalcArmor( area, ductility, thickness , material )

		if mass > 50000 then
			mass = 50000
		elseif mass < 0.1 then
			mass = 0.1
		else
			return
		end

		thickness = mass * 1000 / ( area + area * ductility ) / 0.78
		RunConsoleCommand( "acfarmorprop_thickness", thickness )

	end )

	-- clamp ductility if the change in thickness puts mass out of range
	cvars.AddChangeCallback( "acfarmorprop_thickness", function( _, _, value )

		local area = GetConVar( "acfarmorprop_area" ):GetFloat()

		-- don't bother recalculating if we don't have a valid ent
		if area == 0 then return end

		local thickness = math.Clamp( tonumber( value ) or 0, 0.1, 5000 )
		local ductility = math.Clamp( GetConVar( "acfarmorprop_ductility" ):GetFloat() / 100, -0.8, 0.8 )
		local material  = GetConVar( "acfarmorprop_material" ):GetString() or "RHA"

		local mass		= CalcArmor( area, ductility, thickness , material )

		if mass > 50000 then
			mass = 50000
		elseif mass < 0.1 then
			mass = 0.1
		else
			return
		end

		ductility = -( 39 * area * thickness - mass * 50000 ) / ( 39 * area * thickness )
		RunConsoleCommand( "acfarmorprop_ductility", math.Clamp( ductility * 100, -80, 80 ) )

	end )

	-- Refresh Armor material info on menu
	cvars.AddChangeCallback( "acfarmorprop_material", function( _, _, value )

			if ToolPanel.panel then

				local MatData = ACE_GetMaterialData( value )

				--Use RHA if the choosen material is invalid or doesnt exist
				if not MatData then RunConsoleCommand( "acfarmorprop_material", "RHA" ) return end

				--Too redundant, ik, but looks like the unique way to have it working even when right clicking a prop
				ToolPanel.ComboMat:SetText(MatData.sname)

				ArmorPanelText( "ComboTitle", ToolPanel.panel, MatData.name , "DermaDefaultBold" )
				ArmorPanelText( "ComboDesc" , ToolPanel.panel, MatData.desc .. "\n" )

				ArmorPanelText( "ComboCurve", ToolPanel.panel, "Curve : " .. MatData.curve )
				ArmorPanelText( "ComboMass" , ToolPanel.panel, "Mass scale: " .. MatData.massMod .. "x RHA")
				ArmorPanelText( "ComboKE"	, ToolPanel.panel, "KE protection : " .. MatData.effectiveness .. "x RHA" )
				ArmorPanelText( "ComboCHE"  , ToolPanel.panel, "CHEMICAL protection : " .. (MatData.HEATeffectiveness or MatData.effectiveness) .. "x RHA" )
				ArmorPanelText( "ComboYear" , ToolPanel.panel, "Year : " .. (MatData.year or "unknown") )

			end
	end )
end

-- Apply settings to prop and store dupe info
local function ApplySettings( _, ent, data )

	if not SERVER then return end

	if data.Mass then
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then phys:SetMass( data.Mass ) end
		duplicator.StoreEntityModifier( ent, "mass", { Mass = data.Mass } )
	end

	if data.Ductility then
		ent.ACF = ent.ACF or {}
		ent.ACF.Ductility = data.Ductility / 100
		duplicator.StoreEntityModifier( ent, "acfsettings", { Ductility = data.Ductility } )
	end

	if data.Material then
		ent.ACF = ent.ACF or {}
		ent.ACF.Material = data.Material
		duplicator.StoreEntityModifier( ent, "acfsettings", { Material = data.Material } )
	end

end

duplicator.RegisterEntityModifier( "acfsettings", ApplySettings )
duplicator.RegisterEntityModifier( "mass", ApplySettings )

-- Apply settings to prop
function TOOL:LeftClick( trace )

	local ent = trace.Entity

	if not IsValid( ent ) or ent:IsPlayer() then return false end
	if CLIENT then return true end
	if not ACF_Check( ent ) then return false end

	local ply		= self:GetOwner()

	local ductility = math.Clamp( self:GetClientNumber( "ductility" ), -80, 80 )
	local thickness = math.Clamp( self:GetClientNumber( "thickness" ), 0.1, 50000 )
	local material  = self:GetClientInfo( "material" ) or "RHA"

	local mass		= CalcArmor( ent.ACF.Area, ductility / 100, thickness , material)

	ApplySettings( ply, ent, { Mass = mass , Ductility = ductility, Material = material} )

	-- this invalidates the entity and forces a refresh of networked armor values
	self.AimEntity = nil

	return true

end

-- Suck settings from prop
function TOOL:RightClick( trace )

	local ent = trace.Entity

	if not IsValid( ent ) or ent:IsPlayer() then return false end
	if CLIENT then return true end
	if not ACF_Check( ent ) then return false end

	local ply = self:GetOwner()

	ply:ConCommand( "acfarmorprop_ductility " .. (ent.ACF.Ductility or 0) * 100 )
	ply:ConCommand( "acfarmorprop_thickness " .. ent.ACF.MaxArmour )
	ply:ConCommand( "acfarmorprop_material " .. (ent.ACF.Material or "RHA") )

	-- this invalidates the entity and forces a refresh of networked armor values
	self.AimEntity = nil

	return true

end

-- Total up mass of constrained ents
function TOOL:Reload( trace )

	local ent = trace.Entity

	if not IsValid( ent ) or ent:IsPlayer() then return false end
	if CLIENT then return true end

	local data		= ACF_CalcMassRatio(ent, true)

	local total		= ent.acftotal
	local phystotal	= ent.acfphystotal
	local parenttotal	= ent.acftotal - ent.acfphystotal
	local physratio	= 100 * ent.acfphystotal / ent.acftotal

	local power		= data.Power
	local fuel		= data.Fuel

	local GeneralTb	= { data.MaterialMass, data.MaterialPercent }
	local ToJSON		= util.TableToJSON( GeneralTb )
	local Compressed	= util.Compress(ToJSON)

	net.Start("ACE_ArmorSummary")
		net.WriteFloat(total)
		net.WriteFloat(phystotal)
		net.WriteFloat(parenttotal)
		net.WriteFloat(physratio)
		net.WriteFloat(power)
		net.WriteFloat(fuel)

		net.WriteData(Compressed)
	net.Send(self:GetOwner())

end

if CLIENT then
	net.Receive("ACE_ArmorSummary", function()

		local Color1 = Color(175,0,0)
		local Color2 = Color(255,191,0)
		local Color3 = Color(255,255,100)
		local Color4 = Color(255,191,0)

		local total		= math.Round( net.ReadFloat(), 1 )
		local phystotal	= math.Round( net.ReadFloat(), 1 )
		local parenttotal	= math.Round( net.ReadFloat(), 1 )
		local physratio	= math.Round( net.ReadFloat(), 1 )
		local power		= net.ReadFloat() -- Note: intentional
		local fuel		= math.Round( net.ReadFloat(), 1 )
		local bonus		= (fuel > 0 and 1.25 or 1)

		local hpton		= math.Round( power * bonus / (total / 1000), 1 )
		local hasfuel	= fuel == 1 and " with fuel (25% boost)" or fuel == 2 and "" or " (no fuel)"
		local Compressed	= net.ReadData(640)
		local Decompress	= util.Decompress(Compressed)
		local FromJSON	= util.JSONToTable( Decompress )

		local Sep = "\n"

		local Tabletxt	= {}

		local Title		= { Color2, "<|",Color1, "|============|", Color2, "[- Contraption Summary -]", Color1, "|============|",Color2, "|>" .. Sep }
		local TMass		= { Color4, "- Total Mass: ", Color3, "" .. total, Color4, " kgs / @ ", Color3, "" .. math.Truncate(total / 1000,2), Color4, " tons" .. Sep }
		local TMass2		= { Color4, "- Mass Ratio: ",Color3, "" .. phystotal, Color4, " kgs physical, ", Color3, "" .. parenttotal, Color4, " kgs parented / ", Color3, physratio .. "%", Color4, " physical )" .. Sep }
		local Engine		= { Color4, "- Total Power: ", Color3, "" .. math.Round(power * bonus, 1), Color4," hp / ",Color3, "" .. hpton, Color4, " hp/ton" .. hasfuel .. Sep }
		local ArmorComp1	= { Color4, "- Composition: " .. Sep }

		Tabletxt = table.Add(Tabletxt, Title)
		Tabletxt = table.Add(Tabletxt,TMass)
		Tabletxt = table.Add(Tabletxt,TMass2)
		Tabletxt = table.Add(Tabletxt,Engine)
		Tabletxt = table.Add(Tabletxt,ArmorComp1)

		for material, mass in pairs( FromJSON[1] ) do

			local Percent	=  math.Round( FromJSON[2][material] * 100 ,1)
			local TbStr	= { Color4, "> " .. material .. " @ ", Color3, "" .. math.Round(mass,1), Color4, " kgs (", Color3, Percent .. "%", Color4, ")" .. Sep }

			Tabletxt = table.Add(Tabletxt,TbStr)

		end

		chat.AddText(unpack(Tabletxt))

	end)
end

function TOOL:Think()

	if CLIENT then return end

	local ply	= self:GetOwner()

	local tr	= util.GetPlayerTrace(ply)
	tr.mins	= Vector(0,0,0)
	tr.maxs	= tr.mins
	local trace = util.TraceHull(tr)

	local ent = trace.Entity
	if ent == self.AimEntity then return end

	if ACF_Check( ent ) then

		local Mat = ent.ACF.Material or "RHA"
		local MatData =  ACE_GetMaterialData( Mat )

		if not MatData then return end

		ply:ConCommand( "acfarmorprop_area " .. ent.ACF.Area )
		self.Weapon:SetNWFloat( "WeightMass", ent:GetPhysicsObject():GetMass() )
		self.Weapon:SetNWFloat( "HP", ent.ACF.Health )
		self.Weapon:SetNWFloat( "Armour", ent.ACF.Armour )
		self.Weapon:SetNWFloat( "MaxHP", ent.ACF.MaxHealth )
		self.Weapon:SetNWFloat( "MaxArmour", ent.ACF.MaxArmour )
		self.Weapon:SetNWString( "Material", MatData.sname or "RHA")

	else

		ply:ConCommand( "acfarmorprop_area 0" )
		self.Weapon:SetNWFloat( "WeightMass", 0 )
		self.Weapon:SetNWFloat( "HP", 0 )
		self.Weapon:SetNWFloat( "Armour", 0 )
		self.Weapon:SetNWFloat( "MaxHP", 0 )
		self.Weapon:SetNWFloat( "MaxArmour", 0 )
		self.Weapon:SetNWString( "Material", "RHA" )
	end

	self.AimEntity = ent

end

function TOOL:DrawHUD()

	if not CLIENT then return end

	local ent = self:GetOwner():GetEyeTrace().Entity
	if not IsValid( ent ) or ent:IsPlayer() then return end

	local curmass	= self.Weapon:GetNWFloat( "WeightMass" )
	local curarmor	= self.Weapon:GetNWFloat( "MaxArmour" )
	local curhealth	= self.Weapon:GetNWFloat( "MaxHP" )
	local material	= self.Weapon:GetNWString( "Material" )

	local area		= GetConVar( "acfarmorprop_area" ):GetFloat()
	local ductility	= GetConVar( "acfarmorprop_ductility" ):GetFloat()
	local thickness	= GetConVar( "acfarmorprop_thickness" ):GetFloat()
	local mat		= GetConVar( "acfarmorprop_material" ):GetString() or "RHA"

	local MatData	= ACE_GetMaterialData( mat )

	local mass, armor, health = CalcArmor( area, ductility / 100, thickness , mat)
	mass = math.min( mass, 50000 )

	local text = ""
	text = text .. ACFTranslation.ArmorPropertiesText[14] .. math.Round( curmass, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[15] .. math.Round( curarmor, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[16] .. math.Round( curhealth, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[17] .. material

	text = text .. ACFTranslation.ArmorPropertiesText[18] .. math.Round( mass, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[15] .. math.Round( armor, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[16] .. math.Round( health, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[17] .. MatData.sname

	local pos = ent:WorldSpaceCenter()
	AddWorldTip( nil, text, nil, pos, nil )

end

function TOOL:DrawToolScreen()

	if not CLIENT then return end

	local Health	= math.Round( self.Weapon:GetNWFloat( "HP", 0 ), 2 )
	local MaxHealth = math.Round( self.Weapon:GetNWFloat( "MaxHP", 0 ), 2 )
	local Armour	= math.Round( self.Weapon:GetNWFloat( "Armour", 0 ), 2 )
	local MaxArmour = math.Round( self.Weapon:GetNWFloat( "MaxArmour", 0 ), 2 )

	local HealthTxt = Health .. "/" .. MaxHealth
	local ArmourTxt = Armour .. "/" .. MaxArmour

	cam.Start2D()
		render.Clear( 0, 0, 0, 0 )

		surface.SetMaterial( Material( "models/props_combine/combine_interface_disp" ) )
		surface.SetDrawColor( color_white )
		surface.DrawTexturedRect( 0, 0, 256, 256 )
		surface.SetFont( "Torchfont" )

		-- header
		draw.SimpleTextOutlined( ACFTranslation.ArmorPropertiesText[19], "Torchfont", 128, 30, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, color_black )

		-- armor bar
		draw.RoundedBox( 6, 10, 83, 236, 64, Color( 200, 200, 200, 255 ) )
		if Armour ~= 0 and MaxArmour ~= 0 then
			draw.RoundedBox( 6, 15, 88, Armour / MaxArmour * 226, 54, Color( 0, 0, 200, 255 ) )
		end

		draw.SimpleTextOutlined( ACFTranslation.ArmorPropertiesText[20], "Torchfont", 128, 100, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, color_black )
		draw.SimpleTextOutlined( ArmourTxt, "Torchfont", 128, 130, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, color_black )

		-- health bar
		draw.RoundedBox( 6, 10, 183, 236, 64, Color( 200, 200, 200, 255 ) )
		if Health ~= 0 and MaxHealth ~= 0 then
			draw.RoundedBox( 6, 15, 188, Health / MaxHealth * 226, 54, Color( 200, 0, 0, 255 ) )
		end

		draw.SimpleTextOutlined( ACFTranslation.ArmorPropertiesText[21], "Torchfont", 128, 200, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, color_black )
		draw.SimpleTextOutlined( HealthTxt, "Torchfont", 128, 230, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, color_black )
	cam.End2D()

end
