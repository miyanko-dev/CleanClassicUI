local BTN_SIZE = 36
local ICON_SIZE = 40
local OFFSET_X = -4
local OFFSET_Y = -12

local function place()
    if LFGMinimapFrameBorder then LFGMinimapFrameBorder:Hide() end
    if not LFGMinimapFrame then return end

    LFGMinimapFrame:SetParent(UIParent)
    LFGMinimapFrame:ClearAllPoints()
    LFGMinimapFrame:SetSize(BTN_SIZE, BTN_SIZE)
    LFGMinimapFrame:SetPoint("RIGHT", CharacterMicroButton, "LEFT", OFFSET_X, OFFSET_Y)

    if LFGMinimapFrameIcon then
        LFGMinimapFrameIcon:SetSize(ICON_SIZE, ICON_SIZE)
        LFGMinimapFrameIcon:SetPoint("CENTER")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:SetScript("OnEvent", function()
    C_Timer.After(0, place)
end)
