
local Material		= {}

Material.id			= "Texto"
Material.name		= "Textolite"
Material.sname		= "Textolite"
Material.desc		= "As known as fiberglass, this chemical material provides a fairly protection agaisnt both kinetic and chemical rounds, including agaisnt explosive rounds, although its mediocre at all."
Material.year		= 1955

Material.massMod		= 0.35
Material.curve		= 0.94

Material.effectiveness	= 0.5
Material.HEATeffectiveness  = 1.2
Material.HEeffectiveness	= 0.9
Material.resiliance		= 0.005
Material.HEATresiliance	= 2
Material.HEresiliance	= 1.3

Material.spallarmor	= 1
Material.spallresist	= 1.5

Material.spallmult	= 1.3
Material.ArmorMul	= 0.23
Material.NormMult	= 0.5

Material.Stopshock	= true

if SERVER then
	function Material.ArmorResolution( Entity, armor, losArmor, losArmorHealth, maxPenetration, FrArea, caliber, _, Type)

		local HitRes = {}

		local curve		= Material.curve
		local effectiveness = Material.effectiveness
		local resiliance	= Material.resiliance

		armor	= armor ^ curve
		losArmor	= losArmor ^ curve

		if Type == "HEAT" or Type == "THEAT" or Type == "HEATFS" or Type == "THEATFS" then

			local HEATeffectiveness = Material.HEATeffectiveness
			local HEATresiliance = Material.HEATresiliance

			-- Breach probability
			local breachProb = math.Clamp((caliber / Entity.ACF.Armour / HEATeffectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / HEATeffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;

			if breachProb > math.random() and maxPenetration > armor * HEATeffectiveness then			-- Breach chance roll

				HitRes.Damage	= FrArea / HEATresiliance						-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor * HEATeffectiveness						-- Remaining penetration
				HitRes.Loss	= armor * HEATeffectiveness / maxPenetration						-- Energy loss in percents

				return HitRes

			-- Penetration chance roll
			elseif penProb > math.random() then

				local Penetration = math.min( maxPenetration, losArmor * HEATeffectiveness )

				HitRes.Damage	= ( Penetration / losArmorHealth / HEATeffectiveness ) ^ 2 * FrArea / HEATresiliance
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss	= Penetration / maxPenetration

				return HitRes

			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * HEATeffectiveness )

			HitRes.Damage	= ( Penetration / losArmor / HEATeffectiveness ) ^ 2 * FrArea / HEATresiliance
			HitRes.Overkill = 0
			HitRes.Loss	= 1

			return HitRes

		elseif Type == "HE" or Type == "Spall" or Type == "HESH" then

			local HEeffectiveness = Material.HEeffectiveness
			local HEresiliance = Material.HEresiliance

			-- Breach probability
			local breachProb = math.Clamp((caliber / Entity.ACF.Armour / HEeffectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / HEeffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;

			-- Breach chance roll
			if breachProb > math.random() and maxPenetration > armor then

				HitRes.Damage	= FrArea / HEresiliance						-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss	= armor / maxPenetration						-- Energy loss in percents

				return HitRes

			-- Penetration chance roll
			elseif penProb > math.random() then

				local Penetration = math.min( maxPenetration, losArmor * HEeffectiveness )

				HitRes.Damage	= ( Penetration / losArmorHealth / HEeffectiveness ) ^ 2 * FrArea / HEresiliance
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss	= Penetration / maxPenetration

				return HitRes

			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * HEeffectiveness )

			HitRes.Damage	= ( Penetration / losArmorHealth / HEeffectiveness ) ^ 2 * FrArea / HEresiliance
			HitRes.Overkill = 0
			HitRes.Loss	= 1

			return HitRes

		else

			-- Breach probability
			local breachProb = math.Clamp((caliber / Entity.ACF.Armour * effectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;

			if breachProb > math.random() and maxPenetration > armor then			-- Breach chance roll

	--		print("RubberBreach")
				HitRes.Damage	= FrArea / resiliance							-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss	= armor / maxPenetration						-- Energy loss in percents
	--			print("DmgBreach: " .. HitRes.Damage)

				return HitRes

			elseif penProb > math.random() then								-- Penetration chance roll

	--		print("RubberBreach")
				local Penetration = math.min( maxPenetration, losArmor * effectiveness )
				HitRes.Damage	= ( Penetration / losArmorHealth * effectiveness) ^ 2 * FrArea / resiliance
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss	= Penetration / maxPenetration
	--		print("DmgPen: " .. HitRes.Damage)

				return HitRes

			end

	--		print("NoBreach")
			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * effectiveness )

			HitRes.Damage	= ( Penetration / losArmorHealth * effectiveness ) ^ 2 * FrArea / resiliance
			HitRes.Overkill = 0
			HitRes.Loss	= 1
	--		print("DmgNoPen: " .. HitRes.Damage)
			return HitRes

		end

	end
end

list.Set( "ACE_MaterialTypes", Material.id, Material )
