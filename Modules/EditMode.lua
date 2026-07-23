-- On the Classic preset the styled bars hide inside the stock gryphon art; ask once to switch, never silently.

local LAYOUT_NAME = "CleanClassicExperience"

-- Edit Mode share-string export of the addon's reference layout; a failed parse falls back to the Modern preset.
local LAYOUT_STRING = "2 34 1 20 1 1 1 1 1 1 0 0 1 0 1 1 0 1 0 0 0 0 1 1 1 1 1 0 0 0 1 0 1 1 1 0 7 Default 31 0 0 0 0 0 UIParent 604.3 -813.0 -1 ##$$%/&('))$+$,$ 0 1 0 0 0 UIParent 604.3 -771.0 -1 ##$$%/&(')(#,# 0 2 0 0 0 UIParent 654.1 -872.2 -1 ##$$%/&&')(#,# 0 3 0 0 0 UIParent 1648.7 -324.1 -1 #$$$%/&(')(#,# 0 4 0 0 0 UIParent 1606.7 -324.1 -1 #$$$%/&(')(#,# 0 5 1 1 4 UIParent 0.0 0.0 -1 ##$$%/&(')(#,# 0 6 1 1 4 UIParent 0.0 -50.0 -1 ##$$%/&(')(#,# 0 7 1 1 4 UIParent 0.0 -100.0 -1 ##$$%/&(')(#,# 0 10 0 0 0 UIParent 708.7 -741.0 -1 ##$$&&'* 0 11 0 0 0 UIParent 704.5 -741.0 -1 ##$$&&'+,# 0 12 1 6 7 UIParent -470.5 51.0 -1 ##$$&('* 1 -1 0 7 7 UIParent 2.0 242.0 -1 ##$# 2 -1 0 0 0 UIParent 1488.7 -22.0 -1 ##$$%, 3 0 0 0 0 UIParent 378.3 -665.0 -1 3# 3 1 0 0 0 UIParent 1096.3 -665.0 -1 %$3# 3 2 1 6 7 UIParent 520.0 265.0 -1 %#&#3# 3 3 0 0 0 UIParent 35.3 -142.0 -1 '$(#)#-G.5/#1$3#5#6(7-7$ 3 4 0 0 0 UIParent 35.3 -142.0 -1 ,#-G.5/#0#1#2(5#6-7U 3 7 0 0 0 UIParent 446.3 -738.0 -1 3# 5 -1 1 7 7 UIParent 0.0 0.0 -1 # 6 0 0 0 0 UIParent 1079.7 -22.0 -1 ##$#%#&.(()( 6 1 0 0 0 UIParent 1184.7 -181.0 -1 ##$#%#'+(()( 8 -1 0 0 0 UIParent 54.0 -687.0 -1 #%$)$$%%&6 9 -1 0 0 0 UIParent 837.3 -733.0 -1 # 13 -1 0 0 0 UIParent 1473.7 -901.0 -1 ##$#%) 14 -1 0 0 0 UIParent 1475.2 -845.9 -1 ##$#%&&) 15 0 0 0 0 UIParent 597.3 -932.5 -1 &# 15 1 0 8 2 MainStatusTrackingBarContainer 0.0 2.0 -1 &# 16 -1 0 7 7 UIParent 640.0 502.0 -1 #( 18 -1 1 5 5 UIParent 0.0 0.0 -1 #- 24 -1 1 6 7 UIParent -240.0 46.0 -1 #"

-- Match the preset's identity, not its raw index, so a same-numbered user layout never matches.
local function onClassicPreset()
    if not (EditModeManagerFrame and EditModeManagerFrame:IsInitialized()) then
        return false
    end
    local info = EditModeManagerFrame:GetActiveLayoutInfo()
    return info
        and info.layoutType == Enum.EditModeLayoutType.Preset
        and info.layoutIndex == Enum.EditModePresetLayouts.Classic
end

-- Skip presets so a user layout named like ours is the only possible match.
local function findAddonLayout()
    for index, layout in ipairs(EditModeManagerFrame:GetLayouts()) do
        if layout.layoutType ~= Enum.EditModeLayoutType.Preset
            and layout.layoutName == LAYOUT_NAME then
            return index
        end
    end
end

-- ImportLayout saves and auto-activates in one step; a failed parse still gets the user off the Classic preset.
local function applyAddonLayout()
    local existing = findAddonLayout()
    if existing then
        C_EditMode.SetActiveLayout(existing)
        return
    end

    local info = C_EditMode.ConvertStringToLayoutInfo(LAYOUT_STRING)
    if info then
        -- MakeNewLayout needs highestLayoutIndexByType, which Blizzard only builds once the Edit Mode dropdown updates.
        if not EditModeManagerFrame.highestLayoutIndexByType then
            EditModeManagerFrame:CreateLayoutTbls()
        end
        EditModeManagerFrame:ImportLayout(info, Enum.EditModeLayoutType.Account, LAYOUT_NAME)
    else
        C_EditMode.SetActiveLayout(Enum.EditModePresetLayouts.Modern)
    end
end

-- Only the popup buttons set the flag, so a reload with the popup open asks again next login.
local function markAnswered()
    CleanClassicExperienceDB.layoutPromptAnswered = true
end

-- preferredIndex 3 keeps the stock popup slots Blizzard code reuses untainted.
StaticPopupDialogs["CLEAN_CLASSIC_EXPERIENCE_LAYOUT"] = {
    text = "CleanClassicExperience is built for the Modern layout. The Classic preset keeps action bars inside the stock artwork, hiding most of the addon's styling.\n\nSwitch to the addon's layout?",
    button1 = "Switch",
    button2 = "Keep Classic",
    OnAccept = function()
        markAnswered()
        applyAddonLayout()
    end,
    OnCancel = markAnswered,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

-- Switching layouts re-anchors protected bars, blocked in combat; PLAYER_REGEN_ENABLED retries a mid-combat login.
local function promptLayoutSwitch()
    CleanClassicExperienceDB = CleanClassicExperienceDB or {}
    if CleanClassicExperienceDB.layoutPromptAnswered then return end
    if InCombatLockdown() then return end
    if not onClassicPreset() then return end
    if StaticPopup_Visible("CLEAN_CLASSIC_EXPERIENCE_LAYOUT") then return end

    StaticPopup_Show("CLEAN_CLASSIC_EXPERIENCE_LAYOUT")
end

-- Layout info can land after PLAYER_ENTERING_WORLD; the layouts-updated event covers that ordering.
CleanClassicExperience.OnEvent(function()
    promptLayoutSwitch()
end, "PLAYER_ENTERING_WORLD", "EDIT_MODE_LAYOUTS_UPDATED", "PLAYER_REGEN_ENABLED")
