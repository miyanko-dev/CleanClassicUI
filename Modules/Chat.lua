local SPACING = NewNativeUI.SPACING
local BLOCK_GAP = SPACING.XS
local SCREEN_MARGIN = SPACING.MD
local TAB_FONT_SIZE = 14
local TAB_HEIGHT = 22
local TAB_PADDING_X = SPACING.SM

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
        local tex = _G[name .. suffix]
        if tex then tex:SetTexture(nil) end
    end
end

local function sizeTab(tab)
    if not tab then return end
    local text = _G[tab:GetName() .. "Text"]
    if not text then return end
    tab:SetHeight(TAB_HEIGHT)
    tab:SetWidth(math.ceil(text:GetStringWidth()) + TAB_PADDING_X * 2)
end

local function styleTab(tab)
    if not tab or tab.cleanStyled then return end
    local name = tab:GetName()
    for _, suffix in ipairs(TAB_TEXTURE_SUFFIXES) do
        local tex = _G[name .. suffix]
        if tex then tex:SetTexture(nil) end
    end
    local text = _G[name .. "Text"]
    if text then
        local font = text:GetFont()
        text:SetFont(font, TAB_FONT_SIZE, "OUTLINE")
        -- Blizzard's ChatTabTemplate anchors text at CENTER with y=-5; re-center it.
        text:ClearAllPoints()
        text:SetPoint("CENTER", tab, "CENTER", 0, 0)
    end
    sizeTab(tab)
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
        local tex = _G[editBox:GetName() .. suffix]
        if tex then tex:Hide() end
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
        local hfont, hsize = header:GetFont()
        header:SetFont(hfont, hsize, "OUTLINE")
    end

    -- $parentHeaderSuffix (the ": " after the chat type) is in the editbox's
    -- ARTWORK layer and leaks at dimmed alpha when Blizzard fades the box out
    -- on deactivate; visibility is bound to the header via ChatEdit_UpdateHeader below.
    local headerSuffix = _G[editBox:GetName() .. "HeaderSuffix"]
    if headerSuffix then
        headerSuffix:Hide()
        local sfont, ssize = headerSuffix:GetFont()
        headerSuffix:SetFont(sfont, ssize, "OUTLINE")
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

local function layoutTabs()
    local prev = nil
    for i = 1, NUM_CHAT_WINDOWS do
        local tab = _G["ChatFrame" .. i .. "Tab"]
        if tab and tab:IsShown() then
            sizeTab(tab)
            tab:ClearAllPoints()
            if prev then
                tab:SetPoint("BOTTOMLEFT", prev, "BOTTOMRIGHT", BLOCK_GAP, 0)
            else
                tab:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, BLOCK_GAP)
            end
            prev = tab
        end
    end
end

local function applyStyle()
    NewNativeUI.HideForever(ChatFrameMenuButton)
    NewNativeUI.HideForever(ChatFrameChannelButton)

    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            local editBox = _G[chatFrame:GetName() .. "EditBox"]
            local tab = _G[chatFrame:GetName() .. "Tab"]
            NewNativeUI.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
            stripChatFrameTextures(chatFrame)
            styleTab(tab)
            styleEditBox(chatFrame, editBox)
            if chatFrame == ChatFrame1 then
                positionChatFrame(chatFrame, editBox)
            end
        end
    end

    layoutTabs()
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

NewNativeUI.OnEvent(function()
    applyStyle()
    enableClassColors()
end, "PLAYER_ENTERING_WORLD", "UPDATE_FLOATING_CHAT_WINDOWS")

hooksecurefunc("FCF_OpenTemporaryWindow", function()
    local chatFrame = FCF_GetCurrentChatFrame()
    if chatFrame then
        NewNativeUI.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
        stripChatFrameTextures(chatFrame)
        styleTab(_G[chatFrame:GetName() .. "Tab"])
        styleEditBox(chatFrame, _G[chatFrame:GetName() .. "EditBox"])
    end
    layoutTabs()
end)

if FCFDock_UpdateTabs then
    hooksecurefunc("FCFDock_UpdateTabs", layoutTabs)
end

hooksecurefunc("FCF_SetWindowName", function(chatFrame)
    if chatFrame then
        sizeTab(_G[chatFrame:GetName() .. "Tab"])
    end
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

local _origHyperlinkShow = ChatFrame_OnHyperlinkShow
ChatFrame_OnHyperlinkShow = function(self, link, text, button)
    if button == "LeftButton" and IsControlKeyDown() then
        local name = link:match("^player:([^:]+)")
        if name and name ~= "" then
            FCF_OpenTemporaryWindow("WHISPER", name, self, true)
            return
        end
    end
    return _origHyperlinkShow(self, link, text, button)
end
