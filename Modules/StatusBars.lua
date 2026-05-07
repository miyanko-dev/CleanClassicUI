local BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"

local function addBackground(bar)
    if not bar or bar.cleanUIBG then return end
    local bg = CreateFrame("Frame", nil, bar)
    bg:SetAllPoints()
    bg:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
    local tex = bg:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetTexture("Interface/Buttons/WHITE8x8")
    tex:SetVertexColor(0, 0, 0, 0.4)
    bar.cleanUIBG = bg
end

local function cleanBar(bar)
    if not bar then return end
    bar:SetStatusBarTexture(BAR_TEXTURE)
    local fill = bar:GetStatusBarTexture()
    for i = 1, bar:GetNumRegions() do
        local r = select(i, bar:GetRegions())
        if r and r ~= fill and r:GetObjectType() == "Texture" then
            r:Hide()
        end
    end
end

local function setupXPTooltip(bar)
    if not bar or bar.cleanUIHooked then return end
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        local cur, max = UnitXP("player"), UnitXPMax("player")
        local rest = GetXPExhaustion() or 0
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(format("XP: %d / %d (%.0f%%)", cur, max, cur / max * 100), 1, 1, 1)
        if rest > 0 then
            GameTooltip:AddLine(format("Rested: %d (%.0f%%)", rest, rest / max * 100), 0.2, 0.6, 1)
        end
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", GameTooltip_Hide)
    bar.cleanUIHooked = true
end

local function style()
    if MainMenuExpBar then
        addBackground(MainMenuExpBar)
        cleanBar(MainMenuExpBar)
        setupXPTooltip(MainMenuExpBar)
        if ExhaustionTick then
            ExhaustionTick:Hide()
            ExhaustionTick.Show = ExhaustionTick.Hide
        end
        if ExhaustionLevelFillBar then ExhaustionLevelFillBar:Hide() end
    end

    if ReputationWatchStatusBar then
        addBackground(ReputationWatchStatusBar)
        cleanBar(ReputationWatchStatusBar)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("UPDATE_FACTION")
f:SetScript("OnEvent", function()
    C_Timer.After(0, style)
end)
