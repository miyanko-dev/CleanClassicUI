-- Edit Mode owns the bag-button row; style the buttons, stack the container windows, and open bank bags with the bank.

local CONTAINER_GAP = CleanClassicExperience.SPACING.XS

local BAG_BTNS = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
}

-- Blizzard locks the keyring PUSHED while its bag is open, hiding the key art; show the same art pushed instead.
local KEYRING_TEXTURE = "Interface/Buttons/UI-Button-KeyRing"
local KEYRING_LEFT, KEYRING_RIGHT, KEYRING_TOP, KEYRING_BOTTOM = 0, 0.5625, 0, 0.609375
local KEYRING_ZOOM = 0.05

local function styleKeyring()
    local btn = KeyRingButton
    if not btn then return end

    local pushedTexture = btn:GetPushedTexture()
    if pushedTexture then pushedTexture:SetTexture(KEYRING_TEXTURE) end

    local dx = (KEYRING_RIGHT - KEYRING_LEFT) * KEYRING_ZOOM
    local dy = (KEYRING_BOTTOM - KEYRING_TOP) * KEYRING_ZOOM
    for _, tex in ipairs({ btn:GetNormalTexture(), pushedTexture, btn:GetHighlightTexture() }) do
        tex:SetTexCoord(KEYRING_LEFT + dx, KEYRING_RIGHT - dx, KEYRING_TOP + dy, KEYRING_BOTTOM - dy)
    end

    CleanClassicExperience.ApplyBorder(btn)
end

local function styleButtons()
    for _, name in ipairs(BAG_BTNS) do CleanClassicExperience.StyleButton(_G[name]) end
    styleKeyring()
end

-- Blizzard anchors each new column to UIParent's right edge, so re-anchor the whole open-order chain two per column.
local function arrangeContainers()
    local bags = ContainerFrame1 and ContainerFrame1.bags
    if not bags or not bags[1] then return end

    for i, name in ipairs(bags) do
        local bag = _G[name]
        if not bag then return end
        bag:ClearAllPoints()
        if i == 1 then
            bag:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOPRIGHT", CONTAINER_GAP, CONTAINER_GAP)
        elseif i % 2 == 0 then
            bag:SetPoint("BOTTOMRIGHT", _G[bags[i - 1]], "TOPRIGHT", 0, CONTAINER_GAP)
        else
            bag:SetPoint("BOTTOMRIGHT", _G[bags[i - 2]], "BOTTOMLEFT", 0, CONTAINER_GAP)
        end
    end
end

hooksecurefunc("UpdateContainerFrameAnchors", arrangeContainers)

CleanClassicExperience.OnEvent(function(_, event)
    if event == "BANKFRAME_OPENED" then
        for id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do OpenBag(id) end
    else
        for id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do CloseBag(id) end
    end
end, "BANKFRAME_OPENED", "BANKFRAME_CLOSED")

styleButtons()

-- The bag bar's Size setting applies live in Edit Mode before layouts save, so restyle on every applied setting too.
hooksecurefunc(EditModeManagerFrame, "OnSystemSettingChange", styleButtons)

CleanClassicExperience.OnEvent(styleButtons,
    "PLAYER_ENTERING_WORLD", "EDIT_MODE_LAYOUTS_UPDATED")
