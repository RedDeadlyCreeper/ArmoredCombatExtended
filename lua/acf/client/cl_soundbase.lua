
--Featuring functions which manage the current built in ace sound extension system
--TODO: Refactor all this, making ONE function for every sound event. Using tables here fit better than this

--NOTE: i would like to have a way of having realtime volume/pitch depending if approaching/going away,
--as having a way to switch sounds between indoor & outdoor zones. They will sound fine, issue it would be when you pass from an area to another when the sound is being played

--NOTE: For proper doppler effect where pitch/volume is dynamically changed, we need something like soundcreate() instead of ply:emitsound.
--Downside of this, that due to gmod limits, one scripted sound per entity can be used at once. Which idk if it would be good for us.
--We'll have more than one dynamic sound at once :/ weird

ACE = ACE or {}

--Defines the delay time caused by the distance between the event and you. Increasing it will increment the required time to hear a distant event
ACE.DelayMultipler            = 1

--Defines the distance range for close, mid and far sounds. Incrementing it will increase the distances between sounds
ACE.DistanceMultipler         = 1

--Defines the distance range which sonic cracks will be heard by the player
ACE.CrackDistanceMultipler    = 1

--Defines the distance where ring ears start to affect to player
ACE.TinnitusZoneMultipler     = 1.5

----------- Sound Spectrum Config -----------

--Required radius to be considered a small explosion. Less than this the explosion will be considered tiny
ACE.SoundSmallEx	= 5

--Required radius to be considered a medium explosion
ACE.SoundMediumEx  = 10

--Required radius to be considered a large explosion
ACE.SoundLargeEx	= 20

--Required radius to be considered a huge explosion. IDK what thing could pass this, but there is it :)
ACE.SoundHugeEx	= 150


ACE.Sounds          = ACE.Sounds or {}
ACE.Sounds.GunTb    = {}

--Entities which should be the only thing to block the sight
ACE.Sounds.LOSWhitelist = {
	prop_dynamic = true,
	prop_physics = true
}

do

	-- Cache results so we don't need to do expensive filesystem checks every time
	local IsValidCache = {}

	-- Returns whether or not a sound actually exists, fixes client timeout issues
	function IsValidSound( path )
		if IsValidCache[path] == nil then
			IsValidCache[path] = file.Exists( string.format( "sound/%s", tostring( path ) ), "GAME" ) and true or false
		end
		return IsValidCache[path]
	end

	--Global sound function. In order to be modified by a convar config
	--If the Origin is an entity, uses entity:EmitSound( SoundTxt , SoundLevel, Pitch, Volume )
	--If the Origin is a vector Position, uses sound.Play(SoundTxt, Position, SoundLevel, Pitch, Volume)
	function ACE_EmitSound( SoundTxt, Origin, SoundLevel, Pitch, Volume )

		Volume = math.min( Volume, 1 )
		local VolumeConfig = GetConVar("acf_sound_volume"):GetInt() / 100

		if IsEntity(Origin) and IsValid(Origin) then
			Origin:EmitSound( SoundTxt, SoundLevel, Pitch, Volume * VolumeConfig )
		elseif isvector( Origin ) then
			sound.Play(SoundTxt, Origin, SoundLevel, Pitch, Volume * VolumeConfig )
		end
	end

	--Gets the player's point of view if he's using a camera. Returns the entity input if no external entity is involved.
	function ACE_SGetHearingEntity( ply )
		if not IsValid(ply) then return ply end

		------------------------------- Method 1: Via Camera tool -------------------------------
		if ply:GetViewEntity() ~= ply then
			return ply:GetViewEntity()
		end

		-------------------------- Method 2: Via Wire Cam Controller -----------------------------
		ACE.Sounds.HookTable = ACE.Sounds.HookTable or hook.GetTable()
		if ACE.Sounds.HookTable["CalcView"] then

			ply.aceposoverride	= nil
			-- wire cam controller support. I would wish not to have a really hardcoded way to make everything consistent but well...
			local CameraPos        = ACE.Sounds.HookTable["CalcView"]["wire_camera_controller_calcview"]
			local ThirdPersonPos   = CameraPos and CameraPos()

			if ThirdPersonPos and ThirdPersonPos.origin then
				ply.aceposoverride = ThirdPersonPos.origin
				return ply
			end
		end

		return ply
	end

	function ACE_GetDistanceTime( Dist )
		return (Dist / 1500) * ACE.DelayMultipler
	end

	local function GetHeadPos( ply )
		local plyPos	= ply.aceposoverride or ply:GetPos()
		local headPos	= plyPos + ( not ply:InVehicle() and ( ( ply:Crouching() and Vector(0,0,28) ) or Vector(0,0,64) ) or Vector(0,0,0) )
		return headPos
	end

	--Used for those extremely quiet sounds, which should be heard close to the player
	function ACE_SInDistance( Pos, Distance )

		local ply    = LocalPlayer()

		local entply = ACE_SGetHearingEntity( ply )
		local plyPos = entply:IsPlayer() and GetHeadPos( ply ) or entply:GetPos()

		--return true if the distance is lower than the maximum distance
		if ACE_InDist( plyPos, Pos, Distance ) then return true end

		return false
	end

	--Used to see if the player has line of sight with the event
	function ACE_SHasLOS( EventPos )

		local ply = LocalPlayer()
		local headPos = GetHeadPos( ply )

		local LOSTr	= {}
		LOSTr.start    = EventPos + Vector(0,0,10)
		LOSTr.endpos   = headPos
		LOSTr.filter   = function( ent ) if ACE.Sounds.LOSWhitelist[ent:GetClass()] then return true end end --Only hits the whitelisted ents
		local LOS	= util.TraceLine(LOSTr)

		if not LOS.Hit then return true end
		return false
	end

	function ACE_SIsInDoor()

		local ply    = LocalPlayer()
		local entply = ACE_SGetHearingEntity( ply )
		local plyPos = entply.aceposoverride or entply:GetPos()

		local CeilTr	= {}
		CeilTr.start	= plyPos
		CeilTr.endpos	= plyPos + Vector(0,0,2000)
		CeilTr.filter	= {}
		CeilTr.mask	= MASK_SOLID_BRUSHONLY
		local Ceil	= util.TraceLine(CeilTr)

		if Ceil.Hit and Ceil.HitWorld then return true end
		return false
	end

end

do

	--Handles Explosion sounds
	function ACE_SBlast( HitPos, Radius, HitWater, HitWorld )

		local ply = LocalPlayer()

		local count		= 1
		local Emitted	= false --Was the sound played?
		local ide		= "ACE_Explosion#" .. math.random(1,100000)

		--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
		if timer.Exists( ide ) then return end
		timer.Create( ide , 0.1, 0, function()

			count = count + 1

			local entply    = ACE_SGetHearingEntity( ply )

			local plyPos    = entply.aceposoverride or entply:GetPos()
			local Dist      = (plyPos - HitPos):Length()
			local Volume    = 1 / (Dist / 500) * Radius * 0.2
			local Pitch     = math.Clamp(1000 / Radius, 25, 130)
			local Delay     = ACE_GetDistanceTime( Dist )

			if count > Delay then

				--if its not already emitted
				if not Emitted then

					Emitted = true

					--Ground explosions
					if not HitWater then

						--the sound definition. Strings are below
						local Sound

						--This defines the distance between areas for close, mid and far sounds
						local CloseDist = Radius * 275 * ACE.DistanceMultipler

						--Medium dist will be 4.25x times of closedist. So if closedist is 1000 units, then medium dist will be 4250 units
						local MediumDist = CloseDist * 4.25

						--this variable fixes the vol for a better volume scale. It's possible to change it depending of the sound area below
						local VolFix
						local PitchFix

						--TODO: Make a way to use tables instead
						--Close distance
						if Dist < CloseDist then --NOTE: I KNOW ABOUT THIS CANCEROUS LONG NAME FOR THE STRING, JUST IGNORE FOR THIS TIME.

							if Radius >= ACE.SoundHugeEx then
								VolFix = 2000000  -- rip your ears
								PitchFix = 3
								Sound = ACE.Sounds["Blasts"]["huge"]["close"][math.random(1,#ACE.Sounds["Blasts"]["huge"]["close"])]
							elseif Radius >= ACE.SoundLargeEx then
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["large"]["close"][math.random(1,#ACE.Sounds["Blasts"]["large"]["close"])]
							elseif Radius >= ACE.SoundMediumEx then
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["medium"]["close"][math.random(1,#ACE.Sounds["Blasts"]["medium"]["close"])]
							elseif Radius >= ACE.SoundSmallEx then
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["small"]["close"][math.random(1,#ACE.Sounds["Blasts"]["small"]["close"])]
							else
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["tiny"]["close"][math.random(1,#ACE.Sounds["Blasts"]["tiny"]["close"])]
							end

						--Medium distance
						elseif Dist >= CloseDist and Dist < MediumDist then

							if Radius >= ACE.SoundLargeEx then
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["large"]["mid"][math.random(1,#ACE.Sounds["Blasts"]["large"]["mid"])]
							elseif Radius >= ACE.SoundMediumEx then
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["medium"]["mid"][math.random(1,#ACE.Sounds["Blasts"]["medium"]["mid"])]
							elseif Radius >= ACE.SoundSmallEx then
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["small"]["mid"][math.random(1,#ACE.Sounds["Blasts"]["small"]["mid"])]
							else
								VolFix = 8
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["tiny"]["mid"][math.random(1,#ACE.Sounds["Blasts"]["tiny"]["mid"])]
							end

						--Far distance
						elseif Dist >= MediumDist then

							if Radius >= ACE.SoundLargeEx then
								VolFix = 17
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["large"]["far"][math.random(1,#ACE.Sounds["Blasts"]["large"]["far"])]
							elseif Radius >= ACE.SoundMediumEx then
								VolFix = 17
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["medium"]["far"][math.random(1,#ACE.Sounds["Blasts"]["medium"]["far"])]
							elseif Radius >= ACE.SoundSmallEx then
								VolFix = 17
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["small"]["far"][math.random(1,#ACE.Sounds["Blasts"]["small"]["far"])]
							else
								VolFix = 17
								PitchFix = 1
								Sound = ACE.Sounds["Blasts"]["tiny"]["far"][math.random(1,#ACE.Sounds["Blasts"]["tiny"]["far"])]
							end

						end

						--Tinnitus function
						if not ply:HasGodMode() then
							local TinZone = math.max(Radius * 80, 50) * ACE.TinnitusZoneMultipler

							if Dist <= TinZone and ACE_SHasLOS(HitPos) and entply == ply and not ply.aceposoverride then

								entply:SetDSP(33, true)

								if GetConVar("acf_tinnitus"):GetInt() == 1 then

									--See if it supress the current tinnitus and creates a new one, from 0. Should stop the HE spam tinnitus
									entply:StopSound("acf_other/explosions/ring/tinnitus.mp3")
									ACE_EmitSound("acf_other/explosions/ring/tinnitus.mp3", entply, 75, 100, 1 )

								end
							end
							--debugoverlay.Sphere(HitPos, TinZone, 15, Color(0,0,255,32), 1)
						end

						--If a wall is in front of the player and is indoor, reduces its vol
						if not ACE_SHasLOS( HitPos ) and ACE_SIsInDoor() then
							--print("Inside of building")
							VolFix = VolFix * 0.05
						end

						ACE_EmitSound( Sound or "", entply, 75, Pitch * PitchFix, Volume * VolFix )

						--play dirt sounds
						if Radius >= ACE.SoundSmallEx and HitWorld then
							ACE_EmitSound( ACE.Sounds["Debris"]["low"]["close"][math.random(1,#ACE.Sounds["Debris"]["low"]["close"])] or "", plyPos + (HitPos - plyPos):GetNormalized() * 64, 80, Pitch * PitchFix, Volume * VolFix / 20 )
							ACE_EmitSound( ACE.Sounds["Debris"]["high"]["close"][math.random(1,#ACE.Sounds["Debris"]["high"]["close"])] or "", plyPos + (HitPos - plyPos):GetNormalized() * 64, 80, (Pitch * PitchFix) / 0.5, Volume * VolFix / 20 )
						end

						--Underwater Explosions
					else
						ACE_EmitSound( "ambient/water/water_splash" .. math.random(1,3) .. ".wav", entply, 75, math.max(Pitch * 0.75,65), Volume * 0.075 )
						ACE_EmitSound( "^weapons/underwater_explode3.wav", entply, 75, math.max(Pitch * 0.75,65), Volume * 0.075 )
					end
				end

				timer.Stop( ide )
				timer.Remove( ide )
			end
		end )

	end

	--Handles penetration sounds
	function ACE_SPenetration( HitPos, Velocity, Mass )

		--Don't start this without a player
		local ply = LocalPlayer()

		local count    = 1
		local Emitted  = false --Was the sound played?
		local ide      = "ACE_Penetration#" .. math.random(1,100000)

		--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
		if timer.Exists( ide ) then return end
		timer.Create( ide , 0.1, 0, function()

			count = count + 1

			local entply = ACE_SGetHearingEntity( ply )

			local plyPos    = entply.aceposoverride or entply:GetPos()
			local Dist      = (plyPos - HitPos):Length()
			local Volume    = 1 / (Dist / 500) * Mass / 17.5
			local Pitch     = math.Clamp(Velocity * 1, 90, 150)
			local Delay     = ACE_GetDistanceTime( Dist )

			if count > Delay then

				if not Emitted then

					Emitted = true

					local Sound = ACE.Sounds["Penetrations"]["large"]["close"][math.random(1,#ACE.Sounds["Penetrations"]["large"]["close"])] or ""
					local VolFix = 0.5

					--If a wall is in front of the player and is indoor, reduces its vol at 50%
					if not ACE_SHasLOS( HitPos ) and ACE_SIsInDoor() then
						--print("Inside of building")
						VolFix = VolFix * 0.5
					end

					ACE_EmitSound( Sound, entply, 75, Pitch, Volume * VolFix )
				end

				timer.Stop( ide )
				timer.Remove( ide )
			end
		end )
	end

	--Handles ricochet sounds
	function ACE_SRicochet( HitPos, Caliber, Velocity, HitWorld )

		local ply = LocalPlayer()

		local count	= 1
		local Emitted	= false --Was the sound played?

		local ide	= "ACE_Ricochet#" .. math.random(1,100000)

		--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
		if timer.Exists( ide ) then return end
		timer.Create( ide , 0.1, 0, function()

			count = count + 1

			local entply = ACE_SGetHearingEntity( ply )

			local plyPos    = entply.aceposoverride or entply:GetPos()
			local Dist      = (plyPos - HitPos):Length()
			local Volume    = 1 / (Dist / 500) * Velocity / 130000
			local Pitch     = math.Clamp(Velocity * 0.001, 90, 150)
			local Delay     = ACE_GetDistanceTime( Dist )

			if count > Delay then

				if not Emitted then --print('timer has emitted the sound in the time: ' .. count)

					Emitted = true

					local Sound = ""
					local VolFix = 0

					if not HitWorld then

						--any big gun above 50mm
						Sound =  ACE.Sounds["Ricochets"]["large"]["close"][math.random(1,#ACE.Sounds["Ricochets"]["large"]["close"])]
						VolFix = 4

						--50mm guns and below
						if Caliber <= 5 then
							Sound = ACE.Sounds["Ricochets"]["medium"]["close"][math.random(1,#ACE.Sounds["Ricochets"]["medium"]["close"])]
							VolFix = 1

							--lower than 20mm
							if Caliber <= 2 then
								Sound = ACE.Sounds["Ricochets"]["small"]["close"][math.random(1,#ACE.Sounds["Ricochets"]["small"]["close"])]
								VolFix = 1.25
							end
						end

					else

						--Small weapons sound
						if Caliber <= 2 then
							Sound = ACE.Sounds["Ricochets"]["small"]["close"][math.random(1,#ACE.Sounds["Ricochets"]["small"]["close"])]
							VolFix = 1.25

						end
					end

					--If a wall is in front of the player and is indoor, reduces its vol at 50%
					if not ACE_SHasLOS( HitPos ) and ACE_SIsInDoor() then
						--print("Inside of building")
						VolFix = VolFix * 0.5
					end

					if Sound ~= "" then
						ACE_EmitSound( Sound or "", entply, 75, Pitch, Volume * VolFix )
					end
				end

				timer.Stop( ide )
				timer.Remove( ide )
			end
		end )
	end

	function ACE_SGunFire( Gun, Sound, PitchOverride, Propellant )

		if not IsValid(Gun) then return end
		if not Sound or Sound == "" then return end

		Propellant = math.max(Propellant,50)

		local ply = LocalPlayer()

		local count	= 1
		local Emitted   = false
		local ide	= "ACEFire#" .. math.random(1,100000)

		local Pos	= Gun:GetPos() -- Getting the position of the emitter now before the emitter ent stops existing.
		local GunId	= Gun:EntIndex() -- Using Ids to ensure that code doesnt fuck up if the gun is removed from the map during sound late report.

		--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
		if timer.Exists( ide ) then return end
		timer.Create( ide , 0.1, 0, function()

			count = count + 1

			local entply = ACE_SGetHearingEntity( ply )

			local plyPos    = entply.aceposoverride or entply:GetPos()
			local Dist      = (plyPos - Pos):Length()
			local Volume    = 1 / (Dist / 500) * Propellant / 18
			local Delay     = ACE_GetDistanceTime( Dist )

			if count > Delay then

				if not Emitted then

					Emitted = true

					--This defines the distance between areas for close, mid and far sounds
					local CloseDist	= Propellant * 40 * ACE.DistanceMultipler

					--Medium dist will be 4.25x times of closedist. So if closedist is 1000 units, then medium dist will be 4250 units
					local MediumDist	= CloseDist * 4.25

					--local FarDist	= MediumDist * 2

					--this variable fixes the vol for a better volume scale. Overrided normally
					local VolFix		= 1

					--Adjustable Pitch. Overrided normally
					local Pitch		= 100

					local SoundData	= ACE.GSounds["GunFire"][Sound]

					if SoundData then

						local State = "main"
						if Dist >= CloseDist and Dist < MediumDist then

							State	= "mid"
						elseif Dist >= MediumDist then

							State	= "far"
						end

						ACE.Sounds.GunTb[GunId] = (ACE.Sounds.GunTb[GunId] or 0) + 1

						if SoundData[State] then
							if ACE.Sounds.GunTb[GunId] > #SoundData[State]["Package"] then
								ACE.Sounds.GunTb[GunId] = 1
							end

							Sound	= SoundData[State]["Package"][ACE.Sounds.GunTb[GunId]]
							VolFix  = SoundData[State]["Volume"]
							Pitch	= SoundData[State]["Pitch"]
						end

					else
						Pitch = PitchOverride
					end

					--If a wall is in front of the player and is indoor, reduces its vol at 50%
					if not ACE_SHasLOS( Pos ) and ACE_SIsInDoor() then
						--print("Inside of building")
						VolFix = VolFix * 0.5
					end

					--Pos => Gun's pos before to timer. Not possible to use Gun:GetPos() due to risk of gun might not exist at this point.
					ACE_EmitSound( Sound or "", plyPos + (Pos - plyPos):GetNormalized() * 64, 90, Pitch, Volume * VolFix )

				end

				timer.Stop( ide )
				timer.Remove( ide )
			end
		end )
	end

	--TODO: Leave 5 sounds per caliber type. 22 7.26mm sounds go brrrr
	function ACE_SBulletCrack( BulletData, Caliber )

		debugoverlay.Cross(BulletData.SimPos, 10, 5, Color(0,0,255))

		local ply = LocalPlayer()
		local count    = 1
		local Emitted  = false --Was the sound played?

		local ide      = "ACECrack#" .. math.random(1,100000)

		--flag this, so we are not playing this sound for this bullet next time
		BulletData.CrackCreated = true

		if timer.Exists( ide ) then return end
		timer.Create( ide , 0.1, 0, function()

			count = count + 1

			local entply = ACE_SGetHearingEntity( ply )
			local plyPos = entply.aceposoverride or entply:GetPos() --print(plyPos)

			--Delayed event report.
			local CrackPos    = BulletData.SimPos - BulletData.SimFlight:GetNormalized() * 5000
			local Dist        = (plyPos - CrackPos):Length()
			local Volume      = 10000 / Dist
			local Delay       = ACE_GetDistanceTime( Dist )

			if count > Delay then

				if not Emitted then

					Emitted = true

					local VolFix = 0.1

					--Small arm guns
					local Sound = ACE.Sounds["Cracks"]["small"]["close"][math.random(1,#ACE.Sounds["Cracks"]["small"]["close"])]

					--30mm gun and above
					if Caliber >= 3 then
						Sound = ACE.Sounds["Cracks"]["medium"]["close"][math.random(1,#ACE.Sounds["Cracks"]["medium"]["close"])]

						--above 100mm cannons
						if Caliber >= 10 then
							Sound = ACE.Sounds["Cracks"]["large"]["close"][math.random(1,#ACE.Sounds["Cracks"]["large"]["close"])]
							VolFix = 1


							--Some fly sounds don´t fit really well. Special case here.
							if Caliber >= 20 then
								Sound = ACE.Sounds["Cracks"]["large"]["close"][math.random(1,#ACE.Sounds["Cracks"]["large"]["close"])]
								VolFix = 0.5
							end
						end
					end

					--If a wall is in front of the player and is indoor, reduces its vol
					if not ACE_SHasLOS( CrackPos ) and ACE_SIsInDoor() then
						--print("Inside of building")
						VolFix = VolFix * 0.025
					end

					ACE_EmitSound( Sound or "" , entply, 75, 100, Volume * VolFix )
				end
				timer.Stop( ide )
				timer.Remove( ide )
			end
		end )
	end

	--For any miscellaneous sound. BaseDistVolume is the Max dist where Volume will be 1. The volume will start losing dbs beyond this distance. In Units.
	function ACE_SimpleSound( Sound, Origin, Pitch, BaseDistVolume  )

		local ply = LocalPlayer()
		local count    = 1
		local Emitted  = false --Was the sound played?

		local ide = "ACESimpleSound#" .. math.random(1,100000)

		if timer.Exists( ide ) then return end
		timer.Create( ide , 0.1, 0, function()

			count = count + 1

			local entply = ACE_SGetHearingEntity( ply )
			local plyPos = entply.aceposoverride or entply:GetPos()

			--Delayed event report.
			local Dist        = (plyPos - Origin):Length()
			local Delay       = ACE_GetDistanceTime( Dist )
			local Volume      = BaseDistVolume / Dist

			if count > Delay then

				if not Emitted then

					Emitted = true

					local VolFix = 1

					--If a wall is in front of the player and is indoor, reduces its vol
					if not ACE_SHasLOS( Origin ) and ACE_SIsInDoor() then
						VolFix = VolFix * 0.025
					end

					ACE_EmitSound( Sound or "" , plyPos + (Origin - plyPos):GetNormalized() * 64, 100, Pitch, Volume * VolFix )
				end
				timer.Stop( ide )
				timer.Remove( ide )
			end
		end )

	end

	--Coming soon
	--function ACE_SBulletImpact()
	--end

end


