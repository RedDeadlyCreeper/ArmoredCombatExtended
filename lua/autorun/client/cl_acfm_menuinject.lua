

include("acf/client/cl_acfmenu_missileui.lua")


function SetMissileGUIEnabled(panel, enabled, gundata)

    if enabled then
    
        -- Create guidance selection combobox + description label
    
        if not acfmenupanel.CData.MissileSpacer then
            local spacer = vgui.Create("DPanel")
            spacer:SetSize(24, 24)
            spacer.Paint = function() end
            acfmenupanel.CData.MissileSpacer = spacer
            
            acfmenupanel.CustomDisplay:AddItem(spacer)
        end
    
        local default = "Dumb"   -- Dumb is the only acceptable default
        if not acfmenupanel.CData.GuidanceSelect then
            acfmenupanel.CData.GuidanceSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )	--Every display and slider is placed in the Round table so it gets trashed when selecting a new round type
            acfmenupanel.CData.GuidanceSelect:SetSize(100, 30)        
            
            acfmenupanel.CData.GuidanceSelect.OnSelect = function( index , value , data )
                RunConsoleCommand( "acfmenu_data7", data )
                
                local gun = {}
                
                local gunId = acfmenupanel.CData.CaliberSelect:GetValue()
                if gunId then
                    local guns = list.Get("ACFEnts").Guns
                    gun = guns[gunId]
                end
                
                local guidance = ACF.Guidance[data]
                if guidance and guidance.desc then
                    acfmenupanel:CPanelText("GuidanceDesc", guidance.desc .. "\n")
                    
                    local configPanel = ACFMissiles_CreateMenuConfiguration(guidance, acfmenupanel.CData.GuidanceSelect, "acfmenu_data7", acfmenupanel.CData.GuidanceSelect.ConfigPanel, gun)
                    acfmenupanel.CData.GuidanceSelect.ConfigPanel = configPanel
                else
                    acfmenupanel:CPanelText("GuidanceDesc", "Missiles and bombs can be given a guidance package to steer them during flight.\n")
                end
            end
                
            acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.GuidanceSelect )
            
            acfmenupanel:CPanelText("GuidanceDesc", "Missiles and bombs can be given a guidance package to steer them during flight.\n")
            
            local configPanel = vgui.Create("DScrollPanel")
            acfmenupanel.CData.GuidanceSelect.ConfigPanel = configPanel
            acfmenupanel.CustomDisplay:AddItem( configPanel )
            
        else        
            --acfmenupanel.CData.GuidanceSelect:SetSize(100, 30)
            default = acfmenupanel.CData.GuidanceSelect:GetValue()
            acfmenupanel.CData.GuidanceSelect:SetVisible(true)
        end
        
        acfmenupanel.CData.GuidanceSelect:Clear()
        for Key, Value in pairs( gundata.guidance or {} ) do
            acfmenupanel.CData.GuidanceSelect:AddChoice( Value, Value, Value == default )
        end
        
        
        -- Create fuse selection combobox + description label
        
        default = "Contact"  -- Contact is the only acceptable default
        if not acfmenupanel.CData.FuseSelect then
            acfmenupanel.CData.FuseSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )	--Every display and slider is placed in the Round table so it gets trashed when selecting a new round type
            acfmenupanel.CData.FuseSelect:SetSize(100, 30)
            
            acfmenupanel.CData.FuseSelect.OnSelect = function( index , value , data )
			
                local gun = {}
                
                local gunId = acfmenupanel.CData.CaliberSelect:GetValue()
                if gunId then
                    local guns = list.Get("ACFEnts").Guns
                    gun = guns[gunId]
                end
                
                local fuse = ACF.Fuse[data]
                
                if fuse and fuse.desc then
                    acfmenupanel:CPanelText("FuseDesc", fuse.desc .. "\n")
                    
                    local configPanel = ACFMissiles_CreateMenuConfiguration(fuse, acfmenupanel.CData.FuseSelect, "acfmenu_data8", acfmenupanel.CData.FuseSelect.ConfigPanel, gun)
                    acfmenupanel.CData.FuseSelect.ConfigPanel = configPanel
                else
                    acfmenupanel:CPanelText("FuseDesc", "Missiles and bombs can be given a fuse to control when they detonate.\n")
                end
				
				ACFMissiles_SetCommand(acfmenupanel.CData.FuseSelect, acfmenupanel.CData.FuseSelect.ControlGroup, "acfmenu_data8")
            end
                
            acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.FuseSelect )
            
            acfmenupanel:CPanelText("FuseDesc", "Missiles and bombs can be given a fuse to control when they detonate.\n")
            
            local configPanel = vgui.Create("DScrollPanel")
            configPanel:SetTall(0)
            acfmenupanel.CData.FuseSelect.ConfigPanel = configPanel
            acfmenupanel.CustomDisplay:AddItem( configPanel )
        else
            --acfmenupanel.CData.FuseSelect:SetSize(100, 30)
            default = acfmenupanel.CData.FuseSelect:GetValue()
            acfmenupanel.CData.FuseSelect:SetVisible(true)
        end
        
        acfmenupanel.CData.FuseSelect:Clear()
        for Key, Value in pairs( gundata.fuses or {} ) do
            acfmenupanel.CData.FuseSelect:AddChoice( Value, Value, Value == default ) -- Contact is the only acceptable default
        end
    
    else
    
        -- Delete everything!  Tried just making them invisible but they seem to break.
    
        if acfmenupanel.CData.MissileSpacer then
            acfmenupanel.CData.MissileSpacer:Remove()
            acfmenupanel.CData.MissileSpacer = nil
        end
    
    
        if acfmenupanel.CData.GuidanceSelect then
        
            if acfmenupanel.CData.GuidanceSelect.ConfigPanel then
                acfmenupanel.CData.GuidanceSelect.ConfigPanel:Remove()
                acfmenupanel.CData.GuidanceSelect.ConfigPanel = nil   
            end
        
            acfmenupanel.CData.GuidanceSelect:Remove()
            acfmenupanel.CData.GuidanceSelect = nil
        end
        
        if acfmenupanel.CData.GuidanceDesc_text then
            acfmenupanel.CData.GuidanceDesc_text:Remove()
            acfmenupanel.CData.GuidanceDesc_text = nil
        end
        
        
        if acfmenupanel.CData.FuseSelect then
            
            if acfmenupanel.CData.FuseSelect.ConfigPanel then
                acfmenupanel.CData.FuseSelect.ConfigPanel:Remove()
                acfmenupanel.CData.FuseSelect.ConfigPanel = nil   
            end
        
            acfmenupanel.CData.FuseSelect:Remove()
            acfmenupanel.CData.FuseSelect = nil           
        end
        
        if acfmenupanel.CData.FuseDesc_text then
            acfmenupanel.CData.FuseDesc_text:Remove()
            acfmenupanel.CData.FuseDesc_text = nil
        end
    
    end
    
end




function CreateRackSelectGUI(node)    
    
    if not acfmenupanel.CData.MissileSpacer then
        local spacer = vgui.Create("DPanel")
        spacer:SetSize(24, 24)
        spacer.Paint = function() end
        acfmenupanel.CData.MissileSpacer = spacer
        
        acfmenupanel.CustomDisplay:AddItem(spacer)
    end

    
    if not acfmenupanel.CData.RackSelect or IsValid(acfmenupanel.CData.RackSelect) then
        acfmenupanel.CData.RackSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )	--Every display and slider is placed in the Round table so it gets trashed when selecting a new round type
        acfmenupanel.CData.RackSelect:SetSize(100, 30)        
        
        acfmenupanel.CData.RackSelect.OnSelect = function( index , value , data )
            RunConsoleCommand( "acfmenu_data9", data )
            
            local rack = ACF.Weapons.Rack[data]
            if rack and rack.desc then
                acfmenupanel:CPanelText("RackDesc", rack.desc .. "\n")
                
                --local configPanel = ACFMissiles_CreateMenuConfiguration(rack, acfmenupanel.CData.RackSelect, "acfmenu_data1", acfmenupanel.CData.RackSelect.ConfigPanel)
                --acfmenupanel.CData.RackSelect.ConfigPanel = configPanel
            else
                acfmenupanel:CPanelText("RackDesc", "Select a compatible rack from the list above.\n")
            end
        end
            
        acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.RackSelect )
        
        acfmenupanel:CPanelText("RackDesc", "Select a compatible rack from the list above.\n")
        
        local configPanel = vgui.Create("DScrollPanel")
        acfmenupanel.CData.RackSelect.ConfigPanel = configPanel
        acfmenupanel.CustomDisplay:AddItem( configPanel )
        
    else        
        --acfmenupanel.CData.RackSelect:SetSize(100, 30)
        default = acfmenupanel.CData.RackSelect:GetValue()
        acfmenupanel.CData.RackSelect:SetVisible(true)
    end
    
    acfmenupanel.CData.RackSelect:Clear()
    
    local default = node.mytable.rack
    for Key, Value in pairs( ACF_GetCompatibleRacks(node.mytable.id) ) do
        acfmenupanel.CData.RackSelect:AddChoice( Value, Value, Value == default )
    end
    
    
end




function ModifyACFMenu(panel)
    
    oldAmmoSelect = oldAmmoSelect or panel.AmmoSelect
   
    panel.AmmoSelect = function(panel, blacklist)
    
        oldAmmoSelect(panel, blacklist)
    
        acfmenupanel.CData.CaliberSelect.OnSelect = function( index , value , data )            
			acfmenupanel.AmmoData["Data"] = acfmenupanel.WeaponData["Guns"][data]["round"]
			acfmenupanel:UpdateAttribs()
			acfmenupanel:UpdateAttribs()	--Note : this is intentional
            
            local gunTbl = acfmenupanel.WeaponData["Guns"][data]
            local class = gunTbl.gunclass
            
            local Classes = list.Get("ACFClasses")
            timer.Simple(0.01, function() SetMissileGUIEnabled( acfmenupanel, (Classes.GunClass[class].type == "missile"), gunTbl ) end)
		end
        
        local data = acfmenupanel.CData.CaliberSelect:GetValue()
        if data then
            local gunTbl = acfmenupanel.WeaponData["Guns"][data]
            local class = gunTbl.gunclass
            
            local Classes = list.Get("ACFClasses")
            timer.Simple(0.01, function() SetMissileGUIEnabled( acfmenupanel, (Classes.GunClass[class].type == "missile"), gunTbl) end)
        end
        
    end
    
    
    
    
    local rootNodes = acfmenupanel.WeaponSelect:Root().ChildNodes:GetChildren()
    
    local gunsNode
    
    for k, node in pairs(rootNodes) do
        if node:GetText() == "Guns" then
            gunsNode = node
            break
        end
    end
    
    if gunsNode then
        local classNodes = gunsNode.ChildNodes:GetChildren()
        local gunClasses = list.Get("ACFClasses").GunClass
        
        for k, node in pairs(classNodes) do
            local gunNodeElement = node.ChildNodes
            
            if gunNodeElement then
                local gunNodes = gunNodeElement:GetChildren()
                
                for k, gun in pairs(gunNodes) do
                    local class = gunClasses[gun.mytable.gunclass]
                    
                    if (class and class.type == "missile") and not gun.ACFMOverridden then
                        local oldclick = gun.DoClick
                        
                        gun.DoClick = function(self)
                            local ret = oldclick(self)
                            CreateRackSelectGUI(self)
                        end
                        
                        gun.ACFMOverridden = true
                    end
                end
            else
                ErrorNoHalt("ACFM: Unable to find guns for class " .. node:GetText() .. ".\n")
            end
        end        
    else
        ErrorNoHalt("ACFM: Unable to find the ACF Guns node.")
    end
	
	AddDetectionNode(acfmenupanel)
    
end




function AddDetectionNode(panel)
	
	local radarClasses = ACF.Classes.Radar
	local radars = ACF.Weapons.Radar
	
	if radarClasses and radars then
	
		local radar = panel.WeaponSelect:AddNode("Radar")	
	
	
		local nodes = {}
		
		for k, v in pairs(radarClasses) do
			
			nodes[k] = radar:AddNode( v.name or "No Name" )
		
		end
	
		
			
		for Type, Ent in pairs(radars) do	
			
			local curNode = nodes[Ent.class]
			
			if curNode then
				local EndNode = curNode:AddNode( Ent.name or "No Name" )
				EndNode.mytable = Ent
				
				function EndNode:DoClick()
					RunConsoleCommand( "acfmenu_type", self.mytable.type )
					acfmenupanel:UpdateDisplay( self.mytable )
				end
				
				EndNode.Icon:SetImage( "icon16/newspaper.png" )
			end
		end
			
		
	end

end




function FindACFMenuPanel()
    if acfmenupanel then
        ModifyACFMenu(acfmenupanel)
        timer.Remove("FindACFMenuPanel")
    end
end




timer.Create("FindACFMenuPanel", 0.1, 0, FindACFMenuPanel)