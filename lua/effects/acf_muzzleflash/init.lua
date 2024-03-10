

--[[---------------------------------------------------------
	Initializes the effect. The data is a table of data
	which was passed from the server.
]]-----------------------------------------------------------
function EFFECT:Init( data )

	local Gun = data:GetEntity()
	if not IsValid(Gun) then return end

	local Propellant   = data:GetScale()
	local ReloadTime   = data:GetMagnitude()

	local Sound        = Gun:GetNWString( "Sound", "" )
	local SoundPitch   = Gun:GetNWInt( "SoundPitch", 100 )
	local Class        = Gun:GetNWString( "Class", "C" )
	local Caliber      = Gun:GetNWInt( "Caliber", 1 ) * 10
	local MuzzleEffect = Gun:GetNWString( "Muzzleflash", "50cal_muzzleflash_noscale" )

	--This tends to fail
	local ClassData	= ACF.Classes.GunClass[Class]
	local Attachment	= "muzzle"

	if ClassData then

		local longbarrel	= ClassData.longbarrel or nil

		if longbarrel ~= nil and Gun:GetBodygroup( longbarrel.index ) == longbarrel.submodel then
			Attachment = longbarrel.newpos
		end

	end

	if not IsValidSound( Sound ) then
		Sound = ClassData.sound
	end

	if Propellant > 0 then

		ACE_SGunFire( Gun, Sound, SoundPitch, Propellant )

		local Muzzle = Gun:GetAttachment( Gun:LookupAttachment(Attachment)) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }

		ParticleEffect( MuzzleEffect , Muzzle.Pos, Muzzle.Ang, Gun )

		if Gun:WaterLevel() ~= 3 and not ClassData.nolights then

			ACF_RenderLight(Gun:EntIndex(), Caliber * 75, Color(255, 128, 48), Muzzle.Pos + Muzzle.Ang:Forward() * (Caliber / 5))
		end

		if Gun.Animate then
			Gun:Animate( Class, ReloadTime, false )
		end
	else
		if Gun.Animate then
			Gun:Animate( Class, ReloadTime, true )
		end
	end

end


--[[---------------------------------------------------------
	THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	return false
end

--[[---------------------------------------------------------
	Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end
