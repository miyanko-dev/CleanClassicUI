# Edit Mode Plan — act on Classic Era 1.15.9 launch

Working assumption: 1.15.9 ships Edit Mode matching TBC 2.5.6 behavior on the vanilla
gametype. All platform facts below were verified against `Gethe/wow-ui-source` and
`Ketho/BlizzardInterfaceResources`, branch `classic_anniversary` (2.5.6, interface 20506),
during the July 2026 compatibility audit. Items that depend on vanilla-gametype specifics
are marked **verify at retest**.

Decided: the addon ships its signature arrangement as an **Edit Mode preset layout**
(see ADD cluster). Layout control moves to the user, the addon keeps styling and QoL.

## 1. Verdict: hardcoded action bar positioning is obsolete

Confirmed unnecessary. Edit Mode's classic-gametype system map covers every bar the addon
positions, with per-bar user settings the addon cannot match:

| ActionBars.lua behavior | Edit Mode equivalent (verified in `Blizzard_EditMode/Classic/EditModePresetLayouts.lua`) |
|---|---|
| `placeBars()` fixed stack for bars 1–3 | MainBar / Bar2 / Bar3 systems, free drag + snap grid |
| `placeVerticalBars()` for bars 4–5 | RightBar1 / RightBar2 systems |
| `placePet()` / `placeStance()` | PetActionBar / StanceBar systems |
| `SetScale(0.8)` on bar 3 / pet bar | per-bar IconSize + IconPadding settings |
| `enableBars()` via cvars | cvars `bottomLeftActionBar`/`bottomRightActionBar` are GONE (replaced by bitfield `enableMultiActionBars` + EM visibility settings) |
| `hideChrome()` end caps / art | HideBarArt setting on MainBar |

Fighting it is not viable: bars inherit `EditModeActionBarTemplate`, `Show/Hide/SetShown`
are overridden by `EditModeActionBarMixin`, and EM re-applies saved anchors on every
layout apply and login. `SetUserPlaced`/`ignoreFramePositionManager` idioms are dead.

## 2. Action clusters once the patch is live

### REMOVE — delete outright, Edit Mode replaces it

| What | Why |
|---|---|
| MicroMenu.lua (whole module) | EM MicroMenu system: Orientation, Order, Size settings. |
| LFGButton.lua (whole module) | `LFGMinimapFrame` is gone; queueing surfaces via `QueueStatusButton` under the MicroMenu system. |
| UnitFrames.lua Auto Position + its unit menu item | EM drag with snap grid and per-frame FrameSize replaces it; the addon bar layout it aligned to no longer exists. |
| ActionBars.lua layout half: `placeBars`, `placeVerticalBars`, `placePet`, `placeStance`, `enableBars`, `petStanceBase` plumbing, `CleanClassicExperienceLayout` contract | Covered by EM bar systems (see section 1). The cvars it sets no longer exist. |
| StatusBars.lua positioning/sizing: `positionBars`, `sizeXPBar`, `matchXPBarSize`, the xpRep slot layout contract | EM StatusTrackingBar 1/2 owns placement and Size. |
| CastBar.lua anchoring: `applyAnchor`, `scheduleAnchor`, SetPoint hook, `ignoreFramePositionManager` | EM CastBar system owns position, BarSize, LockToPlayerFrame. |
| Auras.lua layout: `arrangeAuras`, `anchorRow`, BuffFrame anchoring to Minimap | EM AuraFrame owns position, orientation, wrap, direction, icon limit, size, padding. |
| Bags.lua button row: `arrangeBtns`, `lockKeyringSize`, `bagContainer`, `MoveMicroButtons` hook (already guarded off) | EM Bags system: Orientation, Direction, Size, SlotPadding. |
| Minimap.lua size/position: `applyLayout` cluster move + `Minimap:SetSize` (already guarded off) | EM Minimap: Size, HeaderUnderneath, RotateMinimap. |
| Chat.lua `positionChatFrame` for ChatFrame1 (already guarded off) | EM Chat Frame system owns position and size. |

### UPDATE — keep the feature, integrate with the modern client

| What | How |
|---|---|
| Action button styling (from ActionBars.lua) | Rebuild as a ButtonStyles module: borders, hidden normal textures, empty-slot border sync via `ACTIONBAR_SHOWGRID/HIDEGRID`, range/usability dimming. Button globals survive (`ActionButton1..`, `MultiBar*ButtonN`, `StanceButtonN`, `PetActionButtonN`); the old `ActionButton_*` globals are gone, hook the button mixins per object instead. Icon sits under a MaskTexture — **verify at retest** that `SetTexCoord` cropping renders acceptably, else drop the crop. |
| Status bar tooltips (from StatusBars.lua) | Port to the anonymous `StatusTrackingBarManager` bars. Missing XP, rested %, and rep numbers are differentiating info. Texture restyle optional. |
| Cast bar restyle (from CastBar.lua) | Restyle `PlayerCastingBarFrame`: texture, border, height, text truncation. ParentKeys (`Text`, `Border`, `Spark`, `Flash`, `Icon`) survive, but `Flash` also drives the new FlashAnim — hide carefully. |
| Aura styling (from Auras.lua) | Debuff-type colored borders on the pooled anonymous buttons under `BuffFrame.AuraContainer`/`DebuffFrame.AuraContainer` (parentKeys `Icon`, `DebuffBorder`, `Duration`), via per-button `AuraButtonMixin.Update` hooks or a `UNIT_AURA` restyle pass. Do NOT re-anchor `Duration` (fights the grid layout). |
| Bags container behavior | Keep container-window column anchoring (`UpdateContainerFrameAnchors` hook, not an EM system) and bank auto open/close. Optionally style BagsBar buttons in place, no reparenting. |
| Minimap styling | Keep chrome hiding (incl. `MinimapCluster.BorderTop`), clock restyle, draggable edge icons, wheel zoom. `MiniMapTracking` may not exist on the vanilla gametype (`MinimapTracking_Dropdown.xml` is `[ExcludeLoadGameType vanilla]`) — **verify at retest**. |
| Chat styling | Already dual-flavor: texture stripping, tab fonts, editbox relocation, class colors, hyperlink modifier clicks all stay. |
| Styling lifecycle | Make every restyle idempotent and re-apply on `EDIT_MODE_LAYOUTS_UPDATED` (event verified) so it survives layout switches and Edit Mode sessions. |
| `_Vanilla.toc` | Reduce to the `_TBC.toc` module set + the new modules from this plan (guards already make the old list safe, the reduced list is the intended state). Bump interface to the 1.15.9 number (expected 11509). |

### ADD — new features enabled by Edit Mode (decided)

| What | How |
|---|---|
| Edit Mode preset layout (committed) | Recreate the CleanClassicExperience arrangement in Edit Mode on the PTR/live client, export the layout string, embed it in the addon. Delivery: a chat command that prints the string for manual import (zero risk), plus a one-time login offer that creates the layout via `C_EditMode.ConvertStringToLayoutInfo` + `SaveLayouts` (API verified on 2.5.6) — **verify at retest** that this works from insecure addon code without taint, else manual import only. Never auto-activate, offer and let the user click. |
| One-time migration notice | First login after the patch: single chat line explaining layout is now Edit Mode (`/editmode`) and the classic arrangement is available as an import. Gate with a SavedVariables flag. |

### KEEP — unchanged, already verified on the modern client

TimerBars, Items, Framerate, NamePlates, RaidFrames, RollFrames, AutoConfirm,
FasterLoot, FastSellRepair, WorldMap, AddonSupport, Tooltips, Character.

## 3. UX recommendations

- Positioning now belongs to the user. Any addon `SetPoint` on an EM system silently
  reverts on the next layout apply, which users read as "the addon is broken". Remove
  all imposed positioning on EM-managed frames rather than trying to win the fight.
- Preset over mandate. The addon's opinion arrives as an importable layout, not forced
  anchors. Users who liked the old fixed layout get it in one click; everyone else keeps
  full Edit Mode freedom. This converts the addon's biggest source of conflict into a
  feature.
- Keep the zero-config identity. With layout delegated to Edit Mode, the addon needs no
  options panel: Edit Mode IS the layout options panel, the addon is pure styling + QoL
  (auto-loot, auto-confirm, sell/repair, class colors, item level, tooltips).
- Respect combat constraints. Edit Mode cannot be used in combat; the addon keeps its
  existing `InCombatLockdown` discipline for anything it still touches.

## 4. Post-launch checklist (extends the 1.15.9 retest runbook in project memory)

1. Run the retest runbook first (interface number, module symbol re-verification,
   vanilla-gametype deltas).
2. Execute the REMOVE cluster and reduce `_Vanilla.toc`.
3. Execute the UPDATE cluster in order of user-visible value: button styling, status bar
   tooltips, aura border colors, cast bar restyle, then the lifecycle plumbing.
4. Execute the ADD cluster: produce and embed the preset layout string, wire the chat
   command, the one-time offer, and the migration notice.
5. Update README and TOC Notes to describe the new division of labor: Edit Mode owns
   layout, the addon owns styling and QoL.
