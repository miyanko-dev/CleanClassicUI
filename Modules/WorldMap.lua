local SCALE = 0.9

local function applyLayout()
    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetScale(SCALE)
    WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    WorldMapFrame.BlackoutFrame.Show = function(self) self:Hide() end
    WorldMapFrame.ScrollContainer.GetCursorPosition = function()
        local x, y = MapCanvasScrollControllerMixin.GetCursorPosition()
        return x / SCALE, y / SCALE
    end
end

local function fadeOnMove()
    if not WorldMapFrame:IsShown() then return end
    local alpha = IsPlayerMoving() and 0.5 or 1
    UIFrameFadeOut(WorldMapFrame, 0.1, WorldMapFrame:GetAlpha(), alpha)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_STARTED_MOVING")
frame:RegisterEvent("PLAYER_STOPPED_MOVING")
frame:SetScript("OnEvent", fadeOnMove)

WorldMapFrame:HookScript("OnUpdate", applyLayout)
WorldMapFrame:HookScript("OnShow", function()
    local alpha = IsPlayerMoving() and 0.5 or 1
    WorldMapFrame:SetAlpha(0)
    UIFrameFadeIn(WorldMapFrame, 0.1, 0, alpha)
    applyLayout()
end)
