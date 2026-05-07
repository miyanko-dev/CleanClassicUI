local BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"
local BG_TEXTURE = "Interface/Buttons/WHITE8x8"

local function addBackground(bar)
    if not bar or bar.cleanBackground then return end
    local bg = CreateFrame("Frame", nil, bar)
    bg:SetAllPoints()
    bg:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
    local tex = bg:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetTexture(BG_TEXTURE)
    tex:SetVertexColor(0, 0, 0, 0.4)
    bar.cleanBackground = bg
end

local function reskinBar(bar)
    if not bar then return end
    bar:SetStatusBarTexture(BAR_TEXTURE)
    local fill = bar:GetStatusBarTexture()
    for i = 1, bar:GetNumRegions() do
        local region = select(i, bar:GetRegions())
        if region and region ~= fill and region:GetObjectType() == "Texture" then
            region:Hide()
        end
    end
end

local function attachXPTooltip(bar)
    if not bar or bar.cleanTooltip then return end
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
    bar.cleanTooltip = true
end

local function applyStyle()
    if MainMenuExpBar then
        addBackground(MainMenuExpBar)
        reskinBar(MainMenuExpBar)
        attachXPTooltip(MainMenuExpBar)
        if ExhaustionTick then
            ExhaustionTick:Hide()
            ExhaustionTick.Show = ExhaustionTick.Hide
        end
        if ExhaustionLevelFillBar then ExhaustionLevelFillBar:Hide() end
    end

    if ReputationWatchStatusBar then
        addBackground(ReputationWatchStatusBar)
        reskinBar(ReputationWatchStatusBar)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("UPDATE_FACTION")
frame:SetScript("OnEvent", function()
    C_Timer.After(0, applyStyle)
end)
