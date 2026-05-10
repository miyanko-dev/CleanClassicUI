CleanUI = CleanUI or {}

CleanUI.BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"

local EDGE_FILE = "Interface/Tooltips/UI-Tooltip-Border"
local EDGE_SIZE = 12
local OFFSET = 3

function CleanUI.ApplyBorder(frame, level)
    if not frame or frame.cleanBorder then return frame.cleanBorder end
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -OFFSET, OFFSET)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", OFFSET, -OFFSET)
    border:SetBackdrop({ edgeFile = EDGE_FILE, edgeSize = EDGE_SIZE })
    border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    border:SetFrameStrata(frame:GetFrameStrata())
    border:SetFrameLevel((level or frame:GetFrameLevel()) + 5)
    frame.cleanBorder = border
    return border
end
