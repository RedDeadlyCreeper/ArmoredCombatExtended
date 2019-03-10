

ACFM_Flares = {}
ACFM_ECMs = {}

ACFM_FlareUID = 0
ACFM_ECMUID = 0




function ACFM_RegisterFlare(bdata)

	bdata.FlareUID = ACFM_FlareUID
	ACFM_Flares[bdata.Index] = ACFM_FlareUID
	
	ACFM_FlareUID = ACFM_FlareUID + 1
	
	
	local flareObj = ACF.Countermeasure.Flare()
	flareObj:Configure(bdata)
	
	bdata.FlareObj = flareObj

	
	ACFM_OnFlareSpawn(bdata)
	
end

function ACFM_RegisterECM(bdata)

	bdata.ECMUID = ACFM_ECMUID
	ACFM_ECMs[bdata.Index] = ACFM_ECMUID
	
	ACFM_ECMUID = ACFM_ECMUID + 1
	
	
	local ecmObj = ACF.Countermeasure.Flare()
	ecmObj:Configure(bdata)
	
	bdata.ECMObj = ecmObj

	
	ACFM_OnECMSpawn(bdata)
	
end




function ACFM_UnregisterFlare(bdata)

	local flareObj = bdata.FlareObj
	
	if flareObj then
		flareObj.Flare = nil
	end

	ACFM_Flares[bdata.Index] = nil

end

function ACFM_UnregisterECM(bdata)

	local ecmObj = bdata.ECMObj
	
	if ecmObj then
		ecmObj.ECM = nil
	end

	ACFM_ecms[bdata.Index] = nil

end




function ACFM_OnFlareSpawn(bdata)

	local flareObj = bdata.FlareObj

	local missiles = flareObj:ApplyToAll()
	
	for k, missile in pairs(missiles) do
		missile.Guidance.Override = flareObj
	end

end

function ACFM_OnECMSpawn(bdata)

	local ecmObj = bdata.ECMObj

	local missiles = ecmObj:ApplyToAll()
	
	for k, missile in pairs(missiles) do
		missile.Guidance.Override = ecmObj
	end

end




function ACFM_GetFlaresInCone(pos, dir, degs)

	local ret = {}
	local bullets = ACF.Bullet
	
	for idx, uid in pairs(ACFM_Flares) do
		
		local flare = bullets[idx]
		
		if not (flare and flare.FlareUID and flare.FlareUID == uid) then continue end
		
		if ACFM_ConeContainsPos(pos, dir, degs, flare.Pos) then
			ret[#ret+1] = flare
		end
		
	end

	return ret
	
end

function ACFM_GetECMsInCone(pos, dir, degs)

	local ret = {}
	local bullets = ACF.Bullet
	
	for idx, uid in pairs(ACFM_ECM) do
		
		local ecm = bullets[idx]
		
		if not (ecm and ecm.FlareUID and ecm.FlareUID == uid) then continue end
		
		if ACFM_ConeContainsPos(pos, dir, degs, ecm.Pos) then
			ret[#ret+1] = ecm
		end
		
	end

	return ret
	
end




function ACFM_GetAnyFlareInCone(pos, dir, degs)

	local bullets = ACF.Bullet
	
	for idx, uid in pairs(ACFM_Flares) do
		
		local flare = bullets[idx]
		
		if not (flare and flare.FlareUID and flare.FlareUID == uid) then continue end
		
		if ACFM_ConeContainsPos(pos, dir, degs, flare.Pos) then
			return flare
		end
		
	end
	
end




function ACFM_GetMissilesInCone(pos, dir, degs)

	local ret = {}
	
	for missile, _ in pairs(ACF_ActiveMissiles) do
		
		if not IsValid(missile) then continue end
		
		if ACFM_ConeContainsPos(pos, dir, degs, missile:GetPos()) then
			ret[#ret+1] = missile
		end
		
	end

	return ret
	
end




function ACFM_GetMissilesInSphere(pos, radius)

	local ret = {}
	
	local radSqr = radius * radius
	
	for missile, _ in pairs(ACF_ActiveMissiles) do
		
		if not IsValid(missile) then continue end
		
		if pos:DistToSqr(missile:GetPos()) <= radSqr then
			ret[#ret+1] = missile
		end
		
	end

	return ret
	
end




-- Tests flare distraction effect upon all undistracted missiles, but does not perform the effect itself.  Returns a list of potentially affected missiles.
-- argument is the bullet in the acf bullet table which represents the flare - not the cm_flare object!
function ACFM_GetAllMissilesWhichCanSee(pos)

	local ret = {}

	for missile, _ in pairs(ACF_ActiveMissiles) do
	
		local guidance = missile.Guidance
	
		if not guidance or guidance.Override or not guidance.ViewCone then 
			continue 
		end
				
		if ACFM_ConeContainsPos(missile:GetPos(), missile:GetForward(), guidance.ViewCone, pos) then
			ret[#ret+1] = missile
		end
		
	end
	
	return ret
	
end




function ACFM_ConeContainsPos(conePos, coneDir, degs, pos)

	local minDot = math.cos( math.rad(degs) )	
		
	local testDir = pos - conePos
	testDir:Normalize()
	
	local dot = coneDir:Dot(testDir)
	
	return (dot >= minDot)
end




function ACFM_ApplyCountermeasures(missile, guidance)

	if guidance.Override then return end
	
	for name, measure in pairs(ACF.Countermeasure) do
	
		if not measure.ApplyContinuous then
			continue
		end
	
		if ACFM_ApplyCountermeasure(missile, guidance, measure) then
			break
		end
	
	end

end




function ACFM_ApplySpawnCountermeasures(missile, guidance)

	if guidance.Override then return end
	
	for name, measure in pairs(ACF.Countermeasure) do
	
		if measure.ApplyContinuous then
			continue
		end
	
		if ACFM_ApplyCountermeasure(missile, guidance, measure) then
			break
		end
	
	end

end




function ACFM_ApplyCountermeasure(missile, guidance, measure)

	if not measure.AppliesTo[guidance.Name] then 
		return false
	end		
	
	local override = measure.ApplyAll(missile, guidance)
	
	if override then
		guidance.Override = override
		return true
	end

end

