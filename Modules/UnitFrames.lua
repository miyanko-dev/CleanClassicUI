local function placeFrames()
    if InCombatLockdown() then
        print("|cffffff00[NewNativeUI]:|r Unit frames can't be moved during combat.")
        return
    end
    if not (PlayerFrame and TargetFrame and CastingBarFrame and ActionButton1 and ActionButton12) then
        print("|cffffff00[NewNativeUI]:|r Required frames not ready, try again after login.")
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
        print("|cffffff00[NewNativeUI]:|r Anchor frames not measurable yet.")
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

SLASH_CLEANUNITFRAMES1 = "/cleanunitframes"
SlashCmdList["CLEANUNITFRAMES"] = placeFrames
