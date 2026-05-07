local BUFF_GAP = 40
local DEBUFF_GAP = 20
local DEBUFF_SPACING = 8

local function arrangeAuras()
    BuffFrame:ClearAllPoints()
    BuffFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -BUFF_GAP, 0)

    local prev
    for i = 1, DEBUFF_MAX_DISPLAY do
        local btn = _G["DebuffButton" .. i]
        if btn and btn:IsShown() then
            btn:ClearAllPoints()
            if not prev then
                btn:SetPoint("TOPRIGHT", BuffFrame, "BOTTOMRIGHT", 0, -DEBUFF_GAP)
            else
                btn:SetPoint("TOPRIGHT", prev, "TOPLEFT", -DEBUFF_SPACING, 0)
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
