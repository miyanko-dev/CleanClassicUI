-- At a merchant: repair all gear when affordable, then sell every grey item.

local function repairAll()
    if not CanMerchantRepair() then return end

    local cost = GetRepairAllCost()
    if cost > 0 and GetMoney() >= cost then
        RepairAllItems()
    end
end

local function sellGreyItems()
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item and item.quality == Enum.ItemQuality.Poor and not item.hasNoValue then
                C_Container.UseContainerItem(bag, slot)
            end
        end
    end
end

CleanClassicExperience.OnEvent(function()
    repairAll()
    sellGreyItems()
end, "MERCHANT_SHOW")
