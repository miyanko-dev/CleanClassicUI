local SPACING = CleanClassicExperience.SPACING
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

-- TBC 2.5.6 replaced the ChatEdit_*/ChatFrame_* globals with ChatFrameUtil and
-- editbox/chat-frame mixin methods, and hands ChatFrame1's position to Edit Mode;
-- era 1.15 keeps all the old globals.
local modernChat = ChatEdit_UpdateHeader == nil

local getActiveWindow = ChatEdit_GetActiveWindow or ChatFrameUtil.GetActiveWindow
local deactivateChat = ChatEdit_DeactivateChat or ChatFrameUtil.DeactivateChat
local inviteUnit = InviteUnit or C_PartyInfo.InviteUnit

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

local function updateHeaderExtras(editBox)
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
    -- on deactivate; visibility is bound to the header via updateHeaderExtras.
    local headerSuffix = _G[editBox:GetName() .. "HeaderSuffix"]
    if headerSuffix then
        headerSuffix:Hide()
        local suffixFont, suffixSize = headerSuffix:GetFont()
        headerSuffix:SetFont(suffixFont, suffixSize, "OUTLINE")
    end

    -- On TBC UpdateHeader is a mixin method copied onto each editbox, so the
    -- post-hook has to be installed per object instead of on a global.
    if modernChat then
        hooksecurefunc(editBox, "UpdateHeader", updateHeaderExtras)
    end

    -- The template ships with ignoreArrows="true", which requires Alt for
    -- cursor movement; disabling it lets plain left/right move the cursor
    -- and plain up/down cycle the native input history.
    editBox:SetAltArrowKeyMode(false)

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
    CleanClassicExperience.HideForever(ChatFrameMenuButton)
    CleanClassicExperience.HideForever(ChatFrameChannelButton)

    local maxWindows = NUM_CHAT_WINDOWS or Constants.ChatFrameConstants.MaxChatWindows
    for i = 1, maxWindows do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            local editBox = _G[chatFrame:GetName() .. "EditBox"]
            local tab = _G[chatFrame:GetName() .. "Tab"]
            CleanClassicExperience.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
            stripChatFrameTextures(chatFrame)
            styleTab(tab)
            styleEditBox(chatFrame, editBox)
            -- Edit Mode owns ChatFrame1's position on TBC.
            if chatFrame == ChatFrame1 and not modernChat then
                positionChatFrame(chatFrame, editBox)
            end
        end
    end
end

local function enableClassColors()
    -- Guard like NamePlates: a redundant SetCVar fires CVAR_UPDATE under insecure execution.
    if GetCVar("chatClassColorOverride") ~= "0" then
        SetCVar("chatClassColorOverride", "0")
    end
    for chatType in pairs(ChatTypeGroup) do
        SetChatColorNameByClass(chatType, true)
    end
    local channels = { GetChannelList() }
    for i = 1, #channels, 3 do
        local id = channels[i]
        if id then SetChatColorNameByClass("CHANNEL" .. id, true) end
    end
end

CleanClassicExperience.OnEvent(function()
    applyStyle()
    enableClassColors()
end, "PLAYER_ENTERING_WORLD", "UPDATE_FLOATING_CHAT_WINDOWS")

-- FCF_SetTemporaryWindowType receives the new chatFrame as its first argument, so we can style brand-new temp tabs (ChatFrameNTab where N > NUM_CHAT_WINDOWS) directly.
hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame)
    if not chatFrame then return end
    CleanClassicExperience.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
    stripChatFrameTextures(chatFrame)
    styleTab(_G[chatFrame:GetName() .. "Tab"])
    styleEditBox(chatFrame, _G[chatFrame:GetName() .. "EditBox"])
end)

-- New messages in a background tab call FCF_StartAlertFlash, which sets the tab
-- to alerting and pins its idle alpha to CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA (1.0);
-- constant channel traffic leaves the tab permanently lit. Replacing the global
-- taints Blizzard's message handling, so cancel the flash from a post-hook instead.
hooksecurefunc("FCF_StartAlertFlash", FCF_StopAlertFlash)

if not modernChat then
    hooksecurefunc("ChatEdit_UpdateHeader", updateHeaderExtras)
end

local isMacClient = IsMacClient and IsMacClient()

local function isInviteModifierDown()
    if isMacClient then return IsMetaKeyDown() end
    return IsAltKeyDown()
end

local function isFriendModifierDown()
    if isMacClient then return IsAltKeyDown() end
    return IsMetaKeyDown()
end

-- Replacing the global ChatFrame_OnHyperlinkShow taints Blizzard's whole click path:
-- the dropdown opened by right-clicking a player name inherits the taint and its
-- protected Copy Character Name -> CopyToClipboard() call fires ADDON_ACTION_FORBIDDEN.
-- A post-hook stays off the secure path; Blizzard's default left-click action
-- (send-tell -> whisper edit box) runs first, so deactivate that edit box
-- before applying our modifier-click behavior.
local function onHyperlinkClick(chatFrame, link, text, button)
    if button ~= "LeftButton" then return end
    local name = link:match("^player:([^:]+)")
    if not name or name == "" then return end

    local wantsWhisperTab = IsControlKeyDown()
    local wantsInvite = not wantsWhisperTab and isInviteModifierDown()
    local wantsFriend = not (wantsWhisperTab or wantsInvite) and isFriendModifierDown()
    if not (wantsWhisperTab or wantsInvite or wantsFriend) then return end

    local editBox = getActiveWindow()
    if editBox then deactivateChat(editBox) end

    if wantsWhisperTab then
        FCF_OpenTemporaryWindow("WHISPER", name, chatFrame, true)
    elseif wantsInvite then
        inviteUnit(name)
    else
        C_FriendList.AddFriend(name)
    end
end

if modernChat then
    EventRegistry:RegisterCallback("ChatFrame.OnHyperlinkClick", function(_, chatFrame, link, text, button)
        onHyperlinkClick(chatFrame, link, text, button)
    end, CleanClassicExperience)
else
    hooksecurefunc("ChatFrame_OnHyperlinkShow", onHyperlinkClick)
end
