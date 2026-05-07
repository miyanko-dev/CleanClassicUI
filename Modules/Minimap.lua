local PADDING = 24
local MINIMAP_SIZE = 196
local DEFAULT_SIZE = 140
local DELTA = (MINIMAP_SIZE - DEFAULT_SIZE) / 2

-- Cluster default insets to the Minimap edges (Classic Era source: Minimap.xml).
-- Minimap is anchored CENTER -> cluster TOP at offset (9, -92), so at default
-- size it's 17 from cluster right and 22 from cluster top. Resizing reduces
-- those insets and may overflow.
local CLUSTER_RIGHT_INSET = 17 - DELTA
local CLUSTER_TOP_INSET = 22 - DELTA
local X_OFFSET = CLUSTER_RIGHT_INSET - PADDING
local Y_OFFSET = CLUSTER_TOP_INSET - PADDING

local hideList = {
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
    MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", X_OFFSET, Y_OFFSET)
end

local function refreshAddonButtons()
    if not LibStub then return end
    local lib = LibStub("LibDBIcon-1.0", true)
    if not (lib and lib.objects and lib.Refresh) then return end
    for name in pairs(lib.objects) do
        lib:Refresh(name)
    end
end

-- Apply size/position immediately at file load so addons that register
-- minimap buttons during ADDON_LOADED/PLAYER_LOGIN see the final size.
applyLayout()

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)

local function onLogin()
    applyLayout()
    for _, name in ipairs(hideList) do
        local frame = _G[name]
        if frame then frame:Hide() end
    end
    if TimeManagerClockButton then
        TimeManagerClockButton:Hide()
    end
    refreshAddonButtons()
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", onLogin)
