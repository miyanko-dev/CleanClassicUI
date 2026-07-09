-- Auto-accept "will be soulbound" warning popups. UIParent registered these
-- events first, so its handler has already shown each popup when ours runs;
-- confirm the action and dismiss the popup.

-- Rolling need or greed on a bind-on-pickup item.
CleanClassicExperience.OnEvent(function(_, _, rollID, rollType)
    ConfirmLootRoll(rollID, rollType)
    StaticPopup_Hide("CONFIRM_LOOT_ROLL", rollID)
end, "CONFIRM_LOOT_ROLL")

-- Looting a bind-on-pickup item directly from a corpse or chest.
CleanClassicExperience.OnEvent(function(_, _, slot)
    ConfirmLootSlot(slot)
    StaticPopup_Hide("LOOT_BIND", slot)
end, "LOOT_BIND_CONFIRM")

-- Using a bind-on-use item.
CleanClassicExperience.OnEvent(function()
    C_Item.ConfirmBindOnUse()
    StaticPopup_Hide("USE_BIND")
end, "USE_BIND_CONFIRM")

-- Selling an item that is still tradeable within its 2-hour group loot window.
CleanClassicExperience.OnEvent(function()
    SellCursorItem()
    StaticPopup_Hide("CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL")
end, "MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
