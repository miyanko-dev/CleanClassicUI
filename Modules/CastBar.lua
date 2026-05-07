local BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"
local BAR_WIDTH = 160
local BAR_HEIGHT = 16

local function position()
    if CastingBarFrame.cleanInHook then return end
    CastingBarFrame.cleanInHook = true
    local y = (CleanUIClassicLayout and CleanUIClassicLayout.castBarY) or 300
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y)
    CastingBarFrame.cleanInHook = false
end

local function styleCastBar()
    CastingBarFrame:SetSize(BAR_WIDTH, BAR_HEIGHT)
    CastingBarFrame:SetStatusBarTexture(BAR_TEXTURE)

    for _, key in ipairs({ "Border", "BorderShield", "Spark", "Flash", "Icon" }) do
        local r = CastingBarFrame[key]
        if r then r:Hide() end
    end

    if CastingBarFrame.Text then
        CastingBarFrame.Text:ClearAllPoints()
        CastingBarFrame.Text:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 0)
    end
end

local styled = false
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PET_BAR_UPDATE")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
f:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
f:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
f:SetScript("OnEvent", function()
    if not styled then
        styleCastBar()
        styled = true
    end
    position()
end)

hooksecurefunc(CastingBarFrame, "SetPoint", position)
