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

	local roundID = self:GetNetworkedString("RoundId", "Unknown ID")
	local roundType = self:GetNetworkedString("RoundType", "Unknown Type")
	local filler = self:GetNetworkedFloat("FillerVol", 0)

	local blast = (filler / 2) ^ 0.33 * 5 * 10 * 0.2
	
	local ret = {}
	ret[#ret+1] = roundID
	ret[#ret+1] = " ("
	ret[#ret+1] = roundType
	ret[#ret+1] = ")\n"
	ret[#ret+1] = filler
	ret[#ret+1] = " cm^3 HE Filler\n"
	ret[#ret+1] = blast
	ret[#ret+1] = " m Blast Radius"
	
	return table.concat(ret)
end



