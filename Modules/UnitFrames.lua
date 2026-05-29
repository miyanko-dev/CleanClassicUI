local DB_KEY = "framePositions"

local function getStore()
    CleanClassicUIDB = CleanClassicUIDB or {}
    CleanClassicUIDB[DB_KEY] = CleanClassicUIDB[DB_KEY] or {}
    return CleanClassicUIDB[DB_KEY]
end

local function applyPosition(frame, pos)
    if not (frame and pos) then return end
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
end

local function placeFrames()
    if InCombatLockdown() then
        print("|cffffff00[CleanClassicUI]:|r Unit frames can't be moved during combat.")
        return
    end
    if not (PlayerFrame and TargetFrame and CastingBarFrame and ActionButton1 and ActionButton12) then
        print("|cffffff00[CleanClassicUI]:|r Required frames not ready, try again after login.")
        return
    end

    -- Use the virtual cast-bottom (assumes a stance/pet bar row above AB2) so the
    -- frames sit at the same peripheral-vision height for every class.
    local layout = CleanClassicUILayout
    local castBottom = (layout and layout.castBottomWithStanceOrPet and layout.castBottomWithStanceOrPet())
        or CastingBarFrame:GetBottom()
    local btn1Left = ActionButton1:GetLeft()
    local btn12Right = ActionButton12:GetRight()
    local pPortraitBottom = PlayerPortrait and PlayerPortrait:GetBottom()
    local tPortraitBottom = TargetFramePortrait and TargetFramePortrait:GetBottom()
    local pFrameBottom = PlayerFrame:GetBottom()
    local tFrameBottom = TargetFrame:GetBottom()
    if not (castBottom and btn1Left and btn12Right
        and pPortraitBottom and tPortraitBottom and pFrameBottom and tFrameBottom) then
        print("|cffffff00[CleanClassicUI]:|r Anchor frames not measurable yet.")
        return
    end

    -- Compensate for each frame's invisible padding so portrait bottoms align with castBottom.
    local pOffset = pPortraitBottom - pFrameBottom
    local tOffset = tPortraitBottom - tFrameBottom

    local store = getStore()
    store.PlayerFrame = {
        point = "BOTTOMRIGHT", relativePoint = "BOTTOMLEFT",
        x = btn1Left, y = castBottom - pOffset,
    }
    store.TargetFrame = {
        point = "BOTTOMLEFT", relativePoint = "BOTTOMLEFT",
        x = btn12Right, y = castBottom - tOffset,
    }

    applyPosition(PlayerFrame, store.PlayerFrame)
    applyPosition(TargetFrame, store.TargetFrame)
end

local positionEntry = CreateFromMixins(UnitPopupButtonBaseMixin)

function positionEntry:GetText()
    return "Auto Position"
end

function positionEntry:OnClick()
    placeFrames()
end

function positionEntry:IsEnabled()
    return not InCombatLockdown()
end

function positionEntry:CanShow(ctx)
    return ctx and (ctx.fromPlayerFrame or ctx.fromTargetFrame)
end

local function injectPositionEntry(menuObject)
    local originalGetEntries = menuObject.GetEntries
    function menuObject:GetEntries()
        local entries = originalGetEntries(self)
        if type(entries) ~= "table" then
            return entries
        end
        local afterMoveIndex
        for index, entry in ipairs(entries) do
            if entry == UnitPopupMovePlayerFrameButtonMixin
                or entry == UnitPopupMoveTargetFrameButtonMixin then
                afterMoveIndex = index + 1
            end
        end
        if not afterMoveIndex then
            return entries
        end
        table.insert(entries, afterMoveIndex, positionEntry)
        return entries
    end
end

for _, menuObject in pairs(UnitPopupMenus) do
    if type(menuObject) == "table" and type(menuObject.GetEntries) == "function" then
        injectPositionEntry(menuObject)
    end
end

local restoreFrame = CreateFrame("Frame")
restoreFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
restoreFrame:SetScript("OnEvent", function()
    if InCombatLockdown() then return end
    local store = getStore()
    applyPosition(PlayerFrame, store.PlayerFrame)
    applyPosition(TargetFrame, store.TargetFrame)
end)
