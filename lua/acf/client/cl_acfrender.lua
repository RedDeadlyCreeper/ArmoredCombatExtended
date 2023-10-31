
---------------- ACE Damage Material rendering ----------------
do
	local Damaged = {
		CreateMaterial("ACF_Damaged1", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged1"}),
		CreateMaterial("ACF_Damaged2", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged2"}),
		CreateMaterial("ACF_Damaged3", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged3"})
	}

	hook.Add("PostDrawOpaqueRenderables", "ACF_RenderDamage", function()
		if not ACF_HealthRenderList then return end
		cam.Start3D( EyePos(), EyeAngles() )
			for k,ent in pairs( ACF_HealthRenderList ) do

				--In case that this is missing
				ent.ACF_HelathPercent = ent.ACF_HelathPercent or 1

				if IsValid(ent) then
					render.ModelMaterialOverride( ent.ACF_Material )
					render.SetBlend( math.Clamp(1 - ent.ACF_HelathPercent,0,0.8) )
					ent:DrawModel()
				elseif ACF_HealthRenderList then
					table.remove(ACF_HealthRenderList,k)
				end
			end
			render.ModelMaterialOverride()
			render.SetBlend(1)
		cam.End3D()
	end)

	net.Receive("ACF_RenderDamage", function()

		local Table = net.ReadTable()

			if not Table then return end

			for _, v in ipairs( Table ) do

				if not v.ID then break end

				local ent, Health, MaxHealth = ents.GetByIndex( v.ID ), v.Health, v.MaxHealth
				if not IsValid(ent) then return end
				if Health ~= MaxHealth then
					ent.ACF_Health = Health
					ent.ACF_MaxHealth = MaxHealth
					ent.ACF_HelathPercent = (Health / MaxHealth)
					if ent.ACF_HelathPercent > 0.7 then
						ent.ACF_Material = Damaged[1]
					elseif ent.ACF_HelathPercent > 0.3 then
						ent.ACF_Material = Damaged[2]
					elseif ent.ACF_HelathPercent <= 0.3 then
						ent.ACF_Material = Damaged[3]
					end
					ACF_HealthRenderList = ACF_HealthRenderList or {}
					ACF_HealthRenderList[ent:EntIndex()] = ent
				else
					if ACF_HealthRenderList then
						if #ACF_HealthRenderList <= 1 then
							ACF_HealthRenderList = nil
						else
							table.remove(ACF_HealthRenderList,ent:EntIndex())
						end
						if ent.ACF then
							ent.ACF.Health = nil
							ent.ACF.MaxHealth = nil
						end
					end
				end
			end
	end)
end
---------------- ACE Light renders ----------------
do
	local function CanEmitLight(lightSize)

		local minLightSize = GetConVar("acf_enable_lighting"):GetFloat()

		if minLightSize == 0 then return false end
		if lightSize == 0 then return false end

		return true
	end

	--[[
		ACF_RenderLight(idx, lightSize, colour, pos, duration)

		- idx		: the index of this light. Use the entity index, or 0 for the world.
		- lightSize	: sets the scale size factor of the light.
		- colour	: the color of this light
		- pos 		: the position
		- duration	: the duration, in seconds, that this light will stand before turning off.
	]]
	function ACF_RenderLight(idx, lightSize, colour, pos, duration)
		if not CanEmitLight(lightSize) then return end

		local dlight = DynamicLight( idx )
		if dlight then

			local c             = colour or Color(255, 128, 48)
			local Brightness    = lightSize * 0.00018

			dlight.Pos          = pos
			dlight.r            = c.r
			dlight.g            = c.g
			dlight.b            = c.b
			dlight.Brightness   = Brightness
			dlight.Decay        = 1000 / 0.1
			dlight.Size         = lightSize
			dlight.DieTime      = CurTime() + (duration or 0.05)

		end
	end
end

