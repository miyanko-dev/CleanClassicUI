hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if tooltip:GetAnchorType() == "ANCHOR_CURSOR" then return end
    tooltip:ClearAllPoints()
    tooltip:SetPoint("TOPLEFT", TargetFrame, "BOTTOMRIGHT",0 , 0)
end)

GameTooltipStatusBar:Hide()
GameTooltipStatusBar:SetScript("OnShow", GameTooltipStatusBar.Hide)
