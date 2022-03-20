
--[[
	set up to provide a random, fairly low cost legality check that discourages trying to game legality checking
	with a hard to predict check time and punishing lockout time
	usage:
	Ent.Legal, Ent.LegalIssues = ACF_CheckLegal(Ent, Model, MinMass, MinInertia, NeedsGateParent, CanVisclip )
	Ent.NextLegalCheck = ACF.LegalSettings:NextCheck(Ent.Legal)
]]

ACF = ACF or {}

ACF.Legal = {}
ACF.Legal.Ignore = {}

ACF.Legal.IsActivated        = math.max(GetConVar('acf_legalcheck'):GetInt(), 0)

ACF.Legal.Ignore.Solid       = math.max(GetConVar('acf_legal_ignore_solid'):GetInt(), 0)
ACF.Legal.Ignore.Model       = math.max(GetConVar('acf_legal_ignore_model'):GetInt(), 0)
ACF.Legal.Ignore.Mass        = math.max(GetConVar('acf_legal_ignore_mass'):GetInt(), 0)
ACF.Legal.Ignore.Material    = math.max(GetConVar('acf_legal_ignore_material'):GetInt(), 0)
ACF.Legal.Ignore.Inertia     = math.max(GetConVar('acf_legal_ignore_inertia'):GetInt(), 0)
ACF.Legal.Ignore.makesphere  = math.max(GetConVar('acf_legal_ignore_makesphere'):GetInt(), 0)
ACF.Legal.Ignore.visclip     = math.max(GetConVar('acf_legal_ignore_visclip'):GetInt(), 0)
ACF.Legal.Ignore.Parent      = math.max(GetConVar('acf_legal_ignore_parent'):GetInt(), 0)

function ACF_LegalityCallBack()

	ACF.Legal.IsActivated        = math.max(GetConVar('acf_legalcheck'):GetInt(), 0)

	ACF.Legal.Ignore.Solid       = math.max(GetConVar('acf_legal_ignore_solid'):GetInt(), 0)
	ACF.Legal.Ignore.Model       = math.max(GetConVar('acf_legal_ignore_model'):GetInt(), 0)
	ACF.Legal.Ignore.Mass        = math.max(GetConVar('acf_legal_ignore_mass'):GetInt(), 0)
	ACF.Legal.Ignore.Material    = math.max(GetConVar('acf_legal_ignore_material'):GetInt(), 0)
	ACF.Legal.Ignore.Inertia     = math.max(GetConVar('acf_legal_ignore_inertia'):GetInt(), 0)
	ACF.Legal.Ignore.makesphere  = math.max(GetConVar('acf_legal_ignore_makesphere'):GetInt(), 0)
	ACF.Legal.Ignore.visclip     = math.max(GetConVar('acf_legal_ignore_visclip'):GetInt(), 0)
	ACF.Legal.Ignore.Parent      = math.max(GetConVar('acf_legal_ignore_parent'):GetInt(), 0)

end

cvars.AddChangeCallback('acf_legalcheck',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_solid',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_model',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_mass',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_material',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_inertia',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_makesphere',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_visclip',ACF_LegalityCallBack)
cvars.AddChangeCallback('acf_legal_ignore_parent',ACF_LegalityCallBack)




ACF.Legal.Min = 5 			-- min seconds between checks --5
ACF.Legal.Max = 25 			-- max seconds between checks --25
ACF.Legal.Lockout = 35		-- lockout time on not legal  --35
ACF.Legal.NextCheck = function(self, Legal) return ACF.CurTime + (Legal and math.random(ACF.Legal.Min, ACF.Legal.Max) or ACF.Legal.Lockout) end


--[[
   checks if an ent meets the given requirements for legality
   MinInertia needs to be mass normalized (normalized=inertia/mass)
   ballistics doesn't check visclips on anything except prop_physics, so no need to check on acf ents
]]--

local AllowedMaterials = {
	RHA = true,
	CHA = true,
	Alum = true
}

--Convert old numeric IDs to the new string IDs
local BackCompMat = {
	"RHA",
	"CHA",
	"Cer",
	"Rub",
	"ERA",
	"Alum",
	"Texto"
}

function ACF_CheckLegal(Ent, Model, MinMass, MinInertia, NeedsGateParent, CanVisclip )

	local problems = {} --problems table definition

	if ACF.Legal.IsActivated == 0 then return (#problems == 0), table.concat(problems, ", ") end

	local physobj = Ent:GetPhysicsObject()
	
	-- check it exists
	if not IsValid(Ent) then return { Legal=false, Problems ={"Invalid Ent"} } end
	
	-- check if physics is valid
	if not IsValid(physobj) then return { Legal=false, Problems ={"Invalid Physics"} } end
	
	-- make sure traces can hit it (fade door, propnotsolid)
	if ACF.Legal.Ignore.Solid <= 0  and not Ent:IsSolid() then
		table.insert(problems,"Not solid")
	end

	-- check if the model matches
	if Model != nil then
		if ACF.Legal.Ignore.Model <= 0 and Ent:GetModel() != Model then
			table.insert(problems,"Wrong model")
		end
	end

	-- check mass
	if ACF.Legal.Ignore.Mass <= 0 and MinMass != nil and (physobj:GetMass() < MinMass) then
		table.insert(problems,"Under min mass")
	end

	-- check material
	-- Allowed materials: rha, cast and aluminum
	if ACF.Legal.Ignore.Material <= 0 then

		local material = Ent.ACF and Ent.ACF.Material or "RHA"

		-- Change numeric ids from old material to the new string material ids. Yeah, because ACF is no updating props when being spawned from a old dupe on spawn.
		if not isstring(material) then

			local Mat_ID = material + 1
			material = BackCompMat[Mat_ID]

		end

		if not AllowedMaterials[material] then
			table.insert(problems,"Material not legal")
		end
	end

	-- check inertia components
	if ACF.Legal.Ignore.Inertia <= 0 and MinInertia != nil then
		local inertia = physobj:GetInertia()/physobj:GetMass()
		if (inertia.x < MinInertia.x) or (inertia.y < MinInertia.y) or (inertia.z < MinInertia.z) then
			table.insert(problems,"Under min inertia")
		end
	end

	-- check makesphere
	if ACF.Legal.Ignore.makesphere <= 0 and physobj:GetVolume() == nil then
		table.insert(problems,"Has makesphere")
	end

	-- check for clips
	if ACF.Legal.Ignore.visclip <= 0 and not CanVisclip and (Ent.ClipData != nil) and (#Ent.ClipData > 0) then
		table.insert(problems,"Has visclip")
	end

	-- if it has a parent, check if legally parented
	if ACF.Legal.Ignore.Parent <= 0 and Ent:GetParent():IsValid() then

		-- check if you have parented to a gate since this will avoid to bypass traces
		if NeedsGateParent and Ent:GetParent():GetClass() ~= 'gmod_wire_gate' then
			table.insert(problems,"Not gate parented")
		end
	end
     	
	-- legal if number of problems is 0
	return (#problems == 0), table.concat(problems, ", ")
	
end