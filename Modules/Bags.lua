local SPACING = -4

local bags = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
    "KeyRingButton",
}

local function arrangeBags()
    if not HelpMicroButton then return end

    for i, name in ipairs(bags) do
        local btn = _G[name]
        if not btn then return end
        btn:SetParent(UIParent)
        btn:Show()
        btn:ClearAllPoints()
        if i == 1 then
            btn:SetPoint("BOTTOMRIGHT", HelpMicroButton, "TOPRIGHT", 0, 10)
        else
            btn:SetPoint("RIGHT", _G[bags[i - 1]], "LEFT", SPACING, 0)
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    C_Timer.After(0.1, arrangeBags)
end)
