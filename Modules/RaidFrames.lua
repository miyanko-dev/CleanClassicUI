local function skinBars(frame)
    if not frame then return end

    -- Share the nameplate health bar fill atlas used across the unit frames
    if frame.healthBar then frame.healthBar:SetStatusBarTexture(CleanClassicExperience.BAR_ATLAS) end

    if frame.powerBar then frame.powerBar:SetStatusBarTexture(CleanClassicExperience.BAR_ATLAS) end
end

hooksecurefunc("DefaultCompactUnitFrameSetup", skinBars)
hooksecurefunc("DefaultCompactMiniFrameSetup", skinBars)
