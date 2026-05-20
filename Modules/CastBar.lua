local BAR_H = 20
local MARGIN = 48

-- 2*BORDER clears the touching position; MARGIN is the visible gap above the action bar.
local ANCHOR_Y = MARGIN + NewNativeUI.BORDER * 2
local HIDDEN = { "Border", "BorderShield", "Spark", "Flash", "Icon" }

local isApplying = false
local isPending = false

local function applyAnchor()
    isPending = false
    if isApplying then return end
    local leftBtn = MultiBarBottomLeftButton5
    local rightBtn = MultiBarBottomLeftButton8
    if not (leftBtn and rightBtn) then return end
    isApplying = true
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint("BOTTOMLEFT", leftBtn, "TOPLEFT", 0, ANCHOR_Y)
    CastingBarFrame:SetPoint("BOTTOMRIGHT", rightBtn, "TOPRIGHT", 0, ANCHOR_Y)
    CastingBarFrame:SetHeight(BAR_H)
    isApplying = false
end

local function scheduleAnchor()
    if isApplying or isPending then return end
    isPending = true
    C_Timer.After(0, applyAnchor)
end

local function styleCastBar()
    CastingBarFrame:SetHeight(BAR_H)
    CastingBarFrame:SetStatusBarTexture(NewNativeUI.BAR_TEXTURE)

    for _, key in ipairs(HIDDEN) do
        local region = CastingBarFrame[key]
        if region then
            region:Hide()
            region:SetScript("OnShow", region.Hide)
        end
    end

    if CastingBarFrame.Text then
        CastingBarFrame.Text:ClearAllPoints()
        CastingBarFrame.Text:SetPoint("CENTER")
    end

    NewNativeUI.ApplyBorder(CastingBarFrame)
end

local isStyled = false

local events = NewNativeUI.OnEvent(function()
    if not isStyled then
        styleCastBar()
        isStyled = true
    end
    scheduleAnchor()
end,
"PLAYER_ENTERING_WORLD", "PET_BAR_UPDATE", "UNIT_PET", "UPDATE_SHAPESHIFT_FORM",
"UPDATE_BONUS_ACTIONBAR", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED")

events:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")

CastingBarFrame.ignoreFramePositionManager = true

hooksecurefunc(CastingBarFrame, "SetPoint", scheduleAnchor)

NewNativeUILayout = NewNativeUILayout or {}
NewNativeUILayout.afterLayout = NewNativeUILayout.afterLayout or {}
table.insert(NewNativeUILayout.afterLayout, scheduleAnchor)

hooksecurefunc("CastingBarFrame_FinishSpell", function(bar)
    if bar == CastingBarFrame then
        bar.flash = nil
        bar.fadeOut = nil
        bar:Hide()
    end
end)
