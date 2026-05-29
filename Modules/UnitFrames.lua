local DB_KEY = "framePositions"

local function getStore()
    CleanClassicUIDB = CleanClassicUIDB or {}
    CleanClassicUIDB[DB_KEY] = CleanClassicUIDB[DB_KEY] or {}
    return CleanClassicUIDB[DB_KEY]
end

-- Reposition from inside the restricted environment: an insecure SetPoint on
-- TargetFrame taints it, which blocks Blizzard's TargetofTarget_Update ->
-- TargetFrameToT:Show() in combat and breaks the target-of-target frame.
local secureMover = CreateFrame("Frame", "CleanClassicUISecureMover", UIParent, "SecureHandlerBaseTemplate")
secureMover:SetFrameRef("anchor", UIParent)

local function applyPosition(frame, pos)
    if not (frame and pos and pos.point and pos.relativePoint and pos.x and pos.y) then return end
    if InCombatLockdown() then return end

    secureMover:SetFrameRef("target", frame)
    secureMover:Execute(([[
        local target = self:GetFrameRef("target")
        local anchor = self:GetFrameRef("anchor")
        target:ClearAllPoints()
        target:SetPoint("%s", anchor, "%s", %d, %d)
    ]]):format(pos.point, pos.relativePoint, math.floor(pos.x + 0.5), math.floor(pos.y + 0.5)))
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
