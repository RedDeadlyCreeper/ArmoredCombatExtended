AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('shared.lua')

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.AdminSpawnable			= true
SWEP.Author					= "Lazermaniac"
SWEP.Contact				= "lazermaniac@gmail.com"

SWEP.Instructions			= ACFTranslation.ACFCuttingTorch[3]

SWEP.Primary.Ammo			= "none"
SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Purpose				= ACFTranslation.ACFCuttingTorch[2]
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Automatic	= true
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Spawnable				= true
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 55
SWEP.ViewModel				= "models/weapons/v_cuttingtorch.mdl"
SWEP.WorldModel				= "models/weapons/w_cuttingtorch.mdl"

SWEP.PrintName			= ACFTranslation.ACFCuttingTorch[1]
SWEP.Slot				= 0
SWEP.SlotPos			= 6
SWEP.IconLetter			= "G"
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true





function SWEP:Initialize()
	if ( SERVER ) then 
		self:SetWeaponHoldType("pistol")--"357 hold type doesnt exist, it's the generic pistol one" Kaf
	end
	util.PrecacheSound( "ambient/energy/NewSpark03.wav" )
	util.PrecacheSound( "ambient/energy/NewSpark04.wav" )
	util.PrecacheSound( "ambient/energy/NewSpark05.wav" )
	util.PrecacheSound( "weapons/physcannon/superphys_small_zap1.wav" )
	util.PrecacheSound( "weapons/physcannon/superphys_small_zap2.wav" )
	util.PrecacheSound( "weapons/physcannon/superphys_small_zap3.wav" )
	util.PrecacheSound( "weapons/physcannon/superphys_small_zap4.wav" )
	util.PrecacheSound( "items/medshot4.wav" )
	
	self.LastSend = 0
end

function SWEP:Think()

	if SERVER then 	
	
		local userid = self.Owner
		local trace = {}
		trace.start = userid:GetShootPos()
		trace.endpos = userid:GetShootPos() + ( userid:GetAimVector() * 128	)
		trace.filter = userid --Not hitting the owner's feet when aiming down
		trace.mins = vector_origin
		trace.maxs = trace.mins

		local tr = util.TraceHull( trace )
		local ent = tr.Entity

		if IsValid(ent) then
			if not ent:IsPlayer() and not ent:IsNPC() then	
				if ACF_Check( ent ) then
					self.Weapon:SetNWFloat( "HP", ent.ACF.Health )
					self.Weapon:SetNWFloat( "Armour", ent.ACF.Armour )
					self.Weapon:SetNWFloat( "MaxHP", ent.ACF.MaxHealth )
					self.Weapon:SetNWFloat( "MaxArmour", ent.ACF.MaxArmour )
				end
			end
		end
		
		self:NextThink(CurTime() + 0.2)
	
	end
	
end

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.05 )

	local userid = self.Owner
	local userid = self.Owner

	local trace = {}
	trace.start 	= userid:GetShootPos()
	trace.endpos 	= userid:GetShootPos() + ( userid:GetAimVector() * 128	)
	trace.filter 	= userid --Not hitting the owner's feet when aiming down
	trace.mins 		= vector_origin
	trace.maxs 		= trace.mins
	local tr = util.TraceHull( trace )

	if ( tr.HitWorld ) then return end	
	if CLIENT then return end

	local ent = tr.Entity

	if ent:IsValid() and ent:GetClass() ~= 'ace_debris' then

		if ent:IsPlayer() || ent:IsNPC() then

			local PlayerHealth 		= ent:Health() --get the health
			local PlayerMaxHealth 	= ent:GetMaxHealth()--and max health too
			local PlayerArmour 		= ent:IsPlayer() and ent:Armor() or 0
			local PlayerMaxArmour 	= 100

			if ( PlayerHealth >= PlayerMaxHealth ) then return end --if the player is healthy or somehow dead, move right along.

			PlayerHealth = PlayerHealth + 3 --otherwise add 1 HP
			ent:SetHealth( PlayerHealth ) --and boost the player's HP to that.
			
			self.Weapon:SetNWFloat( "HP", PlayerHealth ) --Output to the HUD bar
			self.Weapon:SetNWFloat( "Armour", PlayerArmour )
			self.Weapon:SetNWFloat( "MaxHP", PlayerMaxHealth )
			self.Weapon:SetNWFloat( "MaxArmour", PlayerMaxArmour )
			
			local AngPos = userid:GetAttachment( 4 )
			local effect = EffectData()--then make some pretty effects :D ("Fixed that up a bit so it looks like it's actually emanating from the healing player, well mostly" Kaf)
			effect:SetOrigin( AngPos.Pos + userid:GetAimVector() * 10 )
			effect:SetNormal( userid:GetAimVector() )
			effect:SetEntity( self.Weapon )
			util.Effect( "thruster_ring", effect, true, true ) --("The 2 booleans control clientside override, by default it doesn't display it since it'll lag a bit behind inputs in MP, same for sounds" Kaf)
			
			ent:EmitSound( "items/medshot4.wav", true, true )--and play a sound.
		else

			if CPPI and not ent:CPPICanTool( self.Owner, "torch" ) then return false end

			local Valid = ACF_Check ( ent )

			if ( Valid and ent.ACF.Health < ent.ACF.MaxHealth ) then

				ent.ACF.Health = math.min(ent.ACF.Health + (600/ent.ACF.MaxArmour),ent.ACF.MaxHealth)
				ent.ACF.Armour = math.min(ent.ACF.MaxArmour * (ent.ACF.Health/ent.ACF.MaxHealth),ent.ACF.MaxArmour)
				ent:EmitSound( "ambient/energy/NewSpark0" ..tostring( math.random( 3, 5 ) ).. ".wav", 75, 100, 1, CHAN_WEAPON )
				TeslaSpark(tr.HitPos , 1 )

				ACF_UpdateVisualHealth(ent)
			end

			self.Weapon:SetNWFloat( "HP", ent.ACF.Health )
			self.Weapon:SetNWFloat( "Armour", ent.ACF.Armour )
			self.Weapon:SetNWFloat( "MaxHP", ent.ACF.MaxHealth )
			self.Weapon:SetNWFloat( "MaxArmour", ent.ACF.MaxArmour )
		end
	else 

		self.Weapon:SetNWFloat( "HP", 0 )
		self.Weapon:SetNWFloat( "Armour", 0 )
		self.Weapon:SetNWFloat( "MaxHP", 0 )
		self.Weapon:SetNWFloat( "MaxArmour", 0 )
	end

end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.05 )

	local userid = self.Owner
	local userid = self.Owner
	local trace = {}

	trace.start 	= userid:GetShootPos()
	trace.endpos 	= userid:GetShootPos() + ( userid:GetAimVector() * 128	)
	trace.filter 	= userid
	trace.mins 		= vector_origin
	trace.maxs 		= trace.mins

	local tr = util.TraceHull( trace )

	if ( tr.HitWorld ) then return end	
	if CLIENT then return end

	local ent = tr.Entity

	if not IsValid(ent) then return end

	if ACF_Check ( ent ) then

		self.Weapon:SetNWFloat( "HP", ent.ACF.Health )
		self.Weapon:SetNWFloat( "Armour", ent.ACF.Armour )
		self.Weapon:SetNWFloat( "MaxHP", ent.ACF.MaxHealth )
		self.Weapon:SetNWFloat( "MaxArmour", ent.ACF.MaxArmour )

		local HitRes = {}
		local Energy = {}

		if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then

			Energy = { Kinetic = 0.2,Momentum = 0,Penetration = 0.2 }
			HitRes = ACF_Damage ( ent, Energy, 2, 0, self.Owner, _, self, "Torch" )
		else

			if CPPI and not ent:CPPICanTool( self.Owner, "torch" ) then return false end
				
			Energy = { Kinetic = 500, Momentum = 0, Penetration = 500 }
			HitRes = ACF_Damage ( ent, Energy, 2, 0, self.Owner, _, self, "Torch" )

		end

		if HitRes.Kill and not ent:IsPlayer() then

			ACF_APKill( ent, VectorRand() , 0)
			ent:EmitSound( "ambient/energy/NewSpark0" ..tostring( math.random( 3, 5 ) ).. ".wav", 75, 100, 1, CHAN_AUTO ) 
		else
			local effectdata = EffectData()
			effectdata:SetMagnitude( 2.0 )
			effectdata:SetRadius( 1.0 )
			effectdata:SetScale( 1.0 )
			effectdata:SetStart( userid:GetShootPos() )
			effectdata:SetOrigin( tr.HitPos )

			util.Effect( "Sparks", effectdata , true , true )
			ent:EmitSound( "weapons/physcannon/superphys_small_zap" ..tostring( math.random( 1, 4 ) ).. ".wav", 75, 100, 1, CHAN_WEAPON )
		end
	else 
		self.Weapon:SetNWFloat( "HP", 0 )
		self.Weapon:SetNWFloat( "Armour", 0 )
		self.Weapon:SetNWFloat( "MaxHP", 0 )
		self.Weapon:SetNWFloat( "MaxArmour", 0 )
	end
end

function SWEP:Reload()

end

function TeslaSpark(pos, magnitude)
	zap = ents.Create("point_tesla")
	zap:SetKeyValue("targetname", "teslab")
	zap:SetKeyValue("m_SoundName" ,"null")
	zap:SetKeyValue("texture" ,"sprites/laser.spr")
	zap:SetKeyValue("m_Color" ,"200 200 255")
	zap:SetKeyValue("m_flRadius" ,tostring(magnitude*10))
	zap:SetKeyValue("beamcount_min" ,tostring(math.ceil(magnitude)))
	zap:SetKeyValue("beamcount_max", tostring(math.ceil(magnitude)))
	zap:SetKeyValue("thick_min", tostring(magnitude))
	zap:SetKeyValue("thick_max", tostring(magnitude))
	zap:SetKeyValue("lifetime_min" ,"0.05")
	zap:SetKeyValue("lifetime_max", "0.1")
	zap:SetKeyValue("interval_min", "0.05")
	zap:SetKeyValue("interval_max" ,"0.08")
	zap:SetPos(pos)
	zap:Spawn()
	zap:Fire("DoSpark","",0)
	zap:Fire("kill","", 0.1)
end


