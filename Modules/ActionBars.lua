-- Edit Mode owns all bar layout; only style the buttons and hide the styled border on empty action slots.
-- Standard action bars, whose empty slots should show nothing.
local ACTION_BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
}

-- Stance and pet bars are styled the same but keep their native empty behavior.
local BAR_PREFIXES = { "StanceButton", "PetActionButton" }
for _, prefix in ipairs(ACTION_BAR_PREFIXES) do
    table.insert(BAR_PREFIXES, prefix)
end

-- Stance and pet bars stop at 10; the loop just finds nil past the end.
local MAX_BUTTONS = 12

-- The stock slot art is stripped in StyleButton, so the border is what marks a drop target while the grid is up.
local function updateEmptyBorder(btn)
    local border = btn.cleanBorder
    if border and btn.HasAction then
        border:SetShown(btn:HasAction() or (btn.GetShowGrid and btn:GetShowGrid()))
    end
end

-- Mixin copies Update and SetShowGrid onto each button, so hook every instance once instead of a shared table.
local function hookEmptyBorder(btn)
    if not btn or btn.cleanEmptyHooked then return end
    if not (btn.Update and btn.HasAction) then return end
    hooksecurefunc(btn, "Update", updateEmptyBorder)
    if btn.SetShowGrid then
        hooksecurefunc(btn, "SetShowGrid", updateEmptyBorder)
    end
    btn.cleanEmptyHooked = true
end

-- Active auto attack marks its slot with the red flash plus the checked glow; keep only the flash.
local function updateFlashGlow(btn)
    local checked = btn.GetCheckedTexture and btn:GetCheckedTexture()
    if checked then
        checked:SetAlpha(btn:IsFlashing() and 0 or 1)
    end
end

-- UpdateFlash re-raises the glow alpha on every flip and StopFlash can fire alone, so hook both.
local function hookFlashGlow(btn)
    if btn.cleanFlashHooked then return end
    if not (btn.UpdateFlash and btn.StopFlash and btn.IsFlashing) then return end
    hooksecurefunc(btn, "UpdateFlash", updateFlashGlow)
    hooksecurefunc(btn, "StopFlash", updateFlashGlow)
    btn.cleanFlashHooked = true
end

local function styleAllButtons()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, MAX_BUTTONS do CleanClassicExperience.StyleButton(_G[prefix .. i]) end
    end

    for _, prefix in ipairs(ACTION_BAR_PREFIXES) do
        for i = 1, MAX_BUTTONS do
            local btn = _G[prefix .. i]
            if btn then
                hookEmptyBorder(btn)
                updateEmptyBorder(btn)
                hookFlashGlow(btn)
            end
        end
    end
end

styleAllButtons()

-- Icon-size changes apply live in Edit Mode before layouts save, so restyle on every applied setting too.
hooksecurefunc(EditModeManagerFrame, "OnSystemSettingChange", styleAllButtons)

CleanClassicExperience.OnEvent(styleAllButtons,
    "PLAYER_ENTERING_WORLD", "EDIT_MODE_LAYOUTS_UPDATED")
