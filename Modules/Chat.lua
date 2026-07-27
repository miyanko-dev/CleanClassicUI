-- Both 1.15.9 and 2.5.6 run the modern chat code; Edit Mode owns ChatFrame1's position and size.
local SPACING = CleanClassicExperience.SPACING
local BLOCK_GAP = SPACING[4]
local SELECTION_PAD = SPACING[4]
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

    -- The ": " suffix leaks at dimmed alpha when Blizzard fades the box out; bind its visibility to the header.
    local headerSuffix = _G[editBox:GetName() .. "HeaderSuffix"]
    if headerSuffix then
        headerSuffix:Hide()
        local suffixFont, suffixSize = headerSuffix:GetFont()
        headerSuffix:SetFont(suffixFont, suffixSize, "OUTLINE")
    end

    -- UpdateHeader is a mixin method copied onto each editbox, so hook every object.
    hooksecurefunc(editBox, "UpdateHeader", updateHeaderExtras)

    -- The template's ignoreArrows demands Alt for cursor movement; plain arrows now move and cycle history.
    editBox:SetAltArrowKeyMode(false)

    editBox.cleanStyled = true
end

-- Native anchors pad for the hidden button frame and tab chrome; re-hug the visible tab, message frame, and edit box so drags and snapping stay precise.
local function wrapEditModeSelection(chatFrame)
    local selection = chatFrame.Selection
    if not selection then return end

    local name = chatFrame:GetName()
    local tab = _G[name .. "Tab"]
    local editBox = _G[name .. "EditBox"]

    selection:ClearAllPoints()
    selection:SetPoint("TOP", tab or chatFrame, "TOP", 0, SELECTION_PAD)
    selection:SetPoint("LEFT", chatFrame, "LEFT", -SELECTION_PAD, 0)
    selection:SetPoint("RIGHT", chatFrame, "RIGHT", SELECTION_PAD, 0)
    selection:SetPoint("BOTTOM", editBox or chatFrame, "BOTTOM", 0, -SELECTION_PAD)

    -- Base AnchorSelectionFrame computed clamps from the old rect; refresh against the new one.
    chatFrame:UpdateClampOffsets()
end

local MIN_WIDTH = CHAT_FRAME_MIN_WIDTH or 40
local MIN_HEIGHT = CHAT_FRAME_NORMAL_MIN_HEIGHT or 46

-- StartSizing("BOTTOMRIGHT") pins the top-left, so screen-clamping the growing bottom shoves the top upward instead.
-- Cap max height at the room below the pinned top (minus the edit box that trails the frame) so the bottom just stops.
local function capResizeToScreen(chatFrame)
    local editBox = _G[chatFrame:GetName() .. "EditBox"]
    local reserved = SELECTION_PAD
    if editBox then reserved = reserved + editBox:GetHeight() + BLOCK_GAP end

    local maxHeight = math.max(MIN_HEIGHT, chatFrame:GetTop() - reserved)
    chatFrame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, GetScreenWidth(), maxHeight)
end

-- Drop the temporary height cap so the width and height settings can still size the frame freely.
local function restoreResizeBounds(chatFrame)
    chatFrame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT)
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
        end
    end
end

local function enableClassColors()
    -- A redundant SetCVar fires CVAR_UPDATE under insecure execution, so only set on change.
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

-- Style brand-new temporary tabs directly from the frame the hook receives.
hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame)
    if not chatFrame then return end
    CleanClassicExperience.HideForever(_G[chatFrame:GetName() .. "ButtonFrame"])
    stripChatFrameTextures(chatFrame)
    styleTab(_G[chatFrame:GetName() .. "Tab"])
    styleEditBox(chatFrame, _G[chatFrame:GetName() .. "EditBox"])
end)

-- FCF_StartAlertFlash pins an alerting tab's idle alpha to 1; replacing the global taints, so cancel via post-hook.
hooksecurefunc("FCF_StartAlertFlash", FCF_StopAlertFlash)

-- Only ChatFrame1 inherits EditModeChatFrameSystemTemplate; retighten its selection each time the game re-anchors it.
if ChatFrame1 and ChatFrame1.AnchorSelectionFrame then
    hooksecurefunc(ChatFrame1, "AnchorSelectionFrame", wrapEditModeSelection)
end

-- Cap the resize while the grabber drags, then release the cap so nothing else stays constrained.
local resizeButton = ChatFrame1 and ChatFrame1.EditModeResizeButton
if resizeButton then
    resizeButton:HookScript("OnMouseDown", function() capResizeToScreen(ChatFrame1) end)
    resizeButton:HookScript("OnMouseUp", function() restoreResizeBounds(ChatFrame1) end)
end
