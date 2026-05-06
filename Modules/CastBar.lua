local function getAnchorAndPadding()
    if StanceBarFrame and StanceBarFrame:IsShown() and StanceButton1 and StanceButton1:IsShown() then
        return StanceButton1, 16
    end
    if PetActionBarFrame and PetActionBarFrame:IsShown() and PetActionButton1 and PetActionButton1:IsShown() then
        return PetActionButton1, 16
    end
    if MultiBarBottomLeft and MultiBarBottomLeft:IsShown() then
        return MultiBarBottomLeft, 16
    end
    return MainMenuBar, 24
end

local function position()
    if CastingBarFrame.cleanInHook then return end
    CastingBarFrame.cleanInHook = true
    local anchor, padding = getAnchorAndPadding()
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, select(2, anchor:GetCenter()) + anchor:GetHeight() / 2 + padding)
    CastingBarFrame.cleanInHook = false
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PET_BAR_UPDATE")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
f:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
f:SetScript("OnEvent", position)

hooksecurefunc(CastingBarFrame, "SetPoint", position)
