-- Player/target frame styling shared across every client. Pure styling (no move
-- or reparent), so it is safe on the Edit Mode clients where these frames are
-- position-managed:
--   * recolor the ornate frame art (player, target, target-of-target, pet) to grey,
--   * swap the health/power fill to the cast bar (raid) texture,
--   * give the target name the player frame's plain black backing.
local FRAME_COLOR = CleanClassicExperience.COLOR.GREY
local BAR_TEXTURE = CleanClassicExperience.BAR_TEXTURE

-- The frame art is gold, so desaturate before the grey vertex color or it only
-- darkens to brown.
local function tint(texture)
    if not texture then return end
    texture:SetDesaturated(true)
    texture:SetVertexColor(unpack(FRAME_COLOR))
end

-- Power bars: Blizzard rebuilds the texture (and, on the modern art path, the
-- color) in UnitFrameManaBar_UpdateType, so force both back to the classic look.
local function applyPowerBar(manaBar)
    if not manaBar then return end
    manaBar:SetStatusBarTexture(BAR_TEXTURE)
    local unit = manaBar.unit
    if not unit then return end
    local _, powerToken = UnitPowerType(unit)
    local color = powerToken and PowerBarColor[powerToken]
    if color then manaBar:SetStatusBarColor(color.r, color.g, color.b) end
end

-- Health bars keep Blizzard's green/reaction color; only the fill texture changes
-- and it is not reset at runtime.
local function styleFrames()
    tint(PlayerFrameTexture)
    tint(TargetFrameTextureFrameTexture)
    tint(TargetFrameToTTextureFrameTexture)
    tint(PetFrameTexture)

    if PlayerFrameHealthBar then PlayerFrameHealthBar:SetStatusBarTexture(BAR_TEXTURE) end
    if TargetFrameHealthBar then TargetFrameHealthBar:SetStatusBarTexture(BAR_TEXTURE) end
    if PetFrameHealthBar then PetFrameHealthBar:SetStatusBarTexture(BAR_TEXTURE) end
    if TargetFrameToTHealthBar then TargetFrameToTHealthBar:SetStatusBarTexture(BAR_TEXTURE) end
    applyPowerBar(PlayerFrameManaBar)
    applyPowerBar(TargetFrameManaBar)
    applyPowerBar(PetFrameManaBar)
    applyPowerBar(TargetFrameToTManaBar)

    -- Match PlayerFrameBackground (flat black, 0.5 alpha). A color texture ignores
    -- the faction vertex tint (black x reaction = black), so it holds untouched.
    if TargetFrameNameBackground then
        TargetFrameNameBackground:SetColorTexture(0, 0, 0, 0.5)
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
    "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED")
