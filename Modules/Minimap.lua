local MARGIN = 24
local MAP_SIZE = 196
local DEFAULT_SIZE = 140
local SIZE_DELTA = (MAP_SIZE - DEFAULT_SIZE) / 2

local CLUSTER_X = (17 - SIZE_DELTA) - MARGIN
local CLUSTER_Y = (22 - SIZE_DELTA) - MARGIN

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

local function refreshIcons()
    if not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.objects and lib.Refresh) then return end
    for name in pairs(lib.objects) do
        lib:Refresh(name)
    end
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
    refreshIcons()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:SetScript("OnEvent", function()
    C_Timer.After(0, refresh)
end)
