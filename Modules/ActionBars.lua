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

-- Blizzard's Update hides the icon while its data is uncached and nothing redraws it once the data arrives, until hovering forces UpdateAction.
local function repairIcons()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, MAX_BUTTONS do
            local btn = _G[prefix .. i]

            -- Only real action slots carry .action; stance and pet buttons never blank this way.
            if btn and btn.action and btn.icon and not btn.icon:IsShown() then
                local texture = C_ActionBar.GetActionTexture(btn.action)

                -- Texture regions are not protected, so re-showing them cannot taint the button.
                if texture then
                    btn.icon:SetTexture(texture)
                    btn.icon:Show()
                end
            end
        end
    end
end

-- GET_ITEM_INFO_RECEIVED fires in bursts, so coalesce sweeps onto one short timer.
local repairQueued = false
local function queueRepair()
    if repairQueued then return end
    repairQueued = true
    C_Timer.After(0.1, function()
        repairQueued = false
        repairIcons()
    end)
end

CleanClassicExperience.OnEvent(queueRepair,
    "SPELLS_CHANGED", "UPDATE_MACROS", "GET_ITEM_INFO_RECEIVED")
