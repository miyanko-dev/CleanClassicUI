-- Stack the loot roll frames on a movable handle. Untouched, they sit at Blizzard's native spot;
-- drag any frame to move the whole stack, and it returns there every time the frames reappear.
local SPACING = CleanClassicExperience.SPACING

local FRAME_GAP   = SPACING[4]
local ANCHOR_SIZE = 24
local DB_KEY      = "rollFramesAnchor"

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

-- Pin the handle to the game's own loot container so an unmoved stack matches vanilla.
local function applyNativePosition()
    anchor:ClearAllPoints()
    if GroupLootContainer then
        anchor:SetPoint("BOTTOM", GroupLootContainer, "BOTTOM", 0, 0)
    else
        anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

local function loadPosition()
    local db = getDB()
    if db.left then
        anchor:ClearAllPoints()
        anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.left, db.bottom)
    else
        applyNativePosition()
    end
end

-- Store screen coordinates against UIParent so the saved spot survives the native container moving or hiding.
local function savePosition()
    local left, bottom = anchor:GetLeft(), anchor:GetBottom()
    if not left then return end

    anchor:ClearAllPoints()
    anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)

    local db = getDB()
    db.left, db.bottom = left, bottom
end

local arrangeRollFrames

local function attachDrag(frame)
    if frame.cleanDragHooked then return end
    frame.cleanDragHooked = true

    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    -- Every frame rides the handle, so dragging any one moves the whole stack, then persists it.
    frame:SetScript("OnDragStart", function() anchor:StartMoving() end)
    frame:SetScript("OnDragStop", function()
        anchor:StopMovingOrSizing()
        savePosition()
        arrangeRollFrames()
    end)
end

function arrangeRollFrames()
    if not anchor:GetPoint() then loadPosition() end

    -- Grow the stack upward from the handle, matching the native bottom-anchored layout.
    local previous
    for i = 1, frameCount() do
        local frame = _G["GroupLootFrame" .. i]
        if frame then
            attachDrag(frame)
            frame:ClearAllPoints()
            if previous then
                frame:SetPoint("BOTTOM", previous, "TOP", 0, FRAME_GAP)
            else
                frame:SetPoint("BOTTOM", anchor, "BOTTOM", 0, 0)
            end
            previous = frame
        end
    end
end

-- GroupLootContainer_Update runs on add and remove; hooking it keeps our layout through both.
if type(GroupLootContainer_Update) == "function" then
    hooksecurefunc("GroupLootContainer_Update", arrangeRollFrames)
end

CleanClassicExperience.OnEvent(function()
    loadPosition()
    arrangeRollFrames()
end, "PLAYER_LOGIN")
