local BAR_HEIGHT = 20

-- Border art extends 3px past each frame edge; pad the stack gap so it stays visible.
local STACK_GAP = CleanClassicExperience.SPACING[8] + 2 * CleanClassicExperience.BORDER

local function styleTimer(index)
    local frame     = _G["MirrorTimer" .. index]
    local statusbar = _G["MirrorTimer" .. index .. "StatusBar"]
    local text      = _G["MirrorTimer" .. index .. "Text"]
    local border    = _G["MirrorTimer" .. index .. "Border"]
    if not (frame and statusbar and text and border) then return end

    frame:SetHeight(BAR_HEIGHT)
    border:Hide()

    statusbar:ClearAllPoints()
    statusbar:SetAllPoints(frame)
    statusbar:SetStatusBarTexture(CleanClassicExperience.BAR_TEXTURE)

    -- Stretch the template's anonymous black backdrop behind the full bar.
    for _, region in ipairs({ frame:GetRegions() }) do
        if region:GetObjectType() == "Texture" and region:GetDrawLayer() == "BACKGROUND" then
            region:ClearAllPoints()
            region:SetAllPoints(frame)
        end
    end

    text:ClearAllPoints()
    text:SetPoint("CENTER", frame, "CENTER", 0, 0)

    CleanClassicExperience.ApplyBorder(frame)

    if index > 1 then
        frame:ClearAllPoints()
        frame:SetPoint("TOP", _G["MirrorTimer" .. (index - 1)], "BOTTOM", 0, -STACK_GAP)
    end
end

for index = 1, MIRRORTIMER_NUMTIMERS do
    styleTimer(index)
end

-- Footprint and default spot mirror MirrorTimer1's stock XML anchor, so an unsaved layout changes nothing.
local mover = CleanClassicExperience.CreateMover("Exhaustion", "exhaustionAnchor", 206, BAR_HEIGHT)
mover:SetPoint("TOP", 0, -96)

-- Timers 2 and 3 chain below timer 1, so re-homing the first bar carries the whole stack.
MirrorTimer1:ClearAllPoints()
MirrorTimer1:SetPoint("TOP", mover, "TOP")
