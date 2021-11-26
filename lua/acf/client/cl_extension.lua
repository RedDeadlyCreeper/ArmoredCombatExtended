--Featuring functions which manage the current built in ace sound extension system
--TODO: Refactor all this, making ONE function for every sound event. Using tables here fit better than this

--NOTE: i would like to have a way of having realtime volume/pitch depending if approaching/going away, 
--as having a way to switch sounds between indoor & outdoor zones. They will sound fine, issue it would be when you pass from an area to another when the sound is being played

--NOTE: For proper doppler effect where pitch/volume is dynamically changed, we need something like soundcreate() instead of ply:emitsound. 
--Downside of this, that due to gmod limits, one scripted sound per entity can be used at once. Which idk if it would be good for us. 
--We'll have more than one dynamic sound at once :/ weird

ACE = ACE or {}

ACE.Sounds = {}

--Entities which should be the only thing to block the sight
ACE.Sounds.LOSWhitelist = {
	prop_dynamic = true,
	prop_physics = true
}

--Defines the delay time caused by the distance between the event and you. Increasing it will increment the required time to hear a distant event
ACE.DelayMultipler = 1

--Defines the distance range for close, mid and far sounds. Incrementing it will increase the distances between sounds
ACE.DistanceMultipler = 1

--Defines the distance range which sonic cracks will be heard by the player
ACE.CrackDistanceMultipler = 1

--Defines the distance where ring ears start to affect to player
ACE.TinnitusZoneMultipler = 1

--Gets the player's point of view if he's using a camera
function ACE_SGetPOV( ply )
	if not IsValid(ply) then return false, ply end
	local ent

	if ply:GetViewEntity() ~= ply then --print('player using another POV (Gmod based Camera)')
		ent = ply:GetViewEntity()	
	end

	return ent
end

--Used for those extremely quiet sounds, which should be heard close to the player
function ACE_SInDistance( Pos, Mdist )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local entply = ply
	if IsValid(ACE_SGetPOV( ply )) then entply = ACE_SGetPOV( ply ) end

	local plyPos = entply:GetPos()

	local Dist = math.abs((plyPos - Pos):Length())

	--return true if the distance is lower than the maximum distance
	if Dist <= Mdist then return true end
	return false

end

--Used to see if the player has line of sight with the event
function ACE_SHasLOS( EventPos )

	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local plyPos = ply:GetPos()
	local headPos = plyPos + ( !ply:InVehicle() and ( ( ply:Crouching() and Vector(0,0,28) ) or Vector(0,0,64) ) or Vector(0,0,0) ) 

	local LOSTr = {}
	LOSTr.start = EventPos + Vector(0,0,10)
	LOSTr.endpos = headPos
	LOSTr.filter = function( ent ) if ( ACE.Sounds.LOSWhitelist[ent:GetClass()] ) then return true end end --Only hits the whitelisted ents
	local LOS = util.TraceLine(LOSTr)

	debugoverlay.Line(EventPos, LOS.HitPos , 5, Color(0,255,255))

	if not LOS.Hit then return true end
	return false
end

function ACE_SIsInDoor()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local entply = ply
	if IsValid(ACE_SGetPOV( ply )) then entply = ACE_SGetPOV( ply ) end

	local plyPos = entply:GetPos()

	local CeilTr = {}
	CeilTr.start = plyPos
	CeilTr.endpos = plyPos + Vector(0,0,2000)
	CeilTr.filter = {}
	CeilTr.mask = MASK_SOLID_BRUSHONLY
	local Ceil = util.TraceLine(CeilTr)

	if Ceil.Hit and Ceil.HitWorld then return true end
	return false
end

--Handles Explosion sounds
function ACEE_SBlast( HitPos, Radius, HitWater, HitWorld )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local entply = ply
	if IsValid(ACE_SGetPOV( ply )) then entply = ACE_SGetPOV( ply ) end

	local count = 1
	local countToFinish = nil
	local Emitted = false --Was the sound played?
	local ide = 'ACEBoom#'..math.random(1,100000)

	--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
	if timer.Exists( ide ) then return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = entply:GetPos() --print(plyPos)
		local Dist = math.abs((plyPos - HitPos):Length()) --print('distance from explosion: '..Dist)
		local Volume = ( 1/(Dist/500)*Radius*0.2 ) --print('Vol: '..Volume)
		local Pitch =  math.Clamp(1000/Radius,25,130) --print('pitch: '..Pitch)
		local Delay = ( Dist/1500 ) * ACE.DelayMultipler --print('amount to match: '..Delay)
		
		if count > Delay then

			--done so we keep calculating for post-explosion effects (doppler, volume, etc)
			if not countToFinish then countToFinish = count*3 end

			--if its not already emitted
			if not Emitted then

				Emitted = true --print('timer has emitted the sound in the time: '..count)

				--Ground explosions
				if not HitWater then

					--the sound definition. Strings are below
					local Sound

					--This defines the distance between areas for close, mid and far sounds
					local CloseDist = Radius * 275 * ACE.DistanceMultipler

					--Medium dist will be 4.25x times of closedist. So if closedist is 1000 units, then medium dist will be until 4250 units
					local MediumDist = CloseDist*4.25 

					--this variable fixes the vol for a better volume scale. It's possible to change it depending of the sound area below
					local VolFix
					local PitchFix

					--Required radius to be considered a small explosion. Less than this the explosion will be considered tiny
					local SmallEx = 5 

					--Required radius to be considered a medium explosion
					local MediumEx = 10

					--Required radius to be considered a large explosion
					local LargeEx = 20

					--Required radius to be considered a huge explosion. IDK what thing could pass this, but there is it :)
					local HugeEx = 150

					--TODO: Make a way to use tables instead
					--Close distance
					if Dist < CloseDist then --print('you are close')

						VolFix = 8
						PitchFix = 1
						Sound = "acf_other/explosions/ambient/tiny/close/close"..math.random(1,4)..".wav"

						if Radius >= SmallEx then
							VolFix = 8
							PitchFix = 1
							Sound = "acf_other/explosions/ambient/small/close/close"..math.random(1,4)..".wav"

							if Radius >= MediumEx then
								VolFix = 8
								PitchFix = 1
								Sound = "acf_other/explosions/ambient/medium/close/close"..math.random(1,4)..".wav"

								if Radius >= LargeEx then
									VolFix = 8
									PitchFix = 1
									Sound = "acf_other/explosions/ambient/large/close/close"..math.random(1,4)..".wav"

									if Radius >= HugeEx then
										VolFix = 2000000  -- rip your ears
										PitchFix = 3
										Sound = "acf_other/explosions/ambient/huge/bigboom.wav"
									end
								end
							end
						end

					--Medium distance
					elseif Dist >= CloseDist and Dist < MediumDist then --print('you are mid')

						VolFix = 8
						PitchFix = 1
						Sound = "acf_other/explosions/ambient/tiny/mid/mid"..math.random(1,4)..".wav"

						if Radius >= SmallEx then
							VolFix = 8
							PitchFix = 1
							Sound = "acf_other/explosions/ambient/small/mid/mid"..math.random(1,4)..".wav"

							if Radius >= MediumEx then
								VolFix = 8
								PitchFix = 1
								Sound = "acf_other/explosions/ambient/medium/mid/mid"..math.random(1,3)..".wav"

								if Radius >= LargeEx then
									VolFix = 8
									PitchFix = 1
									Sound = "acf_other/explosions/ambient/large/mid/mid"..math.random(1,4)..".wav"

								end
							end
						end

					--Far distance				
					elseif Dist >= MediumDist then --print('you are far')

						VolFix = 17
						PitchFix = 1
						Sound = "acf_other/explosions/ambient/tiny/far/far"..math.random(1,4)..".wav"

						if Radius >= SmallEx then
							VolFix = 17
							PitchFix = 1
							Sound = "acf_other/explosions/ambient/small/far/far"..math.random(1,4)..".wav"

							if Radius >= MediumEx then
								VolFix = 17
								PitchFix = 1
								Sound = "acf_other/explosions/ambient/medium/far/far"..math.random(1,3)..".wav"

								if Radius >= LargeEx then
									VolFix = 17
									PitchFix = 1
									Sound = "acf_other/explosions/ambient/large/far/far"..math.random(1,3)..".wav"

								end
							end
						end

					end

					--Tinnitus function
					local TinZone = math.max(Radius*80,50)*ACE.TinnitusZoneMultipler
					if Dist <= TinZone and ACE_SHasLOS( HitPos ) and entply == ply then
						timer.Simple(0.01, function()
							entply:SetDSP( 32, true )
							entply:EmitSound( "acf_other/explosions/ring/tinnitus.wav", 75, 100, 1 )		
						end)

					end

					--If a wall is in front of the player and is indoor, reduces its vol
					if not ACE_SHasLOS( HitPos ) and ACE_SIsInDoor() then
						--print('Inside of building')
						VolFix = VolFix*0.05
					end

					debugoverlay.Sphere(HitPos, TinZone, 15, Color(0,0,255,32), 1)

					entply:EmitSound( Sound, 75, Pitch * PitchFix, Volume * VolFix )

					--play dirt sounds
					if Radius >= SmallEx and HitWorld then
						sound.Play("acf_other/explosions/debris/grass/debris"..math.Round(math.random(1,4))..".wav", plyPos, 90, (Pitch * PitchFix), Volume * VolFix / 25)
						sound.Play("acf_other/explosions/debris/concrete/debris"..math.Round(math.random(1,6))..".wav", plyPos, 90, (Pitch * PitchFix) / 0.5, Volume * VolFix / 25)
					end

					--Underwater Explosions
				else
					entply:EmitSound( "ambient/water/water_splash"..math.random(1,3)..".wav", 75, Pitch * 0.75, Volume * 0.25)
					entply:EmitSound( "^weapons/underwater_explode3.wav", 75, Pitch * 0.75, Volume * 0.25)
				end
			end

			--its time has ended
			if count > countToFinish then --print('timer "'..ide..'"" has been repeated '..count..' times. stopping & removing it...')
				timer.Stop( ide )
				timer.Remove( ide )
			end
		end
	end )

end

--Handles penetration sounds
function ACE_SPen( HitPos, Velocity, Mass )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local entply = ply
	if IsValid(ACE_SGetPOV( ply )) then entply = ACE_SGetPOV( ply ) end

	local count = 1
	local Emitted = false --Was the sound played?
	local ide = 'ACEPen#'..math.random(1,100000) 	--print('timer created! ID: '..ide)

	--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
	if timer.Exists( ide ) then return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = entply:GetPos() --print(plyPos)
		local Dist = math.abs((plyPos - HitPos):Length()) --print('distance from explosion: '..Dist)
		local Volume = ( 1/(Dist/500)*Mass/17.5 ) --print('Vol: '..Volume)
		local Pitch =  math.Clamp(Velocity*1,90,150)
		local Delay = ( Dist/1500 ) * ACE.DelayMultipler --print('amount to match: '..Delay)

		if count > Delay then

			if not Emitted then --print('timer has emitted the sound in the time: '..count)

				Emitted = true

				local Sound = "acf_other/penetratingshots/pen"..math.random(1,6)..".wav"
				local VolFix = 0.5

				--If a wall is in front of the player and is indoor, reduces its vol at 50%
				if not ACE_SHasLOS( HitPos ) and ACE_SIsInDoor() then
					--print('Inside of building')
					VolFix = VolFix*0.5
				end

				entply:EmitSound( Sound, 75, Pitch, Volume * VolFix)

			end

			timer.Stop( ide )
			timer.Remove( ide )	
		end
	end )
end

--Handles ricochet sounds
function ACEE_SRico( HitPos, Caliber, Velocity, HitWorld )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local entply = ply
	if IsValid(ACE_SGetPOV( ply )) then entply = ACE_SGetPOV( ply ) end

	local count = 1
	local Emitted = false --Was the sound played?

	local ide = 'ACERico#'..math.random(1,100000)
	--print('timer created! ID: '..ide)

	--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
	if timer.Exists( ide ) then return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = entply:GetPos() --print(plyPos)
		local Dist = math.abs((plyPos - HitPos):Length()) --print('distance from explosion: '..Dist)
		local Volume = ( 1/(Dist/500)*Velocity/130000 ) --print('Vol: '..Volume)
		local Pitch =  math.Clamp(Velocity*0.001,90,150) --print('pitch: '..Pitch)
		local Delay = ( Dist/1500 ) * ACE.DelayMultipler --print('amount to match: '..Delay)

		if count > Delay then

			if not Emitted then --print('timer has emitted the sound in the time: '..count)

				Emitted = true

				local Sound = ""
				local VolFix = 0

				if not HitWorld then

					--any big gun above 50mm
					Sound =  "acf_other/ricochets/props/large/close/richo"..math.random(1,7)..".wav"
					VolFix = 4

					--50mm guns and below
					if Caliber <= 5 then
						Sound = "acf_other/ricochets/props/medium/richo"..math.random(1,6)..".wav"
						VolFix = 1

						--lower than 20mm
						if Caliber <= 2 then
							Sound = "acf_other/ricochets/props/small/richo"..math.random(1,2)..".wav"
							VolFix = 1.25
						end
					end

				else
					--Small weapons sound
					if Caliber <=2 then
						Sound = "acf_other/ricochets/props/small/richo"..math.random(1,2)..".wav"
						VolFix = 1.25
	
					end
				end

				--If a wall is in front of the player and is indoor, reduces its vol at 50%
				if not ACE_SHasLOS( HitPos ) and ACE_SIsInDoor() then
					--print('Inside of building')
					VolFix = VolFix*0.5
				end

				if Sound ~= "" then
					entply:EmitSound( Sound , 75, Pitch, Volume * VolFix )
				end
			end

			timer.Stop( ide )
			timer.Remove( ide )	
		end
	end )
end

--Time to think about how to put 3049230 sounds into this. SHIT
function ACE_SGunFire( Pos, Sound ,Class, Caliber, Propellant )

	Propellant = math.max(Propellant,50)
	--print(Propellant)

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local entply = ply
	if IsValid(ACE_SGetPOV( ply )) then entply = ACE_SGetPOV( ply ) end

	local count = 1
	local Emitted = false --Was the sound played?
	local ide = 'ACEFire#'..math.random(1,100000) 	--print('timer created! ID: '..ide)

	--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
	if timer.Exists( ide ) then return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = entply:GetPos() --print(plyPos)
		local Dist = math.abs((plyPos - Pos):Length()) --print('distance from gun: '..Dist)
		local Volume = ( 1/(Dist/500)*Propellant/18 ) --print('Vol: '..Volume)
		local Delay = ( Dist/1500 ) * ACE.DelayMultipler --print('amount to match: '..Delay)

		if count > Delay then

			if not Emitted then --print('timer has emitted the sound in the time: '..count)

				Emitted = true
				local RSound = Sound

				--This defines the distance between areas for close, mid and far sounds
				local CloseDist = Propellant * 40 * ACE.DistanceMultipler --print('Propellant: '..Propellant) print('CloseDist: '..CloseDist)

				--Medium dist will be 4.25x times of closedist. So if closedist is 1000 units, then medium dist will be until 4250 units
				local MediumDist = CloseDist*4.25 --print('MidDist: '..MediumDist)

				local FarDist = MediumDist*2 --print('FarDist: '..FarDist)

				--this variable fixes the vol for a better volume scale. It's possible to change it depending of the sound area below
				local VolFix = 1

				-- The reason of why this requires tables. I can polish this later
				if Dist >= CloseDist and Dist < MediumDist then --print('Mid') print(Class)

					Sound = "acf_other/gunfire/cannon/small/mid/mid"..math.random(1,4)..".wav"
					VolFix = 100

					if Class == 'MG' then
						Sound = "acf_other/gunfire/machinegun/mid/mid"..math.random(1,4)..".wav"
						VolFix = 1.5
					elseif Class == 'HMG' then
						Sound = "acf_other/gunfire/heavymachinegun/mid/mid"..math.random(1,4)..".wav"
						VolFix = 1.75
					elseif Class == 'RAC' then
						Sound = "acf_other/gunfire/rotaryautocannon/mid/mid"..math.random(1,3)..".wav"
						VolFix = 1					
					elseif Class == 'AC' then
						Sound = "acf_other/gunfire/cannon/small/mid/mid"..math.random(1,4)..".wav"--"acf_other/gunfire/autocannon/mid/mid"..math.random(1,8)..".wav"
						VolFix = 1					
					elseif Class == 'C' or Class == 'HW' or Class == 'ATR' then

						Sound = "acf_other/gunfire/heavymachinegun/mid/mid"..math.random(1,4)..".wav"
						VolFix = 1.75

						if Caliber >= 21 then
							Sound = "acf_other/gunfire/cannon/small/mid/mid"..math.random(1,4)..".wav"
							VolFix = 100
						elseif Caliber >= 75 then
							Sound = "acf_other/gunfire/cannon/medium/mid/mid"..math.random(1,4)..".wav"
							VolFix = 100
						elseif Caliber >= 100 then
							Sound = "acf_other/gunfire/cannon/large/mid/mid"..math.random(1,4)..".wav"
							VolFix = 100
						end	
					elseif Class == 'GL' then
						VolFix = 0.5				
					elseif Class == 'FGL' or Class == 'SM' then
						Sound = RSound
						VolFix = 0.5
					end
				elseif Dist >= MediumDist then print('Far')

					Sound = "acf_other/gunfire/cannon/small/far/far"..math.random(1,4)..".wav"
					VolFix = 100

					if Class == 'MG' then
						Sound = "acf_other/gunfire/machinegun/far/far"..math.random(1,4)..".wav"
						VolFix = 1.5
					elseif Class == 'HMG' then
						Sound = "acf_other/gunfire/heavymachinegun/far/far"..math.random(1,4)..".wav"
						VolFix = 2
					elseif Class == 'RAC' then
						Sound = "acf_other/gunfire/rotaryautocannon/mid/mid"..math.random(1,3)..".wav"
						VolFix = 1.25					
					elseif Class == 'AC' then
						Sound = "acf_other/gunfire/cannon/small/far/far"..math.random(1,4)..".wav"--"acf_other/gunfire/autocannon/mid/mid"..math.random(1,8)..".wav"
						VolFix = 1						
					elseif Class == 'C' or Class == 'HW' or Class == 'ATR' then

						Sound = "acf_other/gunfire/heavymachinegun/far/far"..math.random(1,4)..".wav"
						VolFix = 1.75

						if Caliber >= 21 then
							Sound = "acf_other/gunfire/cannon/small/far/far"..math.random(1,4)..".wav"
							VolFix = 100
						elseif Caliber >= 75 then
							Sound = "acf_other/gunfire/cannon/medium/far/far"..math.random(1,4)..".wav"
							VolFix = 100
						elseif Caliber >= 120 then
							Sound = "acf_other/gunfire/cannon/large/far/far"..math.random(1,4)..".wav"
							VolFix = 100
						end
					elseif Class == 'GL' then
						VolFix = 0.5
					elseif Class == 'FGL' or Class == 'SM' then
						Sound = RSound
						VolFix = 0.1
					end
				end

				--If a wall is in front of the player and is indoor, reduces its vol at 50%
				if not ACE_SHasLOS( Pos ) and ACE_SIsInDoor() then
					--print('Inside of building')
					VolFix = VolFix*0.5
				end

				sound.Play(Sound, plyPos, 90, 100, Volume * VolFix) --print('final vol: '..Volume * VolFix) 

			end

			timer.Stop( ide )
			timer.Remove( ide )	
		end
	end )
end

--TODO: Leave 5 sounds per caliber type. 22 7.26mm sounds go brrrr
function ACE_SBulletCrack( BulletData, Caliber )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local entply = ply
	if IsValid(ACE_SGetPOV( ply )) then entply = ACE_SGetPOV( ply ) end

	--flag this, so we are not playing this sound for this bullet next time
	BulletData.CrackCreated = true

	debugoverlay.Cross(BulletData.SimPos, 10, 5, Color(0,0,255))

	local count = 1
	local Emitted = false --Was the sound played?

	local ide = 'ACECrack#'..math.random(1,100000)
	--print('timer created! ID: '..ide)

	if timer.Exists( ide ) then return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = entply:GetPos() --print(plyPos)

		--Delayed event report.
		local CrackPos = BulletData.SimPos - BulletData.SimFlight:GetNormalized()*5000
		local Dist = math.abs((plyPos - CrackPos):Length()) --print('distance from bullet: '..Dist)
		local Volume = ( 10000/Dist) --print('Vol: '..Volume)
		local Delay = ( Dist/1500 ) * ACE.DelayMultipler --print('amount to match: '..Delay)

		if count > Delay then
			if not Emitted then
				Emitted = true

				local VolFix = 1

				--Small arm guns
				local Sound = "acf_other/fly/small/fly"..math.random(1,22)..".wav"

				--30mm gun and above
				if Caliber >= 3 then
					Sound = "acf_other/fly/medium/fly"..math.random(1,10)..".wav"

					--above 100mm cannons
					if Caliber >= 10 then
						Sound = "acf_other/fly/large/fly"..math.random(1,5)..".wav"

						--Some fly sounds don´t fit really well. Special case here.
						if Caliber >= 20 then
							Sound = "acf_other/fly/large/fly"..math.random(1,3)..".wav"
							VolFix = 0.75
						end
					end
				end

				--If a wall is in front of the player and is indoor, reduces its vol
				if not ACE_SHasLOS( CrackPos ) and ACE_SIsInDoor() then
					--print('Inside of building')
					VolFix = VolFix*0.025
				end

				entply:EmitSound( Sound , 75, 100, Volume * VolFix )

			end
			timer.Stop( ide )
			timer.Remove( ide )	
		end
	end )
end

--Coming soon
--function ACE_SBulletImpact()
--end