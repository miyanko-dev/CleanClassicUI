-- Edit Mode owns the cast bar's position and scale; restyle it and give it a fixed base size Edit Mode scales.
local castBar = PlayerCastingBarFrame
if not castBar then return end

local HIDDEN = { "Border", "BorderShield", "Spark", "Flash", "Icon" }
local BAR_WIDTH, BAR_HEIGHT = 160, 20

-- SetLook is the only native writer of the bar's size, so resizing right after it always wins.
local function applySize()
    castBar:SetSize(BAR_WIDTH, BAR_HEIGHT)
end

-- Span the bar so the text centers vertically and ellipsizes at the bar's edges natively.
local function centerText()
    local text = castBar.Text
    if not text then return end
    text:ClearAllPoints()
    text:SetPoint("LEFT")
    text:SetPoint("RIGHT")
    text:SetJustifyH("CENTER")
end

local function styleCastBar()
    castBar:SetStatusBarTexture(CleanClassicExperience.BAR_TEXTURE)

    for _, key in ipairs(HIDDEN) do
        local region = castBar[key]
        if region then
            region:Hide()
            region:SetScript("OnShow", region.Hide)
        end
    end

    centerText()
    CleanClassicExperience.ApplyBorder(castBar)
end

styleCastBar()
applySize()

-- The text sits inside the bar now, so let the Edit Mode highlight hug the resized frame.
castBar.editModeSelectionTopOffset = 0

-- classicStyleCastBar re-applies the stock fill on every cast state change; swap back, keep the color.
hooksecurefunc(castBar, "UpdateBarFillTexture", function(self)
    local r, g, b, a = self:GetStatusBarColor()
    self:SetStatusBarTexture(CleanClassicExperience.BAR_TEXTURE)
    self:SetStatusBarColor(r, g, b, a)
end)

-- SetLook re-anchors the text and resets the native size on every layout apply; redo both after.
hooksecurefunc(castBar, "SetLook", function()
    centerText()
    applySize()
end)

-- BarSize lands as a SetScale that changes the border's coordinate space; re-apply on every applied setting.
hooksecurefunc(EditModeManagerFrame, "OnSystemSettingChange", styleCastBar)

CleanClassicExperience.OnEvent(styleCastBar,
    "PLAYER_ENTERING_WORLD", "EDIT_MODE_LAYOUTS_UPDATED")
