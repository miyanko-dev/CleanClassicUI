local BTN_SIZE = CleanUILayout and CleanUILayout.btnSize or 36
local BAR_SCALE = CleanUILayout and CleanUILayout.bar3Scale or 0.8
local BTN_GAP = -2
local BACKPACK_GAP = -8
local CONTAINER_GAP = 4

local BAG_BTNS = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
    "KeyRingButton",
}

local function styleBtn(btn)
    if not btn then return end
    if btn == KeyRingButton then
        local ratio = btn.cleanUINativeRatio or 1
        btn:SetSize(BTN_SIZE * ratio, BTN_SIZE)
    else
        btn:SetSize(BTN_SIZE, BTN_SIZE)
    end
    btn:SetScale(BAR_SCALE)
    local name = btn:GetName()
    local norm = _G[name .. "NormalTexture"]
    if norm then norm:SetAlpha(0) end
    local icon = _G[name .. "IconTexture"] or _G[name .. "Icon"]
    if icon then
        icon:ClearAllPoints()
        icon:SetAllPoints(btn)
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    CleanUI.ApplyBorder(btn)
end

local function lockKeyringSize()
    if not KeyRingButton or KeyRingButton.cleanUISizeLock then return end
    KeyRingButton.cleanUISizeLock = true
    local w, h = KeyRingButton:GetSize()
    KeyRingButton.cleanUINativeRatio = (h > 0) and (w / h) or 1
    KeyRingButton:HookScript("OnSizeChanged", function(self, sw, sh)
        local target = BTN_SIZE * (self.cleanUINativeRatio or 1)
        if sw ~= target or sh ~= BTN_SIZE then
            self:SetSize(target, BTN_SIZE)
        end
    end)
end

local pending = false
local function arrangeBtns()
    pending = false
    if not HelpMicroButton then return end

    lockKeyringSize()

    for i, name in ipairs(BAG_BTNS) do
        local btn = _G[name]
        if not btn then return end
        btn:SetParent(UIParent)
        btn:Show()
        btn:ClearAllPoints()
        if i == 1 then
            btn:SetPoint("BOTTOMRIGHT", HelpMicroButton, "TOPRIGHT", -2, BACKPACK_GAP)
        else
            btn:SetPoint("RIGHT", _G[BAG_BTNS[i - 1]], "LEFT", BTN_GAP, 0)
        end
        styleBtn(btn)
    end
end

local function schedule()
    if pending then return end
    pending = true
    C_Timer.After(0, arrangeBtns)
end

hooksecurefunc("MoveMicroButtons", schedule)

local function arrangeContainers()
    local visible = {}
    for i = 1, NUM_CONTAINER_FRAMES do
        local f = _G["ContainerFrame" .. i]
        if f and f:IsShown() then
            table.insert(visible, f)
        end
    end
    if #visible == 0 then return end

    visible[1]:ClearAllPoints()
    visible[1]:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOPRIGHT", CONTAINER_GAP, CONTAINER_GAP)
    for i = 2, #visible do
        visible[i]:ClearAllPoints()
        if i % 2 == 0 then
            visible[i]:SetPoint("BOTTOMRIGHT", visible[i - 1], "TOPRIGHT", 0, CONTAINER_GAP)
        else
            visible[i]:SetPoint("BOTTOMRIGHT", visible[i - 2], "BOTTOMLEFT", 0, CONTAINER_GAP)
        end
    end
end

hooksecurefunc("UpdateContainerFrameAnchors", arrangeContainers)

MainMenuBarBackpackButton:SetScript("OnClick", function()
    if IsBagOpen(0) then CloseAllBags() else OpenAllBags() end
end)

local bankFrame = CreateFrame("Frame")
bankFrame:RegisterEvent("BANKFRAME_OPENED")
bankFrame:RegisterEvent("BANKFRAME_CLOSED")
bankFrame:SetScript("OnEvent", function(_, event)
    if event == "BANKFRAME_OPENED" then
        for id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do OpenBag(id) end
    else
        for id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do CloseBag(id) end
    end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:SetScript("OnEvent", schedule)
