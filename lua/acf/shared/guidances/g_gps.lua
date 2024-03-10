
local ClassName = "GPS"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Wire)
ACF.Guidance[ClassName] = this

this.Name = ClassName

-- An entity with a Position wire-output
this.InputSource = nil

this.desc = "This guidance package recieves a one-time position and guides to it regardless of LOS."

-- Disables guidance when true
this.FirstGuidance = true


function this:Init()

end




function this:Configure(missile)

	local launcher = missile.Launcher
	local outputs = launcher.Outputs

	if outputs then

		local names = self:GetNamedWireInputs(missile)


		if #names > 0 then

			self.InputSource = launcher
			self.InputNames = names

		else

			names = self:GetFallbackWireInputs(missile)

			if #names > 0 then
				self.InputSource = launcher
				self.InputNames = names
			end

		end

	end

	self:super().Configure(self, missile)

	self.FirstGuidance = true

end

function this:GetNamedWireInputs(missile)

	local launcher = missile.Launcher
	local outputs = launcher.Outputs

	local names = {}

	-- If we have a Position output, we're in business.
	if outputs.Position and outputs.Position.Type == "VECTOR" then

		names[#names + 1] = "Position"

	end


	if outputs.Target and outputs.Target.Type == "ENTITY" then

		names[#names + 1] = "Target"

	end


	return names

end

function this:GetFallbackWireInputs(missile)

	local launcher = missile.Launcher
	local outputs = launcher.Outputs

	-- To avoid ambiguity, only link if there's a single vector output.
	local foundOutput = nil

	for k, v in pairs(outputs) do
		if v.Type == "VECTOR" then
			if foundOutput then
				foundOutput = nil
				break
			else
				foundOutput = k
			end
		end
	end

	if foundOutput then
		return {foundOutput}
	end

end


function this:GetGuidance(_)

	local posVec = self:GetWireTarget()

	if self.FirstGuidance then
		if not posVec or type(posVec) ~= "Vector" or posVec == Vector() then
			return {TargetPos = nil}
		end
		self.FirstGuidance = false
		self.TargetPos = posVec
	end

	return {TargetPos = self.TargetPos, ViewCone = self.ViewCone}

end

--Another Stupid Workaround. Since guidance degrees are not loaded when ammo is created
function this:GetDisplayConfig(_)

	return
	{
		["Tracking"] = "Single Position"
	}
end



function this:GetWireTarget()

	if not IsValid(self.InputSource) then
		return {}
	end

	local outputs = self.InputSource.Outputs

	if not outputs then
		return {}
	end


	local posVec

	for _, name in pairs(self.InputNames) do

		local outTbl = outputs[name]

		if not (outTbl and outTbl.Value) then continue end

		local val = outTbl.Value

		if isvector(val) and (val.x ~= 0 or val.y ~= 0 or val.z ~= 0) then
			posVec = val
			break
		elseif IsEntity(val) and IsValid(val) then
			posVec = val:GetPos()
			break
		end

	end


	return posVec

end