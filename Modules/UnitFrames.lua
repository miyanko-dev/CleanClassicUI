-- Vanilla UI only: on the modern Edit Mode clients (TBC 2.5.6, likely era 1.15.9)
-- Edit Mode moves unit frames natively and the addon bar layout this aligns to is off.
if not CastingBarFrame then return end

-- Positioning PlayerFrame/TargetFrame from Lua taints them for the session, which blocks
-- Blizzard's TargetofTarget_Update -> TargetFrameToT:Show()/Hide() in combat. SetUserPlaced
-- hands the position to WoW's native layout cache, so a single /reload clears the one-time
-- taint and WoW restores the position itself -- no login-time code needed.
local function place(frame, point, x, y)
    frame:SetMovable(true)
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, "BOTTOMLEFT", math.floor(x + 0.5), math.floor(y + 0.5))
    frame:SetUserPlaced(true)
end

local function placeFrames()
    if InCombatLockdown() then
        print("|cffffff00[CleanClassicExperience]:|r Unit frames can't be moved during combat.")
        return
    end
    if not (PlayerFrame and TargetFrame and CastingBarFrame and ActionButton1 and ActionButton12) then
        print("|cffffff00[CleanClassicExperience]:|r Required frames not ready, try again after login.")
        return
    end

    -- Virtual cast-bottom (assumes a stance/pet row above AB2) keeps the frames at the same
    -- peripheral-vision height for every class.
    local layout = CleanClassicExperienceLayout
    local castBottom = (layout and layout.castBottomWithStanceOrPet and layout.castBottomWithStanceOrPet())
        or CastingBarFrame:GetBottom()
    local firstButtonLeft = ActionButton1:GetLeft()
    local lastButtonRight = ActionButton12:GetRight()
    local playerPortraitBottom = PlayerPortrait and PlayerPortrait:GetBottom()
    local targetPortraitBottom = TargetFramePortrait and TargetFramePortrait:GetBottom()
    local playerFrameBottom = PlayerFrame:GetBottom()
    local targetFrameBottom = TargetFrame:GetBottom()
    if not (castBottom and firstButtonLeft and lastButtonRight
        and playerPortraitBottom and targetPortraitBottom and playerFrameBottom and targetFrameBottom) then
        print("|cffffff00[CleanClassicExperience]:|r Anchor frames not measurable yet.")
        return
    end

    -- Offset by each frame's invisible padding so the portrait bottoms align with castBottom.
    local playerOffset = playerPortraitBottom - playerFrameBottom
    local targetOffset = targetPortraitBottom - targetFrameBottom

    place(PlayerFrame, "BOTTOMRIGHT", firstButtonLeft, castBottom - playerOffset)
    place(TargetFrame, "BOTTOMLEFT", lastButtonRight, castBottom - targetOffset)

    -- Reload unconditionally: any play time before the reload blocks protected
    -- TargetFrameToT:Show()/Hide() in combat (ADDON_ACTION_BLOCKED).
    ReloadUI()
end

-- Add Auto Position to the unit frame menu via Menu.ModifyMenu, which runs taint-free.
-- Append with no index: SecureArray:Insert only does a (tainting) element move when given an
-- index. Inserting above "Move Frame" would shift Blizzard's entries from our insecure code,
-- tainting the protected "Copy Character Name" -> CopyToClipboard entry and triggering
-- ADDON_ACTION_FORBIDDEN. Appending leaves existing entries untouched, so it stays clean.
local function addAutoPosition(owner, rootDescription, contextData)
    if not (contextData and (contextData.fromPlayerFrame or contextData.fromTargetFrame)) then
        return
    end

    local autoPosition = MenuUtil.CreateButton("Auto Position", placeFrames)
    autoPosition:SetEnabled(not InCombatLockdown())

    rootDescription:Insert(autoPosition)
end

for which in pairs(UnitPopupMenus) do
    Menu.ModifyMenu("MENU_UNIT_"..which, addAutoPosition)
end

-- Player/target frame styling shared across every client. Pure styling (no move
-- or reparent), so it is safe on the Edit Mode clients where these frames are
-- position-managed:
--   * recolor the ornate frame art (player, target, target-of-target, pet) to grey,
--     except elite/rare target borders which keep their native dragon art,
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

-- Elite/rare targets swap in the dragon border art; the dragon is baked into the
-- same texture as the frame ring, so keep those borders native instead of greying
-- the dragon out. Normal targets stay grey.
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

-- Health bars keep Blizzard's green/reaction color; only the fill texture changes
-- and it is not reset at runtime.
local function styleFrames()
    tint(PlayerFrameTexture)
    tintTargetBorder()
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
    "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "UNIT_CLASSIFICATION_CHANGED")
