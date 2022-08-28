
function ACF_CanEmitLight(lightSize)

	local minLightSize = GetConVar("ACFM_MissileLights"):GetFloat()
	
	if minLightSize == 0 then return false end
	if lightSize == 0 then return false end

	return true
end

function ACF_RenderLight(idx, lightSize, colour, pos, duration)

	if not ACF_CanEmitLight(lightSize) then return end
	
	local dlight = DynamicLight( idx )

	if dlight then
		
		local size 			= lightSize
		local c 			= colour or Color(255, 128, 48)
		local Brightness 	= size * 0.00018

		dlight.Pos 			= pos
		dlight.r 			= c.r
		dlight.g 			= c.g
		dlight.b 			= c.b
		dlight.Brightness 	= Brightness
		dlight.Decay 		= 1000/0.1
		dlight.Size 		= size
		dlight.DieTime 		= CurTime() + (duration or 0.05)

	end
end



