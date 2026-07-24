local SHADOW_INSET_PIXELS = 4

local cropCoords

-- Inset atlas coords to exclude the baked-in shadow
local function resolveCropCoords()
    if cropCoords then return cropCoords end

    local barAtlas = C_Texture.GetAtlasInfo(CleanClassicExperience.BAR_ATLAS)
    if not barAtlas then return end

    local insetU = SHADOW_INSET_PIXELS * (barAtlas.rightTexCoord - barAtlas.leftTexCoord) / barAtlas.width
    local insetV = SHADOW_INSET_PIXELS * (barAtlas.bottomTexCoord - barAtlas.topTexCoord) / barAtlas.height

    cropCoords = {
        barAtlas.leftTexCoord + insetU,
        barAtlas.rightTexCoord - insetU,
        barAtlas.topTexCoord + insetV,
        barAtlas.bottomTexCoord - insetV,
    }

    return cropCoords
end

local function applyShadowCrop(healthBar)
    local coords = resolveCropCoords()
    if not coords then return end

    local fillTexture = healthBar:GetStatusBarTexture()
    if fillTexture then fillTexture:SetTexCoord(unpack(coords)) end
end

local function skinBars(frame)
    if not frame then return end

    if frame.healthBar then
        frame.healthBar:SetStatusBarTexture(CleanClassicExperience.BAR_ATLAS)
        applyShadowCrop(frame.healthBar)

        -- Reapply crop after value changes rewrite fill coords
        if not frame.healthBar.cceShadowCropHooked then
            frame.healthBar.cceShadowCropHooked = true
            hooksecurefunc(frame.healthBar, "SetValue", applyShadowCrop)
        end
    end

    if frame.powerBar then frame.powerBar:SetStatusBarTexture(CleanClassicExperience.BAR_TEXTURE) end
end

hooksecurefunc("DefaultCompactUnitFrameSetup", skinBars)
hooksecurefunc("DefaultCompactMiniFrameSetup", skinBars)
