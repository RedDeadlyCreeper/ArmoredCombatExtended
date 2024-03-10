
ACF = ACF or {}
ACF.Fuse = ACF.Fuse or {}

local ClassName = "Cluster"

local this = ACF.Fuse[ClassName] or inherit.NewSubOf(ACF.Fuse.Contact)
ACF.Fuse[ClassName] = this

---



this.Name = ClassName


this.Cluster = 2000


this.desc = "This fuse fires a beam directly ahead and releases bomblets when the beam hits something close-by. \n\nRemember that using this is a warcrime, so beware.\nDistance in inches."


-- Configuration information for things like acfmenu.
this.Configurable = this:super() and table.Copy(this:super().Configurable) or {}


local configs = this.Configurable
configs[#configs + 1] =
{
	Name = "Cluster",		-- name of the variable to change
	DisplayName = "Distance",	-- name displayed to the user
	CommandName = "Ds",		-- shorthand name used in console commands

	Type = "number",			-- lua type of the configurable variable
	Min = 1,					-- number specific: minimum value
	Max = 10000				-- number specific: maximum value

	-- in future if needed: min/max getter function based on munition type.  useful for modifying radar cones?
}




-- Do nothing, projectiles auto-detonate on contact anyway.
function this:GetDetonate(missile)

	if not self:IsArmed() then return false end

	local missilePos = missile:GetPos()

	local tracedata =
	{
		start = missilePos,
		endpos = missilePos + missile:GetForward() * self.Cluster,
		filter = missile.Filter or missile,
		mins = Vector(0,0,0),
		maxs = Vector(0,0,0)
	}
	local trace = util.TraceHull(tracedata)

	if IsValid(trace.Entity) and (trace.Entity:GetClass() == "acf_missile" or trace.Entity:GetClass() == "ace_missile_swep_guided") then return false end

	return trace.Hit

end

do

	local WhiteList = {
		HE	= true,
		HEAT	= true,
	}

	local function CreateCluster(missile, bdata)

		local RoundType = bdata.Type

		--Make cluster to fail. Allow with rounds on whitelist only.
		if not WhiteList[RoundType] then return end

		local Bomblets  = math.Clamp(math.Round(bdata.FillerMass * 1.5),3,30)	--30 bomblets original
		--local MuzzlePos = missile:LocalToWorld(Vector(10,0,0))
		local MuzzleVec = missile:GetForward()

		if bdata.Type == "HEAT" then
			Bomblets = math.Clamp(Bomblets,3,25)
		end

		missile.BulletData = {}

		missile.BulletData["Accel"]			= Vector(0,0,-600)
		missile.BulletData["BoomPower"]		= bdata.BoomPower
		missile.BulletData["Caliber"] 		= math.Clamp(bdata.Caliber / Bomblets * 10, 0.05, bdata.Caliber * 0.8) --Controls visual size, does nothing else
		missile.BulletData["Crate"]			= bdata.Crate
		missile.BulletData["DragCoef"]		= bdata.DragCoef / Bomblets / 2
		missile.BulletData["FillerMass"]	= bdata.FillerMass / Bomblets / 2	--nan armor ocurrs when this value is > 1

		--print(bdata.FillerMass)
		--print(Bomblets)
		--print(missile.BulletData["FillerMass"])

		missile.BulletData["Filter"]		= missile
		missile.BulletData["Flight"]		= bdata.Flight
		missile.BulletData["FlightTime"]	= 0
		missile.BulletData["FrArea"]		= bdata.FrArea
		missile.BulletData["FuseLength"]	= 0
		missile.BulletData["Gun"]			= missile
		missile.BulletData["Id"]			= bdata.Id
		missile.BulletData["KETransfert"]	= bdata.KETransfert
		missile.BulletData["LimitVel"]		= 700
		missile.BulletData["MuzzleVel"]		= bdata.MuzzleVel * 20
		missile.BulletData["Owner"]			= bdata.Owner
		missile.BulletData["PenArea"]		= bdata.PenArea
		missile.BulletData["Pos"]			= bdata.Pos
		missile.BulletData["ProjLength"]	= bdata.ProjLength / Bomblets / 2
		missile.BulletData["ProjMass"]		= bdata.ProjMass / Bomblets / 2
		missile.BulletData["PropLength"]	= bdata.PropLength
		missile.BulletData["PropMass"]		= bdata.PropMass
		missile.BulletData["Ricochet"]		= 90--bdata.Ricochet

		--print(bdata.Ricochet)

		missile.BulletData["RoundVolume"]	= bdata.RoundVolume
		missile.BulletData["ShovePower"]	= bdata.ShovePower
		missile.BulletData["Tracer"]		= 0


		missile.BulletData["Type"]		= bdata.Type

		if missile.BulletData.Type == "HEAT" then

			missile.BulletData["SlugMass"] 		= bdata.SlugMass / (Bomblets / 6)
			missile.BulletData["SlugCaliber"] 	= bdata.SlugCaliber / (Bomblets / 6)
			missile.BulletData["SlugDragCoef"] 	= bdata.SlugDragCoef / (Bomblets / 6)
			missile.BulletData["SlugMV"] 		= bdata.SlugMV / (Bomblets / 6)
			missile.BulletData["SlugPenArea"] 	= bdata.SlugPenArea / (Bomblets / 6)
			missile.BulletData["SlugRicochet"] 	= bdata.SlugRicochet
			missile.BulletData["ConeVol"] 		= bdata.SlugMass * 1000 / 7.9 / (Bomblets / 6)
			missile.BulletData["CasingMass"] 	= missile.BulletData.ProjMass + missile.BulletData.FillerMass + (missile.BulletData.ConeVol * 1000 / 7.9)
			missile.BulletData["BoomFillerMass"] = missile.BulletData.FillerMass / 1.5

			--local SlugEnergy = ACF_Kinetic( missile.BulletData.MuzzleVel * 39.37 + missile.BulletData.SlugMV * 39.37 , missile.BulletData.SlugMass, 999999 )
			--local  MaxPen = (SlugEnergy.Penetration/missile.BulletData.SlugPenArea) * ACF.KEtoRHA
			--print(MaxPen)

		end

		missile.FakeCrate = ents.Create("acf_fakecrate2")

		missile.FakeCrate:RegisterTo(missile.BulletData)
		missile.BulletData["Crate"] = missile.FakeCrate:EntIndex()

		local MuzzleVec = missile:GetForward()
		for I = 1,Bomblets do

			timer.Simple(0.01 * I, function()
				if IsValid(missile) then
					Spread = ((missile:GetUp() * (2 * math.random() - 1)) + (missile:GetRight() * (2 * math.random() - 1))) * (I - 1) / 45
					missile.BulletData["Flight"] = (MuzzleVec + (Spread * 2)):GetNormalized() * missile.BulletData["MuzzleVel"] * 39.37 + bdata.Flight

					local MuzzlePos = missile:LocalToWorld(Vector(100 - (I * 20), ((Bomblets / 2) - I) * 2, 0) * 0.5)
					missile.BulletData.Pos = MuzzlePos
					missile.CreateShell = ACF.RoundTypes[missile.BulletData.Type].create
					missile:CreateShell( missile.BulletData )

				end
			end)
		end

		local Radius = missile.BulletData.FillerMass ^ 0.33 * 8 * 39.37 * 2 --Explosion effect radius.
		local Flash = EffectData()
			Flash:SetOrigin( missile:GetPos() )
			Flash:SetNormal( missile:GetForward() )
			Flash:SetRadius( math.max( Radius, 1 ) )
		util.Effect( "ACF_Scaled_Explosion", Flash )

	end


	function this:PerformDetonation( missile, bdata)

		missile:SetNoDraw(true)
		CreateCluster(missile, bdata)

	end
end

function this:GetDisplayConfig()
	return
	{
		["Arming delay"] = math.Round(self.Primer, 3) .. " s",
		["Distance"] = math.Round(self.Cluster / 39.37, 1) .. " m"
	}
end
