-- Edit Mode owns unit frame positions; recolor the frame art grey and swap the bar fills.
local FRAME_COLOR = CleanClassicExperience.COLOR.GREY
local BAR_ATLAS = CleanClassicExperience.BAR_ATLAS

-- SetStatusBarTexture accepts an atlas string, so the bars share the nameplate health bar's fill atlas.

-- Desaturate before the grey vertex color or the gold art only darkens to brown.
local function tint(texture)
    if not texture then return end
    texture:SetDesaturated(true)
    texture:SetVertexColor(unpack(FRAME_COLOR))
end

-- UnitFrameManaBar_UpdateType rebuilds the texture and, on the modern art path, the color; force both back.
local function applyPowerBar(manaBar)
    if not manaBar then return end
    manaBar:SetStatusBarTexture(BAR_ATLAS)
    local unit = manaBar.unit
    if not unit then return end
    local _, powerToken = UnitPowerType(unit)
    local color = powerToken and PowerBarColor[powerToken]
    if color then manaBar:SetStatusBarColor(color.r, color.g, color.b) end
end

-- The dragon border art bakes into the same texture as the frame ring, so elite and rare targets stay native.
local NATIVE_BORDER = {
    elite = true,
    worldboss = true,
    rareelite = true,
    rare = true,
}

local function tintTargetBorder()
    local border = TargetFrameTextureFrameTexture
    if not border then return end

    if NATIVE_BORDER[UnitClassification("target")] then
        border:SetDesaturated(false)
        border:SetVertexColor(1, 1, 1)
    else
        tint(border)
    end
end

-- Health bars keep Blizzard's color; the fill texture is not reset at runtime.
local function styleFrames()
    tint(PlayerFrameTexture)
    tintTargetBorder()
    tint(TargetFrameToTTextureFrameTexture)
    tint(PetFrameTexture)

    if PlayerFrameHealthBar then PlayerFrameHealthBar:SetStatusBarTexture(BAR_ATLAS) end
    if TargetFrameHealthBar then TargetFrameHealthBar:SetStatusBarTexture(BAR_ATLAS) end
    if PetFrameHealthBar then PetFrameHealthBar:SetStatusBarTexture(BAR_ATLAS) end
    if TargetFrameToTHealthBar then TargetFrameToTHealthBar:SetStatusBarTexture(BAR_ATLAS) end
    applyPowerBar(PlayerFrameManaBar)
    applyPowerBar(TargetFrameManaBar)
    applyPowerBar(PetFrameManaBar)
    applyPowerBar(TargetFrameToTManaBar)

    -- Native code recolors the name backing via SetVertexColor, so the atlas swap holds without touching the tint.
    if TargetFrameNameBackground then
        TargetFrameNameBackground:SetAtlas(BAR_ATLAS)
    end

    if TargetFrameBackground then
        TargetFrameBackground:Hide()
    end
end

styleFrames()

-- PlayerFrame_ToPlayerArt restores the default art when leaving a vehicle.
if type(PlayerFrame_ToPlayerArt) == "function" then
    hooksecurefunc("PlayerFrame_ToPlayerArt", function() tint(PlayerFrameTexture) end)
end

if type(UnitFrameManaBar_UpdateType) == "function" then
    hooksecurefunc("UnitFrameManaBar_UpdateType", function(manaBar)
        if manaBar == PlayerFrameManaBar or manaBar == TargetFrameManaBar
            or manaBar == PetFrameManaBar then
            applyPowerBar(manaBar)
        end
    end)
end

CleanClassicExperience.OnEvent(styleFrames,
    "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "UNIT_CLASSIFICATION_CHANGED")
