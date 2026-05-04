-- Detach the player cast bar from PlayerFrame and center it above the action bars.
-- No visual changes — the default Blizzard appearance is preserved.
local function positionCastBar()
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 234)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", positionCastBar)
