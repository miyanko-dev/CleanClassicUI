-- Edit Mode owns the tracking bars' placement; restyle them, reproportion them, and add richer tooltips.
local manager = StatusTrackingBarManager
if not manager then return end

local BG_TEXTURE = "Interface/Buttons/WHITE8x8"

-- Match the cast bar's width at half its height; Edit Mode's Size slider scales this base like the cast bar's.
local BAR_WIDTH, BAR_HEIGHT = 160, 10

-- The container is the Edit Mode system, so the fixed base size stays put while Edit Mode only applies SetScale.
local function resizeContainer(container)
    container:SetSize(BAR_WIDTH, BAR_HEIGHT)

    -- Bars fill the container, but each StatusBar anchors only on the right, so size it explicitly.
    for _, bar in pairs(container.bars or {}) do
        if bar.StatusBar then bar.StatusBar:SetSize(BAR_WIDTH, BAR_HEIGHT) end
    end
end

-- Dark backing so the unfilled portion still reads as a bar. Flush with the fill, since the border sits
-- outside the bar and draws over its edges; any outward outset would bleed the fill past the border.
local function addBackdrop(bar)
    if not bar or bar.cleanBg then return end

    local backdrop = CreateFrame("Frame", nil, bar)
    backdrop:SetAllPoints(bar)
    backdrop:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
    local texture = backdrop:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture(BG_TEXTURE)
    texture:SetVertexColor(0, 0, 0, 0.4)

    bar.cleanBg = backdrop
end

-- Swap in the nameplate fill atlas without losing the state color Blizzard just applied.
local function restyleFill(bar)
    local statusBar = bar.StatusBar
    if not statusBar then return end
    local r, g, b, a = statusBar:GetStatusBarColor()
    statusBar:SetStatusBarTexture(CleanClassicExperience.BAR_ATLAS)
    statusBar:SetStatusBarColor(r, g, b, a)
end

local function stripTextures(bar)
    local statusBar = bar.StatusBar
    if not statusBar then return end
    restyleFill(bar)
    local fill = statusBar:GetStatusBarTexture()
    for i = 1, statusBar:GetNumRegions() do
        local region = select(i, statusBar:GetRegions())
        if region and region ~= fill and region:GetObjectType() == "Texture" then
            region:Hide()
        end
    end
end

local function percentOf(value, max)
    return max > 0 and value / max * 100 or 0
end

local function statLine(value, max)
    return format("%d / %d (%.0f%%)", value, max, percentOf(value, max))
end

local function shortStat(value, max)
    return format("%d (%.0f%%)", value, percentOf(value, max))
end

local function showBarTooltip(bar, buildLines)
    GameTooltip:SetOwner(bar, "ANCHOR_NONE")
    GameTooltip:SetPoint("BOTTOM", bar, "TOP", 0, 4)
    buildLines()
    GameTooltip:Show()
end

-- The bars already have mixin OnEnter/OnLeave handlers, so hook instead of replacing.
local function addBarTooltip(bar, buildLines)
    bar:HookScript("OnEnter", function(self) showBarTooltip(self, buildLines) end)
    bar:HookScript("OnLeave", GameTooltip_Hide)
end

local function addXPTooltip(bar)
    addBarTooltip(bar, function()
        local currentXp, maxXp = UnitXP("player"), UnitXPMax("player")
        local rested = GetXPExhaustion() or 0
        local missing = maxXp - currentXp
        GameTooltip:AddLine(format("XP: %s", statLine(currentXp, maxXp)), 1, 1, 1)
        GameTooltip:AddLine(format("Missing: %s", shortStat(missing, maxXp)), 1, 0.82, 0)
        if rested > 0 then
            GameTooltip:AddLine(format("Rested: %s", shortStat(rested, maxXp)), 0.2, 0.6, 1)
        end
    end)
end

local function addRepTooltip(bar)
    addBarTooltip(bar, function()
        local factionData = C_Reputation.GetWatchedFactionData()
        if not factionData or factionData.factionID == 0 then return end
        local current = factionData.currentStanding - factionData.currentReactionThreshold
        local total = factionData.nextReactionThreshold - factionData.currentReactionThreshold
        local standing = GetText("FACTION_STANDING_LABEL" .. factionData.reaction, UnitSex("player"))
        GameTooltip:AddLine(format("%s (%s)", factionData.name, standing), 1, 1, 1)
        GameTooltip:AddLine(format("Reputation: %s", statLine(current, total)), 1, 1, 1)
        GameTooltip:AddLine(format("Missing: %s", shortStat(total - current, total)), 1, 0.82, 0)
    end)
end

local function styleBar(bar)
    if bar.cleanStyled then return end
    bar.cleanStyled = true

    addBackdrop(bar.StatusBar)
    stripTextures(bar)

    if bar.isExpBar then
        addXPTooltip(bar)

        -- The rested tooltip moved into the bar tooltip above.
        CleanClassicExperience.HideForever(bar.ExhaustionTick)
        if bar.ExhaustionLevelFillBar then bar.ExhaustionLevelFillBar:Hide() end

        -- Re-applies the rested/normal color on UPDATE_EXHAUSTION.
        if bar.UpdateStatusBarTextures then
            hooksecurefunc(bar, "UpdateStatusBarTextures", restyleFill)
        end
    else
        addRepTooltip(bar)

        -- Re-applies the reaction color and texture on every faction update.
        if bar.UpdateBarTextures then
            hooksecurefunc(bar, "UpdateBarTextures", restyleFill)
        end
    end
end

-- UseMainMenuBarArt toggles both texture sets' shown state, so zero alpha silences them for good.
local function hideContainerArt(container)
    for _, region in ipairs(container.MainMenuBarTextures or {}) do region:SetAlpha(0) end
    for _, region in ipairs(container.StandaloneTextures or {}) do region:SetAlpha(0) end
end

local function applyStyle()
    for _, container in ipairs(manager.barContainers or {}) do
        hideContainerArt(container)
        resizeContainer(container)

        -- bars is keyed by the manager's bar enum, not a dense array.
        for _, bar in pairs(container.bars or {}) do
            styleBar(bar)

            -- 12/3 tooltip border that rides the Edit Mode scale, so it thins with the bar instead of dwarfing it.
            CleanClassicExperience.ApplyBorder(bar.StatusBar, nil, nil, nil, true)
        end
    end
end

applyStyle()

-- The Size slider applies its SetScale per tick; re-fit the resized bars and their border after each applied setting.
hooksecurefunc(EditModeManagerFrame, "OnSystemSettingChange", applyStyle)

CleanClassicExperience.OnEvent(function()
    C_Timer.After(0, applyStyle)
end, "PLAYER_ENTERING_WORLD", "EDIT_MODE_LAYOUTS_UPDATED")
