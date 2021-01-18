
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

CreateConVar('sbox_max_acf_explosive', 20)




function ENT:Initialize()
    
	self.BulletData = self.BulletData or {}	
	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
	self.ShouldTrace = false
	
	
	self.Inputs = Wire_CreateInputs( self, { "Detonate" } )
	self.Outputs = Wire_CreateOutputs( self, {} )
	
	
	self.ThinkDelay = 0.1
	
	self.TraceFilter = {self}

end



local nullhit = {Damage = 0, Overkill = 1, Loss = 0, Kill = false}
function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )
	self.ACF.Armour = 0.1
	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function
	if self.Detonated or self.DisableDamage then return table.Copy(nullhit) end
	
	local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
	if CanDo == false then return table.Copy(nullhit) end
	
	HitRes.Kill = false
	self:Detonate()
	
	return table.Copy(nullhit) --This function needs to return HitRes
end




function ENT:TriggerInput( inp, value )
	if inp == "Detonate" and value ~= 0 then
		self:Detonate()
	end
end




function MakeACF_Explosive(Owner, Pos, Angle, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl, Data11, Data12, Data13, Data14, Data15)

	if not Owner:CheckLimit("_acf_explosive") then return false end
	

	local weapon = ACF.Weapons.Guns[Data1]

	local Bomb = ents.Create("acf_explosive")
	if not Bomb:IsValid() then return false end
	Bomb:SetAngles(Angle)
	Bomb:SetPos(Pos)
	Bomb:Spawn()
	Bomb:SetPlayer(Owner)
	
	if CPPI then
		Bomb:CPPISetOwner(Owner)
	end
	
	Bomb.Owner = Owner
	
	
	Mdl = Mdl or ACF.Weapons.Guns[Id].model
	
	Bomb.Id = Id
	Bomb:CreateBomb(Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl, Data11, Data12, Data13 , Data14 , Data15)
	
	Owner:AddCount( "_acf_explosive", Bomb )
	Owner:AddCleanup( "acfmenu", Bomb )
	
	return Bomb
end
list.Set( "ACFCvars", "acf_explosive", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10", "mdl", "data11", "data12", "data13", "data14", "data15"} )
duplicator.RegisterEntityClass("acf_explosive", MakeACF_Explosive, "Pos", "Angle", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10", "Model" , "RoundData11" , "RoundData12", "RoundData13", "RoundData14", "RoundData15" )




function ENT:CreateBomb(Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl, bdata,Data11 ,Data12, Data13 ,Data14, Data15)

	self:SetModelEasy(Mdl)
	--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	self.RoundId 	= Data1		--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType 	= Data2		--Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = Data3--Lenght of propellant
	self.RoundProjectile = Data4--Lenght of the projectile
	self.RoundData5 = ( Data5 or 0 )
	self.RoundData6 = ( Data6 or 0 )
	self.RoundData7 = ( Data7 or 0 )
	self.RoundData8 = ( Data8 or 0 )
	self.RoundData9 = ( Data9 or 0 )
	self.RoundData10 = ( Data10 or 0 )
	self.RoundData11 = ( Data11 or 0 )
	self.RoundData12 = ( Data12 or 0 )
	self.RoundData13 = ( Data13 or 0 )
	self.RoundData14 = ( Data14 or 0 )
	self.RoundData15 = ( Data15 or 0 )
	
	local PlayerData = bdata or ACFM_CompactBulletData(self)
	
	local guntable = ACF.Weapons.Guns
	local gun = guntable[self.RoundId] or {}
	self:ConfigBulletDataShortForm(PlayerData)
	
end




function ENT:SetModelEasy(mdl)
	local curMdl = self:GetModel()
	
	if not mdl or curMdl == mdl then
		self.Model = self:GetModel()
		return 
	end
	
	self:SetModel( mdl )
	self.Model = mdl
	
	self:PhysicsInit( SOLID_VPHYSICS )      	
	self:SetMoveType( MOVETYPE_VPHYSICS )     	
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetMass( 10 ) 
	end 
end




function ENT:SetBulletData(bdata)

	if not (bdata.IsShortForm or bdata.Data5) then error("acf_explosive requires short-form bullet-data but was given expanded bullet-data.") end
	
    bdata = ACFM_CompactBulletData(bdata)
    
	self:CreateBomb(
		bdata.Data1 or bdata.Id,
		bdata.Type or bdata.Data2,
		bdata.PropLength or bdata.Data3,
		bdata.ProjLength or bdata.Data4,
		bdata.Data5, 
		bdata.Data6, 
		bdata.Data7, 
		bdata.Data8, 
		bdata.Data9, 
		bdata.Data10, 
		bdata.Data11, 
		bdata.Data12, 
		bdata.Data13, 
		bdata.Data14, 
		bdata.Data15, 
		nil,
		bdata)
	
	self:ConfigBulletDataShortForm(bdata)
end




function ENT:ConfigBulletDataShortForm(bdata)
	bdata = ACFM_ExpandBulletData(bdata)
	
	self.BulletData = bdata
	self.BulletData.Entity = self
	self.BulletData.Crate = self:EntIndex()
	self.BulletData.Owner = self.BulletData.Owner or self.Owner
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:SetMass( bdata.ProjMass or bdata.RoundMass or bdata.Mass or 10 ) 
	end
	
	self:RefreshClientInfo()
end




local trace = {}

function ENT:TraceFunction()
	local pos = self:GetPos()
	trace.start = pos
	trace.endpos = pos + self:GetVelocity() * self.ThinkDelay * -1  
	trace.filter = self.TraceFilter

	local res = util.TraceEntity( trace, self ) 
	if res.Hit then
		self:OnTraceContact(res)
	end
end




function ENT:Think()
 	
	if self.ShouldTrace then
		self:TraceFunction()		
	end
	
	self:NextThink(CurTime() + self.ThinkDelay)
	
	return true
		
end




function ENT:Detonate(overrideBData)

	if self.Detonated then return end
	
	self.Detonated = true
	
	local bdata = overrideBData or self.BulletData
	local phys = self:GetPhysicsObject()
	local pos = self:GetPos()
	
	local phyvel = 	phys and phys:GetVelocity() or Vector(0, 0, 1000)
	bdata.Flight = 	bdata.Flight or phyvel
	
	timer.Simple(3, function() if IsValid(self) then if IsValid(self.FakeCrate) then self.FakeCrate:Remove() end self:Remove() end end)
	
	if overrideBData then     --check if overrideBData is presented
	    if overrideBData.Entity.Fuse.Cluster == nil then
		   
		   bdata.Owner = 	bdata.Owner or self.Owner
		   
		   if bdata.Type == 'HEAT' or 'THEAT' then  --check if missile is HEAT based
		     if not self.DetonateOffset then    --just cuz lua doesnt like me	  
			  bdata.Pos = pos + bdata.Flight:GetNormalized()
			  
			  else
		      --print('offset changed to be used with HEAT and THEAT')      
		      bdata.Pos = pos + (self.DetonateOffset * 100 or bdata.Flight:GetNormalized())--We define this new offset because HEAT/THEAT bullets are created a little in front of missile detonation, causing some weird rico sounds.
		      end
		   else
		      --print('offset changed to be used with HE')
		      bdata.Pos = pos + (self.DetonateOffset or bdata.Flight:GetNormalized())--Due to endflight, HE offset is ok.   
		   end
		    
		   bdata.NoOcc = 	self
		   bdata.Gun =     self
		
		   debugoverlay.Line(bdata.Pos, bdata.Pos + bdata.Flight, 10, Color(255, 128, 0))
		
		   if bdata.Filter then bdata.Filter[#bdata.Filter+1] = self
		   else bdata.Filter = {self} end
		
		   bdata.RoundMass = bdata.RoundMass or bdata.ProjMass
		   bdata.ProjMass = bdata.ProjMass or bdata.RoundMass 
		
		   bdata.HandlesOwnIteration = nil

		   ACFM_BulletLaunch(bdata)
		   
		

		   self:SetSolid(SOLID_NONE)
		   phys:EnableMotion(false)
		
		   self:DoReplicatedPropHit(bdata)
		
		   self:SetNoDraw(true)
	   else
		   self:SetNoDraw(true)
		   
		   self:ClusterNew(bdata)
	   end
	end
end


function ENT:ClusterNew(bdata)
	local Bomblets = math.Clamp(math.Round(bdata.FillerMass/2),3,30)
	local MuzzlePos = self:LocalToWorld(Vector(10,0,0))
	local MuzzleVec = self:GetForward()

	if bdata.Type == "HEAT" then
		Bomblets = math.Clamp(Bomblets,3,25)
	end
		
	self.BulletData = {}
	
	self.BulletData["Accel"]			= Vector(0,0,-600)
	self.BulletData["BoomPower"]		= bdata.BoomPower
	self.BulletData["Caliber"]			= math.Clamp(bdata.Caliber/Bomblets*10,0.05,bdata.Caliber*0.8) --Controls visual size, does nothing else
	self.BulletData["Crate"]			= bdata.Crate
	self.BulletData["DragCoef"]			= bdata.DragCoef/Bomblets/2
	self.BulletData["FillerMass"]		= bdata.FillerMass/Bomblets --/2
	self.BulletData["Filter"]			= self
	self.BulletData["Flight"]			= bdata.Flight
	self.BulletData["FlightTime"]		= 0
	self.BulletData["FrAera"]			= bdata.FrAera
	self.BulletData["FuseLength"]		= 0
	self.BulletData["Gun"]				= self
	self.BulletData["Id"]				= bdata.Id
	--self.BulletData["Index"]			= 
	self.BulletData["KETransfert"]		= bdata.KETransfert
	self.BulletData["LimitVel"]			= 700
	self.BulletData["MuzzleVel"]		= bdata.MuzzleVel*20
	self.BulletData["Owner"]			= bdata.Owner
	self.BulletData["PenAera"]			= bdata.PenAera
	self.BulletData["Pos"]				= bdata.Pos
	self.BulletData["ProjLength"]		= bdata.ProjLength/Bomblets/2
	self.BulletData["ProjMass"]			= bdata.ProjMass/Bomblets/2
	self.BulletData["PropLength"]		= bdata.PropLength
	self.BulletData["PropMass"]			= bdata.PropMass
	self.BulletData["Ricochet"]			= bdata.Ricochet
	self.BulletData["RoundVolume"]		= bdata.RoundVolume
	self.BulletData["ShovePower"]		= bdata.ShovePower
	self.BulletData["Tracer"]			= 0
	if bdata.Type != "HEAT" and bdata.Type != "AP" and bdata.Type != "SM" and bdata.Type != "HE" and bdata.Type != "APHE" then
	self.BulletData["Type"]				= "AP" 
	else
	self.BulletData["Type"]				= bdata.Type
	end
	

	if(self.BulletData.Type == "HEAT") then
	self.BulletData["SlugMass"]			= bdata.SlugMass/(Bomblets/6)
	self.BulletData["SlugCaliber"]		= bdata.SlugCaliber/(Bomblets/6)
	self.BulletData["SlugDragCoef"]		= bdata.SlugDragCoef/(Bomblets/6)
	self.BulletData["SlugMV"]			= bdata.SlugMV/(Bomblets/6)
	self.BulletData["SlugPenAera"]		= bdata.SlugPenAera/(Bomblets/6)
	self.BulletData["SlugRicochet"]		= bdata.SlugRicochet
	self.BulletData["ConeVol"] = bdata.SlugMass*1000/7.9/(Bomblets/6)
	self.BulletData["CasingMass"] = self.BulletData.ProjMass + self.BulletData.FillerMass + (self.BulletData.ConeVol*1000/7.9)
	self.BulletData["BoomFillerMass"] = self.BulletData.FillerMass/1.5
	local SlugEnergy = ACF_Kinetic( self.BulletData.MuzzleVel*39.37 + self.BulletData.SlugMV*39.37 , self.BulletData.SlugMass, 999999 )
	local  MaxPen = (SlugEnergy.Penetration/self.BulletData.SlugPenAera)*ACF.KEtoRHA
	print(MaxPen)
	
	end


		self.FakeCrate = ents.Create("acf_fakecrate2")


		self.FakeCrate:RegisterTo(self.BulletData)
		
		self.BulletData["Crate"] = self.FakeCrate:EntIndex()

		local MuzzleVec = self:GetForward()
	
	
	local Radius = (self.BulletData.FillerMass)^0.33*8*39.37*2 --Explosion effect radius.
	local Flash = EffectData()
	Flash:SetOrigin( self:GetPos() )
	Flash:SetNormal( self:GetForward() )
	Flash:SetRadius( math.max( Radius, 1 ) )
	util.Effect( "ACF_Scaled_Explosion", Flash )
	
	
	for I=1,Bomblets do
		
		timer.Simple(0.01*I,function()
		if(IsValid(self)) then
			Spread = ((self:GetUp() * (2 * math.random() - 1)) + (self:GetRight() * (2 * math.random() - 1)))*(I-1)/40
			self.BulletData["Flight"] = (MuzzleVec+(Spread * 2)):GetNormalized() * self.BulletData["MuzzleVel"] * 39.37 + bdata.Flight
			
			local MuzzlePos = self:LocalToWorld(Vector(100-(I*20),((Bomblets/2)-I)*2,0)*0.5)
			self.BulletData.Pos = MuzzlePos
			self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
			self:CreateShell( self.BulletData )
			
			end
		end)
	end
end

function ENT:CreateShell()
	--You overwrite this with your own function, defined in the ammo definition file
end

--[[
The following function has been completely reworked, since we have tracehulls, the old one had stopped working for any reason, anyways that didnt look that it was necessary
so i changed the way from getting Retry info from FlightRes to bullet.type
]]--

function ENT:DoReplicatedPropHit(Bullet)  

	local FlightRes = { Entity = self, HitNormal = Bullet.Flight, HitPos = Bullet.Pos, HitGroup = HITGROUP_GENERIC } 
	local Index = Bullet.Index
	
	local Retry = 'HE'  --defining Retry status
	
	if Bullet.Type != 'HE' then --if that type is not HE, switch to penetrate mode
	
	     Retry = 'HEAT'
	
	end
	
	if Retry == "HEAT" then	--aka if Retry == 'Penetrated'
        --print('HEAT')
		
        ACFM_ResetVelocity(Bullet)
		
		if Bullet.OnPenetrated then 	
		   Bullet.OnPenetrated(Index, Bullet, FlightRes) 	 	   
		end	
		
     	ACF_BulletClient( Index, Bullet, "Update" , 2 , FlightRes.HitPos )
		--ACF_CalcBulletFlight( Index, Bullet, true )
						
	elseif Retry == "HE" then --aka else then. non penetration
		--print('HE')
		
		ACFM_ResetVelocity(Bullet)
		 
		if Bullet.OnEndFlight then 	  --endflight code
		   Bullet.OnEndFlight(Index, Bullet, FlightRes) 	   
		end	
		
		ACF_BulletClient( Index, Bullet, "Update" , 1 , FlightRes.HitPos  )  --endflight code
		ACF_BulletEndFlight = ACF.RoundTypes[Bullet.Type]["endflight"]
		ACF_BulletEndFlight( Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal )		
			
	end
	--Since they were missiles and missiles are fucked when impact irl, ricochet code can be scrapped at this moment, beside it was useless too
	
end




function ENT:OnTraceContact(trace)

end



function ENT:SetShouldTrace(bool)
	self.ShouldTrace = bool and true

	self:NextThink(CurTime())
end




function ENT:EnableClientInfo(bool)
	self.ClientInfo = bool
	self:SetNWBool("VisInfo", bool)
	
	if bool then
		self:RefreshClientInfo()
	end
end



function ENT:RefreshClientInfo()

	ACFM_MakeCrateForBullet(self, self.BulletData)
	
end
