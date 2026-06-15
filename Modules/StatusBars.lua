local BG_TEXTURE = "Interface/Buttons/WHITE8x8"

local function addBg(bar)
    if not bar or bar.cleanBg then return end
    local bg  = CreateFrame("Frame", nil, bar)
    bg:SetAllPoints()
    bg:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))

    local tex = bg:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetTexture(BG_TEXTURE)
    tex:SetVertexColor(0, 0, 0, 0.4)

    bar.cleanBg = bg
end

local function stripTextures(bar)
    if not bar then return end
    bar:SetStatusBarTexture(CleanClassicUI.BAR_TEXTURE)

    local fill = bar:GetStatusBarTexture()
    for i = 1, bar:GetNumRegions() do
        local region = select(i, bar:GetRegions())
        if region and region ~= fill and region:GetObjectType() == "Texture" then
            region:Hide()
        end
    end
end

local function percentOf(value, max)
    return max > 0 and value / max * 100 or 0
end

-- "value / max (pct%)"
local function statLine(value, max)
    return format("%d / %d (%.0f%%)", value, max, percentOf(value, max))
end

-- "value (pct%)"
local function shortStat(value, max)
    return format("%d (%.0f%%)", value, percentOf(value, max))
end

-- 4px gap, above the bar (XP, bottom of screen) or below it (rep, top of screen)
local TIP_ABOVE = { point = "BOTTOM", relativePoint = "TOP", y = 4 }
local TIP_BELOW = { point = "TOP", relativePoint = "BOTTOM", y = -4 }

local function showBarTooltip(bar, buildLines, anchor)
    GameTooltip:SetOwner(bar, "ANCHOR_NONE")
    GameTooltip:SetPoint(anchor.point, bar, anchor.relativePoint, 0, anchor.y)
    buildLines()
    GameTooltip:Show()
end

local function addBarTooltip(bar, buildLines, anchor)
    if not bar or bar.cleanTip then return end
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self) showBarTooltip(self, buildLines, anchor) end)
    bar:SetScript("OnLeave", GameTooltip_Hide)
    bar.cleanTip = true
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
    end, TIP_ABOVE)
end

local function addRepTooltip(bar)
    addBarTooltip(bar, function()
        local name, standingID, repMin, repMax, repValue = GetWatchedFactionInfo()
        if not name then return end
        local current = repValue - repMin
        local total = repMax - repMin
        local standing = GetText("FACTION_STANDING_LABEL" .. standingID, UnitSex("player"))
        GameTooltip:AddLine(format("%s (%s)", name, standing), 1, 1, 1)
        GameTooltip:AddLine(format("Reputation: %s", statLine(current, total)), 1, 1, 1)
        GameTooltip:AddLine(format("Missing: %s", shortStat(total - current, total)), 1, 0.82, 0)
    end, TIP_BELOW)
end

local function styleXPBar()
    if not MainMenuExpBar then return end
    addBg(MainMenuExpBar)
    stripTextures(MainMenuExpBar)
    addXPTooltip(MainMenuExpBar)
    CleanClassicUI.ApplyBorder(MainMenuExpBar)
    CleanClassicUI.HideForever(ExhaustionTick)
    if ExhaustionLevelFillBar then ExhaustionLevelFillBar:Hide() end
end

-- Center the rep bar at the top edge, 16px below it
local function positionRepBar()
    if not ReputationWatchBar then return end
    ReputationWatchBar:ClearAllPoints()
    ReputationWatchBar:SetPoint("TOP", UIParent, "TOP", 0, -CleanClassicUI.SPACING.MD)
end

-- Mirror the XP bar's dimensions so both bars look identical
local function matchXPBarSize(frame)
    if not MainMenuExpBar then return end
    local width, height = MainMenuExpBar:GetWidth(), MainMenuExpBar:GetHeight()
    frame:SetSize(width, height)
    frame.StatusBar:SetSize(width, height)
end

-- Blizzard re-anchors, re-sizes, and re-shows the native art on every update; re-apply ours
local function hookRepBarLayout()
    if CleanClassicUI.repBarHooked or not MainMenuTrackingBar_Configure then return end
    CleanClassicUI.repBarHooked = true
    hooksecurefunc("MainMenuTrackingBar_Configure", function(frame)
        if frame ~= ReputationWatchBar then return end
        stripTextures(frame.StatusBar)
        matchXPBarSize(frame)
        positionRepBar()
    end)
end

local function styleRepBar()
    local frame = ReputationWatchBar
    if not frame or not frame.StatusBar then return end
    addBg(frame.StatusBar)
    stripTextures(frame.StatusBar)
    matchXPBarSize(frame)
    -- Anchor the tooltip to the parent frame: it stays above the StatusBar in hit-testing
    addRepTooltip(frame)
    CleanClassicUI.ApplyBorder(frame.StatusBar)
    CleanClassicUI.HideForever(frame.OverlayFrame)
    positionRepBar()
    hookRepBarLayout()
end

local function applyStyle()
    styleXPBar()
    styleRepBar()
end

CleanClassicUI.OnEvent(function()
    C_Timer.After(0, applyStyle)
end, "PLAYER_ENTERING_WORLD", "PLAYER_LEVEL_UP", "UPDATE_FACTION")
