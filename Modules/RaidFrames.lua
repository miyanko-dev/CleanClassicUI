local function skinBars(uf)
    if not uf then return end
    if uf.healthBar then uf.healthBar:SetStatusBarTexture(CleanUI.BAR_TEXTURE) end
    if uf.powerBar then uf.powerBar:SetStatusBarTexture(CleanUI.BAR_TEXTURE) end
end

hooksecurefunc("CompactUnitFrame_UpdateHealth", skinBars)
hooksecurefunc("CompactUnitFrame_UpdatePower", skinBars)
