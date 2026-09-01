local function skinBars(frame)
    if not frame then return end

    -- Share the nameplate health bar fill atlas used across the unit frames
    if frame.healthBar then frame.healthBar:SetStatusBarTexture(CleanClassicUI.BAR_ATLAS) end

    if frame.powerBar then frame.powerBar:SetStatusBarTexture(CleanClassicUI.BAR_ATLAS) end
end

hooksecurefunc("DefaultCompactUnitFrameSetup", skinBars)
hooksecurefunc("DefaultCompactMiniFrameSetup", skinBars)

-- Catch pet and target minis, whose setup func the raid container captured before this addon loaded
hooksecurefunc("CompactUnitFrame_SetUpFrame", skinBars)
