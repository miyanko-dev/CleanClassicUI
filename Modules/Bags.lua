local bagButtons = {
    MainMenuBarBackpackButton,
    CharacterBag0Slot,
    CharacterBag1Slot,
    CharacterBag2Slot,
    CharacterBag3Slot,
    KeyRingButton,
}

local function styleBag(button)
    if not button or button.customBorder then return end
    local name   = button:GetName()
    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetPoint("TOPLEFT",     button, "TOPLEFT",     -3,  3)
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT",  3, -3)
    border:SetBackdrop({ edgeFile = BORD, edgeSize = 12 })
    border:SetBackdropBorderColor(unpack(GREY_RGB))
    border:SetFrameLevel(button:GetFrameLevel() + 2)
    button.customBorder = border

    local normal = _G[name .. "NormalTexture"]
    if normal then normal:SetAlpha(0); normal:Hide() end

    local icon = _G[name .. "IconTexture"]
    if icon then
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT",     button, "TOPLEFT",     0, 0)
        icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
end

-- Position bag slots above the micro menu and style each one
local function arrangeBags()
    MainMenuBarBackpackButton:ClearAllPoints()
    MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", MainMenuMicroButton, "TOPRIGHT", 0, 4)

    CharacterBag0Slot:ClearAllPoints()
    CharacterBag0Slot:SetPoint("RIGHT", MainMenuBarBackpackButton, "LEFT", -4, 0)
    CharacterBag0Slot:SetParent(ContainerFrame1)

    CharacterBag1Slot:ClearAllPoints()
    CharacterBag1Slot:SetPoint("RIGHT", CharacterBag0Slot, "LEFT", -4, 0)
    CharacterBag1Slot:SetParent(ContainerFrame1)

    CharacterBag2Slot:ClearAllPoints()
    CharacterBag2Slot:SetPoint("RIGHT", CharacterBag1Slot, "LEFT", -4, 0)
    CharacterBag2Slot:SetParent(ContainerFrame1)

    CharacterBag3Slot:ClearAllPoints()
    CharacterBag3Slot:SetPoint("RIGHT", CharacterBag2Slot, "LEFT", -4, 0)
    CharacterBag3Slot:SetParent(ContainerFrame1)

    KeyRingButton:ClearAllPoints()
    KeyRingButton:SetPoint("RIGHT", CharacterBag3Slot, "LEFT", -4, -1)
    KeyRingButton:SetParent(ContainerFrame1)

    for _, button in ipairs(bagButtons) do
        styleBag(button)
    end
end

local bagSlotFrame = CreateFrame("Frame")
bagSlotFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
bagSlotFrame:RegisterEvent("BAG_UPDATE")
bagSlotFrame:SetScript("OnEvent", arrangeBags)

-- Stack open bag frames in two columns anchored to the backpack button
local function arrangeContainers()
    local visible = {}
    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame" .. i]
        if frame and frame:IsShown() then
            table.insert(visible, frame)
        end
    end

    if #visible > 0 then
        visible[1]:ClearAllPoints()
        visible[1]:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOPRIGHT", 4, 4)
        for i = 2, #visible do
            visible[i]:ClearAllPoints()
            if i % 2 == 0 then
                visible[i]:SetPoint("BOTTOMRIGHT", visible[i - 1], "TOPRIGHT", 0, 4)
            else
                visible[i]:SetPoint("BOTTOMRIGHT", visible[i - 2], "BOTTOMLEFT", 0, 4)
            end
        end
    end

    if not IsBagOpen(0) and IsBagOpen(KEYRING_CONTAINER) then
        ToggleBag(KEYRING_CONTAINER)
    end
end

hooksecurefunc("UpdateContainerFrameAnchors", arrangeContainers)

local containerFrame = CreateFrame("Frame")
containerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
containerFrame:RegisterEvent("BAG_UPDATE")
containerFrame:RegisterEvent("BANKFRAME_OPENED")
containerFrame:RegisterEvent("BANKFRAME_CLOSED")
containerFrame:RegisterEvent("MERCHANT_SHOW")
containerFrame:RegisterEvent("MERCHANT_CLOSED")
containerFrame:RegisterEvent("BAG_OPEN")
containerFrame:RegisterEvent("BAG_CLOSED")
containerFrame:SetScript("OnEvent", arrangeContainers)

-- Backpack button toggles all bags at once
MainMenuBarBackpackButton:SetScript("OnClick", function()
    if IsBagOpen(0) then CloseAllBags() else OpenAllBags() end
end)

-- Auto-open / close all bank bags with the bank frame
local bankFrame = CreateFrame("Frame")
bankFrame:RegisterEvent("BANKFRAME_OPENED")
bankFrame:RegisterEvent("BANKFRAME_CLOSED")
bankFrame:SetScript("OnEvent", function(self, event)
    local start = NUM_BAG_SLOTS + 1
    local stop  = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
    if event == "BANKFRAME_OPENED" then
        for id = start, stop do OpenBag(id) end
    else
        for id = start, stop do CloseBag(id) end
    end
end)
