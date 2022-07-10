

--[[--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
]]-----------------------------------------------------------
function EFFECT:Init( data ) 

	local Gun = data:GetEntity()
	if not IsValid(Gun) then return end
	
	local Propellant 	= data:GetScale()
	local ReloadTime 	= data:GetMagnitude()
	
	local Sound 		= Gun:GetNWString( "Sound", "" )
	local Class 		= Gun:GetNWString( "Class", "C" )
	local Caliber 		= Gun:GetNWInt( "Caliber", 1 ) * 10 

	--This tends to fail
	local ClassData 	= list.Get("ACFClasses").GunClass[Class]
	local Attachment 	= "muzzle"

	if ClassData then

		local longbarrel 	= ClassData.longbarrel or nil
	
		if longbarrel ~= nil then
			if Gun:GetBodygroup( longbarrel.index ) == longbarrel.submodel then
				Attachment = longbarrel.newpos
			end
		end

	end

	if not IsValidSound( Sound ) then
		Sound = ClassData["sound"]
	end
		
	if Propellant > 0 then

		ACE_SGunFire( Gun, Sound, Propellant )

		local Muzzle = Gun:GetAttachment( Gun:LookupAttachment(Attachment)) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }
		local Flash = ClassData and ClassData["muzzleflash"] or '50cal_muzzleflash_noscale'

		ParticleEffect( Flash , Muzzle.Pos, Muzzle.Ang, Gun )

		if Gun.Animate then 
			Gun:Animate( Class, ReloadTime, false )
		end
	else
		if Gun.Animate then 
			Gun:Animate( Class, ReloadTime, true )
		end
	end
	
 end 
   
   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end