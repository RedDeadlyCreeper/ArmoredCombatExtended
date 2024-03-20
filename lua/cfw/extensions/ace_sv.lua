local CLASS = CFW.classes.contraption

-- Maintains a table of ACE components for each contraption
do
    hook.Add("cfw.contraption.entityAdded", "CFW_ACE_Entities", function(con, ent)
        if not IsValid(ent) then return end
        if not con.aceEntities then con.aceEntities = {} end

        local class = ent:GetClass()

        if class:match("^ace_") or class:match("^acf_") then
            con.aceEntities[ent] = true
        end
    end)

    hook.Add("cfw.contraption.entityRemoved", "CFW_ACE_Entities", function(con, ent)
        if not IsValid(ent) then return end
        if not con.aceEntities then return end

        con.aceEntities[ent] = nil
    end)
end

-- Attempt to keep track of baseplates of contraptions, based on which entity has the most constraints
-- This is probably bad but it works for now
do
    local function findContraptionBaseplate(con)
        local maxConstraintCount = 0
        local baseplate = next(con.ents)

        for ent in pairs(con.ents) do
            if IsValid(ent) and not IsValid(ent:GetParent()) then
                local count = #constraint.GetTable(ent)

                if count > maxConstraintCount then
                    maxConstraintCount = count
                    baseplate = ent
                end
            end
        end

        con.aceBaseplate = baseplate
    end

    hook.Add("cfw.contraption.entityAdded", "CFW_ACE_BaseplateDetection", findContraptionBaseplate)
    hook.Add("cfw.contraption.entityRemoved", "CFW_ACE_BaseplateDetection", findContraptionBaseplate)
end

--- Returns the hottest entity in a contraption and its temperature
---@return Entity
---@return number
function CLASS:GetACEHottestEntity()
    local aceEntities = self.aceEntities

    if not aceEntities then return end

    local hottest
    local highestTemp = 0

    for ent in pairs(aceEntities) do
        if ent.Heat then
            local temp = ent.Heat
            if temp > highestTemp then
                hottest = ent
                highestTemp = temp
            end
        end
    end

    return hottest, highestTemp
end

--- Returns a table of all heat sources in a contraption
---@return table
function CLASS:GetACEHotEnts()
    local aceEntities = self.aceEntities

    if not aceEntities then return end

    local hotEnts = {}

    for ent in pairs(aceEntities) do
        if ent.Heat then
            hotEnts[#hotEnts + 1] = ent
        end
    end

    return hotEnts
end

--- Returns a weighted average position of all heat sources in a contraption
---@return Vector
function CLASS:GetACEHeatPosition()
    local aceEntities = self.aceEntities

    if not aceEntities then return end

    local totalTemp = 0
    local totalPos = Vector(0, 0, 0)

    for ent in pairs(aceEntities) do
        if ent.Heat then
            local temp = ent.Heat
            totalTemp = totalTemp + temp
            totalPos = totalPos + ent:GetPos() * temp
        end
    end

    return totalPos / totalTemp
end