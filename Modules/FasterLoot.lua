-- Loot everything instantly while keeping the loot window hidden, modeled on
-- SpeedyAutoLoot. Blizzard's LootFrame shows itself on LOOT_OPENED, so it is
-- parented to an always-hidden host; it is only brought back when auto-loot
-- is off for this corpse or an item cannot be looted (locked, above the group
-- roll threshold, or bags are full). AutoConfirm.lua covers the bind popups.

local LOOT_INTERVAL  = 0.033
local NO_ROLL        = 10
local KEYRING_FAMILY = 256

local hiddenHost = CreateFrame("Frame", nil, UIParent)
hiddenHost:Hide()

local isLooting     = false
local autoLooting   = false
local lootFailed    = false
local frameShown    = false
local rollThreshold = NO_ROLL
local lastNumItems
local ticker
local lootedSlots = {}

-- An item fits if the keyring takes it, a partial stack absorbs it, or a
-- compatible bag has a free slot.
local function itemFits(itemLink, quantity)
    local stackSize = select(8, C_Item.GetItemInfo(itemLink))
    local itemFamily = C_Item.GetItemFamily(itemLink)

    if itemFamily == KEYRING_FAMILY
        and C_Container.GetContainerNumFreeSlots(Enum.BagIndex.Keyring) > 0 then
        return true
    end

    local owned = C_Item.GetItemCount(itemLink)
    if owned > 0 and stackSize and stackSize > 1
        and ((stackSize - owned) % stackSize) >= quantity then
        return true
    end

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(bag)
        if freeSlots > 0
            and (not bagFamily or bagFamily == 0
                or (itemFamily and bit.band(itemFamily, bagFamily) > 0)) then
            return true
        end
    end

    return false
end

local function tryLootSlot(slot)
    local slotType = GetLootSlotType(slot)
    if slotType == Enum.LootSlotType.None then return true end

    local quantity, _, quality, locked = select(3, GetLootSlotInfo(slot))
    if locked or (quality and quality >= rollThreshold) then return false end

    if slotType ~= Enum.LootSlotType.Item or itemFits(GetLootSlotLink(slot), quantity) then
        LootSlot(slot)
        lootedSlots[slot] = true
        return true
    end

    return false
end

local function showLootFrame()
    frameShown = true
    if not LootFrame:IsEventRegistered("LOOT_OPENED") then return end

    LootFrame:SetParent(UIParent)
    LootFrame:SetFrameStrata("HIGH")
    LootFrame:ClearAllPoints()

    if C_CVar.GetCVarBool("lootUnderMouse") then
        local x, y = GetCursorPosition()
        local scale = LootFrame:GetEffectiveScale()
        LootFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale - 40, y / scale + 20)
    else
        LootFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -125)
    end

    LootFrame:Raise()
end

-- Items at or above the group roll threshold would pop a roll dialog, so they
-- are left to the visible frame.
local function updateRollThreshold()
    local method = C_PartyInfo.GetLootMethod()
    local rollLoot = method == Enum.LootMethod.Group
        or method == Enum.LootMethod.Needbeforegreed
        or method == Enum.LootMethod.Masterlooter
    rollThreshold = (IsInGroup() and rollLoot) and GetLootThreshold() or NO_ROLL
end

-- Loot from the last slot down, one slot per tick; instant lists trip the
-- server's loot throttle.
local function lootAllSlots(numItems)
    if ticker then ticker:Cancel() end
    updateRollThreshold()

    local slot = numItems
    ticker = C_Timer.NewTicker(LOOT_INTERVAL, function()
        if slot >= 1 then
            if not tryLootSlot(slot) then lootFailed = true end
            slot = slot - 1
        else
            ticker:Cancel()
            if lootFailed then showLootFrame() end
        end
    end, numItems + 1)
end

local function onLootOpened(autoLoot)
    isLooting = true

    -- The first event of a loot session decides auto vs manual; repeated
    -- LOOT_READY spam from fast clicking can carry a flipped flag.
    if lastNumItems == nil then
        autoLooting = autoLoot
            or C_CVar.GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE")
    end

    local numItems = GetNumLootItems()
    if numItems == 0 or numItems == lastNumItems then return end
    lastNumItems = numItems

    if autoLooting then
        lootAllSlots(numItems)
    else
        showLootFrame()
    end
end

local function onLootClosed()
    isLooting = false
    autoLooting = false
    lootFailed = false
    frameShown = false
    lastNumItems = nil
    if ticker then ticker:Cancel() end
    wipe(lootedSlots)

    if LootFrame:IsEventRegistered("LOOT_OPENED") then
        LootFrame:SetParent(hiddenHost)
    end
end

-- Classic era can leave a looted stack sitting in its slot; loot it again
-- when the server reports the slot changed.
local function onSlotChanged(slot)
    if isLooting and lootedSlots[slot] and LootSlotHasItem(slot) then
        tryLootSlot(slot)
    end
end

local SHOW_FRAME_ERRORS = { ERR_INV_FULL, ERR_ITEM_MAX_COUNT, ERR_LOOT_ROLL_PENDING }

local function onErrorMessage(_, message)
    if isLooting and not frameShown and tContains(SHOW_FRAME_ERRORS, message) then
        showLootFrame()
    end
end

CleanClassicExperience.OnEvent(function(_, event, ...)
    if event == "LOOT_READY" or event == "LOOT_OPENED" then
        onLootOpened(...)
    elseif event == "LOOT_CLOSED" then
        onLootClosed()
    elseif event == "LOOT_SLOT_CHANGED" then
        onSlotChanged(...)
    elseif event == "UI_ERROR_MESSAGE" then
        onErrorMessage(...)
    end
end, "LOOT_READY", "LOOT_OPENED", "LOOT_CLOSED", "LOOT_SLOT_CHANGED", "UI_ERROR_MESSAGE")

-- Take the frame captive from the start so the first loot never flickers.
if LootFrame:IsEventRegistered("LOOT_OPENED") then
    LootFrame:SetParent(hiddenHost)
end
