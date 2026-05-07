local SCREEN_PADDING = 24
local BUTTON_OVERLAP = -3

local anchor = CreateFrame("Frame", "CleanUIMicroMenu", UIParent)
anchor:SetSize(1, 1)
anchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -SCREEN_PADDING, SCREEN_PADDING)

local function reposition()
    if InCombatLockdown() then return end
    local first = CharacterMicroButton
    if not first then return end

    local count = 0
    for _, name in ipairs(MICRO_BUTTONS) do
        local btn = _G[name]
        if btn and btn:IsShown() then count = count + 1 end
    end
    if count == 0 then return end

    local width = first:GetWidth() or 28
    local height = first:GetHeight() or 58
    anchor:SetSize(count * width + (count - 1) * BUTTON_OVERLAP, height)

    UpdateMicroButtonsParent(anchor)
    first:ClearAllPoints()
    first:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0)
end

hooksecurefunc("MoveMicroButtons", function()
    C_Timer.After(0, reposition)
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:SetScript("OnEvent", function()
    C_Timer.After(0, reposition)
end)
