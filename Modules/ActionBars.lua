-- Position action bars
local function positionActionBars()
    MainMenuBar:SetWidth(512)
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", -2, 72)
    MainMenuBar:SetMovable(true)
    MainMenuBar:SetUserPlaced(true)

    MultiBarBottomLeft:Show()
    MultiBarBottomLeft:ClearAllPoints()
    MultiBarBottomLeft:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 118)
    MultiBarBottomLeft:SetMovable(true)
    MultiBarBottomLeft:SetUserPlaced(true)

    MultiBarBottomRight:Show()
    MultiBarBottomRight:ClearAllPoints()
    MultiBarBottomRight:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 24)
    MultiBarBottomRight:SetMovable(true)
    MultiBarBottomRight:SetUserPlaced(true)
    MultiBarBottomRight:SetScale(0.8)

    MultiBarRight:ClearAllPoints()
    MultiBarRight:SetPoint("RIGHT", UIParent, "RIGHT", -16, 0)
    MultiBarRight:SetMovable(true)
    MultiBarRight:SetUserPlaced(true)

    MultiBarLeft:ClearAllPoints()
    MultiBarLeft:SetPoint("RIGHT", MultiBarRight, "LEFT", -2, 0)
    MultiBarLeft:SetMovable(true)
    MultiBarLeft:SetUserPlaced(true)

    MainMenuBarLeftEndCap:Hide()
    MainMenuBarRightEndCap:Hide()
    MainMenuBarPageNumber:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()
    MainMenuBarTexture0:Hide()
    MainMenuBarTexture1:Hide()
    MainMenuBarTexture2:Hide()
    MainMenuBarTexture3:Hide()
    MainMenuMaxLevelBar0:Hide()
    MainMenuMaxLevelBar1:Hide()
    MainMenuMaxLevelBar2:Hide()
    MainMenuMaxLevelBar3:Hide()
    MainMenuBarMaxLevelBar:Hide()
    MainMenuBarOverlayFrame:Hide()

    if MainMenuBarTextureExtender then
        MainMenuBarTextureExtender:Hide()
    end

    SlidingActionBarTexture0:Hide()
    SlidingActionBarTexture0.Show = SlidingActionBarTexture0.Hide

    SlidingActionBarTexture1:Hide()
    SlidingActionBarTexture1.Show = SlidingActionBarTexture1.Hide

    MainMenuBarPerformanceBarFrame:Hide()
    MainMenuBarPerformanceBarFrame.Show = MainMenuBarPerformanceBarFrame.Hide
end

local actionBarFrame = CreateFrame("Frame")
actionBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
actionBarFrame:SetScript("OnEvent", positionActionBars)

-- Dim action buttons when out of range or unusable
local function updateUsability(self)
    if not self or not self.action then return end
    local isUsable  = IsUsableAction(self.action)
    local inRange   = IsActionInRange(self.action)
    local alpha     = (not isUsable or inRange == false) and 0.9 or 1.0
    self.icon:SetAlpha(alpha)
end

hooksecurefunc("ActionButton_OnUpdate", updateUsability)

-- Style action buttons: remove stock textures, add custom border
local function hideButtonTextures(button)
    if not button then return end
    local normal = _G[button:GetName() .. "NormalTexture"]
    if normal then
        normal:SetAlpha(0)
        normal:SetTexture(nil)
    end
    local floating = _G[button:GetName() .. "FloatingBG"]
    if floating then
        floating:SetAlpha(0)
        floating:SetTexture(nil)
    end
end

local function addButtonBorder(button)
    if not button then return end
    if not button.customBorder then
        local backdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
        backdrop:SetPoint("TOPLEFT",     button, "TOPLEFT",     -3,  3)
        backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT",  3, -3)
        backdrop:SetBackdrop({ edgeFile = BORD, edgeSize = 12 })
        backdrop:SetBackdropBorderColor(unpack(GREY_RGB))
        backdrop:SetFrameLevel(button:GetFrameLevel() + 2)
        button.customBorder = backdrop
    end
    local icon = _G[button:GetName() .. "Icon"]
    if icon then icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
end

local function styleButtonFonts(button)
    if not button then return end
    local macroName = _G[button:GetName() .. "Name"]
    if macroName then
        macroName:SetFont(FONT, 10, "OUTLINE")
        macroName:SetTextColor(unpack(WHITE_RGB))
        macroName:SetAlpha(0.5)
    end
    local hotkey = _G[button:GetName() .. "HotKey"]
    if hotkey then
        hotkey:SetFont(FONT, 12, "OUTLINE")
        hotkey:SetTextColor(unpack(WHITE_RGB))
        hotkey:SetAlpha(0.75)
    end
end

local function styleActionButtons()
    for i = 1, 12 do
        local buttons = {
            _G["ActionButton"              .. i],
            _G["MultiBarBottomLeftButton"  .. i],
            _G["MultiBarBottomRightButton" .. i],
            _G["MultiBarRightButton"       .. i],
            _G["MultiBarLeftButton"        .. i],
        }
        for _, button in ipairs(buttons) do
            hideButtonTextures(button)
            addButtonBorder(button)
            styleButtonFonts(button)
        end
    end
end

local buttonStyleFrame = CreateFrame("Frame")
buttonStyleFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
buttonStyleFrame:SetScript("OnEvent", styleActionButtons)

-- Stance bar
local function hideStanceTextures(button)
    for n = 1, 3 do
        local tex = _G[button:GetName() .. "NormalTexture" .. n]
        if tex then
            tex:SetAlpha(0)
            tex:SetTexture(nil)
        end
    end
end

local function addStanceBorder(button)
    if not button.customBorder then
        local backdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
        backdrop:SetPoint("TOPLEFT",     button, "TOPLEFT",     -3,  3)
        backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT",  3, -3)
        backdrop:SetBackdrop({ edgeFile = BORD, edgeSize = 12 })
        backdrop:SetBackdropBorderColor(unpack(GREY_RGB))
        backdrop:SetFrameLevel(button:GetFrameLevel() + 2)
        button.customBorder = backdrop
    end
    local icon = _G[button:GetName() .. "Icon"]
    if icon then icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
end

local function positionStanceButtons()
    if InCombatLockdown() then return end
    local previous
    local anchor = MultiBarBottomLeft:IsShown() and MultiBarBottomLeftButton1 or ActionButton1
    for slot = 1, NUM_STANCE_SLOTS do
        local button = _G["StanceButton" .. slot]
        button:ClearAllPoints()
        if not previous then
            button:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 8)
        else
            button:SetPoint("LEFT", previous, "RIGHT", 8, 0)
        end
        button:SetScale(0.9)
        hideStanceTextures(button)
        addStanceBorder(button)
        previous = button
    end
    StanceBarLeft:SetAlpha(0);   StanceBarLeft:SetTexture(nil)
    StanceBarMiddle:SetAlpha(0); StanceBarMiddle:SetTexture(nil)
    StanceBarRight:SetAlpha(0);  StanceBarRight:SetTexture(nil)
end

local stanceFrame = CreateFrame("Frame")
stanceFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
stanceFrame:RegisterEvent("UPDATE_STEALTH")
stanceFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
stanceFrame:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
stanceFrame:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
stanceFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
stanceFrame:SetScript("OnEvent", positionStanceButtons)

-- Pet action bar
local function hidePetTextures(button)
    local normal = _G[button:GetName() .. "NormalTexture"]
    if normal then normal:SetAlpha(0); normal:SetTexture(nil) end
    local normal2 = _G[button:GetName() .. "NormalTexture2"]
    if normal2 then normal2:SetAlpha(0); normal2:SetTexture(nil) end
    local castable = _G[button:GetName() .. "AutoCastable"]
    if castable then castable:SetAlpha(0); castable:Hide() end
end

local function addPetBorder(button)
    if not button.customBorder then
        local backdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
        backdrop:SetPoint("TOPLEFT",     button, "TOPLEFT",     -3,  3)
        backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT",  3, -3)
        backdrop:SetBackdrop({ edgeFile = BORD, edgeSize = 12 })
        backdrop:SetBackdropBorderColor(unpack(GREY_RGB))
        backdrop:SetFrameLevel(button:GetFrameLevel() + 2)
        button.customBorder = backdrop
    end
    local icon = _G[button:GetName() .. "Icon"]
    if icon then icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
end

local function positionPetButtons()
    local previous
    for slot = 1, 10 do
        local button = _G["PetActionButton" .. slot]
        button:ClearAllPoints()
        if not previous then
            button:SetPoint("BOTTOMLEFT", MultiBarBottomLeft, "TOPLEFT", 0, 6)
        else
            button:SetPoint("LEFT", previous, "RIGHT", 6, 0)
        end
        button:SetScale(0.9)
        hidePetTextures(button)
        addPetBorder(button)
        previous = button
    end
end

local petBarFrame = CreateFrame("Frame")
petBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
petBarFrame:RegisterEvent("UNIT_PET")
petBarFrame:RegisterEvent("PET_BAR_UPDATE")
petBarFrame:SetScript("OnEvent", positionPetButtons)

-- Vehicle leave button
local function positionVehicleButton()
    MainMenuBarVehicleLeaveButton:SetSize(24, 24)
    MainMenuBarVehicleLeaveButton:ClearAllPoints()
    MainMenuBarVehicleLeaveButton:SetPoint("BOTTOMRIGHT", PlayerPortrait, "TOPLEFT", -2, 2)
end

MainMenuBarVehicleLeaveButton:HookScript("OnShow", positionVehicleButton)
