local BUTTON_OVERLAP = -4
local BACKPACK_GAP = -8

local BAG_BUTTONS = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
    "KeyRingButton",
}

local function arrangeBags()
    if not HelpMicroButton then return end

    for i, name in ipairs(BAG_BUTTONS) do
        local btn = _G[name]
        if not btn then return end
        btn:SetParent(UIParent)
        btn:Show()
        btn:ClearAllPoints()
        if i == 1 then
            btn:SetPoint("BOTTOMRIGHT", HelpMicroButton, "TOPRIGHT", 0, BACKPACK_GAP)
        else
            btn:SetPoint("RIGHT", _G[BAG_BUTTONS[i - 1]], "LEFT", BUTTON_OVERLAP, 0)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    C_Timer.After(0.1, arrangeBags)
end)
