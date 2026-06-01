local SPACING = CleanClassicUI.SPACING
local BLOCK_GAP = SPACING.XS
local SCREEN_MARGIN = SPACING.MD
local TAB_FONT_SIZE = 14

local TAB_TEXTURE_SUFFIXES = {
    "Left", "Middle", "Right",
    "SelectedLeft", "SelectedMiddle", "SelectedRight",
    "HighlightLeft", "HighlightMiddle", "HighlightRight",
    "Glow",
}

local CHAT_FRAME_TEXTURE_SUFFIXES = {
    "Background",
    "TopLeftTexture", "TopRightTexture", "BottomLeftTexture", "BottomRightTexture",
    "LeftTexture", "RightTexture", "TopTexture", "BottomTexture",
}

local function stripChatFrameTextures(chatFrame)
    local name = chatFrame:GetName()
    for _, suffix in ipairs(CHAT_FRAME_TEXTURE_SUFFIXES) do
        local texture = _G[name .. suffix]
        if texture then texture:SetTexture(nil) end
    end
end

local function styleTab(tab)
    if not tab or tab.cleanStyled then return end

    local name = tab:GetName()
    for _, suffix in ipairs(TAB_TEXTURE_SUFFIXES) do
        local texture = _G[name .. suffix]
        if texture then texture:SetTexture(nil) end
    end

    local text = _G[name .. "Text"]
    if text then
        local font = text:GetFont()
        text:SetFont(font, TAB_FONT_SIZE, "OUTLINE")
    end

    local conversationIcon = tab.conversationIcon or _G[name .. "ConversationIcon"]
    if conversationIcon then conversationIcon:Hide() end

    tab:HookScript("OnClick", function(self)
        if IsShiftKeyDown() then
            local chatFrame = _G["ChatFrame" .. self:GetID()]
            if chatFrame then chatFrame:ScrollToBottom() end
        end
    end)
    tab.cleanStyled = true
end

local function styleEditBox(chatFrame, editBox)
    if not editBox or editBox.cleanStyled then return end

    for _, suffix in ipairs({ "Left", "Mid", "Right" }) do
        local texture = _G[editBox:GetName() .. suffix]
        if texture then texture:Hide() end
    end

    editBox:ClearAllPoints()
    editBox:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT", 0, -BLOCK_GAP)
    editBox:SetPoint("TOPRIGHT", chatFrame, "BOTTOMRIGHT", 0, -BLOCK_GAP)

    local font, size = editBox:GetFont()
    editBox:SetFont(font, size, "OUTLINE")

    local header = _G[editBox:GetName() .. "Header"]
    if header then
        header:ClearAllPoints()
        header:SetPoint("LEFT", editBox, "LEFT", 8, 0)
        local headerFont, headerSize = header:GetFont()
        header:SetFont(headerFont, headerSize, "OUTLINE")
    end

    -- $parentHeaderSuffix (the ": " after the chat type) is in the editbox's
    -- ARTWORK layer and leaks at dimmed alpha when Blizzard fades the box out
    -- on deactivate; visibility is bound to the header via ChatEdit_UpdateHeader below.
    local headerSuffix = _G[editBox:GetName() .. "HeaderSuffix"]
    if headerSuffix then
        headerSuffix:Hide()
        local suffixFont, suffixSize = headerSuffix:GetFont()
        headerSuffix:SetFont(suffixFont, suffixSize, "OUTLINE")
    end

    editBox.cleanStyled = true
end

local function positionChatFrame(chatFrame, editBox)
    chatFrame:SetMovable(true)
    chatFrame:ClearAllPoints()
    chatFrame:SetPoint(
        "BOTTOMLEFT", UIParent, "BOTTOMLEFT",
        SCREEN_MARGIN,
        SCREEN_MARGIN + BLOCK_GAP + editBox:GetHeight()
    )
    chatFrame:SetUserPlaced(true)
end

local function applyStyle()
    CleanClassicUI.HideForever(ChatFrameMenuButton)
    CleanClassicUI.HideForever(ChatFrameChannelButton)

    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            local editBox = _G[chatFrame:GetName() .. "EditBox"]
            local tab = _G[chatFrame:GetName() .. "Tab"]
            CleanClassicUI.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
            stripChatFrameTextures(chatFrame)
            styleTab(tab)
            styleEditBox(chatFrame, editBox)
            if chatFrame == ChatFrame1 then
                positionChatFrame(chatFrame, editBox)
            end
        end
    end
end

local function enableClassColors()
    SetCVar("chatClassColorOverride", "0")
    for chatType in pairs(ChatTypeGroup) do
        SetChatColorNameByClass(chatType, true)
    end
    for chatType in pairs(CHAT_CONFIG_CHAT_LEFT) do
        SetChatColorNameByClass(chatType, true)
    end
    local channels = { GetChannelList() }
    for i = 1, #channels, 3 do
        local id = channels[i]
        if id then SetChatColorNameByClass("CHANNEL" .. id, true) end
    end
end

CleanClassicUI.OnEvent(function()
    applyStyle()
    enableClassColors()
end, "PLAYER_ENTERING_WORLD", "UPDATE_FLOATING_CHAT_WINDOWS")

-- FCF_SetTemporaryWindowType receives the new chatFrame as its first argument, so we can style brand-new temp tabs (ChatFrameNTab where N > NUM_CHAT_WINDOWS) directly.
hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame)
    if not chatFrame then return end
    CleanClassicUI.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
    stripChatFrameTextures(chatFrame)
    styleTab(_G[chatFrame:GetName() .. "Tab"])
    styleEditBox(chatFrame, _G[chatFrame:GetName() .. "EditBox"])
end)

hooksecurefunc("ChatEdit_UpdateHeader", function(editBox)
    local headerSuffix = _G[editBox:GetName() .. "HeaderSuffix"]
    if headerSuffix then
        headerSuffix:Hide()
        if editBox.header then
            editBox:SetTextInsets(15 + editBox.header:GetWidth(), 13, 0, 0)
        end
    end

    if editBox:GetAttribute("chatType") ~= "WHISPER" then return end
    local whisperColor = ChatTypeInfo["WHISPER_INFORM"]
    if not whisperColor then return end
    editBox:SetTextColor(whisperColor.r, whisperColor.g, whisperColor.b)
    if editBox.header then
        editBox.header:SetTextColor(whisperColor.r, whisperColor.g, whisperColor.b)
    end
end)

local isMacClient = IsMacClient and IsMacClient()

local function isInviteModifierDown()
    if isMacClient then return IsMetaKeyDown() end
    return IsAltKeyDown()
end

local originalHyperlinkShow = ChatFrame_OnHyperlinkShow
ChatFrame_OnHyperlinkShow = function(self, link, text, button)
    if button == "LeftButton" then
        local name = link:match("^player:([^:]+)")
        if name and name ~= "" then
            if IsControlKeyDown() then
                FCF_OpenTemporaryWindow("WHISPER", name, self, true)
                return
            elseif isInviteModifierDown() then
                InviteUnit(name)
                return
            end
        end
    end
    return originalHyperlinkShow(self, link, text, button)
end
