-- Vanilla UI only: on the modern Edit Mode clients (TBC 2.5.6, likely era 1.15.9)
-- buff buttons are anonymous pooled frames and Edit Mode owns the aura layout.
if not AuraButton_Update then return end

local SPACING = CleanClassicExperience.SPACING
local C = CleanClassicExperience.COLOR

local BUFF_GAP    = 40
local DEBUFF_GAP  = 40
local AURA_GAP    = SPACING.SM
local DURATION_Y  = -6

-- Never write BUFF_HORIZ_SPACING (or any Blizzard-read global): secure code reading an
-- addon-written global taints the whole execution. Via PlayerFrame_ToPlayerArt ->
-- BuffFrame_Update at login it tainted PlayerFrame.unit, which TargetofTarget_Update
-- reads, blocking TargetFrameToT:Show() in combat. arrangeAuras spaces buttons itself.

local DEBUFF_COLORS = {
    Poison  = C.GREEN,
    Magic   = C.BLUE,
    Curse   = C.VIOLET,
    Disease = C.ORANGE,
}

local function styleAura(btn, color)
    if not btn then return end

    local border = CleanClassicExperience.ApplyBorder(btn)
    if border then border:SetBackdropBorderColor(unpack(color)) end

    local icon = _G[btn:GetName() .. "Icon"]
    if icon then icon:SetTexCoord(0.05, 0.95, 0.05, 0.95) end

    local nativeBorder = _G[btn:GetName() .. "Border"]
    if nativeBorder then nativeBorder:Hide() end

    local duration = _G[btn:GetName() .. "Duration"]
    if duration then
        duration:ClearAllPoints()
        duration:SetPoint("TOP", btn, "BOTTOM", 0, DURATION_Y)
    end
end

-- Blizzard rounds anything past an hour to whole hours ("2 h"); show exact minutes instead
hooksecurefunc("AuraButton_UpdateDuration", function(btn, timeLeft)
    if not (btn.duration and timeLeft) then return end

    if timeLeft >= 3600 and timeLeft < 86400 then
        btn.duration:SetFormattedText(MINUTE_ONELETTER_ABBR, math.ceil(timeLeft / 60))
    end

    btn.duration:SetVertexColor(1, 1, 1)
end)

hooksecurefunc("AuraButton_Update", function(name, index, filter)
    local btn = _G[name .. index]
    if not btn then return end

    if filter == "HARMFUL" then
        local debuffType = select(5, UnitDebuff("player", index))
        styleAura(btn, DEBUFF_COLORS[debuffType] or C.RED)
    else
        styleAura(btn, C.GREY)
    end
end)

local function anchorRow(prefix, count, anchor, anchorPoint, offsetY)
    local previous
    for i = 1, count do
        local btn = _G[prefix .. i]
        if btn and btn:IsShown() then
            btn:ClearAllPoints()
            if not previous then
                btn:SetPoint("TOPRIGHT", anchor, anchorPoint, 0, offsetY or 0)
            else
                btn:SetPoint("TOPRIGHT", previous, "TOPLEFT", -AURA_GAP, 0)
            end
            previous = btn
        end
    end
end

local function arrangeAuras()
    BuffFrame:ClearAllPoints()
    BuffFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -BUFF_GAP, 0)

    for i = 1, 5 do
        local tempEnchant = _G["TempEnchant" .. i]
        if tempEnchant then styleAura(tempEnchant, C.BLUE) end
    end

    anchorRow("BuffButton", BUFF_MAX_DISPLAY, BuffFrame, "TOPRIGHT")

    local debuffAnchor = _G["BuffButton1"] or BuffFrame
    anchorRow("DebuffButton", DEBUFF_MAX_DISPLAY, debuffAnchor, "BOTTOMRIGHT", -DEBUFF_GAP)
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", arrangeAuras)

CleanClassicExperience.OnEvent(function(_, _, unit)
    if unit and unit ~= "player" then return end
    arrangeAuras()
end, "PLAYER_ENTERING_WORLD", "UNIT_AURA")
