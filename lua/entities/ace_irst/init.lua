AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS( "base_wire_entity" )

function ENT:Initialize()

    self.ThinkDelay             = 0.1
    self.StatusUpdateDelay      = 0.5
    self.LastStatusUpdate       = CurTime()
    self.Active                 = false

    self:SetActive(false)

    self.Heat                   = 21      -- Heat              
    self.HeatAboveAmbient       = 5       -- How many degrees above Ambient Temperature this irst will start to track?
    
    self.NextLegalCheck         = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
    self.Legal                  = true
    self.LegalIssues            = ""

    self.ClosestToBeam          = -1

    self:UpdateOverlayText()

    self.Inputs     = WireLib.CreateInputs( self, { "Active" } )
    self.Outputs    = WireLib.CreateOutputs( self, {"Detected", "Owner [ARRAY]", "Position [ARRAY]", "Angle [ARRAY]", "EffHeat [ARRAY]", "ClosestToBeam"} )

end

function MakeACE_IRST(Owner, Pos, Angle, Id)

    if not Owner:CheckLimit("_acf_missileradar") then return false end

    Id = Id or "Small-IRST"

    local radar = ACF.Weapons.Radar[Id]
    
    if not radar then return false end
    
    local IRST = ents.Create("ace_irst")
    if not IsValid(IRST) then return false end

    IRST:SetAngles(Angle)
    IRST:SetPos(Pos)
    
    IRST.Model                 = radar.model
    IRST.Weight                = radar.weight
    IRST.ACFName               = radar.name        
    IRST.ICone                 = radar.viewcone    --Note: intentional. --Recorded initial cone
    IRST.Cone                  = IRST.ICone

    IRST.SeekSensitivity       = radar.SeekSensitivity
    IRST.inac                  = radar.inaccuracy

    IRST.MinimumDistance       = radar.mindist
    IRST.MaximumDistance       = radar.maxdist

    IRST.Id                    = Id
    IRST.Class                 = radar.class
    
    IRST:Spawn()
    
    IRST.Owner = CPPI and IRST:CPPISetOwner(Owner) or IRST:SetPlayer(Owner)
    
    IRST:SetNWNetwork()
    IRST:SetModelEasy(radar.model)
    IRST:UpdateOverlayText()

    Owner:AddCount( "_acf_missileradar", IRST )
    Owner:AddCleanup( "acfmenu", IRST )

    return IRST

end
list.Set( "ACFCvars", "ace_irst", {"id"} )
duplicator.RegisterEntityClass("ace_irst", MakeACE_IRST, "Pos", "Angle", "Id" )

function ENT:SetNWNetwork()
    self:SetNWString( "WireName", self.ACFName )
end

function ENT:SetModelEasy(mdl)

    local Rack = self
    
    Rack:SetModel( mdl )    
    Rack.Model = mdl
    
    Rack:PhysicsInit( SOLID_VPHYSICS )          
    Rack:SetMoveType( MOVETYPE_VPHYSICS )       
    Rack:SetSolid( SOLID_VPHYSICS )
    
    local phys = Rack:GetPhysicsObject()    
    if (phys:IsValid()) then 
        phys:SetMass(Rack.Weight)
    end     
    
end

function ENT:TriggerInput( inp, value )
    if inp == "Active" then
        self:SetActive((value ~= 0) and self.Legal)
    end
end

function ENT:SetActive(active)

    self.Active = active
    
    if active  then
        local sequence = self:LookupSequence("active") or 0
        self:ResetSequence(sequence)
        self.AutomaticFrameAdvance = true
        self.Heat = 21 + 40
    else
        local sequence = self:LookupSequence("idle") or 0
        self:ResetSequence(sequence)
        self.AutomaticFrameAdvance = false

        WireLib.TriggerOutput( self, "Detected"     , 0 )
        WireLib.TriggerOutput( self, "Owner"        , {} )
        WireLib.TriggerOutput( self, "Position"     , {} )
        WireLib.TriggerOutput( self, "Angle"        , {} )
        WireLib.TriggerOutput( self, "EffHeat"      , {} )
        WireLib.TriggerOutput( self, "ClosestToBeam", -1 )  
        self.Heat = 21
    end

end

function ENT:GetWhitelistedEntsInCone()

    local ScanArray = ACE.contraptionEnts
    if table.IsEmpty(ScanArray) then return {} end

    local WhitelistEnts = {}
    local LOSdata       = {}
    local LOStr         = {}

    local IRSTPos       = self:GetPos()

    local entpos        = Vector()
    local difpos        = Vector()
    local dist          = 0

    for k, scanEnt in ipairs(ScanArray) do

        -- skip any invalid entity
        if not IsValid(scanEnt) then goto cont end 

        --Why IRST should track itself?
        if scanEnt:EntIndex() == self:EntIndex() then goto cont end

        entpos  = scanEnt:GetPos()
        difpos  = entpos - IRSTPos
        dist    = difpos:Length()

        -- skip any ent outside of minimun distance
        if dist < self.MinimumDistance then goto cont end 
        
        -- skip any ent far than maximum distance
        if dist > self.MaximumDistance then goto cont end

        LOSdata.start           = IRSTPos
        LOSdata.endpos          = entpos
        LOSdata.collisiongroup  = COLLISION_GROUP_WORLD
        LOSdata.filter          = function( ent ) if ( ent:GetClass() != "worldspawn" ) then return false end end
        LOSdata.mins            = vector_origin
        LOSdata.maxs            = LOSdata.mins

        LOStr = util.TraceHull( LOSdata )
    
        --Trace did not hit world   
        if not LOStr.Hit then 
            table.insert(WhitelistEnts, scanEnt)
        end     
        
        ::cont::
    end
    
    return WhitelistEnts
    
end

function ENT:AcquireLock()

    local found             = self:GetWhitelistedEntsInCone()

    local IRSTPos           = self:GetPos()
    local inac              = self.inac
    local randanginac       = math.Rand(-inac,inac) --Using the same accuracy var for inaccuracy, what could possibly go wrong?
    local randposinac       = Vector(math.Rand(-inac, inac), math.Rand(-inac, inac), math.Rand(-inac, inac))

    --Table definition
    local Owners            = {}
    local Positions         = {}
    local Temperatures      = {}
    local posTable          = {}

    self.ClosestToBeam = -1
    local besterr           = math.huge --Hugh mungus number

    local entpos            = Vector()
    local difpos            = Vector()
    local nonlocang         = Angle()
    local ang               = Angle()
    local absang            = Angle()
    local errorFromAng      = 0
    local dist              = 0

    local physEnt           = NULL


    for k, scanEnt in ipairs(found) do

        entpos      = scanEnt:WorldSpaceCenter()
        difpos      = (entpos - IRSTPos)

        nonlocang   = difpos:Angle()
        ang         = self:WorldToLocalAngles(nonlocang)        --Used for testing if inrange
        absang      = Angle(math.abs(ang.p),math.abs(ang.y),0)  --Since I like ABS so much

        --Doesn't want to see through peripheral vison since its easier to focus a seeker on a target front and center of an array
        errorFromAng = 0.01*(absang.y/90)^2+0.01*(absang.y/90)^2+0.01*(absang.p/90)^2 

        if absang.p < self.Cone and absang.y < self.Cone then --Entity is within seeker cone

            --if the target is a Heat Emitter, track its heat
            if scanEnt.Heat then
                
                Heat = self.SeekSensitivity * scanEnt.Heat 
            
            --if is not a Heat Emitter, track the friction's heat           
            else

                physEnt = scanEnt:GetPhysicsObject()
        
                --skip if it has not a valid physic object. It's amazing how gmod can break this. . .
                if physEnt:IsValid() then   
                --check if it's not frozen. If so, skip it, unmoveable stuff should not be even considered
                    if not physEnt:IsMoveable() then goto cont end
                end

                dist = difpos:Length()              
                Heat = ACE_InfraredHeatFromProp( self, scanEnt , dist )
            
            end
            
            --Skip if not Hotter than AmbientTemp in deg C.
            if Heat <= ACE.AmbientTemp + self.HeatAboveAmbient then goto cont end 

            --Could do pythagorean stuff but meh, works 98% of time
            local err = absang.p + absang.y 

            --Sorts targets as closest to being directly in front of radar
            if err < besterr then 
                self.ClosestToBeam =  table.getn( Owners ) + 1
                besterr = err
            end

            local errorFromHeat     = math.max((200-Heat)/5000,0) --200 degrees to the seeker causes no loss in accuracy
            local posErrorFromHeat  = 1 - math.min(1, (Heat / 200))
            local angerr            = 1 + randanginac * (errorFromAng + errorFromHeat)

            --For Owner table
            table.insert( Owners        , CPPI and ( IsValid( scanEnt:CPPIGetOwner() ) and scanEnt:CPPIGetOwner():GetName()) or scanEnt:GetOwner():GetName() or "")
            table.insert( Positions     , (entpos + randposinac * posErrorFromHeat * difpos:Length()/500 ) )
            table.insert( Temperatures  , Heat )
            table.insert( posTable      , nonlocang * angerr )

            debugoverlay.Line(self:GetPos(), Positions[1], 5, Color(255,255,0), true)

        end

        ::cont::
    end

    if self.ClosestToBeam ~= -1 then --Some entity passed the test to be valid

        WireLib.TriggerOutput( self, "Detected"     , 1 )
        WireLib.TriggerOutput( self, "Owner"        , Owners )
        WireLib.TriggerOutput( self, "Position"     , Positions )
        WireLib.TriggerOutput( self, "Angle"        , posTable )
        WireLib.TriggerOutput( self, "EffHeat"      , Temperatures )
        WireLib.TriggerOutput( self, "ClosestToBeam", self.ClosestToBeam )       
    else --Nothing detected

        WireLib.TriggerOutput( self, "Detected"     , 0 )
        WireLib.TriggerOutput( self, "Owner"        , {} )
        WireLib.TriggerOutput( self, "Position"     , {} )
        WireLib.TriggerOutput( self, "Angle"        , {} )
        WireLib.TriggerOutput( self, "EffHeat"      , {} )
        WireLib.TriggerOutput( self, "ClosestToBeam", -1 )  
    end



end

function ENT:Think()

    local curTime = CurTime()   
    self:NextThink(curTime + self.ThinkDelay)

    if ACF.CurTime > self.NextLegalCheck then

        self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, math.Round(self.Weight,2), nil, true, true)
        self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

        if not self.Legal then
            self.Active = false
            self:SetActive(false)
        end
        
    end

    if self.Active and self.Legal then
        self:AcquireLock()
    end

    if (self.LastStatusUpdate + self.StatusUpdateDelay < curTime) then
        self:UpdateStatus()
        self.LastStatusUpdate = curTime
    end

    self:UpdateOverlayText()

end

function ENT:UpdateStatus()
        self.Status = self.Active and "On" or "Off"
end

function ENT:UpdateOverlayText()

    local cone      = self.Cone
    local status    = self.Status or "Off"
    local detected  = status ~= "Off" and self.ClosestToBeam ~= -1 or false
    local range     = self.MaximumDistance or 0

    local txt = "Status: "..status

    txt = txt.."\n\nView Cone: "..math.Round(cone * 2, 2).." deg"

    txt = txt.."\nMax Range: "..(isnumber(range) and math.Round(range / 39.37 , 2).." m" or "Unlimited" )

    if detected then
        txt = txt.."\n\nTarget Detected!"
    end

    if not self.Legal then
      txt = txt .. "\n\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
    end

    self:SetOverlayText(txt)


end