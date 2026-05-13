local SPACING = CleanUI.SPACING
local BORDER = CleanUI.BORDER
local BTN_SIZE = CleanUI.BTN_SIZE

local BAG_BTN_GAP = 6
local BAR_SCALE = (CleanUILayout and CleanUILayout.bar3Scale) or 0.8
local CONTAINER_GAP = SPACING.XS

CleanUILayout = CleanUILayout or {}
CleanUILayout.bagScale = BAR_SCALE

local BAG_BTNS = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
    "KeyRingButton",
}

-- Keep the keyring at the shared button size while preserving its native aspect ratio.
local function lockKeyringSize()
    if not KeyRingButton or KeyRingButton.cleanSizeLock then return end
    KeyRingButton.cleanSizeLock = true
    local w, h = KeyRingButton:GetSize()
    KeyRingButton.cleanRatio = (h > 0) and (w / h) or 1
    KeyRingButton:HookScript("OnSizeChanged", function(self, sw, sh)
        local target = BTN_SIZE * (self.cleanRatio or 1)
        if sw ~= target or sh ~= BTN_SIZE then
            self:SetSize(target, BTN_SIZE)
        end
    end)
end

local function styleBtn(btn)
    if not btn then return end
    if btn == KeyRingButton then
        btn:SetSize(BTN_SIZE * (btn.cleanRatio or 1), BTN_SIZE)
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

local function arrangeBtns()
    if not HelpMicroButton then return end

    lockKeyringSize()

    for i, name in ipairs(BAG_BTNS) do
        local btn = _G[name]
        if not btn then return end
        btn:SetParent(UIParent)
        btn:Show()
        btn:ClearAllPoints()
        if i == 1 then
            btn:SetPoint("BOTTOMRIGHT", HelpMicroButton, "TOPRIGHT", -BORDER, BORDER)
        else
            btn:SetPoint("RIGHT", _G[BAG_BTNS[i - 1]], "LEFT", -BAG_BTN_GAP, 0)
        end
        styleBtn(btn)
    end
end

hooksecurefunc("MoveMicroButtons", arrangeBtns)

local function arrangeContainers()
    local visible = {}
    for i = 1, NUM_CONTAINER_FRAMES do
        local container = _G["ContainerFrame" .. i]
        if container and container:IsShown() then
            table.insert(visible, container)
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

CleanUI.OnEvent(function(_, event)
    if event == "BANKFRAME_OPENED" then
        for id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do OpenBag(id) end
    else
        for id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do CloseBag(id) end
    end
end, "BANKFRAME_OPENED", "BANKFRAME_CLOSED")

CleanUI.OnEvent(arrangeBtns,
    "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED")
