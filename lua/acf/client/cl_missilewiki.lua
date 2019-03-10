local PANEL = {}
local MIN_X, MIN_Y = 800, 600


function PANEL:Init()

	self:SetSize(MIN_X, MIN_Y)

	self.modelview = vgui.Create('DModelPanel', self)
	self.modelview:SetSize(80, 80)
	self.modelview:SetPos(20, 30)
	self.modelview:SetModel( "models/missiles/bgm_71e.mdl" )
	self.modelview.LayoutEntity = function() end 
	self.modelview:SetFOV( 45 )		
		local viewent = self.modelview:GetEntity()
		local boundmin, boundmax = viewent:GetRenderBounds()
		local dist = boundmin:Distance(boundmax)*1.1
		local centre = boundmin + (boundmax - boundmin)/2
	self.modelview:SetCamPos( centre + Vector( 0, dist, 0 ) )
	self.modelview:SetLookAt( centre )
	
	//*
	self.close = vgui.Create('DButton', self)
	self.close:SetSize(40, 15)
	//self.close:SizeToContents()
	self.close:SetPos(580, 440)
	self.close:SetText('Close')
	self.close.DoClick = function() self:Close() end
	//*/

	self.html = vgui.Create('DHTML', self)
	self.html:SetSize(450, 400)
	self.html:SetPos(120, 30)
	self.html:SetHTML("Fetching Info....")
	
	self.tree = vgui.Create('DTree', self)
	self.tree:SetSize(80, 230)
	self.tree:SetPos(20, 200)
	
	self:SetVisible(true)
	self:Center()
	self:SetSizable(true)
    self:SetTitle("")
	self:MakePopup()
	self:ShowCloseButton(false)
	self:SetDeleteOnClose(false)
	
	self:InvalidateLayout()

end



function PANEL:SetText(txt)
    self.html:SetHTML('<body bgcolor="#f0f0f0"><font face="Helvetica" color="#0f0f0f">' .. txt .. "</font></body>")
end



function PANEL:SetList(HTML, startpage, groups, modelassocs) //TODO: groups, modelassocs
	self.tree:Clear()
	
    if not HTML or table.Count(HTML) < 1 then
        self:SetText("Failed to load the ACF Missiles Wiki.  If this continues, please inform us at https://github.com/Bubbus/ACF-Missiles")
        return
    end
    
	for k,v in pairsByKeys(HTML) do
		
		local node = self.tree:AddNode(k)
		node.DoClick = function() 
			self.html:SetHTML(v) 
		end
		if k == startpage then
			self.html:SetHTML(v) 
		end
	end
end



function PANEL:PerformLayout()
	local x, y  = self:GetSize()
	
	if x < MIN_X then
		x = MIN_X
		self:SetWide(MIN_X)
	end
	
	if y < MIN_Y then
		y = MIN_Y
		self:SetTall(MIN_Y)
	end
	
	local initWide, initTall, padding = 10, 30, 10
	local wide, tall = initWide, initTall
	local sidebarWide = 160
	
	self.close:SetPos(x - (self.close:GetWide() + 3), 3)
	//self.close:SetWide(self.html:GetWide())
	
	self.modelview:SetPos(wide, tall)
	self.modelview:SetWide(sidebarWide)
	tall = tall + self.modelview:GetTall() + padding
	
	self.tree:SetPos(wide, tall)
	self.tree:SetSize(sidebarWide, y - (tall + padding))
	
	//tall = tall + self.tree:GetTall() + padding
	tall = initTall
	wide = wide + sidebarWide + padding
	
	self.html:SetPos(wide, tall)
	self.html:SetSize(x - (wide + padding), y - (tall + padding))
	
end


derma.DefineControl( "ACFMissile_Wiki", "Wiki for ACF Missiles", PANEL, "DFrame" )
