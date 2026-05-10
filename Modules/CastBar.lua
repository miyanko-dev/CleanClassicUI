local BAR_W = 160
local BAR_H = 16
local FALLBACK_Y = 300
local HIDDEN = { "Border", "BorderShield", "Spark", "Flash", "Icon" }

local applying = false
local pending = false

local function applyAnchor()
    pending = false
    if applying then return end
    applying = true
    local y = (CleanUILayout and CleanUILayout.castBarY) or FALLBACK_Y
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y)
    applying = false
end

local function scheduleAnchor()
    if applying or pending then return end
    pending = true
    C_Timer.After(0, applyAnchor)
end

local function styleCastBar()
    CastingBarFrame:SetSize(BAR_W, BAR_H)
    CastingBarFrame:SetStatusBarTexture(CleanUI.BAR_TEXTURE)

    for _, key in ipairs(HIDDEN) do
        local r = CastingBarFrame[key]
        if r then
            r:Hide()
            r:SetScript("OnShow", r.Hide)
        end
    end

    if CastingBarFrame.Text then
        CastingBarFrame.Text:ClearAllPoints()
        CastingBarFrame.Text:SetPoint("CENTER")
    end

    CleanUI.ApplyBorder(CastingBarFrame)
end

local styled = false
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PET_BAR_UPDATE")
frame:RegisterEvent("UNIT_PET")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
frame:SetScript("OnEvent", function()
    if not styled then
        styleCastBar()
        styled = true
    end
    scheduleAnchor()
end)

hooksecurefunc(CastingBarFrame, "SetPoint", scheduleAnchor)

CleanUILayout = CleanUILayout or {}
CleanUILayout.afterLayout = CleanUILayout.afterLayout or {}
table.insert(CleanUILayout.afterLayout, scheduleAnchor)

hooksecurefunc("CastingBarFrame_FinishSpell", function(bar)
    if bar == CastingBarFrame then
        bar.flash = nil
        bar.fadeOut = nil
        bar:Hide()
    end
end)
