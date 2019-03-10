-- cl_init.lua

include ("shared.lua")

ENT.RenderGroup 		= RENDERGROUP_OPAQUE

-- local MUZZLE = "xcfRkMzl"
-- local RELOAD = "xcfRkRld"


function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()	
    Wire_Render(self)
	
	-- local Ammo = math.max(self:GetNetworkedBeamInt("Ammo"), 0)
	-- if not self.munitionVis and self.gunType then return end
	-- local attach, angpos, attachname, mountpoint, class, classtable, visEnt
	-- //print("ammo", Ammo)
	-- local modelcount = ACF.Weapons.Guns[self.gunType].magsize or 1
	-- for i=modelcount, modelcount-Ammo+1, -1 do
		-- attachname = "missile" .. i
		-- attach = self:LookupAttachment(attachname)
		
		-- angpos = self:GetMunitionAngPos(self.gunType, attach, attachname)
			
		-- visEnt = self.munitionVis[i]
		-- if IsValid(visEnt) then
			-- visEnt:SetNoDraw(false)
			-- visEnt:SetPos(angpos.Pos)
			-- visEnt:SetAngles(angpos.Ang)
			-- //print("drawing", class, "at", angpos.Pos)
			-- visEnt:DrawModel()
			-- visEnt:SetNoDraw(true)
		-- end
	-- end
end

function ENT:DoNormalDraw()
	local e = self
	if (LocalPlayer():GetEyeTrace().Entity == e and EyePos():Distance(e:GetPos()) < 256) then
		if(self:GetOverlayText() ~= "") then
			AddWorldTip(e:EntIndex(),self:GetOverlayText(),0.5,e:GetPos(),e)
		end
	end
end


function ENT:Think()
	-- local gunType = self:GetNetworkedBeamString("GunType")
	-- if gunType and gunType ~= self.gunType then
		-- local guntbl = ACF.Weapons.Guns[gunType] or {round = {}}
		-- local visModel = guntbl.round.rackmdl or guntbl.round.model or "models/munitions/round_100mm_shot.mdl"
		-- //print(visModel)
		-- if self.munitionVis then
			-- for i, mdl in pairs(self.munitionVis) do
				-- mdl:Remove()
			-- end
		-- end
		
		-- local modelcount = ACF.Weapons.Guns[gunType].magsize or 1
		-- self.munitionVis = {}
		-- for i=1, modelcount do
			-- local visEnt = ents.CreateClientProp(visModel)
			-- visEnt:SetModel(visModel)
			-- visEnt:Spawn()
			-- visEnt:SetNoDraw(true)
			-- visEnt:SetParent(self)
			-- self.munitionVis[i] = visEnt
		-- end
		
		-- self.gunType = gunType
	-- end
end

function ENT:Initialize()
	-- self.munitionVis = nil
	-- self.gunType = ""
end

function ENT:Animate( Class, ReloadTime, LoadOnly )

end



-- local netfx = XCF.NetFX or error("Rack entity loaded before NetFX")
-- local uids = netfx.AmmoUIDs

-- function XCF_RackReceiveMuzzle(len)
	-- local gun = net.ReadEntity()
	-- local ammo = net.ReadDouble()
	-- local time = net.ReadDouble()
	-- local attach = net.ReadDouble()
	-- if not IsValid(gun) then return end
	
	-- --print("Muzzle in!", ammo, gun, time, attach)
	
	-- local ammodata = uids[tostring(ammo)]
	-- if not ammodata then 
		-- netfx.UnknownAmmoUID(ammo)
		-- return
	-- end
	
	-- local Effect = EffectData()
		-- Effect:SetEntity( gun )
		-- Effect:SetScale( ammodata.PropMass )
		-- Effect:SetMagnitude( time )
		-- Effect:SetRadius( attach )
		-- Effect:SetSurfaceProp( ACF.RoundTypes[ammodata.Type].netid  )	--Encoding the ammo type into a table index
	-- util.Effect( "ACF_MuzzleFlash", Effect, true)
	
-- end
-- net.Receive(MUZZLE, XCF_RackReceiveMuzzle)


-- function XCF_RackReceiveReload(len)
	-- local gun = net.ReadEntity()
	-- local time = net.ReadDouble()
	-- if not IsValid(gun) then return end
	
	-- --print("Reload in!", time, gun)
	
	-- local Effect = EffectData()
		-- Effect:SetEntity( gun )
		-- Effect:SetScale( 0 )
		-- Effect:SetMagnitude( time )
		-- Effect:SetSurfaceProp( 1 )	--Encoding the ammo type into a table index
	-- util.Effect( "ACF_MuzzleFlash", Effect, true)
-- end
-- net.Receive(RELOAD, XCF_RackReceiveReload)
