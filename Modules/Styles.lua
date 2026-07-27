CleanClassicExperience = CleanClassicExperience or {}

CleanClassicExperience.BAR_TEXTURE = "Interface/RaidFrame/Raid-Bar-Hp-Fill"
CleanClassicExperience.BAR_ATLAS = "UI-HUD-CoolDownManager-Bar"
CleanClassicExperience.EDGE_FILE = "Interface/Tooltips/UI-Tooltip-Border"

CleanClassicExperience.BORDER = 3

-- Keyed by pixel value; use SPACING[8] over a bare 8 to mark an intentional layout gap.
CleanClassicExperience.SPACING = {
    [4]  = 4,
    [8]  = 8,
    [16] = 16,
    [24] = 24,
}

-- RED through ORANGE mirror Blizzard's debuff-type border colors so aura borders match the game.
CleanClassicExperience.COLOR = {
    RED    = { 0.800, 0.000, 0.000 },
    GREEN  = { 0.000, 0.600, 0.000 },
    BLUE   = { 0.200, 0.600, 1.000 },
    VIOLET = { 0.600, 0.000, 1.000 },
    ORANGE = { 0.600, 0.400, 0.000 },
    GREY   = { 0.5, 0.5, 0.5 },
}

local EDGE_SIZE = 12

-- Backdrop edges render in local coordinates; divide by the host's extra scale so every border matches on screen.
local function extraScale(frame)
    local frameScale, uiScale = frame:GetEffectiveScale(), UIParent:GetEffectiveScale()
    if not frameScale or not uiScale or frameScale == 0 or uiScale == 0 then return 1 end
    return frameScale / uiScale
end

-- Safe to re-apply after scale changes; anchor optionally wraps an inner region instead of the frame.
-- proportional keeps the raw edge so the border rides the host's Edit Mode scale instead of holding on-screen size.
function CleanClassicExperience.ApplyBorder(frame, level, edgeSize, anchor, proportional)
    if not frame then return end

    local scale = proportional and 1 or extraScale(frame)
    local edge = (edgeSize or EDGE_SIZE) / scale
    local inset = CleanClassicExperience.BORDER / scale

    local border = frame.cleanBorder
    if border and border.cleanEdge == edge then return border end

    if not border then
        border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        border:SetFrameStrata(frame:GetFrameStrata())
        border:SetFrameLevel((level or frame:GetFrameLevel()) + 5)
        frame.cleanBorder = border
    end

    -- SetBackdrop resets the border color to white; keep the caller's color on re-apply.
    local r, g, b, a
    if border.cleanEdge then
        r, g, b, a = border:GetBackdropBorderColor()
    else
        r, g, b = unpack(CleanClassicExperience.COLOR.GREY)
    end

    local target = anchor or frame
    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", target, "TOPLEFT", -inset, inset)
    border:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", inset, -inset)
    border:SetBackdrop({ edgeFile = CleanClassicExperience.EDGE_FILE, edgeSize = edge })
    border:SetBackdropBorderColor(r, g, b, a)
    border.cleanEdge = edge
    return border
end

local ICON_CROP = 0.1

-- The glow art runs nearly to its texture edge while the flash carries more margin, so each needs its own overshoot.
local GLOW_SCALE  = 1.05
local FLASH_SCALE = 1.15

-- Shared restyle for action, bag, and aura buttons; borderAnchor wraps an inner region and the border is returned.
function CleanClassicExperience.StyleButton(btn, borderAnchor)
    if not btn then return end

    -- Clear the file and zero the alpha so oversized stock ring art stays gone even if Blizzard re-sets it.
    local normalTexture = btn.GetNormalTexture and btn:GetNormalTexture()
    if normalTexture then
        normalTexture:SetTexture(nil)
        normalTexture:SetAlpha(0)
    end

    -- Swap the stock depress art for the bluish hover glow; fitted with the other glows below.
    local pushedTexture = btn.GetPushedTexture and btn:GetPushedTexture()
    if pushedTexture then
        pushedTexture:SetTexture("Interface/Buttons/ButtonHilight-Square")
        pushedTexture:SetBlendMode("ADD")
        pushedTexture:SetAlpha(1)
    end

    local name = btn:GetName()

    local icon = btn.icon or btn.Icon
        or (name and (_G[name .. "IconTexture"] or _G[name .. "Icon"]))
    if icon then icon:SetTexCoord(ICON_CROP, 1 - ICON_CROP, ICON_CROP, 1 - ICON_CROP) end

    local width, height = btn:GetSize()
    if width and width > 0 then
        local function fitGlow(glow, scale)
            if not glow then return end
            scale = scale or GLOW_SCALE
            glow:ClearAllPoints()
            glow:SetPoint("CENTER", btn, "CENTER")
            glow:SetSize(width * scale, height * scale)
        end
        fitGlow(btn.GetCheckedTexture and btn:GetCheckedTexture())
        fitGlow(btn.GetHighlightTexture and btn:GetHighlightTexture())
        fitGlow(pushedTexture)

        -- Restore the alpha earlier versions zeroed before fitting the auto-attack flash.
        local flash = btn.Flash or (name and _G[name .. "Flash"])
        if flash then
            flash:SetAlpha(1)
            fitGlow(flash, FLASH_SCALE)
        end
    end

    return CleanClassicExperience.ApplyBorder(btn, nil, nil, borderAnchor)
end

function CleanClassicExperience.HideForever(frame)
    if not frame then return end
    frame:Hide()
    frame:SetScript("OnShow", frame.Hide)
end

function CleanClassicExperience.OnEvent(callback, ...)
    local frame = CreateFrame("Frame")
    for i = 1, select("#", ...) do
        frame:RegisterEvent((select(i, ...)))
    end
    frame:SetScript("OnEvent", callback)
    return frame
end
