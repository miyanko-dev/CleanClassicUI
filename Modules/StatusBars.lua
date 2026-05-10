local BG_TEXTURE = "Interface/Buttons/WHITE8x8"

local function addBg(bar)
    if not bar or bar.cleanBg then return end
    local bg = CreateFrame("Frame", nil, bar)
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
    bar:SetStatusBarTexture(CleanUI.BAR_TEXTURE)
    local fill = bar:GetStatusBarTexture()
    for i = 1, bar:GetNumRegions() do
        local r = select(i, bar:GetRegions())
        if r and r ~= fill and r:GetObjectType() == "Texture" then
            r:Hide()
        end
    end
end

local function addXPTooltip(bar)
    if not bar or bar.cleanTip then return end
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        local cur, max = UnitXP("player"), UnitXPMax("player")
        local rest = GetXPExhaustion() or 0
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 4)
        GameTooltip:AddLine(format("XP: %d / %d (%.0f%%)", cur, max, cur / max * 100), 1, 1, 1)
        if rest > 0 then
            GameTooltip:AddLine(format("Rested: %d (%.0f%%)", rest, rest / max * 100), 0.2, 0.6, 1)
        end
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", GameTooltip_Hide)
    bar.cleanTip = true
end

local function applyStyle()
    if MainMenuExpBar then
        addBg(MainMenuExpBar)
        stripTextures(MainMenuExpBar)
        addXPTooltip(MainMenuExpBar)
        CleanUI.ApplyBorder(MainMenuExpBar)
        if ExhaustionTick then
            ExhaustionTick:Hide()
            ExhaustionTick.Show = ExhaustionTick.Hide
        end
        if ExhaustionLevelFillBar then ExhaustionLevelFillBar:Hide() end
    end

    if ReputationWatchStatusBar then
        addBg(ReputationWatchStatusBar)
        stripTextures(ReputationWatchStatusBar)
        CleanUI.ApplyBorder(ReputationWatchStatusBar)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("UPDATE_FACTION")
frame:SetScript("OnEvent", function()
    C_Timer.After(0, applyStyle)
end)
