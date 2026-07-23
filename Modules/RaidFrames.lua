local function skinBars(frame)
    if not frame then return end

    if frame.healthBar then frame.healthBar:SetStatusBarTexture(CleanClassicExperience.BAR_ATLAS) end
    if frame.powerBar  then frame.powerBar:SetStatusBarTexture(CleanClassicExperience.BAR_TEXTURE)  end
end

hooksecurefunc("CompactUnitFrame_UpdateHealth", skinBars)
hooksecurefunc("CompactUnitFrame_UpdatePower",  skinBars)
