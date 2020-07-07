AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
 
include ("shared.lua")
 
SWEP.Weight = 10
SWEP.DeployDelay = 1 --Time in seconds after pulling out before firing
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetNextPrimaryFire( CurTime() + self.DeployDelay )
	if IsValid(self:GetParent()) then
		self.Owner = self:GetParent()
		self:SetOwner(self:GetParent())
	end
	self:InitBulletData()
	self:UpdateFakeCrate()

end

function SWEP:UpdateFakeCrate(realcrate)
	if not IsValid(self.FakeCrate) then
		self.FakeCrate = ents.Create("acf_fakecrate2")
	end

	self.FakeCrate:RegisterTo(self)
	
	self.BulletData["Crate"] = self.FakeCrate:EntIndex()
	self:SetNWString( "Sound", self.Primary.Sound )
end

function SWEP:OnRemove()

if IsValid(self.Owner) then
    self.Owner:SetWalkSpeed( self.NormalPlayerWalkSpeed)
    self.Owner:SetRunSpeed( self.NormalPlayerRunSpeed)
end

	if not IsValid(self.FakeCrate) then return end
	
	local crate = self.FakeCrate
	timer.Simple(15, function() if IsValid(crate) then crate:Remove() end end)

end

local nosplode = {AP = true, APC = true, APCBC = true, APDS = true, APDSS = true, HVAP = true, HP = true, FLR = true,HEAT = true, THEAT = true}
local nopen = {HE = true, SM = true, FLR = true, HEAT = true, THEAT = true}
local heat = {HEAT = true}
local heatt = {THEAT = true}

function SWEP:DoAmmoStatDisplay()
    local bdata = self.BulletData
    
    local roundType = bdata.Type
	
	if bdata.Tracer and bdata.Tracer > 0 then 
		roundType = roundType .. "-T"
	end
	
	local sendInfo = string.format( "%smm %s ammo: %im/s speed",
                                   tostring(bdata.Caliber * 10),
									roundType,
									self.ThrowVel or bdata.MuzzleVel)
	
        
        if not nopen[bdata.Type] then
		local Energy = ACF_Kinetic( bdata.MuzzleVel*39.37 , bdata.ProjMass, bdata.LimitVel )
		local MaxPen = (Energy.Penetration/bdata.PenAera)*ACF.KEtoRHA
            sendInfo = sendInfo .. string.format( 	", %.1fmm pen",MaxPen)
        end
        
        if not nosplode[bdata.Type] then
            sendInfo = sendInfo .. string.format( 	", %.1fm blast",(bdata.FillerMass)^0.33*8)
            
		end
		
        if heat[bdata.Type] then
            sendInfo = sendInfo .. string.format( 	", %.1fm blast",(bdata.BoomFillerMass)^0.33*8)
		local Energy = ACF_Kinetic( bdata.SlugMV*39.37 , bdata.SlugMass, 999999 )
		local MaxPen = (Energy.Penetration/bdata.SlugPenAera)*ACF.KEtoRHA

            sendInfo = sendInfo .. string.format( 	", %.1fmm pen",MaxPen)
		end
		
        if heatt[bdata.Type] then
            sendInfo = sendInfo .. string.format( 	", %.1fm blast",(bdata.BoomFillerMass)^0.33*8)
		local Energy = ACF_Kinetic( bdata.SlugMV*39.37 , bdata.SlugMass, 999999 )
		local MaxPen = (Energy.Penetration/bdata.SlugPenAera)*ACF.KEtoRHA
           sendInfo = sendInfo .. string.format( 	", (1)%.1fmm pen",MaxPen)
		local Energy = ACF_Kinetic( bdata.SlugMV2*39.37 , bdata.SlugMass2, 999999 )
		local MaxPen = (Energy.Penetration/bdata.SlugPenAera2)*ACF.KEtoRHA
           sendInfo = sendInfo .. string.format( 	", (2)%.1fmm pen",MaxPen)
		end		
		
		
	
	self.Owner:SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 10)", sendInfo))
end

function SWEP:ACEFireBullet()

	if not self.Owner:HasGodMode() then

	self.Owner = self:GetParent()
--	self:SetOwner(self:GetParent())
	local ZoomedNumber = self.Zoomed and 1 or 0
	local CrouchedNumber = self.Owner:Crouching() and 1 or 0
		
	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()

	local sprinting = (self.Owner:KeyDown(IN_SPEED) and 1 or 0.5) * 2 --Sprinting doubles inaccuracy
	
	local EyeAngle = self.Owner:EyeAngles()
	--Boolet Firing
	local RandUnitSquare = (EyeAngle:Up() * (2 * math.random() - 1) + EyeAngle:Right() * (2 * math.random() - 1))
	local Spread = RandUnitSquare:GetNormalized() * self.Primary.Cone * self.InaccuracyAccumulation * (1 - self.ZoomAccuracyImprovement * ZoomedNumber - self.CrouchAccuracyImprovement * CrouchedNumber) * sprinting * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4)))
--	local Spread = Vector(0 , 0 , 0)
--	local Spread = EyeAngle:Forward()/10 * SWEP.coneAng * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4))) 
	local ShootVec = EyeAngle:Forward()+Spread
--	local ShootVec = EyeAngle:Forward()
	
	self.BulletData.Pos = MuzzlePos+EyeAngle:Forward()*30 --35
	self.BulletData.Flight = ShootVec * self.BulletData.MuzzleVel * 39.37 + self.Owner:GetVelocity()
	
--	print("MV: "..self.BulletData.Flight:Length()/39.37)
	self.BulletData.Owner = self.Owner
	self.BulletData.Gun = self
	self.BulletData.Crate = self.FakeCrate:EntIndex()
	
	
	if self.BeforeFire then
		self:BeforeFire()
	end
	
--function Round.create( Gun, BulletData )
	
--	ACF_CreateBullet( BulletData )
	
--end
	
--	self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
	ACE_SWEP_CreateBullet( self.BulletData )	
--	ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Update" , 0 , self.BulletData.Pos)


--	self.Owner:SetEyeAngles( EyeAngle+Angle(math.random(-1,1)*self.Primary.RecoilAngleVer,math.random(-1,1)*self.Primary.RecoilAngleHor,0) * (self.InaccuracyAccumulation - CrouchedNumber * self.CrouchRecoilImprovement - self.ZoomRecoilImprovement * ZoomedNumber) )
	else
		print("SWEP fired in godmode. Refusing to create bullet")
	end
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end
    self.Owner:SetWalkSpeed(self.NormalPlayerWalkSpeed)
    self.Owner:SetRunSpeed(self.NormalPlayerRunSpeed)
	return true
end

function SWEP:MuzzleEffect( MuzzlePos, MuzzleDir, realcall )

end


function ACE_SWEP_CreateBullet( BulletData )
	
--	if not IsValid(Swep) then error("Tried to create swep round with no swep or owner!") return end

	ACF.CurBulletIndex = ACF.CurBulletIndex + 1		--Increment the index
	if ACF.CurBulletIndex > ACF.BulletIndexLimt then
		ACF.CurBulletIndex = 1
	end

	--Those are BulletData settings that are global and shouldn't change round to round	

	local cvarGrav = GetConVar("sv_gravity")
	BulletData["Accel"] = Vector(0,0,cvarGrav:GetInt()*-1)
	BulletData["LastThink"] = ACF.SysTime
	BulletData["FlightTime"] = 0
	BulletData["TraceBackComp"] = BulletData.Owner:GetVelocity():Dot(BulletData.Flight:GetNormalized())
	--BulletData.FiredPos = BulletData.Pos --when adding back in, update acfdamage roundimpact rico
	--BulletData.FiredTime = ACF.SysTime --same as fuse inittime, can combine when readding
	if type(BulletData["FuseLength"]) ~= "number" then
		BulletData["FuseLength"] = 0
	else
		--print("Has fuse")
		if BulletData["FuseLength"] > 0 then
			BulletData["InitTime"] = ACF.SysTime
		end
	end

	BulletData["Filter"] = { BulletData["Gun"] , BulletData.Owner}
	BulletData["Index"] = ACF.CurBulletIndex
	ACF.Bullet[ACF.CurBulletIndex] = table.Copy(BulletData)		--Place the bullet at the current index pos
--	print(ACF.Bullet[ACF.CurBulletIndex].Flight:Length()/39.37)
	ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )
	ACF_CalcBulletFlight( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex] )
	
end

function SWEP:Equip()

	self.Owner:GiveAmmo( 8*self.Primary.ClipSize, self.Primary.Ammo	, false )
	self:DoAmmoStatDisplay()
	self:SetNextPrimaryFire( CurTime() + self.DeployDelay )
end



function SWEP:Deploy()

		self.NormalPlayerWalkSpeed = self.Owner:GetWalkSpeed()
		self.NormalPlayerRunSpeed = self.Owner:GetRunSpeed()
		
		self.Owner:SetWalkSpeed( self.NormalPlayerWalkSpeed * self.CarrySpeedMul )
		self.Owner:SetRunSpeed( self.NormalPlayerRunSpeed * self.CarrySpeedMul * 0.8)
		self:SetNextPrimaryFire( CurTime() + self.DeployDelay )
		self:Think()
		self:DoAmmoStatDisplay()
		
		if self.Zoomed then
			self:SetZoom(false)
		end
		
	end