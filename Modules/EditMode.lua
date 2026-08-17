local movers = {}

local MOVEMENT_KEYS = { UP = true, DOWN = true, LEFT = true, RIGHT = true }

-- Era lacks these HUD systems natively; an unregistered mover adopts EditModeSystemMixin for native placement chrome.
function CleanClassicExperience.CreateMover(systemName, dbKey, width, height)
    local mover = CreateFrame("Frame", nil, UIParent)
    Mixin(mover, EditModeSystemMixin)
    mover:SetSize(width, height)
    mover:SetClampedToScreen(true)
    mover:Hide()

    -- Set only the fields OnSystemLoad would, minus manager registration and the settings map.
    mover.snappedFrames = {}
    mover.downKeys = {}
    mover.systemNameString = systemName

    function mover:SavedPosition()
        return CleanClassicExperienceDB and CleanClassicExperienceDB[dbKey]
    end

    -- Store bottom-right in UIParent space so the anchor survives reloads and pooled snap targets.
    function mover:RestorePosition()
        local pos = self:SavedPosition()
        if not pos then return end
        self:ClearAllPoints()
        self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", pos.right, pos.bottom)
    end

    -- Every native reposition path funnels through here; save to the addon's variables instead of the manager.
    function mover:OnSystemPositionChange()
        CleanClassicExperienceDB = CleanClassicExperienceDB or {}
        CleanClassicExperienceDB[dbKey] = { right = self:GetRight(), bottom = self:GetBottom() }
        self:RestorePosition()
    end

    -- The native SelectSystem attaches the settings dialog these fake systems lack; select without it.
    function mover:SelectSystem()
        if not self.isSelected then
            self:SetMovable(true)
            self.Selection:ShowSelected()
            self.isSelected = true
            self:UpdateMagnetismRegistration()
        end
    end

    -- The mixin sizes nudges from downKeys, but propagated key-downs never send their key-ups here, so a released SHIFT would stick; read the live modifier.
    function mover:IsShiftKeyDown()
        return IsShiftKeyDown()
    end

    -- The real selection template brings the dashed highlight, selected state, and hover label.
    local selection = CreateFrame("Frame", nil, mover, "EditModeSystemSelectionTemplate")
    selection:SetAllPoints(mover)
    selection:SetSystem(mover)
    mover.Selection = selection

    -- The stock handler routes through the manager, which ignores unregistered systems; select locally.
    selection:SetScript("OnMouseDown", function()
        EditModeManagerFrame:ClearSelectedSystem()
        mover:SelectSystem()
    end)

    -- Without a settings dialog feeding keys, listen while visible and swallow only the keys acted on.
    mover:EnableKeyboard(true)
    mover:SetScript("OnKeyDown", function(self, key)
        local swallow = (MOVEMENT_KEYS[key] and self:CanBeMoved())
            or (key == "ESCAPE" and self.isSelected)
        self:SetPropagateKeyboardInput(not swallow)

        if key == "ESCAPE" then
            if self.isSelected then self:HighlightSystem() end
            return
        end

        self:OnKeyDown(key)
    end)
    mover:SetScript("OnKeyUp", mover.OnKeyUp)

    table.insert(movers, mover)
    return mover
end

EventRegistry:RegisterCallback("EditMode.Enter", function()
    for _, mover in ipairs(movers) do
        mover:RestorePosition()
        mover:Show()
        mover:HighlightSystem()
    end
end, movers)

-- Hide before clearing so the focus mirror hooks see hidden movers mid-teardown.
EventRegistry:RegisterCallback("EditMode.Exit", function()
    for _, mover in ipairs(movers) do
        mover:Hide()
        mover:ClearHighlight()
        mover:ClearDownKeys()
    end
end, movers)

-- Mirror native focus flow: any manager-driven pick or clear drops every mover back to highlighted.
local function dropSelection()
    for _, mover in ipairs(movers) do
        if mover:IsShown() then mover:HighlightSystem() end
    end
end
hooksecurefunc(EditModeManagerFrame, "SelectSystem", dropSelection)
hooksecurefunc(EditModeManagerFrame, "ClearSelectedSystem", dropSelection)

-- SavedVariables land after the module files run; place each mover once they exist.
CleanClassicExperience.OnEvent(function()
    for _, mover in ipairs(movers) do
        mover:RestorePosition()
    end
end, "PLAYER_ENTERING_WORLD")
