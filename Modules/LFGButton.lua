-- Detach the LFG button from the minimap and place it next to the micro menu
local function positionLFGButton()
    if LFGMinimapFrameBorder then
        LFGMinimapFrameBorder:Hide()
    end

    if LFGMinimapFrame then
        LFGMinimapFrame:SetParent(UIParent)
        LFGMinimapFrame:ClearAllPoints()
        LFGMinimapFrame:SetSize(36, 36)
        LFGMinimapFrame:SetPoint("RIGHT", CharacterMicroButton, "LEFT", -4, -12)
    end

    if LFGMinimapFrameIcon then
        LFGMinimapFrameIcon:SetSize(40, 40)
        LFGMinimapFrameIcon:SetPoint("CENTER", LFGMinimapFrame, "CENTER", 0, 0)
    end
end

local lfgFrame = CreateFrame("Frame")
lfgFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
lfgFrame:SetScript("OnEvent", positionLFGButton)
