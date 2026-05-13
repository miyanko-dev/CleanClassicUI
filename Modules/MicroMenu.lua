local MARGIN = CleanUI.SPACING.LG
local BTN_OVERLAP = -3

local isActive = false

local function shownCount()
    local count = 0
    for _, name in ipairs(MICRO_BUTTONS) do
        local btn = _G[name]
        if btn and btn:IsShown() then count = count + 1 end
    end
    return count
end

-- UpdateMicroButtonsParent reparents all protected micro buttons and propagates taint widely.
-- Move CharacterMicroButton only so the row anchors bottom-right while buttons keep their parent.
local function reposition()
    if InCombatLockdown() or isActive then return end
    local first = CharacterMicroButton
    if not first then return end

    local count = shownCount()
    if count == 0 then return end
    local btnWidth = first:GetWidth() or 28
    local totalWidth = count * btnWidth + (count - 1) * BTN_OVERLAP

    isActive = true
    first:ClearAllPoints()
    first:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -MARGIN - (totalWidth - btnWidth), MARGIN)
    isActive = false
end

hooksecurefunc("MoveMicroButtons", reposition)

CleanUI.OnEvent(reposition,
    "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED")
