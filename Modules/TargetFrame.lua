-- TargetFrame: 232 × 100 px (Vanilla/TargetFrame.xml) — same size as PlayerFrame,
-- internally mirrored (portrait on the right). BOTTOM anchor at x=+260, y=164.
-- Re-anchored on PLAYER_TARGET_CHANGED because Blizzard calls
-- UIParent_UpdateTopFramePositions() on each target change.
local function positionTargetFrame()
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 260, 164)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", positionTargetFrame)
