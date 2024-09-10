

function ACE_DoContraptionLegalCheck(CheckEnt) --In the future could allow true/false to stop the vehicle from working.

	CheckEnt.CanLegalCheck = CheckEnt.CanLegalCheck or false
	if not CheckEnt.CanLegalCheck then return end
	CheckEnt.CanLegalCheck = false

	local Contraption = CheckEnt:GetContraption()
	if not IsValid(Contraption) then return end
	ACE_CheckLegalCont(Contraption)

	timer.Simple(3, function() if IsValid(CheckEnt) then CheckEnt.CanLegalCheck = true end end) --Reallows the legal check after 3 seconds to prevent spam.

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

	HasWarned = Contraption.OTWarnings.WarnedOverWeight or false
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


	local function ACE_InitPts(Class)
		Class.ACEPoints = 0
	end
	hook.Add("cfw.contraption.created", "ACE_InitPoints", ACE_InitPts)
	hook.Add("cfw.family.created", "ACE_InitPoints", ACE_InitPts)


	local function ACE_AddPts(Class, Ent)
		if not IsValid(Ent) then return end

		--local Mass = PhysObj:GetMass()

		local AcePts = ACE_GetEntPoints(Ent)

		Ent._AcePts     = AcePts

		Class.ACEPoints = Class.ACEPoints + AcePts
		--print(Class.ACEPoints)
	end
	hook.Add("cfw.contraption.entityAdded", "ACE_AddPoints", ACE_AddPts)
	hook.Add("cfw.family.added", "ACE_AddPoints", ACE_AddPts)

	local function ACE_RemPts(Class, Ent)
		if not IsValid(Ent) then return end

		local AcePts = ACE_GetEntPoints(Ent)

		Class.ACEPoints = Class.ACEPoints - AcePts
	end

	hook.Add("cfw.contraption.entityRemoved", "ACE_RemPoints", ACE_RemPts)
	hook.Add("cfw.family.subbed", "ACE_RemPoints", ACE_RemPts)


end