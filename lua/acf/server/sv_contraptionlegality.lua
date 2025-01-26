

function ACE_DoContraptionLegalCheck(CheckEnt) --In the future could allow true/false to stop the vehicle from working.

	CheckEnt.CanLegalCheck = CheckEnt.CanLegalCheck or false
	if not CheckEnt.CanLegalCheck then return end

	CheckEnt.CanLegalCheck = false
	timer.Simple(3, function() if IsValid(CheckEnt) then CheckEnt.CanLegalCheck = true end end) --Reallows the legal check after 3 seconds to prevent spam.

	local Contraption = CheckEnt:GetContraption() or {}
	if table.IsEmpty(Contraption) then return end

	ACE_CheckLegalCont(Contraption)

end

function ACE_CheckLegalCont(Contraption)

	Contraption.OTWarnings = Contraption.OTWarnings or {} --Used to remember all the one time warnings.
	--Flag test
	local HasWarned = false

	HasWarned = Contraption.OTWarnings.WarnedOverPoints or false
	if Contraption.ACEPoints > ACF.PointsLimit and not HasWarned then
		local Ply = Contraption:GetACEBaseplate():CPPIGetOwner()
		local AboveAmt = Contraption.ACEPoints - ACF.PointsLimit
		local msg = "[ACE] " .. Ply:Nick() .. " has a vehicle [" .. math.ceil(AboveAmt) .. "pts] over the limit costing [" .. math.ceil(Contraption.ACEPoints) .. "pts / " .. math.ceil(ACF.PointsLimit) .. "pts]"

		chatMessageGlobal( msg, Color( 255, 234, 0))

		Contraption.OTWarnings.WarnedOverPoints = true
	end

	--HasWarned = Contraption.OTWarnings.WarnedOverWeight or false
	if Contraption.totalMass > ACF.MaxWeight and not HasWarned then
		local Ply = Contraption:GetACEBaseplate():CPPIGetOwner()
		local AboveAmt = Contraption.totalMass - ACF.MaxWeight

		local msg = "[ACE] " .. Ply:Nick() .. " has a vehicle [" .. math.ceil(AboveAmt) .. "kg] over the limit, weighing [" .. math.ceil(Contraption.totalMass) .. "kg / " .. math.ceil(ACF.MaxWeight) .. "kg]"
		chatMessageGlobal( msg, Color( 255, 234, 0))

		Contraption.OTWarnings.WarnedOverWeight = true
	end

	--chatMessageGlobal( message, color)


end



function ACE_GetEntPoints(Ent, MassOverride)
	local Points = 0 --Use the specially assigned points if it has them


	if IsValid(Ent) then --Used to exclude entities with special points. Could exploit this by using said entities as armor. Now it's in addition to.

		if not MassOverride then
			local phys = Ent:GetPhysicsObject()
			if IsValid(phys) then
				Points = phys:GetMass() / 1000 * ACF.PointsPerTon
				local EACF = Ent.ACF or {}
				local Mat = EACF.Material or "RHA"
				local DuctMul = 1 / ( 1 + (EACF.Ductility or 1) ) ^ 0.5 --Counteracts the weight bonus from ductility.

				Points = Points * (ACE.MatCostTables[Mat] or 1) * DuctMul
			end
		else
			Points = MassOverride / 1000 * ACF.PointsPerTon
			local EACF = Ent.ACF or {}
			local Mat = EACF.Material or "RHA"
			local DuctMul = 1 / ( 1 + (EACF.Ductility or 1) ) ^ 0.5 --Counteracts the weight bonus from ductility.

			Points = Points * (ACE.MatCostTables[Mat] or 1) * DuctMul
		end

	end

	Points = Points + (Ent.ACEPoints or 0)

	return Points
end

do


	--Used for setweight update checks. This is such a hacky way to do things.
	local PHYS    = FindMetaTable("PhysObj")
	local ACE_Override_SetMass = ACE_Override_SetMass or PHYS.SetMass
	function PHYS:SetMass(mass)

		local ent     = self:GetEntity()
		local oldPointValue = ent._AcePts or 0 -- The 'or 0' handles cases of ents connected before they had a physObj

		ent._AcePts = ACE_GetEntPoints(ent,mass)

		ACE_Override_SetMass(self,mass)

		local con = ent:GetContraption()

		if con then
			con.ACEPoints = con.ACEPoints + (ent._AcePts - oldPointValue)
		end
	end

	local FirepowerEnts = {
		["acf_rack"]                  = true,
		["acf_gun"]                   = true
	}
	local CrewEnts = {
		["ace_crewseat_gunner"]                  = true,
		["ace_crewseat_loader"]                  = true,
		["ace_crewseat_driver"]                   = true
	}
	local ElectronicEnts = {
		["ace_rwr_dir"]                  = true,
		["ace_rwr_sphere"]                  = true,
		["acf_missileradar"]                  = true,
		["acf_opticalcomputer"]                  = true,
		["ace_ecm"]                  = true,
		["ace_trackingradar"]                  = true,
		["ace_searchradar"]                  = true,
		["ace_irst"]                  = true,
		["ace_crewseat_driver"]                   = true
	}

	local function ACE_getPtsType(ClassName)
		local RetVal = "Armor"

		if ClassName == "prop_physics" then
			--Do nothing. Bypass to skip all the later checks for most common parts.
			RetVal = "Armor" --In circumstances like these, I HATE LINTER. Useless redundant callout but I have to have it to prevent the chain from being empty.
		elseif ClassName == "acf_engine" then
			RetVal = "Engines"
		elseif FirepowerEnts[ClassName] then
			RetVal = "Firepower"
		elseif ClassName == "acf_fueltank" then
			RetVal = "Fuel"
		elseif ClassName == "acf_ammo" then
			RetVal = "Ammo"
		elseif CrewEnts[ClassName] then
			RetVal = "Crew"
		elseif ElectronicEnts[ClassName] then
			RetVal = "Electronics"
		end

		return RetVal
	end

	local function ACE_InitPts(Class)
		Class.ACEPoints = 0

		Class.ACEPointsPerType = {}
		Class.ACEPointsPerType.Armor = 0
		Class.ACEPointsPerType.Engines = 0
		Class.ACEPointsPerType.Firepower = 0
		Class.ACEPointsPerType.Fuel = 0
		Class.ACEPointsPerType.Ammo = 0
		Class.ACEPointsPerType.Crew = 0
		Class.ACEPointsPerType.Electronics = 0
	end

	hook.Add("cfw.contraption.created", "ACE_InitPoints", ACE_InitPts)
	hook.Add("cfw.family.created", "ACE_InitPoints", ACE_InitPts)


	function ACE_AddPts(Class, Ent)
		if not IsValid(Ent) then return end

		--local Mass = PhysObj:GetMass()

		local AcePts = ACE_GetEntPoints(Ent)

		Ent._AcePts     = AcePts

		Class.ACEPoints = Class.ACEPoints + AcePts

		local EClass = ACE_getPtsType(Ent:GetClass())
		Class.ACEPointsPerType[EClass] = Class.ACEPointsPerType[EClass] + AcePts

		--print(Class.ACEPoints)
	end
	hook.Add("cfw.contraption.entityAdded", "ACE_AddPoints", ACE_AddPts)
	hook.Add("cfw.family.added", "ACE_AddPoints", ACE_AddPts)

	function ACE_RemPts(Class, Ent)
		if not IsValid(Ent) then return end

		local AcePts = ACE_GetEntPoints(Ent)

		Class.ACEPoints = Class.ACEPoints - AcePts

		local EClass = ACE_getPtsType(Ent:GetClass())
		Class.ACEPointsPerType[EClass] = Class.ACEPointsPerType[EClass] - AcePts
		--print(EClass .. ": " .. Class.ACEPointsPerType[EClass])
	end

	hook.Add("cfw.contraption.entityRemoved", "ACE_RemPoints", ACE_RemPts)
	hook.Add("cfw.family.subbed", "ACE_RemPoints", ACE_RemPts)


end