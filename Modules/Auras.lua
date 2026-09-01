-- Edit Mode owns the aura layout; restyle the buttons with dispel-colored borders, exact minutes, and a timer margin.
if not (BuffFrame and BuffFrame.auraFrames and DebuffFrame) then return end

local COLOR = CleanClassicUI.COLOR

local DEBUFF_COLORS = {
    Poison  = COLOR.GREEN,
    Magic   = COLOR.BLUE,
    Curse   = COLOR.VIOLET,
    Disease = COLOR.ORANGE,
}

local AURA_COLORS = {
    Buff         = COLOR.GREY,
    TempEnchant  = COLOR.BLUE,
    DeadlyDebuff = COLOR.RED,
}

-- Edit Mode example auras carry only an auraType; cycle the dispel colors so the preview matches live debuffs.
local EXAMPLE_DEBUFF_COLORS = { COLOR.BLUE, COLOR.VIOLET, COLOR.ORANGE, COLOR.GREEN, COLOR.RED }

local function borderColor(btn, exampleIndex)
    if btn.isExample then
        if btn.auraType == "Debuff" then
            return EXAMPLE_DEBUFF_COLORS[(exampleIndex - 1) % #EXAMPLE_DEBUFF_COLORS + 1]
        end
        return AURA_COLORS[btn.auraType] or COLOR.GREY
    end
    if btn.buttonInfo.auraType == "Debuff" then
        return DEBUFF_COLORS[btn.buttonInfo.debuffType] or COLOR.RED
    end
    return AURA_COLORS[btn.buttonInfo.auraType] or COLOR.GREY
end

-- Blizzard abbreviates past 90 minutes to whole hours; UpdateDuration runs every tick, so the rewrite sticks.
local function hookDuration(btn)
    if btn.cleanDurationHooked then return end
    btn.cleanDurationHooked = true
    hooksecurefunc(btn, "UpdateDuration", function(self, timeLeft)
        if not (self.Duration and timeLeft) then return end
        if timeLeft >= 3600 and timeLeft < 86400 then
            self.Duration:SetFormattedText(MINUTE_ONELETTER_ABBR, math.ceil(timeLeft / 60))
        end
        self.Duration:SetVertexColor(1, 1, 1)
    end)
end

local function styleButton(btn, color)
    -- Wrap only the 30x30 Icon so the timer in the button's bottom strip sits outside the border.
    local border = CleanClassicUI.StyleButton(btn, btn.Icon)
    if border then border:SetBackdropBorderColor(unpack(color)) end

    -- Edit Mode examples never run the UpdateDuration hook, so whiten here as well.
    if btn.Duration then btn.Duration:SetVertexColor(1, 1, 1) end

    -- Blizzard re-shows these native overlays on every update; ours replaces them.
    if btn.DebuffBorder then btn.DebuffBorder:Hide() end
    if btn.TempEnchantBorder then btn.TempEnchantBorder:Hide() end
end

-- UpdateGridLayout re-anchors every Duration flush against the icon, so re-apply the margin afterwards.
local DURATION_MARGIN = CleanClassicUI.SPACING[4]

local function offsetDurations(container, auras)
    local point, relativePoint, x, y
    if container.isHorizontal then
        if container.addIconsToTop then
            point, relativePoint, x, y = "BOTTOM", "TOP", 0, DURATION_MARGIN
        else
            point, relativePoint, x, y = "TOP", "BOTTOM", 0, -DURATION_MARGIN
        end
    else
        if container.addIconsToRight then
            point, relativePoint, x, y = "LEFT", "RIGHT", DURATION_MARGIN, 0
        else
            point, relativePoint, x, y = "RIGHT", "LEFT", -DURATION_MARGIN, 0
        end
    end
    for _, btn in ipairs(auras or {}) do
        if btn.Duration and btn.Icon then
            btn.Duration:ClearAllPoints()
            btn.Duration:SetPoint(point, btn.Icon, relativePoint, x, y)
        end
    end
end

local function styleAuraFrame(auraFrame)
    local exampleIndex = 0
    for _, btn in ipairs(auraFrame.auraFrames) do
        if not btn.isAuraAnchor then
            hookDuration(btn)
            if btn.isExample then
                exampleIndex = exampleIndex + 1
                styleButton(btn, borderColor(btn, exampleIndex))
            elseif btn.buttonInfo then
                styleButton(btn, borderColor(btn))
            end
        end
    end
end

hooksecurefunc(BuffFrame, "UpdateAuraButtons", styleAuraFrame)
hooksecurefunc(DebuffFrame, "UpdateAuraButtons", styleAuraFrame)

-- The icon-size setting lands as a per-button SetScale inside UpdateGridLayout without an UpdateAuraButtons pass.
hooksecurefunc(BuffFrame, "UpdateGridLayout", styleAuraFrame)
hooksecurefunc(DebuffFrame, "UpdateGridLayout", styleAuraFrame)
hooksecurefunc(BuffFrame.AuraContainer, "UpdateGridLayout", offsetDurations)
hooksecurefunc(DebuffFrame.AuraContainer, "UpdateGridLayout", offsetDurations)

CleanClassicUI.OnEvent(function()
    styleAuraFrame(BuffFrame)
    styleAuraFrame(DebuffFrame)
    offsetDurations(BuffFrame.AuraContainer, BuffFrame.auraFrames)
    offsetDurations(DebuffFrame.AuraContainer, DebuffFrame.auraFrames)
end, "PLAYER_ENTERING_WORLD")
