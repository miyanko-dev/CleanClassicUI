local QUALITY_COLORS = ITEM_QUALITY_COLORS
local BORDER_TEXTURE = [[Interface\Common\WhiteIconFrame]]
local QUEST_COLOR    = CleanClassicExperience.COLOR.YELLOW

-- Skip Poor and Common to keep grey and white items uncluttered.
local MIN_QUALITY = 2

local function showBorder(button, r, g, b)
    local border = button and button.IconBorder
    if not border then return end
    border:SetTexture(BORDER_TEXTURE)
    border:SetVertexColor(r, g, b)
    border:Show()
end

local function hideBorder(button)
    local border = button and button.IconBorder
    if border then border:Hide() end
end

local function colorByQuality(button, quality)
    if not quality or quality < MIN_QUALITY then return end
    local color = QUALITY_COLORS and QUALITY_COLORS[quality]
    if color then showBorder(button, color.r, color.g, color.b) end
end

-- Bags, bank, merchant, loot, mail: stock coloring via the global hook.
hooksecurefunc("SetItemButtonQuality", colorByQuality)

-- Equipped gear: PaperDoll slots never call SetItemButtonQuality in Classic.
hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
    local quality = GetInventoryItemQuality("player", button:GetID())
    if quality and quality >= MIN_QUALITY then
        colorByQuality(button, quality)
    else
        hideBorder(button)
    end
end)

-- Inspected gear: same as PaperDoll, but Blizzard_InspectUI is load-on-demand.
local function hookInspectSlots()
    hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        local unit    = InspectFrame and InspectFrame.unit
        local quality = unit and GetInventoryItemQuality(unit, button:GetID())
        if quality and quality >= MIN_QUALITY then
            colorByQuality(button, quality)
        else
            hideBorder(button)
        end
    end)
end

if C_AddOns.IsAddOnLoaded("Blizzard_InspectUI") then
    hookInspectSlots()
else
    CleanClassicExperience.OnEvent(function(frame, _, addonName)
        if addonName == "Blizzard_InspectUI" then
            frame:UnregisterEvent("ADDON_LOADED")
            hookInspectSlots()
        end
    end, "ADDON_LOADED")
end

-- Quest items in bags: override the quality color with quest yellow.
hooksecurefunc("ContainerFrame_Update", function(frame)
    local bagID = frame:GetID()
    local name  = frame:GetName()
    for i = 1, frame.size do
        local btn = _G[name .. "Item" .. i]
        if btn then
            local info = C_Container.GetContainerItemQuestInfo(bagID, btn:GetID())
            if info and info.isQuestItem then
                showBorder(btn, QUEST_COLOR[1], QUEST_COLOR[2], QUEST_COLOR[3])
            end
        end
    end
end)
