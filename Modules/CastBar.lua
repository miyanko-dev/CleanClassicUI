-- CastingBarFrame: 195 × 13 px (Vanilla/CastingBarFrame.xml).
-- Centered between PlayerFrame and TargetFrame; BOTTOM flush with the unit frames
-- at y=164. Gap to each unit frame edge: ~50 px ((260-116) - (195/2) ≈ 47 px).
local function positionCastBar()
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 164)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", positionCastBar)
