local function configureQuestie()
    if not C_AddOns.IsAddOnLoaded("Questie") then return end

    Questie.db.profile.nameplateX     = -28
    Questie.db.profile.nameplateY     = 10
    Questie.db.profile.nameplateScale = 1.5
end

CleanClassicUI.OnEvent(configureQuestie, "PLAYER_ENTERING_WORLD")
