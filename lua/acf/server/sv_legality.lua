
--[[
	set up to provide a random, fairly low cost legality check that discourages trying to game legality checking
	with a hard to predict check time and punishing lockout time
	usage:
	Ent.Legal, Ent.LegalIssues = ACF_CheckLegal(Ent, Model, MinMass, MinInertia, NeedsGateParent, CanVisclip )
	Ent.NextLegalCheck = ACF.LegalSettings:NextCheck(Ent.Legal)
]]

ACF.LegalSettings = {
	CanModelSwap = false,
	Min = 5, 			-- min seconds between checks
	Max = 25, 			-- max seconds between checks
	Lockout = 35,		-- lockout time on not legal
	NextCheck = function(self, Legal) return ACF.CurTime + (Legal and math.random(self.Min, self.Max) or self.Lockout) end
}

--[[
   checks if an ent meets the given requirements for legality
   MinInertia needs to be mass normalized (normalized=inertia/mass)
   ballistics doesn't check visclips on anything except prop_physics, so no need to check on acf ents
]]--

function ACF_CheckLegal(Ent, Model, MinMass, MinInertia, NeedsGateParent, CanVisclip )
    
	
	local problems = {} --problems table definition
	local physobj = Ent:GetPhysicsObject()
    
	if ACF.LegalChecks == 0 then return  (#problems == 0), table.concat(problems, ", ") end   --checking if admin has allowed legal checks first
	
	-- check it exists
	if not IsValid(Ent) then return { Legal=false, Problems ={"Invalid Ent"} } end
	
	-- check if physics is valid
	if not IsValid(physobj) then return { Legal=false, Problems ={"Invalid Physics"} } end
	
	-- make sure traces can hit it (fade door, propnotsolid)
	if not Ent:IsSolid() then
		table.insert(problems,"Not solid")
	end

	-- check if the model matches
	if Model != nil and not ACF.LegalSettings.CanModelSwap then
		if Ent:GetModel() != Model then
			table.insert(problems,"Wrong model")
		end
	end

	-- check mass
	if MinMass != nil and (physobj:GetMass() < MinMass) then
		table.insert(problems,"Under min mass")
	end

	-- check material
	-- Allowed materials: rha, cast and aluminum
	local material = Ent.ACF and Ent.ACF.Material or 0
	if material > 1 then
		if material ~= 5 then table.insert(problems,"Material not legal") end
	end

	-- check inertia components
	if MinInertia != nil then
		local inertia = physobj:GetInertia()/physobj:GetMass()
		if (inertia.x < MinInertia.x) or (inertia.y < MinInertia.y) or (inertia.z < MinInertia.z) then
			table.insert(problems,"Under min inertia")
		end
	end

	-- check makesphere
	if physobj:GetVolume() == nil then
		table.insert(problems,"Has makesphere")
	end

	-- check for clips
	if not CanVisclip and (Ent.ClipData != nil) and (#Ent.ClipData > 0) then
		table.insert(problems,"Has visclip")
	end

	-- if it has a parent, check if legally parented
	if Ent:GetParent():IsValid() then
		--Re-used requires wel parent, don't mind me being evil
		--if NeedsGateParent and not IsValid( Ent:GetParent():GetParent() ) then --Makes sure you parent in a way that doesn't bypass traces, Note that you do not actually need to parent to a gate as that does not matter
		--	table.insert(problems,"Not propperly gate parented. Parent the parent entity.")
		--end

		-- dev note: parent really requires a gate since not using it will lead to other ways of bypassing. As proof, test the code above vs missiles. They will hit nothing...
		-- Also, you just need a gate for it, no required to validate the parent of the parent.
		-- check if you have parented to a gate since this will avoid to bypass traces
		if NeedsGateParent and Ent:GetParent():GetClass() ~= 'gmod_wire_gate' then
			table.insert(problems,"Not gate parented")
		end
	end
     	
	-- legal if number of problems is 0
	return (#problems == 0), table.concat(problems, ", ")
	
end