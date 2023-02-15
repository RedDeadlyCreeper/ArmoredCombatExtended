
local Material		= {}

Material.id			= "Alum"
Material.name		= "Aluminum"
Material.sname		= "Aluminum"
Material.desc		= "The aluminum is normally used by AFVs or light constructions, due to its low cost and realible armor effectiveness, but its extremely vulnerable to spalling and its really worthless for heavy applications."
Material.year		= 1955

Material.massMod		= 0.221
Material.curve		= 0.93

Material.effectiveness  = 0.34
Material.resiliance	= 0.95
Material.HEATMul		= 80

Material.spallarmor	= 1
Material.spallresist	= 1.5

Material.spallmult	= 2
Material.ArmorMul	= 0.334
Material.NormMult	= 0.7

if SERVER then
	function Material.ArmorResolution( _, armor, losArmor, losArmorHealth, maxPenetration, FrArea, caliber, damageMult, Type)

		local HitRes = {}

		local curve		= Material.curve
		local effectiveness = Material.effectiveness
		local resiliance	= Material.resiliance

		armor = armor ^ curve
		losArmor = losArmor ^ curve

		local DamageModifier = 1

		if Type == "Spall" then

			DamageModifier = Material.spallresist

		elseif Type == "HEAT" or Type == "THEAT" or Type == "HEATFS" or Type == "THEATFS" then

			DamageModifier = Material.HEATMul

		end

		-- Breach probability
		local breachProb = math.Clamp((caliber / armor / effectiveness - 1.3) / (7 - 1.3), 0, 1)

		-- Penetration probability
		local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * ( maxPenetration / losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;

		if breachProb > math.random() and maxPenetration > armor then			-- Breach chance roll

			HitRes.Damage	= FrArea / resiliance * DamageModifier * damageMult						-- Inflicted Damage
			HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
			HitRes.Loss	= armor / maxPenetration						-- Energy loss in percents

			return HitRes

		-- Penetration chance roll
		elseif penProb > math.random() then

			local Penetration = math.min( maxPenetration, losArmor * effectiveness )

			HitRes.Damage	= (( Penetration / losArmorHealth / effectiveness ) ^ 2 * FrArea * DamageModifier * damageMult ) / resiliance
			HitRes.Overkill = (maxPenetration - Penetration)
			HitRes.Loss	= Penetration / maxPenetration

			return HitRes

		end

		-- Projectile did not breach nor penetrate armor
		local Penetration = math.min( maxPenetration , losArmor * effectiveness)

		HitRes.Damage	= (( Penetration / losArmorHealth / effectiveness ) ^ 2 * FrArea * DamageModifier * damageMult ) / resiliance
		HitRes.Overkill = 0
		HitRes.Loss	= 1

		return HitRes

	end
end

list.Set( "ACE_MaterialTypes", Material.id, Material )
