AddCSLuaFile("shared.lua")
SWEP.Base = "weapon_ace_base"
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Grenades/Mines"

if CLIENT then
	SWEP.PrintName		= "Frag Grenade"
	SWEP.Slot		    = 4
	SWEP.SlotPos		= 3
end

SWEP.Spawnable		= true

--Visual
SWEP.ViewModelFlip 	= true
SWEP.ViewModel		= "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel		= "models/weapons/w_eq_fraggrenade.mdl"
SWEP.ReloadSound	= "weapons/knife/knife_deploy1.wav"
SWEP.HoldType		= "grenade"
SWEP.CSMuzzleFlashes	= true


-- Other settings
SWEP.Weight			= 10

-- Weapon info
SWEP.Purpose		= "BAD NADE!"
SWEP.Instructions	= "Left mouse to drop mine"

-- Primary fire settings
SWEP.Primary.Sound			= "weapons/slam/throw.wav"
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 10
SWEP.Primary.RecoilAngle	= 15
SWEP.Primary.RecoilAngleVer	= 0.0
SWEP.Primary.RecoilAngleHor	= 0.0
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 2
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= 0
SWEP.Primary.Ammo		= "RPG_Round"

SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1

SWEP.ReloadSoundEnabled = 1

SWEP.AimOffset = Vector(0,0,0)
SWEP.InaccuracyAccumulation = 0
SWEP.lastFire = CurTime()

SWEP.MaxInaccuracyMult = 0
SWEP.InaccuracyAccumulationRate = 0.3
SWEP.InaccuracyDecayRate = 1

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, -15, 2.98)
SWEP.ZoomPos = Vector(2,-2,2)
SWEP.IronSightsAng = Angle(0.45, 0, 0)
SWEP.CarrySpeedMul = 1 --WalkSpeedMult when carrying the weapon

SWEP.ZoomAccuracyImprovement = 0.5 -- 0.3 means 0.7 the inaccuracy
SWEP.ZoomRecoilImprovement = 0.2 -- 0.3 means 0.7 the recoil movement

SWEP.CrouchAccuracyImprovement = 0.4 -- 0.3 means 0.7 the inaccuracy
SWEP.CrouchRecoilImprovement = 0.2 -- 0.3 means 0.7 the recoil movement


SWEP.Pin = true
--

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if (self:Ammo1() == 0) and (self:Clip1() == 0) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound(Sound(self.Primary.Sound), 100, 100, 1, CHAN_WEAPON)

	if CLIENT then
		return
	end

	self.BulletData.Owner = self:GetOwner()
	self.BulletData.Gun = self
	self.InaccuracyAccumulation = math.Clamp(self.InaccuracyAccumulation + self.InaccuracyAccumulationRate - self.InaccuracyDecayRate * (CurTime() - self.lastFire), 1, self.MaxInaccuracyMult)


	local Forward = self:GetOwner():EyeAngles():Forward()

	local Up = self:GetOwner():EyeAngles():Up()

	local ent = ents.Create( "ace_grenade" )

	if ( IsValid( ent ) ) then

		ent:SetPos( self:GetOwner():GetShootPos() + Forward * 32 )
		ent:SetAngles( self:GetOwner():EyeAngles() )
		ent:Spawn()
		ent:GetPhysicsObject():ApplyForceCenter((Forward * 800 + Up * 100 + self:GetOwner():GetVelocity()) * 5)
		ent:SetOwner( self:GetOwner() )
	end

	self:SendWeaponAnim( ACT_VM_THROW )
	self:GetOwner():SetAnimation( ACT_HANDGRENADE_THROW1 )

	self.lastFire = CurTime()

	if (self.Primary.TakeAmmoPerBullet) then
		self:TakePrimaryAmmo(self.Primary.NumShots)
	else
		self:TakePrimaryAmmo(1)
	end

end


function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	if (self:Ammo1() == 0) and (self:Clip1() == 0) then return end
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:EmitSound(Sound(self.Primary.Sound), 100, 100, 1, CHAN_WEAPON )

	if CLIENT then
		return
	end

		self:SendWeaponAnim( ACT_VM_PULLPIN )
		self:GetOwner():SetAnimation( ACT_HANDGRENADE_THROW1 )

	self.BulletData.Owner = self:GetOwner()
	self.BulletData.Gun = self
	self.InaccuracyAccumulation = math.Clamp(self.InaccuracyAccumulation + self.InaccuracyAccumulationRate - self.InaccuracyDecayRate * (CurTime() - self.lastFire), 1, self.MaxInaccuracyMult)


	local Forward = self:GetOwner():EyeAngles():Forward()

	local Up = self:GetOwner():EyeAngles():Up()

	local ent = ents.Create( "ace_grenade" )

	if ( IsValid( ent ) ) then

		ent:SetPos( self:GetOwner():GetShootPos() + Forward * 32 )
		ent:SetAngles( self:GetOwner():EyeAngles() )
		ent:Spawn()
		ent:GetPhysicsObject():ApplyForceCenter((Forward * 400 - Up * 60 + self:GetOwner():GetVelocity()) * 5)
		ent:SetOwner( self:GetOwner() )
	end

	self:SendWeaponAnim( ACT_VM_PULLPIN  )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	self.lastFire = CurTime()

	if (self.Primary.TakeAmmoPerBullet) then
		self:TakePrimaryAmmo(self.Primary.NumShots)
	else
		self:TakePrimaryAmmo(1)
	end

end

function SWEP:Think()	--Jumping and throwing grenades for more range is allowed and encouraged
end

function SWEP:Reload()

	if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 and self.ReloadSoundEnabled == 1 then
		self:EmitSound(Sound(self.ReloadSound))
	end
	self:DefaultReload(ACT_VM_DRAW )

--player.GetByID( 1 ):GiveAmmo( 30-self:Clip1(), "AR2", true )
	self:Think()
	return true
end