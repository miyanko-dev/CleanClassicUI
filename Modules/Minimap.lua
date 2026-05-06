local SCALE = 1.4
local INV_SCALE = 1 / SCALE
local CIRCLE_MASK = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
local EDGE_PADDING = 10

local hideList = {
    "GameTimeFrame",
    "MinimapZoneTextButton",
    "MinimapToggleButton",
    "MinimapCompassTexture",
    "MinimapBorder",
    "MinimapBorderTop",
    "MinimapZoomIn",
    "MinimapZoomOut",
}

local function buildBorder()
    if Minimap.cleanBorder then return end

    local border = Minimap:CreateTexture(nil, "BACKGROUND", nil, -7)
    border:SetTexture(CIRCLE_MASK)
    border:SetVertexColor(0, 0, 0, 0.5)
    border:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)

    Minimap.cleanBorder = border
end

local function hookChild(child)
    if child.cleanHooked then return end
    child.cleanHooked = true
    hooksecurefunc(child, "SetPoint", function(self, point, relTo, relPoint, x, y)
        if relTo ~= Minimap or self.cleanInHook then return end
        self.cleanInHook = true
        self:SetPoint(point, relTo, relPoint, (x or 0) * SCALE, (y or 0) * SCALE)
        self.cleanInHook = false
    end)
end

local function adjustChild(child)
    hookChild(child)
    if child.cleanAdjusted then return end
    child.cleanAdjusted = true

    for i = 1, child:GetNumPoints() do
        local point, relTo, relPoint, x, y = child:GetPoint(i)
        if relTo == Minimap then
            child:SetPoint(point, relTo, relPoint, x, y)
        end
    end
    child:SetScale(INV_SCALE)
end

local function adjustChildren()
    for _, child in ipairs({ Minimap:GetChildren() }) do
        adjustChild(child)
    end
end

local function placeOnEdge(frame, dbKey, defaultAngle)
    if not frame then return end
    CleanUIClassicDB = CleanUIClassicDB or {}
    local angle = math.rad(CleanUIClassicDB[dbKey] or defaultAngle)
    local r = Minimap:GetWidth() / 2 + EDGE_PADDING
    frame.cleanInHook = true
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
    frame.cleanInHook = false
end

local function makeDraggable(frame, dbKey, defaultAngle)
    if not frame or frame.cleanDragSetup then return end
    frame.cleanDragSetup = true

    frame:SetParent(Minimap)
    frame:SetScale(INV_SCALE)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            local sc = Minimap:GetEffectiveScale()
            cx, cy = cx * sc, cy * sc
            CleanUIClassicDB = CleanUIClassicDB or {}
            CleanUIClassicDB[dbKey] = math.deg(math.atan2(my - cy, mx - cx))
            placeOnEdge(self, dbKey, defaultAngle)
        end)
    end)
    frame:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    placeOnEdge(frame, dbKey, defaultAngle)
end

local function setupEdgeButtons()
    makeDraggable(MiniMapMailFrame, "mailAngle", 225)
    makeDraggable(MiniMapTracking, "trackingAngle", 270)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_PENDING_MAIL")
f:SetScript("OnEvent", function()
    Minimap:SetScale(SCALE)
    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)

    for _, name in ipairs(hideList) do
        local frame = _G[name]
        if frame then frame:Hide() end
    end

    buildBorder()
    adjustChildren()
    setupEdgeButtons()
    C_Timer.After(2, function()
        adjustChildren()
        setupEdgeButtons()
    end)

    Minimap:EnableMouseWheel(true)
    Minimap:SetScript("OnMouseWheel", function(_, delta)
        if delta > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
    end)
end)
