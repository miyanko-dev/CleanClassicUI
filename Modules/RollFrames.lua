local SPACING = CleanClassicUI.SPACING

local FRAME_GAP = SPACING.XS
local LEFT_MARGIN = 24
local DEFAULT_FRAME_HEIGHT = 85
local ANCHOR_SIZE = 24
local DB_KEY = "rollFramesAnchor"

local function getDB()
    CleanClassicUIDB = CleanClassicUIDB or {}
    CleanClassicUIDB[DB_KEY] = CleanClassicUIDB[DB_KEY] or {}
    return CleanClassicUIDB[DB_KEY]
end

local anchor = CreateFrame("Frame", "CleanClassicUIRollAnchor", UIParent)
anchor:SetSize(ANCHOR_SIZE, ANCHOR_SIZE)
anchor:SetFrameStrata("MEDIUM")
anchor:SetMovable(true)
anchor:SetClampedToScreen(true)

local function frameCount()
    return NUM_GROUP_LOOT_FRAMES or 4
end

local function frameHeight()
    if GroupLootFrame1 and GroupLootFrame1:GetHeight() > 0 then
        return GroupLootFrame1:GetHeight()
    end
    return DEFAULT_FRAME_HEIGHT
end

local function applyDefaultPosition()
    local stack = frameCount() * frameHeight() + (frameCount() - 1) * FRAME_GAP
    anchor:ClearAllPoints()
    anchor:SetPoint("TOPLEFT", UIParent, "LEFT", LEFT_MARGIN, stack / 2)
end

local function savePosition()
    local point, _, relPoint, x, y = anchor:GetPoint(1)
    if not point then return end
    local db = getDB()
    db.point, db.relPoint, db.x, db.y = point, relPoint, x, y
end

local function loadPosition()
    local db = getDB()
    if db.point then
        anchor:ClearAllPoints()
        anchor:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
    else
        applyDefaultPosition()
    end
end

local function attachDrag(frame)
    if frame.cleanCCUIDragHooked then return end
    frame.cleanCCUIDragHooked = true
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() anchor:StartMoving() end)
    frame:SetScript("OnDragStop", function()
        anchor:StopMovingOrSizing()
        savePosition()
    end)
end

local function arrangeRollFrames()
    for i = 1, frameCount() do
        local frame = _G["GroupLootFrame" .. i]
        if frame then
            frame:ClearAllPoints()
            if i == 1 then
                frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
            else
                frame:SetPoint("TOPLEFT", _G["GroupLootFrame" .. (i - 1)], "BOTTOMLEFT", 0, -FRAME_GAP)
            end
            attachDrag(frame)
        end
    end
end

if type(GroupLootFrame_OpenNewFrame) == "function" then
    hooksecurefunc("GroupLootFrame_OpenNewFrame", arrangeRollFrames)
end

CleanClassicUI.OnEvent(function()
    loadPosition()
    arrangeRollFrames()
end, "PLAYER_LOGIN")
