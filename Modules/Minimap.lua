-- Edit Mode owns the cluster; hide chrome, restyle clock and zone text, unify every button, add wheel zoom and drag.
local HIDDEN = {
    "MinimapBorder",
    "MinimapToggleButton",
    "MinimapZoomIn",
    "MinimapZoomOut",
    "GameTimeFrame",
}

-- OnUpdateRotationSetting re-shows one of these on every rotateMinimap flip, but never touches their alpha.
local ROTATION_ART = {
    "MinimapNorthTag",
    "MinimapCompassTexture",
}

local BUTTON_SIZE = 33

-- The zone text acts as the map's header: constant-size, gap below to the map.
local ZONE_TEXT_HEIGHT = 18
local ZONE_TEXT_GAP    = 2

local CLOCK_GAP = 12

-- Desaturate before the grey vertex color or the gold ring art only darkens.
local RING_COLOR = CleanClassicUI.COLOR.GREY

-- Copy LibDBIcon's classic recipe so native and addon buttons share one look.
local ICON_SIZE = 17
local BG_SIZE   = 20
local RING_SIZE = 53
local ICON_CROP = 0.05

-- LibDBIcon's stock rim gap; native buttons reuse it so every button sits on one circle.
local EDGE_GAP = 5

-- The ring art's opening sits (-11, 12) from its center at RING_SIZE, so anchor at the inverse offset.
local RING_TO_ICON_X, RING_TO_ICON_Y = 11, -12

local EDGE_BUTTONS = {
    { frame = "MiniMapTracking",         icon = "MiniMapTrackingIcon",    ring = "MiniMapTrackingBorder" },
    { frame = "MiniMapMailFrame",        icon = "MiniMapMailIcon",        ring = "MiniMapMailBorder" },
    { frame = "MiniMapBattlefieldFrame", icon = "MiniMapBattlefieldIcon", ring = "MiniMapBattlefieldBorder" },
}

CleanClassicUIDB = CleanClassicUIDB or {}
CleanClassicUIDB.iconAngles = CleanClassicUIDB.iconAngles or {}

-- Cancel the Edit Mode container scale once so nothing parented to this ring grows with the map.
local edgeFrame = CreateFrame("Frame", "CleanClassicUIMinimapEdge", Minimap)
edgeFrame:SetPoint("CENTER", Minimap, "CENTER")

-- Extra scale Edit Mode puts on the map, measured against the unscaled cluster around it.
local function mapScale()
    local cluster, map = MinimapCluster:GetEffectiveScale(), Minimap:GetEffectiveScale()
    if cluster <= 0 or map <= 0 then return 1 end
    return map / cluster
end

-- Match the map's on-screen circle so children need no scale math of their own.
local function resizeEdge()
    local scale    = mapScale()
    local diameter = Minimap:GetWidth() * scale
    edgeFrame:SetScale(1 / scale)
    edgeFrame:SetSize(diameter, diameter)
end

-- Offsets are read in the moved frame's own units, so only edgeFrame children may be placed here.
local function placeOnEdge(frame, angle)
    local rad    = math.rad(angle)
    local radius = edgeFrame:GetWidth() / 2 + EDGE_GAP
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", edgeFrame, "CENTER", math.cos(rad) * radius, math.sin(rad) * radius)
end

local function recolorRing(ring)
    if not ring then return end
    ring:SetDesaturated(true)
    ring:SetVertexColor(unpack(RING_COLOR))
end

-- Crop baked icon edges like LibDBIcon so square art stays inside the ring.
local function styleButtonIcon(icon, frame)
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", frame, "CENTER")
    icon:SetTexCoord(ICON_CROP, 1 - ICON_CROP, ICON_CROP, 1 - ICON_CROP)
end

local function styleRing(ring, icon)
    if not ring then return end
    ring:SetSize(RING_SIZE, RING_SIZE)
    ring:ClearAllPoints()
    ring:SetPoint("CENTER", icon, "CENTER", RING_TO_ICON_X, RING_TO_ICON_Y)
    recolorRing(ring)
end

-- Native buttons lack LibDBIcon's backdrop disc; add one so tints match.
local function ensureBackground(frame, icon)
    if not frame.ccuiBackground then
        frame.ccuiBackground = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
        frame.ccuiBackground:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    end
    frame.ccuiBackground:SetSize(BG_SIZE, BG_SIZE)
    frame.ccuiBackground:ClearAllPoints()
    frame.ccuiBackground:SetPoint("CENTER", icon, "CENTER")
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

-- Addon buttons keep LibDBIcon's own sizing; the ring parent and color are all this addon sets.
local function refreshAddonIcons()
    local lib = LibStub and LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.objects and lib.SetButtonRadius) then return end

    for _, button in pairs(lib.objects) do
        button:SetParent(edgeFrame)
        recolorRing(button.border)
    end

    -- The lib anchors to Minimap in unscaled units, so grow its radius by what the map's scale adds.
    lib:SetButtonRadius((Minimap:GetWidth() / 2) * (mapScale() - 1) + EDGE_GAP)
end

-- Buttons that addons register after login must pick up the styling too.
local iconCreationHooked = false
local function hookIconCreation()
    if iconCreationHooked or not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.RegisterCallback) then return end

    lib.RegisterCallback(CleanClassicUI, "LibDBIcon_IconCreated", refreshAddonIcons)
    iconCreationHooked = true
end

local function dragUpdate(frame, key)
    local cx, cy = edgeFrame:GetCenter()
    if not cx then return end
    local mx, my = GetCursorPosition()
    local scale  = edgeFrame:GetEffectiveScale()
    local angle  = math.deg(math.atan2(my / scale - cy, mx / scale - cx))
    CleanClassicUIDB.iconAngles[key] = angle
    placeOnEdge(frame, angle)
end

local function enableEdgeDrag(frame, key)
    if frame.ccuiDraggable then return end
    frame.ccuiDraggable = true

    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function() dragUpdate(frame, key) end)
    end)
    frame:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
end

local function setupEdgeIcon(frame, key, defaultAngle)
    if not frame then return end
    enableEdgeDrag(frame, key)
    placeOnEdge(frame, CleanClassicUIDB.iconAngles[key] or defaultAngle)
end

local function adjustEdgeIcons()
    setupEdgeIcon(MiniMapTracking,         "tracking",    135)
    setupEdgeIcon(MiniMapMailFrame,        "mail",         45)
    setupEdgeIcon(MiniMapBattlefieldFrame, "battlefield", 225)
end

local function styleEdgeButton(entry)
    local frame, icon = _G[entry.frame], _G[entry.icon]
    if not (frame and icon) then return end

    -- Parenting onto the ring is what keeps the map's Edit Mode scale off the button.
    frame:SetParent(edgeFrame)
    frame:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    styleButtonIcon(icon, frame)
    ensureBackground(frame, icon)

    styleRing(_G[entry.ring], icon)
end

-- Blizzard rewrites the battlefield icon on every queue update; restore the shared geometry after it.
local function restyleBattlefieldIcon()
    if MiniMapBattlefieldFrame and MiniMapBattlefieldIcon then
        styleButtonIcon(MiniMapBattlefieldIcon, MiniMapBattlefieldFrame)
    end
end

hooksecurefunc("BattlefieldFrame_UpdateStatus", restyleBattlefieldIcon)
hooksecurefunc("MiniMapBattlefieldFrame_UpdateArena", restyleBattlefieldIcon)

local function styleEdgeButtons()
    for _, entry in ipairs(EDGE_BUTTONS) do
        styleEdgeButton(entry)
    end
end

-- Park the clock under the map's visible bottom edge at a constant gap.
local function placeClock()
    if not TimeManagerClockButton then return end
    TimeManagerClockButton:SetParent(edgeFrame)
    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint("TOP", edgeFrame, "BOTTOM", 0, -CLOCK_GAP)
end

-- Re-fit the ring first, then re-place everything that reads its radius.
local function refreshEdge()
    resizeEdge()
    adjustEdgeIcons()
    refreshAddonIcons()
    placeClock()
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

    for _, name in ipairs(ROTATION_ART) do
        local texture = _G[name]
        if texture then texture:SetAlpha(0) end
    end

    -- The top banner is a parentKey texture, not a named global.
    if MinimapCluster and MinimapCluster.BorderTop then
        MinimapCluster.BorderTop:Hide()
    end

    if MinimapCluster then
        -- The stock hit insets padded the removed border art and now miss the visible content.
        MinimapCluster:SetHitRectInsets(0, 0, 0, 0)

        -- Clearing this stops SetEditModeScale resizing the header, so it stays a constant white strip.
        MinimapCluster.scaleMinimapHeader = false
    end

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
        TimeManagerClockButton:SetSize(60, 20)
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

    styleEdgeButtons()
    refreshEdge()
    hookIconCreation()
    anchorMinimapContainer()
end

applyMinimap()

-- Every size change routes through the container's scale, including live slider drags that fire no event.
if MinimapCluster and MinimapCluster.MinimapContainer then
    hooksecurefunc(MinimapCluster.MinimapContainer, "SetScale", refreshEdge)
end

-- Each scale change ends in SetHeaderUnderneath, which resets the container to its stock anchor, so re-fix after.
hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", anchorMinimapContainer)

-- Blizzard recolors the zone text by PvP zone type on every zone change, so keep it white.
hooksecurefunc("Minimap_Update", function()
    if MinimapZoneText then MinimapZoneText:SetTextColor(1, 1, 1) end
end)

CleanClassicUI.OnEvent(function()
    C_Timer.After(0, applyMinimap)
end, "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
"EDIT_MODE_LAYOUTS_UPDATED")
