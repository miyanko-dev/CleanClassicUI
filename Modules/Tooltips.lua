local SPACING = CleanUI.SPACING
local BORDER = CleanUI.BORDER

-- Anchor tooltip BOTTOMRIGHT so its border sits SPACING.XS inside Container 1's
-- border on both the right and bottom edges, giving a uniform corner margin.
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if tooltip:GetAnchorType() == "ANCHOR_CURSOR" then return end
    if not MainMenuBarBackpackButton then return end
    tooltip:ClearAllPoints()
    tooltip:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOPRIGHT", 0, SPACING.SM)
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
