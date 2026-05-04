-- Anchor non-cursor tooltips so they open at the TargetFrame's top-left corner,
-- spanning naturally toward the bottom-right of that region.
local function updateTooltipAnchor(tooltipFrame)
    if tooltipFrame:GetAnchorType() == "ANCHOR_CURSOR" then return end
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", 0, 0)
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", updateTooltipAnchor)

-- Hide the health bar shown inside tooltips
GameTooltipStatusBar:Hide()
GameTooltipStatusBar:SetScript("OnShow", function(self) self:Hide() end)
