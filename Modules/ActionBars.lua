local MARGIN = 24
local UNIT_FRAME_GAP = 72
local BAR1_BAR2_GAP = 8
local BAR2_PET_GAP = 8
local BAR3_SCALE = 0.8
local PET_SCALE = 0.8
local PET_COUNT = 10
local PET_GAP = 6
local STANCE_GAP = 6
local BUTTON_SIZE = 36
-- ActionButton1 sits at MainMenuBar's BOTTOMLEFT(8, 4), so its visible bottom
-- is 4px above MainMenuBar's frame bottom.
local AB1_BOTTOM_OFFSET = 4
-- PlayerFrameManaBar: TOPLEFT(106, -52) size 119x12 within PlayerFrame, so
-- its BOTTOMRIGHT lives at PF.TOPLEFT + (225, -64). To place that point at
-- MBL.Button1.TOPLEFT + (0, MARGIN) we offset PF.TOPLEFT by (-225, MARGIN+64).
-- TargetFrameManaBar: TOPRIGHT(-106, -52) size 119x12 within TargetFrame, so
-- its BOTTOMLEFT lives at TF.TOPLEFT + (7, -64). Mirror for target with
-- offset (-7, MARGIN+64) anchored to MBL.Button12.TOPRIGHT.
local PF_MANA_BR_X = 225
local TF_MANA_BL_X = 7
local UF_MANA_TO_TOP = 64

CleanUIClassicLayout = CleanUIClassicLayout or {}

local function ensureBarsEnabled()
    if InCombatLockdown() then return end
    if GetCVar("bottomLeftActionBar") ~= "1" then SetCVar("bottomLeftActionBar", "1") end
    if GetCVar("bottomRightActionBar") ~= "1" then SetCVar("bottomRightActionBar", "1") end
end

local function positionLayout()
    if InCombatLockdown() then return end

    local y = MARGIN
    local barWidth = 512 * BAR3_SCALE

    if MainMenuExpBar then
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y)
        MainMenuExpBar:SetWidth(barWidth)
        if MainMenuExpBar:IsShown() then y = y + MainMenuExpBar:GetHeight() end
    end

    if ReputationWatchBar then
        ReputationWatchBar:ClearAllPoints()
        ReputationWatchBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y)
        ReputationWatchBar:SetWidth(barWidth)
        if ReputationWatchStatusBar then ReputationWatchStatusBar:SetWidth(barWidth) end
        if ReputationWatchBar:IsShown() then y = y + ReputationWatchBar:GetHeight() end
    end

    y = y + MARGIN

    -- Action bar 3 (MultiBarBottomRight)
    MultiBarBottomRight:Show()
    MultiBarBottomRight:SetScale(BAR3_SCALE)
    MultiBarBottomRight:ClearAllPoints()
    MultiBarBottomRight:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y / BAR3_SCALE)
    MultiBarBottomRight:SetMovable(true)
    MultiBarBottomRight:SetUserPlaced(true)
    y = y + BUTTON_SIZE * BAR3_SCALE + MARGIN

    -- Action bar 1 (MainMenuBar)
    MainMenuBar:SetWidth(512)
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y - AB1_BOTTOM_OFFSET)
    MainMenuBar:SetMovable(true)
    MainMenuBar:SetUserPlaced(true)
    y = y + BUTTON_SIZE  -- top of ActionButton1 row

    -- Action bar 2 (MultiBarBottomLeft) anchored to ActionButton1 for X-alignment
    MultiBarBottomLeft:Show()
    MultiBarBottomLeft:ClearAllPoints()
    MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, BAR1_BAR2_GAP)
    MultiBarBottomLeft:SetMovable(true)
    MultiBarBottomLeft:SetUserPlaced(true)
    y = y + BAR1_BAR2_GAP + BUTTON_SIZE

    -- Pet bar
    if PetActionBarFrame and PetActionBarFrame:IsShown() and PetActionButton1 and PetActionButton1:IsShown() then
        y = y + BAR2_PET_GAP
        PetActionBarFrame:SetScale(PET_SCALE)
        local btnW = PetActionButton1:GetWidth()
        local totalW = PET_COUNT * btnW + (PET_COUNT - 1) * PET_GAP
        local firstX = -(totalW - btnW) / 2
        PetActionButton1:ClearAllPoints()
        PetActionButton1:SetPoint("BOTTOM", UIParent, "BOTTOM", firstX, y / PET_SCALE)
        local prev = PetActionButton1
        for i = 2, PET_COUNT do
            local btn = _G["PetActionButton" .. i]
            btn:ClearAllPoints()
            btn:SetPoint("LEFT", prev, "RIGHT", PET_GAP, 0)
            prev = btn
        end
        y = y + PetActionButton1:GetHeight() * PET_SCALE
    end

    -- Stance bar
    if StanceBarFrame and StanceBarFrame:IsShown() and GetNumShapeshiftForms() > 0 then
        y = y + BAR2_PET_GAP
        local count = GetNumShapeshiftForms()
        local btn1 = _G["StanceButton1"]
        local btnW = btn1:GetWidth()
        local totalW = count * btnW + (count - 1) * STANCE_GAP
        local firstX = -(totalW - btnW) / 2
        local prev
        for i = 1, count do
            local btn = _G["StanceButton" .. i]
            btn:ClearAllPoints()
            if not prev then
                btn:SetPoint("BOTTOM", UIParent, "BOTTOM", firstX, y)
            else
                btn:SetPoint("LEFT", prev, "RIGHT", STANCE_GAP, 0)
            end
            prev = btn
        end
        StanceBarLeft:SetAlpha(0)
        StanceBarMiddle:SetAlpha(0)
        StanceBarRight:SetAlpha(0)
        y = y + BUTTON_SIZE
    end

    CleanUIClassicLayout.castBarY = y + MARGIN

    -- Right-side vertical bars (4 + 5): 24px margin from screen right edge.
    -- MultiBarLeft (5) is anchored to MultiBarRight (4) by Blizzard, so moving
    -- the container moves both together.
    if VerticalMultiBarsContainer then
        VerticalMultiBarsContainer:ClearAllPoints()
        VerticalMultiBarsContainer:SetPoint("RIGHT", UIParent, "RIGHT", -MARGIN, 0)
    end

    -- Player & target frames anchored to bar 2's first/last button
    if PlayerFrame and MultiBarBottomLeftButton1 then
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint("TOPLEFT", MultiBarBottomLeftButton1, "TOPLEFT",
            -PF_MANA_BR_X, UNIT_FRAME_GAP + UF_MANA_TO_TOP)
        PlayerFrame:SetUserPlaced(true)
    end
    if TargetFrame and MultiBarBottomLeftButton12 then
        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint("TOPLEFT", MultiBarBottomLeftButton12, "TOPRIGHT",
            -TF_MANA_BL_X, UNIT_FRAME_GAP + UF_MANA_TO_TOP)
        TargetFrame:SetUserPlaced(true)
    end

    -- Hide default art
    MainMenuBarLeftEndCap:Hide()
    MainMenuBarRightEndCap:Hide()
    MainMenuBarPageNumber:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()
    MainMenuBarMaxLevelBar:Hide()
    MainMenuBarOverlayFrame:Hide()
    if MainMenuBarTextureExtender then MainMenuBarTextureExtender:Hide() end
    MainMenuBarPerformanceBarFrame:Hide()
    MainMenuBarPerformanceBarFrame.Show = MainMenuBarPerformanceBarFrame.Hide

    for i = 0, 3 do
        _G["MainMenuBarTexture" .. i]:Hide()
        _G["MainMenuMaxLevelBar" .. i]:Hide()
    end

    for i = 0, 1 do
        local t = _G["SlidingActionBarTexture" .. i]
        t:Hide()
        t.Show = t.Hide
    end
end

local function stripFloatingBG(name)
    local bg = _G[name .. "FloatingBG"]
    if bg then bg:SetAlpha(0) end
end

local function stripButtons()
    for i = 1, 12 do
        stripFloatingBG("ActionButton" .. i)
        stripFloatingBG("MultiBarBottomLeftButton" .. i)
        stripFloatingBG("MultiBarBottomRightButton" .. i)
        stripFloatingBG("MultiBarRightButton" .. i)
        stripFloatingBG("MultiBarLeftButton" .. i)
    end
end

local function updateUsability(self)
    if not self or not self.action then return end
    local usable = IsUsableAction(self.action)
    local inRange = IsActionInRange(self.action)
    self.icon:SetAlpha((not usable or inRange == false) and 0.9 or 1.0)
end

hooksecurefunc("ActionButton_OnUpdate", updateUsability)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PET_BAR_UPDATE")
f:RegisterEvent("UNIT_PET")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
f:SetScript("OnEvent", function()
    ensureBarsEnabled()
    positionLayout()
    stripButtons()
end)
