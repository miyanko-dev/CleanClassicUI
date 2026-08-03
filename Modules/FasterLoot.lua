local addon = CreateFrame("Frame")

-- parenting LootFrame to a hidden frame stops it rendering without firing OnHide and CloseLoot
local hider = CreateFrame("Frame", nil, UIParent)
hider:Hide()
LootFrame:SetParent(hider)

-- Blizzard anchors the frame while it is invisible, revealing is just a reparent
local function revealIfLootRemains()
    for slot = 1, GetNumLootItems() do
        if LootSlotHasItem(slot) then
            LootFrame:SetParent(UIParent)
            return
        end
    end
end

addon:RegisterEvent("LOOT_READY")
addon:RegisterEvent("LOOT_CLOSED")

addon:SetScript("OnEvent", function(_, event)
    if event == "LOOT_CLOSED" then
        LootFrame:SetParent(hider)
        return
    end

    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        if TSMDestroyBtn and TSMDestroyBtn:IsShown() and TSMDestroyBtn:GetButtonState() == "DISABLED" then
            return
        end
        for i = GetNumLootItems(), 1, -1 do
            LootSlot(i)
        end
        -- anything the server refuses stays in a slot, that is the only reason to see the frame
        C_Timer.After(0.4, revealIfLootRemains)
    else
        revealIfLootRemains()
    end
end)
