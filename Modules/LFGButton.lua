local function position()
    if LFGMinimapFrameBorder then LFGMinimapFrameBorder:Hide() end
    if not LFGMinimapFrame then return end

    LFGMinimapFrame:SetParent(UIParent)
    LFGMinimapFrame:ClearAllPoints()
    LFGMinimapFrame:SetSize(36, 36)
    LFGMinimapFrame:SetPoint("RIGHT", CharacterMicroButton, "LEFT", -4, -12)

    if LFGMinimapFrameIcon then
        LFGMinimapFrameIcon:SetSize(40, 40)
        LFGMinimapFrameIcon:SetPoint("CENTER")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", position)
