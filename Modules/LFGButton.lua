-- Dock the group-finder eye left of the character micro button: no ring, native eye art, micro-menu scale.
local BUTTON_SIZE = 33
local SCALE       = 1.5
local MARGIN      = -2

local function placeLFGButton()
    if not (LFGMinimapFrame and CharacterMicroButton) then return end
    if LFGMinimapFrameBorder then LFGMinimapFrameBorder:Hide() end
    LFGMinimapFrame:SetParent(MicroMenu or UIParent)
    LFGMinimapFrame:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    LFGMinimapFrame:SetScale(SCALE)
    LFGMinimapFrame:ClearAllPoints()

    -- Anchor offsets are in the button's scaled units; divide so the margin stays MARGIN in micro-menu units.
    LFGMinimapFrame:SetPoint("RIGHT", CharacterMicroButton, "LEFT", -MARGIN / SCALE, 0)
end

placeLFGButton()

CleanClassicUI.OnEvent(function()
    C_Timer.After(0, placeLFGButton)
end, "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
"EDIT_MODE_LAYOUTS_UPDATED")
