local BG_TEXTURE = "Interface/Buttons/WHITE8x8"

local BAR_HEIGHT = 8
local BAR_EDGE = 8

-- Layer the bar top-to-bottom as border / progress fill / backdrop: the backdrop sits one
-- level below the bar so the fill covers it, and the border sits above so its line always
-- draws over the fill edges. Both share the bar's edge offset; the dark fill tucks 1px under
-- the border line, and the bar is sized so the progress fill runs out to that same line.
local function addChrome(bar)
    if not bar or bar.cleanBg then return end
    local edge = (CleanClassicExperienceLayout and CleanClassicExperienceLayout.xpRepEdge) or CleanClassicExperience.BORDER
    local barLevel = bar:GetFrameLevel()

    -- Backdrop (bottom): dark fill, tucked 1px under the border line.
    local bgOutset = edge - 1
    local backdrop = CreateFrame("Frame", nil, bar)
    backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", -bgOutset, bgOutset)
    backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", bgOutset, -bgOutset)
    backdrop:SetFrameLevel(math.max(0, barLevel - 1))
    local tex = backdrop:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetTexture(BG_TEXTURE)
    tex:SetVertexColor(0, 0, 0, 0.4)

    -- Border (top): drawn above the progress fill so the line is never clipped by it.
    local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    border:SetPoint("TOPLEFT", bar, "TOPLEFT", -edge, edge)
    border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", edge, -edge)
    border:SetFrameLevel(barLevel + 5)
    border:SetBackdrop({ edgeFile = CleanClassicExperience.EDGE_FILE, edgeSize = BAR_EDGE })
    border:SetBackdropBorderColor(unpack(CleanClassicExperience.COLOR.GREY))

    bar.cleanBg = backdrop
end

local function stripTextures(bar)
    if not bar then return end
    bar:SetStatusBarTexture(CleanClassicExperience.BAR_TEXTURE)

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

-- 4px gap above the bar; both bars sit at the bottom of the screen
local TIP_ABOVE = { point = "BOTTOM", relativePoint = "TOP", y = 4 }

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
    end, TIP_ABOVE)
end

-- Match AB3's visible width (fill + border) so the bars read as one strip with the bar stack.
local function sizeXPBar()
    if not MainMenuExpBar then return end
    local layout = CleanClassicExperienceLayout
    local width = layout and layout.xpRepWidth and layout.xpRepWidth()
    if width then MainMenuExpBar:SetWidth(width) end
    MainMenuExpBar:SetHeight((layout and layout.xpRepBarHeight) or BAR_HEIGHT)
end

local function styleXPBar()
    if not MainMenuExpBar then return end
    addChrome(MainMenuExpBar)
    stripTextures(MainMenuExpBar)
    addXPTooltip(MainMenuExpBar)
    CleanClassicExperience.HideForever(ExhaustionTick)
    if ExhaustionLevelFillBar then ExhaustionLevelFillBar:Hide() end
    sizeXPBar()
end

-- XP bar pinned to the bottom slot, centered; rep bar in the slot above it, or in the
-- bottom slot itself when the XP bar is hidden (max level). AB3 reserves both slots
-- regardless of visibility (see ActionBars.lua), so the action bar stack never shifts.
local function positionBars()
    local layout = CleanClassicExperienceLayout
    local edge = (layout and layout.xpRepEdge) or CleanClassicExperience.BORDER
    local bottomSlot = (layout and layout.xpRepBottomSlot or 0) + edge
    local upperSlot = (layout and layout.xpRepUpperSlot or 0) + edge
    local xpShown = MainMenuExpBar and MainMenuExpBar:IsShown()

    if MainMenuExpBar then
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, bottomSlot)
    end
    if ReputationWatchBar then
        ReputationWatchBar:ClearAllPoints()
        ReputationWatchBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, xpShown and upperSlot or bottomSlot)
    end
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
    if CleanClassicExperience.repBarHooked or not MainMenuTrackingBar_Configure then return end
    CleanClassicExperience.repBarHooked = true
    hooksecurefunc("MainMenuTrackingBar_Configure", function(frame)
        if frame ~= ReputationWatchBar then return end
        stripTextures(frame.StatusBar)
        matchXPBarSize(frame)
        positionBars()
    end)
end

local function styleRepBar()
    local frame = ReputationWatchBar
    if not frame or not frame.StatusBar then return end
    addChrome(frame.StatusBar)
    stripTextures(frame.StatusBar)
    matchXPBarSize(frame)
    -- Anchor the tooltip to the parent frame: it stays above the StatusBar in hit-testing
    addRepTooltip(frame)
    CleanClassicExperience.HideForever(frame.OverlayFrame)
    hookRepBarLayout()
end

local function applyStyle()
    styleXPBar()
    styleRepBar()
    positionBars()
end

CleanClassicExperience.OnEvent(function()
    C_Timer.After(0, applyStyle)
end, "PLAYER_ENTERING_WORLD", "PLAYER_LEVEL_UP", "UPDATE_FACTION")
