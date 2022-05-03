
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
        Name = "Primer",            -- name of the variable to change
        DisplayName = "Arming Delay (in seconds)",   -- name displayed to the user
        CommandName = "AD",         -- shorthand name used in console commands
        
        Type = "number",            -- lua type of the configurable variable
        Min = 0,                    -- number specific: minimum value
        MinConfig = "armdelay",     -- round specific override for minimum value
        Max = 10                    -- number specific: maximum value
        
        -- in future if needed: min/max getter function based on munition type.  useful for modifying radar cones?
    }
}


function this:Init()
	self.TimeStarted = nil
end


function this:IsArmed()
    return self.TimeStarted + self.Primer <= CurTime()
end


function this:Configure(missile, guidance)
    self.TimeStarted = CurTime()
end


-- Do nothing, projectiles auto-detonate on contact anyway.
function this:GetDetonate(missile, guidance)
	return false
end


function this:GetDisplayConfig()
	return {["Primer"] = math.Round(self.Primer, 1) .. " s"}
end