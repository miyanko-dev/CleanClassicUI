local SPACING = NewNativeUI.SPACING
local BORDER = NewNativeUI.BORDER
local BTN_SIZE = NewNativeUI.BTN_SIZE

local MARGIN = SPACING.LG
local BAR_GAP = SPACING.MD
local TIGHT_GAP = SPACING.XS

-- Vertical offset between MainMenuBar frame bottom and ActionButton1 frame bottom.
local AB1_INSET = 4
local MAIN_BAR_WIDTH = 512

local BAR3_SCALE = 0.8
local BAR3_BTN_W = 36
local BAR3_BTN_GAP = 6
local BAR3_BTN_COUNT = 12

local PET_SCALE = 0.8

-- Native PetActionBarFrame: 509x43, PetActionButton1 inset (36,2), 10 buttons of 30px with gaps mostly 8 (one 7), row width 371.
local PET_BAR_WIDTH = 509
local PET_ROW_WIDTH = 371
local PET_BTN1_INSET_X = 36
local PET_CENTER_SHIFT = (PET_BAR_WIDTH - PET_ROW_WIDTH) / 2 - PET_BTN1_INSET_X

-- Native StanceBarFrame: 29x32 (buttons extend beyond), StanceButton1 inset (11,3), 30px buttons with gap 7.
local STANCE_BTN_SIZE = 30
local STANCE_BTN_GAP = 7
local STANCE_BTN1_INSET_X = 11

local BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
}

NewNativeUILayout = NewNativeUILayout or {}
NewNativeUILayout.bar3Scale = BAR3_SCALE
NewNativeUILayout.btnSize = BTN_SIZE
NewNativeUILayout.afterLayout = NewNativeUILayout.afterLayout or {}

-- Visible width of the XP/rep stack, sized to match action bar 3's visible button row.
local function xpRepWidth()
    local outer = (BAR3_BTN_COUNT * BAR3_BTN_W + (BAR3_BTN_COUNT - 1) * BAR3_BTN_GAP + 2 * BORDER) * BAR3_SCALE
    return outer - 2 * BORDER
end

-- True while the cursor holds an action or the spellbook is open.
local gridShown = false

-- Hide cleanBorder on empty slots unless the grid is being shown for drag/spellbook.
local function syncBorder(btn)
    if not btn or not btn.cleanBorder or not btn.action then return end
    btn.cleanBorder:SetShown(HasAction(btn.action) or gridShown)
end

local function syncAllBorders()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, 12 do syncBorder(_G[prefix .. i]) end
    end
end

local function styleBtn(btn)
    if not btn then return end
    local name = btn:GetName()
    local norm = _G[name .. "NormalTexture"]
    if norm then norm:SetAlpha(0) end
    local float = _G[name .. "FloatingBG"]
    if float then float:SetAlpha(0) end
    local icon = _G[name .. "Icon"]
    if icon then icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
    NewNativeUI.ApplyBorder(btn)
    syncBorder(btn)
end

hooksecurefunc("ActionButton_Update", syncBorder)
hooksecurefunc("ActionButton_ShowGrid", syncBorder)
hooksecurefunc("ActionButton_HideGrid", syncBorder)

-- Force action bars 2 and 3 on; bars 4 and 5 remain user-controlled.
local function enableBars()
    if GetCVar("bottomLeftActionBar") ~= "1" then SetCVar("bottomLeftActionBar", "1") end
    if GetCVar("bottomRightActionBar") ~= "1" then SetCVar("bottomRightActionBar", "1") end
end

-- Captured from placeBars; used as the pet/stance base (AB2 visible top in screen px).
local petStanceBase = nil

-- Position XP/rep and action bars 1-5. Returns the screen-Y of AB2's visible top.
local function placeBars()
    local xpRepFrameBottom = MARGIN + BORDER
    local stackTop = xpRepFrameBottom
    local xpRepShown = false

    if MainMenuExpBar then
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, xpRepFrameBottom)
        MainMenuExpBar:SetWidth(xpRepWidth())
        if MainMenuExpBar:IsShown() then
            stackTop = stackTop + MainMenuExpBar:GetHeight()
            xpRepShown = true
        end
    end

    if ReputationWatchBar then
        ReputationWatchBar:ClearAllPoints()
        ReputationWatchBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, stackTop)
        ReputationWatchBar:SetWidth(xpRepWidth())
        if ReputationWatchStatusBar then ReputationWatchStatusBar:SetWidth(xpRepWidth()) end
        if ReputationWatchBar:IsShown() then
            stackTop = stackTop + ReputationWatchBar:GetHeight()
            xpRepShown = true
        end
    end

    local xpRepVisibleTop = xpRepShown and (stackTop + BORDER) or 0

    local ab3Border = BORDER * BAR3_SCALE
    local ab3FrameBottomScreen = xpRepVisibleTop + BAR_GAP + ab3Border
    MultiBarBottomRight:SetMovable(true)
    MultiBarBottomRight:SetUserPlaced(true)
    MultiBarBottomRight:Show()
    MultiBarBottomRight:SetScale(BAR3_SCALE)
    MultiBarBottomRight:ClearAllPoints()
    MultiBarBottomRight:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, ab3FrameBottomScreen / BAR3_SCALE)
    local ab3VisibleTop = ab3FrameBottomScreen + BTN_SIZE * BAR3_SCALE + ab3Border

    local ab1FrameBottomScreen = ab3VisibleTop + BAR_GAP + BORDER
    MainMenuBar:SetMovable(true)
    MainMenuBar:SetUserPlaced(true)
    MainMenuBar:SetWidth(MAIN_BAR_WIDTH)
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, ab1FrameBottomScreen - AB1_INSET)
    local ab1VisibleTop = ab1FrameBottomScreen + BTN_SIZE + BORDER

    -- Anchor AB2 to ActionButton1 so AB2's first button shares X with AB1's first button.
    local ab2AnchorY = TIGHT_GAP + 2 * BORDER
    MultiBarBottomLeft:SetMovable(true)
    MultiBarBottomLeft:SetUserPlaced(true)
    MultiBarBottomLeft:Show()
    MultiBarBottomLeft:ClearAllPoints()
    MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, ab2AnchorY)
    local ab2VisibleTop = ab1VisibleTop + TIGHT_GAP + BTN_SIZE + 2 * BORDER

    return ab2VisibleTop
end

-- MultiBarRight (bar 4) and MultiBarLeft (bar 5) live inside VerticalMultiBarsContainer.
-- Reposition the container; Blizzard handles the bars inside it.
local function placeVerticalBars()
    if InCombatLockdown() or not VerticalMultiBarsContainer then return end
    VerticalMultiBarsContainer:ClearAllPoints()
    VerticalMultiBarsContainer:SetPoint("RIGHT", UIParent, "RIGHT", -(MARGIN + BORDER), 0)
end

local function hideChrome()
    MainMenuBarLeftEndCap:Hide()
    MainMenuBarRightEndCap:Hide()
    MainMenuBarPageNumber:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()
    MainMenuBarMaxLevelBar:Hide()
    MainMenuBarOverlayFrame:Hide()
    if MainMenuBarTextureExtender then MainMenuBarTextureExtender:Hide() end
    NewNativeUI.HideForever(MainMenuBarPerformanceBarFrame)
    for i = 0, 3 do
        if _G["MainMenuBarTexture" .. i] then _G["MainMenuBarTexture" .. i]:Hide() end
        if _G["MainMenuMaxLevelBar" .. i] then _G["MainMenuMaxLevelBar" .. i]:Hide() end
    end
    for i = 0, 1 do
        NewNativeUI.HideForever(_G["SlidingActionBarTexture" .. i])
    end
end

local function styleAllButtons()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, 12 do styleBtn(_G[prefix .. i]) end
    end
    for i = 1, NUM_STANCE_SLOTS do
        local btn = _G["StanceButton" .. i]
        if btn then
            for j = 1, 3 do
                local tex = _G[btn:GetName() .. "NormalTexture" .. j]
                if tex then tex:SetAlpha(0) end
            end
            styleBtn(btn)
        end
    end
    for i = 1, NUM_PET_ACTION_SLOTS or 10 do
        local btn = _G["PetActionButton" .. i]
        if btn then
            for _, suffix in ipairs({ "NormalTexture", "NormalTexture2" }) do
                local n = _G[btn:GetName() .. suffix]
                if n then n:SetAlpha(0) end
            end
            local icon = _G[btn:GetName() .. "Icon"]
            if icon then icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
            NewNativeUI.ApplyBorder(btn)
        end
    end
end

-- Mirrors PetActionBar_OnEvent's show/hide test: PetHasActionBar +
-- UnitIsVisible("pet"). Reads the underlying state so stance repositions
-- immediately on mount, not 0.09s later when the slide-out completes.
local function isPetVisible()
    if not (PetActionBarFrame and PetActionButton1) then return false end
    if PetHasActionBar and not PetHasActionBar() then return false end
    if UnitIsVisible and not UnitIsVisible("pet") then return false end
    return true
end

local function placePet()
    if InCombatLockdown() or not petStanceBase then return end
    if not (PetActionBarFrame and PetActionButton1) then return end

    PetActionBarFrame.ignoreFramePositionManager = true
    if not PetActionBarFrame:IsUserPlaced() then
        PetActionBarFrame:SetMovable(true)
        PetActionBarFrame:SetUserPlaced(true)
    end
    PetActionBarFrame:SetScale(PET_SCALE)

    local petBorder = BORDER * PET_SCALE
    local petFrameBottomScreen = petStanceBase + TIGHT_GAP + petBorder
    PetActionBarFrame:ClearAllPoints()
    PetActionBarFrame:SetPoint("BOTTOM", UIParent, "BOTTOM",
        PET_CENTER_SHIFT, petFrameBottomScreen / PET_SCALE)
end

local function placeStance()
    if InCombatLockdown() or not petStanceBase then return end
    local numForms = GetNumShapeshiftForms()
    if not (StanceBarFrame and StanceBarFrame:IsShown() and numForms > 0) then return end
    local base = petStanceBase
    if isPetVisible() then
        local petBorder = BORDER * PET_SCALE
        local petButtonH = PetActionButton1:GetHeight() * PET_SCALE
        base = base + TIGHT_GAP + petBorder + petButtonH + petBorder
    end
    local stanceFrameBottomScreen = base + TIGHT_GAP + BORDER

    StanceBarFrame.ignoreFramePositionManager = true
    if not StanceBarFrame:IsUserPlaced() then
        StanceBarFrame:SetMovable(true)
        StanceBarFrame:SetUserPlaced(true)
    end
    local rowWidth = STANCE_BTN_SIZE * numForms + STANCE_BTN_GAP * (numForms - 1)
    StanceBarFrame:ClearAllPoints()
    StanceBarFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM",
        -(STANCE_BTN1_INSET_X + rowWidth / 2), stanceFrameBottomScreen)
    StanceBarLeft:SetAlpha(0)
    StanceBarMiddle:SetAlpha(0)
    StanceBarRight:SetAlpha(0)
end

hooksecurefunc("ActionButton_OnUpdate", function(self)
    if not self or not self.action then return end
    local usable = IsUsableAction(self.action)
    local inRange = IsActionInRange(self.action)
    self.icon:SetAlpha((not usable or inRange == false) and 0.9 or 1.0)
end)

-- Replace the pet bar's slide-time repositioner with a no-op. One-time method
-- swap, zero per-frame cost — Blizzard's slide state machine still drives
-- mode/Show/Hide and the OnUpdate range timer keeps working, but the per-tick
-- SetPoint to MainMenuBar that fights our anchor is gone.
if PetActionBarFrame and PetActionBarFrame.UpdatePositionValues then
    PetActionBarFrame.UpdatePositionValues = function() end
end

local function runLayout()
    if InCombatLockdown() then return end
    enableBars()
    petStanceBase = placeBars()
    placeVerticalBars()
    hideChrome()
    styleAllButtons()
    syncAllBorders()
    placePet()
    placeStance()
    for _, cb in ipairs(NewNativeUILayout.afterLayout) do cb() end
end

-- Blizzard runs MultiActionBar_Update whenever bars 4 or 5 are toggled on/off.
if MultiActionBar_Update then hooksecurefunc("MultiActionBar_Update", placeVerticalBars) end

NewNativeUILayout.scheduleLayout = runLayout
NewNativeUILayout.relayout = runLayout

-- Events from Gethe/wow-ui-source classic_era:
--   PetActionBar.lua/PetActionBar_OnEvent drives Show/HidePetActionBar on
--     PET_BAR_UPDATE, UNIT_PET (arg1=="player"), PET_UI_UPDATE,
--     UPDATE_VEHICLE_ACTIONBAR. PLAYER_MOUNT_DISPLAY_CHANGED also registered.
--   StanceBar reacts to UPDATE_SHAPESHIFT_FORM(S).
NewNativeUI.OnEvent(function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        runLayout()
    elseif event == "UNIT_PET" then
        if arg1 == "player" then
            placePet()
            placeStance()
        end
    elseif event == "PET_BAR_UPDATE" or event == "PET_UI_UPDATE"
        or event == "UPDATE_VEHICLE_ACTIONBAR" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        placePet()
        placeStance()
    elseif event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_FORMS" then
        placeStance()
    elseif event == "ACTIONBAR_SHOWGRID" then
        gridShown = true
        syncAllBorders()
    elseif event == "ACTIONBAR_HIDEGRID" then
        gridShown = false
        syncAllBorders()
    end
end,
"PLAYER_ENTERING_WORLD",
"PET_BAR_UPDATE", "UNIT_PET", "PET_UI_UPDATE", "UPDATE_VEHICLE_ACTIONBAR",
"PLAYER_MOUNT_DISPLAY_CHANGED",
"UPDATE_SHAPESHIFT_FORM", "UPDATE_SHAPESHIFT_FORMS",
"ACTIONBAR_SHOWGRID", "ACTIONBAR_HIDEGRID")
