--[[------------------------
    1.- This is the file that displays the main menu, such as guns, ammo, mobility and subfolders.
   
    2.- Almost everything here has been documented, you should find the responsible function easily.

    3.- If you are going to do changes, please not to be a shitnuckle and write a note alongside the code that you´ve changed/edited. This should avoid issues with future developers.

]]--------------------------
function PANEL:Init( ) 

   acfmenupanel = self.Panel
   
   -- // height
   self:SetTall( surface.ScreenHeight() - 150 )
   
   -- //Weapon Select   
   self.WeaponSelect = vgui.Create( "DTree", self )

    -- //Tables definition
   self.WeaponData = ACF.Weapons
   radarClasses = list.Get("ACFClasses").Radar
   radars = list.Get( "ACFEnts").Radar

--[[=========================
   Table distribution
]]--=========================
   local Classes = list.Get("ACFClasses")
   self.GunClasses         = {}
   self.MisClasses         = {}
   self.ModClasses         = {}

   for ID,Table in pairs(Classes) do
      self.GunClasses[ID] = {}
      self.MisClasses[ID] = {}
      self.ModClasses[ID] = {}
      for ClassID,Class in pairs(Table) do
         Class.id = ClassID
         
         --Table content for Guns folder
         if Class.type == 'Gun' then    
         
            --print('Gun detected!')
            table.insert(self.GunClasses[ID], Class)
         
         --Table content for Missiles folder
         elseif Class.type == 'missile' then    
         
            --print('Missile detected!')
            table.insert(self.MisClasses[ID], Class)
         
         else
         
            --print('Modded Gun detected!')
            table.insert(self.ModClasses[ID], Class)
         
         end
         
      end

      table.sort(self.GunClasses[ID], function(a,b) return a.id < b.id end )
      table.sort(self.MisClasses[ID], function(a,b) return a.id < b.id end )
      table.sort(self.ModClasses[ID], function(a,b) return a.id < b.id end )

   end
   
   self.WeaponDisplay = {}
   local WeaponDisplay = list.Get("ACFEnts")
   
   for ID,Table in pairs(WeaponDisplay) do
      self.WeaponDisplay[ID] = {}
      for EntID,Data in pairs(Table) do
         table.insert(self.WeaponDisplay[ID], Data)
      end
      
      if ID == "Guns" then
         table.sort(self.WeaponDisplay[ID], function(a,b) if a.gunclass == b.gunclass then return a.caliber < b.caliber else return a.gunclass < b.gunclass end end)
      else
         table.sort(self.WeaponDisplay[ID], function(a,b) return a.id < b.id end )
      end
      
   end
   
--[[=========================
   ACE information folder
]]--=========================

   HomeNode = self.WeaponSelect:AddNode( "ACE Main Menu" , "icon16/world.png" ) --Main Menu folder
   HomeNode:SetExpanded(true)
   HomeNode.mytable = {}
   HomeNode.mytable.guicreate = (function( Panel, Table ) ACFHomeGUICreate( Table ) end or nil)
   HomeNode.mytable.guiupdate = (function( Panel, Table ) ACFHomeGUIUpdate( Table ) end or nil)

   function HomeNode:DoClick()
      acfmenupanel:UpdateDisplay(self.mytable)
   end
    

--[[=========================
   Guns folder
]]--========================= 
   local Guns = HomeNode:AddNode( "Guns" , "icon16/attach.png" ) --Guns folder
   
   for ClassID,Class in pairs(self.GunClasses["GunClass"]) do
   
      local SubNode = Guns:AddNode( Class.name or "No Name" , "icon16/brick.png" )
      
      for Type, Ent in pairs(self.WeaponDisplay["Guns"]) do 
         if Ent.gunclass == Class.id then
         
            local EndNode = SubNode:AddNode( Ent.name or "No Name")
            EndNode.mytable = Ent
            
            function EndNode:DoClick()
               RunConsoleCommand( "acfmenu_type", self.mytable.type )
               acfmenupanel:UpdateDisplay( self.mytable )
            end
            EndNode.Icon:SetImage( "icon16/newspaper.png" )
         end
      end
      
   end

--[[=========================
   Modded Guns folder   
]]--========================= 

--print(table.Count(self.ModClasses))

   if table.Count(self.ModClasses["GunClass"]) > 0 then   --this will only load any uncategorized, non official weapon of ace. If they are missiles, Gearboxes or Engines, they will be loaded on missiles, Gearboxes and Engines folder respectively!!
       
       local Mod = HomeNode:AddNode( "Modded Guns" , "icon16/attach.png") --Modded Guns folder
   
         for ClassID,Class in pairs(self.ModClasses["GunClass"]) do 
   
          local SubNode = Mod:AddNode( Class.name or "No Name" , "icon16/brick.png" )
      
          for Type, Ent in pairs(self.WeaponDisplay["Guns"]) do   
             if Ent.gunclass == Class.id then
         
                local EndNode = SubNode:AddNode( Ent.name or "No Name")
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
   
--[[=========================
   Missiles folder
]]--========================= 

   local Missiles = HomeNode:AddNode( "Missiles" , "icon16/wand.png" ) --Missiles folder
   
   for ClassID,Class in pairs(self.MisClasses["GunClass"]) do
   
      local SubNode = Missiles:AddNode( Class.name or "No Name" , "icon16/brick.png" )
      
      for Type, Ent in pairs(self.WeaponDisplay["Guns"]) do 
         if Ent.gunclass == Class.id then
         
            local EndNode = SubNode:AddNode( Ent.name or "No Name")
            EndNode.mytable = Ent
            
            function EndNode:DoClick()
               RunConsoleCommand( "acfmenu_type", self.mytable.type )
               acfmenupanel:UpdateDisplay( self.mytable )
            end
            EndNode.Icon:SetImage( "icon16/newspaper.png" )
         end
      end
      
   end

--[[=========================
   Ammo folder
]]--=========================     
   local Ammo = HomeNode:AddNode( "Ammo" , "icon16/box.png" ) --Ammo folder
   
   local AP = Ammo:AddNode("Armor Piercing Rounds", "icon16/brick.png" )
   local HE = Ammo:AddNode("High Explosive Rounds", "icon16/brick.png" )
   --local HEAT = Ammo:AddNode("Explosive Anti-Tank Rounds", "icon16/brick.png" )  --Unused. HEAT rounds are in HE folder.
   local SPECS = Ammo:AddNode("Special Purpose Rounds" , "icon16/brick.png" )
   
--[[=========================
   Ammo subfolder AP
]]--=========================       
   
   local APAttribs = list.Get("APRoundTypes") 
   self.APAttribs = {}
   for ID,Table in pairs(APAttribs) do
      Table.id = ID
      table.insert(self.APAttribs, Table)
   end
   table.sort(self.APAttribs, function(a,b) return a.id < b.id end ) 
   
   
   for AmmoID,AmmoTable in pairs(self.APAttribs) do
      
      local EndNode = AP:AddNode( AmmoTable.name or "No Name" )
      EndNode.mytable = AmmoTable
      function EndNode:DoClick()
         RunConsoleCommand( "acfmenu_type", self.mytable.type )
         acfmenupanel:UpdateDisplay( self.mytable )
      end
      EndNode.Icon:SetImage( "icon16/newspaper.png" )
      
   end

--[[=========================
   Ammo subfolder HE
]]--=========================       
   
   local HEAttribs = list.Get("HERoundTypes") 
   self.HEAttribs = {}
   for ID,Table in pairs(HEAttribs) do
      Table.id = ID
      table.insert(self.HEAttribs, Table)
   end
   table.sort(self.HEAttribs, function(a,b) return a.id < b.id end ) 
   
   
   for AmmoID,AmmoTable in pairs(self.HEAttribs) do
      
      local EndNode = HE:AddNode( AmmoTable.name or "No Name" )
      EndNode.mytable = AmmoTable
      function EndNode:DoClick()
         RunConsoleCommand( "acfmenu_type", self.mytable.type )
         acfmenupanel:UpdateDisplay( self.mytable )
      end
      EndNode.Icon:SetImage( "icon16/newspaper.png" )
      
   end

--[[=========================
   Ammo subfolder SPECS
]]--=========================       
   
   local SPECSAttribs = list.Get("SPECSRoundTypes") --local RoundAttribs = list.Get("ACFRoundTypes")
   self.SPECSAttribs = {}
   for ID,Table in pairs(SPECSAttribs) do
      Table.id = ID
      table.insert(self.SPECSAttribs, Table)
   end
   table.sort(self.SPECSAttribs, function(a,b) return a.id < b.id end ) 
   
   
   for AmmoID,AmmoTable in pairs(self.SPECSAttribs) do
      
      local EndNode = SPECS:AddNode( AmmoTable.name or "No Name" )
      EndNode.mytable = AmmoTable
      function EndNode:DoClick()
         RunConsoleCommand( "acfmenu_type", self.mytable.type )
         acfmenupanel:UpdateDisplay( self.mytable )
      end
      EndNode.Icon:SetImage( "icon16/newspaper.png" )
      
   end
      
--[[=========================
   Mobility folder
]]--=========================
   local Mobility       = HomeNode:AddNode( "Mobility" , "icon16/car.png" )   --Mobility folder
   local Gearboxes      = Mobility:AddNode( "Gearboxes" , "icon16/brick.png"  )
   local FuelTanks      = Mobility:AddNode( "Fuel Tanks" , "icon16/brick.png"  )
   local Engines        = Mobility:AddNode("Engines" , "icon16/brick.png" )
   
   local EngineSubcats  = {}
        
   for _, MobilityTable in pairs(self.WeaponDisplay["Mobility"]) do
      local Categories  = EngineSubcats
      local NodeAdd     = Mobility

      if MobilityTable.ent == "acf_engine" then
         NodeAdd = Engines
      elseif MobilityTable.ent == "acf_gearbox" then
         NodeAdd = Gearboxes
      elseif MobilityTable.ent == "acf_fueltank" then
         NodeAdd = FuelTanks
      end

      if MobilityTable.fuel then
         local Category = Categories[MobilityTable.fuel]
         
         if not Category then
            local Node = NodeAdd:AddNode(MobilityTable.fuel , "icon16/brick.png")
         
            Category = {
               _Node = Node,
               Default = Node:AddNode("Miscellaneous" , "icon16/brick.png")
            }
            
            Categories[MobilityTable.fuel] = Category
         end
      
         Categories  = Category
         NodeAdd     = Category._Node
      end
      
      if MobilityTable.category and not Categories[MobilityTable.category] then
         Categories[MobilityTable.category] = NodeAdd:AddNode(MobilityTable.category , "icon16/brick.png")
      end
   end 
                
   for MobilityID,MobilityTable in pairs(self.WeaponDisplay["Mobility"]) do   
      
      local NodeAdd = Mobility
      
      if MobilityTable.ent == "acf_engine" then

         local FuelCategory   = EngineSubcats[MobilityTable.fuel]
         local Category       = MobilityTable.category
         local Node           = Category and FuelCategory[Category] or FuelCategory.Default
         
         NodeAdd = Node
         
      elseif MobilityTable.ent == "acf_gearbox" then
         NodeAdd = Gearboxes
         if(MobilityTable.category) then
            NodeAdd = EngineSubcats[MobilityTable.category]
         else
            NodeAdd = EngineSubcats["miscg"]
         end
         
      elseif MobilityTable.ent == "acf_fueltank" then
         NodeAdd = FuelTanks
         if (MobilityTable.category) then
            NodeAdd = EngineSubcats[MobilityTable.category]
         end
      end
      
      local EndNode = NodeAdd:AddNode( MobilityTable.name or "No Name" )
      EndNode.mytable = MobilityTable
      function EndNode:DoClick()
         RunConsoleCommand( "acfmenu_type", self.mytable.type )
         acfmenupanel:UpdateDisplay( self.mytable )
      end
      EndNode.Icon:SetImage( "icon16/newspaper.png" )

   end

--[[=========================
   Sensor folder
]]--=========================
   local sensors     = HomeNode:AddNode("Sensors" , "icon16/transmit.png") --Sensor folder name
   local radar       = sensors:AddNode("Radar" , "icon16/brick.png"  ) --Radar subfolder
   local antimissile = radar:AddNode("Anti-Missile Radar" , "icon16/brick.png"  )
   local tracking    = radar:AddNode("Tracking Radar", "icon16/brick.png")
   
   local nods = {}
   
   if radarClasses then
      for k, v in pairs(radarClasses) do  --calls subfolders
         if v.type == "Tracking-Radar" then
            nods[k] = tracking:AddNode( v.name or "No Name" , "icon16/brick.png"   )
         elseif v.type == "Anti-missile" then
            nods[k] = antimissile:AddNode( v.name or "No Name" , "icon16/brick.png"   )
         end
      end

      for _, Ent in pairs(radars) do --calls subfolders content   

         local curNode = nods[Ent.class]     --print(Ent.class)

         if curNode then

            local EndNode = curNode:AddNode( Ent.name or "No Name" )
            EndNode.mytable = Ent
            
            function EndNode:DoClick()
               RunConsoleCommand( "acfmenu_type", self.mytable.type )
               acfmenupanel:UpdateDisplay( self.mytable )
            end   
               EndNode.Icon:SetImage( "icon16/newspaper.png" )
         end
      end --end radar folder
  
   end

--[[=========================
   Settings folder
]]--=========================
   local OptionsNode = self.WeaponSelect:AddNode( "Settings" ) --Options folder
   
   local CLNod    = OptionsNode:AddNode("Client" , "icon16/user.png")--Client folder
   local SVNod    = OptionsNode:AddNode("Server", "icon16/cog.png")--Server folder
   
   CLNod.mytable  = {}
   SVNod.mytable  = {}
   
   CLNod.mytable.guicreate = (function( Panel, Table ) ACFCLGUICreate( Table ) end or nil)   
   SVNod.mytable.guicreate = (function( Panel, Table ) ACFSVGUICreate( Table ) end or nil)
   
   function CLNod:DoClick()
      acfmenupanel:UpdateDisplay(self.mytable)
   end
   function SVNod:DoClick()
      acfmenupanel:UpdateDisplay(self.mytable)
   end
   OptionsNode.Icon:SetImage( "icon16/wrench_orange.png" )
   
--[[=========================
   Contact & Support folder
]]--=========================
    local Contact =  self.WeaponSelect:AddNode( "Contact Us" , "icon16/feed.png" ) --Options folder
   Contact.mytable = {}
   
   Contact.mytable.guicreate = (function( Panel, Table ) ContactGUICreate( Table ) end or nil)
    
   function Contact:DoClick()
      acfmenupanel:UpdateDisplay(self.mytable)
   end      
   
end

--[[
------------------------------------
---Think   // needed?
------------------------------------
function PANEL:Think( )

end
]]
function PANEL:UpdateDisplay( Table )
   
   RunConsoleCommand( "acfmenu_id", Table.id or 0 )
   
   --If a previous display exists, erase it
   if ( acfmenupanel.CustomDisplay ) then
      acfmenupanel.CustomDisplay:Clear(true)
      acfmenupanel.CustomDisplay = nil
      acfmenupanel.CData = nil
   end
   --Create the space to display the custom data
   acfmenupanel.CustomDisplay = vgui.Create( "DPanelList", acfmenupanel )  
      acfmenupanel.CustomDisplay:SetSpacing( 10 )
      acfmenupanel.CustomDisplay:EnableHorizontal( false ) 
      acfmenupanel.CustomDisplay:EnableVerticalScrollbar( false ) 
      acfmenupanel.CustomDisplay:SetSize( acfmenupanel:GetWide(), acfmenupanel:GetTall() )
   
   if not acfmenupanel["CData"] then
      --Create a table for the display to store data
      acfmenupanel["CData"] = {} 
   end
      
   acfmenupanel.CreateAttribs = Table.guicreate
   acfmenupanel.UpdateAttribs = Table.guiupdate
   acfmenupanel:CreateAttribs( Table )
   
   acfmenupanel:PerformLayout()

end

function PANEL:CreateAttribs( Table )
   --You overwrite this with your own function, defined in the ammo definition file, so each ammotype creates it's own menu
end

function PANEL:UpdateAttribs( Table )
   --You overwrite this with your own function, defined in the ammo definition file, so each ammotype creates it's own menu
end

function PANEL:PerformLayout()
   
   --Starting positions
   local vspacing = 10
   local ypos = 0
   
   --Selection Tree panel
   acfmenupanel.WeaponSelect:SetPos( 0, ypos )
   acfmenupanel.WeaponSelect:SetSize( acfmenupanel:GetWide(), ScrH()*0.4 )
   ypos = acfmenupanel.WeaponSelect.Y + acfmenupanel.WeaponSelect:GetTall() + vspacing
   
   if acfmenupanel.CustomDisplay then
      --Custom panel
      acfmenupanel.CustomDisplay:SetPos( 0, ypos )
      acfmenupanel.CustomDisplay:SetSize( acfmenupanel:GetWide(), acfmenupanel:GetTall() - acfmenupanel.WeaponSelect:GetTall() - 10 )
      ypos = acfmenupanel.CustomDisplay.Y + acfmenupanel.CustomDisplay:GetTall() + vspacing
   end
   
end

--[[=========================
   ACE information folder content
]]--=========================
function ACFHomeGUICreate( Table )

   if not acfmenupanel.CustomDisplay then return end

   local color
   local versionstring

   if ACF.CurrentVersion > 0 then
   if ACF.Version >= ACF.CurrentVersion then
      versionstring = "Up To Date"
      color = Color(0,225,0,255)
   else
      versionstring = "Out Of Date"
      color = Color(225,0,0,255)

   end
   else
      versionstring = "No internet Connection available!"
      color = Color(225,0,0,255)
   end

   versiontext = "GitHub Version: "..ACF.CurrentVersion.."\nCurrent Version: "..ACF.Version

   acfmenupanel["CData"]["VersionInit"] = vgui.Create( "DLabel" )
   acfmenupanel["CData"]["VersionInit"]:SetText(versiontext)   
   acfmenupanel["CData"]["VersionInit"]:SetTextColor( Color( 0, 0, 0) )
   acfmenupanel["CData"]["VersionInit"]:SizeToContents()
   acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"]["VersionInit"] )
   
   
   acfmenupanel["CData"]["VersionText"] = vgui.Create( "DLabel" )

   acfmenupanel["CData"]["VersionText"]:SetFont( 'Trebuchet18' )
   acfmenupanel["CData"]["VersionText"]:SetText("ACE Is "..versionstring.."!\n\n")
   acfmenupanel["CData"]["VersionText"]:SetTextColor( Color( 0, 0, 0) )
   acfmenupanel["CData"]["VersionText"]:SizeToContents() 
   
   acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"]["VersionText"] )
   -- end version
   
   acfmenupanel:CPanelText("Header", "Changelog")  --changelog screen
   
--[[=========================
   Changelog table maker
]]--========================= 
   
   if acfmenupanel.Changelog then
      acfmenupanel["CData"]["Changelist"] = vgui.Create( "DTree" )

      for i = 0, table.maxn(acfmenupanel.Changelog)-100 do 
         
         local k = table.maxn(acfmenupanel.Changelog)-i
         
          local Node = acfmenupanel["CData"]["Changelist"]:AddNode( "Rev "..k )
               Node.mytable = {}
               Node.mytable["rev"] = k
                function Node:DoClick()
            
                acfmenupanel:UpdateAttribs( Node.mytable )
               
             end        
          Node.Icon:SetImage( "icon16/newspaper.png" )
      
      end

      acfmenupanel.CData.Changelist:SetSize( acfmenupanel.CustomDisplay:GetWide(), 60 )
      
      acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"]["Changelist"] )
      
      acfmenupanel.CustomDisplay:PerformLayout()
      
      acfmenupanel:UpdateAttribs( {rev = table.maxn(acfmenupanel.Changelog)} )
   end
   
end

--[[=========================
   ACE information folder content updater
]]--=========================
function ACFHomeGUIUpdate( Table )
   
   acfmenupanel:CPanelText("Changelog", acfmenupanel.Changelog[Table["rev"]])
   acfmenupanel.CustomDisplay:PerformLayout()
   
   local color
   local versionstring
   
   if ACF.CurrentVersion > 0 then
   if ACF.Version >= ACF.CurrentVersion then
      versionstring = "Up To Date"
      color = Color(0,225,0,255)
   else
      versionstring = "Out Of Date"
      color = Color(225,0,0,255)

   end
   else
      versionstring = "No internet Connection available!"
      color = Color(225,0,0,255)
   end
   
   local txt
   
   if ACF.CurrentVersion > 0 then
      txt = "ACE Is "..versionstring.."!\n\n"
   else
      txt = versionstring
   end
   
   acfmenupanel["CData"]["VersionText"]:SetText(txt)
   acfmenupanel["CData"]["VersionText"]:SetTextColor( Color( 0, 0, 0) )
   acfmenupanel["CData"]["VersionText"]:SetColor(color) 
   acfmenupanel["CData"]["VersionText"]:SizeToContents() 
   
end

--[[=========================
   Changelog.txt
]]--=========================

function ACFChangelogHTTPCallBack(contents , size)
   local Temp = string.Explode( "*", contents )
   
   acfmenupanel.Changelog = {}  --changelog table
   for Key,String in pairs(Temp) do
      
      acfmenupanel.Changelog[tonumber(string.sub(String,2,4))] = string.Trim(string.sub(String, 5))
      
   end
   
      table.SortByKey(acfmenupanel.Changelog,true)
   
   
   --print('1.-'..acfmenupanel.Changelog[100]..'\n2.-'..acfmenupanel.Changelog[101]..'\n3.-'..acfmenupanel.Changelog[102])
   
   local Table = {}
      Table.guicreate = (function( Panel, Table ) ACFHomeGUICreate( Table ) end or nil)
      Table.guiupdate = (function( Panel, Table ) ACFHomeGUIUpdate( Table ) end or nil)
   acfmenupanel:UpdateDisplay( Table )
   
end

http.Fetch("http://raw.github.com/RedDeadlyCreeper/ArmoredCombatExtended/master/changelog.txt", ACFChangelogHTTPCallBack, function() end)

--[[=========================
   Clientside folder content
]]--=========================
function ACFCLGUICreate( Table )  

   local Client = acfmenupanel["CData"]["Options"]

   Client = vgui.Create( "DLabel" )
   Client:SetPos( 0, 0 )
   Client:SetColor( Color(10,10,10) ) 
   Client:SetText("ACE - Client Side Control Panel")
   Client:SetFont("DermaDefaultBold")
   Client:SizeToContents()  
   acfmenupanel.CustomDisplay:AddItem( Client )
   
   local Sub = vgui.Create( "DLabel" )
   Sub:SetPos( 0, 0 )
   Sub:SetColor( Color(10,10,10) ) 
   Sub:SetText("Client Side parameters can be adjusted here.")
   Sub:SizeToContents()  
   acfmenupanel.CustomDisplay:AddItem( Sub )

   local Effects = vgui.Create( "DForm" )
   Effects:SetName("Rendering")

   Effects:CheckBox("Allow missile motor lighting", "ACFM_MissileLights")
   Effects:ControlHelp( "Enable dynamic lights to be emitted from missile motors (impacts performance!)" )

   Effects:CheckBox("Draw Mobility rope links", "ACF_MobilityRopeLinks")
   Effects:ControlHelp( "Allow you to see the links between engines and gearboxes (requires dupe restart)" )

   Effects:NumSlider( "Particle Multipler", "acf_cl_particlemul", 1, 5, 0 )
   Effects:ControlHelp( "Adjusts the particles that will be created by ACE. Keep this low for better performance." )

   acfmenupanel.CustomDisplay:AddItem( Effects )   

end

--[[=========================
   Serverside folder content
]]--=========================
function ACFSVGUICreate( Table )   --Serverside folder content

   local ply = LocalPlayer()
   if not IsValid(ply) then return end
   if not ply:IsSuperAdmin() then return end

   local Server = acfmenupanel["CData"]["Options"]

   Server = vgui.Create( "DLabel" )
   Server:SetPos( 0, 0 )
   Server:SetColor( Color(10,10,10) ) 
   Server:SetText("ACE - Server Side Control Panel")
   Server:SetFont("DermaDefaultBold")
   Server:SizeToContents()  
   acfmenupanel.CustomDisplay:AddItem( Server )
   
   local Sub = vgui.Create( "DLabel" )
   Sub:SetPos( 0, 0 )
   Sub:SetColor( Color(10,10,10) ) 
   Sub:SetText("Server Side parameters can be adjusted here")
   Sub:SizeToContents()  
   acfmenupanel.CustomDisplay:AddItem( Sub )

   if ACE.IsDedicated then ACFSVGUIERROR() return end --For dedicated servers, change the values directly in code. Weird

   local General = vgui.Create( "DForm" )
   General:SetName("General")

   General:CheckBox("Enable HE push", "acf_hepush")
   General:ControlHelp( "Allow HE to push contraptions away" )

   General:CheckBox("Enable Recoil force", "acf_recoilpush")
   General:ControlHelp( "Gun's recoil will push the contraption back when firing" )

   General:NumSlider( "Debris Life Time", "acf_debris_lifetime", 0, 60, 2 )
   General:ControlHelp( "How many seconds debris will stand on the map before being deleted (0 means never)." )

   General:NumSlider( "Child debris chance", "acf_debris_children", 0, 1, 2 )
   General:ControlHelp( "Adjusts the chance of create debris when a contraption's gate have been destroyed" )

   --General:NumSlider( "Year", "acf_year", 1900, 2021, 0 )
   --General:ControlHelp( "Changes the year. This will affect the available weaponry (requires restart)." )

   acfmenupanel.CustomDisplay:AddItem( General )

   local Spall = vgui.Create( "DForm" )
   Spall:SetName("Spalling")

   Spall:CheckBox("Enable Spalling", "acf_spalling")
   Spall:ControlHelp( "Enable additional spalling to be created during penetrations. Disable this to have better performance." )

   Spall:NumSlider( "Spalling Multipler", "acf_spalling_multipler", 1, 5, 0 )
   Spall:ControlHelp( "How much Spalling will be created during impacts? Applies for spalling created by impacts" )

   acfmenupanel.CustomDisplay:AddItem( Spall )

   local Legal = vgui.Create( "DForm" )
   Legal:SetName("Legality")

   Legal:CheckBox("Enable Legality checks", "acf_legalcheck")
   Legal:ControlHelp( "Enable the legality checks, which will punish with a lock time any stuff considered illegal." )

   Legal:CheckBox( "Allow not solid", "acf_legal_ignore_solid" )
   Legal:ControlHelp( "allow to use not solid" )

   Legal:CheckBox( "Allow any model", "acf_legal_ignore_model" )
   Legal:ControlHelp( "Allow ace ents to use any model" )

   Legal:CheckBox( "Allow any mass", "acf_legal_ignore_mass" )
   Legal:ControlHelp( "Allow ace ents to use any weight" )

   Legal:CheckBox( "Allow any material", "acf_legal_ignore_material" )
   Legal:ControlHelp( "Allow ace ents to use any material type" )

   Legal:CheckBox( "Allow any inertia", "acf_legal_ignore_inertia" )
   Legal:ControlHelp( "Allow ace ents to have any inertia in it" )

   Legal:CheckBox("Allow makesphere", "acf_legal_ignore_makesphere")
   Legal:ControlHelp( "Allow ace ents to have makesphere" )

   Legal:CheckBox( "Allow visclip", "acf_legal_ignore_visclip" )
   Legal:ControlHelp( "ace ents can have visclip at any case" )

   Legal:CheckBox( "Allow any parent", "acf_legal_ignore_parent" )
   Legal:ControlHelp( "Allow to bypass gate requirement" )

   acfmenupanel.CustomDisplay:AddItem( Legal )  

--[[
   local Sound = vgui.Create( "DForm" )
   Sound:SetName("Sound Extension placeholder name")

   Spall:CheckBox("Enable Spalling", "acf_spalling")
   Spall:ControlHelp( "Enable additional spalling to be created during penetrations. Disable this to have better performance." )

   acfmenupanel.CustomDisplay:AddItem( Sound )  

   local PP = vgui.Create( "DForm" )
   PP:SetName("Damage protection - DOESNT WORK")

   PP:CheckBox("Enable ACE damage permissions", "acf_enable_dp")
   PP:ControlHelp( "Sets a damage protection system into the server (requires CPPI and restart)" )

   PP:CheckBox("Enable ACE protection if in godmode", "TEST")
   PP:ControlHelp( "if enabled, users will not deal any damage if they have godmode." )   

   acfmenupanel.CustomDisplay:AddItem( PP )
]]--
end
function ACFSVGUIERROR()

   local Note = vgui.Create( "DLabel" )
   Note:SetPos( 0, 0 )
   Note:SetColor( Color(10,10,10) ) 
   Note:SetText("Not available in this moment")
   Note:SizeToContents()  
   acfmenupanel.CustomDisplay:AddItem( Note )

end


--[[=========================
   Contact folder content
]]--=========================
function ContactGUICreate( Table )

   acfmenupanel["CData"]["Contact"] = vgui.Create( "DLabel" )
   acfmenupanel["CData"]["Contact"]:SetPos( 0, 0 )
   acfmenupanel["CData"]["Contact"]:SetColor( Color(10,10,10) ) 
   acfmenupanel["CData"]["Contact"]:SetText("Contact Us")
   acfmenupanel["CData"]["Contact"]:SetFont("Trebuchet24")
   acfmenupanel["CData"]["Contact"]:SizeToContents()  
   acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"]["Contact"] )
   
   acfmenupanel:CPanelText('desc1','If you want to contribute to ACE by providing us feedback, report bugs or tell us suggestions about new stuff to be added, our discord is a good place.')
   acfmenupanel:CPanelText("desc2","Don't forget to check out our wiki, contains valuable information about how to use this addon. It's on WIP, but expect more content in future.")
   
   local Discord = vgui.Create("DButton")
   Discord:SetText( "Join our Discord!" )
   Discord:SetPos(0,0)
   Discord:SetSize(250,30)
   Discord.DoClick = function()
       gui.OpenURL( 'https://discord.gg/Y8aEYU6' ) 
   end
   acfmenupanel.CustomDisplay:AddItem( Discord )
   
   local Wiki = vgui.Create("DButton")
   Wiki:SetText( "Open Wiki" )
   Wiki:SetPos(0,0)
   Wiki:SetSize(250,30)
   Wiki.DoClick = function()
       gui.OpenURL( 'https://github.com/RedDeadlyCreeper/ArmoredCombatExtended/wiki' )
   end
   acfmenupanel.CustomDisplay:AddItem( Wiki )
   
   local Guide = vgui.Create("DButton")
   Guide:SetText( "ACE guidelines" )
   Guide:SetPos(0,0)
   Guide:SetSize(250,30)
   Guide.DoClick = function()
       gui.OpenURL( 'https://docs.google.com/document/d/1yaHq4Lfjad4KKa0Jg9s-5lCpPVjV7FE4HXoGaKpi4Fs/edit' )
   end
   acfmenupanel.CustomDisplay:AddItem( Guide )

end

--[[=========================
   Ammo & Gun selection content
]]--=========================
function PANEL:AmmoSelect( Blacklist )
   
   if not acfmenupanel.CustomDisplay then return end
   if not Blacklist then Blacklist = {} end
   
   if not acfmenupanel.AmmoData then

      acfmenupanel.AmmoData = {}
      acfmenupanel.AmmoData["Id"] = "Ammo2x4x4"  --default Ammo dimension on list
      acfmenupanel.AmmoData["Type"] = "Ammo"
      acfmenupanel.AmmoData["Data"] = acfmenupanel.WeaponData["Guns"]["12.7mmMG"]["round"]

      ModelDisplay = "models/ammocrates/ammocrate_2x4x4.mdl"

   end
--[[=========================
   Creating the ammo crate selection
]]--========================= 

   acfmenupanel.CData.CrateSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )   --Every display and slider is placed in the Round table so it gets trashed when selecting a new round type  
   acfmenupanel.CData.CrateSelect:SetSize(100, 30)
   
   for Key, Value in pairs( acfmenupanel.WeaponDisplay["Ammo"] ) do
      
      acfmenupanel.CData.CrateSelect:AddChoice( Value.id , Key ) --Creates the list
         
   end

   acfmenupanel.CData.CrateSelect.OnSelect = function( index , value , data )   -- calls the ID of the list

   RunConsoleCommand( "acfmenu_id", data )
   acfmenupanel.AmmoData["Id"] = data
         
   if acfmenupanel.CData.CrateDisplay then

      cratemodel = ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].model
      acfmenupanel.CData.CrateDisplay:SetModel(cratemodel)
      acfmenupanel:CPanelText("CrateDesc", ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].desc)

      --DisEnt = acfmenupanel.CData.CrateDisplay:GetEntity()

   end

   self:UpdateAttribs()

end
      
   acfmenupanel.CData.CrateSelect:SetText(acfmenupanel.AmmoData["Id"])
   RunConsoleCommand( "acfmenu_id", acfmenupanel.AmmoData["Id"] )
      
   acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.CrateSelect )
   
--[[=========================
   Creating the caliber selection display
]]--========================= 

   acfmenupanel.CData.CaliberSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay ) 
   acfmenupanel.CData.CaliberSelect:SetSize(100, 30)
   
      for Key, Value in pairs( acfmenupanel.WeaponDisplay["Guns"] ) do
      
         if( !table.HasValue( Blacklist, Value.gunclass ) ) then
            acfmenupanel.CData.CaliberSelect:AddChoice( Value.id , Key )
         end
         
      end
      
      acfmenupanel.CData.CaliberSelect.OnSelect = function( index , value , data )
         acfmenupanel.AmmoData["Data"] = acfmenupanel.WeaponData["Guns"][data]["round"]
         self:UpdateAttribs()
         self:UpdateAttribs() --Note : this is intentional
      end
      
   acfmenupanel.CData.CaliberSelect:SetText(acfmenupanel.AmmoData["Data"]["id"])
      
   acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.CaliberSelect )

--[[=========================
   Creating the Model display
]]--========================= 

   --Used to create the general model display
   if not acfmenupanel.CData.CrateDisplay then
   
   acfmenupanel:CPanelText("CrateDesc", ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].desc)
   
   acfmenupanel.CData.CrateDisplay = vgui.Create( "DModelPanel" , acfmenupanel.CustomDisplay )
   acfmenupanel.CData.CrateDisplay:SetSize(200,200)  
   acfmenupanel.CData.CrateDisplay:SetCamPos( Vector( 250, 500, 250 ) )
   acfmenupanel.CData.CrateDisplay:SetLookAt( Vector( 0, 0, 0 ) )
   acfmenupanel.CData.CrateDisplay:SetFOV( 20 ) 
   acfmenupanel.CData.CrateDisplay:SetModel(ACF.Weapons.Ammo[acfmenupanel.AmmoData["Id"]].model)   
   acfmenupanel.CData.CrateDisplay.LayoutEntity = function( entity ) end
   
   acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.CrateDisplay )
   
   end
end

function PANEL:AmmoSlider(Name, Value, Min, Max, Decimals, Title, Desc) --Variable name in the table, Value, Min value, Max Value, slider text title, slider decimeals, description text below slider 

   if not acfmenupanel["CData"][Name] then
      
      acfmenupanel["CData"][Name] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
      acfmenupanel["CData"][Name].Label:SetSize( 0 ) --Note : this is intentional 
      acfmenupanel["CData"][Name]:SetTall( 50 ) -- make the slider taller to fit the new label
      acfmenupanel["CData"][Name]:SetMin( 0 )
      acfmenupanel["CData"][Name]:SetMax( 1000 )
      acfmenupanel["CData"][Name]:SetDark( true )
      acfmenupanel["CData"][Name]:SetDecimals( Decimals )

      acfmenupanel["CData"][Name.."_label"] = vgui.Create( "DLabel", acfmenupanel["CData"][Name]) -- recreating the label
      acfmenupanel["CData"][Name.."_label"]:SetPos( 0,0 )
      acfmenupanel["CData"][Name.."_label"]:SetText( Title )
      acfmenupanel["CData"][Name.."_label"]:SizeToContents()
      acfmenupanel["CData"][Name.."_label"]:SetTextColor( Color( 0, 0, 0) )

      if acfmenupanel.AmmoData[Name] then
            acfmenupanel["CData"][Name]:SetValue(acfmenupanel.AmmoData[Name])
      end

      acfmenupanel["CData"][Name].OnValueChanged = function( slider, val )

      if acfmenupanel.AmmoData[Name] != val then

         acfmenupanel.AmmoData[Name] = val
            self:UpdateAttribs( Name )
         end

      end

      acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name] )

   end

   acfmenupanel["CData"][Name]:SetMin( Min ) 
   acfmenupanel["CData"][Name]:SetMax( Max )
   acfmenupanel["CData"][Name]:SetValue( Value )
   
   if not acfmenupanel["CData"][Name.."_text"] and Desc then

      acfmenupanel["CData"][Name.."_text"] = vgui.Create( "DLabel" )
      acfmenupanel["CData"][Name.."_text"]:SetText( Desc or "" )
      acfmenupanel["CData"][Name.."_text"]:SetTextColor( Color( 0, 0, 0) )
      acfmenupanel["CData"][Name.."_text"]:SetTall( 20 )
      acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name.."_text"] )

   end

   acfmenupanel["CData"][Name.."_text"]:SetText( Desc )
   acfmenupanel["CData"][Name.."_text"]:SetSize( acfmenupanel.CustomDisplay:GetWide(), 10 )
   acfmenupanel["CData"][Name.."_text"]:SizeToContentsX()
   
end

-- Variable name in the table, slider text title, slider decimeals, description text below slider 
function PANEL:AmmoCheckbox(Name, Title, Desc) 

   if not acfmenupanel["CData"][Name] then

      acfmenupanel["CData"][Name] = vgui.Create( "DCheckBoxLabel" )
      acfmenupanel["CData"][Name]:SetText( Title or "" )
      acfmenupanel["CData"][Name]:SetTextColor( Color( 0, 0, 0) )
      acfmenupanel["CData"][Name]:SizeToContents()

      if acfmenupanel.AmmoData[Name] != nil then
         acfmenupanel["CData"][Name]:SetChecked(acfmenupanel.AmmoData[Name])
      else
         acfmenupanel.AmmoData[Name] = false
      end

      acfmenupanel["CData"][Name].OnChange = function( check, bval )
         acfmenupanel.AmmoData[Name] = bval

         self:UpdateAttribs( {Name, bval} )

      end

      acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name] )

   end

   acfmenupanel["CData"][Name]:SetText( Title )
   
   
   if not acfmenupanel["CData"][Name.."_text"] and Desc then

      acfmenupanel["CData"][Name.."_text"] = vgui.Create( "DLabel" )
      acfmenupanel["CData"][Name.."_text"]:SetText( Desc or "" )
      acfmenupanel["CData"][Name.."_text"]:SetTextColor( Color( 0, 0, 0) )
      acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name.."_text"] )

   end

   acfmenupanel["CData"][Name.."_text"]:SetText( Desc )
   acfmenupanel["CData"][Name.."_text"]:SetSize( acfmenupanel.CustomDisplay:GetWide(), 10 )
   acfmenupanel["CData"][Name.."_text"]:SizeToContentsX()
   
end

function PANEL:AmmoStats(RoundLenght, MaxTotalLenght ,MuzzleVel ,MaxPen)

    acfmenupanel:CPanelText("AmmoStats", "Round Length : "..RoundLenght.."/"..MaxTotalLenght.." cms\n\nMuzzle Velocity : "..MuzzleVel.." m\\s\nMax penetration : "..MaxPen.." mm RHA") --Total round length (Name, Desc)
   
end

--[[-------------------------------------
    PANEL:CPanelText(Name, Desc, Font)
   
   1-Name: Identifier of this text
   2-Desc: The content of this text
   3-Font: The Font to be used in this text. Leave it empty or nil to use the default one
]]---------------------------------------
function PANEL:CPanelText(Name, Desc, Font)

   if not acfmenupanel["CData"][Name.."_text"] then

      acfmenupanel["CData"][Name.."_text"] = vgui.Create( "DLabel" )

      acfmenupanel["CData"][Name.."_text"]:SetText( Desc or "" )
      acfmenupanel["CData"][Name.."_text"]:SetTextColor( Color( 0, 0, 0) )

      if Font then acfmenupanel["CData"][Name.."_text"]:SetFont( Font ) end

      acfmenupanel["CData"][Name.."_text"]:SetWrap(true)
      acfmenupanel["CData"][Name.."_text"]:SetAutoStretchVertical( true )

      acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name.."_text"] )

   end

   acfmenupanel["CData"][Name.."_text"]:SetText( Desc )
   acfmenupanel["CData"][Name.."_text"]:SetSize( acfmenupanel.CustomDisplay:GetWide(), 10 )
   acfmenupanel["CData"][Name.."_text"]:SizeToContentsY()

end