-- Era ships no HudTooltip system; an unregistered mover adopts EditModeSystemMixin for native placement chrome.

-- Footprint and default spot mirror retail's GameTooltipDefaultContainer.
local mover = CreateFrame("Frame", nil, UIParent)
Mixin(mover, EditModeSystemMixin)
mover:SetSize(250, 150)
mover:SetPoint("BOTTOMRIGHT", -9, 85)
mover:SetClampedToScreen(true)
mover:Hide()

-- Set only the fields OnSystemLoad would, minus manager registration and the settings map.
mover.snappedFrames = {}
mover.downKeys = {}
mover.systemNameString = "Tooltip"

local function savedPosition()
    return CleanClassicExperienceDB and CleanClassicExperienceDB.tooltipAnchor
end

-- Store bottom-right in UIParent space so the anchor survives reloads and pooled snap targets.
local function restorePosition()
    local pos = savedPosition()
    if not pos then return end
    mover:ClearAllPoints()
    mover:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", pos.right, pos.bottom)
end

-- Every native reposition path funnels through here; save to the addon's variables instead of the manager.
function mover:OnSystemPositionChange()
    CleanClassicExperienceDB = CleanClassicExperienceDB or {}
    CleanClassicExperienceDB.tooltipAnchor = { right = self:GetRight(), bottom = self:GetBottom() }
    restorePosition()
end

-- The native SelectSystem attaches the settings dialog this fake system lacks; select without it.
function mover:SelectSystem()
    if not self.isSelected then
        self:SetMovable(true)
        self.Selection:ShowSelected()
        self.isSelected = true
        self:UpdateMagnetismRegistration()
    end
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

-- Mirror native focus flow: any manager-driven pick or clear drops this mover back to highlighted.
local function dropSelection()
    if mover:IsShown() then mover:HighlightSystem() end
end
hooksecurefunc(EditModeManagerFrame, "SelectSystem", dropSelection)
hooksecurefunc(EditModeManagerFrame, "ClearSelectedSystem", dropSelection)

-- Without a settings dialog feeding keys, listen while visible and swallow only the keys acted on.
local MOVEMENT_KEYS = { UP = true, DOWN = true, LEFT = true, RIGHT = true }

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

EventRegistry:RegisterCallback("EditMode.Enter", function()
    restorePosition()
    mover:Show()
    mover:HighlightSystem()
end, mover)

-- Hide before clearing so the focus mirror hooks see a hidden mover mid-teardown.
EventRegistry:RegisterCallback("EditMode.Exit", function()
    mover:Hide()
    mover:ClearHighlight()
    mover:ClearDownKeys()
end, mover)

-- Blizzard forces ANCHOR_NONE before this hook runs, so anchoring to the hidden mover is safe.
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    if not savedPosition() then return end
    tooltip:ClearAllPoints()
    tooltip:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT")
end)

-- SavedVariables land after this file runs; place the mover once they exist.
CleanClassicExperience.OnEvent(restorePosition, "PLAYER_ENTERING_WORLD")

CleanClassicExperience.HideForever(GameTooltipStatusBar)

local function appendItemLevel(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end

    local level = C_Item.GetDetailedItemLevelInfo(link)
    if not level or level <= 0 then return end

    tooltip:AddLine("Item Level " .. level, 1, 0.82, 0)
end

GameTooltip:HookScript("OnTooltipSetItem",    appendItemLevel)
ItemRefTooltip:HookScript("OnTooltipSetItem", appendItemLevel)
