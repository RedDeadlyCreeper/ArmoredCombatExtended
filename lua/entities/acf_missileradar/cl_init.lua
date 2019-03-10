include ("shared.lua")



function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()	
    Wire_Render(self)
end



function ENT:DoNormalDraw()

	local drawbubble = self:GetNetworkedBool("VisInfo", false)
	
	if not drawbubble then return end
	if not (LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance(self:GetPos()) < 256) then return end
	
	local tooltip = self:GetOverlayText()
	
	if (tooltip ~= "") then
		AddWorldTip(self:EntIndex(), tooltip, 0.5, self:GetPos(), self)
	end
		
end



function ENT:GetOverlayText()
	
	local cone 	 = self:GetNWFloat("ConeDegs", 0)
	local range	 = self:GetNWFloat("Range", 0)
	local id 	 = self:GetNWString("Id", "")
	local status = self:GetNWString("Status", "")
	
	local ret = {}
	ret[#ret+1] = id
	
	if cone > 0 then
		ret[#ret+1] = "\nScanning angle: "
		ret[#ret+1] = math.Round(cone * 2, 2)
		ret[#ret+1] = " deg"
	end
	
	if range > 0 then
		ret[#ret+1] = "\nDetection range: "
		ret[#ret+1] = math.Round(range / 39.37 , 2)
		ret[#ret+1] = " m"
	end
	
	if status ~= "" then
		ret[#ret+1] = "\n("
		ret[#ret+1] = status
		ret[#ret+1] = ")"
	end
	
	return table.concat(ret)
end



function ACFRadarGUICreate( Table )
		
	acfmenupanel:CPanelText("Name", Table.name)
	
	acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
		acfmenupanel.CData.DisplayModel:SetModel( Table.model )
		acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250, 500, 250 ) )
		acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
		acfmenupanel.CData.DisplayModel:SetFOV( 20 )
		acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
		acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel, entity ) end
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
	
	acfmenupanel:CPanelText("ClassDesc", ACF.Classes.Radar[Table.class].desc)	
	acfmenupanel:CPanelText("GunDesc", Table.desc)
	acfmenupanel:CPanelText("ViewCone", "View cone : "..((Table.viewcone or 180) * 2).." degs")
	acfmenupanel:CPanelText("ViewRange", "View range : ".. (Table.range and (math.Round(Table.range / 39.37, 1) .. " m") or "unlimited"))
	acfmenupanel:CPanelText("Weight", "Weight : "..Table.weight.." kg")
	
	if Table.canparent then
		acfmenupanel:CPanelText("GunParentable", "\nThis radar can be parented.")
	end
	
	acfmenupanel.CustomDisplay:PerformLayout()
	
end

