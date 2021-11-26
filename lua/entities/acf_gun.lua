
AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Gun"
ENT.WireDebugName = "ACF Gun"

if CLIENT then

	local ACF_GunInfoWhileSeated = CreateClientConVar("ACF_GunInfoWhileSeated", 0, true, false)

	function ENT:Initialize()
		
		self.BaseClass.Initialize( self )
		
		self.LastFire = 0
		self.Reload = 1
		self.CloseTime = 1
		self.Rate = 1
		self.RateScale = 1
		self.FireAnim = self:LookupSequence( "shoot" )
		self.CloseAnim = self:LookupSequence( "load" )
		self.LastThink = 0
	end
	
	-- copied from base_wire_entity: DoNormalDraw's notip arg isn't accessible from ENT:Draw defined there.
	function ENT:Draw()
	
		local lply = LocalPlayer()
		local hideBubble = not ACF_GunInfoWhileSeated:GetBool() and IsValid(lply) and lply:InVehicle()
		
		self.BaseClass.DoNormalDraw(self, false, hideBubble)
		Wire_Render(self)
		
		if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then 
			-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
			Wire_DrawTracerBeam( self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false ) 
		end
		
	end
	
	function ENT:Think()
		
		self.BaseClass.Think( self )
		
		local SinceFire = CurTime() - self.LastFire
		self:SetCycle( SinceFire * self.Rate / self.RateScale )
		if CurTime() > self.LastFire + self.CloseTime and self.CloseAnim then
			self:ResetSequence( self.CloseAnim )
			self:SetCycle( ( SinceFire - self.CloseTime ) * self.Rate / self.RateScale )
			self.Rate = 1 / ( self.Reload - self.CloseTime ) -- Base anim time is 1s, rate is in 1/10 of a second
			self:SetPlaybackRate( self.Rate )
		end
		
	end

	function ENT:Animate( Class, ReloadTime, LoadOnly )
		
		if self.CloseAnim and self.CloseAnim > 0 then
			self.CloseTime = math.max(ReloadTime-0.75,ReloadTime*0.75)
		else
			self.CloseTime = ReloadTime
			self.CloseAnim = nil
		end
		
		self:ResetSequence( self.FireAnim )
		self:SetCycle( 0 )
		self.RateScale = self:SequenceDuration()
		if LoadOnly then
			self.Rate = 1000000
		else
			self.Rate = 1/math.Clamp(self.CloseTime,0.1,1.5)	--Base anim time is 1s, rate is in 1/10 of a second
		end
		self:SetPlaybackRate( self.Rate )
		self.LastFire = CurTime()
		self.Reload = ReloadTime
		
	end

	function ACFGunGUICreate( Table )
			
		acfmenupanel:CPanelText("Name", Table.name)
		
		local GunDisplay = acfmenupanel.CData.DisplayModel

		GunDisplay = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
		GunDisplay:SetModel( Table.model )
		GunDisplay:SetCamPos( Vector( 250, 500, 250 ) )
		GunDisplay:SetLookAt( Vector( 0, 0, 0 ) )
		GunDisplay:SetFOV( 20 )
		GunDisplay:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
		GunDisplay.LayoutEntity = function( panel, entity ) end
		acfmenupanel.CustomDisplay:AddItem( GunDisplay )

		local GunClass = list.Get("ACFClasses").GunClass[Table.gunclass]
		acfmenupanel:CPanelText("ClassDesc", GunClass.desc)	
		acfmenupanel:CPanelText("GunDesc", Table.desc)
		acfmenupanel:CPanelText("Caliber", "Caliber : "..(Table.caliber*10).."mm")
		acfmenupanel:CPanelText("Weight", "Weight : "..Table.weight.."kg")
		acfmenupanel:CPanelText("Year", "Year : "..Table.year)
		
		if not Table.rack then
			local RoundVolume = 3.1416 * (Table.caliber/2)^2 * Table.round.maxlength
			local RoF = 60 / (((RoundVolume / 500 ) ^ 0.60 ) * GunClass.rofmod * (Table.rofmod or 1)) --class and per-gun use same var name
			acfmenupanel:CPanelText("Firerate", "RoF : "..math.Round(RoF,1).." rounds/min")
			if Table.magsize then acfmenupanel:CPanelText("Magazine", "Magazine : "..Table.magsize.." rounds\nReload :   "..Table.magreload.." s") end
			acfmenupanel:CPanelText("Spread", "Spread : "..GunClass.spread.." degrees")

			acfmenupanel:CPanelText("GunParentable", "\nThis weapon can be parented.")
		end
		
		acfmenupanel.CustomDisplay:PerformLayout()
		
	end
	
	return
end

function ENT:Initialize()
		
	self.ReloadTime = 1
	
	self.FirstLoad = true
	self.Ready = true
	self.Firing = nil
	self.Reloading = nil
	self.CrateBonus = 1
	self.NextFire = 0
	self.LastSend = 0
	self.LastLoadDuration = 0
	self.Owner = self
	self.Parentable = false
	self.NextLegalCheck = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal = true
	self.LegalIssues = ""
	self.FuseTime = 0
	self.ROFLimit = 0 --Used for selecting firerate
	
	self.IsMaster = true --needed?
	self.AmmoLink = {}
	self.CrewLink = {}
	self.HasGunner = 0
	self.LoaderCount = 0
	self.CurAmmo = 1
	self.Sequence = 1
	self.GunClass = "MG"
	
	self.Heat = ACE.AmbientTemp
	
	self.BulletData = {}
		self.BulletData.Type = "Empty"
		self.BulletData.PropMass = 0
		self.BulletData.ProjMass = 0
	
	self.Inaccuracy 	= 1
	self.LastThink = 0	
	self.Inputs = Wire_CreateInputs( self, { "Fire", "Unload", "Reload", "Fuse Time" } )
	self.Outputs = WireLib.CreateSpecialOutputs( self, { "Ready", "AmmoCount", "Entity", "Shots Left", "Fire Rate", "Muzzle Weight", "Muzzle Velocity" , "Heat"}, { "NORMAL", "NORMAL", "ENTITY", "NORMAL", "NORMAL", "NORMAL", "NORMAL" , "NORMAL"} )
	Wire_TriggerOutput(self, "Entity", self)

end  

function MakeACF_Gun(Owner, Pos, Angle, Id)
   

	local EID
	local List = list.Get("ACFEnts")
	if List.Guns[Id] then 
	EID = Id 
	elseif Id == '20mmHRAC' then    
	EID = '20mmRAC'	
	elseif Id == '30mmHRAC' then
    EID = '30mmRAC'
	elseif Id == '105mmSB' then  --ACF2 smoothbore compatibility / thanks old-ACF devs for creating another smoothbore ids
	EID = '100mmSBC'
	elseif Id == '120mmSB' then
	EID = '120mmSBC'
	elseif Id == '140mmSB' then
	EID = '140mmSBC'
	elseif Id == '170mmSB' then
	EID = '170mmSBC'
    else	
	EID = "100mmC" --just cuz 50mmC was too small
	end
	local Lookup = List.Guns[EID]

	
	if Lookup.gunclass == "SL" then
		if not Owner:CheckLimit("_acf_smokelauncher") then return false end
	else
	
	if Lookup.gunclass == "RAC" or Lookup.gunclass == "MG" or Lookup.gunclass == "AC" then
		if not Owner:CheckLimit("_acf_rapidgun") then return false end
	elseif Lookup.caliber >= ACF.LargeCaliber then
		if not Owner:CheckLimit("_acf_largegun") then return false end
	end	
	
		if not Owner:CheckLimit("_acf_gun") then return false end
	end
	
	local Gun = ents.Create("acf_gun")
	local ClassData = list.Get("ACFClasses").GunClass[Lookup.gunclass]
	if not Gun:IsValid() then return false end
	Gun:SetAngles(Angle)
	Gun:SetPos(Pos)
	Gun:Spawn()
	
	Gun:SetPlayer(Owner)
	Gun.Owner = Owner
	Gun.Id = Id
	Gun.Caliber	= Lookup.caliber
	Gun.Model = Lookup.model
	Gun.Mass = Lookup.weight
	Gun.Class = Lookup.gunclass
	Gun.Parentable = Lookup.canparent
	Gun.Heat = ACE.AmbientTemp
	Gun.LinkRangeMul = math.max(Gun.Caliber / 10,1)^1.2
	if ClassData.color then
		Gun:SetColor(Color(ClassData.color[1],ClassData.color[2],ClassData.color[3], 255))
	end
	Gun.PGRoFmod = 1 --per gun rof
	if(Lookup.rofmod) then
		Gun.PGRoFmod = math.max(0.01, Lookup.rofmod)
	end
	Gun.CurrentShot = 0
	Gun.MagSize = 1
	
    --IDK why does this has been broken, giving it sense now
	--to cover guns that uses magazines
	if(Lookup.magsize) then	
		Gun.MagSize = math.max(Gun.MagSize, Lookup.magsize)	
		local Cal = Gun.Caliber
	
		if Cal>=3 and Cal<=12 then  
		    Gun.Inputs = Wire_AdjustInputs( Gun, { "Fire", "Unload", "Reload", "Fuse Time", "ROFLimit"} )
		else 
            Gun.Inputs = Wire_AdjustInputs( Gun, { "Fire", "Unload", "Reload", "ROFLimit"} )
        end		
		
	--to cover guns that get its ammo directly from the crate
	else
		local Cal = Gun.Caliber

		if Cal>=3 and Cal<=12 then
		    Gun.Inputs = Wire_AdjustInputs( Gun, { "Fire", "Unload" , "Fuse Time", "ROFLimit"} )
		else
		    Gun.Inputs = Wire_AdjustInputs( Gun, { "Fire", "Unload", "ROFLimit"} )
		end
	end
	
	Gun.MagReload = 0
	if(Lookup.magreload) then
		Gun.MagReload = math.max(Gun.MagReload, Lookup.magreload)
	end
	Gun.MinLengthBonus = 0.5 * 3.1416*(Gun.Caliber/2)^2 * Lookup.round.maxlength
	
	Gun:SetNWString( "WireName", Lookup.name )
	Gun:SetNWString( "Class", Gun.Class )
	Gun:SetNWInt( "Caliber", Gun.Caliber )
	Gun:SetNWString( "ID", Gun.Id )
	Gun.Muzzleflash = ClassData.muzzleflash
	Gun.RoFmod = ClassData.rofmod
	Gun.RateOfFire = 1 --updated when gun is linked to ammo
	Gun.Sound = ClassData.sound
	Gun:SetNWString( "Sound", Gun.Sound )
	Gun.Inaccuracy = ClassData.spread
	Gun:SetModel( Gun.Model )	
	
	Gun:PhysicsInit( SOLID_VPHYSICS )      	
	Gun:SetMoveType( MOVETYPE_VPHYSICS )     	
	Gun:SetSolid( SOLID_VPHYSICS )
	
	local Muzzle = Gun:GetAttachment( Gun:LookupAttachment( "muzzle" ) )
	Gun.Muzzle = Gun:WorldToLocal(Muzzle.Pos)
	
	local longbarrel = ClassData.longbarrel
	if longbarrel ~= nil then
		timer.Simple(0.25, function() --need to wait until after the property is actually set
			if Gun:GetBodygroup( longbarrel.index ) == longbarrel.submodel then
				local Muzzle = Gun:GetAttachment( Gun:LookupAttachment( longbarrel.newpos ) )
				Gun.Muzzle = Gun:WorldToLocal(Muzzle.Pos)
			end
		end)
	end

	local phys = Gun:GetPhysicsObject()  	
	if IsValid( phys ) then
		phys:SetMass( Gun.Mass )
		Gun.ModelInertia = 0.99 * phys:GetInertia()/phys:GetMass() -- giving a little wiggle room
	end 
	
	Gun:UpdateOverlayText()
	
	Owner:AddCleanup( "acfmenu", Gun )
	
	if Lookup.gunclass == "SL" then
		Owner:AddCount("_acf_smokelauncher", Gun)
	else
	
	if Lookup.gunclass == "RAC" or Lookup.gunclass == "MG" or Lookup.gunclass == "AC" then
		Owner:AddCount("_acf_rapidgun", Gun)
	elseif Lookup.caliber >= ACF.LargeCaliber then
		Owner:AddCount("_acf_largegun", Gun)
	end
	
		Owner:AddCount("_acf_gun", Gun)
	end
	
	ACF_Activate(Gun, 0)
	
	return Gun
	
end
list.Set( "ACFCvars", "acf_gun", {"id"} )
duplicator.RegisterEntityClass("acf_gun", MakeACF_Gun, "Pos", "Angle", "Id")

function ENT:UpdateOverlayText()
	
	local roundType = self.BulletData.Type
	
	if self.BulletData.Tracer and self.BulletData.Tracer > 0 then 
		roundType = roundType .. "-T"
	end
	
	local isEmpty = self.BulletData.Type == "Empty"
	
	local clipLeft = isEmpty and 0 or (self.MagSize - self.CurrentShot)
	local ammoLeft = (self.Ammo or 0) + clipLeft
	local isReloading = not isEmpty and CurTime() < self.NextFire and (self.MagSize == 1 or (self.LastLoadDuration > self.ReloadTime))
	local gunStatus = isReloading and "reloading" or (clipLeft .. " in gun")
	
	local text = roundType .. " - " .. ammoLeft .. (ammoLeft == 1 and " shot left" or " shots left ( " .. gunStatus .. " )")

	text = text .. "\nRounds Per Minute: " .. math.Round( self.RateOfFire or 0, 2 )
	
	if not self.Legal then
		text = text .. "\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end

	self:SetOverlayText( text )
	
end

function ENT:Link( Target )
	
--	print(Target:GetClass())
	
	if not IsValid( Target ) then
		return false, "Target not a valid entity!"		
	end

	-- CrewLink
	-- the gunner
	if Target:GetClass() == "ace_crewseat_gunner" then
	
    	--Don't link if it's already linked
		for k, v in pairs( self.CrewLink ) do
			if v == Target then
				return false, "That crewseat is already linked to this gun!"
			end
		end
	
		--Don't link if it's too far from this gun
		if RetDist( self, Target ) > 100 * self.LinkRangeMul then
	    	return false, "That crewseat is too far to be linked to this gun!"
		end
	
		--Don't link if it's already linked
		if self.HasGunner == 1 then
			return false, "The gun already has a gunner!"	
		end
	
		table.insert( self.CrewLink, Target )
		table.insert( Target.Master, self )
	
		self.HasGunner = 1

		return true, "Link successful!"

	-- the loader
	elseif Target:GetClass() == "ace_crewseat_loader" then

		-- Don't link if it's already linked
		for k, v in pairs( self.CrewLink ) do
			if v == Target then
				return false, "That crewseat is already linked to this gun!"
			end
		end

		--Don't link if it's too far from this gun
		if RetDist( self, Target ) > 100 * self.LinkRangeMul then
			return false, "That crewseat is too far to be linked to this gun!"
		end

		if self.HasGunner == 0 then --IK there is going to be an exploit to delete the gunner after placing a loader but idk how to fix *shrugs*
			return false, "You need a gunner before you can have a loader!"	
		end
	
		if self.LoaderCount >= 3 then
			return false, "The gun already has 3 loaders!"	
		end

		if self.Class == "AC" or self.Class == "MG" or self.Class == "RAC" or self.Class == "HMG" or self.Class == "GL" or self.Class == "SA" or self.Class == "AL" then
			return false, "This gun cannot have a loader!"	
		end	
	
		table.insert( self.CrewLink, Target )
		table.insert( Target.Master, self )
	
		self.LoaderCount = self.LoaderCount + 1

		return true, "Link successful!"
	
	--Ammo Link
	elseif Target:GetClass() == "acf_ammo" then 
	
		--We have to change the Id manually here
		if self.Id == '20mmHRAC' then
	    	self.Id = '20mmRAC'
		elseif self.Id == '30mmHRAC' then
	    	self.Id = '30mmRAC'	
		elseif self.Id == '105mmSB' then
	    	self.Id = '100mmSBC'
		elseif self.Id == '120mmSB' then
	    	self.Id = '120mmSBC'
		elseif self.Id == '140mmSB' then
	    	self.Id = '140mmSBC'
		elseif self.Id == '170mmSB' then
	    	self.Id = '170mmSBC'
		end
	
		-- Don't link if it's not the right ammo type
		if Target.BulletData.Id ~= self.Id then 
        	return false, "Wrong ammo type!"
		end
	
		-- Don't link if it's a refill crate
		if Target.RoundType == "Refill" then
			return false, "Refill crates cannot be linked!"
		end
	
		-- Don't link if it's a blacklisted round type for this gun
		local Blacklist = ACF.AmmoBlacklist[ Target.RoundType ] or {}
	
		if table.HasValue( Blacklist, self.Class ) then
			return false, "That round type cannot be used with this gun!"
		end
	
		-- Dont't link if it's too far from this gun
		if RetDist( self, Target ) > 512 * self.LinkRangeMul then
	    	return false, "That crate is too far to be connected with this gun!"
		end
	
		-- Don't link if it's already linked
		for k, v in pairs( self.AmmoLink ) do
			if v == Target then
				return false, "That crate is already linked to this gun!"
			end
		end
	
		table.insert( self.AmmoLink, Target )
		table.insert( Target.Master, self )
	
		if self.BulletData.Type == "Empty" and Target.Load then
			self:UnloadAmmo()
		end
	
		local ReloadBuff = 1
		if not (self.Class == "AC" or self.Class == "MG" or self.Class == "RAC" or self.Class == "HMG" or self.Class == "GL" or self.Class == "SA") then
			ReloadBuff = 1.25-(self.LoaderCount*0.25)
		end
	
		self.ReloadTime = math.max(( ( math.max(Target.BulletData.RoundVolume,self.MinLengthBonus) / 500 ) ^ 0.60 ) * self.RoFmod * self.PGRoFmod * ReloadBuff, self.ROFLimit)
		self.RateOfFire = 60 / self.ReloadTime

		Wire_TriggerOutput( self, "Fire Rate", self.RateOfFire )
		Wire_TriggerOutput( self, "Muzzle Weight", math.floor( Target.BulletData.ProjMass * 1000 ) )
		Wire_TriggerOutput( self, "Muzzle Velocity", math.floor( Target.BulletData.MuzzleVel * ACF.VelScale ) )

		return true, "Link successful!"
	
	else
		return false, "Guns can only be linked to ammo crates or crew seats!"
	end
	
end

function ENT:Unlink( Target )

	local Success = false
	for Key,Value in pairs(self.AmmoLink) do
		if Value == Target then
			table.remove(self.AmmoLink,Key)
			Success = true
		end
	end
	for Key,Value in pairs(self.CrewLink) do
		if Value == Target then
			if Target:GetClass() == "ace_crewseat_gunner" then
			self.HasGunner = 0			
			elseif Target:GetClass() == "ace_crewseat_loader" then
			self.LoaderCount = self.LoaderCount - 1			

			
			end
			table.remove(self.CrewLink,Key)
			Success = true
		end
	end

	if Success then
		return true, "Unlink successful!"
	else
		return false, "That entity is not linked to this gun!"
	end
	
end

function ENT:CanProperty( ply, property )

	if property == "bodygroups" then
		local longbarrel = list.Get("ACFClasses").GunClass[self.Class].longbarrel
		if longbarrel ~= nil then
			timer.Simple(0.25, function() --need to wait until after the property is actually set
				if self:GetBodygroup( longbarrel.index ) == longbarrel.submodel then
					local Muzzle = self:GetAttachment( self:LookupAttachment( longbarrel.newpos ) )
					self.Muzzle = self:WorldToLocal(Muzzle.Pos)
				else
					local Muzzle = self:GetAttachment( self:LookupAttachment( "muzzle" ) )
					self.Muzzle = self:WorldToLocal(Muzzle.Pos)
				end
			end)
		end
	end 
	
	return true

end

local WireTable = { "gmod_wire_adv_pod", "gmod_wire_pod", "gmod_wire_keyboard", "gmod_wire_joystick", "gmod_wire_joystick_multi" }

function ENT:GetUser( inp )
	if not inp then return nil end
	if inp:GetClass() == "gmod_wire_adv_pod" then
		if inp.Pod then
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_pod" then
		if inp.Pod then
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_keyboard" then
		if inp.ply then
			return inp.ply 
		end
	elseif inp:GetClass() == "gmod_wire_joystick" then
		if inp.Pod then 
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_joystick_multi" then
		if inp.Pod then 
			return inp.Pod:GetDriver()
		end
	elseif inp:GetClass() == "gmod_wire_expression2" then
		if inp.Inputs.Fire then
			return self:GetUser(inp.Inputs.Fire.Src) 
		elseif inp.Inputs.Shoot then
			return self:GetUser(inp.Inputs.Shoot.Src) 
		elseif inp.Inputs then
			for _,v in pairs(inp.Inputs) do
				if v.Src then
					if table.HasValue(WireTable, v.Src:GetClass()) then
						return self:GetUser(v.Src) 
					end
				end
			end
		end
	end
	return inp.Owner or inp:GetOwner()
	
end

function ENT:TriggerInput( iname, value )
	
	if (iname == "Unload" and value > 0 and !self.Reloading) then
		self:UnloadAmmo()
	elseif ( iname == "Fire" and value > 0 and ACF.GunfireEnabled and self.Legal ) then
		if self.NextFire < CurTime() then
			self.User = self:GetUser(self.Inputs.Fire.Src) or self.Owner
			if not IsValid(self.User) then self.User = self.Owner end
			self:FireShell()
			self:Think()
		end
		self.Firing = true
	elseif ( iname == "Fire" and value <= 0 ) then
		self.Firing = false
	elseif ( iname == "Reload" and value ~= 0 ) then
		self.Reloading = true
	elseif ( iname == "Fuse Time" ) then
	if value > 0 then
		self.FuseTime = value
		self:SetNWString("connected","wired")
	else
		self.FuseTime = 0
		self:SetNWString("connected","unwired")
	end
	elseif (iname == "ROFLimit") then
		self.ROFLimit = math.min(1/(value/60),10) --Clamped to 10 seconds because people are stupid and set this too low
--		print("Test")
	end		
end

local function RetDist( enta, entb )
	if not ((enta and enta:IsValid()) or (entb and entb:IsValid())) then return 0 end
	disp = enta:GetPos() - entb:GetPos()
	dist = math.sqrt( disp.x * disp.x + disp.y * disp.y + disp.z * disp.z )
	return dist
end

function ENT:Think()
	
	--Legality check part
	if ACF.CurTime > self.NextLegalCheck then

		-- check gun is legal
		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, self.Mass, self.ModelInertia, nil, true)
		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

		-- check the seat is legal
		local seat = IsValid(self.User) and self.User:GetVehicle() or nil

		if IsValid(seat) then
			local legal, issues = ACF_CheckLegal(seat, nil, nil, nil, nil, false)
			if not legal then
				self.Legal = false
				self.LegalIssues = self.LegalIssues .. "\nSeat not legal: " .. issues
			end
		end

		self:UpdateOverlayText()

		if not self.Legal then
			if self.Firing then self:TriggerInput("Fire",0) end
		end

	end



	local PhysObj = self:GetPhysicsObject()
	if not IsValid(PhysObj) then return	end --IDK how an object can break this bad but it did. Hopefully this fixes the 1 in a million bug


----Heat function
	DeltaTime = CurTime() - self.LastThink	
	
	--print(DeltaTime)
	
	self.Heat = ACE_HeatFromGun( self , self.Heat, DeltaTime )
	Wire_TriggerOutput(self, "Heat", math.Round(self.Heat))

 

----TODO: instead of breaking the gun by heat, decrease accurancy and jam it
	local OverHeat = math.max(self.Heat/200,0) --overheat will start affecting the gun at 200° celcius. STILL unrealistic, weird
	if OverHeat > 1.0 and self.Caliber < 10 then  --leave the low calibers to damage themselves only

        local phys = self:GetPhysicsObject()
	    local Mass = phys:GetMass()
	
	    HitRes = ACF_Damage ( self , {Kinetic = (1 * OverHeat)* (1+math.max(Mass-300,0.1)),Momentum = 0,Penetration = (1*OverHeat)* (1+math.max(Mass-300,0.1))} , 2 , 0 , self.Owner )

		if HitRes.Kill then
			ACF_HEKill( self, VectorRand() , 0)
		end
			
	end

	
	local Time = CurTime()
	if self.LastSend+1 <= Time then
		local Ammo = 0
		local CrateBonus = {}
		local rofbonus = 0
		local totalcap = 0
		
		for Key, Crate in pairs(self.AmmoLink) do --UnlinkDistance
			if IsValid( Crate ) and Crate.Load and Crate.Legal then
				if RetDist( self, Crate ) < 512 * self.LinkRangeMul then
					Ammo = Ammo + (Crate.Ammo or 0)
					CrateBonus[Crate.RoFMul] = (CrateBonus[Crate.RoFMul] or 0) + Crate.Capacity
					totalcap = totalcap + Crate.Capacity
				else
					self:Unlink( Crate )
					soundstr =  "physics/metal/metal_box_impact_bullet" .. tostring(math.random(1, 3)) .. ".wav"
					self:EmitSound(soundstr,500,100)
				end
			end
		end
		
		for Key, Seat in pairs(self.CrewLink) do --UnlinkDistance
			if IsValid( Seat ) then --Legality check missing atm
				if RetDist( self, Seat ) < 100 * self.LinkRangeMul then
				--Do stuff
				else
					self:Unlink( Seat )
					soundstr =  "physics/metal/metal_canister_impact_hard" .. tostring(math.random(1, 3)) .. ".wav"
					self:EmitSound(soundstr,500,100)
				end
			end
		end
		
		for mul, cap in pairs(CrateBonus) do
			rofbonus = rofbonus + (cap/totalcap)*mul 
		end

		self.CrateBonus = rofbonus or 1
		self.Ammo = Ammo
		self:UpdateOverlayText()
		
		Wire_TriggerOutput(self, "AmmoCount", Ammo)
		
		
		if( self.MagSize ) then
			Wire_TriggerOutput(self, "Shots Left", self.MagSize - self.CurrentShot)
		else
			Wire_TriggerOutput(self, "Shots Left", 1)
		end
		
		self:SetNWString("GunType",self.Id)
		self:SetNWInt("Ammo",Ammo)
		self:SetNWString("Type",self.BulletData.Type)
		self:SetNWFloat("Mass",self.BulletData.ProjMass*100)
		self:SetNWFloat("Propellant",self.BulletData.PropMass*1000)
		self:SetNWFloat("FireRate",self.RateOfFire)
		
		self.LastSend = Time
	
	end
	
	if self.NextFire <= Time then
		self.Ready = true
		Wire_TriggerOutput(self, "Ready", 1)
		
		if self.MagSize and self.MagSize == 1 then
			self.CurrentShot = 0
		end
		
		if self.Firing then
		    --print('Fire!')
			self:FireShell()	
		elseif self.Reloading then
		    --print('Reloading!')
			self:ReloadMag()
			self.Reloading = false
		end
	end
		self.LastThink = ACF.CurTime
	self:NextThink(Time)
	return true
end

function ENT:ReloadMag()
	if(self.IsUnderWeight == nil) then
		self.IsUnderWeight = true
	end
	if ( (self.CurrentShot > 0) and self.IsUnderWeight and self.Ready and self.Legal ) then
		if ( ACF.RoundTypes[self.BulletData.Type] ) then		--Check if the roundtype loaded actually exists
			self:LoadAmmo(self.MagReload, false)	
			self:EmitSound("weapons/357/357_reload4.wav",500,100)
			self.CurrentShot = 0
			Wire_TriggerOutput(self, "Ready", 0)
		else
			self.CurrentShot = 0
			self.Ready = false
			Wire_TriggerOutput(self, "Ready", 0)
			self:LoadAmmo(false, true)	
		end
	end
end

function ENT:GetInaccuracy()
	local SpreadScale = ACF.SpreadScale
	local IaccMult = 1
	
	if (self.ACF.Health and self.ACF.MaxHealth) then
		IaccMult = math.Clamp(((1 - SpreadScale) / (0.5)) * ((self.ACF.Health/self.ACF.MaxHealth) - 1) + 1, 1, SpreadScale)
	end
	if (self.BulletData.Type == "APFSDS" or self.BulletData.Type == "APFSDSS" or self.BulletData.Type == "HEATFS" or self.BulletData.Type == "HEFS"or self.BulletData.Type == "THEATFS") then
	IaccMult = IaccMult*0.25
	end
	
	if self.HasGunner == 0 then 
	IaccMult = 1.5
--	print("Cannon less accurate bc of lack of gunner")
	end
	
	local coneAng = self.Inaccuracy * ACF.GunInaccuracyScale * IaccMult
	
	return coneAng
end



function ENT:FireShell()
    
	--print('FireShell')
	
	local CanDo = hook.Run("ACF_FireShell", self, self.BulletData )

	if(self.IsUnderWeight == nil) then
		self.IsUnderWeight = true
	end
	
	local bool = true

	if ( bool and self.IsUnderWeight and self.Ready and self.Legal ) then

	--print('FireShell2')	
		
		Blacklist = {}
		if not ACF.AmmoBlacklist[self.BulletData.Type] then
			Blacklist = {}
		else
			Blacklist = ACF.AmmoBlacklist[self.BulletData.Type]	
		end
		if ( ACF.RoundTypes[self.BulletData.Type] and !table.HasValue( Blacklist, self.Class ) ) then		--Check if the roundtype loaded actually exists
		
		   	--print('FireShell3')
			--print('Fire!')
		    
            self.HeatFire = true  --Used by Heat			

			local MuzzlePos = self:LocalToWorld(self.Muzzle)
			local MuzzleVec = self:GetForward()
			
			local coneAng = math.tan(math.rad(self:GetInaccuracy())) 
			local randUnitSquare = (self:GetUp() * (2 * math.random() - 1) + self:GetRight() * (2 * math.random() - 1))
			local spread = randUnitSquare:GetNormalized() * coneAng * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4)))
			local ShootVec = (MuzzleVec + spread):GetNormalized()
			
			self:MuzzleEffect( MuzzlePos, MuzzleVec )
			
			--local TestVel = ACF_GetPhysicalParent(self):GetVelocity()
		
			local GPos = self:GetPos()
			local TestVel = self:WorldToLocal(ACF_GetPhysicalParent(self):GetVelocity()+GPos)
			TestVel = self:LocalToWorld(Vector(math.max(TestVel.x,-0.1),TestVel.y,TestVel.z))-GPos

			self.BulletData.Pos = MuzzlePos + TestVel * DeltaTime * 5 --Less clipping on fast vehicles, especially moving perpindicular since traceback doesnt compensate for that. A multiplier of 3 is semi-reliable. A multiplier of 5 guarentees it doesnt happen.
			self.BulletData.Flight = ShootVec * self.BulletData.MuzzleVel * 39.37 + TestVel
			self.BulletData.Owner = self.User
			self.BulletData.Gun = self

			local Cal = self.Caliber

--			print("BooletType: "..self.BulletData.Type)

				local FuseNoise = 1
			if Cal<12 then
				if (self.BulletData.Type == "HE" or self.BulletData.Type == "SM") then
					if self.FuseTime < (0.28^math.max(Cal-3,1)) then
					FuseNoise = 1
					else
					FuseNoise = 1 + math.Rand(-1,1)* math.max(((Cal-3)/23),0.2)
					end
				    
					wired = self:GetNWString('connected')
					
					if wired == 'wired' then --using fusetime via wire will override the ammo fusetime!
				        --print(wired)
					    self.BulletData.FuseLength = self.FuseTime * FuseNoise  
									
					end
									
				end
			end

			self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
			self:CreateShell( self.BulletData )
			
			local PhysObj = self:GetPhysicsObject()
			local HasPhys = not self:GetParent():IsValid()
			ACF_KEShove(self, HasPhys and util.LocalToWorld(self, self:GetPhysicsObject():GetMassCenter(), 0) or self:GetPos(), -self:GetForward(), (self.BulletData.ProjMass * self.BulletData.MuzzleVel * 39.37 + self.BulletData.PropMass * 3000 * 39.37)*(GetConVarNumber("acf_recoilpush") or 1) )

			--todo: https://github.com/MartyX5555/ACE-Dev/pull/1 --> see this
			--ACF_KEShove(self, nil, -self:GetForward(), (self.BulletData.ProjMass * self.BulletData.MuzzleVel * 39.37 + self.BulletData.PropMass * 3000 * 39.37)*(GetConVarNumber("acf_recoilpush") or 1) )

			
			self.Ready = false
			self.CurrentShot = math.min(self.CurrentShot + 1, self.MagSize)
			if((self.CurrentShot >= self.MagSize) and (self.MagSize > 1)) then
				self:LoadAmmo(self.MagReload, false)	
				self:EmitSound("weapons/357/357_reload4.wav",500,100)
				timer.Simple(self.LastLoadDuration, function() if IsValid(self) then self.CurrentShot = 0 end end)
			else
				self:LoadAmmo(false, false)	
			end
			Wire_TriggerOutput(self, "Ready", 0)
		else
			
			self.CurrentShot = 0
			self.Ready = false
			Wire_TriggerOutput(self, "Ready", 0)
			self:LoadAmmo(false, true)	
		end
	end
	
end

function ENT:FindNextCrate()

	local MaxAmmo = table.getn(self.AmmoLink)
	local AmmoEnt = nil
	local i = 0
	
	while i <= MaxAmmo and not (AmmoEnt and AmmoEnt:IsValid() and AmmoEnt.Ammo > 0) do -- need to check ammoent here? returns if found
		
		self.CurAmmo = self.CurAmmo + 1
		if self.CurAmmo > MaxAmmo then self.CurAmmo = 1 end
		
		AmmoEnt = self.AmmoLink[self.CurAmmo]
		if AmmoEnt and AmmoEnt:IsValid() and AmmoEnt.Ammo > 0 and AmmoEnt.Load and AmmoEnt.Legal then
			return AmmoEnt
		end
		AmmoEnt = nil
		
		i = i + 1
	end
	
	return false
end

function ENT:LoadAmmo( AddTime, Reload )

	local AmmoEnt = self:FindNextCrate()
	local curTime = CurTime()
	
	if AmmoEnt and AmmoEnt.Legal then
		AmmoEnt.Ammo = AmmoEnt.Ammo - 1
		self.BulletData = AmmoEnt.BulletData
		self.BulletData.Crate = AmmoEnt:EntIndex()
		
		local cb = 1
		if(self.CrateBonus and (self.MagReload == 0)) then
			cb = self.CrateBonus
			if (cb == 0) then cb = 1 end
		end
		
		local Adj = not self.BulletData.LengthAdj and 1 or self.BulletData.LengthAdj --FL firerate bonus adjustment
		local ReloadBuff = 1

		if not (self.Class == "AC" or self.Class == "MG" or self.Class == "RAC" or self.Class == "HMG" or self.Class == "GL" or self.Class == "SA") then
			ReloadBuff = 1.25-(self.LoaderCount*0.25)
		end
		
		self.ReloadTime = math.max(( ( math.max(self.BulletData.RoundVolume,self.MinLengthBonus*Adj) / 500 ) ^ 0.60 ) * self.RoFmod * self.PGRoFmod * cb * ReloadBuff, self.ROFLimit)
		Wire_TriggerOutput(self, "Loaded", self.BulletData.Type)
		
		self.RateOfFire = (60/self.ReloadTime)
		Wire_TriggerOutput(self, "Fire Rate", self.RateOfFire)
		Wire_TriggerOutput(self, "Muzzle Weight", math.floor(self.BulletData.ProjMass*1000) )
		Wire_TriggerOutput(self, "Muzzle Velocity", math.floor(self.BulletData.MuzzleVel*ACF.VelScale) )
		
		self.NextFire = curTime + self.ReloadTime
		local reloadTime = self.ReloadTime
		
		if AddTime then
			reloadTime = reloadTime + AddTime * self.CrateBonus
		end
		if Reload then
			self:ReloadEffect()
		end

		if self.FirstLoad then
			self.FirstLoad = false
			reloadTime = 0.1
		end
		
		self.NextFire = curTime + reloadTime
		self.LastLoadDuration = reloadTime
		
		self:Think()
		return true	
	else
		self.BulletData = {}
			self.BulletData.Type = "Empty"
			self.BulletData.PropMass = 0
			self.BulletData.ProjMass = 0
		
		self:EmitSound("weapons/shotgun/shotgun_empty.wav",500,100)
		Wire_TriggerOutput(self, "Loaded", "Empty")
				
		self.NextFire = curTime + 0.5
		self:Think()
	end
	return false
	
end

function ENT:UnloadAmmo()

	if not self.BulletData or not self.BulletData.Crate then return end -- Explanation: http://www.youtube.com/watch?v=dwjrui9oCVQ
	if not self.Ready then
		if (self.NextFire-CurTime()) < 0 then return end -- see above; preventing spam
		if self.MagSize > 1 and self.CurrentShot >= self.MagSize then return end -- prevent unload in middle of mag reload
	end
	
	local Crate = Entity( self.BulletData.Crate )
	if Crate and Crate:IsValid() and self.BulletData.Type == Crate.BulletData.Type then
		Crate.Ammo = math.min(Crate.Ammo+1, Crate.Capacity)
	end
	
	self.Ready = false
	Wire_TriggerOutput(self, "Ready", 0)
	self:EmitSound("weapons/shotgun/shotgun_empty.wav",500,100)
	
	local unloadtime = self.ReloadTime/2 -- base time to swap a fully loaded shell out
	if self.NextFire < CurTime() then -- unloading in middle of reload
		unloadtime = math.min(unloadtime, math.max(self.ReloadTime - (self.NextFire - CurTime()),0) )
	end
	self:LoadAmmo( unloadtime, true )

end

function ENT:MuzzleEffect()
	
	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( self.BulletData.PropMass )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData.Type].netid  )	--Encoding the ammo type into a table index
	util.Effect( "ACF_MuzzleFlash", Effect, true, true )

end

function ENT:ReloadEffect()

	local Effect = EffectData()
		Effect:SetEntity( self )
		Effect:SetScale( 0 )
		Effect:SetMagnitude( self.ReloadTime )
		Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData.Type].netid  )	--Encoding the ammo type into a table index
	util.Effect( "ACF_MuzzleFlash", Effect, true, true )
	
end

function ENT:PreEntityCopy()

	local info = {}
	local entids = {}
	for Key, Value in pairs(self.AmmoLink) do					--First clean the table of any invalid entities
		if not Value:IsValid() then
			table.remove(self.AmmoLink, Value)
		end
	end
	for Key, Value in pairs(self.AmmoLink) do					--Then save it
		table.insert(entids, Value:EntIndex())
	end
	for Key, Value in pairs(self.CrewLink) do					--First clean the table of any invalid entities
		if not Value:IsValid() then
			table.remove(self.CrewLink, Value)
		end
	end
	for Key, Value in pairs(self.CrewLink) do					--Then save it
		table.insert(entids, Value:EntIndex())
	end
	info.entities = entids
	if info.entities then
		duplicator.StoreEntityModifier( self, "ACFAmmoLink", info )
	end
	
	--Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if (Ent.EntityMods) and (Ent.EntityMods.ACFAmmoLink) and (Ent.EntityMods.ACFAmmoLink.entities) then

		local AmmoLink = Ent.EntityMods.ACFAmmoLink

		if AmmoLink.entities and table.Count(AmmoLink.entities) > 0 then

			for _,AmmoID in pairs(AmmoLink.entities) do

				local Ammo = CreatedEntities[ AmmoID ]

				if Ammo and Ammo:IsValid() then
				
					if Ammo:GetClass() == "acf_ammo" then
						self:Link( Ammo )
					elseif Ammo:GetClass() == "ace_crewseat_gunner" then
						self:Link( Ammo )
					elseif Ammo:GetClass() == "ace_crewseat_loader" then
						self:Link( Ammo )
					end
				end
			end
		end

		Ent.EntityMods.ACFAmmoLink = nil
	end
	
	--Wire dupe info
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end
