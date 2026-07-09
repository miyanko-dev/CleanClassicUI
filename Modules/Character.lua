local SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }

local ilvlText
local pendingRetry = false

local function createText()
    if ilvlText or not CharacterLevelText then return end
    local parent = CharacterLevelText:GetParent()
    ilvlText = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    ilvlText:SetPoint("TOP", CharacterLevelText, "BOTTOM", 0, -1)

    -- Push guild text below the new line so they don't overlap.
    if CharacterGuildText then
        CharacterGuildText:ClearAllPoints()
        CharacterGuildText:SetPoint("TOP", ilvlText, "BOTTOM", 0, -1)
    end
end

local function shiftLevelText()
    if not CharacterLevelText or not CharacterNameText then return end
    CharacterLevelText:ClearAllPoints()
    CharacterLevelText:SetPoint("TOP", CharacterNameText, "BOTTOM", 0, -8)
end

local function computeAverage()
    local total, count = 0, 0
    local hasPending = false

    for _, slot in ipairs(SLOTS) do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local _, _, _, ilvl = GetItemInfo(link)
            if ilvl then
                total = total + ilvl
                count = count + 1
            else
                hasPending = true
            end
        end
    end

    if count == 0 then return nil, hasPending end
    return total / count, hasPending
end

local function updateText()
    if not ilvlText then return end
    local avg, hasPending = computeAverage()
    if avg then
        ilvlText:SetFormattedText("Item Level: %.0f", avg)
        ilvlText:Show()
    else
        ilvlText:Hide()
    end
    pendingRetry = hasPending
end

CleanClassicExperience.OnEvent(function(_, event)
    if event == "PLAYER_LOGIN" then
        createText()
        shiftLevelText()
        updateText()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        updateText()
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        if pendingRetry then updateText() end
    end
end, "PLAYER_LOGIN", "PLAYER_EQUIPMENT_CHANGED", "GET_ITEM_INFO_RECEIVED")
