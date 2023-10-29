
local ACF_HealthRenderList = {}

local Damaged = {
	CreateMaterial("ACF_Damaged1", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged1"}),
	CreateMaterial("ACF_Damaged2", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged2"}),
	CreateMaterial("ACF_Damaged3", "VertexLitGeneric", {["$basetexture"] = "damaged/damaged3"})
}

hook.Add("PostDrawOpaqueRenderables", "ACF_RenderDamage", function()
	if not ACF_HealthRenderList then return end

	cam.Start3D( EyePos(), EyeAngles() )

		for k,ent in pairs( ACF_HealthRenderList ) do
			if not IsValid(ent) then
				ACF_HealthRenderList[k] = nil
				continue
			end

			render.ModelMaterialOverride( ent.ACF_Material )
			render.SetBlend( math.Clamp( 1 - ent.ACF_HealthPercent,0,0.8) )
			ent:DrawModel()

		end
		render.ModelMaterialOverride()
		render.SetBlend(1)
	cam.End3D()
end)

net.Receive("ACF_RenderDamage", function()

	local Index = net.ReadUInt(13)
	local Entity = ents.GetByIndex( Index )

	if IsValid(Entity) then

		local MaxHealth = net.ReadFloat()
		local Health = net.ReadFloat()

		if math.Round(MaxHealth) == math.Round(Health) then
			ACF_HealthRenderList[Entity:EntIndex()] = nil
			return
		end

		Entity.ACF_Health = Health
		Entity.ACF_MaxHealth = MaxHealth
		Entity.ACF_HealthPercent = (Health / MaxHealth)

		if Entity.ACF_HealthPercent > 0.7 then
			Entity.ACF_Material = Damaged[1]
		elseif Entity.ACF_HealthPercent > 0.3 then
			Entity.ACF_Material = Damaged[2]
		elseif Entity.ACF_HealthPercent <= 0.3 then
			Entity.ACF_Material = Damaged[3]
		end

		ACF_HealthRenderList[Entity:EntIndex()] = Entity

	end
end)
