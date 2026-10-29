# CGM legacy200 presentation patchset

Targets Custom Gimmicks v1.14.2 and vivid/stasis 6.2.2.2. Integrates the former
Legacy Gameplay UI demonstration into CGM, with independent UI, skin, and
background-particle controls. No System Options entry is installed or read.

| Control | Values | Behavior |
| --- | --- | --- |
| `uimode` | `0` modern, `1` legacy200 | Discrete callback; set destination immediately at the event start. Does not select a noteskin or particle mode. |
| `changeskin` | existing 0–3; new `4` legacy200 | Existing skin-change callback. Requires `ENABLE_SKIN_CHANGE: true`. Explicitly selects chip/hold/bumper/timing/mine sprites independently of UI. |
| `bgparticles200` | `0` jacket mask, `1` plain old particles | Discrete callback; bypasses jacket multiplication for background particles. Retains particle alpha and chart controls. Independent of UI and skin. |

A callback uses `val2`, falling back to `val1` when `val2` is `_`. Nonzero
presentation values >=0.5 enable the mode. Duration and easing do not animate
these discrete switches. Retriggering the same value is idempotent. State lives
on the gameplay controller and starts at 0 for every fresh song/restart.
Existing `uialpha`, `bgalph`, `holdoverlayalpha`, `notealp`, special chart
artwork, effects, sprite pivots, SV caches, clipping and per-lane transforms
retain their existing ownership.

```text
!proxies:0
!obj:obj_custom_gimmick
32,0,linear,_,1,uimode,-1
48,0,linear,_,4,changeskin,-1
64,0,linear,_,1,bgparticles200,-1
96,0,linear,_,0,uimode,-1
112,0,linear,_,0,changeskin,-1
128,0,linear,_,0,bgparticles200,-1
```

```json
{"ENABLE_SKIN_CHANGE": true}
```

For GML integration there is `cgm_set_ui_mode("legacy200")`, or `"modern"`,
as well as numeric 1/0. MPF can use the existing `set_mod_val("uimode", 1)` and
`set_mod_val("bgparticles200", 1)` APIs. Direct UI writes are reconciled by the
controller's End Step before drawing. Timeline `uimode` callbacks reconcile
immediately. Skin changes continue to use the existing callback API.

UI switching covers HUD composition/fonts/live score, lane/receptor artwork,
beam depth/opacity/tween state, judgement/combo artwork and active hit feedback.
Room sprite swaps reverse only this patch's stock replacements; graphic IDs,
alpha, alternate frames and layer state remain intact. Already-running hit
rectangles change palette/width/speed without resetting their animation age.
Both hit-particle presentations run from the same native random draws and are
selected at draw time, so switching does not leak old presentation tails or
change the game's RNG stream. Legacy hold bodies use explicit solid geometry
only when skin 4 is selected, even under modern UI.

CGM's Allison overlay blends from the selected base skin and invalidates its
baked sprites after a skin change at unchanged alpha. Its legacy hold colors
come from the real Allison sprite, and its geometry interpolates into the
native hold presentation. Special/generated sprites remain authored effects.

The known old layout limits (including lower lanes stopping at row 164 and
fixed HUD allocation) are retained. This patch does not redesign those limits.


## Source layout

`codes/gml_GlobalScript_cgm_legacy200.gml` provides shared mode queries and the public setter.
`o_cgm_legacy200_ui` owns room-art switching and its End Step reconciliation.
The `_hud`, `_skin`, and `_feedback` scripts contain shared rendering helpers used by multiple base-game events.
CGM-owned skin registration, Allison blending and background-particle code are edited directly in their existing files.
`codepatches.json` contains hooks into base-game HUD, note, beam, judgement and particle events.
Those events are not CGM-owned; replacing them wholesale would discard native behavior and other patches.
The long Find strings locate existing HUD blocks. Their replacement delegates legacy drawing to helpers and preserves the original modern branch.
No new legacy implementation files are placed under `codepatches/`.
