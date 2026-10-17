# Shamlet Mask + Pig Aggro Fix

Standalone DST mod that:

1. **Fixes pig aggression** while wearing a Shamlet Mask (`disguisehat`) — config on/off
2. **Provides or patches** the mask so it works alone *or* with Above the Clouds / Tropical Adventures / stock Shamlet Mask
3. Loads **after** ATC (`priority = -2`)

## Behavior

| Situation | What this mod does |
|---|---|
| No other mod registers `disguisehat` | Registers own prefab, assets, recipe (`playermonster`), optional starting mask |
| ATC / TA / Shamlet Mask already has `disguisehat` | Does **not** duplicate the prefab; wraps equip/unequip + patches Wortox |
| `FIX_PIG_AGGRO` off | Skips combat/tag + Wortox patches; mask can still be provided |

## Config

| Option | Default | Effect |
|---|---|---|
| `FIX_PIG_AGGRO` | on | Strip `monster` + `playermonster`, add `disguise` / `notmonster`, restore on unequip; Wortox inclination re-strip |
| `PROVIDE_MASK` | on | Register own mask when missing |
| `STARTING_MASK` | on | Give mask to monster players on first spawn (skipped if stock Shamlet Mask is enabled) |

## Layout

```text
modinfo.lua
modmain.lua
modicon.xml / .tex
startitem.lua
scripts/disguise_aggro.lua
scripts/PatchWortox.lua
scripts/prefabs/disguisehat.lua
anim/hat_disguise.zip
images/inventoryimages/hat_disguise.tex / .xml
```

## Install

Copy this folder into your DST `mods` directory (or symlink it), enable it in the mods menu.

Compatible workshop IDs detected as providers: `1581485409` (Shamlet Mask), `3322803908` / `3330056551` (ATC), `2986194136` (Tropical Adventures).
