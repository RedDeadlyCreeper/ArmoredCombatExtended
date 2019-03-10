
local ClassName = "Wire"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Dumb)
ACF.Guidance[ClassName] = this

---



this.Name = ClassName

-- An entity with a Position wire-output
this.InputSource = nil

-- Length of the guidance wire
this.WireLength = 15748			-- about 400m

-- Disables guidance when true
this.WireSnapped = false



this.desc = "This guidance package is controlled by the launcher, which reads a target-position and steers the munition towards it."



function this:Init()
	
end



-- Use this to make sure you don't alter the shared default filter unintentionally
function this:GetSeekFilter(class)
    if self.Filter == self.DefaultFilter then
        self.Filter = table.Copy(self.DefaultFilter)
    end
    
    return self.Filter
end




function this:Configure(missile)

    local launcher = missile.Launcher
    local outputs = launcher.Outputs
    
    if outputs then
        
        local names = self:GetNamedWireInputs(missile)
        
            
        if #names > 0 then
        
            self.InputSource = launcher
            self.InputNames = names
        
        else
            
            names = self:GetFallbackWireInputs(missile)
            
            if #names > 0 then
                self.InputSource = launcher
                self.InputNames = names
            end
            
        end
        
    end
    
    self.WireSnapped = false

end




function this:GetNamedWireInputs(missile)
    
    local launcher = missile.Launcher
    local outputs = launcher.Outputs
    
    local names = {}
        
    -- If we have a Position output, we're in business.
    if outputs.Position and outputs.Position.Type == "VECTOR" then
    
        names[#names+1] = "Position"
        
    end
    
    
    if outputs.Target and outputs.Target.Type == "ENTITY" then
    
        names[#names+1] = "Target"
    
    end
    
    
    return names
    
end




function this:GetFallbackWireInputs(missile)

    local launcher = missile.Launcher
    local outputs = launcher.Outputs

    -- To avoid ambiguity, only link if there's a single vector output.
    local foundOutput = nil
    
    for k, v in pairs(outputs) do
        if v.Type == "VECTOR" then
            if foundOutput then
                foundOutput = nil
                break
            else
                foundOutput = k
            end
        end
    end
    
    if foundOutput then
        return {foundOutput}
    end

end




function this:GetGuidance(missile)

	local launcher = self.InputSource

    if not IsValid(launcher) then
        return {}
    end

	local launcherPos = launcher:GetPos()
    local distMsl = missile:GetPos():DistToSqr(launcherPos)		-- We're using squared distance to optimise

    if distMsl > self.WireLength ^ 2 then
        self.WireSnapped = true
        return {TargetPos = nil}
    end

	
    local posVec = self:GetWireTarget()    

    if not posVec or type(posVec) != "Vector" or posVec == Vector() then
        return {TargetPos = nil} 
	else
		local distTrgt = posVec:DistToSqr(launcherPos)
		if distMsl > distTrgt then
			return {TargetPos = nil} 
		end
    end


    self.TargetPos = posVec
	return {TargetPos = posVec}
	
end




function this:GetWireTarget()
	
    if not IsValid(self.InputSource) then 
		return {} 
	end
    
    local outputs = self.InputSource.Outputs
    
    if not outputs then
        return {} 
	end
    
    
    local posVec
    
    for k, name in pairs(self.InputNames) do
        
        local outTbl = outputs[name]
        
        if not (outTbl and outTbl.Value) then continue end
        
        local val = outTbl.Value
        
        if isvector(val) and (val.x ~= 0 or val.y ~= 0 or val.z ~= 0) then
            posVec = val
            break
        elseif IsEntity(val) and IsValid(val) then 
            posVec = val:GetPos()
            break
        end
        
    end
    
    
    return posVec
    
end



function this:GetDisplayConfig()
	return {["Wire Length"] = math.Round(self.WireLength / 39.37, 1) .. " m"}
end
