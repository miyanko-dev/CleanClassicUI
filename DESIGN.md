# Exchange — Checkout Design System

> Reverse-engineered from the Figma frame **Shop / Checkout — Step 1 (Filled)**
> (`Exchange`, node `16:8450`). Mobile-first, iOS, 375 pt viewport.
> Every value below is sourced from the file's Figma variables — use the token, not the raw hex.

---

## 0. Environment note (font substitution)

The brand font **Vorwerk** is referenced by every text layer in the source file but is **not installed in the Figma plugin runtime**, so new/edited text cannot be set in Vorwerk. All frames generated for **A.09** therefore use **Inter** as a 1:1 stand-in (weights map: Regular→Regular, Medium→Medium, H6/headings 600→Semi Bold, Bold→Bold). Inter is a near-identical humanist sans; swap back to Vorwerk on handoff. Real design-system component instances (Nav Bar, Text Field, Button, Banner, Checkbox, Radio, Divider, Step head) are reused from the library — their internal text was re-set to Inter only so it could be relabeled.

---

## 1. Brand & platform

- **Product**: Vorwerk online shop checkout (single-page, multi-step accordion).
- **Platform**: native iOS, portrait. Base frame **375 × var** pt with the iOS status bar (`Safe Area/Top = 59`) and home indicator.
- **Voice**: calm, reassuring, transactional. Plain sentences, sentence case, no marketing fluff inside the flow.

---

## 2. Color tokens

Reference tokens by name; never hard-code hex in components.

### Content (text / icons)
| Token | Hex | Use |
|---|---|---|
| `Content/contentPrimary` | `#23282A` | Headings, primary body, filled input text |
| `Content/contentSecondary` | `#3F4447` | Secondary body, helper labels |
| `Content/contentTertiary` | `#6C7175` | Captions, "incl. VAT", hints, placeholder support |
| `Content/contentDisabledSubtle` | `#919394` | Disabled text, placeholder |
| `Content/contentAccent` | `#00AC46` | Active/selected accent text & icons |
| `Content/contentOnColorPrimary` | `#FFFFFF` | Text on accent/dark surfaces |
| `Native iOS/contentBlack` | `#000000` | iOS status-bar glyphs only |

### Background
| Token | Hex | Use |
|---|---|---|
| `Background/backgroundPrimary` | `#FFFFFF` | Page & card surface |
| `Background/backgroundSecondary` | `#F3F5F3` | Inset blocks (address search), subtle fills |
| `Background/backgroundAccent` | `#00AC46` | Primary button, selected control fill |
| `Background/backgroundBoldFifth` | `#23282A` | Numbered step badge (active) |
| `Background/backgroundInformationSubtlest` | `#E9F3FE` | Info banner fill |
| `Background/backgroundBlack7` | `#00000012` | Hover/press overlay |
| `Background/backgroundBlack20` | `#00000033` | Scrim |
| `Background/backgroundAlwaysWhite` | `#FFFFFF` | Surfaces that never invert |

### Border
| Token | Hex | Use |
|---|---|---|
| `Border/borderDefault` | `#919394` | Input outline (rest) |
| `Border/borderDefaultSubtle` | `#DCDFDC` | Dividers, section separators |
| `Border/borderAccent` | `#00AC46` | Selected radio/checkbox/input focus |
| `Border/borderInformationSubtler` | `#9EC4EE` | Info banner outline |
| `Border/borderBlack7` | `#00000012` | Hairline on light fills |

### New tokens introduced for A.09 (not in source — define on handoff)
| Token | Hex | Use |
|---|---|---|
| `Content/contentError` / `Border/borderError` | `#D92D20` | Inline error text & destructive validation (email-conflict message) |
| `Background/backgroundErrorSubtlest` | `#FDECEB` | Error/empty-state icon circle fill |
| `Background/backgroundAccentSubtle` | `#F2FBF6` / `#EAF7EF` | Autofilled/selected field & card tint |
| `Background/backgroundWarningSubtle` + `Border/borderWarning` | `#FFF4E5` / `#E8A33D` | Diff-highlight (changed-value) treatment |

> The `Online` / `Offline` / `Syncing` connectivity colors reuse `contentAccent`, `contentTertiary`, and `borderInformationSubtler` respectively.

---

## 3. Typography

- **Family**: `Vorwerk` for both body (`Family/body`) and titles (`Family/title`).
- **Weights**: Regular (400), Medium (600), Bold.

| Style | Family | Size | Line-height | Weight | Use |
|---|---|---|---|---|---|
| H4 | title | 16 | 26 | Medium | (h4 line-height token) |
| **H6 Medium** | body | 16 | 20 | 600 | Step titles, section headings |
| H5 | body | — | 22 | Bold | Sub-section emphasis |
| **P16** | body | 16 | 26 | Regular | Default body, input values |
| **P14 Regular** | body | 14 | 22 | Regular | Helper / paragraph text |
| P14 (p16c-aligned) | body | 14 | 20 | Regular | Compact captions |
| P12 | body | 12 | 20 | Regular | Field labels, fine print |
| iOS Nav Title (inline) | title | 17 | 22 | Regular | Navigation-bar title |

Rules: section headings = **H6 Medium**; field labels = **P12** `contentSecondary`; body/values = **P16**; legal/VAT = **P14/P12** `contentTertiary`. Required fields append ` *`.

---

## 4. Spacing, radius, hairline

- **Spacing scale** (px): `0.25s=2`, `0.5s=4`, `0.75s=6`, `1s=8`, `1.5s=12`, `2s=16`.
- **Page gutter**: 16 (`2s`) left/right.
- **Field → label gap**: 8 (`1s`); **label → input**: ~8; **field row gap**: 12–16.
- **Section gap**: 24–32 between titled groups.
- **Radius**: `0.5r=4` (chips, small), `r=8` (inputs, buttons, banners, cards).
- **Hairline**: `0.33` px dividers; standard divider 1 px `borderDefaultSubtle`.
- **Touch target**: minimum 44 × 44 (icons sit in 48 × 48 wrappers).
- **Icon size**: 16 (XS), 24 (default), nav 24.

---

## 5. Layout — checkout page

Top → bottom, all within the 375 pt frame:

1. **iOS status bar** (44 pt) — system.
2. **Navigation bar** (`Navigation Bar/iPhone`, 103 pt incl. safe area): leading `‹ Cart`, centered title `Check out`.
3. **Order summary bar** (`Basket`, 56 pt): cart icon + "Your order" (H6) · right-aligned total `1.549,00 €` (Bold) with `incl. VAT, free shipping` (P12 tertiary) · expand chevron.
4. **Step accordion** (16 pt gutter):
   - **Step 1 — Contact & delivery** (active, expanded).
   - **Step 2 — Payment** (collapsed, head only).
   - **Step 3 — Sign & submit** (collapsed, head only).
5. **Home indicator** (system).

**Step head**: numbered badge (24–28 px circle) + title (H6 Medium). Active badge = `backgroundBoldFifth` fill, white numeral; inactive = outline `borderDefaultSubtle`, tertiary numeral. A 1 px divider closes each collapsed step.

---

## 6. Components

All components are Auto Layout, full-width (343 pt content = 375 − 2×16) unless noted.

### Text Field (`Text Field` / `.base Text field`)
- Structure: **Label** (P12, `contentSecondary`, optional ` *`) → **container** (48 pt) → optional **supportingText** (20 pt).
- Container: white fill, 1 px `borderDefault`, radius `r=8`, inner padding 16 horizontal; value P16 `contentPrimary`.
- Trailing **clear** icon (`close-circle-filled`, 24, tertiary) when filled.
- States: rest (`borderDefault`) · focus (`borderAccent`, 2 px) · filled · error (red border + `error-circle-filled` + supporting text) · disabled (`contentDisabledSubtle`).
- Variants seen: half-width pairs (ZIP/City 106+225, Street/Number 225+106), full-width, multiline (100–128 pt).

### Combo box / Dropdown (`Combo box`)
- Text field with trailing `caret-down` (24). Title & Salutation use this. Opens `Dropdown menu` overlay (274 pt) — list rows, selected row marked accent.

### Phone field (`.base Phone field`)
- Left **country block** (105 pt): flag (24×16) + dial code (`+49`, P16) + `caret-down`. Right input shares the same outlined container; one combined border.

### Radio button group (`Radio button group`)
- Horizontal options; circle 24, selected = `borderAccent` ring + `backgroundAccent` dot. Used for Salutation (Mrs / Mr / Customer) and delivery timing.

### Advanced Radio button (`Advanced Radio button`)
- Radio + leading brand logo (e.g. DHL) + label, full-width row (54 pt). Used for delivery method.

### Checkbox (`Checkbox` / `.base_checkbox`)
- Box 24, radius `0.5r=4`; checked = `backgroundAccent` + white check. Label P16 wrapping to two lines. Used for "Customer is business client", "billing same as delivery", consents.

### Chip Toggle (`Chip Toggle`)
- Pill, radius `0.5r`/`r`, 36 pt tall, auto-width, wraps to rows. Rest = outline `borderDefaultSubtle`; selected = `borderAccent` + accent text/subtle fill.

### Slider (`Slider`)
- 4 px track `borderDefaultSubtle`, filled portion `backgroundAccent`, 24 px circular handle, tick marks, min/max scale labels (P12) + supporting text.

### Banner (`Banner`)
- Info: `backgroundInformationSubtlest` fill, `borderInformationSubtler` outline, radius `r`, padding 16. Title (H6/bold) + body (P14). Example: "Receive Delivery Notifications".

### Address search (`Address search`)
- Inset block (`backgroundSecondary`, radius `r`): search field with leading `search` icon + placeholder "Start typing the address here", followed by an "or enter it manually" labeled **Separator** (divider–label–divider) before manual fields.

### Button (`Button`)
- **Primary**: full-width, 48 pt, `backgroundAccent` fill, white H6 label, radius `r`. ("Continue to payment").
- **Secondary / icon**: outline or square icon button (e.g. 36 × 36 edit/remove).
- States: rest · hover (`backgroundBlack7` overlay) · pressed · disabled (muted) · loading (spinner, label hidden).

### Divider (`Divider`)
- 1 px `borderDefaultSubtle`, full-width, closes sections/steps.

### Step head (`Step head`)
- 40 pt: numbered badge + title; active vs inactive per §5.

---

## 7. Business logic & flow

Three-step single-page checkout; only one step expanded at a time.

**Step 1 — Contact & delivery**
- Top note: "Please note that we only deliver our products within {Country}" + "Fields marked with * are required."
- **For whom are you ordering?** — "Order for" selector chip (current contact) with clear (×); supports choosing/clearing the contact.
- **Email address** (required) + info banner recommending email for delivery notifications.
- **Where should we send the order?** — Salutation (radio, required) · Title (optional dropdown) · First name * · Last name * · "Customer is business client" checkbox.
- **Address**: customer-address search OR manual entry (ZIP*, City*, Street*, Number*, District*, additional info, Phone, Mobile*).
- **Invoice address**: checkbox "The billing address is the same as the delivery address" (default checked; unchecking reveals separate billing fields).
- **Delivery method**: advanced radio (e.g. "Free DHL home delivery").
- **Delivery timing**: radio — "As soon as possible (within 3–5 working days)" / "Later (select delivery week)".
- Primary CTA **Continue to payment** → validates required fields, then collapses Step 1 and expands Step 2.

**Step 2 — Payment**: collapsed until reached.
**Step 3 — Sign & submit**: collapsed until reached; final order placement (overview list shows consents + signature line "Marta Schmidt, 05.04.2026").

**Validation**: inline, on blur and on CTA; error border + icon + message under the field; CTA disabled or scrolls to first error.

---

## 8. States to design (per component)

rest · hover · focus · selected/checked · filled · disabled · loading · empty · error. Provide error and focus for inputs; checked/selected for radio/checkbox/chip; loading for the primary CTA.

---

## 9. Accessibility

- Body ≥ 14 pt, labels 12 pt minimum; primary text `#23282A` on white ≈ 13:1.
- Accent green `#00AC46` is for fills/selection, not for small text on white (≈ 2.8:1) — pair with `contentPrimary` text.
- Every input has a persistent visible label (not placeholder-only).
- Touch targets ≥ 44 pt; focus ring uses `borderAccent` 2 px.
- Required marked with `*` and stated up front; errors are text + icon, not color alone.

---

## 10. Assumptions (note where the source was silent)

- `{Country}` and the order total are placeholders/sample data.
- Step 2 (Payment) and Step 3 (Sign & submit) content is inferred from step heads + the overview catalog; their full layouts are not in the source filled screen.
- Hover states are documented for completeness though the target is touch-first iOS.
- Color hex values mirror the current Figma variables; treat the **token name** as canonical if values drift.

---

## 11. Net-new components built for A.09 (Business Partner Duplicate Check)

Created as **local components/variant sets** in the Figma file (reuse via instances; promote to the shared library on handoff). All use the tokens above.

- **Connectivity Badge** — variant set `State = Offline / Online / Syncing`. Pill, radius `r=8`, 8px status dot + P12 Medium label. Offline = `bgSecondary`/`contentTertiary`; Online = accent tint + `contentAccent`; Syncing = `backgroundInformationSubtlest` + info dot. Sits top-right of the nav bar.
- **BP Record Row** — compact list item: name (P16 Semi Bold), phone (P14), email (P14 `contentSecondary`). Named text layers `name` / `phone` / `email`.
- **Action Button Pair** — two equal-width buttons (gap `1s`): outline "Create new entry" + primary action ("Use this record" / "Select & overwrite" / "Keep & overwrite").
- **Duplicate Suggestion Card** — variant set `State = Default / Selected / Disabled`. Record Row + Action Button Pair in a 16-padded card (radius `r`). Selected = `borderAccent` 2px + accent tint; Disabled = greyed "Create new entry" + `contentError` conflict message.
- **Push Notification** — iOS notification card (radius 20, drop shadow): app icon + app name + "now" + `title` + `body`. Reused for success / info / action-required (icon tint amber for action-required).
- **Diff Highlight Field** — label + value box on `backgroundWarningSubtle` with `borderWarning` and a "Changed" tag, plus the prior value ("Existing record: …"). Shows which fields differ between the advisor's entry and an existing record.

### Composed patterns (built from primitives + tokens; document for extraction)
- **Bottom Sheet** — top-radius 20, upward drop shadow, drag handle (36×4), over a 20% scrim. Used in 2c.
- **Centered Modal / Dialog** — radius 16, 45% scrim, header + divider + scrollable matches + divider + Cancel footer. Used in 4d.
- **Loading overlay** — 40% scrim + centered card (radius 14) with arc spinner + label. Used in 4a.
- **Inline loader** — 16px arc spinner + P12 label directly under the triggering field. Used in 2a.
- **Toast / Snackbar** — `backgroundBoldFifth` bar, white P14 Medium + leading glyph, 16px from edges, 24px above home indicator. Used in 4b/4c.
- **Status banner** — full-width `backgroundInformationSubtlest` bar with spinner + label ("Syncing… 1 contact pending"). Used in 3b.
- **Confirmation / Empty-error state** — 72px tinted icon circle + title (20 Semi Bold) + centered body + primary (+ secondary) button. Used in 3a / 6b.

## 12. A.09 frame inventory (in the Figma file, beside the source)

`BP Input Form Base` ×2 (Offline/Online) · `2a` Loading · `2b` No-match · `2c` Partial-match sheet · `2d` Autofill · `3a` Save confirmation · `3b` Syncing list · `3c/3d/3e` Push (lock-screen) · `3f` Resolution · `4a` Loading overlay · `4b` Success toast · `4c` Full-dup toast · `4d` Partial-dup modal · `5a` Edit re-check · `6a` Email-conflict close-up · `6b` Network error. Each frame has an annotation card (Trigger / Sync mode / Data source / Exit paths); a **Prototype Flow & Handoff** frame documents all connections.
