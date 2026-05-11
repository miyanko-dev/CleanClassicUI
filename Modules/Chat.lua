local EDGE_FILE = "Interface/Tooltips/UI-Tooltip-Border"
local BG_FILE = "Interface/Tooltips/UI-Tooltip-Background"
local EDITBOX_GAP = 8

local function kill(el)
    if not el then return end
    el:Hide()
    el:SetScript("OnShow", el.Hide)
end

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
        bgFile = BG_FILE,
        edgeFile = EDGE_FILE,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    bg:SetBackdropColor(0, 0, 0, 1)
    bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    bg:SetFrameLevel(editBox:GetFrameLevel() - 1)
    bg:Hide()
    editBox.cleanBg = bg

    local header = _G[editBox:GetName() .. "Header"]
    if header then
        header:ClearAllPoints()
        header:SetPoint("LEFT", editBox, "LEFT", 8, 0)
    end

    editBox:HookScript("OnEditFocusGained", function(self) self.cleanBg:Show() end)
    editBox:HookScript("OnEditFocusLost", function(self) self.cleanBg:Hide() end)
end

local function applyStyle()
    kill(ChatFrameMenuButton)
    kill(ChatFrameChannelButton)

    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame" .. i]
        if cf then
            kill(_G[cf:GetName() .. "ButtonFrame"])
            styleEditBox(cf, _G[cf:GetName() .. "EditBox"])
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

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS")
frame:SetScript("OnEvent", function()
    applyStyle()
    enableClassColors()
end)

hooksecurefunc("FCF_OpenTemporaryWindow", function()
    local cf = FCF_GetCurrentChatFrame()
    if cf then
        kill(_G[cf:GetName() .. "ButtonFrame"])
        styleEditBox(cf, _G[cf:GetName() .. "EditBox"])
    end
end)

hooksecurefunc("ChatEdit_UpdateHeader", function(editBox)
    if editBox:GetAttribute("chatType") ~= "WHISPER" then return end
    local info = ChatTypeInfo["WHISPER_INFORM"]
    if not info then return end
    editBox:SetTextColor(info.r, info.g, info.b)
    if editBox.header then
        editBox.header:SetTextColor(info.r, info.g, info.b)
    end
end)
