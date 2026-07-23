-- Edit Mode owns the tracking bars' placement; restyle them, halve their width, and add richer tooltips.
local manager = StatusTrackingBarManager
if not manager then return end

local BG_TEXTURE = "Interface/Buttons/WHITE8x8"
local BAR_EDGE = 8
local WIDTH_FACTOR = 0.5

-- Divide the halved width by the container's Edit Mode scale so the on-screen width stays fixed at 50%.
local function resizeContainer(container)
    container.cleanNativeWidth = container.cleanNativeWidth or container:GetWidth()

    local containerScale = container:GetEffectiveScale()
    local uiScale = UIParent:GetEffectiveScale()
    local scale = 1
    if containerScale and uiScale and containerScale > 0 and uiScale > 0 then
        scale = containerScale / uiScale
    end

    local width = container.cleanNativeWidth * WIDTH_FACTOR / scale
    container:SetWidth(width)
    for _, bar in pairs(container.bars or {}) do
        if bar.StatusBar then bar.StatusBar:SetWidth(width) end
    end
end

-- Layer the border above the fill and the backdrop below so the border line always draws over the fill edges.
local function addChrome(bar)
    if not bar or bar.cleanBg then return end
    local edge = CleanClassicExperience.BORDER
    local barLevel = bar:GetFrameLevel()

    -- The dark fill tucks 1px under the border line.
    local bgOutset = edge - 1
    local backdrop = CreateFrame("Frame", nil, bar)
    backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", -bgOutset, bgOutset)
    backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", bgOutset, -bgOutset)
    backdrop:SetFrameLevel(math.max(0, barLevel - 1))
    local backdropTexture = backdrop:CreateTexture(nil, "BACKGROUND")
    backdropTexture:SetAllPoints()
    backdropTexture:SetTexture(BG_TEXTURE)
    backdropTexture:SetVertexColor(0, 0, 0, 0.4)

    local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    border:SetPoint("TOPLEFT", bar, "TOPLEFT", -edge, edge)
    border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", edge, -edge)
    border:SetFrameLevel(barLevel + 5)
    border:SetBackdrop({ edgeFile = CleanClassicExperience.EDGE_FILE, edgeSize = BAR_EDGE })
    border:SetBackdropBorderColor(unpack(CleanClassicExperience.COLOR.GREY))

    bar.cleanBg = backdrop
end

-- Swap the fill texture without losing the state color Blizzard just applied.
local function restyleFill(bar)
    local statusBar = bar.StatusBar
    if not statusBar then return end
    local r, g, b, a = statusBar:GetStatusBarColor()
    statusBar:SetStatusBarTexture(CleanClassicExperience.BAR_TEXTURE)
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
        local data = C_Reputation.GetWatchedFactionData()
        if not data or data.factionID == 0 then return end
        local current = data.currentStanding - data.currentReactionThreshold
        local total = data.nextReactionThreshold - data.currentReactionThreshold
        local standing = GetText("FACTION_STANDING_LABEL" .. data.reaction, UnitSex("player"))
        GameTooltip:AddLine(format("%s (%s)", data.name, standing), 1, 1, 1)
        GameTooltip:AddLine(format("Reputation: %s", statLine(current, total)), 1, 1, 1)
        GameTooltip:AddLine(format("Missing: %s", shortStat(total - current, total)), 1, 0.82, 0)
    end)
end

local function styleBar(bar)
    if bar.cleanStyled then return end
    bar.cleanStyled = true

    addChrome(bar.StatusBar)
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
        end
    end
end

applyStyle()

-- The Size slider applies its SetScale per tick; recompute the compensated width after each applied setting.
hooksecurefunc(EditModeManagerFrame, "OnSystemSettingChange", applyStyle)

CleanClassicExperience.OnEvent(function()
    C_Timer.After(0, applyStyle)
end, "PLAYER_ENTERING_WORLD", "EDIT_MODE_LAYOUTS_UPDATED")
