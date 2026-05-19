local SPACING = CleanUI.SPACING
local EDITBOX_GAP = SPACING.SM

local function styleEditBox(chatFrame, editBox)
    if not editBox or editBox.cleanBg then return end

    for _, suffix in ipairs({ "Left", "Mid", "Right" }) do
        local tex = _G[editBox:GetName() .. suffix]
        if tex then tex:Hide() end
    end

    editBox:ClearAllPoints()
    editBox:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT", -3, -EDITBOX_GAP)
    editBox:SetPoint("TOPRIGHT", chatFrame, "BOTTOMRIGHT", 3, -EDITBOX_GAP)

    local bg = CreateFrame("Frame", nil, editBox, "BackdropTemplate")
    bg:SetAllPoints(editBox)
    bg:SetBackdrop({
        bgFile = CleanUI.BG_FILE,
        edgeFile = CleanUI.EDGE_FILE,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    bg:SetBackdropColor(0, 0, 0, 1)
    bg:SetBackdropBorderColor(unpack(CleanUI.COLOR.GREY))
    bg:SetFrameLevel(editBox:GetFrameLevel() - 1)
    bg:Hide()
    editBox.cleanBg = bg

    local header = _G[editBox:GetName() .. "Header"]
    if header then
        header:ClearAllPoints()
        header:SetPoint("LEFT", editBox, "LEFT", 8, 0)
    end

    -- $parentHeaderSuffix (the ": " after the chat type) is in the editbox's
    -- ARTWORK layer and leaks at dimmed alpha when Blizzard fades the box out
    -- on deactivate; toggle it with focus instead.
    local headerSuffix = _G[editBox:GetName() .. "HeaderSuffix"]
    if headerSuffix then headerSuffix:Hide() end

    editBox:HookScript("OnEditFocusGained", function(self)
        self.cleanBg:Show()
        if headerSuffix then headerSuffix:Show() end
    end)
    editBox:HookScript("OnEditFocusLost", function(self)
        self.cleanBg:Hide()
        if headerSuffix then headerSuffix:Hide() end
    end)
end

local function applyStyle()
    CleanUI.HideForever(ChatFrameMenuButton)
    CleanUI.HideForever(ChatFrameChannelButton)

    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            CleanUI.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
            styleEditBox(chatFrame, _G[chatFrame:GetName() .. "EditBox"])
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

CleanUI.OnEvent(function()
    applyStyle()
    enableClassColors()
end, "PLAYER_ENTERING_WORLD", "UPDATE_FLOATING_CHAT_WINDOWS")

hooksecurefunc("FCF_OpenTemporaryWindow", function()
    local chatFrame = FCF_GetCurrentChatFrame()
    if chatFrame then
        CleanUI.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
        styleEditBox(chatFrame, _G[chatFrame:GetName() .. "EditBox"])
    end
end)

hooksecurefunc("ChatEdit_UpdateHeader", function(editBox)
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
