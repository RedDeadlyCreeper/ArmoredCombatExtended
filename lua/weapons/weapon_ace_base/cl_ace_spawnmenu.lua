AddCSLuaFile()

if SERVER then return end

local function createSpawnIcon(w, propPanel)
	return spawnmenu.CreateContentIcon(w.ScriptedEntityType or "weapon", propPanel, {
		nicename = w.PrintName or w.ClassName,
		spawnname = w.ClassName,
		material = w.IconOverride or "entities/" .. w.ClassName .. ".png",
		admin = w.AdminOnly
	})
end

hook.Add("PopulateWeapons", "AddWeaponContentACESweps", function(pnlContent, tree)
	local weaponsList = list.Get("Weapon")
	local ACEWeapons = {}

	--look into every weapon and see if they're from ACE
	for _, weapon in pairs(weaponsList) do
		if (weapons.IsBasedOn(weapon.ClassName, "weapon_ace_base")) then
			if (ACEWeapons[weapon.Category] == nil) then
				ACEWeapons[weapon.Category] = {}
			end

			--keep them for later if so
			table.insert(ACEWeapons[weapon.Category], weapon)
		end
	end

	--loop through all weapon categories
	for _, categoryNode in pairs(tree:Root():GetChildNodes()) do
		--if the text matches the categories we saved before we replace DoPopulate
		if not ACEWeapons[categoryNode:GetText()] then continue end

		local manifest = {
			["Other"] = {} --default header
		}

		--order them by subcategory
		for _, weapon in pairs(ACEWeapons[categoryNode:GetText()]) do
			--get weapon from storeds
			local actualWeapon = weapons.Get(weapon.ClassName)

			if (actualWeapon.SubCategory == nil) then
				table.insert(manifest["Other"], weapon)
			else
				if (manifest[actualWeapon.SubCategory] == nil) then
					manifest[actualWeapon.SubCategory] = {}
				end
				table.insert(manifest[actualWeapon.SubCategory], weapon)
			end
		end

		categoryNode.DoPopulate = function(self)
			-- If we've already populated it - forget it.
			if (self.PropPanel) then return end

			-- Create the container panel
			self.PropPanel = vgui.Create("ContentContainer", pnlContent)
			self.PropPanel:SetVisible(false)
			self.PropPanel:SetTriggerSpawnlistChange(false)

			for categoryName, weps in SortedPairs(manifest) do
				if (#weps <= 0) then
					continue
				end

				--create header
				local label = vgui.Create("ContentHeader", container)
				label:SetText(categoryName)

				self.PropPanel:Add(label)

				--this is copy from gmod
				for _, ent in SortedPairsByMemberValue(weps, "PrintName") do
					local icon = createSpawnIcon(ent, self.PropPanel)
					local oldPaint = icon.Paint
					local we = weapons.Get(ent.ClassName)
					local bPossibleBlueprint = we.Base ~= "weapon_ace_base"

					if (bPossibleBlueprint) then
						icon.DoClick = function()
							RunConsoleCommand("gm_giveswep", ent.ClassName)
						end
					end

					icon.Paint = function(self, aWide, aTall)
						if (bPossibleBlueprint) then
							blueprintIconPaint(self, aWide, aTall)
						end
						oldPaint(self, aWide, aTall)
					end

					local oldMenuExtra = icon.OpenMenuExtra
					icon.OpenMenuExtra = function(icon, menu)
						oldMenuExtra(icon, menu)
						local weaponsBasedOnMe = {}

						--blueprints
						for _, w in pairs(weaponsList) do
							if (weapons.IsBasedOn(w.ClassName, ent.ClassName)) then
								weaponsBasedOnMe[#weaponsBasedOnMe + 1] = w
							end
						end

						if (#weaponsBasedOnMe > 0) then
							menu:AddSpacer()

							local grid = vgui.Create("DGrid")
							grid:SetCols(math.min(#weaponsBasedOnMe, 3))
							grid:SetColWide(icon:GetWide())
							grid:SetRowHeight(icon:GetTall())

							for _, w in pairs(weaponsBasedOnMe) do
								local subIcon = createSpawnIcon(w, menu)
								local oldPaint = subIcon.Paint
								subIcon.Paint = function(self, aWide, aTall)
									blueprintIconPaint(self, aWide, aTall)
									oldPaint(self, aWide, aTall)
								end

								subIcon.DoClick = function()
									RunConsoleCommand("gm_giveswep", w.ClassName)
								end

								subIcon.DoRightClick = function() end

								grid:AddItem(subIcon)
							end

							menu:AddPanel(grid)
						end
					end
				end
			end
		end
	end
end)
