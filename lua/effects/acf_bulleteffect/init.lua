
function EFFECT:Init( data )

	self.Index = data:GetMaterialIndex()
	--print(self.Index)
	if not self.Index then
		self.Alive = false
		self:Remove()
		return
	end
	self.CreateTime = ACF.CurTime

	local Hit = data:GetScale()
	local Bullet = ACF.BulletEffect[self.Index]

	--Scale encodes the hit type, so if it's 0 it's a new bullet, else it's an update so we need to remove the effect
	if (Hit > 0 and Bullet) then	

		--print("Updating Bullet Effect")
		Bullet.SimFlight = data:GetStart()*10		--Updating old effect with new values
		Bullet.SimPos = data:GetOrigin()

		--Bullet has reached end of flight, remove old effect
		if (Hit == 1) then		

			self.HitEnd = ACF.RoundTypes[Bullet.AmmoType]["endeffect"]
			self:HitEnd( Bullet )
			ACF.BulletEffect[self.Index] = nil			--This is crucial, to effectively remove the bullet flight model from the client

			if IsValid(Bullet.Tracer) then Bullet.Tracer:Finish() end

		--Bullet penetrated, don't remove old effect
		elseif (Hit == 2) then		

			self.HitPierce = ACF.RoundTypes[Bullet.AmmoType]["pierceeffect"]
			self:HitPierce( Bullet )

		--Bullet ricocheted, don't remove old effect
		elseif (Hit == 3) then		

			self.HitRicochet = ACF.RoundTypes[Bullet.AmmoType]["ricocheteffect"]
			self:HitRicochet( Bullet )

		end

		ACF_SimBulletFlight( Bullet, self.Index )
		self.Alive = false
		self:Remove()

	else
		--print("Creating Bullet Effect")
		local BulletData = {}
		BulletData.Crate = data:GetEntity()

		--TODO: Check if it is actually a crate
		if not IsValid(BulletData.Crate) then
			self.Alive = false
			self:Remove()
			return
		end

	

		BulletData.SimFlight = data:GetStart()*10
		BulletData.SimPos = data:GetOrigin()
		BulletData.SimPosLast = BulletData.SimPos
		BulletData.Caliber = BulletData.Crate:GetNWFloat( "Caliber", 10 )
		BulletData.RoundMass = BulletData.Crate:GetNWFloat( "ProjMass", 10 )
		BulletData.FillerMass = BulletData.Crate:GetNWFloat( "FillerMass" )
		BulletData.WPMass = BulletData.Crate:GetNWFloat( "WPMass" )
		BulletData.DragCoef = BulletData.Crate:GetNWFloat( "DragCoef", 1 )
		BulletData.AmmoType = BulletData.Crate:GetNWString( "AmmoType", "AP" )

		BulletData.BulletModel = BulletData.Crate:GetNWString( "BulletModel", "models/munitions/round_100mm_shot.mdl" ) 

		if BulletData.Crate:GetNWFloat( "Tracer" ) > 0 then
			BulletData.Counter = 0	
			BulletData.Tracer = ParticleEmitter( BulletData.SimPos )
			BulletData.TracerColour = BulletData.Crate:GetNWVector( "TracerColour", BulletData.Crate:GetColor() ) or Vector(255,255,255)
		end


		BulletData.Accel = BulletData.Crate:GetNWVector( "Accel", Vector(0,0,-600))

		BulletData.LastThink = CurTime() --ACF.CurTime
		BulletData.Effect = self.Entity
		BulletData.CrackCreated = false
		BulletData.InitialPos = BulletData.SimPos --Store the first pos, se we can limit the crack sound at certain distance


		--Add all that data to the bullet table, overwriting if needed
		ACF.BulletEffect[self.Index] = BulletData		

		--Moving the effect to the calculated position
		self:SetPos( BulletData.SimPos )									
		self:SetAngles( BulletData.SimFlight:Angle() )
		self:SetModel( BulletData.BulletModel )
		self.Alive = true

		ACF_SimBulletFlight( ACF.BulletEffect[self.Index], self.Index )

	end

end

function EFFECT:HitEnd()
	--You overwrite this with your own function, defined in the ammo definition file
	ACF.BulletEffect[self.Index] = nil			--Failsafe
end

function EFFECT:HitPierce()
	--You overwrite this with your own function, defined in the ammo definition file
	ACF.BulletEffect[self.Index] = nil			--Failsafe
end

function EFFECT:HitRicochet()
	--You overwrite this with your own function, defined in the ammo definition file
	ACF.BulletEffect[self.Index] = nil			--Failsafe
end

function EFFECT:Think()

	local Bullet = ACF.BulletEffect[self.Index]

	if self.Alive and Bullet and self.CreateTime > ACF.CurTime-30 then

		--We require this so the tracer is not spawned in middle of the gun (when initially fired)
		if Bullet.Tracer and IsValid(Bullet.Tracer) and Bullet.Counter < 3 then Bullet.Counter = Bullet.Counter + 1 end
		
		return true
	end

	--if the bullet will be not stand in the map, less its tracer
	if Bullet and IsValid(Bullet.Tracer) then Bullet.Tracer:Finish() end
	return false
end

function EFFECT:ApplyMovement( Bullet )

	local setPos = Bullet.SimPos
	if((math.abs(setPos.x) > 16380) or (math.abs(setPos.y) > 16380) or (setPos.z < -16380)) then
		self.Alive = false

		return
	end
	if( setPos.z < 16380 ) then
		self:SetPos( setPos )--Moving the effect to the calculated position
		self:SetAngles( Bullet.SimFlight:Angle() )

		local Speed = math.abs((Bullet.SimPos - Bullet.SimPosLast):Length()) 

		--sonic crack sound
		if not Bullet.CrackCreated then
			if ACE_SInDistance( Bullet.SimPos, math.max(Bullet.Caliber*100*ACE.CrackDistanceMultipler,250) ) and not ACE_SInDistance( Bullet.InitialPos, 750 ) then
				if Speed > 100 then --Note: when the client has lag, this could throw higher velocities even if bullet is slower
					--print(Bullet.Caliber*10*ACE.CrackDistanceMultipler)
					--print('Bullet Speed: '..Speed)
					ACE_SBulletCrack(Bullet, Bullet.Caliber) 
				end
			end
		end
	end

	if Bullet.Tracer and IsValid(Bullet.Tracer) then
		
		local value = 2.5

		if Bullet.Counter <= 1 then value = 1.85 end

		local DeltaTime = ACF.CurTime - Bullet.LastThink
		local DeltaPos = Bullet.SimPos - Bullet.SimPosLast
		local Length =  math.min(-DeltaPos:Length()*value,-1)

		local MaxSprites = 2

		local Light = Bullet.Tracer:Add( "sprites/acf_tracer.vmt", setPos + Bullet.SimFlight*0.01 )

		--debugoverlay.Cross(setPos,3,1,Color(255,255,255,10), true)

		if (Light) then
			Light:SetAngles( Bullet.SimFlight:Angle() )
			Light:SetVelocity( Bullet.SimFlight:GetNormalized() )
			Light:SetColor( Bullet.TracerColour.x, Bullet.TracerColour.y, Bullet.TracerColour.z )
			Light:SetDieTime( math.Clamp(ACF.CurTime-self.CreateTime,0.1,0.2) ) -- 0.075, 0.1
			Light:SetStartAlpha( 180 )
			Light:SetEndAlpha( 0 )
			Light:SetStartSize( 30*Bullet.Caliber ) -- 5
			Light:SetEndSize( 1*Bullet.Caliber ) --15*Bullet.Caliber
			Light:SetStartLength( Length )
			Light:SetEndLength( 1 ) --Length
		end
		
		if MaxSprites > 0 then

			for i=1, MaxSprites do
				local Smoke = Bullet.Tracer:Add( "particle/smokesprites_000"..math.random(1,9), setPos - (DeltaPos*i/MaxSprites) )
				if (Smoke) then
					Smoke:SetAngles( Bullet.SimFlight:Angle() )
					Smoke:SetVelocity( Bullet.SimFlight*0.05 )
					Smoke:SetColor( 200 , 200 , 200 )
					Smoke:SetDieTime( 0.6 ) -- 1.2
					Smoke:SetStartAlpha( 10 )
					Smoke:SetEndAlpha( 0 )
					Smoke:SetStartSize( 1 )
					Smoke:SetEndSize( Length/400*Bullet.Caliber )
					Smoke:SetRollDelta( 0.1 )
					Smoke:SetAirResistance( 150 )
					Smoke:SetGravity( Vector(0,0,20) )

				end
			end
		end
	end
end

function EFFECT:Render()

	local Bullet = ACF.BulletEffect[self.Index]

	if (Bullet) then
		self.Entity:SetModelScale( Bullet.Caliber/10 , 0 )
		self.Entity:DrawModel()       // Draw the model.
	end

end
