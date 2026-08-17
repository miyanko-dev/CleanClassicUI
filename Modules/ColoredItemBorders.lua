-- Classic Era ships IconBorder on every ItemButtonTemplate but leaves it hidden; tint that native region instead of stacking art over the slot.
local MIN_QUALITY = Enum.ItemQuality.Good

-- Quest items are nearly always plain white, so they take Blizzard's quest gold over their own quality color.
local function borderColor(quality, isQuest)
    if isQuest then return NORMAL_FONT_COLOR:GetRGB() end
    if quality and quality >= MIN_QUALITY then return C_Item.GetItemQualityColor(quality) end
end

local function paintBorder(button, r, g, b)
    local border = button and button.IconBorder
    if not border then return end

    if not r then
        border:Hide()
        return
    end

    border:SetVertexColor(r, g, b)
    border:Show()
end

local function paintContainerSlot(button, bagId)
    local slotId = button:GetID()
    local info = C_Container.GetContainerItemInfo(bagId, slotId)
    local questInfo = C_Container.GetContainerItemQuestInfo(bagId, slotId)
    paintBorder(button, borderColor(info and info.quality, questInfo and questInfo.isQuestItem))
end

-- An equipped item resolves to a link only once its data is cached, which is also when Blizzard draws its icon.
local function paintEquippedSlot(button, unit)
    local link = unit and GetInventoryItemLink(unit, button:GetID())
    paintBorder(button, borderColor(link and C_Item.GetItemQualityByID(link)))
end

hooksecurefunc("ContainerFrame_Update", function(frame)
    local name = frame:GetName()
    for i = 1, frame.size do
        paintContainerSlot(_G[name .. "Item" .. i], frame:GetID())
    end
end)

-- Bank bag slots report against the shared bank-bag container, generic slots against the panel itself.
hooksecurefunc("BankFrameItemButton_Update", function(button)
    paintContainerSlot(button, button.isBag and Enum.BagIndex.Bankbag or button:GetParent():GetID())
end)

hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
    paintEquippedSlot(button, "player")
end)

-- The inspect panel loads on demand, so its slot updater only exists to hook once that addon arrives.
CleanClassicExperience.OnEvent(function(self, _, addon)
    if addon ~= "Blizzard_InspectUI" then return end

    hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        paintEquippedSlot(button, InspectFrame.unit)
    end)
    self:UnregisterEvent("ADDON_LOADED")
end, "ADDON_LOADED")
