local RED = { 0.980, 0.153, 0.184 }
local ORANGE = { 0.984, 0.506, 0.157 }
local YELLOW = { 0.984, 0.820, 0.204 }
local GREEN = { 0.188, 0.996, 0.192 }
local GREY = { 0.5, 0.5, 0.5 }

local EDGE_FILE = "Interface/Tooltips/UI-Tooltip-Border"

local function colorBar(plate, unit)
    local bar = plate.UnitFrame and plate.UnitFrame.healthBar
    if not bar then return end

    local threat = UnitThreatSituation("player", unit)
    if threat and threat >= 2 then
        bar:SetStatusBarColor(unpack(ORANGE))
    elseif UnitIsTapDenied(unit) then
        bar:SetStatusBarColor(unpack(GREY))
    elseif UnitCanAttack("player", unit) then
        local reaction = UnitReaction(unit, "player")
        if reaction and reaction <= 3 then
            bar:SetStatusBarColor(unpack(RED))
        else
            bar:SetStatusBarColor(unpack(YELLOW))
        end
    else
        bar:SetStatusBarColor(unpack(GREEN))
    end
end

local function addBorder(bar, plate)
    if bar.cleanBorder then return end
    local border = CreateFrame("Frame", nil, plate, "BackdropTemplate")
    border:SetPoint("TOPLEFT", bar, "TOPLEFT", -3, 3)
    border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 3, -3)
    border:SetBackdrop({ edgeFile = EDGE_FILE, edgeSize = 12 })
    border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    border:SetFrameStrata("HIGH")
    bar.cleanBorder = border
end

local function stylePlate(plate, unit)
    local uf = plate and plate.UnitFrame
    if not uf then return end

    local bar = uf.healthBar
    bar:SetStatusBarTexture(CleanUI.BAR_TEXTURE)

    if bar.border then bar.border:Hide() end
    if uf.LevelFrame then uf.LevelFrame:Hide() end

    bar:ClearAllPoints()
    bar:SetPoint("CENTER", uf, "CENTER", 0, 8)
    bar:SetWidth(uf:GetWidth())

    addBorder(bar, plate)

    if uf.name then
        uf.name:ClearAllPoints()
        uf.name:SetPoint("BOTTOM", bar, "TOP", 0, 8)
        uf.name:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        uf.name:SetTextColor(1, 1, 1)
    end

    if uf.RaidTargetFrame then
        uf.RaidTargetFrame:ClearAllPoints()
        uf.RaidTargetFrame:SetPoint("LEFT", bar, "RIGHT", 8, 0)
    end

    colorBar(plate, unit)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:SetScript("OnEvent", function(_, event, unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end
    if event == "NAME_PLATE_UNIT_ADDED" then
        stylePlate(plate, unit)
    else
        colorBar(plate, unit)
    end
end)

local cfgFrame = CreateFrame("Frame")
cfgFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
cfgFrame:SetScript("OnEvent", function()
    SetCVar("nameplateMinScale", 0.8)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateMaxScale", 1)
    SetCVar("nameplateOverlapH", 1)
    SetCVar("nameplateOverlapV", 1)
    SetCVar("nameplateMaxDistance", 40)
end)
