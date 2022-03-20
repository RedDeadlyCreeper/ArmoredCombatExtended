
local cat = ((ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction");

TOOL.Category		= cat
TOOL.Name			= "#Tool.acfmenu.listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = "gun"
TOOL.ClientConVar[ "id" ] = "7.62mmMG"

TOOL.ClientConVar[ "data1" ] = "7.62mmMG"
TOOL.ClientConVar[ "data2" ] = "AP"
TOOL.ClientConVar[ "data3" ] = 0
TOOL.ClientConVar[ "data4" ] = 0
TOOL.ClientConVar[ "data5" ] = 0
TOOL.ClientConVar[ "data6" ] = 0
TOOL.ClientConVar[ "data7" ] = 0
TOOL.ClientConVar[ "data8" ] = 0
TOOL.ClientConVar[ "data9" ] = 0
TOOL.ClientConVar[ "data10" ] = 0
TOOL.ClientConVar[ "data11" ] = 0
TOOL.ClientConVar[ "data12" ] = 0
TOOL.ClientConVar[ "data13" ] = 0
TOOL.ClientConVar[ "data14" ] = 0
TOOL.ClientConVar[ "data15" ] = 0

cleanup.Register( "acfmenu" )

if CLIENT then
	language.Add( "Tool.acfmenu.listname", ACFTranslation.ACFMenuTool[1] )
	language.Add( "Tool.acfmenu.name", ACFTranslation.ACFMenuTool[2] )
	language.Add( "Tool.acfmenu.desc", ACFTranslation.ACFMenuTool[3] )
	language.Add( "Tool.acfmenu.0", ACFTranslation.ACFMenuTool[4] )
	language.Add( "Tool.acfmenu.1", ACFTranslation.ACFMenuTool[5] )
	
	language.Add( "Undone_ACF Entity", ACFTranslation.ACFMenuTool[6] )
	language.Add( "Undone_acf_engine",ACFTranslation.ACFMenuTool[7] )
	language.Add( "Undone_acf_gearbox", ACFTranslation.ACFMenuTool[8] )
	language.Add( "Undone_acf_ammo", ACFTranslation.ACFMenuTool[9] )
	language.Add( "Undone_acf_gun", ACFTranslation.ACFMenuTool[10] )
	language.Add( "SBoxLimit_acf_gun", ACFTranslation.ACFMenuTool[11] )
	language.Add( "SBoxLimit_acf_rack", ACFTranslation.ACFMenuTool[12] )
	language.Add( "SBoxLimit_acf_ammo", ACFTranslation.ACFMenuTool[13] )
	language.Add( "SBoxLimit_acf_sensor", ACFTranslation.ACFMenuTool[14] )

	/*------------------------------------
		BuildCPanel
	------------------------------------*/
	function TOOL.BuildCPanel( CPanel )
	
		local pnldef_ACFmenu = vgui.RegisterFile( "acf/client/cl_acfmenu_gui.lua" )
		
		// create
		local DPanel = vgui.CreateFromTable( pnldef_ACFmenu )
		CPanel:AddPanel( DPanel )
	
	end
end

-- Spawn/update functions
function TOOL:LeftClick( trace )

	if CLIENT then return true end
	if not IsValid( trace.Entity ) and not trace.Entity:IsWorld() then return false end
	
	local ply = self:GetOwner()
	local Type = self:GetClientInfo( "type" )
	local Id = self:GetClientInfo( "id" )
	
	local TypeId = ACF.Weapons[Type][Id]
	if not TypeId then return false end
	
	local DupeClass = duplicator.FindEntityClass( TypeId["ent"] ) 
	
	if DupeClass then
		local ArgTable = {}
			ArgTable[2] = trace.HitNormal:Angle():Up():Angle() 
			ArgTable[1] = trace.HitPos + trace.HitNormal*50
			debugoverlay.Cross(trace.HitPos, 5, 5, Color(255,0,0), true)
			debugoverlay.Cross(ArgTable[1], 5, 5, Color(255,0,0), true)
			
		local ArgList = list.Get("ACFCvars")
		
		-- Reading the list packaged with the ent to see what client CVar it needs
		for Number, Key in pairs( ArgList[ACF.Weapons[Type][Id]["ent"]] ) do
			ArgTable[ Number+2 ] = self:GetClientInfo( Key )
		end
		
		if trace.Entity:GetClass() == ACF.Weapons[Type][Id]["ent"] and trace.Entity.CanUpdate then
			table.insert( ArgTable, 1, ply )
			local success, msg = trace.Entity:Update( ArgTable )
			ACF_SendNotify( ply, success, msg )
		else
			-- Using the Duplicator entity register to find the right factory function
			local Ent = DupeClass.Func( ply, unpack( ArgTable ) )
			if not IsValid(Ent) then ACF_SendNotify(ply, false, ACFTranslation.ACFMenuTool[15]) return false end
			Ent:Activate()
			--Ent:GetPhysicsObject():Wake()
			Ent:DropToFloor()
			Ent:GetPhysicsObject():EnableMotion( false )
			
			undo.Create( ACF.Weapons[Type][Id]["ent"] )
				undo.AddEntity( Ent )
				undo.SetPlayer( ply )
			undo.Finish()
		end
			
		return true
	else
		print(ACFTranslation.ACFMenuTool[16])
	end

end

-- Link/unlink functions
function TOOL:RightClick( trace )

	if not IsValid( trace.Entity ) then return false end
	if CLIENT then return true end
	
	local ply = self:GetOwner()
	
	if self:GetStage() == 0 and trace.Entity.IsMaster then
		self.Master = trace.Entity
		self:SetStage( 1 )
		return true
	elseif self:GetStage() == 1 then
		local success, msg
		
		if ply:KeyDown( IN_USE ) or ply:KeyDown( IN_SPEED ) then
			success, msg = self.Master:Unlink( trace.Entity )
		else
			success, msg = self.Master:Link( trace.Entity )
		end
		
		ACF_SendNotify( ply, success, msg )
		
		self:SetStage( 0 )
		self.Master = nil
		return true
	else
		return false
	end
	
end
