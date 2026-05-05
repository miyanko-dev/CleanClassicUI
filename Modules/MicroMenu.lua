local PADDING = 20

local anchor = CreateFrame("Frame", "CleanUIMicroMenu", UIParent)
anchor:SetSize(1, 1)
anchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -PADDING, PADDING)

local function reposition()
    if InCombatLockdown() then return end
    local first = CharacterMicroButton
    if not first then return end

    local count = 0
    for _, name in ipairs(MICRO_BUTTONS) do
        local btn = _G[name]
        if btn and btn:IsShown() then
            count = count + 1
        end
    end
    if count == 0 then return end

    local w = first:GetWidth() or 28
    local h = first:GetHeight() or 58
    anchor:SetSize(count * w + (count - 1) * -3, h)

    UpdateMicroButtonsParent(anchor)
    first:ClearAllPoints()
    first:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0)
end

hooksecurefunc("MoveMicroButtons", function()
    C_Timer.After(0, reposition)
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UI_SCALE_CHANGED")
f:RegisterEvent("DISPLAY_SIZE_CHANGED")
f:SetScript("OnEvent", function()
    C_Timer.After(0, reposition)
end)
