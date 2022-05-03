
ACF = ACF or {}
ACF.Fuse = ACF.Fuse or {}

local ClassName = "Cluster"

local this = ACF.Fuse[ClassName] or inherit.NewSubOf(ACF.Fuse.Contact)
ACF.Fuse[ClassName] = this

---



this.Name = ClassName


this.Cluster = 2000


this.desc = "This fuse fires a beam directly ahead and releases bomblets when the beam hits something close-by. \n\nRemember that using this is a warcrime, so beware.\nDistance in inches."


-- Configuration information for things like acfmenu.
this.Configurable = this:super() and table.Copy(this:super().Configurable) or {}


local configs = this.Configurable
configs[#configs + 1] = 
{
    Name = "Cluster",           -- name of the variable to change
    DisplayName = "Distance",   -- name displayed to the user
    CommandName = "Ds",         -- shorthand name used in console commands
    
    Type = "number",            -- lua type of the configurable variable
    Min = 1,                    -- number specific: minimum value
    Max = 10000                 -- number specific: maximum value
    
    -- in future if needed: min/max getter function based on munition type.  useful for modifying radar cones?
}




-- Do nothing, projectiles auto-detonate on contact anyway.
function this:GetDetonate(missile, guidance)
	
    if not self:IsArmed() then return false end
    
    local missilePos = missile:GetPos()
    
    local tracedata = 
    {
        start = missilePos,
        endpos = missilePos + missile:GetForward() * self.Cluster,
        filter = missile.Filter or missile,
        mins = Vector(0,0,0),
        maxs = Vector(0,0,0)
    }
	local trace = util.TraceHull(tracedata)

    if IsValid(trace.Entity) and trace.Entity:GetClass() == 'acf_missile' then return false end

	return trace.Hit
    
end



function this:GetDisplayConfig()
	return 
	{
		["Primer"] = math.Round(self.Primer, 1) .. " s",
		["Distance"] = math.Round(self.Cluster / 39.37, 1) .. " m"
	}
end
