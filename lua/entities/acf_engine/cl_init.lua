-- cl_init.lua

include("shared.lua")

local ACF_EngineInfoWhileSeated = CreateClientConVar("ACF_EngineInfoWhileSeated", 0, true, false)

-- copied from base_wire_entity: DoNormalDraw's notip arg isn't accessible from ENT:Draw defined there.
function ENT:Draw()

    local lply = LocalPlayer()
    local hideBubble = not GetConVar("ACF_EngineInfoWhileSeated"):GetBool() and IsValid(lply) and lply:InVehicle()
    
    self.BaseClass.DoNormalDraw(self, false, hideBubble)
    Wire_Render(self)
    
    if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then 
        -- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
        Wire_DrawTracerBeam( self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false ) 
    end
    
end
--[[
function ACE_EngineGUI_Create( Table )

    acfmenupanel.EngineData         = acfmenupanel.EngineData       or {}
    acfmenupanel.EngineData.Id      = acfmenupanel.EngineData.Id    or "19.0-V8"
    acfmenupanel.EngineData.Fuel    = acfmenupanel.EngineData.Fuel  or "Diesel"
    acfmenupanel.EngineData.Cat     = acfmenupanel.EngineData.Cat   or "V8"

    do
        -- filters by fuel type
        acfmenupanel.CData.EngineFuelBox = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay ) 
        local EngineFuelBox = acfmenupanel.CData.EngineFuelBox

        EngineFuelBox:SetSize(100,30)

        local filtered = {}

        for Key, EngineList in pairs( ACF.Weapons.Mobility ) do

            if not EngineList.enginetype then goto cont end

            local fueltype = EngineList.fuel

            if not filtered[fueltype] then

                EngineFuelBox:AddChoice( fueltype  )
                filtered[fueltype] = true
            end

            ::cont::
        end

        EngineFuelBox.OnSelect = function( value , index , data )
            acfmenupanel.CData.EngineCatBox:Clear()
            acfmenupanel.EngineData.Fuel = data

            local filtered = {}

            for Key, EngineList in pairs( ACF.Weapons.Mobility ) do

                if not EngineList.enginetype then goto cont end

                local cat = EngineList.category
                local fueltype = EngineList.fuel

                if not filtered[cat] and fueltype == data then

                    acfmenupanel.CData.EngineCatBox:AddChoice( cat  )
                    filtered[cat] = true
                end

                ::cont::
            end
        end
        acfmenupanel.CustomDisplay:AddItem( EngineFuelBox )

    end

    do
        -- filters by category
        acfmenupanel.CData.EngineCatBox = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay ) 
        local EngineCatBox = acfmenupanel.CData.EngineCatBox

        EngineCatBox:SetSize(100,30)

        EngineCatBox.OnSelect = function( value , index , data )
            acfmenupanel.CData.EngineIdBox:Clear()
            acfmenupanel.EngineData.Cat = data

            for Key, EngineList in pairs( ACF.Weapons.Mobility ) do

                if not EngineList.enginetype then goto cont end

                local cat   = EngineList.category
                local name  = EngineList.name
                local id    = EngineList.id
                local fuel  = EngineList.fuel

                if cat == data and fuel == acfmenupanel.EngineData.Fuel then

                    acfmenupanel.CData.EngineIdBox:AddChoice( name, id  )
                end

                ::cont::
            end

        end
        acfmenupanel.CustomDisplay:AddItem( EngineCatBox )

    end

    do
        -- filters by id
        acfmenupanel.CData.EngineIdBox = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay ) 
        local EngineIdBox = acfmenupanel.CData.EngineIdBox

        EngineIdBox:SetSize(100,30)

        EngineIdBox.OnSelect = function( value , index , data )

            _,data = EngineIdBox:GetSelected()

            acfmenupanel.EngineData.Id = data
            ACE_EngineGUI_Update( Table )

            RunConsoleCommand( "acfmenu_id", data )
        end

        acfmenupanel.CustomDisplay:AddItem( EngineIdBox )

    end

    ACE_EngineGUI_Update( Table )

end
]]
function ACE_EngineGUI_Update( Table )
    
    --local Id = acfmenupanel.EngineData.Id print(Id)
    --Table = ACF.Weapons.Mobility[Id]

    acfmenupanel:CPanelText("Name", Table.name, "DermaDefaultBold")
    
    if not acfmenupanel.CData.DisplayModel then

        acfmenupanel.CData.DisplayModel = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
        acfmenupanel.CData.DisplayModel:SetModel( Table.model )
        acfmenupanel.CData.DisplayModel:SetCamPos( Vector( 250, 500, 250 ) )
        acfmenupanel.CData.DisplayModel:SetLookAt( Vector( 0, 0, 0 ) )
        acfmenupanel.CData.DisplayModel:SetFOV( 20 )
        acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
        acfmenupanel.CData.DisplayModel.LayoutEntity = function( panel, entity ) end
        acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.DisplayModel )
    
    end

    acfmenupanel.CData.DisplayModel:SetModel( Table.model )

    acfmenupanel:CPanelText("Desc", Table.desc)
    
    local peakkw = Table.peakpower
    local peakkwrpm = Table.peakpowerrpm
    local peaktqrpm = Table.peaktqrpm
    local pbmin = Table.peakminrpm
    local pbmax = Table.peakmaxrpm

    if Table.requiresfuel then --if fuel required, show max power with fuel at top, no point in doing it twice
        acfmenupanel:CPanelText("Power", "\nPeak Power : "..math.floor(peakkw*ACF.TorqueBoost).." kW / "..math.Round(peakkw*ACF.TorqueBoost*1.34).." HP @ "..math.Round(peakkwrpm).." RPM")
        acfmenupanel:CPanelText("Torque", "Peak Torque : "..math.Round(Table.torque*ACF.TorqueBoost).." n/m  / "..math.Round(Table.torque*ACF.TorqueBoost*0.73).." ft-lb @ "..math.Round(peaktqrpm).." RPM")
    else
        acfmenupanel:CPanelText("Power", "\nPeak Power : "..math.floor(peakkw).." kW / "..math.Round(peakkw*1.34).." HP @ "..math.Round(peakkwrpm).." RPM")
        acfmenupanel:CPanelText("Torque", "Peak Torque : "..(Table.torque).." n/m  / "..math.Round(Table.torque*0.73).." ft-lb @ "..math.Round(peaktqrpm).." RPM")
    end

    acfmenupanel:CPanelText("RPM", "Idle : "..(Table.idlerpm).." RPM\nPowerband : "..(math.Round(pbmin / 10) * 10).."-"..(math.Round(pbmax / 10) * 10).." RPM\nRedline : "..(Table.limitrpm).." RPM")
    acfmenupanel:CPanelText("Weight", "Weight : "..(Table.weight).." kg")
    
    
    acfmenupanel:CPanelText("FuelType", "\nFuel Type : "..(Table.fuel))
    
    if Table.fuel == "Electric" then
        local cons = ACF.ElecRate * peakkw / ACF.Efficiency[Table.enginetype]
        acfmenupanel:CPanelText("FuelCons", "Peak energy use : "..math.Round(cons,1).." kW / "..math.Round(0.06*cons,1).." MJ/min")
    elseif Table.fuel == "Multifuel" then
        local petrolcons = ACF.FuelRate * ACF.Efficiency[Table.enginetype] * ACF.TorqueBoost * peakkw / (60 * ACF.FuelDensity.Petrol)
        local dieselcons = ACF.FuelRate * ACF.Efficiency[Table.enginetype] * ACF.TorqueBoost * peakkw / (60 * ACF.FuelDensity.Diesel)
        acfmenupanel:CPanelText("FuelConsP", "Petrol Use at "..math.Round(peakkwrpm).." rpm : "..math.Round(petrolcons,2).." liters/min / "..math.Round(0.264*petrolcons,2).." gallons/min")
        acfmenupanel:CPanelText("FuelConsD", "Diesel Use at "..math.Round(peakkwrpm).." rpm : "..math.Round(dieselcons,2).." liters/min / "..math.Round(0.264*dieselcons,2).." gallons/min")
    else
        local fuelcons = ACF.FuelRate * ACF.Efficiency[Table.enginetype] * ACF.TorqueBoost * peakkw / (60 * ACF.FuelDensity[Table.fuel])
        acfmenupanel:CPanelText("FuelCons", (Table.fuel).." Use at "..math.Round(peakkwrpm).." rpm : "..math.Round(fuelcons,2).." liters/min / "..math.Round(0.264*fuelcons,2).." gallons/min")
    end
    
    if Table.requiresfuel then
        acfmenupanel:CPanelText("Fuelreq", "\nTHIS ENGINE REQUIRES "..(Table.fuel == "Electric" and "BATTERIES" or "FUEL").."\n", "DermaDefaultBold")
    else
        acfmenupanel:CPanelText("FueledPower", "\nWhen supplied with fuel:\nPeak Power : "..math.floor(peakkw*ACF.TorqueBoost).." kW / "..math.Round(peakkw*ACF.TorqueBoost*1.34).." HP @ "..math.Round(peakkwrpm).." RPM")
        acfmenupanel:CPanelText("FueledTorque", "Peak Torque : "..(Table.torque*ACF.TorqueBoost).." n/m  / "..math.Round(Table.torque*ACF.TorqueBoost*0.73).." ft-lb @ "..math.Round(peaktqrpm).." RPM\n")
    end
    
    acfmenupanel.CustomDisplay:PerformLayout()
    
end