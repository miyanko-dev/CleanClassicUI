-- PlayerFrame: 232 × 100 px (Classic/PlayerFrame.xml).
-- BOTTOM anchor at x=-260, y=164 — symmetric with TargetFrame, bottoms flush,
-- ~10 px clearance above the MultiBarBottomLeft top edge (~y=154).
local function positionPlayerFrame()
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", -260, 164)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", positionPlayerFrame)
