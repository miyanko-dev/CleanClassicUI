# CleanClassicUI

Minimalist UI addon for World of Warcraft Classic Era (1.15.x).

## Features

- Action bars with clean bordered buttons and centered layout
- Bordered bags with stacked containers and one-key toggle
- Right-aligned micro menu along the bottom edge
- LFG button detached from the minimap
- Minimal centered cast bar
- Nameplates with threat coloring
- Color-coded buffs and debuffs anchored near the minimap
- Enlarged minimap with scroll-to-zoom
- Reskinned XP and reputation bars
- Streamlined chat with class-colored names
- Raid frames with class colors and custom textures
- Scaled-down world map that fades while moving
- Tooltips anchored above the bag buttons with item level
- Questie nameplate icon positioning
- Auto-position the player and target frames via the unit frame right-click menu

## Notes

**Auto Position** (right-click the player or target frame → "Auto Position") snaps the
frames to a clean spot near the action bars. WoW saves the placement natively, so it
sticks across sessions. Positioning a protected frame from an addon taints it until the
next reload, so a reload prompt appears — until you reload, interacting with a unit may
log a one-time, harmless "action blocked" error. Reloading clears it.
