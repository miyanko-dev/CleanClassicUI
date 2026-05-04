local BUTTON_WIDTH = 28

-- Collect visible micro buttons, dim them, and right-align them along the screen edge
local function configureMicroButtons()
    local buttons = {}
    for name in pairs(_G) do
        if type(name) == "string" and string.match(name, "^%a+MicroButton$") then
            local button = _G[name]
            if type(button) == "table" and button.IsVisible and button:IsVisible() then
                table.insert(buttons, button)
                button:SetAlpha(0.5)
                button:SetWidth(BUTTON_WIDTH)
                button:SetClampedToScreen(false)
            end
        end
    end

    local totalWidth    = #buttons * BUTTON_WIDTH
    local adjustedWidth = totalWidth - BUTTON_WIDTH

    local characterButton = _G["CharacterMicroButton"]
    if characterButton then
        characterButton:ClearAllPoints()
        characterButton:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMRIGHT", -(adjustedWidth + 16), 16)
    end
end

local function scheduleMicroButtonUpdate()
    C_Timer.After(0, configureMicroButtons)
end

local microMenuFrame = CreateFrame("Frame")
microMenuFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
microMenuFrame:RegisterEvent("PLAYER_LOGIN")
microMenuFrame:RegisterEvent("UI_SCALE_CHANGED")
microMenuFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
microMenuFrame:SetScript("OnEvent", scheduleMicroButtonUpdate)
