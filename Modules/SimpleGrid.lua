local SPACING = 20
local GRID_ALPHA = 0.15
local CENTER_THICKNESS = 2
local CENTER_ALPHA = 0.6
local WHITE = "Interface/Buttons/WHITE8x8"

local gridFrame

local function build()
    if gridFrame then return gridFrame end
    gridFrame = CreateFrame("Frame", "CleanUISimpleGrid", UIParent)
    gridFrame:SetAllPoints()
    gridFrame:SetFrameStrata("HIGH")
    gridFrame:Hide()

    local cx = GetScreenWidth() / 2
    local cy = GetScreenHeight() / 2

    for i = 1, math.floor(cx / SPACING) do
        local off = i * SPACING
        for _, s in ipairs({1, -1}) do
            local l = gridFrame:CreateTexture(nil, "BACKGROUND")
            l:SetTexture(WHITE)
            l:SetVertexColor(1, 1, 1, GRID_ALPHA)
            l:SetWidth(1)
            l:SetPoint("TOP", UIParent, "TOP", s * off, 0)
            l:SetPoint("BOTTOM", UIParent, "BOTTOM", s * off, 0)
        end
    end

    for i = 1, math.floor(cy / SPACING) do
        local off = i * SPACING
        for _, s in ipairs({1, -1}) do
            local l = gridFrame:CreateTexture(nil, "BACKGROUND")
            l:SetTexture(WHITE)
            l:SetVertexColor(1, 1, 1, GRID_ALPHA)
            l:SetHeight(1)
            l:SetPoint("LEFT", UIParent, "LEFT", 0, s * off)
            l:SetPoint("RIGHT", UIParent, "RIGHT", 0, s * off)
        end
    end

    local v = gridFrame:CreateTexture(nil, "OVERLAY")
    v:SetTexture(WHITE)
    v:SetVertexColor(1, 1, 1, CENTER_ALPHA)
    v:SetWidth(CENTER_THICKNESS)
    v:SetPoint("TOP", UIParent, "TOP", 0, 0)
    v:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)

    local h = gridFrame:CreateTexture(nil, "OVERLAY")
    h:SetTexture(WHITE)
    h:SetVertexColor(1, 1, 1, CENTER_ALPHA)
    h:SetHeight(CENTER_THICKNESS)
    h:SetPoint("LEFT", UIParent, "LEFT", 0, 0)
    h:SetPoint("RIGHT", UIParent, "RIGHT", 0, 0)

    return gridFrame
end

SLASH_SIMPLEGRID1 = "/simplegrid"
SlashCmdList["SIMPLEGRID"] = function()
    local g = build()
    if g:IsShown() then g:Hide() else g:Show() end
end
