-- Edit Mode owns the cluster; hide chrome, restyle clock and zone text, unify every button, add wheel zoom and drag.
local HIDDEN = {
    "MinimapBorder",
    "MinimapToggleButton",
    "MinimapNorthTag",
    "MinimapCompassTexture",
    "MinimapZoomIn",
    "MinimapZoomOut",
    "GameTimeFrame",
}

local BUTTON_SIZE = 33

-- The zone text acts as the map's header: constant-size, gap below to the map.
local ZONE_TEXT_HEIGHT = 18
local ZONE_TEXT_GAP    = 2

-- Desaturate before the grey vertex color or the gold ring art only darkens.
local RING_COLOR = CleanClassicExperience.COLOR.GREY

-- Copy LibDBIcon's classic recipe so native and addon buttons share one look.
local ICON_SIZE = 17
local BG_SIZE   = 20
local RING_SIZE = 53
local ICON_CROP = 0.05

-- The ring art's opening sits (-11, 12) from its center at RING_SIZE, so anchor at the inverse offset.
local RING_TO_ICON_X, RING_TO_ICON_Y = 11, -12

-- rings lists per-flavor texture names (era/tbc); whichever exists is used.
local EDGE_BUTTONS = {
    { frame = "MiniMapTracking",         icon = "MiniMapTrackingIcon",    rings = { "MiniMapTrackingBorder", "MiniMapTrackingButtonBorder" } },
    { frame = "MiniMapMailFrame",        icon = "MiniMapMailIcon",        rings = { "MiniMapMailBorder" } },
    { frame = "MiniMapBattlefieldFrame", icon = "MiniMapBattlefieldIcon", rings = { "MiniMapBattlefieldBorder" } },
}

local function recolorRing(ring)
    if not ring then return end
    ring:SetDesaturated(true)
    ring:SetVertexColor(unpack(RING_COLOR))
end

local function placeButtonIcon(icon, frame)
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", frame, "CENTER")
end

-- Crop baked icon edges like LibDBIcon so square art stays inside the ring.
local function styleButtonIcon(icon, frame)
    placeButtonIcon(icon, frame)
    icon:SetTexCoord(ICON_CROP, 1 - ICON_CROP, ICON_CROP, 1 - ICON_CROP)
end

local function styleRing(ring, icon)
    if not ring then return end
    ring:SetSize(RING_SIZE, RING_SIZE)
    ring:ClearAllPoints()
    ring:SetPoint("CENTER", icon, "CENTER", RING_TO_ICON_X, RING_TO_ICON_Y)
    recolorRing(ring)
end

local function styleBackdrop(backdrop, icon)
    backdrop:SetSize(BG_SIZE, BG_SIZE)
    backdrop:ClearAllPoints()
    backdrop:SetPoint("CENTER", icon, "CENTER")
end

-- Native buttons lack LibDBIcon's backdrop disc; add one so tints match.
local function ensureBackground(frame, icon)
    if not frame.cceBackground then
        frame.cceBackground = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
        frame.cceBackground:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    end
    styleBackdrop(frame.cceBackground, icon)
end

-- A frame inside the Edit Mode-scaled container set to this scale keeps a constant on-screen size.
local function counterScale()
    return MinimapCluster:GetEffectiveScale() / Minimap:GetEffectiveScale()
end

-- Pinning the clock's effective scale to the cluster's also keeps its 12px gap constant.
local function pinClock()
    if TimeManagerClockButton then
        TimeManagerClockButton:SetScale(counterScale())
    end
end

-- Re-anchor the scaled container to the cluster's top so the Edit Mode selection overlay hugs the content.
local function anchorMinimapContainer()
    local container = MinimapCluster and MinimapCluster.MinimapContainer
    if not container then return end
    local inset = (ZONE_TEXT_HEIGHT + ZONE_TEXT_GAP) / container:GetScale()
    container:ClearAllPoints()
    container:SetPoint("TOP", MinimapCluster, "TOP", 0, -inset)
    if MinimapCluster.MarkDirty then
        MinimapCluster:MarkDirty()
    end
end

-- Counter-scale addon buttons and widen the lib's ring radius so they stay BUTTON_SIZE on the map edge.
local function refreshAddonIcons()
    if not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.objects and lib.Refresh) then return end

    local counter = counterScale()
    if lib.SetButtonRadius then
        lib:SetButtonRadius((Minimap:GetWidth() / 2) * (1 / counter - 1))
    end
    for name, btn in pairs(lib.objects) do
        btn:SetScale(counter)
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)

        -- The lib owns icon texcoords (crop and pressed state); geometry only.
        if btn.icon then
            placeButtonIcon(btn.icon, btn)

            if btn.background then
                styleBackdrop(btn.background, btn.icon)
            end

            styleRing(btn.border, btn.icon)
        end

        lib:Refresh(name)
    end
end

-- Buttons that addons register after login must pick up the styling too.
local iconCreationHooked = false
local function hookIconCreation()
    if iconCreationHooked or not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.RegisterCallback) then return end

    lib.RegisterCallback(CleanClassicExperience, "LibDBIcon_IconCreated", refreshAddonIcons)
    iconCreationHooked = true
end

local function placeOnEdge(icon, angle)
    local rad = math.rad(angle)

    -- Divide the rim radius by the button's counter-scale so local offsets land on the map edge.
    local radius = (Minimap:GetWidth() / 2) / icon:GetScale()
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", Minimap, "CENTER", math.cos(rad) * radius, math.sin(rad) * radius)
end

local function dragUpdate(icon, key)
    local cx, cy = Minimap:GetCenter()
    if not cx then return end
    local mx, my = GetCursorPosition()
    local scale  = Minimap:GetEffectiveScale()
    local angle  = math.deg(math.atan2(my / scale - cy, mx / scale - cx))
    CleanClassicExperienceDB.iconAngles[key] = angle
    placeOnEdge(icon, angle)
end

-- dragHandle receives the mouse when it differs from the moved frame (TBC's dropdown child covers its parent).
local function setupEdgeIcon(icon, key, defaultAngle, dragHandle)
    if not icon then return end
    local handle = dragHandle or icon
    icon:SetMovable(true)
    handle:RegisterForDrag("LeftButton")
    handle:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function() dragUpdate(icon, key) end)
    end)
    handle:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    local angle = CleanClassicExperienceDB.iconAngles[key] or defaultAngle
    placeOnEdge(icon, angle)
end

local function adjustEdgeIcons()
    setupEdgeIcon(MiniMapTracking,         "tracking",    135, MiniMapTrackingButton)
    setupEdgeIcon(MiniMapMailFrame,        "mail",         45)
    setupEdgeIcon(MiniMapBattlefieldFrame, "battlefield", 225)
end

local function styleEdgeButton(entry)
    local frame, icon = _G[entry.frame], _G[entry.icon]
    if not (frame and icon) then return end

    -- Era ships tracking parented outside the map; make every edge button a Minimap child so rim math treats them alike.
    if frame:GetParent() ~= Minimap then
        frame:SetParent(Minimap)
    end

    frame:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    frame:SetScale(counterScale())
    styleButtonIcon(icon, frame)
    ensureBackground(frame, icon)

    for _, name in ipairs(entry.rings) do
        styleRing(_G[name], icon)
    end
end

-- Blizzard rewrites the battlefield icon on every queue update; restore the shared geometry after it.
local function restyleBattlefieldIcon()
    if MiniMapBattlefieldFrame and MiniMapBattlefieldIcon then
        styleButtonIcon(MiniMapBattlefieldIcon, MiniMapBattlefieldFrame)
    end
end

if type(BattlefieldFrame_UpdateStatus) == "function" then
    hooksecurefunc("BattlefieldFrame_UpdateStatus", restyleBattlefieldIcon)
end
if type(MiniMapBattlefieldFrame_UpdateArena) == "function" then
    hooksecurefunc("MiniMapBattlefieldFrame_UpdateArena", restyleBattlefieldIcon)
end

local function styleEdgeButtons()
    for _, entry in ipairs(EDGE_BUTTONS) do
        styleEdgeButton(entry)
    end

    -- Keep TBC's child dropdown click target matched to the resized frame.
    if MiniMapTrackingButton then
        MiniMapTrackingButton:ClearAllPoints()
        MiniMapTrackingButton:SetAllPoints(MiniMapTracking)
    end
end

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)

local function applyMinimap()
    for _, name in ipairs(HIDDEN) do
        local region = _G[name]
        if region then region:Hide() end
    end

    -- The top banner is a parentKey texture, not a named global.
    if MinimapCluster and MinimapCluster.BorderTop then
        MinimapCluster.BorderTop:Hide()
    end

    -- The stock hit insets padded the removed border art and now miss the visible content.
    if MinimapCluster then
        MinimapCluster:SetHitRectInsets(0, 0, 0, 0)
    end

    -- Blizzard scales the header with the map (scaleMinimapHeader); pin it back to a constant white header.
    if MinimapZoneTextButton and MinimapZoneText
        and MinimapCluster and MinimapCluster.MinimapContainer then
        MinimapZoneTextButton:Show()
        MinimapZoneTextButton:SetScale(1)
        MinimapZoneTextButton:SetSize(140, ZONE_TEXT_HEIGHT)
        MinimapZoneTextButton:ClearAllPoints()
        MinimapZoneTextButton:SetPoint("BOTTOM", MinimapCluster.MinimapContainer, "TOP", 0, ZONE_TEXT_GAP)

        MinimapZoneText:SetFont(MinimapZoneText:GetFont(), 14, "OUTLINE")
        MinimapZoneText:SetSize(0, ZONE_TEXT_HEIGHT)
        MinimapZoneText:ClearAllPoints()
        MinimapZoneText:SetPoint("CENTER", MinimapZoneTextButton, "CENTER", 0, 0)
        MinimapZoneText:SetTextColor(1, 1, 1)
    end

    if TimeManagerClockButton then
        TimeManagerClockButton:Show()
        TimeManagerClockButton:SetScale(counterScale())
        TimeManagerClockButton:SetSize(60, 20)
        TimeManagerClockButton:ClearAllPoints()
        TimeManagerClockButton:SetPoint("TOP", Minimap, "BOTTOM", 0, -12)
        TimeManagerClockButton:SetHitRectInsets(0, 0, 0, 0)

        for _, region in pairs({ TimeManagerClockButton:GetRegions() }) do
            if region:IsObjectType("Texture") then
                region:Hide()
            end
        end

        TimeManagerClockTicker:SetFont(TimeManagerClockTicker:GetFont(), 14, "OUTLINE")
        TimeManagerClockTicker:ClearAllPoints()
        TimeManagerClockTicker:SetPoint("CENTER", TimeManagerClockButton, "CENTER", 0, 0)
    end

    CleanClassicExperienceDB = CleanClassicExperienceDB or {}
    CleanClassicExperienceDB.iconAngles = CleanClassicExperienceDB.iconAngles or {}
    styleEdgeButtons()
    adjustEdgeIcons()
    refreshAddonIcons()
    hookIconCreation()
    anchorMinimapContainer()
end

applyMinimap()

-- The size slider routes through SetEditModeScale, including live drags that fire no event; re-pin everything.
if MinimapCluster and MinimapCluster.SetEditModeScale then
    hooksecurefunc(MinimapCluster, "SetEditModeScale", function()
        pinClock()
        refreshAddonIcons()
        styleEdgeButtons()
        adjustEdgeIcons()
        if MinimapZoneTextButton then MinimapZoneTextButton:SetScale(1) end
        anchorMinimapContainer()
    end)
end

-- Each scale change ends in SetHeaderUnderneath, which resets the container to its stock anchor; re-fix after.
if MinimapCluster and MinimapCluster.SetHeaderUnderneath then
    hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", anchorMinimapContainer)
end

-- Blizzard recolors the zone text by PvP zone type on every zone change; keep it white.
if type(Minimap_Update) == "function" then
    hooksecurefunc("Minimap_Update", function()
        if MinimapZoneText then MinimapZoneText:SetTextColor(1, 1, 1) end
    end)
end

CleanClassicExperience.OnEvent(function()
    C_Timer.After(0, applyMinimap)
end, "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
"EDIT_MODE_LAYOUTS_UPDATED")
