local PADDING = 20
local BAR_GAP = 6
local XP_REP_HEIGHT = 22

local function positionBars()
    if InCombatLockdown() then return end

    MultiBarBottomRight:Show()
    MultiBarBottomRight:ClearAllPoints()
    MultiBarBottomRight:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, PADDING + XP_REP_HEIGHT + PADDING)
    MultiBarBottomRight:SetScale(0.8)
    MultiBarBottomRight:SetMovable(true)
    MultiBarBottomRight:SetUserPlaced(true)

    MainMenuBar:SetWidth(512)
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", MultiBarBottomRight, "TOP", 0, PADDING)
    MainMenuBar:SetMovable(true)
    MainMenuBar:SetUserPlaced(true)

    MultiBarBottomLeft:Show()
    MultiBarBottomLeft:ClearAllPoints()
    MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, BAR_GAP)
    MultiBarBottomLeft:SetMovable(true)
    MultiBarBottomLeft:SetUserPlaced(true)

    MainMenuBarLeftEndCap:Hide()
    MainMenuBarRightEndCap:Hide()
    MainMenuBarPageNumber:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()
    MainMenuBarMaxLevelBar:Hide()
    MainMenuBarOverlayFrame:Hide()
    if MainMenuBarTextureExtender then MainMenuBarTextureExtender:Hide() end

    for i = 0, 3 do
        _G["MainMenuBarTexture" .. i]:Hide()
        _G["MainMenuMaxLevelBar" .. i]:Hide()
    end

    for i = 0, 1 do
        local t = _G["SlidingActionBarTexture" .. i]
        t:Hide()
        t.Show = t.Hide
    end

    MainMenuBarPerformanceBarFrame:Hide()
    MainMenuBarPerformanceBarFrame.Show = MainMenuBarPerformanceBarFrame.Hide
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

local function getUpperAnchor()
    if MultiBarBottomLeft:IsShown() then
        return MultiBarBottomLeftButton1
    end
    return ActionButton1
end

local function positionStance()
    if InCombatLockdown() then return end
    local anchor = getUpperAnchor()
    local prev
    for i = 1, NUM_STANCE_SLOTS do
        local btn = _G["StanceButton" .. i]
        btn:ClearAllPoints()
        if not prev then
            btn:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, PADDING)
        else
            btn:SetPoint("LEFT", prev, "RIGHT", 6, 0)
        end
        prev = btn
    end
    StanceBarLeft:SetAlpha(0)
    StanceBarMiddle:SetAlpha(0)
    StanceBarRight:SetAlpha(0)
end

local PET_SCALE = 0.8
local PET_GAP = 6
local PET_COUNT = 10
local PET_OFFSET_Y = 8 / PET_SCALE

local function getPetAnchor()
    if MultiBarBottomLeft:IsShown() then
        return MultiBarBottomLeft
    end
    return MainMenuBar
end

local function positionPet()
    if InCombatLockdown() then return end
    if not PetActionBarFrame or not PetActionButton1 then return end

    PetActionBarFrame:SetScale(PET_SCALE)

    local btnW = PetActionButton1:GetWidth()
    local totalW = PET_COUNT * btnW + (PET_COUNT - 1) * PET_GAP
    local firstX = -(totalW - btnW) / 2

    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetPoint("BOTTOM", getPetAnchor(), "TOP", firstX, PET_OFFSET_Y)

    local prev = PetActionButton1
    for i = 2, PET_COUNT do
        local btn = _G["PetActionButton" .. i]
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", prev, "RIGHT", PET_GAP, 0)
        prev = btn
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
f:SetScript("OnEvent", function(_, event)
    positionBars()
    stripButtons()
    positionStance()
    positionPet()
end)
