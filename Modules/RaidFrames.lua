local function skinBars(uf)
    if uf and uf.healthBar then
        uf.healthBar:SetStatusBarTexture(CleanUI.BAR_TEXTURE)
    end
    if uf and uf.powerBar then
        uf.powerBar:SetStatusBarTexture(CleanUI.BAR_TEXTURE)
    end
end

hooksecurefunc("CompactUnitFrame_UpdateHealth", skinBars)
hooksecurefunc("CompactUnitFrame_UpdatePower", skinBars)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function()
    SetCVar("useCompactPartyFrames", 1)
    SetCVar("raidFramesDisplayClassColor", 1)
    SetCVar("raidFramesDisplayBorder", 0)
end)
