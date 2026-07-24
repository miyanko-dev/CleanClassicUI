-- At a merchant: repair all gear when affordable, then sell every grey item in throttle-safe batches.
-- The server silently drops sale requests past roughly one buyback page per burst, so sell 12 and rescan.
local BATCH_SIZE     = 12
local BATCH_INTERVAL = 0.3
local MAX_STALLS     = 2

local selling = false

local function repairAll()
    if not CanMerchantRepair() then return end

    local cost = GetRepairAllCost()
    if cost > 0 and GetMoney() >= cost then
        RepairAllItems()
    end
end

-- Re-index every pass: sold slots empty out, so the fresh scan is the sale confirmation.
local function junkSlots()
    local slots = {}
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local slotItem = C_Container.GetContainerItemInfo(bag, slot)
            if slotItem and slotItem.quality == Enum.ItemQuality.Poor and not slotItem.hasNoValue then
                table.insert(slots, { bag = bag, slot = slot })
            end
        end
    end
    return slots
end

local function sellNextBatch(previousCount, stalls)
    if not selling then return end

    local junk = junkSlots()
    if #junk == 0 then
        selling = false
        return
    end

    -- A pass without progress means lag or rejected sales; retry briefly, then stop instead of spamming.
    if previousCount and #junk >= previousCount then
        stalls = stalls + 1
        if stalls > MAX_STALLS then
            selling = false
            return
        end
    else
        stalls = 0
    end

    for i = 1, math.min(#junk, BATCH_SIZE) do
        C_Container.UseContainerItem(junk[i].bag, junk[i].slot)
    end

    C_Timer.After(BATCH_INTERVAL, function() sellNextBatch(#junk, stalls) end)
end

local function sellGreyItems()
    selling = true
    sellNextBatch(nil, 0)
end

CleanClassicExperience.OnEvent(function(_, event)
    if event == "MERCHANT_SHOW" then
        repairAll()
        sellGreyItems()
    else
        selling = false
    end
end, "MERCHANT_SHOW", "MERCHANT_CLOSED")
