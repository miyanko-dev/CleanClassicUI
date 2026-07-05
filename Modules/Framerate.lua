local MARGIN = CleanClassicUI.SPACING.MD

-- The FPS readout is a WorldFrame label + number. Pin the label to the
-- top-left and force the number to sit on its right so both move together.
local function styleFramerate()
    if not (FramerateLabel and FramerateText) then return end

    FramerateLabel:ClearAllPoints()
    FramerateLabel:SetPoint("TOPLEFT", UIParent, "TOPLEFT", MARGIN, -MARGIN)

    FramerateText:ClearAllPoints()
    FramerateText:SetPoint("LEFT", FramerateLabel, "RIGHT")

    for _, text in ipairs({ FramerateLabel, FramerateText }) do
        local font, size = text:GetFont()
        text:SetFont(font, size, "OUTLINE")
    end
end

styleFramerate()

-- The readout may be created or re-anchored after load, so re-apply when it
-- is toggled (Ctrl+R) and once the world is up.
if ToggleFramerate then
    hooksecurefunc("ToggleFramerate", styleFramerate)
end

CleanClassicUI.OnEvent(styleFramerate, "PLAYER_ENTERING_WORLD")
