
function ACE_GetEntPoints(Ent)
	local Points = Ent.ACEPoints or -1 --Use the speciailly assigned points if it has them

		if Points == -1 and IsValid(Ent) then
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

function ACE_UpdateContraptionPoints(ContraptionEnt) --

		local Pts = 0


		for ent in pairs(ContraptionEnt.ents) do
			Pts = Pts + ACE_GetEntPoints(ent)
		end

		if Pts > 1 then
			--print("Total Contraption Pointcost: " .. Pts)
			ContraptionEnt.ACEPoints = Pts
		end
		return Pts
end

ACE_NextTickContraptions = 0
--Replace with system that updates tanks individually much faster.

function ACE_ContraptionLegality()

	if ACF.CurTime > ACE_NextTickContraptions then
		--ACE_NextTickContraptions = ACF.CurTime + 3
		ACE_NextTickContraptions = ACF.CurTime + 10

		for Contraption in pairs(CFW.Contraptions) do
			ACE_UpdateContraptionPoints(Contraption)
		end

	end
end
hook.Remove( "Tick", "ACE_HandleContraptionLegality" )
hook.Add("Tick", "ACE_HandleContraptionLegality", ACE_ContraptionLegality)


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