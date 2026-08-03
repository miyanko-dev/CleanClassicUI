-- Edit Mode owns all bar layout; styling is one-shot cosmetics only.
-- Never hook button updates: Blizzard hides icons itself while macro data resolves
-- at login, and a broken update chain leaves them stuck hidden.
local BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
    "StanceButton",
    "PetActionButton",
}

-- Stance and pet bars stop at 10; the loop just finds nil past the end.
local MAX_BUTTONS = 12

local function styleAllButtons()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, MAX_BUTTONS do
            CleanClassicExperience.StyleButton(_G[prefix .. i])
        end
    end
end

styleAllButtons()

-- Icon-size changes apply live in Edit Mode before layouts save, so restyle on every applied setting too.
hooksecurefunc(EditModeManagerFrame, "OnSystemSettingChange", styleAllButtons)

CleanClassicExperience.OnEvent(styleAllButtons,
    "PLAYER_ENTERING_WORLD", "EDIT_MODE_LAYOUTS_UPDATED")
