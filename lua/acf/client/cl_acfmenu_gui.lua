function PANEL:Init( ) 

	acfmenupanel = self.Panel
	
	-- // height
	self:SetTall( surface.ScreenHeight() - 150 )
	
	-- //Weapon Select	
	self.WeaponSelect = vgui.Create( "DTree", self )

    -- //Tables definition
	self.WeaponData = ACF.Weapons
	radarClasses = ACF.Classes.Radar
	radars = ACF.Weapons.Radar
	
--[[=========================
   Table distribution
]]--=========================
	local Classes = list.Get("ACFClasses")
	self.GunClasses = {}
	self.MisClasses = {}
	self.ModClasses = {}

	for ID,Table in pairs(Classes) do
		self.GunClasses[ID] = {}
		self.MisClasses[ID] = {}
		self.ModClasses[ID] = {}
		for ClassID,Class in pairs(Table) do
			Class.id = ClassID
			
			
			if Class.type == 'Gun' then    --Table content for Guns folder
			
			--print('Gun detected!')
			table.insert(self.GunClasses[ID], Class)
			
			elseif Class.type == 'missile' then    --Table content for Missiles folder
			
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
	
	local WeaponDisplay = list.Get("ACFEnts")
	self.WeaponDisplay = {}
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

print(table.Count(self.ModClasses))

	if table.Count(self.ModClasses["GunClass"]) > 0 then   --this will only load any uncategorized, non official weapon of ace. If they are missiles, Gearboxes or Engines, they will be loaded on missiles, Gearboxes and Engines folder repectetively!!
	    
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
   Ammo subfolder HEAT                 --Unused. HEAT rounds are in HE folder.
]]--=========================	   	
--[[	
	local HEATAttribs = list.Get("HEATRoundTypes") 
	self.HEATAttribs = {}
	for ID,Table in pairs(HEATAttribs) do
		Table.id = ID
		table.insert(self.HEATAttribs, Table)
	end
	table.sort(self.HEATAttribs, function(a,b) return a.id < b.id end )	
	
	
	for AmmoID,AmmoTable in pairs(self.HEATAttribs) do
		
		local EndNode = HEAT:AddNode( AmmoTable.name or "No Name" )
		EndNode.mytable = AmmoTable
		function EndNode:DoClick()
			RunConsoleCommand( "acfmenu_type", self.mytable.type )
			acfmenupanel:UpdateDisplay( self.mytable )
		end
		EndNode.Icon:SetImage( "icon16/newspaper.png" )
		
	end
]]--
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
	local Mobility = HomeNode:AddNode( "Mobility" , "icon16/car.png" )	--Mobility folder
	local Gearboxes = Mobility:AddNode( "Gearboxes" , "icon16/brick.png"  )
	local FuelTanks = Mobility:AddNode( "Fuel Tanks" , "icon16/brick.png"  )
	local Engines = Mobility:AddNode("Engines" , "icon16/brick.png" )
	
	local EngineSubcats = {}
        
	for _, MobilityTable in pairs(self.WeaponDisplay["Mobility"]) do
		local Categories = EngineSubcats
		local NodeAdd = Mobility

		if( MobilityTable.ent == "acf_engine" ) then
			NodeAdd = Engines
		elseif ( MobilityTable.ent == "acf_gearbox" ) then
			NodeAdd = Gearboxes
		elseif ( MobilityTable.ent == "acf_fueltank" ) then
			NodeAdd = FuelTanks
		end

		if not Categories["miscg"] then
			--Categories["miscg"] = Gearboxes:AddNode("Miscellaneous" , "icon16/brick.png")
			--Basics = Gearboxes:AddNode("Basic" , "icon16/brick.png")
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
		
			Categories = Category
			NodeAdd = Category._Node
		end
		
		if MobilityTable.category and not Categories[MobilityTable.category] then
			Categories[MobilityTable.category] = NodeAdd:AddNode(MobilityTable.category , "icon16/brick.png")
		end
	end 
                
	for MobilityID,MobilityTable in pairs(self.WeaponDisplay["Mobility"]) do   
		
		local NodeAdd = Mobility
		
		if MobilityTable.ent == "acf_engine" then
			local FuelCategory = EngineSubcats[MobilityTable.fuel]
			local Category = MobilityTable.category
			local Node = Category and FuelCategory[Category] or FuelCategory.Default
			
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
	local sensors = HomeNode:AddNode("Sensors" , "icon16/transmit.png") --Sensor folder name
	local radar = sensors:AddNode("Radar" , "icon16/brick.png"  ) --Radar subfolder
	local antimissile = radar:AddNode("Anti-Missile Radar" , "icon16/brick.png"  )
	
	local nods = {}
	
	for k, v in pairs(radarClasses) do  --calls subfolders		
		nods[k] = antimissile:AddNode( v.name or "No Name" , "icon16/brick.png"   )	
	end
    
	for Type, Ent in pairs(radars) do --calls subfolders content	
		local curNode = nods[Ent.class]		
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

--[[=========================
   Settings folder
]]--=========================
	local OptionsNode = self.WeaponSelect:AddNode( "Settings" ) --Options folder
	
	local CLNod = OptionsNode:AddNode("Client" , "icon16/user.png")--Client folder
	local SVNod = OptionsNode:AddNode("Server", "icon16/cog.png")--Server folder
	
	CLNod.mytable = {}
	SVNod.mytable = {}
	
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


------------------------------------
---Think   // needed?
------------------------------------
function PANEL:Think( )

end

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
	--start version
--Trebuchet18

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

	acfmenupanel["CData"]["VersionInit"] = vgui.Create( "DLabel" )
	
	versiontext = "GitHub Version: "..ACF.CurrentVersion.."\nCurrent Version: "..ACF.Version
	acfmenupanel["CData"]["VersionInit"]:SetText(versiontext)	
	acfmenupanel["CData"]["VersionInit"]:SetDark( true )
	acfmenupanel["CData"]["VersionInit"]:SizeToContents()
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"]["VersionInit"] )
	
	
	acfmenupanel["CData"]["VersionText"] = vgui.Create( "DLabel" )
	

    acfmenupanel["CData"]["VersionText"]:SetFont( 'Trebuchet18' )
	acfmenupanel["CData"]["VersionText"]:SetText("ACE Is "..versionstring.."!\n\n")
	acfmenupanel["CData"]["VersionText"]:SetDark( true )
	acfmenupanel["CData"]["VersionText"]:SetColor(color) 
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
	acfmenupanel["CData"]["VersionText"]:SetDark( true )
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

    acfmenupanel["CData"]["Options"] = vgui.Create( "DLabel" )
	acfmenupanel["CData"]["Options"]:SetPos( 0, 0 )
	acfmenupanel["CData"]["Options"]:SetColor( Color(10,10,10) ) 
	acfmenupanel["CData"]["Options"]:SetText("ACE - Client Side Control Panel")
	acfmenupanel["CData"]["Options"]:SetFont("DermaDefaultBold")
	acfmenupanel["CData"]["Options"]:SizeToContents()  
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"]["Options"] )
	
	local Sub = vgui.Create( "DLabel" )
	Sub:SetPos( 0, 0 )
	Sub:SetColor( Color(10,10,10) ) 
	Sub:SetText("Client Side parameters can be adjusted here.")
	Sub:SizeToContents()  
	acfmenupanel.CustomDisplay:AddItem( Sub )
	
	local MisLight = vgui.Create( "DCheckBoxLabel" , acfmenupanel["CData"]["Options"] )
	MisLight:SetPos(50,200)
	MisLight:SetText("Enable missiles emit light while their motors are burning? (Impact on performance!)")
	MisLight:SetTextColor( Color(10,10,10) )
	MisLight:SetConVar("ACFM_MissileLights")
	MisLight:SetValue( false )
	MisLight:SizeToContents()
	acfmenupanel.CustomDisplay:AddItem( MisLight )
	
	local Rope = vgui.Create( "DCheckBoxLabel" , acfmenupanel["CData"]["Options"] )
	Rope:SetPos(50,200)
	Rope:SetText("Draw Mobility rope links? (requires dupe respawn!)")
	Rope:SetTextColor( Color(10,10,10) )
	Rope:SetConVar("ACF_MobilityRopeLinks")
	Rope:SetValue( false )
	Rope:SizeToContents()
	acfmenupanel.CustomDisplay:AddItem( Rope )
		
end

--[[=========================
   Serverside folder content
]]--=========================
function ACFSVGUICreate( Table )   --Serverside folder content

    acfmenupanel["CData"]["Options"] = vgui.Create( "DLabel" )
	acfmenupanel["CData"]["Options"]:SetPos( 0, 0 )
	acfmenupanel["CData"]["Options"]:SetColor( Color(10,10,10) ) 
	acfmenupanel["CData"]["Options"]:SetText("ACE - Server Side Control Panel")
	acfmenupanel["CData"]["Options"]:SetFont("DermaDefaultBold")
	acfmenupanel["CData"]["Options"]:SizeToContents()  
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"]["Options"] )
	
	local Sub = vgui.Create( "DLabel" )
	Sub:SetPos( 0, 0 )
	Sub:SetColor( Color(10,10,10) ) 
	Sub:SetText("Server Side parameters can be adjusted here (admin only!)")
	Sub:SizeToContents()  
	acfmenupanel.CustomDisplay:AddItem( Sub )
	
   
	local Legal = vgui.Create( "DCheckBoxLabel" , acfmenupanel["CData"]["Options"] )
	Legal:SetPos(50,200)
	Legal:SetText("Enable Legality checks? (requires restart!)")
	Legal:SetTextColor( Color(10,10,10) )
	Legal:SetConVar("acf_legalchecks")
	Legal:SetValue( false )
	Legal:SizeToContents()
	
	acfmenupanel.CustomDisplay:AddItem( Legal )
	
	local Damage = vgui.Create( "DCheckBoxLabel" , acfmenupanel["CData"]["Options"] )
	Damage:SetPos(50,200)
	Damage:SetText("Enable ACE Damage permissions? (requires restart and CPPI to work)")
	Damage:SetTextColor( Color(10,10,10) )
	Damage:SetConVar("acf_enable_dp")
	Damage:SetValue( false )
	Damage:SizeToContents()
	
	acfmenupanel.CustomDisplay:AddItem( Damage )
	
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
	
	acfmenupanel:CPanelText('desc1','If you want to contribute to ACE by providing us feedback, report bugs or tell us suggestions about what stuff and why we should include it, our discord is a good place for that.')
	acfmenupanel:CPanelText('desc2','Don´t forget to check out our wiki, contains valuable information about how to use this addon. Its on WIP, but expect more content on future.')
	
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
	
end

function PANEL:AmmoSelect( Blacklist )
	
	if not acfmenupanel.CustomDisplay then return end
	if not Blacklist then Blacklist = {} end
	
	if not acfmenupanel.AmmoData then
		acfmenupanel.AmmoData = {}
			acfmenupanel.AmmoData["Id"] = "Ammo2x4x4"
			acfmenupanel.AmmoData["Type"] = "Ammo"
			acfmenupanel.AmmoData["Data"] = acfmenupanel.WeaponData["Guns"]["12.7mmMG"]["round"]
	end
	
	--Creating the ammo crate selection
	acfmenupanel.CData.CrateSelect = vgui.Create( "DComboBox", acfmenupanel.CustomDisplay )	--Every display and slider is placed in the Round table so it gets trashed when selecting a new round type
		acfmenupanel.CData.CrateSelect:SetSize(100, 30)
		for Key, Value in pairs( acfmenupanel.WeaponDisplay["Ammo"] ) do
			acfmenupanel.CData.CrateSelect:AddChoice( Value.id , Key )
		end
		acfmenupanel.CData.CrateSelect.OnSelect = function( index , value , data )
			RunConsoleCommand( "acfmenu_id", data )
			acfmenupanel.AmmoData["Id"] = data
			self:UpdateAttribs()
		end
		acfmenupanel.CData.CrateSelect:SetText(acfmenupanel.AmmoData["Id"])
		RunConsoleCommand( "acfmenu_id", acfmenupanel.AmmoData["Id"] )
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.CrateSelect )
	
	--Create the caliber selection display
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
			self:UpdateAttribs()	--Note : this is intentional
		end
		acfmenupanel.CData.CaliberSelect:SetText(acfmenupanel.AmmoData["Data"]["id"])
	acfmenupanel.CustomDisplay:AddItem( acfmenupanel.CData.CaliberSelect )

end

function PANEL:AmmoSlider(Name, Value, Min, Max, Decimals, Title, Desc) --Variable name in the table, Value, Min value, Max Value, slider text title, slider decimeals, description text below slider 

	if not acfmenupanel["CData"][Name] then
		acfmenupanel["CData"][Name] = vgui.Create( "DNumSlider", acfmenupanel.CustomDisplay )
			acfmenupanel["CData"][Name].Label:SetSize( 0 ) --Note : this is intentional 
			acfmenupanel["CData"][Name]:SetTall( 50 ) -- make the slider taller to fit the new label
			acfmenupanel["CData"][Name]:SetMin( 0 )
			acfmenupanel["CData"][Name]:SetMax( 1000 )
			acfmenupanel["CData"][Name]:SetDecimals( Decimals )
		acfmenupanel["CData"][Name.."_label"] = vgui.Create( "DLabel", acfmenupanel["CData"][Name]) -- recreating the label
			acfmenupanel["CData"][Name.."_label"]:SetPos( 0,0 )
			acfmenupanel["CData"][Name.."_label"]:SetText( Title )
			acfmenupanel["CData"][Name.."_label"]:SizeToContents()
			acfmenupanel["CData"][Name.."_label"]:SetDark( true )
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
			acfmenupanel["CData"][Name.."_text"]:SetDark( true )
			acfmenupanel["CData"][Name.."_text"]:SetTall( 20 )
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name.."_text"] )
	end
	acfmenupanel["CData"][Name.."_text"]:SetText( Desc )
	acfmenupanel["CData"][Name.."_text"]:SetSize( acfmenupanel.CustomDisplay:GetWide(), 10 )
	acfmenupanel["CData"][Name.."_text"]:SizeToContentsX()
	
end

function PANEL:AmmoCheckbox(Name, Title, Desc) --Variable name in the table, slider text title, slider decimeals, description text below slider 

	if not acfmenupanel["CData"][Name] then
		acfmenupanel["CData"][Name] = vgui.Create( "DCheckBoxLabel" )
			acfmenupanel["CData"][Name]:SetText( Title or "" )
			acfmenupanel["CData"][Name]:SetDark( true )
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
			acfmenupanel["CData"][Name.."_text"]:SetDark( true )
			acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name.."_text"] )
	end
	acfmenupanel["CData"][Name.."_text"]:SetText( Desc )
	acfmenupanel["CData"][Name.."_text"]:SetSize( acfmenupanel.CustomDisplay:GetWide(), 10 )
	acfmenupanel["CData"][Name.."_text"]:SizeToContentsX()
	
end

function PANEL:CPanelText(Name, Desc)

	if not acfmenupanel["CData"][Name.."_text"] then
		acfmenupanel["CData"][Name.."_text"] = vgui.Create( "DLabel" )
			acfmenupanel["CData"][Name.."_text"]:SetText( Desc or "" )
			acfmenupanel["CData"][Name.."_text"]:SetDark( true )
			acfmenupanel["CData"][Name.."_text"]:SetWrap(true)
			acfmenupanel["CData"][Name.."_text"]:SetAutoStretchVertical( true )
		acfmenupanel.CustomDisplay:AddItem( acfmenupanel["CData"][Name.."_text"] )
	end
	acfmenupanel["CData"][Name.."_text"]:SetText( Desc )
	acfmenupanel["CData"][Name.."_text"]:SetSize( acfmenupanel.CustomDisplay:GetWide(), 10 )
	acfmenupanel["CData"][Name.."_text"]:SizeToContentsY()

end
