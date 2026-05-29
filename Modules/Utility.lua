local function toggleFrameStack()
    local loader = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn
    loader("Blizzard_DebugTools")
    if FrameStackTooltip_Toggle then
        FrameStackTooltip_Toggle()
    end
end

local function bindRightClick(button, handler)
    if not button then return end
    button:RegisterForClicks("LeftButtonUp")
    button:HookScript("OnMouseUp", function(self, click)
        if click == "RightButton" and self:IsEnabled() and self:IsMouseOver() then
            handler()
        end
    end)
end

bindRightClick(MainMenuMicroButton, ReloadUI)
bindRightClick(HelpMicroButton, toggleFrameStack)
