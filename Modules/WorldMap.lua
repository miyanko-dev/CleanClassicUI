local FRAME_SCALE      = 0.9
local MAX_CANVAS_ZOOM  = 4.0
local CANVAS_ZOOM_STEP = 0.25

local worldMap        = WorldMapFrame
local scrollContainer = worldMap.ScrollContainer

-- One-time setup: fixed scale, wheel zoom, and a blackout backdrop that never shows.
worldMap:SetScale(FRAME_SCALE)
worldMap.BlackoutFrame.Show = worldMap.BlackoutFrame.Hide
scrollContainer:EnableMouseWheel(true)

-- Compensate cursor lookup for the scaled frame so pin hit-tests stay aligned.
scrollContainer.GetCursorPosition = function(self)
    local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(self)
    return x / FRAME_SCALE, y / FRAME_SCALE
end

-- Raise the canvas zoom ceiling so the wheel can zoom past the native zone tier.
scrollContainer.GetScaleForMaxZoom = function(self)
    return MAX_CANVAS_ZOOM * (self.baseScale or 1)
end

-- Floor zoom-out at the scale that fully covers the viewport so no texture edges show.
scrollContainer.GetScaleForMinZoom = function(self)
    local layers = self.mapID and C_Map.GetMapArtLayers(self.mapID)
    if not (layers and layers[1]) then
        return (self.zoomLevels and self.zoomLevels[1] and self.zoomLevels[1].scale) or 1
    end
    local widthScale  = self:GetWidth()  / layers[1].layerWidth
    local heightScale = self:GetHeight() / layers[1].layerHeight
    return math.max(widthScale, heightScale)
end

-- Snap zoom directly to the new scale and anchor pan at the cursor's canvas point.
scrollContainer:SetScript("OnMouseWheel", function(self, delta)
    local currentScale = self:GetCanvasScale()
    local step         = CANVAS_ZOOM_STEP * (self.baseScale or 1)
    local newScale     = math.max(self:GetScaleForMinZoom(), math.min(self:GetScaleForMaxZoom(), currentScale + delta * step))
    if newScale == currentScale then return end

    local cursorX, cursorY = self:GetCursorPosition()
    local cursorNormX = self:NormalizeHorizontalSize(cursorX / currentScale - self.Child:GetLeft())
    local cursorNormY = self:NormalizeVerticalSize(self.Child:GetTop() - cursorY / currentScale)

    self:InstantPanAndZoom(newScale, cursorNormX, cursorNormY)
end)

-- The panel manager keeps tucking the map aside, so re-centre it every frame it's shown.
worldMap:HookScript("OnUpdate", function(self)
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end)
