-- Make the fixed clock/alarm panel draggable and remember its spot; Blizzard_TimeManager is load-on-demand.
local DB_KEY = "timeManagerFrame"

local function getDB()
    CleanClassicExperienceDB = CleanClassicExperienceDB or {}
    CleanClassicExperienceDB[DB_KEY] = CleanClassicExperienceDB[DB_KEY] or {}
    return CleanClassicExperienceDB[DB_KEY]
end

local function savePosition(frame)
    local point, _, relPoint, x, y = frame:GetPoint(1)
    if not point then return end

    local db = getDB()
    db.point, db.relPoint, db.x, db.y = point, relPoint, x, y
end

local function loadPosition(frame)
    local db = getDB()
    if not db.point then return end

    frame:ClearAllPoints()
    frame:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
end

local function makeMovable()
    local frame = TimeManagerFrame
    if not frame or frame.cleanMovable then return end
    frame.cleanMovable = true

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        savePosition(self)
    end)

    loadPosition(frame)
end

if C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") then
    makeMovable()
else
    CleanClassicExperience.OnEvent(function(self, _, name)
        if name == "Blizzard_TimeManager" then
            self:UnregisterEvent("ADDON_LOADED")
            makeMovable()
        end
    end, "ADDON_LOADED")
end
