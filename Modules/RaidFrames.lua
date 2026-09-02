-- The fill atlas bakes a dark bevel into its top and bottom 6 of 20 rows and a few edge columns.
-- Stretched over a 34px raid health bar that bevel reads as a black drop shadow, so trim it away.
local TRIM_V = 0.3
local TRIM_H = 0.025

-- Crop to the flat middle of the atlas; the StatusBar fills within the texture's own texcoords
local function cropFill(bar)
    local info = C_Texture.GetAtlasInfo(CleanClassicUI.BAR_ATLAS)
    local fill = bar:GetStatusBarTexture()
    if not (info and fill) then return end
    local w = info.rightTexCoord - info.leftTexCoord
    local h = info.bottomTexCoord - info.topTexCoord
    fill:SetTexCoord(
        info.leftTexCoord + w * TRIM_H, info.rightTexCoord - w * TRIM_H,
        info.topTexCoord + h * TRIM_V, info.bottomTexCoord - h * TRIM_V)
end

-- Share the nameplate fill atlas used across the unit frames, minus its bevel
local function skinBar(bar)
    if not bar then return end
    bar:SetStatusBarTexture(CleanClassicUI.BAR_ATLAS)
    cropFill(bar)
end

-- Blizzard insets the health bar 1px over a dark background, which reads as a black outline.
-- Pin the background to the bar so it only backs missing health and the outline disappears.
local function fitBackground(frame)
    local bg = frame.background
    if not (bg and frame.healthBar) then return end
    bg:ClearAllPoints()
    bg:SetAllPoints(frame.healthBar)
end

local function skinBars(frame)
    if not frame then return end
    skinBar(frame.healthBar)
    skinBar(frame.powerBar)
    fitBackground(frame)
end

hooksecurefunc("DefaultCompactUnitFrameSetup", skinBars)
hooksecurefunc("DefaultCompactMiniFrameSetup", skinBars)

-- Catch pet and target minis, whose setup func the raid container captured before this addon loaded
hooksecurefunc("CompactUnitFrame_SetUpFrame", skinBars)
