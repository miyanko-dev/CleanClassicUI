local BAR_H = 20

-- Border art extends 3px past each frame edge; pad the stack gap so it stays visible.
local STACK_GAP = CleanClassicUI.SPACING.SM + 2 * CleanClassicUI.BORDER

local function styleTimer(index)
    local frame     = _G["MirrorTimer" .. index]
    local statusbar = _G["MirrorTimer" .. index .. "StatusBar"]
    local text      = _G["MirrorTimer" .. index .. "Text"]
    local border    = _G["MirrorTimer" .. index .. "Border"]
    if not (frame and statusbar and text and border) then return end

    frame:SetHeight(BAR_H)
    border:Hide()

    statusbar:ClearAllPoints()
    statusbar:SetAllPoints(frame)
    statusbar:SetStatusBarTexture(CleanClassicUI.BAR_TEXTURE)

    -- Stretch the template's anonymous black backdrop behind the full bar.
    for _, region in ipairs({ frame:GetRegions() }) do
        if region:GetObjectType() == "Texture" and region:GetDrawLayer() == "BACKGROUND" then
            region:ClearAllPoints()
            region:SetAllPoints(frame)
        end
    end

    text:ClearAllPoints()
    text:SetPoint("CENTER", frame, "CENTER", 0, 0)

    CleanClassicUI.ApplyBorder(frame)

    if index > 1 then
        frame:ClearAllPoints()
        frame:SetPoint("TOP", _G["MirrorTimer" .. (index - 1)], "BOTTOM", 0, -STACK_GAP)
    end
end

for index = 1, MIRRORTIMER_NUMTIMERS do
    styleTimer(index)
end
