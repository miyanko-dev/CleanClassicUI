local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    MinimapCluster:SetScale(1.1)
    MinimapCluster:ClearAllPoints()
    MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)

    if GameTimeFrame then GameTimeFrame:Hide() end
    if MinimapZoneTextButton then MinimapZoneTextButton:Hide() end
    if MinimapToggleButton then MinimapToggleButton:Hide() end
    if MinimapCompassTexture then MinimapCompassTexture:Hide() end
    if MinimapBorderTop then MinimapBorderTop:Hide() end
    if MinimapZoomIn then MinimapZoomIn:Hide() end
    if MinimapZoomOut then MinimapZoomOut:Hide() end

    Minimap:EnableMouseWheel(true)
    Minimap:SetScript("OnMouseWheel", function(_, delta)
        if delta > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
    end)
end)
