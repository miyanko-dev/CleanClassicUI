hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if tooltip:GetAnchorType() == "ANCHOR_CURSOR" then return end
    tooltip:ClearAllPoints()
    tooltip:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOPRIGHT", 0, 8)
end)

GameTooltipStatusBar:Hide()
GameTooltipStatusBar:SetScript("OnShow", GameTooltipStatusBar.Hide)

local function appendItemLevel(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end
    local level = C_Item.GetDetailedItemLevelInfo(link)
    if not level or level <= 0 then return end
    tooltip:AddLine("Item Level " .. level, 1, 0.82, 0)
end

GameTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
ItemRefTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
