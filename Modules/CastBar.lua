local BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"
local BAR_WIDTH = 160
local BAR_HEIGHT = 16
local FALLBACK_Y = 300

local HIDDEN_REGIONS = { "Border", "BorderShield", "Spark", "Flash", "Icon" }

local repositioning = false
local function anchorCastBar()
    if repositioning then return end
    repositioning = true
    local y = (CleanUIClassicLayout and CleanUIClassicLayout.castBarY) or FALLBACK_Y
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y)
    repositioning = false
end

local function styleCastBar()
    CastingBarFrame:SetSize(BAR_WIDTH, BAR_HEIGHT)
    CastingBarFrame:SetStatusBarTexture(BAR_TEXTURE)

    for _, key in ipairs(HIDDEN_REGIONS) do
        local region = CastingBarFrame[key]
        if region then
            region:Hide()
            region:SetScript("OnShow", region.Hide)
        end
    end

    if CastingBarFrame.Text then
        CastingBarFrame.Text:ClearAllPoints()
        CastingBarFrame.Text:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 0)
    end
end

local styled = false
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PET_BAR_UPDATE")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
frame:SetScript("OnEvent", function()
    if not styled then
        styleCastBar()
        styled = true
    end
    anchorCastBar()
end)

hooksecurefunc(CastingBarFrame, "SetPoint", anchorCastBar)

hooksecurefunc("CastingBarFrame_FinishSpell", function(bar)
    if bar == CastingBarFrame then
        bar.flash = nil
        bar.fadeOut = nil
        bar:Hide()
    end
end)
