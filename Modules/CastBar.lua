local BAR_H       = 20
local TEXT_PADDING = 6
local ELLIPSIS    = "..."

local HIDDEN = { "Border", "BorderShield", "Spark", "Flash", "Icon" }

local isApplying = false
local isPending  = false

-- Binary-search the longest prefix that fits, then append "...".
local function truncateToWidth(text, full, maxWidth)
    text:SetText(full)
    if text:GetStringWidth() <= maxWidth then return end
    local lo, hi = 0, #full
    while lo < hi do
        local mid = math.floor((lo + hi + 1) / 2)
        text:SetText(string.sub(full, 1, mid) .. ELLIPSIS)
        if text:GetStringWidth() <= maxWidth then
            lo = mid
        else
            hi = mid - 1
        end
    end
    text:SetText(string.sub(full, 1, lo) .. ELLIPSIS)
end

local function updateTextLayout()
    local text = CastingBarFrame.Text
    if not text then return end
    local barW = CastingBarFrame:GetWidth()
    if not barW or barW <= 0 then return end
    local usable = barW - 2 * TEXT_PADDING
    if usable <= 0 then return end
    truncateToWidth(text, text:GetText() or "", usable)
    text:ClearAllPoints()
    text:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 0)
    text:SetJustifyH("CENTER")
end

local function applyAnchor()
    isPending = false
    if not isApplying then
        local leftBtn  = MultiBarBottomLeftButton5
        local rightBtn = MultiBarBottomLeftButton8
        local layout   = CleanClassicUILayout
        local yOffset  = layout and layout.castbarYOffsetAboveAB2 and layout.castbarYOffsetAboveAB2()
        if leftBtn and rightBtn and yOffset then
            isApplying = true
            CastingBarFrame:ClearAllPoints()
            CastingBarFrame:SetPoint("BOTTOMLEFT",  leftBtn,  "TOPLEFT",  0, yOffset)
            CastingBarFrame:SetPoint("BOTTOMRIGHT", rightBtn, "TOPRIGHT", 0, yOffset)
            CastingBarFrame:SetHeight(BAR_H)
            isApplying = false
        end
    end
    updateTextLayout()
end

local function scheduleAnchor()
    if isApplying or isPending then return end
    isPending = true
    C_Timer.After(0, applyAnchor)
end

local function styleCastBar()
    CastingBarFrame:SetHeight(BAR_H)
    CastingBarFrame:SetStatusBarTexture(CleanClassicUI.BAR_TEXTURE)

    for _, key in ipairs(HIDDEN) do
        local region = CastingBarFrame[key]
        if region then
            region:Hide()
            region:SetScript("OnShow", region.Hide)
        end
    end

    if CastingBarFrame.Text then
        CastingBarFrame.Text:SetWordWrap(false)
        CastingBarFrame.Text:SetNonSpaceWrap(false)
    end

    CleanClassicUI.ApplyBorder(CastingBarFrame)
end

local isStyled = false

local events = CleanClassicUI.OnEvent(function()
    if not isStyled then
        styleCastBar()
        isStyled = true
    end
    scheduleAnchor()
end,
"PLAYER_ENTERING_WORLD", "PET_BAR_UPDATE", "UNIT_PET", "UPDATE_SHAPESHIFT_FORM",
"UPDATE_BONUS_ACTIONBAR", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED")

events:RegisterUnitEvent("UNIT_SPELLCAST_START",         "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")

CastingBarFrame.ignoreFramePositionManager = true

hooksecurefunc(CastingBarFrame, "SetPoint", scheduleAnchor)

CleanClassicUILayout = CleanClassicUILayout or {}
CleanClassicUILayout.afterLayout = CleanClassicUILayout.afterLayout or {}
table.insert(CleanClassicUILayout.afterLayout, scheduleAnchor)

hooksecurefunc("CastingBarFrame_FinishSpell", function(bar)
    if bar == CastingBarFrame then
        bar.flash   = nil
        bar.fadeOut = nil
        bar:Hide()
    end
end)
