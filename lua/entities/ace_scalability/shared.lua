DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName		= "Scalable Entity"
ENT.WireDebugName	= "Scalable Entity"

cleanup.Register("scalable entity")

function ENT:ConvertMeshToScale(MeshData, Scale)

	local NewMesh = table.Copy(MeshData)

	for _, vertexgroup in pairs(NewMesh) do

		for k, vertex in pairs(vertexgroup) do
			vertexgroup[k] = (istable(vertex) and vertex.pos or vertex) * Scale
		end

	end

	return NewMesh
end

-- A More shitty workaround to avoid certain tools can modify the physics of scalable ents. The hack below didnt work for some reason.
-- If there are more tools that can modify the physics, report it to add it here.
do

	local BlacklistedTools = {
		advresizer = true,
		proper_clipping_physicize = true,
	}

	function ENT:CanTool( _, _, mode, _, _ )

		if BlacklistedTools[mode] then return false end
		return true
	end

end

--[[
	-- Brought from ACF3
	-- Dirty, dirty hacking to prevent other addons initializing physics the wrong way
	-- Required for stuff like Proper Clipping resetting the physics object when clearing out physclips
	do
		local EntMeta = FindMetaTable("Entity")

		function ENT:PhysicsInit(Solid, Bypass, ...)
			if Bypass then
				return EntMeta.PhysicsInit(self, Solid, Bypass, ...)
			end

			local Init = self.FirstInit

			if not Init then
				self.FirstInit = true
			end

			if Init or CLIENT then
				self:Restore()

				return true
			end
		end
	end
]]
