
AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "ACF Ammo Crate"
ENT.WireDebugName = "ACF Ammo Crate"

if CLIENT then
	
	--Shamefully stolen from lua rollercoaster. I'M SO SORRY. I HAD TO.

	local function Bezier( a, b, c, d, t )
		local ab,bc,cd,abbc,bccd 
		
		ab = LerpVector(t, a, b)
		bc = LerpVector(t, b, c)
		cd = LerpVector(t, c, d)
		abbc = LerpVector(t, ab, bc)
		bccd = LerpVector(t, bc, cd)
		dest = LerpVector(t, abbc, bccd)
		
		return dest
	end


	local function BezPoint(perc, Table)
		perc = perc or self.Perc
		
		local vec = Vector(0, 0, 0)
		
		vec = Bezier(Table[1], Table[2], Table[3], Table[4], perc)
		
		return vec
	end
	
	function ACF_DrawRefillAmmo( Table )
    
		for k,v in pairs( Table ) do        
			local St, En = v.EntFrom:LocalToWorld(v.EntFrom:OBBCenter()), v.EntTo:LocalToWorld(v.EntTo:OBBCenter())
			local Distance = (En - St):Length()
			local Amount = math.Clamp((Distance/50),2,100)
			local Time = (SysTime() - v.StTime)
			local En2, St2 = En + Vector(0,0,100), St + ((En-St):GetNormalized() * 10)
			local vectab = { St, St2, En2, En}
			local center = (St+En)/2
			for I = 1, Amount do
				local point = BezPoint(((((I+Time)%Amount))/Amount), vectab)
				local ang = (point - center):Angle()
				local MdlTbl = {
					model = v.Model,
					pos = point,
					angle = ang
				}
				render.Model( MdlTbl )
			end
		end
        
	end

    function ACF_TrimInvalidRefillEffects(effectsTbl)
        
        local effect
    
        for i=1, #effectsTbl do
            effect = effectsTbl[i]
            
            if not (IsValid(effect.EntFrom) and IsValid(effect.EntTo)) then 
                effectsTbl[i] = nil
            end
        end
        
    end
	
	local ACF_AmmoInfoWhileSeated = CreateClientConVar("ACF_AmmoInfoWhileSeated", 0, true, false)
	
	function ENT:Draw()
		
		local lply = LocalPlayer()
		local hideBubble = not GetConVar("ACF_AmmoInfoWhileSeated"):GetBool() and IsValid(lply) and lply:InVehicle()
		
		self.BaseClass.DoNormalDraw(self, false, hideBubble)
		Wire_Render(self)
		
		if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then 
			-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
			Wire_DrawTracerBeam( self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false ) 
		end
		--self.BaseClass.Draw( self )
		
		if self.RefillAmmoEffect then
            ACF_TrimInvalidRefillEffects(self.RefillAmmoEffect)
			ACF_DrawRefillAmmo( self.RefillAmmoEffect )
		end
		
	end
	
	usermessage.Hook("ACF_RefillEffect", function( msg )
		local EntFrom, EntTo, Weapon = ents.GetByIndex( msg:ReadFloat() ), ents.GetByIndex( msg:ReadFloat() ), msg:ReadString()
		if not IsValid( EntFrom ) or not IsValid( EntTo ) then return end
		//local List = list.Get( "ACFRoundTypes")	
		--local Mdl = ACF.Weapons.Guns[Weapon].round.model or "models/munitions/round_100mm_shot.mdl" --[Weapon] returns an invalid no
		local Mdl = "models/munitions/round_100mm_shot.mdl"
		EntFrom.RefillAmmoEffect = EntFrom.RefillAmmoEffect or {}
		table.insert( EntFrom.RefillAmmoEffect, {EntFrom = EntFrom, EntTo = EntTo, Model = Mdl, StTime = SysTime()} )
	end)
	
	usermessage.Hook("ACF_StopRefillEffect", function( msg )
		local EntFrom, EntTo = ents.GetByIndex( msg:ReadFloat() ), ents.GetByIndex( msg:ReadFloat() )
        //print("stop", EntFrom, EntTo)
		if not IsValid( EntFrom ) or not IsValid( EntTo )or not EntFrom.RefillAmmoEffect then return end
		for k,v in pairs( EntFrom.RefillAmmoEffect ) do
			if v.EntTo == EntTo then
				if #EntFrom.RefillAmmoEffect<=1 then 
					EntFrom.RefillAmmoEffect = nil
					return
				end
				table.remove(EntFrom.RefillAmmoEffect, k)
			end
		end
	end)
	
	return
	
end

function ENT:Initialize()
	
	self.SpecialHealth = true	--If true needs a special ACF_Activate function
	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
	self.IsExplosive = true
	self.Exploding = false
	self.Damaged = false
	self.CanUpdate = true
	self.Load = false
	self.EmptyMass = 1
	self.AmmoMassMax = 0
	self.NextMassUpdate = 0
	self.Ammo = 0
	self.IsTwoPiece = false
	self.NextLegalCheck = ACF.CurTime + math.random(ACF.Legal.Min, ACF.Legal.Max) -- give any spawning issues time to iron themselves out
	self.Legal = true
	self.LegalIssues = ""
	self.Active = false
	
	--print(self.NextLegalCheck)

	self.Master = {}
	self.Sequence = 0
	
	self.Inputs = Wire_CreateInputs( self, { "Active" } ) --, "Fuse Length"
	self.Outputs = Wire_CreateOutputs( self, { "Munitions" } )
		
	self.NextThink = CurTime() +  1
	
	ACF.AmmoCrates = ACF.AmmoCrates or {}

	self.Capacity = 1
	self.AmmoMassMax =  1
	self.Caliber = 1
	self.RoFMul = 1
	self.LastMass = 1

	self.RoundId = ( self.RoundId or "100mmC"	)	--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType = ( self.RoundType or "AP"	) --Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = ( self.RoundPropellant or 0 )--Lenght of propellant
	self.RoundProjectile = ( self.RoundProjectile or 0 )--Lenght of the projectile
	self.RoundData5 = ( self.RoundData5 or 0 )
	self.RoundData6 = ( self.RoundData6 or 0 )
	self.RoundData7 = ( self.RoundData7 or 0 )
	self.RoundData8 = ( self.RoundData8 or 0 )
	self.RoundData9 = ( self.RoundData9 or 0 )
	self.RoundData10 = ( self.RoundData10 or 0 )
	self.RoundData11 = ( self.RoundData11 or 0 )	
	self.RoundData12 = ( self.RoundData12 or 0 )	
	self.RoundData13 = ( self.RoundData13 or 0 )	
	self.RoundData14 = ( self.RoundData14 or 0 )	
	self.RoundData15 = ( self.RoundData15 or 0 )
end

function ENT:ACF_Activate( Recalc )
	
	local EmptyMass = math.max(self.EmptyMass, self:GetPhysicsObject():GetMass() - self.AmmoMassMax)

	self.ACF = self.ACF or {} 
	
	local PhysObj = self:GetPhysicsObject()
	if not self.ACF.Aera then
		self.ACF.Aera = PhysObj:GetSurfaceArea() * 6.45
	end
	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end
	
	local Armour = EmptyMass*1000 / self.ACF.Aera / 0.78 --So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume/ACF.Threshold							--Setting the threshold of the prop aera gone 
	local Percent = 1 
	
	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health/self.ACF.MaxHealth
	end
	
	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent/2)
	self.ACF.MaxArmour = Armour
	self.ACF.Type = nil
	self.ACF.Mass = self.Mass
	self.ACF.Density = (self:GetPhysicsObject():GetMass()*1000) / self.ACF.Volume
	self.ACF.Type = "Prop"
	
end

function ENT:ACF_OnDamage( Entity, Energy, FrAera, Angle, Inflictor, Bone, Type )	--This function needs to return HitRes

	local Mul = (((Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS") and ACF.HEATMulAmmo) or 1) --Heat penetrators deal bonus damage to ammo
	local HitRes = ACF_PropDamage( Entity, Energy, FrAera * Mul, Angle, Inflictor )	--Calling the standard damage prop function
	
	if self.Exploding or not self.IsExplosive then return HitRes end
	
	if HitRes.Kill then
		if hook.Run("ACF_AmmoExplode", self, self.BulletData ) == false then return HitRes end
		self.Exploding = true
		if( Inflictor and Inflictor:IsValid() and Inflictor:IsPlayer() ) then
			self.Inflictor = Inflictor
		end
		if self.Ammo > 1 and (not (self.BulletData.Type == "Refill")) then
			ACF_ScaledExplosion( self )
		else
--			ACF_HEKill( self, VectorRand() )
			self:Remove()
			--print("HEKill")
		end
	end
	
	-- cookoff chance calculation
	if self.Damaged then return HitRes end

	if table.IsEmpty( self.BulletData or {} ) then  
		self:Remove()	
	else

	local Ratio = (HitRes.Damage/self.BulletData.RoundVolume)^0.2

	local CMul = 1 --30% Chance to detonate, 5% chance to cookoff
	if Type == "HEAT" or Type == "THEAT" or Type == "HEATFS"or Type == "THEATFS" then
		Mul = ACF.HEATMulAmmo --Heat penetrators deal bonus damage to ammo, 90% chance to detonate, 15% chance to cookoff
		CMul = 6
	elseif Type == "HE" then
		CMul = 3	
	end	

	local DetRand = 0	

	if (self.BulletData.Type == "Refill") then
		DetRand = 0.75
	else
		DetRand = math.Rand(0,1) * CMul
	end
	
	if DetRand >= 0.95 then --Tests if cooks off
		self.Inflictor = Inflictor
		self.Damaged = CurTime() + (5 - Ratio*3)
--		print("Cookoff")
	elseif DetRand >= 0.7 then  
		self.Inflictor = Inflictor
		self.Damaged = 1 --Instant explosion guarenteed		
--		print("Instant boom")
	end
	
	end

	return HitRes --This function needs to return HitRes
end

function MakeACF_Ammo(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15)

	if not Owner:CheckLimit("_acf_ammo") then return false end
	
	local Ammo = ents.Create("acf_ammo")
	if not Ammo:IsValid() then return false end
	Ammo:SetAngles(Angle)
	Ammo:SetPos(Pos)
	Ammo:Spawn()
	Ammo:SetPlayer(Owner)
	Ammo.Owner = Owner
	
	Ammo.Model = ACF.Weapons.Ammo[Id].model 
	Ammo:SetModel( Ammo.Model )	
	
	Ammo:PhysicsInit( SOLID_VPHYSICS )      	
	Ammo:SetMoveType( MOVETYPE_VPHYSICS )     	
	Ammo:SetSolid( SOLID_VPHYSICS )
	
	Ammo.Id = Id
	Ammo:CreateAmmo(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15)
	
	local vol = math.floor(Ammo:GetPhysicsObject():GetVolume())

	Ammo.Ammo = Ammo.Capacity

	Ammo.EmptyMass = ACF.Weapons.Ammo[Ammo.Id].weight or 1


	Ammo.Mass = Ammo.EmptyMass + Ammo.AmmoMassMax
	Ammo.LastMass = 1
	
	Ammo:UpdateMass()
	
	Owner:AddCount( "_acf_ammo", Ammo )
	Owner:AddCleanup( "acfmenu", Ammo )
	
	table.insert(ACF.AmmoCrates, Ammo)
	
	
	return Ammo
end
list.Set( "ACFCvars", "acf_ammo", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10", "data11", "data12", "data13", "data14", "data15"} )
duplicator.RegisterEntityClass("acf_ammo", MakeACF_Ammo, "Pos", "Angle", "Id", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10" , "RoundData11", "RoundData12", "RoundData13", "RoundData14", "RoundData15" )
function ENT:Update( ArgsTable )
	
	-- That table is the player data, as sorted in the ACFCvars above, with player who shot, 
	-- and pos and angle of the tool trace inserted at the start

	local msg = "Ammo crate updated successfully!"
	
	if ArgsTable[1] ~= self.Owner then -- Argtable[1] is the player that shot the tool
		return false, "You don't own that ammo crate!"
	end
	
	if ArgsTable[6] == "Refill" then -- Argtable[6] is the round type. If it's refill it shouldn't be loaded into guns, so we refuse to change to it
		return false, "Refill ammo type is only avaliable for new crates!"
	end
	
	if ArgsTable[5] ~= self.RoundId then -- Argtable[5] is the weapon ID the new ammo loads into
		for Key, Gun in pairs( self.Master ) do
			if IsValid( Gun ) then
				Gun:Unlink( self )
			end
		end
		msg = "New ammo type loaded, crate unlinked."
	else -- ammotype wasn't changed, but let's check if new roundtype is blacklisted
		local Blacklist = ACF.AmmoBlacklist[ ArgsTable[6] ] or {}
		
		for Key, Gun in pairs( self.Master ) do
			if IsValid( Gun ) and table.HasValue( Blacklist, Gun.Class ) then
				Gun:Unlink( self )
				msg = "New round type cannot be used with linked gun, crate unlinked."
			end
		end
	end
	
	local AmmoPercent = self.Ammo/math.max(self.Capacity,1)
	
	self:CreateAmmo(ArgsTable[4], ArgsTable[5], ArgsTable[6], ArgsTable[7], ArgsTable[8], ArgsTable[9], ArgsTable[10], ArgsTable[11], ArgsTable[12], ArgsTable[13], ArgsTable[14], ArgsTable[15], ArgsTable[16], ArgsTable[17], ArgsTable[18], ArgsTable[19])	

	self.Ammo = math.floor(self.Capacity*AmmoPercent)
	
	self.LastMass = 1 -- force update of mass
	self:UpdateMass()
	
	return true, msg
	
end

function ENT:UpdateOverlayText()
	
	local roundType = self.RoundType
	
	
	if table.IsEmpty( self.BulletData or {} ) then  return end

	if self.BulletData.Tracer and self.BulletData.Tracer > 0 then 
		roundType = roundType .. "-T"
	end
	
	local text = roundType .. " - " .. self.Ammo .. " / " .. self.Capacity
	--text = text .. "\nRound Type: " .. self.RoundType
	
	local RoundData = ACF.RoundTypes[ self.RoundType ]
	
	if RoundData and RoundData.cratetxt then
		text = text .. "\n" .. RoundData.cratetxt( self.BulletData, self )
	end

	if self.IsTwoPiece then
		text = text .. "\nUses 2 piece ammo\n30% reload penalty"
	end


	if not self.Legal then
		text = text .. "\nNot legal, disabled for " .. math.ceil(self.NextLegalCheck - ACF.CurTime) .. "s\nIssues: " .. self.LegalIssues
	end



	self:SetOverlayText( text )
	
end

function ENT:CreateAmmo(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10 , Data11 , Data12 , Data13 , Data14 , Data15)
	
	--Weapon this round loads into, ie 140mmC, 105mmH ...
	if Data1 == '20mmHRAC' then                            --checking if its an old gun
	    self.RoundId = '20mmRAC'                           --replacing it with the current one
	elseif Data1 == '30mmHRAC' then
	    self.RoundId = '30mmRAC'
	elseif Data1 == '105mmSB' then
	    self.RoundId = '100mmSBC'
	elseif Data1 == '120mmSB' then
	    self.RoundId = '120mmSBC'
	elseif Data1 == '140mmSB' then
	    self.RoundId = '140mmSBC'
	elseif Data1 == '170mmSB' then
	    self.RoundId = '170mmSBC'
	else
	    self.RoundId = ( Data1 or '100mmC'	)
	end

	local GunData = list.Get("ACFEnts").Guns[self.RoundId]
    if not GunData then  
		self:Remove()
		return
	end

	--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght

	self.RoundType = ( Data2 or "AP"	)   --Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = ( Data3 or 0 )   --Lenght of propellant
	self.RoundProjectile = ( Data4 or 0 )   --Lenght of the projectile
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
	
	
	local PlayerData = {}   --what a mess
		PlayerData.Id           = self.RoundId 
		PlayerData.Type         = self.RoundType 
		PlayerData.PropLength   = self.RoundPropellant 
		PlayerData.ProjLength   = self.RoundProjectile 
		PlayerData.Data5        = self.RoundData5 
		PlayerData.Data6        = self.RoundData6 
		PlayerData.Data7        = self.RoundData7 
		PlayerData.Data8        = self.RoundData8 
		PlayerData.Data9        = self.RoundData9 
		PlayerData.Data10       = self.RoundData10 
		PlayerData.Data11       = self.RoundData11 	
		PlayerData.Data12       = self.RoundData12 	
		PlayerData.Data13       = self.RoundData13 	
		PlayerData.Data14       = self.RoundData14 	
		PlayerData.Data15       = self.RoundData15 
		
		
	self.ConvertData = ACF.RoundTypes[self.RoundType].convert
	self.BulletData = self:ConvertData( PlayerData )
	
	local Min,Max = self:GetCollisionBounds()  --Getting entity´s dimensions
	local Size = (Max - Min)
    --print(Size)
	local Efficiency = 0.1576 * ACF.AmmoMod
	local vol = math.floor(self:GetPhysicsObject():GetVolume())

	if not (self.BulletData.Type == "Refill") then   --ammo capacity start code

		local width = (GunData.caliber)/ACF.AmmoWidthMul/1.6
		local shellLength = ((self.BulletData.PropLength or 0) + (self.BulletData.ProjLength or 0))/ACF.AmmoLengthMul/3
	
		self.Volume = vol*Efficiency

		--Vertical placement
		local cap1 = (math.floor(Size.z/shellLength) * math.floor(Size.x/width) * math.floor(Size.y/width)) or 1
		--Horizontal Placement 1
		local cap2 = (math.floor(Size.x/shellLength) * math.floor(Size.z/width) * math.floor(Size.y/width)) or 1
		--Horizontal placement 2
		local cap3 = (math.floor(Size.y/shellLength) * math.floor(Size.z/width) * math.floor(Size.x/width)) or 1
		--Vertical 2 piece placement
		local cap4 = math.floor(math.floor(Size.z/shellLength*2)/2 * math.floor(Size.x/width) * math.floor(Size.y/width)) or 1
		--Horizontal 2 piece  Placement 1
		local cap5 = math.floor(math.floor(Size.x/shellLength*2)/2 * math.floor(Size.z/width) * math.floor(Size.y/width)) or 1
		--Horizontal 2 piece  placement 2
		local cap6 = math.floor(math.floor(Size.y/shellLength*2)/2 * math.floor(Size.z/width) * math.floor(Size.x/width)) or 1


	local tval1 = math.max(cap1,cap2,cap3)
	local tval2 = math.max(cap4,cap5,cap6)

	if (tval2-tval1)/(tval1+tval2) > 0.3 then --2 piece ammo time, uses 2 piece if 2 piece leads to more than 30% shells
		self.Capacity = tval2
		self.IsTwoPiece = true
	else
		self.Capacity = tval1
		self.IsTwoPiece = false
	end


	self.AmmoMassMax = ((self.BulletData.ProjMass + self.BulletData.PropMass) * self.Capacity * 2) or 1 -- why *2 ?
	
	else -- for refill ammocrates Calculations 

	local vol = math.floor(self:GetPhysicsObject():GetVolume())
	self.Volume = vol*Efficiency
	
	self.Capacity = 99999999
	self.AmmoMassMax = vol*1	
	
	end -- end capacity calculations
	
	self.Caliber = GunData.caliber or 1
	self.RoFMul = (vol > 40250) and (1-(math.log(vol*0.00066)/math.log(2)-4)*0.05) or 1 --*0.0625 for 25% @ 4x8x8, 0.025 10%, 0.0375 15%, 0.05 20%
	self.RoFMul = self.RoFMul + (((self.IsTwoPiece) and 0.3) or 0) --30% ROF penalty for 2 piece

	self:SetNWString( "Ammo", self.Ammo )
	self:SetNWString( "WireName", GunData.name .. " Ammo" )
	
	self.NetworkData = ACF.RoundTypes[self.RoundType].network
	self:NetworkData( self.BulletData )
	
	self:UpdateOverlayText()
	
end

function ENT:UpdateMass()
	self.Mass = self.EmptyMass + self.AmmoMassMax*(self.Ammo/math.max(self.Capacity,1))
	
	--reduce superflous engine calls, update crate mass every 5 kgs change or every 10s-15s
	if math.abs((self.LastMass or 0) - self.Mass) > 5 or CurTime() > self.NextMassUpdate then
		self.LastMass = self.Mass
		self.NextMassUpdate = CurTime()+math.Rand(10,15)
		local phys = self:GetPhysicsObject()  	
		if (phys:IsValid()) then 
			phys:SetMass( self.Mass ) 
		end
	end
	
end

function ENT:GetInaccuracy()
	local SpreadScale = ACF.SpreadScale
	local inaccuracy = 0
	local Gun = list.Get("ACFEnts").Guns[self.RoundId]
	
	if Gun then
		local Classes = list.Get("ACFClasses")
		inaccuracy = (Classes.GunClass[Gun.gunclass] or {spread = 0}).spread
	end
	
	local coneAng = inaccuracy * ACF.GunInaccuracyScale
	return coneAng
end

function ENT:TriggerInput( iname, value )

	if (iname == "Active") then
		if value > 0 then
			self.Active = true

			if self.Legal then
				self.Load = true
				self:FirstLoad()
			end
		else
			self.Active = false
			self.Load = false
		end
	elseif (iname == "Fuse Length" and value > 0 and (self.BulletData.RoundType == "HE" or self.BulletData.RoundType == "APHE")) then
	end

end

function ENT:FirstLoad()

	for Key,Value in pairs(self.Master) do
		local Gun = self.Master[Key]
		if IsValid(Gun) and Gun.FirstLoad and Gun.BulletData.Type == "Empty" and Gun.Legal then
			Gun:LoadAmmo(false, false)
		end
	end
	
end

function ENT:Think()
	
	if ACF.CurTime > self.NextLegalCheck then
		--print('time passed!')

		self.Legal, self.LegalIssues = ACF_CheckLegal(self, self.Model, math.floor(self.EmptyMass), nil, true, true)

		self.NextLegalCheck = ACF.Legal.NextCheck(self.legal)

		self:UpdateOverlayText()

		if not self.Legal then
			self.Load = false
		else
			--if legal, go back to the action
			if self.Active then self.Load = true end
		end
		
	end
	
	self:UpdateMass()
	
	if self.Ammo ~= self.AmmoLast or not self.Legal then
		self:UpdateOverlayText()
		self.AmmoLast = self.Ammo
	end
	
	local color = self:GetColor()
	self:SetNWVector("TracerColour", Vector( color.r, color.g, color.b ) )
	
	local cvarGrav = GetConVar("sv_gravity")
	local vec = Vector(0,0,cvarGrav:GetInt()*-1)
	
	if( self.sitp_inspace ) then
		vec = Vector(0, 0, 0)
	end
		
	self:SetNWVector("Accel", vec)
		
	self:NextThink( CurTime() +  1 )
	
	-- cookoff handling
	if self.Damaged then
	
		CrateType = self.BulletData.Type or "Refill"
		
		if CrateType == "Refill" then
		
			self:Remove()
			
		elseif self.Ammo <= 1 or self.Damaged < CurTime() then -- immediately detonate if there's 1 or 0 shells
		
			ACF_ScaledExplosion( self ) -- going to let empty crates harmlessly poot still, as an audio cue it died
			
		else
		
				if math.Rand(0,150) > self.BulletData.RoundVolume^0.5 and math.Rand(0,1) < self.Ammo/math.max(self.Capacity,1) and ACF.RoundTypes[CrateType] then
				
				
					self:EmitSound( "ambient/explosions/explode_4.wav", 350, math.max(255 - self.BulletData.PropMass*100,60)  )	
					local Speed = ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass/2, self.Caliber )

					self.BulletData.Pos = self:LocalToWorld(self:OBBCenter() + VectorRand()*(self:OBBMaxs()-self:OBBMins())/2)
					self.BulletData.Flight = (VectorRand()):GetNormalized() * Speed * 39.37 + self:GetVelocity()
					self.BulletData.Owner = self.Inflictor or self.Owner
					self.BulletData.Gun = self
					self.BulletData.Crate = self:EntIndex()
					self.CreateShell = ACF.RoundTypes[CrateType].create
					self:CreateShell( self.BulletData )
					
					self.Ammo = self.Ammo - 1
					
				end
				
			self:NextThink( CurTime() + 0.01 + self.BulletData.RoundVolume^0.5/100 )
					
		end

	-- Completely new, fresh, genius, beautiful, flawless refill system.
	elseif self.RoundType == "Refill" and self.Load then
	
	
		for _,Ammo in pairs( ACF.AmmoCrates ) do
		
			if Ammo.RoundType ~= "Refill" then
			
				local dist = self:GetPos():Distance(Ammo:GetPos())
				
				if dist < ACF.RefillDistance then
				
					if Ammo.Capacity > Ammo.Ammo then
					
						self.SupplyingTo = self.SupplyingTo or {}
							
						if not table.HasValue( self.SupplyingTo, Ammo:EntIndex() ) then
						
							table.insert(self.SupplyingTo, Ammo:EntIndex())
							self:RefillEffect( Ammo )
								
						end
								
						local Supply = math.ceil((1/((Ammo.BulletData.ProjMass+Ammo.BulletData.PropMass)*5000))*self:GetPhysicsObject():GetMass()^1.2)
						--Msg(tostring(50000).."/"..((Ammo.BulletData.ProjMass+Ammo.BulletData.PropMass)*1000).."/"..dist.."="..Supply.."\n")
						local Transfert = math.min(Supply, Ammo.Capacity - Ammo.Ammo)
						Ammo.Ammo = Ammo.Ammo + Transfert
--						self.Ammo = self.Ammo - Transfert
							
						Ammo.Supplied = true
						Ammo.Entity:EmitSound( "weapons/shotgun/shotgun_reload"..math.random(1,3)..".wav", 350, 100, 0.30 )
						
					end
				end
			end
		end
	end
	
	-- checks to stop supply
	if self.SupplyingTo then
		for k, EntID in pairs( self.SupplyingTo ) do
			local Ammo = ents.GetByIndex(EntID)
			if not IsValid( Ammo ) then 
				table.remove(self.SupplyingTo, k)
				self:StopRefillEffect( EntID )
			else
				local dist = self:GetPos():Distance(Ammo:GetPos())
				-- If ammo crate is out of refill max distance or is full or our refill crate is damaged or just in-active then stop refiliing it.
				if (dist > ACF.RefillDistance) or (Ammo.Capacity <= Ammo.Ammo) or self.Damaged or not self.Load or not Ammo.Legal then
					table.remove(self.SupplyingTo, k)
					self:StopRefillEffect( EntID )
				end
			end
		end
	end
	
	Wire_TriggerOutput(self, "Munitions", self.Ammo)
	return true

end

function ENT:RefillEffect( Target )
	umsg.Start("ACF_RefillEffect")
		umsg.Float( self:EntIndex() )
		umsg.Float( Target:EntIndex() )
		umsg.String( Target.RoundType )
	umsg.End()
end

function ENT:StopRefillEffect( TargetID )
	umsg.Start("ACF_StopRefillEffect")
		umsg.Float( self:EntIndex() )
		umsg.Float( TargetID )
	umsg.End()
end

function ENT:ConvertData()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:NetworkData()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:OnRemove()
	
	for Key,Value in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self )
			self.Ammo = 0
		end
	end
	for k,v in pairs(ACF.AmmoCrates) do
		if v == self then
			table.remove(ACF.AmmoCrates,k)
		end
	end
	
end
