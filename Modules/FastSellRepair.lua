-- At a merchant: repair all gear when affordable, then sell every grey item in throttle-safe batches.
-- The server silently drops sale requests past roughly one buyback page per burst, so sell 12 and rescan.
local BATCH_SIZE     = 12
local BATCH_INTERVAL = 0.3
local MAX_STALLS     = 2

local REPAIR_FORMAT = "Repaired for %s."
local SOLD_FORMAT   = "Sold junk for %s."

local selling = false
local junkValue = 0

-- Print in the system color so the report reads as a game line rather than addon chatter.
local function printMoney(format, amount)
    local color = ChatTypeInfo["SYSTEM"]
    local coins = C_CurrencyInfo.GetCoinTextureString(amount)
    DEFAULT_CHAT_FRAME:AddMessage(format:format(coins), color.r, color.g, color.b)
end

local function repairAll()
    if not CanMerchantRepair() then return end

    local cost = GetRepairAllCost()
    if cost > 0 and GetMoney() >= cost then
        RepairAllItems()
        printMoney(REPAIR_FORMAT, cost)
    end
end

-- Re-index every pass: sold slots empty out, so the fresh scan is the sale confirmation.
local function junkSlots()
    local slots = {}
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local slotItem = C_Container.GetContainerItemInfo(bag, slot)
            if slotItem and slotItem.quality == Enum.ItemQuality.Poor and not slotItem.hasNoValue then
                table.insert(slots, { bag = bag, slot = slot, item = slotItem })
            end
        end
    end
    return slots
end

-- Anything already sitting in a bag is cached, so sellPrice is reliable; fall back to 0 if it ever is not.
local function totalValue(slots)
    local total = 0
    for _, entry in ipairs(slots) do
        local sellPrice = select(11, C_Item.GetItemInfo(entry.item.itemID))
        total = total + (sellPrice or 0) * entry.item.stackCount
    end
    return total
end

-- Report the difference against the opening scan so a stalled run still prints what actually sold.
local function finishSelling(remainingValue)
    selling = false

    local earned = junkValue - remainingValue
    if earned > 0 then
        printMoney(SOLD_FORMAT, earned)
    end
end

local function sellNextBatch(previousCount, stalls)
    if not selling then return end

    local junk = junkSlots()
    if #junk == 0 then
        finishSelling(0)
        return
    end

    -- A pass without progress means lag or rejected sales; retry briefly, then stop instead of spamming.
    if previousCount and #junk >= previousCount then
        stalls = stalls + 1
        if stalls > MAX_STALLS then
            finishSelling(totalValue(junk))
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
    local junk = junkSlots()
    if #junk == 0 then return end

    selling = true
    junkValue = totalValue(junk)
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
