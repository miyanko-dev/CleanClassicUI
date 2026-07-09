local MARGIN = CleanClassicExperience.SPACING.LG
local MAP_SIZE = 196
local DEFAULT_SIZE = 140
local SIZE_DELTA = (MAP_SIZE - DEFAULT_SIZE) / 2

local CLUSTER_X = (17 - SIZE_DELTA) - MARGIN
local CLUSTER_Y = (22 - SIZE_DELTA) - MARGIN

local EDGE_SCALE  = 1.0
local EDGE_RADIUS = (MAP_SIZE / 2) / EDGE_SCALE

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

local function applyLayout()
    Minimap:SetSize(MAP_SIZE, MAP_SIZE)
    MinimapCluster:SetScale(1.0)
    MinimapCluster:ClearAllPoints()
    MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", CLUSTER_X, CLUSTER_Y)
end

local function refreshAddonIcons()
    if not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.objects and lib.Refresh) then return end
    if lib.SetButtonRadius then lib:SetButtonRadius(0) end
    for name in pairs(lib.objects) do
        lib:Refresh(name)
    end
end

local function placeOnEdge(icon, angle)
    local rad = math.rad(angle)
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", Minimap, "CENTER", math.cos(rad) * EDGE_RADIUS, math.sin(rad) * EDGE_RADIUS)
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

local function setupEdgeIcon(icon, key, defaultAngle)
    if not icon then return end
    icon:SetScale(EDGE_SCALE)
    icon:SetMovable(true)
    icon:RegisterForDrag("LeftButton")
    icon:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(this) dragUpdate(this, key) end)
    end)
    icon:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    local angle = CleanClassicExperienceDB.iconAngles[key] or defaultAngle
    placeOnEdge(icon, angle)
end

local function adjustEdgeIcons()
    setupEdgeIcon(MiniMapTracking,       "tracking",    135)
    setupEdgeIcon(MiniMapMailFrame,      "mail",         45)
    setupEdgeIcon(MiniMapBattlefieldFrame, "battlefield", 225)
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
    adjustEdgeIcons()
    refreshAddonIcons()
end

applyMinimap()

CleanClassicExperience.OnEvent(function()
    C_Timer.After(0, applyMinimap)
end, "PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED")
