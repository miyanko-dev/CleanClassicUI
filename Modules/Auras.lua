local SPACING = NewNativeUI.SPACING
local C = NewNativeUI.COLOR

local BUFF_GAP = 40
local DEBUFF_GAP = 40
local AURA_GAP = SPACING.SM
local DURATION_Y = -6

BUFF_HORIZ_SPACING = -AURA_GAP

local DEBUFF_COLORS = {
    Poison  = C.GREEN,
    Magic   = C.BLUE,
    Curse   = C.VIOLET,
    Disease = C.ORANGE,
}

local function styleAura(btn, color)
    if not btn then return end
    local border = NewNativeUI.ApplyBorder(btn)
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

NewNativeUI.OnEvent(function(_, _, unit)
    if unit and unit ~= "player" then return end
    arrangeAuras()
end, "PLAYER_ENTERING_WORLD", "UNIT_AURA")
