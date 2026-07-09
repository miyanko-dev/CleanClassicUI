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
