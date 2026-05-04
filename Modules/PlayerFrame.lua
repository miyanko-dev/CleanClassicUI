-- Move PlayerFrame to the bottom-left area without altering its default appearance.
-- Mirrors the TargetFrame position on the opposite side of the screen.
local function positionPlayerFrame()
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", -280, 180)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", positionPlayerFrame)
