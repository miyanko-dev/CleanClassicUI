NewNativeUI = NewNativeUI or {}

NewNativeUI.BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"
NewNativeUI.EDGE_FILE = "Interface/Tooltips/UI-Tooltip-Border"
NewNativeUI.BG_FILE = "Interface/Tooltips/UI-Tooltip-Background"

NewNativeUI.BORDER = 3
NewNativeUI.BTN_SIZE = 36

NewNativeUI.SPACING = {
    XS  = 4,
    SM  = 8,
    MD  = 16,
    LG  = 24,
    XL  = 32,
    XXL = 48,
}

NewNativeUI.COLOR = {
    RED    = { 0.980, 0.153, 0.184 },
    GREEN  = { 0.188, 0.996, 0.192 },
    BLUE   = { 0.157, 0.443, 0.851 },
    VIOLET = { 0.643, 0.231, 0.918 },
    ORANGE = { 0.984, 0.506, 0.157 },
    YELLOW = { 0.984, 0.820, 0.204 },
    GREY   = { 0.5, 0.5, 0.5 },
}

local EDGE_SIZE = 12

function NewNativeUI.ApplyBorder(frame, level)
    if not frame or frame.cleanBorder then return frame and frame.cleanBorder end
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -NewNativeUI.BORDER, NewNativeUI.BORDER)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", NewNativeUI.BORDER, -NewNativeUI.BORDER)
    border:SetBackdrop({ edgeFile = NewNativeUI.EDGE_FILE, edgeSize = EDGE_SIZE })
    border:SetBackdropBorderColor(unpack(NewNativeUI.COLOR.GREY))
    border:SetFrameStrata(frame:GetFrameStrata())
    border:SetFrameLevel((level or frame:GetFrameLevel()) + 5)
    frame.cleanBorder = border
    return border
end

function NewNativeUI.HideForever(frame)
    if not frame then return end
    frame:Hide()
    frame:SetScript("OnShow", frame.Hide)
end

function NewNativeUI.OnEvent(handler, ...)
    local frame = CreateFrame("Frame")
    for i = 1, select("#", ...) do
        frame:RegisterEvent((select(i, ...)))
    end
    frame:SetScript("OnEvent", handler)
    return frame
end
