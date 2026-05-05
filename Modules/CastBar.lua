local PADDING = 20

local function getAnchor()
    if StanceBarFrame and StanceBarFrame:IsShown() and StanceButton1:IsShown() then
        return StanceButton1
    end
    if PetActionBarFrame and PetActionBarFrame:IsShown() and PetActionButton1:IsShown() then
        return PetActionButton1
    end
    if MultiBarBottomLeft:IsShown() then
        return MultiBarBottomLeft
    end
    return MainMenuBar
end

local function position()
    if InCombatLockdown() then return end
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", getAnchor(), "TOP", 0, PADDING)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("PET_BAR_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", position)
