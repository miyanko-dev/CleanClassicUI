local SPACING = CleanUI.SPACING
local BORDER = CleanUI.BORDER
local BTN_SIZE = CleanUI.BTN_SIZE

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
local PET_COUNT = 10
local PET_GAP = 6

local STANCE_GAP = 6

local BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
}

CleanUILayout = CleanUILayout or {}
CleanUILayout.bar3Scale = BAR3_SCALE
CleanUILayout.btnSize = BTN_SIZE
CleanUILayout.afterLayout = CleanUILayout.afterLayout or {}

-- Visible width of the XP/rep stack, sized to match action bar 3's visible button row.
local function xpRepWidth()
    local outer = (BAR3_BTN_COUNT * BAR3_BTN_W + (BAR3_BTN_COUNT - 1) * BAR3_BTN_GAP + 2 * BORDER) * BAR3_SCALE
    return outer - 2 * BORDER
end

-- Center a row of equal-width buttons; screenY is the row frame bottom in UIParent pixels.
local function centerRow(prefix, count, gap, scale, screenY)
    local first = _G[prefix .. "1"]
    if not first then return end
    local w = first:GetWidth()
    local startX = -(count * w + (count - 1) * gap - w) / 2
    local s = scale or 1
    first:ClearAllPoints()
    first:SetPoint("BOTTOM", UIParent, "BOTTOM", startX, screenY / s)
    for i = 2, count do
        local cur, prev = _G[prefix .. i], _G[prefix .. (i - 1)]
        if cur and prev then
            cur:ClearAllPoints()
            cur:SetPoint("LEFT", prev, "RIGHT", gap, 0)
        end
    end
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
    CleanUI.ApplyBorder(btn)
    syncBorder(btn)
end

hooksecurefunc("ActionButton_Update", syncBorder)

local function enableBars()
    if GetCVar("bottomLeftActionBar") ~= "1" then SetCVar("bottomLeftActionBar", "1") end
    if GetCVar("bottomRightActionBar") ~= "1" then SetCVar("bottomRightActionBar", "1") end
end

-- Position XP/rep and action bars 1-3 bottom-up using border-aware visible gaps.
-- Returns the screen-Y of action bar 2's visible top, used as the pet/stance base.
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

    if VerticalMultiBarsContainer then
        VerticalMultiBarsContainer:ClearAllPoints()
        VerticalMultiBarsContainer:SetPoint("RIGHT", UIParent, "RIGHT", -MARGIN, 0)
    end

    return ab2VisibleTop
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
    CleanUI.HideForever(MainMenuBarPerformanceBarFrame)
    for i = 0, 3 do
        if _G["MainMenuBarTexture" .. i] then _G["MainMenuBarTexture" .. i]:Hide() end
        if _G["MainMenuMaxLevelBar" .. i] then _G["MainMenuMaxLevelBar" .. i]:Hide() end
    end
    for i = 0, 1 do
        CleanUI.HideForever(_G["SlidingActionBarTexture" .. i])
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
    for i = 1, PET_COUNT do
        local btn = _G["PetActionButton" .. i]
        if btn then
            for _, suffix in ipairs({ "NormalTexture", "NormalTexture2" }) do
                local n = _G[btn:GetName() .. suffix]
                if n then n:SetAlpha(0) end
            end
            local icon = _G[btn:GetName() .. "Icon"]
            if icon then icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
            CleanUI.ApplyBorder(btn)
        end
    end
end

-- Captured from placeBars; used as the pet/stance base (AB2 visible top in screen px).
local petStanceBase = nil

local function isPetVisible()
    return PetActionBarFrame and PetActionBarFrame:IsShown()
        and PetActionButton1 and PetActionButton1:IsShown()
end

local function placePet()
    if InCombatLockdown() or not petStanceBase then return end
    if not isPetVisible() then return end
    PetActionBarFrame:SetScale(PET_SCALE)
    local petBorder = BORDER * PET_SCALE
    local petFrameBottomScreen = petStanceBase + TIGHT_GAP + petBorder
    centerRow("PetActionButton", PET_COUNT, PET_GAP, PET_SCALE, petFrameBottomScreen)
end

local function placeStance()
    if InCombatLockdown() or not petStanceBase then return end
    if not (StanceBarFrame and StanceBarFrame:IsShown() and GetNumShapeshiftForms() > 0) then return end
    local base = petStanceBase
    if isPetVisible() then
        local petBorder = BORDER * PET_SCALE
        local petButtonH = (PetActionButton1 and PetActionButton1:GetHeight() or BTN_SIZE) * PET_SCALE
        base = base + TIGHT_GAP + petBorder + petButtonH + petBorder
    end
    local stanceFrameBottomScreen = base + TIGHT_GAP + BORDER
    centerRow("StanceButton", GetNumShapeshiftForms(), STANCE_GAP, 1, stanceFrameBottomScreen)
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

-- Hide the border on empty slots unless the grid is being shown (drag, spellbook, CVar).
local function syncBorder(btn)
    if not btn or not btn.cleanBorder or not btn.action then return end
    local hasAction = HasAction(btn.action)
    local showGrid = btn:GetAttribute("showgrid") or 0
    btn.cleanBorder:SetShown(hasAction or showGrid > 0)
end

hooksecurefunc("ActionButton_ShowGrid", syncBorder)
hooksecurefunc("ActionButton_HideGrid", syncBorder)
hooksecurefunc("ActionButton_Update", syncBorder)

local function syncAllBorders()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, 12 do syncBorder(_G[prefix .. i]) end
    end
end

local isLayoutDone = false

local function runLayout()
    if isLayoutDone or InCombatLockdown() then return end
    enableBars()
    petStanceBase = placeBars()
    hideChrome()
    styleAllButtons()
    syncAllBorders()
    placePet()
    placeStance()
    syncAllBorders()
    isLayoutDone = true
    for _, cb in ipairs(CleanUILayout.afterLayout) do cb() end
end

local function relayout()
    isLayoutDone = false
    C_Timer.After(0, runLayout)
end

CleanUILayout.scheduleLayout = runLayout
CleanUILayout.relayout = relayout

CleanUI.OnEvent(function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        C_Timer.After(0, runLayout)
    elseif event == "PLAYER_REGEN_ENABLED" then
        if not isLayoutDone then C_Timer.After(0, runLayout) end
    elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
        relayout()
    elseif event == "PET_BAR_UPDATE" or event == "UNIT_PET" then
        C_Timer.After(0, function()
            placePet()
            placeStance()
        end)
    elseif event == "UPDATE_SHAPESHIFT_FORM" then
        C_Timer.After(0, placeStance)
    elseif event == "ACTIONBAR_SHOWGRID" then
        gridShown = true
        syncAllBorders()
    elseif event == "ACTIONBAR_HIDEGRID" then
        gridShown = false
        syncAllBorders()
    end
end,
"PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UI_SCALE_CHANGED",
"DISPLAY_SIZE_CHANGED", "PET_BAR_UPDATE", "UNIT_PET", "UPDATE_SHAPESHIFT_FORM",
"ACTIONBAR_SHOWGRID", "ACTIONBAR_HIDEGRID")
