AddCSLuaFile()

local Clamp = math.Clamp

--Calculates a position along a catmull-rom spline (as defined on https://www.mvps.org/directx/articles/catmull/)
--This is used for calculating engine torque curves
function ACF_CalcCurve(Points, Pos)
    local Count = #Points

    if Count < 3 then return 0 end

    if Pos <= 0 then
        return Points[1]
    elseif Pos >= 1 then
        return Points[Count]
    end

    local T       = (Pos * (Count - 1)) % 1
    local Current = math.floor(Pos * (Count - 1) + 1)
    local P0      = Points[Clamp(Current - 1, 1, Count - 2)]
    local P1      = Points[Clamp(Current, 1, Count - 1)]
    local P2      = Points[Clamp(Current + 1, 2, Count)]
    local P3      = Points[Clamp(Current + 2, 3, Count)]

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
    local powerTable = {} --Power at each point on the curve for use in powerband calc
    local res = 32 --Iterations for use in calculating the curve, higher is more accurate

    --Calculate peak torque/power RPM
    for i = 0, res do
        local rpm = i / res * redline
        local perc = math.Remap(rpm, idle, redline, 0, 1)
        local curTq = ACF_CalcCurve(curve, perc)
        local power = maxTq * curTq * rpm / 9548.8

        powerTable[i] = power

        if power > peakPower then
            peakPower = power
            peakPowerRPM = rpm
        end

        if Clamp(curTq, 0, 1) > peakTq then
            peakTq = curTq
            peakTqRPM = rpm
        end
    end

    --Find the bounds of the powerband (within 10% of its peak)
    local powerbandMinRPM
    local powerbandMaxRPM

    for i = 0, res do
        local powerFrac = powerTable[i] / peakPower
        local rpm = i / res * redline

        if powerFrac > 0.9 and not powerbandMinRPM then
            powerbandMinRPM = rpm
        end

        if (powerbandMinRPM and powerFrac < 0.9 and not powerbandMaxRPM) or (i == res and not powerbandMaxRPM) then
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


--Creates & updates ACE dupes.
--[[
-- USAGE:
    To Add a dupe, you have to put inside of your_addon_name/scripts/vehicles/>HERE< with the following naming:

    acedupe_[folder name]_[your dupe name].txt

    Note: 
    - folder name must be ONE word (acecool, myaddon, tankpack, etc). It cannot have spaces!!!
    - you dupe name can have spaces, however, they must be '_' for the file. The loader will automatically change that symbol to spaces.

    Correct way examples: 

    - acedupe_tanks_bmp2.txt
    - acedupe_cars_my_cool_car.txt
    - acedupe_thebest_the_best_of_the_best.txt
]]

do

    local file_name
    local file_directory
    local main_directory = "advdupe2/"

    local Dupes          = {}
    local dupefiles      = {}

    local fileIndex      = "acedupe"

    function ACE_Dupes_Refresh()

        Dupes = file.Find("scripts/vehicles/*.txt", "GAME")

        if not Dupes then return end

        dupefiles = {}

        for i, Result in ipairs(Dupes) do

            local Id = string.Explode("_", Result)
            if Id[1] ~= fileIndex then goto cont end

            file_name = table.concat( Id, " ", 3) 
            file_name = string.Replace( file_name, ".txt", "" )

            dupefiles[i] = Result --Catching desired files
            file_content = file.Read("scripts/vehicles/"..dupefiles[i], "GAME")

            file_directory = main_directory.."ace "..Id[2]
            local fileExists = file.Exists( file_directory.."/"..file_name..".txt", "DATA")

            if not fileExists then

                --print( "[ACE|INFO]- Creating dupe '"..file_name.."'' in "..file_directory )

                file.CreateDir(file_directory)
                file.Write(file_directory.."/"..file_name..".txt", file_content)

                
            else
                --Idea: bring the analyzer from the internet instead of locally?

                local CFile_Size = file.Size(file_directory.."/"..file_name..".txt", "DATA")
                local NFile_Size = file.Size("scripts/vehicles/"..dupefiles[i], "GAME")

                if NFile_Size > 0 and CFile_Size ~= NFile_Size then

                    --print("[ACE|INFO]- your dupe "..file_name.." is different/outdated! Updating....")

                    file.Write(file_directory.."/"..file_name..".txt", file_content)

                end

            end
            ::cont::
        end

    end

end

timer.Simple(1, function()
    ACF_UpdateChecking()
    ACE_Dupes_Refresh()
end )


do

    --Used to reconvert old material ids
    ACE.BackCompMat = {
        [0] = "RHA",
        [1] = "CHA",
        [2] = "Cer",
        [3] = "Rub",
        [4] = "ERA",
        [5] = "Alum",
        [6] = "Texto"
    }

    function ACE_GetMaterialData( Mat )

        if not ACE.Armors or table.IsEmpty(ACE.Armors) then
            print("[ACE|ERROR]- No Armor material data found! Have the armor folder been renamed or removed? Unexpected results could occur!")
            return nil
        end

        Mat = not isstring(Mat) and ACE.BackCompMat[Mat] or Mat

        local MatData = ACE.Armors[Mat]

        if not MatData or table.IsEmpty(MatData) then
            print("[ACE|ERROR]- We got an invalid or unknown armor [ "..Mat.." ] which is not able to be processed. Dealing as RHA...")

            MatData = ACE.Armors["RHA"]

        end

        return MatData
    end
end

function ACE_CheckRound( id )

    local rounddata = ACF.RoundTypes[ id ]

    if not rounddata then return false end

    return true
end