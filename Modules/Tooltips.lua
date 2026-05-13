local SPACING = CleanUI.SPACING
local TOOLTIP_BORDER = CleanUI.BORDER

-- Visible 8px gap between tooltip and the bag button, accounting for both border insets.
local function anchorOffset()
    local bagScale = (CleanUILayout and CleanUILayout.bagScale) or 1
    local bagBorder = CleanUI.BORDER * bagScale
    local x = bagBorder - TOOLTIP_BORDER
    local y = SPACING.SM + bagBorder + TOOLTIP_BORDER
    return x, y
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if tooltip:GetAnchorType() == "ANCHOR_CURSOR" then return end
    if not MainMenuBarBackpackButton then return end
    local x, y = anchorOffset()
    tooltip:ClearAllPoints()
    tooltip:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOPRIGHT", x, y)
end)

CleanUI.HideForever(GameTooltipStatusBar)

local function appendItemLevel(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end
    local level = C_Item.GetDetailedItemLevelInfo(link)
    if not level or level <= 0 then return end
    tooltip:AddLine("Item Level " .. level, 1, 0.82, 0)
end

GameTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
ItemRefTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
