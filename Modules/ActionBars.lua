local SCREEN_MARGIN = 24
local UNIT_FRAME_GAP = 72
local BAR_GAP = 8
local PET_GAP = 6
local STANCE_GAP = 6
local BUTTON_SIZE = 36
local BAR3_SCALE = 0.8
local PET_SCALE = 0.8
local PET_COUNT = 10

-- ActionButton1 sits 4px above MainMenuBar's frame bottom.
local AB1_BOTTOM_INSET = 4

-- Mana-bar offsets used to align Player/Target frames with action bar 2.
-- Derived from Blizzard's PlayerFrame/TargetFrame XML insets.
local PLAYER_MANA_RIGHT = 225
local TARGET_MANA_LEFT = 7
local MANA_TO_FRAME_TOP = 64

CleanUIClassicLayout = CleanUIClassicLayout or {}

local function enableExtraBars()
    if InCombatLockdown() then return end
    if GetCVar("bottomLeftActionBar") ~= "1" then SetCVar("bottomLeftActionBar", "1") end
    if GetCVar("bottomRightActionBar") ~= "1" then SetCVar("bottomRightActionBar", "1") end
end

local function keepHidden(frame)
    if not frame then return end
    frame:Hide()
    frame.Show = frame.Hide
end

local function centerRow(prefix, count, gap, scale, y)
    local first = _G[prefix .. "1"]
    local width = first:GetWidth()
    local totalWidth = count * width + (count - 1) * gap
    local startX = -(totalWidth - width) / 2
    first:ClearAllPoints()
    first:SetPoint("BOTTOM", UIParent, "BOTTOM", startX, y / scale)
    for i = 2, count do
        local btn = _G[prefix .. i]
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", _G[prefix .. (i - 1)], "RIGHT", gap, 0)
    end
end

local function applyLayout()
    if InCombatLockdown() then return end

    local y = SCREEN_MARGIN
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

    y = y + SCREEN_MARGIN

    MultiBarBottomRight:Show()
    MultiBarBottomRight:SetScale(BAR3_SCALE)
    MultiBarBottomRight:ClearAllPoints()
    MultiBarBottomRight:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y / BAR3_SCALE)
    MultiBarBottomRight:SetMovable(true)
    MultiBarBottomRight:SetUserPlaced(true)
    y = y + BUTTON_SIZE * BAR3_SCALE + SCREEN_MARGIN

    MainMenuBar:SetWidth(512)
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y - AB1_BOTTOM_INSET)
    MainMenuBar:SetMovable(true)
    MainMenuBar:SetUserPlaced(true)
    y = y + BUTTON_SIZE

    MultiBarBottomLeft:Show()
    MultiBarBottomLeft:ClearAllPoints()
    MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, BAR_GAP)
    MultiBarBottomLeft:SetMovable(true)
    MultiBarBottomLeft:SetUserPlaced(true)
    y = y + BAR_GAP + BUTTON_SIZE

    if PetActionBarFrame and PetActionBarFrame:IsShown()
        and PetActionButton1 and PetActionButton1:IsShown() then
        y = y + BAR_GAP
        PetActionBarFrame:SetScale(PET_SCALE)
        centerRow("PetActionButton", PET_COUNT, PET_GAP, PET_SCALE, y)
        y = y + PetActionButton1:GetHeight() * PET_SCALE
    end

    if StanceBarFrame and StanceBarFrame:IsShown() and GetNumShapeshiftForms() > 0 then
        y = y + BAR_GAP
        centerRow("StanceButton", GetNumShapeshiftForms(), STANCE_GAP, 1, y)
        StanceBarLeft:SetAlpha(0)
        StanceBarMiddle:SetAlpha(0)
        StanceBarRight:SetAlpha(0)
        y = y + BUTTON_SIZE
    end

    CleanUIClassicLayout.castBarY = y + SCREEN_MARGIN

    if VerticalMultiBarsContainer then
        VerticalMultiBarsContainer:ClearAllPoints()
        VerticalMultiBarsContainer:SetPoint("RIGHT", UIParent, "RIGHT", -SCREEN_MARGIN, 0)
    end

    if PlayerFrame and MultiBarBottomLeftButton1 then
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint("TOPLEFT", MultiBarBottomLeftButton1, "TOPLEFT",
            -PLAYER_MANA_RIGHT, UNIT_FRAME_GAP + MANA_TO_FRAME_TOP)
        PlayerFrame:SetUserPlaced(true)
    end
    if TargetFrame and MultiBarBottomLeftButton12 then
        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint("TOPLEFT", MultiBarBottomLeftButton12, "TOPRIGHT",
            -TARGET_MANA_LEFT, UNIT_FRAME_GAP + MANA_TO_FRAME_TOP)
        TargetFrame:SetUserPlaced(true)
    end

    MainMenuBarLeftEndCap:Hide()
    MainMenuBarRightEndCap:Hide()
    MainMenuBarPageNumber:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()
    MainMenuBarMaxLevelBar:Hide()
    MainMenuBarOverlayFrame:Hide()
    if MainMenuBarTextureExtender then MainMenuBarTextureExtender:Hide() end
    keepHidden(MainMenuBarPerformanceBarFrame)

    for i = 0, 3 do
        _G["MainMenuBarTexture" .. i]:Hide()
        _G["MainMenuMaxLevelBar" .. i]:Hide()
    end
    for i = 0, 1 do
        keepHidden(_G["SlidingActionBarTexture" .. i])
    end
end

local BUTTON_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
}

local function hideButtonBackgrounds()
    for _, prefix in ipairs(BUTTON_PREFIXES) do
        for i = 1, 12 do
            local bg = _G[prefix .. i .. "FloatingBG"]
            if bg then bg:SetAlpha(0) end
        end
    end
end

hooksecurefunc("ActionButton_OnUpdate", function(self)
    if not self or not self.action then return end
    local usable = IsUsableAction(self.action)
    local inRange = IsActionInRange(self.action)
    self.icon:SetAlpha((not usable or inRange == false) and 0.9 or 1.0)
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PET_BAR_UPDATE")
frame:RegisterEvent("UNIT_PET")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
frame:SetScript("OnEvent", function()
    enableExtraBars()
    applyLayout()
    hideButtonBackgrounds()
end)
