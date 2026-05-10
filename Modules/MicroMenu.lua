local MARGIN = 24
local BTN_OVERLAP = -3

local anchor = CreateFrame("Frame", "CleanUIMicroMenu", UIParent)
anchor:SetSize(1, 1)
anchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -MARGIN, MARGIN)

local active = false
local pending = false

local function reposition()
    pending = false
    if InCombatLockdown() or active then return end
    local first = CharacterMicroButton
    if not first then return end

    local count = 0
    for _, name in ipairs(MICRO_BUTTONS) do
        local btn = _G[name]
        if btn and btn:IsShown() then count = count + 1 end
    end

    if count == 0 then
        C_Timer.After(0.1, reposition)
        return
    end

    active = true
    local w = first:GetWidth() or 28
    local h = first:GetHeight() or 58
    anchor:SetSize(count * w + (count - 1) * BTN_OVERLAP, h)

    UpdateMicroButtonsParent(anchor)
    first:ClearAllPoints()
    first:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0)
    active = false
end

local function schedule()
    if pending or active then return end
    pending = true
    C_Timer.After(0, reposition)
end

hooksecurefunc("MoveMicroButtons", schedule)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:SetScript("OnEvent", schedule)
