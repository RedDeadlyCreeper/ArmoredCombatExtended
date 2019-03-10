
local ClassName = "Timed"


ACF = ACF or {}
ACF.Fuse = ACF.Fuse or {}

local this = ACF.Fuse[ClassName] or inherit.NewSubOf(ACF.Fuse.Contact)
ACF.Fuse[ClassName] = this

---



this.Name = ClassName

-- Time to explode, begins ticking after configuration.
this.Timer = 10


this.desc = "This fuse triggers upon direct contact, or when the timer ends.\nDelay in seconds."


-- Configuration information for things like acfmenu.
this.Configurable = table.Copy(this:super().Configurable)

local configs = this.Configurable
configs[#configs + 1] = 
{
    Name = "Timer",             -- name of the variable to change
    DisplayName = "Trigger Delay",   -- name displayed to the user
    CommandName = "Tm",         -- shorthand name used in console commands
    
    Type = "number",            -- lua type of the configurable variable
    Min = 0,                    -- number specific: minimum value
    Max = 30                    -- number specific: maximum value
    
    -- in future if needed: min/max getter function based on munition type.  useful for modifying radar cones?
}




function this:GetDetonate(missile, guidance)
	return self:IsArmed() and self.TimeStarted + self.Timer <= CurTime()
end



function this:GetDisplayConfig()
	return 
	{
		["Primer"] = tostring(math.Round(self.Primer, 1)) .. " s",
		["Timer"] = tostring(math.Round(self.Timer, 1)) .. " s"
	}
end