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

-- Reload immediately so the one-time taint never reaches combat.
StaticPopupDialogs["CLEANCLASSICUI_POSITION_RELOAD"] = {
    text = "Unit frames positioned. Reload now to finalize -- WoW will then remember the position on its own.\n\nUntil you reload, interacting with a unit may log a harmless \"action blocked\" error. Reloading clears it.",
    button1 = RELOADUI,
    button2 = CANCEL,
    OnAccept = ReloadUI,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function placeFrames()
    if InCombatLockdown() then
        print("|cffffff00[CleanClassicUI]:|r Unit frames can't be moved during combat.")
        return
    end
    if not (PlayerFrame and TargetFrame and CastingBarFrame and ActionButton1 and ActionButton12) then
        print("|cffffff00[CleanClassicUI]:|r Required frames not ready, try again after login.")
        return
    end

    -- Virtual cast-bottom (assumes a stance/pet row above AB2) keeps the frames at the same
    -- peripheral-vision height for every class.
    local layout = CleanClassicUILayout
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
        print("|cffffff00[CleanClassicUI]:|r Anchor frames not measurable yet.")
        return
    end

    -- Offset by each frame's invisible padding so the portrait bottoms align with castBottom.
    local playerOffset = playerPortraitBottom - playerFrameBottom
    local targetOffset = targetPortraitBottom - targetFrameBottom

    place(PlayerFrame, "BOTTOMRIGHT", firstButtonLeft, castBottom - playerOffset)
    place(TargetFrame, "BOTTOMLEFT", lastButtonRight, castBottom - targetOffset)

    StaticPopup_Show("CLEANCLASSICUI_POSITION_RELOAD")
end

-- Add Auto Position above Blizzard's native "Move Frame" entry via Menu.ModifyMenu, which
-- runs taint-free. A nil index appends, covering menus with no Move Frame entry.
local function addAutoPosition(owner, rootDescription, contextData)
    if not (contextData and (contextData.fromPlayerFrame or contextData.fromTargetFrame)) then
        return
    end

    local autoPosition = MenuUtil.CreateButton("Auto Position", placeFrames)
    autoPosition:SetEnabled(not InCombatLockdown())

    local moveIndex
    for index, entry in rootDescription:EnumerateElementDescriptions() do
        if MenuUtil.GetElementText(entry) == MOVE_FRAME then
            moveIndex = index
            break
        end
    end

    rootDescription:Insert(autoPosition, moveIndex)
end

for which in pairs(UnitPopupMenus) do
    Menu.ModifyMenu("MENU_UNIT_"..which, addAutoPosition)
end
