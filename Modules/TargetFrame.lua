-- Move TargetFrame to the bottom-right area without altering its default appearance.
-- Re-anchors on PLAYER_TARGET_CHANGED because Blizzard resets the position when
-- the target changes (show/hide cycle moves the frame back to its default point).
local function positionTargetFrame()
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 280, 180)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", positionTargetFrame)
