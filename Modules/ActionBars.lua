local MARGIN = 24
local BAR_GAP = 8
local BTN_SIZE = 36
local BAR3_SCALE = 0.8
local PET_SCALE = 0.8
local PET_COUNT = 10
local PET_GAP = 6
local STANCE_GAP = 6
local AB1_INSET = 4
local UF_GAP = 72
local UF_TOP = 64
local PLAYER_X = 225
local TARGET_X = 7

CleanUILayout = CleanUILayout or {}
CleanUILayout.afterLayout = CleanUILayout.afterLayout or {}

local function keepHidden(f)
    if not f then return end
    f:Hide()
    f.Show = f.Hide
end

local function enableBars()
    if InCombatLockdown() then return end
    if GetCVar("bottomLeftActionBar") ~= "1" then SetCVar("bottomLeftActionBar", "1") end
    if GetCVar("bottomRightActionBar") ~= "1" then SetCVar("bottomRightActionBar", "1") end
end

local function centerRow(prefix, count, gap, scale, y)
    local first = _G[prefix .. "1"]
    local w = first:GetWidth()
    local total = count * w + (count - 1) * gap
    local startX = -(total - w) / 2
    first:ClearAllPoints()
    first:SetPoint("BOTTOM", UIParent, "BOTTOM", startX, y / scale)
    for i = 2, count do
        _G[prefix .. i]:ClearAllPoints()
        _G[prefix .. i]:SetPoint("LEFT", _G[prefix .. (i - 1)], "RIGHT", gap, 0)
    end
end

local function layout()
    if InCombatLockdown() then return end

    local y = MARGIN
    local barW = 512 * BAR3_SCALE

    if MainMenuExpBar then
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y)
        MainMenuExpBar:SetWidth(barW)
        if MainMenuExpBar:IsShown() then y = y + MainMenuExpBar:GetHeight() end
    end

    if ReputationWatchBar then
        ReputationWatchBar:ClearAllPoints()
        ReputationWatchBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y)
        ReputationWatchBar:SetWidth(barW)
        if ReputationWatchStatusBar then ReputationWatchStatusBar:SetWidth(barW) end
        if ReputationWatchBar:IsShown() then y = y + ReputationWatchBar:GetHeight() end
    end

    y = y + MARGIN

    MultiBarBottomRight:Show()
    MultiBarBottomRight:SetScale(BAR3_SCALE)
    MultiBarBottomRight:ClearAllPoints()
    MultiBarBottomRight:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y / BAR3_SCALE)
    MultiBarBottomRight:SetMovable(true)
    MultiBarBottomRight:SetUserPlaced(true)
    y = y + BTN_SIZE * BAR3_SCALE + MARGIN

    MainMenuBar:SetWidth(512)
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, y - AB1_INSET)
    MainMenuBar:SetMovable(true)
    MainMenuBar:SetUserPlaced(true)
    y = y + BTN_SIZE

    MultiBarBottomLeft:Show()
    MultiBarBottomLeft:ClearAllPoints()
    MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, BAR_GAP)
    MultiBarBottomLeft:SetMovable(true)
    MultiBarBottomLeft:SetUserPlaced(true)
    y = y + BAR_GAP + BTN_SIZE

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
        y = y + BTN_SIZE
    end

    CleanUILayout.castBarY = y + MARGIN

    if VerticalMultiBarsContainer then
        VerticalMultiBarsContainer:ClearAllPoints()
        VerticalMultiBarsContainer:SetPoint("RIGHT", UIParent, "RIGHT", -MARGIN, 0)
    end

    if PlayerFrame and MultiBarBottomLeftButton1 then
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint("TOPLEFT", MultiBarBottomLeftButton1, "TOPLEFT",
            -PLAYER_X, UF_GAP + UF_TOP)
        PlayerFrame:SetUserPlaced(true)
    end
    if TargetFrame and MultiBarBottomLeftButton12 then
        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint("TOPLEFT", MultiBarBottomLeftButton12, "TOPRIGHT",
            -TARGET_X, UF_GAP + UF_TOP)
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

local BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
}

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
end

local function styleAll()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, 12 do
            styleBtn(_G[prefix .. i])
        end
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
            local n = _G[btn:GetName() .. "NormalTexture"]
            if n then n:SetAlpha(0) end
            local n2 = _G[btn:GetName() .. "NormalTexture2"]
            if n2 then n2:SetAlpha(0) end
            local icon = _G[btn:GetName() .. "Icon"]
            if icon then icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
            CleanUI.ApplyBorder(btn)
        end
    end
end

hooksecurefunc("ActionButton_OnUpdate", function(self)
    if not self or not self.action then return end
    local usable = IsUsableAction(self.action)
    local inRange = IsActionInRange(self.action)
    self.icon:SetAlpha((not usable or inRange == false) and 0.9 or 1.0)
end)

local pending = false
local function scheduleLayout()
    if pending then return end
    pending = true
    C_Timer.After(0, function()
        pending = false
        enableBars()
        layout()
        styleAll()
        for _, cb in ipairs(CleanUILayout.afterLayout) do cb() end
    end)
end

CleanUILayout.scheduleLayout = scheduleLayout

if PetActionBarFrame then
    PetActionBarFrame:HookScript("OnShow", scheduleLayout)
    PetActionBarFrame:HookScript("OnHide", scheduleLayout)
end
if StanceBarFrame then
    StanceBarFrame:HookScript("OnShow", scheduleLayout)
    StanceBarFrame:HookScript("OnHide", scheduleLayout)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PET_BAR_UPDATE")
frame:RegisterEvent("UNIT_PET")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:SetScript("OnEvent", scheduleLayout)
