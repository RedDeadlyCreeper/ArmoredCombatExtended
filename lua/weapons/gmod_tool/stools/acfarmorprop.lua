
local cat = ((ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction");

TOOL.Category	= cat
TOOL.Name		= "#tool.acfarmorprop.name"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["thickness"] = 1
TOOL.ClientConVar["ductility"] = 0
if ACF.EnableNewContent and ACF.Year >= 1955 then
TOOL.ClientConVar["material"] = 0
end
CreateClientConVar( "acfarmorprop_area", 0, false, true ) -- we don't want this one to save

-- Calculates mass, armor, and health given prop area and desired ductility and thickness.
local function CalcArmor( Area, Ductility, Thickness, Material )
	local testMaterial = 0
	local massMod = 1
	if ACF.EnableNewContent and ACF.Year >= 1955 then
	testMaterial = math.floor(Material + 0.5)
	massMod = 1
	
	if testMaterial == 0 then --RHA	
		massMod = 1
	elseif testMaterial == 1 then --Cast
		massMod = 2
	elseif testMaterial == 2 then --Ceramic
		massMod = 0.8
	elseif testMaterial == 3 then--Rubber
		massMod = 0.2
	elseif testMaterial == 4 then --ERA
		massMod = 2
	elseif testMaterial == 5 then --Aluminum
		massMod = 0.221
	elseif testMaterial == 6 then --Textolite
	massMod = 0.35
	else --Overflow
		massMod = 1
	end
	end
	
	local mass =  Area * ( 1 + Ductility ) ^ 0.5 * Thickness * 0.00078 * massMod
	local armor = ACF_CalcArmor( Area, Ductility, mass / massMod )
	local health = ( Area + Area * Ductility ) / ACF.Threshold
	
	return mass, armor, health
	
end

if CLIENT then

	language.Add( "tool.acfarmorprop.name", ACFTranslation.ArmorPropertiesText[1] )
	language.Add( "tool.acfarmorprop.desc", ACFTranslation.ArmorPropertiesText[2] )
	language.Add( "tool.acfarmorprop.0", ACFTranslation.ArmorPropertiesText[3] )
--	print(ACFTranslation.ArmorPropertiesText[1])
	function TOOL.BuildCPanel( panel )
		
		local Presets = vgui.Create( "ControlPresets" )
			Presets:AddConVar( "acfarmorprop_thickness" )
			Presets:AddConVar( "acfarmorprop_ductility" )
			if ACF.EnableNewContent and ACF.Year >= 1955 then
			Presets:AddConVar( "acfarmorprop_material" )
			end
			Presets:SetPreset( "acfarmorprop" )
		panel:AddItem( Presets )
		
		panel:NumSlider( ACFTranslation.ArmorPropertiesText[4], "acfarmorprop_thickness", 1, 5000 )
		panel:ControlHelp( ACFTranslation.ArmorPropertiesText[5] )
		
		panel:NumSlider( ACFTranslation.ArmorPropertiesText[6], "acfarmorprop_ductility", -80, 80 )
		panel:ControlHelp( ACFTranslation.ArmorPropertiesText[7] )
		if ACF.EnableNewContent and ACF.Year >= 1955 then		
		panel:NumSlider( ACFTranslation.ArmorPropertiesText[8], "acfarmorprop_material", 0, 6, 0 )
		panel:ControlHelp( ACFTranslation.ArmorPropertiesText[9] )
		end
	end
	
	surface.CreateFont( "Torchfont", { size = 40, weight = 1000, font = "arial" } )
	
	-- clamp thickness if the change in ductility puts mass out of range
	cvars.AddChangeCallback( "acfarmorprop_ductility", function( cvar, oldvalue, value )
	
		local area = GetConVarNumber( "acfarmorprop_area" )
		
		-- don't bother recalculating if we don't have a valid ent
		if area == 0 then return end
		
		local ductility = math.Clamp( ( tonumber( value ) or 0 ) / 100, -0.8, 0.8 )
		local thickness = math.Clamp( GetConVarNumber( "acfarmorprop_thickness" ), 0.1, 5000 )
		local material = 0
		if ACF.EnableNewContent and ACF.Year >= 1955 then
		local material = math.Clamp( math.floor(GetConVarNumber( "acfarmorprop_material" )+0.5), 0, 4 )
		end
		local mass = CalcArmor( area, ductility, thickness , material)
		
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
	cvars.AddChangeCallback( "acfarmorprop_thickness", function( cvar, oldvalue, value )
		
		local area = GetConVarNumber( "acfarmorprop_area" )
		
		-- don't bother recalculating if we don't have a valid ent
		if area == 0 then return end
		
		local thickness = math.Clamp( tonumber( value ) or 0, 0.1, 5000 )
		local ductility = math.Clamp( GetConVarNumber( "acfarmorprop_ductility" ) / 100, -0.8, 0.8 )
		local material = 0
		if ACF.EnableNewContent and ACF.Year >= 1955 then
		material = math.Clamp( math.floor(GetConVarNumber( "acfarmorprop_material" )+0.5), 0, 6 )
		end
		local mass = CalcArmor( area, ductility, thickness , material )
		
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
	
	cvars.AddChangeCallback( "acfarmorprop_material", function( cvar, oldvalue, value )
		
		local area = GetConVarNumber( "acfarmorprop_area" )
		
		-- don't bother recalculating if we don't have a valid ent
		if area == 0 then return end
		
		local thickness = math.Clamp( GetConVarNumber( "acfarmorprop_thickness" ), 0.1, 5000 )
		local ductility = math.Clamp( GetConVarNumber( "acfarmorprop_ductility" ) / 100, -0.8, 0.8 )
		local material = 0
		if ACF.EnableNewContent and ACF.Year >= 1955 then
		material = math.Clamp( math.floor(tonumber( value )+0.5 or 0), 0, 6 )
		end

		RunConsoleCommand( "acfarmorprop_material", math.floor(material+0.5))
		
	end )
	
end

-- Apply settings to prop and store dupe info
local function ApplySettings( ply, ent, data )

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
	
	if ACF.EnableNewContent and ACF.Year >= 1955 then	
	if data.Material then
		ent.ACF = ent.ACF or {}
		ent.ACF.Material = data.Material
		duplicator.StoreEntityModifier( ent, "acfsettings", { Material = data.Material } )
	end
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
	
	local ply = self:GetOwner()

	
	local ductility = math.Clamp( self:GetClientNumber( "ductility" ), -80, 80 )
	local thickness = math.Clamp( self:GetClientNumber( "thickness" ), 0.1, 50000 )
	
	local material = 0
	if ACF.EnableNewContent and ACF.Year >= 1955 then
	material = math.Clamp( math.floor(self:GetClientNumber( "material" )+0.5), 0, 6 )
	end
	
	local testMaterial = math.floor(material + 0.5)
	local massMod = 1
	if testMaterial == 0 then --RHA	
		massMod = 1
	elseif testMaterial == 1 then --Cast
		massMod = 1.5
	elseif testMaterial == 2 then --Ceramic
		massMod = 0.75
	elseif testMaterial == 3 then--Rubber
		massMod = 0.2
	elseif testMaterial == 4 then --ERA
		massMod = 2
	elseif testMaterial == 5 then --Aluminum
		massMod = 0.35
	elseif testMaterial == 5 then --Textolite
		massMod = 0.2
	else
		massMod = 1.3
	end
	
	local mass = CalcArmor( ent.ACF.Aera, ductility / 100, thickness , material)
	
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
	ply:ConCommand( "acfarmorprop_material " .. (ent.ACF.Material or 0) )
	
	-- this invalidates the entity and forces a refresh of networked armor values
	self.AimEntity = nil
	
	return true
	
end

-- Total up mass of constrained ents
function TOOL:Reload( trace )
	
	local ent = trace.Entity
	
	if not IsValid( ent ) or ent:IsPlayer() then return false end
	if CLIENT then return true end
	
	local data = ACF_CalcMassRatio(ent, true)
	
	local total = math.Round( ent.acftotal, 1 )
	local phystotal = math.Round( ent.acfphystotal, 1 )
	local parenttotal = math.Round( ent.acftotal - ent.acfphystotal, 1 )
	local physratio = math.Round(100 * ent.acfphystotal / ent.acftotal, 1)
	
	local pwr = "\n"
	if data.Fuel == 2 then
		pwr = pwr .. math.Round(data.Power * 1.25 / (ent.acftotal/1000), 1) .. " hp/ton @ " .. math.Round(data.Power * 1.25) .. " hp"
	else
		pwr = pwr .. math.Round(data.Power / (ent.acftotal/1000), 1) .. " hp/ton @ " .. math.Round(data.Power) .. " hp"
		if data.Fuel == 1 then
			pwr = pwr .. "\n" .. math.Round(data.Power * 1.25 / (ent.acftotal/1000), 1) .. " hp/ton @ " .. math.Round(data.Power * 1.25) .. " hp "..ACFTranslation.ArmorPropertiesText[10]
		end
	end
	
	self:GetOwner():ChatPrint( ACFTranslation.ArmorPropertiesText[11] .. total .. " kg  ("..phystotal.." kg "..ACFTranslation.ArmorPropertiesText[12]..", "..parenttotal.." kg "..ACFTranslation.ArmorPropertiesText[13]..", "..physratio.."% "..ACFTranslation.ArmorPropertiesText[12]..")"..pwr )
	
end

function TOOL:Think()
	
	if not SERVER then return end
	
	local ply = self:GetOwner()
	local ent = ply:GetEyeTrace().Entity
	if ent == self.AimEntity then return end
	
	if ACF_Check( ent ) then
		
		ply:ConCommand( "acfarmorprop_area " .. ent.ACF.Aera )
		self.Weapon:SetNWFloat( "WeightMass", ent:GetPhysicsObject():GetMass() )
		self.Weapon:SetNWFloat( "HP", ent.ACF.Health )
		self.Weapon:SetNWFloat( "Armour", ent.ACF.Armour )
		self.Weapon:SetNWFloat( "MaxHP", ent.ACF.MaxHealth )
		self.Weapon:SetNWFloat( "MaxArmour", ent.ACF.MaxArmour )
		if ACF.EnableNewContent and ACF.Year >= 1955 then
		self.Weapon:SetNWFloat( "Material", (ent.ACF.Material or 0))
		else
		self.Weapon:SetNWFloat( "Material", 0 )
		end
	else
	
		ply:ConCommand( "acfarmorprop_area 0" )
		self.Weapon:SetNWFloat( "WeightMass", 0 )
		self.Weapon:SetNWFloat( "HP", 0 )
		self.Weapon:SetNWFloat( "Armour", 0 )
		self.Weapon:SetNWFloat( "MaxHP", 0 )
		self.Weapon:SetNWFloat( "MaxArmour", 0 )
		self.Weapon:SetNWFloat( "Material", 0 )
	end
	
	self.AimEntity = ent
	
end

function TOOL:DrawHUD()
	
	if not CLIENT then return end
	
	local ent = self:GetOwner():GetEyeTrace().Entity
	if not IsValid( ent ) or ent:IsPlayer() then return end
	
	local curmass = self.Weapon:GetNWFloat( "WeightMass" )
	local curarmor = self.Weapon:GetNWFloat( "MaxArmour" )
	local curhealth = self.Weapon:GetNWFloat( "MaxHP" )
	local curmat = self.Weapon:GetNWFloat( "Material" )
	
	local area = GetConVarNumber( "acfarmorprop_area" )
	local ductility = GetConVarNumber( "acfarmorprop_ductility" )
	local thickness = GetConVarNumber( "acfarmorprop_thickness" )
	local material = 0
	if ACF.EnableNewContent and ACF.Year >= 1955 then
	material = GetConVarNumber( "acfarmorprop_material" )
	end
	local mass, armor, health = CalcArmor( area, ductility / 100, thickness , material)
	mass = math.min( mass, 50000 )
	
	local text = ACFTranslation.ArmorPropertiesText[14] .. math.Round( curmass, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[15] .. math.Round( curarmor, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[16] .. math.Round( curhealth, 2 )
	if ACF.EnableNewContent and ACF.Year >= 1955 then
	text = text .. ACFTranslation.ArmorPropertiesText[17] .. curmat 
	end
	text = text .. ACFTranslation.ArmorPropertiesText[18] .. math.Round( mass, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[15] .. math.Round( armor, 2 )
	text = text .. ACFTranslation.ArmorPropertiesText[16] .. math.Round( health, 2 )
	if ACF.EnableNewContent and ACF.Year >= 1955 then
	text = text .. ACFTranslation.ArmorPropertiesText[17] .. material 
	end
	
	local pos = ent:GetPos()
	AddWorldTip( nil, text, nil, pos, nil )
	
end

function TOOL:DrawToolScreen( w, h )
	
	if not CLIENT then return end
	
	local Health = math.Round( self.Weapon:GetNWFloat( "HP", 0 ), 2 )
	local MaxHealth = math.Round( self.Weapon:GetNWFloat( "MaxHP", 0 ), 2 )
	local Armour = math.Round( self.Weapon:GetNWFloat( "Armour", 0 ), 2 )
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
