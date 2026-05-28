local function placeFrames()
    if InCombatLockdown() then
        print("|cffffff00[CleanClassicUI]:|r Unit frames can't be moved during combat.")
        return
    end
    if not (PlayerFrame and TargetFrame and CastingBarFrame and ActionButton1 and ActionButton12) then
        print("|cffffff00[CleanClassicUI]:|r Required frames not ready, try again after login.")
        return
    end

    local castBottom = CastingBarFrame:GetBottom()
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

    PlayerFrame:SetMovable(true)
    PlayerFrame:SetUserPlaced(true)
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", btn1Left, castBottom - pOffset)

    TargetFrame:SetMovable(true)
    TargetFrame:SetUserPlaced(true)
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", btn12Right, castBottom - tOffset)
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
        local insertIndex = #entries + 1
        for index, entry in ipairs(entries) do
            if entry == UnitPopupCancelButtonMixin then
                insertIndex = index
                break
            end
        end
        table.insert(entries, insertIndex, positionEntry)
        return entries
    end
end

for _, menuObject in pairs(UnitPopupMenus) do
    if type(menuObject) == "table" and type(menuObject.GetEntries) == "function" then
        injectPositionEntry(menuObject)
    end
end
