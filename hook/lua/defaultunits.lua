local oldACUUnit = ACUUnit

---@class ACUUnit : Unit
ACUUnit = Class(oldACUUnit) {
    updateBuildRestrictions = function(self)
        local aiBrain = self.AIBrain
        local factionCategory = categories[string.upper(__blueprints[self.UnitId].General.FactionName)]
        -- Sanity check.
        if not factionCategory then
            return
        end
        self:AddBuildRestriction(categories.SUPPORTFACTORY)

        local upgradeNames = {
            'ImprovedEngineering',
            'CombatEngineering',
            'AdvancedEngineering',
            'ExperimentalEngineering',
            'AssaultEngineering',
            'ApocalypticEngineering'
        }

        -- Check for the existence of HQs
        for _, researchType in ipairs({categories.LAND, categories.AIR, categories.NAVAL}) do
            -- If there is a research station of the appropriate type, enable support factory construction
            for _, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH2 * factionCategory * researchType, false, true) do
                if not unit.Dead and not unit:IsBeingBuilt() then
                    for _, title in upgradeNames do
                        if self:HasEnhancement(title) then
                            self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * factionCategory * researchType)
                            break
                        end
                    end
                    break
                end
            end
            for _, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH3 * factionCategory * researchType, false, true) do
                if not unit.Dead and not unit:IsBeingBuilt() then
                    -- Special case for the commander, since its engineering upgrades are implemented using build restrictions
                    for key, title in upgradeNames do
                        if key <= 2 and self:HasEnhancement(title) then
                            self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * factionCategory * researchType)
                        elseif key > 2 and self:HasEnhancement(title) then
                            self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * factionCategory * researchType)
                            self:RemoveBuildRestriction(categories.TECH3 * categories.SUPPORTFACTORY * factionCategory * researchType)
                            break
                        end
                    end
                    break
                end
            end
        end
    end,
}
