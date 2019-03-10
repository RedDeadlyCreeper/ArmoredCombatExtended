


AddCSLuaFile()
include("acf/shared/sh_acfm_getters.lua")




local function checkIfDataIsMissile(data)

	local guns = list.Get("ACFEnts").Guns
	local class = guns[data.Id]
	
	if not (class and class.gunclass) then
		return oldDisplayData(data)
	end
	
	local classes = list.Get("ACFClasses").GunClass
	class = classes[class.gunclass]
	
	return (class.type and class.type == "missile")

end




function ACFM_ModifyRoundDisplayFuncs()
    
    local roundTypes = list.GetForEdit("ACFRoundTypes")
    
    if not ACFM_RoundDisplayFuncs then
        
        ACFM_RoundDisplayFuncs = {}
    
        for k, v in pairs(roundTypes) do
            ACFM_RoundDisplayFuncs[k] = v.getDisplayData
        end

    end
    
    
    for k, v in pairs(roundTypes) do
        
        local oldDisplayData = ACFM_RoundDisplayFuncs[k]
    
        if oldDisplayData then
            v.getDisplayData = function(data)
            
                if not checkIfDataIsMissile(data) then
					return oldDisplayData(data)
				end
            
                -- NOTE: if these replacements cause side-effects somehow, move to a masking-metatable approach
            
                local MuzzleVel = data.MuzzleVel
                local slugMV = data.SlugMV
                
                data.MuzzleVel = 0
                data.SlugMV = (slugMV or 0) * (ACF_GetGunValue(data.Id, "penmul") or 1)
                
                local ret = oldDisplayData(data)
                
                data.SlugMV = slugMV
                data.MuzzleVel = MuzzleVel
                
                return ret
            end
        end
    end
    
end




local function configConcat(tbl, sep)

	local toConcat = {}
	
	for k, v in pairs(tbl) do
		toConcat[#toConcat+1] = tostring(k) .. " = " .. tostring(v)
	end

	return table.concat(toConcat, sep)
	
end




function ACFM_ModifyCrateTextFuncs()
    
    local roundTypes = list.GetForEdit("ACFRoundTypes")
    
    if not ACFM_CrateTextFuncs then
        
        ACFM_CrateTextFuncs = {}
    
        for k, v in pairs(roundTypes) do
            ACFM_CrateTextFuncs[k] = v.cratetxt
        end

    end
    
    
    for k, v in pairs(roundTypes) do
        
        local oldCratetxt = ACFM_CrateTextFuncs[k]
	
        if oldCratetxt then
            v.cratetxt = function(data, crate)
			
                local origCrateTxt = oldCratetxt(data)
				
				if not checkIfDataIsMissile(data) then
					return origCrateTxt
				end
				
				local str = { origCrateTxt }
				
				local guidance  = IsValid(crate) and crate.RoundData7 or data.Data7
				local fuse      = IsValid(crate) and crate.RoundData8 or data.Data8
				
				if guidance then
					guidance = ACFM_CreateConfigurable(guidance, ACF.Guidance, bdata, "guidance")
					if guidance and guidance.Name ~= "Dumb" then 
						str[#str+1] = "\n\n"
						str[#str+1] = guidance.Name
						str[#str+1] = " guidance\n("
						str[#str+1] = configConcat(guidance:GetDisplayConfig(), ", ")
						str[#str+1] = ")"
					end
				end
				
				if fuse then
					fuse = ACFM_CreateConfigurable(fuse, ACF.Fuse, bdata, "fuses")
					if fuse then 
						str[#str+1] = "\n\n"
						str[#str+1] = fuse.Name
						str[#str+1] = " fuse\n("
						str[#str+1] = configConcat(fuse:GetDisplayConfig(), ", ")
						str[#str+1] = ")"
					end
				end
                
                return table.concat(str)
            end
			
			ACF.RoundTypes[k].cratetxt = v.cratetxt
        end
    end
    
end




function ACFM_ModifyRoundBaseGunpowder()
    
    local oldGunpowder = ACFM_ModifiedRoundBaseGunpowder and oldGunpowder or ACF_RoundBaseGunpowder
    
    
    ACF_RoundBaseGunpowder = function(PlayerData, Data, ServerData, GUIData)
        
        PlayerData, Data, ServerData, GUIData = oldGunpowder(PlayerData, Data, ServerData, GUIData)
        
        Data.Id = PlayerData.Id
        
        return PlayerData, Data, ServerData, GUIData
        
    end
    
    
    ACFM_ModifiedRoundBaseGunpowder = true
    
end



timer.Simple(1, ACFM_ModifyRoundBaseGunpowder)
timer.Simple(1, ACFM_ModifyRoundDisplayFuncs)
timer.Simple(1, ACFM_ModifyCrateTextFuncs)

-- if CLIENT then
    -- timer.Simple(1, ACFM_ModifyRoundGUIFuncs)
-- end

