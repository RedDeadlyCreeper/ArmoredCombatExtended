	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACE Base"
	SWEP.Author				= "RDC"
	SWEP.Contact			= "Discord: RDC#7737"	
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "y"
	SWEP.DrawCrosshair		= true
	SWEP.Purpose		= "You shouldn't have this"
	SWEP.Instructions       = ""

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACE Sweps"
SWEP.ViewModel 			= "models/weapons/v_snip_sg550.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_sg550.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.RecoilAngleVer	= 1
SWEP.Primary.RecoilAngleHor	= 1
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_SG550.Single"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

// misnomer.  the position of the acf muzzleflash.
SWEP.AimOffset = Vector(32, 8, -1)

// use this to chop the scope off your gun
SWEP.ScopeChopPos = Vector(0, 0, 0)
SWEP.ScopeChopAngle = Angle(0, 0, -90)

SWEP.ZoomTime = 0.4


SWEP.InaccuracyCrouchBonus = 0.7
SWEP.InaccuracyDuckPenalty = 6

SWEP.HasZoom = true
SWEP.HasScope = false

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false

SWEP.InaccuracyAccumulation = 1

SWEP.ZoomFOV = 50
SWEP.ZoomAccuracyImprovement = 0.9 -- 0.3 means 0.7 the inaccuracy
SWEP.ZoomRecoilImprovement = 0.6 -- 0.3 means 0.7 the recoil movement

SWEP.CrouchAccuracyImprovement = 0.5 -- 0.3 means 0.7 the inaccuracy
SWEP.CrouchRecoilImprovement = 0.7 -- 0.3 means 0.7 the recoil movement

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, -4.74, 2.98)
SWEP.ZoomPos = Vector(2,-2,2)
SWEP.IronSightsAng = Angle(0.45, 0, 0)
SWEP.CarrySpeedMul = 1 --WalkSpeedMult when carrying the weapon

SWEP.NormalPlayerWalkSpeed = 200
SWEP.NormalPlayerRunSpeed = 400



function SWEP:Think()
	
--	if CLIENT then
--		self:ZoomThink()
--	end
	local val = CurTime() + 0.25 
	if (!(self.Owner:IsOnGround())) and (self:GetNextPrimaryFire() < val ) then --If owner leaves ground cause 0.25 second penalty to firing
	self:SetNextPrimaryFire( val )
	end

	if self.ThinkAfter then self:ThinkAfter() end
	
	
	if SERVER then
        
        if self.Zoomed and not self:CanZoom() then
            self:SetZoom(false)
        end
        
	end
	
end

function SWEP:InitBulletData()
	
	self.BulletData = {}

		self.BulletData.Id = "7.62mmMG"
		self.BulletData.Type = "AP"
		self.BulletData.Id = 1
		self.BulletData.Caliber = 0.556
		self.BulletData.PropLength = 4 --Volume of the case as a cylinder * Powder density converted from g to kg		
		self.BulletData.ProjLength = 8 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
		self.BulletData.Data5 = 0  --He Filler or Flechette count
		self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
		self.BulletData.Data7 = 0
		self.BulletData.Data8 = 0
		self.BulletData.Data9 = 0
		self.BulletData.Data10 = 1 -- Tracer
		self.BulletData.Colour = Color(255, 0, 0)
		--
		self.BulletData.Data13 = 0 --THEAT ConeAng2
		self.BulletData.Data14 = 0 --THEAT HE Allocation
		self.BulletData.Data15 = 0
	
		self.BulletData.AmmoType  = self.BulletData.Type
		self.BulletData.FrAera    = 3.1416 * (self.BulletData.Caliber/2)^2
		self.BulletData.ProjMass  = self.BulletData.FrAera * (self.BulletData.ProjLength*7.9/1000)
		self.BulletData.PropMass  = self.BulletData.FrAera * (self.BulletData.PropLength*ACF.PDensity/1000) --Volume of the case as a cylinder * Powder density converted from g to kg
		self.BulletData.FillerVol = self.BulletData.Data5
		self.BulletData.FillerMass = self.BulletData.FillerVol * ACF.HEDensity/1000
		--		self.BulletData.DragCoef  = 0 --Alternatively manually set it
		self.BulletData.DragCoef  = ((self.BulletData.FrAera/10000)/self.BulletData.ProjMass)	

		--Don't touch below here
		self.BulletData.MuzzleVel = ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber )		
		self.BulletData.ShovePower = 0.2
		self.BulletData.KETransfert = 0.3
		self.BulletData.PenAera = self.BulletData.FrAera^ACF.PenAreaMod
		self.BulletData.Pos = Vector(0 , 0 , 0)
		self.BulletData.LimitVel = 800	
		self.BulletData.Ricochet = 60
		self.BulletData.Flight = Vector(0 , 0 , 0)
		self.BulletData.BoomPower = self.BulletData.PropMass + self.BulletData.FillerMass
		self.BulletData.FuseLength = 0
		--For Fake Crate
		self.Type = self.BulletData.Type
		self.BulletData.Tracer = self.BulletData.Data10
		self.Tracer = self.BulletData.Tracer
		self.Caliber = self.BulletData.Caliber
		self.ProjMass = self.BulletData.ProjMass
		self.FillerMass = self.BulletData.FillerMass
		self.DragCoef = self.BulletData.DragCoef
		self.Colour = self.BulletData.Colour
		self.DetonatorAngle = 80
		
end

function SWEP:CanZoom()

 --   local sprinting = self.Owner:KeyDown(IN_SPEED)
 --   if sprinting then return false end
    
    return true

end

function SWEP:SecondaryAttack()

	if SERVER and self.HasZoom and self:CanZoom() then
		self:SetZoom()
	end

	return false
	
end

function SWEP:SetZoom(zoom)

    if zoom == nil then
        self.Zoomed = not self.Zoomed
    else
        self.Zoomed = zoom
    end
	
	
	if SERVER then self:SetNWBool("Zoomed", self.Zoomed) end
	
	if self.Zoomed then
		
		if SERVER then 
            self:SetOwnerZoomSpeed(true)
            self.Owner:SetFOV(self.ZoomFOV, 0.25) 
        end
        
	else			
		
		if SERVER then 
            self:SetOwnerZoomSpeed(false)
            self.Owner:SetFOV(0, 0.25) 
        end
        
	end

	
--	self:GetViewModelPosition(self.Owner:EyePos(), self.Owner:EyeAngles())
end

function SWEP:SetOwnerZoomSpeed(setSpeed)
	if ( CLIENT ) then return end
    if setSpeed then
    
        self.Owner:SetWalkSpeed( math.min(self.NormalPlayerWalkSpeed * 0.5 * self.CarrySpeedMul,self.NormalPlayerWalkSpeed) )
        self.Owner:SetRunSpeed( math.min(self.NormalPlayerRunSpeed * 0.5 * self.CarrySpeedMul,self.NormalPlayerRunSpeed))
        
    elseif self.NormalPlayerWalkSpeed and self.NormalPlayerRunSpeed then
    
        self.Owner:SetWalkSpeed( math.min(self.NormalPlayerWalkSpeed * self.CarrySpeedMul,self.NormalPlayerWalkSpeed))
        self.Owner:SetRunSpeed( math.min(self.NormalPlayerRunSpeed * self.CarrySpeedMul,self.NormalPlayerRunSpeed))
        
    end

end


-- Adjust these variables to move the viewmodel's position
SWEP.IronSightsPos = Vector( 15, 0, 0 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

function SWEP:GetViewModelPosition( EyePos, EyeAng )
	local Mul = 0

	local Offset = self.IronSightsPos

	if ( self.IronSightsAng ) then
		EyeAng = EyeAng * 1

		EyeAng:RotateAroundAxis( EyeAng:Right(), 	self.IronSightsAng.x * Mul )
		EyeAng:RotateAroundAxis( EyeAng:Up(), 		self.IronSightsAng.y * Mul )
		EyeAng:RotateAroundAxis( EyeAng:Forward(),	self.IronSightsAng.z * Mul )
	end

	local Right 	= EyeAng:Right()
	local Up 		= EyeAng:Up()
	local Forward 	= EyeAng:Forward()

	EyePos = EyePos + Offset.x * Right * Mul
	EyePos = EyePos + Offset.y * Forward * Mul
	EyePos = EyePos + Offset.z * Up * Mul

	return EyePos, EyeAng
end	


function SWEP:DoImpactEffect( tr, nDamageType )
return true
end



function SWEP:DrawScope(Zoomed)
	if not (Zoomed and self.HasScope) then return false end
	
	local scrw = ScrW()
	local scrw2 = ScrW() / 2
	local scrh = ScrH()
	local scrh2 = ScrH() / 2
	
	local traceargs = util.GetPlayerTrace(LocalPlayer())
	traceargs.filter = {self.Owner, self.Owner:GetVehicle() or nil}
	local trace = util.TraceLine(traceargs)
		
	local scrpos = trace.HitPos:ToScreen()
	local devx = scrw2 - scrpos.x - 0.5
	local devy = scrh2 - scrpos.y - 0.5

	surface.SetDrawColor(0, 0, 0, 255) 

	local rectsides = ((scrw - scrh) / 2) * 0.7

	surface.SetDrawColor(0, 0, 0, 255) 

	

	surface.SetDrawColor(0, 0, 0, 255) 
	
	surface.SetMaterial(Material("gmod/scope"))
	surface.DrawTexturedRect(rectsides - devx, 0 - devy, scrw - rectsides * 2, scrh)
	
	surface.DrawRect(0, 0, rectsides + 2 - devx, scrh)
	surface.DrawRect(scrw - rectsides - 2 - devx, 0, rectsides + 2 + devx, scrh)
	
	if math.abs(devy) >= 0.5 then
		surface.DrawRect(rectsides + 2 - devx, 0, scrw - rectsides * 2, -devy)
		surface.DrawRect(rectsides + 2 - devx, scrh - devy, scrw - rectsides * 2, devy)
	end
	
	return true
end



function SWEP:DoDrawCrosshair( x, y )

	Zoom = self:GetNWBool("Zoomed") 


self:DrawScope(Zoom)

	ReticleSize = 1 + (self.Owner:KeyDown(IN_SPEED) and 0.5 or 0) + (self.Owner:Crouching() and -0.5 or 0) + (Zoom and -0.5 or 0) 
--	ReticleSize = 1
--	ReticleSize = self.InaccuracyAccumulation
--	print(self.InaccuracyAccumulation)

	surface.SetDrawColor( 255, 0, 0, 255 )
	surface.DrawLine((x + 30), y, (x + 15*ReticleSize), y)
	surface.DrawLine((x - 30), y, (x - 15*ReticleSize), y)
	surface.DrawLine(x, y + 30, x, y + 15*ReticleSize)
	surface.DrawLine(x, y - 30, x, y - 15*ReticleSize)
--	surface.DrawOutlinedRect( x - 32, y - 32, 64, 64 )

local scale = Vector( 15*ReticleSize, 15*ReticleSize, 0 )
local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )

if ReticleSize > 0 then

	surface.DrawRect( x - 1, y - 1, 2, 2 )
for a = 0, 360 - segmentdist, segmentdist do
	surface.DrawLine( x + math.cos( math.rad( a ) ) * scale.x, y - math.sin( math.rad( a ) ) * scale.y, x + math.cos( math.rad( a + segmentdist ) ) * scale.x, y - math.sin( math.rad( a + segmentdist ) ) * scale.y )
end

end

	return true

end