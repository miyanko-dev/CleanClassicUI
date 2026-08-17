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

-- Only these bars carry stock art; the multi bars ship none.
local ART_BARS = { MainActionBar, StanceBar, PetActionBar, PossessActionBar }

local ART_KEYS = {
    "EndCaps",             -- MainActionBar's compact gryphon caps
    "BorderArt",
    "BackgroundArtLeft",   -- StanceBar's three-piece plate
    "BackgroundArtMiddle",
    "BackgroundArtRight",
}

-- Match Edit Mode's Hide Bar Art without writing to the layout; it only flips SetShown, so zero alpha outlasts it.
local function hideBarArt()
    -- The wide dwarf plate and its gryphon caps sit on the stock main menu bar, not on any action bar.
    MainMenuBarArtFrame:SetAlpha(0)

    for _, bar in ipairs(ART_BARS) do
        for _, key in ipairs(ART_KEYS) do
            if bar[key] then bar[key]:SetAlpha(0) end
        end

        -- Pet and possess bars keep their plate pieces in an array instead.
        for _, texture in ipairs(bar.BackgroundArtTextures or {}) do
            texture:SetAlpha(0)
        end
    end
end

hideBarArt()

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
