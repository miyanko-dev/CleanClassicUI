local MARGIN = 24
local MAP_SIZE = 196
local DEFAULT_SIZE = 140
local SIZE_DELTA = (MAP_SIZE - DEFAULT_SIZE) / 2

local CLUSTER_X = (17 - SIZE_DELTA) - MARGIN
local CLUSTER_Y = (22 - SIZE_DELTA) - MARGIN

local EDGE_SCALE = 1.0
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

local function placeOnEdge(frame, angle)
    local rad = math.rad(angle)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", Minimap, "CENTER", math.cos(rad) * EDGE_RADIUS, math.sin(rad) * EDGE_RADIUS)
end

local function dragUpdate(frame, key)
    local cx, cy = Minimap:GetCenter()
    if not cx then return end
    local mx, my = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local angle = math.deg(math.atan2(my / scale - cy, mx / scale - cx))
    CleanUIClassicDB.iconAngles[key] = angle
    placeOnEdge(frame, angle)
end

local function setupEdgeIcon(frame, key, defaultAngle)
    if not frame then return end
    frame:SetScale(EDGE_SCALE)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(self) dragUpdate(self, key) end)
    end)
    frame:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    local angle = CleanUIClassicDB.iconAngles[key] or defaultAngle
    placeOnEdge(frame, angle)
end

local function adjustEdgeIcons()
    setupEdgeIcon(MiniMapTracking, "tracking", 135)
    setupEdgeIcon(MiniMapMailFrame, "mail", 45)
    setupEdgeIcon(MiniMapBattlefieldFrame, "battlefield", 225)
end

applyLayout()

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)

local function refresh()
    applyLayout()
    for _, name in ipairs(HIDDEN) do
        local f = _G[name]
        if f then f:Hide() end
    end
    if TimeManagerClockButton then TimeManagerClockButton:Hide() end
    CleanUIClassicDB = CleanUIClassicDB or {}
    CleanUIClassicDB.iconAngles = CleanUIClassicDB.iconAngles or {}
    adjustEdgeIcons()
    refreshAddonIcons()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:SetScript("OnEvent", function()
    C_Timer.After(0, refresh)
end)
