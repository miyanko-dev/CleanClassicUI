local BUFF_GAP = 40
local DEBUFF_GAP = 40
local SPACING = 8
local DURATION_Y = -6

BUFF_HORIZ_SPACING = -SPACING

local RED = { 0.980, 0.153, 0.184 }
local GREEN = { 0.188, 0.996, 0.192 }
local BLUE = { 0.157, 0.443, 0.851 }
local VIOLET = { 0.643, 0.231, 0.918 }
local ORANGE = { 0.984, 0.506, 0.157 }
local GREY = { 0.5, 0.5, 0.5 }

local DEBUFF_COLORS = {
    Poison = GREEN,
    Magic = BLUE,
    Curse = VIOLET,
    Disease = ORANGE,
}

local function styleAura(btn, color)
    if not btn then return end
    local border = CleanUI.ApplyBorder(btn)
    if border then border:SetBackdropBorderColor(unpack(color)) end
    local icon = _G[btn:GetName() .. "Icon"]
    if icon then icon:SetTexCoord(0.05, 0.95, 0.05, 0.95) end
    local def = _G[btn:GetName() .. "Border"]
    if def then def:Hide() end
    local dur = _G[btn:GetName() .. "Duration"]
    if dur then
        dur:ClearAllPoints()
        dur:SetPoint("TOP", btn, "BOTTOM", 0, DURATION_Y)
    end
end

hooksecurefunc("AuraButton_Update", function(name, index, filter)
    local btn = _G[name .. index]
    if not btn then return end
    if filter == "HARMFUL" then
        local dtype = select(5, UnitDebuff("player", index))
        styleAura(btn, DEBUFF_COLORS[dtype] or RED)
    else
        styleAura(btn, GREY)
    end
end)

local function arrangeAuras()
    BuffFrame:ClearAllPoints()
    BuffFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -BUFF_GAP, 0)

    for i = 1, 5 do
        local enc = _G["TempEnchant" .. i]
        if enc then styleAura(enc, BLUE) end
    end

    local prev
    for i = 1, BUFF_MAX_DISPLAY do
        local btn = _G["BuffButton" .. i]
        if btn and btn:IsShown() then
            btn:ClearAllPoints()
            if not prev then
                btn:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
            else
                btn:SetPoint("TOPRIGHT", prev, "TOPLEFT", -SPACING, 0)
            end
            prev = btn
        end
    end

    local firstBuff = _G["BuffButton1"]
    local debuffAnchor = firstBuff or BuffFrame

    prev = nil
    for i = 1, DEBUFF_MAX_DISPLAY do
        local btn = _G["DebuffButton" .. i]
        if btn and btn:IsShown() then
            btn:ClearAllPoints()
            if not prev then
                btn:SetPoint("TOPRIGHT", debuffAnchor, "BOTTOMRIGHT", 0, -DEBUFF_GAP)
            else
                btn:SetPoint("TOPRIGHT", prev, "TOPLEFT", -SPACING, 0)
            end
            prev = btn
        end
    end
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", arrangeAuras)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_AURA")
frame:SetScript("OnEvent", function(_, _, unit)
    if unit and unit ~= "player" then return end
    arrangeAuras()
end)
