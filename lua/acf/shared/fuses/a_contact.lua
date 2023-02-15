
local ClassName = "Contact"


ACF = ACF or {}
ACF.Fuse = ACF.Fuse or {}

local this = ACF.Fuse[ClassName] or inherit.NewBaseClass()
ACF.Fuse[ClassName] = this

---



this.Name = ClassName

this.desc = "This fuse triggers upon direct contact against solid surfaces."

this.Primer = 0

-- Configuration information for things like acfmenu.
this.Configurable =
{
	{
		Name		= "Primer",						-- name of the variable to change
		DisplayName = "Arming Delay (in seconds)",	-- name displayed to the user
		CommandName = "AD",							-- shorthand name used in console commands

		Type		= "number",						-- lua type of the configurable variable
		Min		= 0,								-- number specific: minimum value
		MinConfig	= "armdelay",					-- round specific override for minimum value
		Max		= 10								-- number specific: maximum value

		-- in future if needed: min/max getter function based on munition type.  useful for modifying radar cones?
	}
}


function this:Init()
	self.TimeStarted = nil
end


function this:IsArmed()
	return self.TimeStarted + self.Primer <= CurTime()
end


function this:Configure()
	self.TimeStarted = CurTime()
end


-- Do nothing, projectiles auto-detonate on contact anyway.
function this:GetDetonate()
	return false
end

function this:PerformDetonation( missile, bdata, phys, pos )

	bdata.Owner = bdata.Owner or missile.Owner
	bdata.Pos	= pos + (missile.DetonateOffset or bdata.Flight:GetNormalized()) * 20

	bdata.NoOcc =	missile
	bdata.Gun	=	missile

	if bdata.Filter then bdata.Filter[#bdata.Filter + 1] = missile else bdata.Filter = {missile} end

	bdata.RoundMass = bdata.RoundMass or bdata.ProjMass
	bdata.ProjMass  = bdata.ProjMass or bdata.RoundMass

	bdata.HandlesOwnIteration = nil

	ACFM_BulletLaunch(bdata)

	missile:SetSolid(SOLID_NONE)
	phys:EnableMotion(false)

	missile:DoReplicatedPropHit(bdata)
	missile:SetNoDraw(true)
end

function this:GetDisplayConfig()
	return {["Arming delay"] = math.Round(self.Primer, 3) .. " s"}
end
