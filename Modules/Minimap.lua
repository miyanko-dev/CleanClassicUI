local SCREEN_PADDING = 24
local MINIMAP_SIZE = 196
local DEFAULT_SIZE = 140
local SIZE_DELTA = (MINIMAP_SIZE - DEFAULT_SIZE) / 2

-- MinimapCluster has 17px right / 22px top default insets to the Minimap.
-- Resizing reduces those insets, so we offset the cluster to compensate.
local CLUSTER_X = (17 - SIZE_DELTA) - SCREEN_PADDING
local CLUSTER_Y = (22 - SIZE_DELTA) - SCREEN_PADDING

local HIDDEN_FRAMES = {
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
    Minimap:SetSize(MINIMAP_SIZE, MINIMAP_SIZE)
    MinimapCluster:SetScale(1.0)
    MinimapCluster:ClearAllPoints()
    MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", CLUSTER_X, CLUSTER_Y)
end

local function refreshMinimapButtons()
    if not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.objects and lib.Refresh) then return end
    for name in pairs(lib.objects) do
        lib:Refresh(name)
    end
end

-- Apply at file load so addons registering buttons during ADDON_LOADED see final size.
applyLayout()

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    applyLayout()
    for _, name in ipairs(HIDDEN_FRAMES) do
        local f = _G[name]
        if f then f:Hide() end
    end
    if TimeManagerClockButton then TimeManagerClockButton:Hide() end
    refreshMinimapButtons()
end)
