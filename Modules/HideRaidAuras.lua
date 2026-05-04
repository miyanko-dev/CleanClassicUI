if not BentoInterfaceClassicDB then
    BentoInterfaceClassicDB = {}
end

local hideRaidAuras = true  -- hidden by default

-- Suppress buffs and debuffs on every compact unit frame update
local function suppressAuras(frame)
    if hideRaidAuras then
        CompactUnitFrame_HideAllBuffs(frame)
        CompactUnitFrame_HideAllDebuffs(frame)
    end
end

hooksecurefunc("CompactUnitFrame_UpdateAuras", suppressAuras)

-- Apply the custom bar texture to raid frame health/power bars
local function setRaidBarTextures(raidFrame)
    if raidFrame and raidFrame.healthBar then
        raidFrame.healthBar:SetStatusBarTexture(BAR)
    end
    if raidFrame and raidFrame.powerBar then
        raidFrame.powerBar:SetStatusBarTexture(BAR)
    end
end

hooksecurefunc("CompactUnitFrame_UpdateHealth", setRaidBarTextures)
hooksecurefunc("CompactUnitFrame_UpdatePower",  setRaidBarTextures)

-- Force compact frames for party and display class colours without borders
local function applyGroupConfig()
    SetCVar("useCompactPartyFrames",       1)
    SetCVar("raidFramesDisplayClassColor", 1)
    SetCVar("raidFramesDisplayBorder",     0)
end

local groupConfigFrame = CreateFrame("Frame")
groupConfigFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
groupConfigFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupConfigFrame:SetScript("OnEvent", applyGroupConfig)

-- Persist the toggle state across sessions
local function loadSavedState()
    if BentoInterfaceClassicDB.hideRaidAuras ~= nil then
        hideRaidAuras = BentoInterfaceClassicDB.hideRaidAuras
    else
        BentoInterfaceClassicDB.hideRaidAuras = hideRaidAuras
    end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "BentoInterface-Classic" then
        loadSavedState()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Slash command ---------------------------------------------------------------

local function printHelp()
    print(YELLOW_LUA .. "Bento Interface — Hide Raid Auras|r")
    print(WHITE_LUA  .. "Hides all buff and debuff icons on compact raid/party frames.|r")
    print(YELLOW_LUA .. "Commands:|r")
    print("  " .. WHITE_LUA .. "/raidframeauras|r"
                            .. GREY_LUA .. "        — toggle aura visibility|r")
    print("  " .. WHITE_LUA .. "/raidframeauras help|r"
                            .. GREY_LUA .. "   — show this text|r")
    local status = hideRaidAuras
        and (RED_LUA   .. "hidden|r")
        or  (GREEN_LUA .. "shown|r")
    print(WHITE_LUA .. "Current state: |r" .. status)
end

SLASH_RAIDFRAMEAURAS1 = "/raidframeauras"
SlashCmdList["RAIDFRAMEAURAS"] = function(input)
    input = strtrim(input or ""):lower()

    if input == "help" or input == "?" then
        printHelp()
        return
    end

    hideRaidAuras = not hideRaidAuras
    BentoInterfaceClassicDB.hideRaidAuras = hideRaidAuras

    local status = hideRaidAuras
        and (RED_LUA   .. "hidden|r")
        or  (GREEN_LUA .. "shown|r")
    print(YELLOW_LUA .. "[Hide Raid Auras]|r Raid frame auras are now "
          .. status .. ". " .. GREY_LUA .. "(/raidframeauras help)|r")
end
