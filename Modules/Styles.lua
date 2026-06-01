CleanClassicUI = CleanClassicUI or {}

CleanClassicUI.BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"
CleanClassicUI.EDGE_FILE = "Interface/Tooltips/UI-Tooltip-Border"
CleanClassicUI.BG_FILE = "Interface/Tooltips/UI-Tooltip-Background"

CleanClassicUI.BORDER = 3
CleanClassicUI.BTN_SIZE = 36

CleanClassicUI.SPACING = {
    XS  = 4,
    SM  = 8,
    MD  = 16,
    LG  = 24,
    XL  = 32,
    XXL = 48,
}

CleanClassicUI.COLOR = {
    RED    = { 0.980, 0.153, 0.184 },
    GREEN  = { 0.188, 0.996, 0.192 },
    BLUE   = { 0.157, 0.443, 0.851 },
    VIOLET = { 0.643, 0.231, 0.918 },
    ORANGE = { 0.984, 0.506, 0.157 },
    YELLOW = { 0.984, 0.820, 0.204 },
    GREY   = { 0.5, 0.5, 0.5 },
}

local EDGE_SIZE = 12

function CleanClassicUI.ApplyBorder(frame, level)
    if not frame or frame.cleanBorder then return frame and frame.cleanBorder end
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -CleanClassicUI.BORDER, CleanClassicUI.BORDER)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", CleanClassicUI.BORDER, -CleanClassicUI.BORDER)
    border:SetBackdrop({ edgeFile = CleanClassicUI.EDGE_FILE, edgeSize = EDGE_SIZE })
    border:SetBackdropBorderColor(unpack(CleanClassicUI.COLOR.GREY))
    border:SetFrameStrata(frame:GetFrameStrata())
    border:SetFrameLevel((level or frame:GetFrameLevel()) + 5)
    frame.cleanBorder = border
    return border
end

function CleanClassicUI.HideForever(frame)
    if not frame then return end
    frame:Hide()
    frame:SetScript("OnShow", frame.Hide)
end

function CleanClassicUI.OnEvent(callback, ...)
    local frame = CreateFrame("Frame")
    for i = 1, select("#", ...) do
        frame:RegisterEvent((select(i, ...)))
    end
    frame:SetScript("OnEvent", callback)
    return frame
end
