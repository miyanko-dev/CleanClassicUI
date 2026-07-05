local SPACING = CleanClassicUI.SPACING

local FRAME_GAP           = SPACING.XS
local LEFT_MARGIN         = SPACING.LG
local DEFAULT_FRAME_HEIGHT = 85
local ANCHOR_SIZE         = 24
local DB_KEY              = "rollFramesAnchor"

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
    local stackHeight = frameCount() * frameHeight() + (frameCount() - 1) * FRAME_GAP
    anchor:ClearAllPoints()
    anchor:SetPoint("TOPLEFT", UIParent, "LEFT", LEFT_MARGIN, stackHeight / 2)
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

-- Blizzard resets a dragged frame too; restore where the player left it
local function restoreDraggedPosition(frame)
    local saved = frame.cleanCCUIDragPoint
    if not saved then return end

    frame:ClearAllPoints()
    frame:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4])
end

local function attachDrag(frame)
    if frame.cleanCCUIDragHooked then return end
    frame.cleanCCUIDragHooked = true

    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then
            self.cleanCCUIMovingStack = true
            anchor:StartMoving()
        else
            self.cleanCCUIDragged = true
            self:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(self)
        if self.cleanCCUIMovingStack then
            self.cleanCCUIMovingStack = nil
            anchor:StopMovingOrSizing()
            savePosition()
        else
            self:StopMovingOrSizing()
            local point, _, relPoint, x, y = self:GetPoint(1)
            self.cleanCCUIDragPoint = { point, relPoint, x, y }
        end
    end)

    frame:HookScript("OnHide", function(self)
        self.cleanCCUIDragged = nil
        self.cleanCCUIDragPoint = nil
    end)
end

local function arrangeRollFrames()
    local previous

    for i = 1, frameCount() do
        local frame = _G["GroupLootFrame" .. i]
        if frame then
            attachDrag(frame)

            if frame.cleanCCUIDragged then
                restoreDraggedPosition(frame)
            else
                frame:ClearAllPoints()
                if previous then
                    frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -FRAME_GAP)
                else
                    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
                end
                previous = frame
            end
        end
    end
end

-- Runs on every add AND remove; hooking only GroupLootFrame_OpenNewFrame
-- misses the reset that GroupLootContainer_RemoveFrame triggers
if type(GroupLootContainer_Update) == "function" then
    hooksecurefunc("GroupLootContainer_Update", arrangeRollFrames)
end

CleanClassicUI.OnEvent(function()
    loadPosition()
    arrangeRollFrames()
end, "PLAYER_LOGIN")
