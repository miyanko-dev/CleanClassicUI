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

local function addXPTooltip(bar)
    if not bar or bar.cleanTip then return end
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        local currentXp, maxXp = UnitXP("player"), UnitXPMax("player")
        local rested = GetXPExhaustion() or 0
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 4)
        GameTooltip:AddLine(format("XP: %d / %d (%.0f%%)", currentXp, maxXp, currentXp / maxXp * 100), 1, 1, 1)
        if rested > 0 then
            GameTooltip:AddLine(format("Rested: %d (%.0f%%)", rested, rested / maxXp * 100), 0.2, 0.6, 1)
        end
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", GameTooltip_Hide)
    bar.cleanTip = true
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

local function styleRepBar()
    if not ReputationWatchStatusBar then return end
    addBg(ReputationWatchStatusBar)
    stripTextures(ReputationWatchStatusBar)
    CleanClassicUI.ApplyBorder(ReputationWatchStatusBar)
end

local function applyStyle()
    styleXPBar()
    styleRepBar()
end

CleanClassicUI.OnEvent(function()
    C_Timer.After(0, applyStyle)
end, "PLAYER_ENTERING_WORLD", "PLAYER_LEVEL_UP", "UPDATE_FACTION")
