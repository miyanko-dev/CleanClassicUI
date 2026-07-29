-- Footprint and default spot mirror retail's GameTooltipDefaultContainer.
local mover = CleanClassicExperience.CreateMover("Tooltip", "tooltipAnchor", 250, 150)
mover:SetPoint("BOTTOMRIGHT", -9, 85)

-- Blizzard forces ANCHOR_NONE before this hook runs, so anchoring to the hidden mover is safe.
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if not mover:SavedPosition() then return end
    tooltip:ClearAllPoints()
    tooltip:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT")
end)

CleanClassicExperience.HideForever(GameTooltipStatusBar)

local function appendItemLevel(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end

    local level = C_Item.GetDetailedItemLevelInfo(link)
    if not level or level <= 0 then return end

    tooltip:AddLine("Item Level " .. level, 1, 0.82, 0)
end

GameTooltip:HookScript("OnTooltipSetItem",    appendItemLevel)
ItemRefTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
