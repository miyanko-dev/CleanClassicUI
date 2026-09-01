-- Edit Mode owns unit frame positions; recolor the frame art grey and swap the bar fills.
local FRAME_COLOR = CleanClassicUI.COLOR.GREY
local BAR_ATLAS = CleanClassicUI.BAR_ATLAS

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

-- Every power bar we own. UnitFrameManaBar_UpdateType resets each to the default texture on
-- every UNIT_DISPLAYPOWER, so styleFrames and the hook below must cover the same set or a bar
-- silently reverts; the ToT bar used to slip through the hook and kept falling back.
local MANA_BARS = {
    PlayerFrameManaBar,
    TargetFrameManaBar,
    PetFrameManaBar,
    TargetFrameToTManaBar,
}

-- The 1.15.9/2.5.6 prediction segments ship with the legacy UI-StatusBar fill, which clashes with BAR_ATLAS.
-- UnitFrame_Initialize stores them under these keys; each is a StatusBarOverlaySegment with a Fill texture.
local SEGMENT_KEYS = {
    "myHealPredictionBar",
    "otherHealPredictionBar",
    "healAbsorbBar",
    "totalAbsorbBar",
    "myManaCostPredictionBar",
}

-- SetAtlas keeps the segment's fillColor vertex tint, so only the texture needs replacing.
local function applySegmentFills(frame)
    for _, key in ipairs(SEGMENT_KEYS) do
        local segment = frame and frame[key]
        if segment and segment.Fill then
            segment.Fill:SetAtlas(BAR_ATLAS, TextureKitConstants.IgnoreAtlasSize)
        end
    end
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
    for _, bar in ipairs(MANA_BARS) do applyPowerBar(bar) end

    -- ToT carries no prediction segments, so only these three frames need the fill swap.
    applySegmentFills(PlayerFrame)
    applySegmentFills(TargetFrame)
    applySegmentFills(PetFrame)

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

-- Hide the red highlight and yellow glow only; the rest and combat icons stay on OVERLAY, above the frame art.
-- PlayerFrame_UpdateStatus re-shows these on every state change, so keep re-hiding them.
local function hideStatus(region)
    if not region then return end
    hooksecurefunc(region, "Show", region.Hide)
    region:Hide()
end

hideStatus(PlayerStatusTexture)
hideStatus(PlayerStatusGlow)

-- Re-apply after Blizzard resets the texture; this is the only runtime path that re-textures a power bar.
if type(UnitFrameManaBar_UpdateType) == "function" then
    hooksecurefunc("UnitFrameManaBar_UpdateType", function(manaBar)
        for _, bar in ipairs(MANA_BARS) do
            if manaBar == bar then
                applyPowerBar(manaBar)
                return
            end
        end
    end)
end

CleanClassicUI.OnEvent(styleFrames,
    "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "UNIT_CLASSIFICATION_CHANGED")
