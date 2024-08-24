
function ACE_GetEntPoints(Ent)
	local Points = Ent.ACEPoints or 0 --Use the specially assigned points if it has them

	if Points == 0 and IsValid(Ent) then
			local phys = Ent:GetPhysicsObject()
			if IsValid(phys) then
				Points = phys:GetMass() / 1000 * ACF.PointsPerTon
				local EACF = Ent.ACF or {}
				local Mat = EACF.Material or "RHA"
				Points = Points * (ACE.MatCostTables[Mat] or 1)
			end
	end

		--print(Points)


	return Points
end


--Uncomment this to enable the point system checks.
--Picks an entity and then updates it in chunks across numerous ticks. Updating other legality flags could also happen once per update.
--Disabled for now. Noted issue: Removing a contraption or updating it in the middle of a check would occasionally completely break the system permanantly until a restart. Otherwise the system worked well. Now if I could only find the bug to squash.
--[[
do

	local ACE_TimerDelay = 0.1	--Time in seconds to run legality logic.
	local ACE_FractionsToIterate = 0.05 --Sections to break each vehicle into. 0.05 will iterate 5% of a vehicle every iteration. 2 seconds to fully profile a vehicle at 0.1 delay.

	local ACE_ContraptionFractionProfiled = 0
	local ACE_ContraptionLastCount = 0
	local ACE_ContraptionTestingPoints = 0
	function ACE_UpdateContraptionPoints(ContraptionEnt)

		--Gets entity count on the vehicle
		local ContCount = table.Count(ContraptionEnt.ents)

		--print(ContCount)

		--Determines which entities to test to
		ACE_ContraptionFractionProfiled = math.min(ACE_ContraptionFractionProfiled + ACE_FractionsToIterate,1)
		ContCountMax = math.ceil(ContCount * ACE_ContraptionFractionProfiled)

		--ACE_ContraptionFractionProfiled = 1.1

		--print("CMin: " .. ContCountMin)
		--print("CMax: " .. ContCountMax)

		local Pts = 0
		local TrackerCount = 0
		for ent in pairs(ContraptionEnt.ents) do
			TrackerCount = TrackerCount + 1
			if TrackerCount <= ACE_ContraptionLastCount then continue end --Could probably be done faster by storing a subtable but eh.
			if TrackerCount > ContCountMax then break end --Also eh
			Pts = Pts + ACE_GetEntPoints(ent)
		end

		ACE_ContraptionLastCount = TrackerCount

		if Pts > 0 then
			--print("Points tallied: " .. Pts)
			ACE_ContraptionTestingPoints = ACE_ContraptionTestingPoints + Pts
		end

		--All parts have been profiled. Move to the next vehicle.
		if ACE_ContraptionFractionProfiled >= 1 then
			ContraptionEnt.ACEPoints = ACE_ContraptionTestingPoints
			print("Total Contraption Points: " .. ACE_ContraptionTestingPoints)

			ACE_ContraptionTestingPoints = 0
			ACE_ContraptionFractionProfiled = 0
			ACE_ContraptionLastCount = 0

			--Tells that we have finished profiling the current vehicle
			return true
		end

		return false

		--ContraptionEnt.ACEPoints

	end


	local ACE_ContraptionToProfile = nil
	local ACE_ContraptionNumberProfiled = 0
	function ACE_FindNextContraption() --Finds the next CFW contraption in the list to profile

		local ContCount = table.Count(CFW.Contraptions)

		ACE_ContraptionNumberProfiled = ACE_ContraptionNumberProfiled + 1
		if ACE_ContraptionNumberProfiled > ContCount then
			ACE_ContraptionNumberProfiled = 1
		end

		local ContTrackerCount = 1
		for Contraption in pairs(CFW.Contraptions) do

			if ContTrackerCount < ACE_ContraptionNumberProfiled then continue end


			--if not IsValid(Contraption) then --Avoids a lot of wasted time sorting through invalid contraptions
			--	--print("Novalid")
			--	ACE_ContraptionNumberProfiled = ACE_ContraptionNumberProfiled + 1
			--	if ACE_ContraptionNumberProfiled > ContCount then
			--		ACE_ContraptionNumberProfiled = 1
			--	end
			--	continue
			--end


			ACE_ContraptionTestingPoints = 0
			ACE_ContraptionFractionProfiled = 0
			ACE_ContraptionLastCount = 0

			ACE_ContraptionToProfile = Contraption
			break

		end

	end

	local ACE_NextTickContraptions = 0
	function ACE_ContraptionLegality()

		if ACF.CurTime > ACE_NextTickContraptions then
			ACE_NextTickContraptions = ACF.CurTime + 2.25 --Logic runs every ~2.25 seconds

			if not ACE_ContraptionToProfile then
				ACE_FindNextContraption()
				print("Next Contraption to profile: " .. ACE_ContraptionNumberProfiled)
			end

		end


		if ACE_ContraptionToProfile then
			local ProfileContraption = ACE_UpdateContraptionPoints(ACE_ContraptionToProfile)
			if ProfileContraption then --If we finished profiling the contraption find the next contraption to profile
				ACE_ContraptionToProfile = nil
			end
		end

	end
	--timer.Remove( "ACE_ScanContraptionLegality" )
	--timer.Create( "ACE_ScanContraptionLegality", ACE_TimerDelay, 0, ACE_ContraptionLegality )

end
]]--






--for ent in pairs()


--Used for setweight update checks
--local PHYS = FindMetaTable("PhysObj")
--ACE_Override_SetMass = ACE_Override_SetMass or PHYS.SetMass

--[[
function PHYS:SetMass(mass)
	--local ent = self:GetEntity()
	print("some extra logic here, applied to")

	ACE_Override_SetMass(mass)
end
]]--
--[[

hook.Add("AdvDupe_FinishPasting", "TestHook", function(entityList)
    timer.Simple(0, function()
        local entID = next(entityList[1].EntityList)
        local ent = Entity(entID)
        local contraption = ent:GetContraption()
        
        print(entID, ent, contraption)
    end)
end)

]]--