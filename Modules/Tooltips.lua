local anchorX, anchorY

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if tooltip:GetAnchorType() == "ANCHOR_CURSOR" then return end

    local levelText = TargetFrameTextureFrameLevelText
    if not levelText then return end

    local right, bottom = levelText:GetRight(), levelText:GetBottom()
    if right and bottom then
        local scale = levelText:GetEffectiveScale() / UIParent:GetEffectiveScale()
        anchorX, anchorY = right * scale, bottom * scale
    end

    if not anchorX then return end

    tooltip:ClearAllPoints()
    tooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", anchorX + 4, anchorY - 4)
end)

CleanClassicUI.HideForever(GameTooltipStatusBar)

local function appendItemLevel(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end

    local level = C_Item.GetDetailedItemLevelInfo(link)
    if not level or level <= 0 then return end

    tooltip:AddLine("Item Level " .. level, 1, 0.82, 0)
end

GameTooltip:HookScript("OnTooltipSetItem",    appendItemLevel)
ItemRefTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
