local MARGIN = CleanClassicExperience.SPACING.LG
local MAP_SIZE = 196
local DEFAULT_SIZE = 140
local SIZE_DELTA = (MAP_SIZE - DEFAULT_SIZE) / 2

local CLUSTER_X = (17 - SIZE_DELTA) - MARGIN
local CLUSTER_Y = (22 - SIZE_DELTA) - MARGIN

local EDGE_SCALE = 1.0

-- Edit Mode owns the cluster's anchor, scale, and size on TBC 2.5.6; only the
-- vanilla UI lets us place and enlarge the map ourselves.
local modernCluster = MinimapCluster and MinimapCluster.MinimapContainer ~= nil

local HIDDEN = {
    "MinimapBorder",
    "MinimapBorderTop",
    "MinimapZoneTextButton",
    "MinimapToggleButton",
    "MinimapNorthTag",
    "MinimapCompassTexture",
    "MinimapZoomIn",
    "MinimapZoomOut",
    "GameTimeFrame",
}

local BUTTON_SIZE = 33

-- The circular MiniMap-TrackingBorder rings stay; desaturating before the grey
-- vertex color is required because tinting the gold art alone only darkens it.
local RING_COLOR = CleanClassicExperience.COLOR.GREY

local RINGS = {
    "MiniMapMailBorder",
    "MiniMapBattlefieldBorder",
    "MiniMapTrackingBorder",        -- era
    "MiniMapTrackingButtonBorder",  -- tbc
}

local function recolorRing(ring)
    if not ring then return end
    ring:SetDesaturated(true)
    ring:SetVertexColor(unpack(RING_COLOR))
end

local function applyLayout()
    if modernCluster then return end
    Minimap:SetSize(MAP_SIZE, MAP_SIZE)
    MinimapCluster:SetScale(1.0)
    MinimapCluster:ClearAllPoints()
    MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", CLUSTER_X, CLUSTER_Y)
end

-- Match addon buttons to the Blizzard edge buttons: same size, grey ring.
-- Refresh never resets size or border color, so this sticks.
local function refreshAddonIcons()
    if not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.objects and lib.Refresh) then return end
    if lib.SetButtonRadius then lib:SetButtonRadius(0) end
    for name, btn in pairs(lib.objects) do
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        recolorRing(btn.border)
        lib:Refresh(name)
    end
end

local function placeOnEdge(icon, angle)
    local rad = math.rad(angle)
    local radius = (Minimap:GetWidth() / 2) / EDGE_SCALE
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

-- dragHandle: the frame that receives mouse input when it differs from the
-- moved frame (TBC's tracking dropdown child covers its parent entirely).
local function setupEdgeIcon(icon, key, defaultAngle, dragHandle)
    if not icon then return end
    local handle = dragHandle or icon
    icon:SetScale(EDGE_SCALE)
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
    setupEdgeIcon(MiniMapTracking,       "tracking",    135, MiniMapTrackingButton)
    setupEdgeIcon(MiniMapMailFrame,      "mail",         45)
    setupEdgeIcon(MiniMapBattlefieldFrame, "battlefield", 225)
end

local function sizeEdgeButton(btn)
    if btn then btn:SetSize(BUTTON_SIZE, BUTTON_SIZE) end
end

-- Grey rings and one shared frame size; the native icon/ring geometry stays.
local function styleEdgeButtons()
    for _, name in ipairs(RINGS) do
        recolorRing(_G[name])
    end

    sizeEdgeButton(MiniMapTracking)
    sizeEdgeButton(MiniMapMailFrame)
    sizeEdgeButton(MiniMapBattlefieldFrame)

    -- Era draws the tracking ring at 64px while every other button uses 52;
    -- normalize it, shifted by the icon's (2,-2) center offset.
    if MiniMapTrackingBorder then
        MiniMapTrackingBorder:SetSize(52, 52)
        MiniMapTrackingBorder:ClearAllPoints()
        MiniMapTrackingBorder:SetPoint("TOPLEFT", 2, -2)
    end

    -- The native 24px icon fits the 64px ring; shrink it to the mail button's
    -- 18px-under-52px geometry (icon center on the ring opening) so the ring
    -- art crops it again. SetTexture on tracking swaps never resets this.
    if MiniMapTrackingIcon then
        MiniMapTrackingIcon:SetSize(18, 18)
        MiniMapTrackingIcon:ClearAllPoints()
        MiniMapTrackingIcon:SetPoint("TOPLEFT", 9, -8)
    end

    -- TBC wraps tracking in a child dropdown button; keep the click target
    -- matched to the resized frame.
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
    applyLayout()

    for _, name in ipairs(HIDDEN) do
        local region = _G[name]
        if region then region:Hide() end
    end

    -- On TBC the top banner is a parentKey texture, not the MinimapBorderTop global.
    if modernCluster and MinimapCluster.BorderTop then
        MinimapCluster.BorderTop:Hide()
    end

    if TimeManagerClockButton then
        TimeManagerClockButton:Show()
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
end

applyMinimap()

CleanClassicExperience.OnEvent(function()
    C_Timer.After(0, applyMinimap)
end, "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED")
