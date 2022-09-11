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


-- Other settings
SWEP.Weight			= 10

-- Weapon info
SWEP.Purpose		= "BAD NADE!"
SWEP.Instructions	= "Left mouse to throw grenade"

-- Primary fire settings
SWEP.Primary.Sound			= "weapons/slam/throw.wav"
SWEP.Primary.NumShots		= 1
SWEP.Primary.Delay			= 2
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= 0
SWEP.Primary.Ammo		= "RPG_Round"

SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1

SWEP.lastFire = CurTime()
--

function SWEP:ThrowNade(power)
	local owner = self:GetOwner()

	timer.Simple(1, function()
		local wep = owner:GetActiveWeapon()
		if owner:Alive() and wep:GetClass() ~= "weapon_ace_grenade" then return end

		if owner:Alive() then
			wep:EmitSound(Sound(wep.Primary.Sound), 100, 100, 1, CHAN_WEAPON)
		else
			power = 0
		end

		local ent = ents.Create( "ace_grenade" )

		if ( IsValid( ent ) ) then
			local aim = owner:GetAimVector()
			ent:SetPos( owner:GetShootPos() )
			ent:SetAngles( owner:EyeAngles() )
			ent:Spawn()
			ent:GetPhysicsObject():ApplyForceCenter(aim * power + owner:GetVelocity() * 5) --5 = mass of nade
			ent:SetOwner( owner )
		end
	end)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if (self:Ammo1() == 0) and (self:Clip1() == 0) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	if CLIENT then
		return
	end

	local owner = self:GetOwner()

	self:SendWeaponAnim( ACT_VM_PULLPIN  )
	owner:SetAnimation( PLAYER_ATTACK1 )

	self:ThrowNade(4000)

	self.lastFire = CurTime()
	self:TakePrimaryAmmo(1)

end


function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	if (self:Ammo1() == 0) and (self:Clip1() == 0) then return end
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if CLIENT then
		return
	end

	self:SendWeaponAnim( ACT_VM_PULLPIN )
	self:GetOwner():SetAnimation( ACT_HANDGRENADE_THROW1 )

	local owner = self:GetOwner()

	self:SendWeaponAnim( ACT_VM_PULLPIN  )
	owner:SetAnimation( PLAYER_ATTACK1 )

	self:ThrowNade(1000)

	self.lastFire = CurTime()
	self:TakePrimaryAmmo(1)

end

function SWEP:Think()
end

function SWEP:Reload()
	if CurTime() < self.lastFire + self.Primary.Delay then return end

	if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 and self.ReloadSound then
		self:EmitSound(Sound(self.ReloadSound))
	end
	self:DefaultReload(ACT_VM_DRAW )

	return true
end