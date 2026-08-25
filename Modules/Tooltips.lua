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

-- Nothing native caps tooltip width, so wrap the long lines instead of letting the frame grow sideways.
local MAX_WIDTH = 240
local TEXT_INSET, PAIR_GAP = 20, 8

local wrapped = {}

local function capWidth(tooltip)
    -- A tooltip is as wide as its widest line, so nothing can overflow while the frame itself fits.
    if not tooltip.default or tooltip:GetWidth() <= MAX_WIDTH then return end

    local didWrap = false

    for i = 1, tooltip:NumLines() do
        local left  = _G["GameTooltipTextLeft" .. i]
        local right = _G["GameTooltipTextRight" .. i]

        -- A pair shares one line, so the left half only gets the room the right half leaves.
        local room = MAX_WIDTH - TEXT_INSET
        if right and right:IsShown() then
            room = room - right:GetStringWidth() - PAIR_GAP
        end

        if not left.cleanWrapped and room > 0 and left:GetStringWidth() > room then
            left:SetWordWrap(true)
            left:SetWidth(room)
            left.cleanWrapped = true
            wrapped[#wrapped + 1] = left
            didWrap = true
        end
    end

    -- The engine sized the frame before the wrap; re-showing runs its layout again and restores the bottom padding.
    if didWrap then tooltip:Show() end
end

-- Populating a tooltip always resizes it, so this fires exactly when there is new text to measure.
GameTooltip:HookScript("OnSizeChanged", capWidth)

-- These font strings are reused for every tooltip, so hand back the ones this actually took.
GameTooltip:HookScript("OnTooltipCleared", function()
    for i = #wrapped, 1, -1 do
        wrapped[i]:SetWidth(0)
        wrapped[i].cleanWrapped = nil
        wrapped[i] = nil
    end
end)

local function appendItemLevel(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end

    local level = C_Item.GetDetailedItemLevelInfo(link)
    if not level or level <= 0 then return end

    tooltip:AddLine("Item Level " .. level, 1, 0.82, 0)
end

GameTooltip:HookScript("OnTooltipSetItem",    appendItemLevel)
ItemRefTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
