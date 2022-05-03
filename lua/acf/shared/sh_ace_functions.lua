AddCSLuaFile()

--Calculates a position along a catmull-rom spline (as defined on https://www.mvps.org/directx/articles/catmull/)
--This is used for calculating engine torque curves
function ACF_CalcCurve(Points, Pos)
    if #Points < 3 then
        return 0
    end

    local T = 0
    if Pos <= 0 then
        T = 0
    elseif Pos >= 1 then
        T = 1
    else
        T = Pos * (#Points - 1)
        T = T % 1
    end

    local CurrentPoint = math.floor(Pos * (#Points - 1) + 1)
    local P0 = Points[math.Clamp(CurrentPoint - 1, 1, #Points - 2)]
    local P1 = Points[math.Clamp(CurrentPoint, 1, #Points - 1)]
    local P2 = Points[math.Clamp(CurrentPoint + 1, 2, #Points)]
    local P3 = Points[math.Clamp(CurrentPoint + 2, 3, #Points)]

    return 0.5 * ((2 * P1) +
        (P2 - P0) * T +
        (2 * P0 - 5 * P1 + 4 * P2 - P3) * T ^ 2 +
        (3 * P1 - P0 - 3 * P2 + P3) * T ^ 3)
end

--Calculates the performance characteristics of an engine, given a torque curve, max torque (in nm), idle, and redline rpm
function ACF_CalcEnginePerformanceData(curve, maxTq, idle, redline)
    local peakTq = 0
    local peakTqRPM
    local peakPower = 0
    local powerbandMinRPM
    local powerbandMaxRPM
    local powerTable = {} --Power at each point on the curve for use in powerband calc
    local powerbandTable = {} --(torque + power) / 2 at each point on the curve
    local powerbandPeak = 0 --Highest value of (torque + power) / 2
    local res = 32 --Iterations for use in calculating the curve, higher is more accurate
    local curveFactor = (redline - idle) / redline --Torque curves all start after idle RPM is reached

    --Calculate peak torque/power rpm.
    for i = 0, res do
        local rpm = i / res * redline
        local perc = (rpm - idle) / curveFactor / redline
        local curTq = ACF_CalcCurve(curve, perc)
        local power = maxTq * curTq * rpm / 9548.8
        powerTable[i] = power
        if power > peakPower then
            peakPower = power
            peakPowerRPM = rpm
        end

        if math.Clamp(curTq, 0, 1) > peakTq then
            peakTq = curTq
            peakTqRPM = rpm
        end
    end

    --Loop two, to calculate the powerband's peak.
    for i = 0, res do
        local power = powerTable[i] / peakPower
        local tq = ACF_CalcCurve(curve, i / res)
        local powerband = power + tq --This seems like the best way I was given to calculate the powerband range - maybe improve eventually?
        powerbandTable[i] = powerband

        if powerband > powerbandPeak then
            powerbandPeak = powerband
        end
    end

    --Loop three, to actually figure out where the bounds of the powerband are (within 10% of max).
    for i = 0, res do
        local powerband = powerbandTable[i] / powerbandPeak
        local rpm = i / res * redline

        if powerband > 0.9 and not powerbandMinRPM then
            powerbandMinRPM = rpm
        end

        if (powerbandMinRPM and powerband < 0.9 and not powerbandMaxRPM) or (i == res and not powerbandMaxRPM) then
            powerbandMaxRPM = rpm
        end
    end

    return {
        peakTqRPM = peakTqRPM,
        peakPower = peakPower,
        peakPowerRPM = peakPowerRPM,
        powerbandMinRPM = powerbandMinRPM,
        powerbandMaxRPM = powerbandMaxRPM
    }
end

-- changes here will be automatically reflected in the armor properties tool
function ACF_CalcArmor( Area, Ductility, Mass )
    
    return ( Mass * 1000 / Area / 0.78 ) / ( 1 + Ductility ) ^ 0.5 * ACF.ArmorMod
    
end

function ACF_MuzzleVelocity( Propellant, Mass, Caliber )

    local PEnergy   = ACF.PBase * ((1+Propellant)^ACF.PScale-1)
    local Speed     = ((PEnergy*2000/Mass)^ACF.MVScale)
    local Final     = Speed -- - Speed * math.Clamp(Speed/2000,0,0.5)

    return Final
end

function ACF_Kinetic( Speed , Mass, LimitVel )
    
    LimitVel = LimitVel or 99999
    Speed = Speed/39.37
    
    local Energy = {}
        Energy.Kinetic = ((Mass) * ((Speed)^2))/2000 --Energy in KiloJoules
        Energy.Momentum = (Speed * Mass)
        
        local KE = (Mass * (Speed^ACF.KinFudgeFactor))/2000 + Energy.Momentum
        Energy.Penetration = math.max( KE - (math.max(Speed-LimitVel,0)^2)/(LimitVel*5) * (KE/200)^0.95 , KE*0.1 )

    return Energy
end

do

    --Convert old numeric IDs to the new string IDs
    local BackCompMat = {
        "RHA",
        "CHA",
        "Cer",
        "Rub",
        "ERA",
        "Alum",
        "Texto"
    }

    -- Global Ratio Setting Function
    function ACF_CalcMassRatio( obj, pwr )
        if not IsValid(obj) then return end
        local Mass          = 0
        local PhysMass      = 0
        local power         = 0
        local fuel          = 0
        local Compositions  = {}
        local MatSums       = {}
        local PercentMat    = {}

        -- find the physical parent highest up the chain
        local Parent = ACF_GetPhysicalParent(obj)
    
        -- get the shit that is physically attached to the vehicle
        local PhysEnts = ACF_GetAllPhysicalConstraints( Parent )
    
        -- add any parented but not constrained props you sneaky bastards
        local AllEnts = table.Copy( PhysEnts )
        for k, v in pairs( AllEnts ) do
        
            table.Merge( AllEnts, ACF_GetAllChildren( v ) )
    
        end
    
        for k, v in pairs( AllEnts ) do
        
            if IsValid( v ) then

                if v:GetClass() == "acf_engine" then
                    power = power + (v.peakkw * 1.34)
                    fuel = v.RequiresFuel and 2 or fuel
                elseif v:GetClass() == "acf_fueltank" then
                    fuel = math.max(fuel,1)
                end
            
                local phys = v:GetPhysicsObject()
                if IsValid( phys ) then     
            
                    Mass = Mass + phys:GetMass() --print("total mass of contraption: "..Mass)
                
                    if PhysEnts[ v ] then
                        PhysMass = PhysMass + phys:GetMass()
                    end
                
                end

                if pwr then
                    local PhysObj = v:GetPhysicsObject()

                    if IsValid(PhysObj) then

                        local material          = v.ACF and v.ACF.Material or "RHA"

                        --ACE doesnt update their material stats actively, so we need to update it manually here.
                        if not isstring(material) then
                            local Mat_ID = material + 1
                            material = BackCompMat[Mat_ID]
                        end

                        Compositions[material]  = Compositions[material] or {}

                        table.insert(Compositions[material], PhysObj:GetMass() )

                    end
                end

            end
        end

        --Build the ratios here
        for k, v in pairs( AllEnts ) do
            v.acfphystotal      = PhysMass
            v.acftotal          = Mass
            v.acflastupdatemass = ACF.CurTime   
        end 

        if pwr then
            --Get mass Material composition here
            for material, tablemass in pairs(Compositions) do

                MatSums[material] = 0

                for i,mass in pairs(tablemass) do

                    MatSums[material] = MatSums[material] + mass 

                end 

                --Gets the actual material percent of the contraption
                PercentMat[material] = ( MatSums[material] / obj.acftotal ) or 0

            end
        end
        if pwr then return { Power = power, Fuel = fuel, MaterialPercent = PercentMat, MaterialMass = MatSums } end
    end

end

--Checks if theres new versions for ACE
function ACF_UpdateChecking( )
    http.Fetch("https://raw.githubusercontent.com/RedDeadlyCreeper/ArmoredCombatExtended/master/lua/autorun/acf_globals.lua",function(contents,size) 

        --maybe not the best way to get git but well......
        str = tostring("String:"..contents)    
        i,k = string.find(str,'ACF.Version =')
                
        local rev = tonumber(string.sub(str,k+2,k+4)) or 0
        
        if rev and ACF.Version == rev  and rev ~= 0 then
            
            print("[ACE | INFO]- You have the latest version! Current version: "..rev)
        
        elseif rev and ACF.Version > rev and rev ~= 0 then

            print("[ACE | INFO]- You have an experimental version! Your version: "..ACF.Version..". Main version: "..rev)
        elseif rev == 0 then
        
            print("[ACE | ERROR]- Unable to find the latest version! No internet available.")
            
        else
        
            print("[ACE | INFO]- A new version of ACE is available! Your version: "..ACF.Version..". New version: "..rev)
            if CLIENT then chat.AddText( Color( 255, 0, 0 ), "A newer version of ACE is available!" ) end
            
        end
        ACF.CurrentVersion = rev
        
    end, function() end)
end

--Creates and updates the ace dupes. ATM only analyzer.
function ACE_Dupes_Refresh()

    --Directory relative to DATA folder
    local Directory = "advdupe2/ace tools"

    --Name of the file
    local FileName  = "armor_analyzer"

    --To check if the file already exists
    local FileExists = file.Exists( Directory.."/"..FileName..".txt", "DATA")

    --Writes in case of not existing
    if not FileExists then

        local File_Content = file.Read("scripts/vehicles/armor_analyzer.txt", "GAME")

        file.CreateDir(Directory)
        file.Write(Directory.."/"..FileName..".txt", File_Content)


    --Updates the current one if it differs from the new version.
    else
        --Idea: bring the analyzer from the internet instead of locally?

        local Current_File_Size = file.Size("advdupe2/ace tools/armor_analyzer.txt", "DATA")
        local New_File_Size     = file.Size("scripts/vehicles/armor_analyzer.txt", "GAME")

        if New_File_Size > 0 and Current_File_Size ~= New_File_Size then

            print("[ACE|INFO]- Your armor analyzer is different. Updating...")

            local File_Content = file.Read("scripts/vehicles/armor_analyzer.txt", "GAME")

            file.Write(Directory.."/"..FileName..".txt", File_Content)

        end
    end
end

timer.Simple(2, function()
    ACF_UpdateChecking()
    ACE_Dupes_Refresh()
end )