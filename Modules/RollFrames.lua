-- Stack the loot roll frames on a movable anchor; drag one frame free, shift-drag to move the whole stack.
local SPACING = CleanClassicExperience.SPACING

local FRAME_GAP           = SPACING.XS
local LEFT_MARGIN         = SPACING.LG
local DEFAULT_FRAME_HEIGHT = 85
local ANCHOR_SIZE         = 24
local DB_KEY              = "rollFramesAnchor"

local function getDB()
    CleanClassicExperienceDB = CleanClassicExperienceDB or {}
    CleanClassicExperienceDB[DB_KEY] = CleanClassicExperienceDB[DB_KEY] or {}
    return CleanClassicExperienceDB[DB_KEY]
end

local anchor = CreateFrame("Frame", "CleanClassicExperienceRollAnchor", UIParent)
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

-- Blizzard resets a dragged frame too; restore where the player left it.
local function restoreDraggedPosition(frame)
    local saved = frame.cleanDragPoint
    if not saved then return end

    frame:ClearAllPoints()
    frame:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4])
end

local function attachDrag(frame)
    if frame.cleanDragHooked then return end
    frame.cleanDragHooked = true

    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then
            self.cleanMovingStack = true
            anchor:StartMoving()
        else
            self.cleanDragged = true
            self:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(self)
        if self.cleanMovingStack then
            self.cleanMovingStack = nil
            anchor:StopMovingOrSizing()
            savePosition()
        else
            self:StopMovingOrSizing()
            local point, _, relPoint, x, y = self:GetPoint(1)
            self.cleanDragPoint = { point, relPoint, x, y }
        end
    end)

    frame:HookScript("OnHide", function(self)
        self.cleanDragged = nil
        self.cleanDragPoint = nil
    end)
end

local function arrangeRollFrames()
    local previous

    for i = 1, frameCount() do
        local frame = _G["GroupLootFrame" .. i]
        if frame then
            attachDrag(frame)

            if frame.cleanDragged then
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

-- GroupLootContainer_Update runs on add and remove; hooking only OpenNewFrame would miss removals.
if type(GroupLootContainer_Update) == "function" then
    hooksecurefunc("GroupLootContainer_Update", arrangeRollFrames)
end

CleanClassicExperience.OnEvent(function()
    loadPosition()
    arrangeRollFrames()
end, "PLAYER_LOGIN")
