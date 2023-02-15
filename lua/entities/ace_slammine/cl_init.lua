include("shared.lua")

function ENT:Initialize()
	self.SpawnTime = CurTime()
end

function ENT:Draw()
	self:DrawModel()

	if CurTime() - self.SpawnTime < 2.5 then
		return
	end

	local ent = self

	local startpos = self:LocalToWorld(Vector(-2.25, 1.4, 0))
	local dir = ent:GetUp()
	local len = 300

	local tr = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir * len,
		filter = ent
	} )

	render.SetMaterial(Material("cable/redlaser"))
	render.DrawBeam(startpos, tr.HitPos, 1, 0, 1)
end

function ENT:Think()
end
