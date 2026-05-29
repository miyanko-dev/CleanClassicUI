local SPACING = CleanClassicUI.SPACING
local BORDER = CleanClassicUI.BORDER
local BTN_SIZE = CleanClassicUI.BTN_SIZE

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
local PET_BTN1_INSET_Y = 2
local PET_BTN_SIZE = 30
local PET_CENTER_SHIFT = (PET_BAR_WIDTH - PET_ROW_WIDTH) / 2 - PET_BTN1_INSET_X

-- Native StanceBarFrame: 29x32 (buttons extend beyond), StanceButton1 inset (11,3), 30px buttons with gap 7.
local STANCE_BTN_SIZE = 30
local STANCE_BTN_GAP = 7
local STANCE_BTN1_INSET_X = 11
local STANCE_BTN1_INSET_Y = 3

-- AB1 to AB2 spacing (TIGHT_GAP + 2*BORDER) used between AB2 and the pet/stance bar above it.
-- AB3 to AB1 spacing (BAR_GAP + BORDER) used between the topmost bottom-bar element and the castbar.
local INNER_BAR_GAP = TIGHT_GAP + 2 * BORDER
local OUTER_BAR_GAP = BAR_GAP + BORDER

local BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
}

CleanClassicUILayout = CleanClassicUILayout or {}
CleanClassicUILayout.bar3Scale = BAR3_SCALE
CleanClassicUILayout.btnSize = BTN_SIZE
CleanClassicUILayout.afterLayout = CleanClassicUILayout.afterLayout or {}

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
    CleanClassicUI.ApplyBorder(btn)
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
-- MultiBarRight is anchored TOPRIGHT at (0,0) inside a 141x503 container that
-- matches its height, so the container's BOTTOMRIGHT coincides with MultiBarRight's
-- BOTTOMRIGHT. Anchor the container to the backpack button: horizontal margin
-- matches ContainerFrame1 (see Bags.lua), vertical gap is fixed at SPACING.XXL so
-- AB4/AB5 sit a comfortable distance above the bag row.
local function placeVerticalBars()
    if InCombatLockdown() or not VerticalMultiBarsContainer or not MainMenuBarBackpackButton then return end
    VerticalMultiBarsContainer:ClearAllPoints()
    VerticalMultiBarsContainer:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOPRIGHT", SPACING.XS, SPACING.XXL)
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
    CleanClassicUI.HideForever(MainMenuBarPerformanceBarFrame)
    for i = 0, 3 do
        if _G["MainMenuBarTexture" .. i] then _G["MainMenuBarTexture" .. i]:Hide() end
        if _G["MainMenuMaxLevelBar" .. i] then _G["MainMenuMaxLevelBar" .. i]:Hide() end
    end
    for i = 0, 1 do
        CleanClassicUI.HideForever(_G["SlidingActionBarTexture" .. i])
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
            CleanClassicUI.ApplyBorder(btn)
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

-- Replace PetActionBarMixin.UpdatePositionValues on the frame so every Blizzard
-- caller (ShowPetActionBar, PetActionBar_OnUpdate, UIParentManageFramePositions)
-- runs our placement instead of Blizzard's, which would otherwise re-anchor the
-- bar against MainMenuBar.TOP and fight our SetPoint. The replacement is insecure
-- Lua, but the InCombatLockdown guard means it never calls SetPoint while combat
-- protection is active, so it can't trigger ADDON_ACTION_BLOCKED when the panel
-- manager reruns it. Anchoring directly to UIParent (no SetUserPlaced) avoids
-- the original taint source.
local function placePetBar(self)
    if InCombatLockdown() or not petStanceBase then return end
    if not (self and PetActionButton1) then return end

    self:SetScale(PET_SCALE)

    -- Pet button BOTTOM sits INNER_BAR_GAP above AB2's visible top, matching AB1 to AB2.
    -- PetActionButton1 is inset PET_BTN1_INSET_Y self-units above PetActionBarFrame.BOTTOM,
    -- so subtract that scaled inset so the visible row (not the frame) lands at the gap.
    local petFrameBottomScreen = petStanceBase + INNER_BAR_GAP - PET_BTN1_INSET_Y * PET_SCALE

    self:ClearAllPoints()
    self:SetPoint("BOTTOM", UIParent, "BOTTOM",
        PET_CENTER_SHIFT, petFrameBottomScreen / PET_SCALE)
end

local function placePet()
    if PetActionBarFrame then placePetBar(PetActionBarFrame) end
end

local function placeStance()
    if InCombatLockdown() or not petStanceBase then return end
    local numForms = GetNumShapeshiftForms()
    if not (StanceBarFrame and StanceBarFrame:IsShown() and numForms > 0) then return end

    -- Stance button BOTTOM sits INNER_BAR_GAP above whatever bar is directly below it:
    -- pet button TOP if the pet bar is visible, otherwise AB2's visible top.
    local stanceBtnBottomScreen
    if isPetVisible() then
        local petBtnBottomScreen = petStanceBase + INNER_BAR_GAP
        local petBtnTopScreen = petBtnBottomScreen + PET_BTN_SIZE * PET_SCALE
        stanceBtnBottomScreen = petBtnTopScreen + INNER_BAR_GAP
    else
        stanceBtnBottomScreen = petStanceBase + INNER_BAR_GAP
    end
    local stanceFrameBottomScreen = stanceBtnBottomScreen - STANCE_BTN1_INSET_Y

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

-- Returns the Y delta (screen px) from AB2 visible top to where CastingBarFrame.BOTTOM
-- should land, so the cast bar sits OUTER_BAR_GAP above the topmost visible bottom-bar
-- element (stance if shown, else pet if shown, else AB2 itself).
CleanClassicUILayout.castbarYOffsetAboveAB2 = function()
    if not petStanceBase then return OUTER_BAR_GAP end
    local topAboveAB2 = 0
    if isPetVisible() then
        topAboveAB2 = INNER_BAR_GAP + PET_BTN_SIZE * PET_SCALE
    end
    local numForms = GetNumShapeshiftForms and GetNumShapeshiftForms() or 0
    if StanceBarFrame and StanceBarFrame:IsShown() and numForms > 0 then
        topAboveAB2 = topAboveAB2 + INNER_BAR_GAP + STANCE_BTN_SIZE
    end
    return topAboveAB2 + OUTER_BAR_GAP
end

-- Screen-Y where CastingBarFrame.BOTTOM would land if a stance bar row sat above
-- AB2, regardless of current class/state. Used by Auto Position so unit frames
-- adopt the higher peripheral-vision position even when no pet/stance bar exists.
CleanClassicUILayout.castBottomWithStanceOrPet = function()
    if not petStanceBase then return nil end
    return petStanceBase + INNER_BAR_GAP + STANCE_BTN_SIZE + OUTER_BAR_GAP
end

hooksecurefunc("ActionButton_OnUpdate", function(self)
    if not self or not self.action then return end
    local usable = IsUsableAction(self.action)
    local inRange = IsActionInRange(self.action)
    self.icon:SetAlpha((not usable or inRange == false) and 0.9 or 1.0)
end)

-- Install our placement as PetActionBarFrame:UpdatePositionValues so every
-- Blizzard caller routes through it. The original Blizzard method is replaced
-- on the frame instance (PetActionBarMixin copies methods onto the frame at
-- creation), so calls via PetActionBarFrame:UpdatePositionValues() resolve to
-- placePetBar instead of Blizzard's anchor-against-parent routine.
if PetActionBarFrame then
    PetActionBarFrame.UpdatePositionValues = placePetBar
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
    for _, cb in ipairs(CleanClassicUILayout.afterLayout) do cb() end
end

-- Blizzard runs MultiActionBar_Update whenever bars 4 or 5 are toggled on/off.
if MultiActionBar_Update then hooksecurefunc("MultiActionBar_Update", placeVerticalBars) end

CleanClassicUILayout.scheduleLayout = runLayout
CleanClassicUILayout.relayout = runLayout

-- Events from Gethe/wow-ui-source classic_era:
--   PetActionBar.lua/PetActionBar_OnEvent drives Show/HidePetActionBar on
--     PET_BAR_UPDATE, UNIT_PET (arg1=="player"), PET_UI_UPDATE,
--     UPDATE_VEHICLE_ACTIONBAR. PLAYER_MOUNT_DISPLAY_CHANGED also registered.
--   StanceBar reacts to UPDATE_SHAPESHIFT_FORM(S).
CleanClassicUI.OnEvent(function(self, event, arg1)
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
    elseif event == "PLAYER_REGEN_ENABLED" then
        placePet()
        placeStance()
    end
end,
"PLAYER_ENTERING_WORLD",
"PET_BAR_UPDATE", "UNIT_PET", "PET_UI_UPDATE", "UPDATE_VEHICLE_ACTIONBAR",
"PLAYER_MOUNT_DISPLAY_CHANGED",
"UPDATE_SHAPESHIFT_FORM", "UPDATE_SHAPESHIFT_FORMS",
"ACTIONBAR_SHOWGRID", "ACTIONBAR_HIDEGRID",
"PLAYER_REGEN_ENABLED")
