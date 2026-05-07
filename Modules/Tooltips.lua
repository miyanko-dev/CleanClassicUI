local FALLBACK_X = -20
local FALLBACK_Y = 200

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if tooltip:GetAnchorType() == "ANCHOR_CURSOR" then return end
    tooltip:ClearAllPoints()
    if TargetFrame and TargetFrame:IsShown() then
        tooltip:SetPoint("TOPLEFT", TargetFrame, "BOTTOMRIGHT", 0, 0)
    else
        tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", FALLBACK_X, FALLBACK_Y)
    end
end)

GameTooltipStatusBar:Hide()
GameTooltipStatusBar:SetScript("OnShow", GameTooltipStatusBar.Hide)

local function appendItemLevel(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end
    local itemLevel = C_Item.GetDetailedItemLevelInfo(link)
    if not itemLevel or itemLevel <= 0 then return end
    tooltip:AddLine("Item Level " .. itemLevel, 1, 0.82, 0)
end

GameTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
ItemRefTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
