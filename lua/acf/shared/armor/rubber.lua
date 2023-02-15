
local Material		= {}

Material.id			= "Rub"
Material.name		= "Rubber"
Material.sname		= "Rubber"
Material.desc		= "Another Material, that while its totally useless agaisnt kinetic rounds, excels agaisnt shaped charges like HEAT"
Material.year		= 1955

Material.massMod		= 0.2
Material.curve		= 0.95

Material.specialeffect  = 30

Material.effectiveness  = 0.02
Material.HEATeffectiveness = 3
Material.resiliance	= 0.25
Material.HEATresiliance = 0.3
Material.HEresiliance	= 0.3
Material.Catchresiliance = 0.25

Material.spallarmor	= 2
Material.spallresist	= 3.5

Material.spallmult	= 0.01
Material.ArmorMul	= 0.01
Material.NormMult	= 0.05

Material.Stopshock	= true

if SERVER then
	function Material.ArmorResolution( _, armor, losArmor, losArmorHealth, maxPenetration, FrArea, caliber, damageMult, Type)

		local HitRes = {}

		local curve		= Material.curve
		local effectiveness = Material.effectiveness
		local resiliance	= Material.resiliance

		armor	= armor ^ curve
		losArmor	= losArmor ^ curve

		--=========================================================================================================\
		--------------------------------------------------------- For HEAT shells & Spall -------------------------->
		--=========================================================================================================/
		if Type == "HEAT" or Type == "THEAT" or Type == "HEATFS" or Type == "THEATFS" or Type == "Spall" then

			local specialeffect		= Material.specialeffect
			local specialeffectiveness  = Material.HEATeffectiveness
			local specialresiliance	= Material.HEATresiliance

			local spallresist = Material.spallresist

			if Type == "Spall" then
				specialeffectiveness = specialeffectiveness * spallresist
			end

			local DmgResist = 0.01 + math.min(caliber * 10 / specialeffect, 5) * 6

			-- Breach probability
			local breachProb = math.Clamp((caliber / armor / specialeffectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * ( maxPenetration / losArmor / specialeffectiveness - 1 ))), 0.0015, 0.9985) - 0.0015) / 0.997;

			-- Breach chance roll
			if breachProb > math.random() and maxPenetration > armor then

				HitRes.Damage	= FrArea / specialresiliance * damageMult		-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor											-- Remaining penetration
				HitRes.Loss	= armor / maxPenetration											-- Energy loss in percents

				return HitRes

			-- Penetration chance roll
			elseif penProb > math.random() then

				local Penetration = math.min( maxPenetration, losArmor * specialeffectiveness )

				HitRes.Damage = (Penetration / losArmorHealth / specialeffectiveness) ^ 2 * FrArea / specialresiliance * DmgResist * damageMult
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss	= Penetration / maxPenetration

				return HitRes

			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * specialeffectiveness )

			HitRes.Damage	= ( Penetration / losArmor / specialeffectiveness ) ^ 2 * FrArea / specialresiliance * DmgResist * damageMult
			HitRes.Overkill = 0
			HitRes.Loss	= 1

			return HitRes
		--===============================================================================================\
		--------------------------------------------------------- For HE shells -------------------------->
		--===============================================================================================/
		elseif Type == "HE" then
			--print("spalling2!!!")
			--print(Type)

			local specialeffectiveness = Material.HEATeffectiveness
			local HEresiliance = Material.HEresiliance

			-- Breach probability
			local breachProb = math.Clamp((caliber / armor / HEresiliance - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / specialeffectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997

			-- Breach chance roll
			if breachProb > math.random() and maxPenetration > armor then

				HitRes.Damage	= FrArea / HEresiliance  * damageMult	-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor							-- Remaining penetration
				HitRes.Loss	= armor / maxPenetration							-- Energy loss in percents

				return HitRes

			-- Penetration chance roll
			elseif penProb > math.random() then

				local Penetration = math.min( maxPenetration, losArmor * specialeffectiveness )

				HitRes.Damage	= ( Penetration / losArmorHealth / specialeffectiveness ) ^ 2 * FrArea / HEresiliance * damageMult
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss	= Penetration / maxPenetration

				return HitRes

			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * specialeffectiveness )

			HitRes.Damage	= ( Penetration / losArmorHealth / specialeffectiveness ) ^ 2 * FrArea / HEresiliance * damageMult
			HitRes.Overkill = 0
			HitRes.Loss	= 1

			return HitRes

		--===============================================================================================\
		--------------------------------------------------------- For AP shells -------------------------->
		--===============================================================================================/
		else

			local Catchresiliance = Material.Catchresiliance

			-- Breach probability
			local breachProb = math.Clamp((caliber / armor / effectiveness - 1.3) / (7 - 1.3), 0, 1)

			-- Penetration probability
			local penProb = (math.Clamp(1 / (1 + math.exp(-43.9445 * (maxPenetration / losArmor / effectiveness - 1))), 0.0015, 0.9985) - 0.0015) / 0.997;

			-- Breach chance roll
			if breachProb > math.random() and maxPenetration > armor then

				HitRes.Damage	= FrArea / resiliance * damageMult						-- Inflicted Damage
				HitRes.Overkill = maxPenetration - armor						-- Remaining penetration
				HitRes.Loss	= armor / maxPenetration						-- Energy loss in percents

				return HitRes

			-- Penetration chance roll
			elseif penProb > math.random() then

				local Penetration = math.min( maxPenetration, losArmor * effectiveness )

				HitRes.Damage	= ( Penetration / losArmorHealth * effectiveness ) ^ 2 * FrArea / resiliance * damageMult
				HitRes.Overkill = (maxPenetration - Penetration)
				HitRes.Loss	= Penetration / maxPenetration

				--print('Damage applied: ' .. HitRes.Damage)
				return HitRes

			end

			-- Projectile did not breach nor penetrate armor
			local Penetration = math.min( maxPenetration , losArmor * effectiveness )

			HitRes.Damage	= ( Penetration / losArmorHealth * effectiveness ) ^ 2 * FrArea / Catchresiliance * damageMult
			HitRes.Overkill = 0
			HitRes.Loss	= 1

			return HitRes

		end

	end
end

list.Set( "ACE_MaterialTypes", Material.id, Material )
