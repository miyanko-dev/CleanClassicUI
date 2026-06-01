local C = CleanClassicUI.COLOR

local function colorBar(plate, unit)
    local bar = plate.UnitFrame and plate.UnitFrame.healthBar
    if not bar then return end

    local threat = UnitThreatSituation("player", unit)
    if threat and threat >= 2 then
        bar:SetStatusBarColor(unpack(C.ORANGE))
    elseif UnitIsTapDenied(unit) then
        bar:SetStatusBarColor(unpack(C.GREY))
    elseif UnitCanAttack("player", unit) then
        local reaction = UnitReaction(unit, "player")
        if reaction and reaction <= 3 then
            bar:SetStatusBarColor(unpack(C.RED))
        else
            bar:SetStatusBarColor(unpack(C.YELLOW))
        end
    else
        bar:SetStatusBarColor(unpack(C.GREEN))
    end
end

-- Nameplate border needs HIGH strata, so ApplyBorder can't be reused (inherits parent strata).
local function addBorder(bar, plate)
    if bar.cleanBorder then return end

    local border = CreateFrame("Frame", nil, plate, "BackdropTemplate")
    border:SetPoint("TOPLEFT",     bar, "TOPLEFT",     -CleanClassicUI.BORDER,  CleanClassicUI.BORDER)
    border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT",  CleanClassicUI.BORDER, -CleanClassicUI.BORDER)
    border:SetBackdrop({ edgeFile = CleanClassicUI.EDGE_FILE, edgeSize = 12 })
    border:SetBackdropBorderColor(unpack(C.GREY))
    border:SetFrameStrata("HIGH")
    bar.cleanBorder = border
end

local function stylePlate(plate, unit)
    local uf = plate and plate.UnitFrame
    if not uf then return end

    local bar = uf.healthBar
    bar:SetStatusBarTexture(CleanClassicUI.BAR_TEXTURE)

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

CleanClassicUI.OnEvent(function(_, event, unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end

    if event == "NAME_PLATE_UNIT_ADDED" then
        stylePlate(plate, unit)
    else
        colorBar(plate, unit)
    end
end, "NAME_PLATE_UNIT_ADDED", "UNIT_THREAT_SITUATION_UPDATE", "UNIT_THREAT_LIST_UPDATE")

CleanClassicUI.OnEvent(function()
    SetCVar("nameplateMinScale",      0.8)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateMaxScale",      1)
    SetCVar("nameplateOverlapH",      1)
    SetCVar("nameplateOverlapV",      1)
    SetCVar("nameplateMaxDistance",   40)
end, "PLAYER_ENTERING_WORLD")
