# CleanClassicExperience

Minimalist UI addon for World of Warcraft Classic Era (1.15.x).

## Features

- Action bars with clean bordered buttons and centered layout
- XP and reputation bars docked at the bottom below the action bars
- Minimal centered cast bar
- Restyled mirror timers (breath, fatigue)
- Bordered bags with stacked containers and one-key toggle
- Quality-colored item borders on bag and character slots
- Average item level on the character panel
- Item level in item tooltips
- Tooltips anchored to a fixed screen position
- Right-aligned micro menu along the bottom edge
- LFG button detached from the minimap
- Enlarged minimap with scroll-to-zoom
- FPS readout pinned to the top-left corner
- Nameplates with threat coloring
- Color-coded buffs and debuffs anchored near the minimap
- Streamlined chat with class-colored names
- Click shortcuts on player names: Ctrl for a whisper tab, Alt/Cmd to invite or add friend
- Shift-click a chat tab to scroll it to the newest message
- Raid frames with class colors and custom textures
- Free-draggable loot roll frames with saved position
- Auto-accept for soulbound loot, bind-on-use, and trade-timer popups
- Instant looting with the loot window hidden unless something can't be looted
- Auto repair and grey item selling at vendors
- Scaled-down centered world map with mouse-wheel zoom that fades while moving
- Questie nameplate icon positioning
- Auto-position the player and target frames via the unit frame right-click menu

## Notes

**Auto Position** (right-click the player or target frame → "Auto Position") snaps the
frames to a clean spot near the action bars. WoW saves the placement natively, so it
sticks across sessions. Positioning a protected frame from an addon taints it until the
next reload, so a reload prompt appears — until you reload, interacting with a unit may
log a one-time, harmless "action blocked" error. Reloading clears it.
