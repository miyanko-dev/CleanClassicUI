local BTN_SIZE = CleanClassicExperience.BTN_SIZE
local ICON_SIZE = 40
local OFFSET_X  = -4
local OFFSET_Y  = -12

local function placeButton()
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

CleanClassicExperience.OnEvent(function()
    C_Timer.After(0, placeButton)
end, "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED")
