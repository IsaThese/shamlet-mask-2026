# Shamlet Mask + Pig Aggro Fix

Standalone DST mod that:

1. **Fixes pig aggression** while wearing a Shamlet Mask (`disguisehat`) — config on/off
2. **Provides or patches** the mask so it works alone *or* with Above the Clouds / Tropical Experience / Tropical Adventures / stock Shamlet Mask
3. Loads last among those packs via `priority = -101` (after ATC `-1`, Tropical Experience `-20`, Tropical Adventures `-100`)

## Behavior

| Situation | What this mod does |
|---|---|
| No other mod registers `disguisehat` | Registers own prefab, assets, recipe (`playermonster`), optional starting mask |
| ATC / TE / TA / Shamlet Mask already has `disguisehat` | Does **not** duplicate the prefab; wraps equip/unequip + patches Wortox |
| `FIX_PIG_AGGRO` off | Skips tags, Wortox, TUNING, and KeepTarget patches; mask can still be provided |
| `ALWAYS_DISGUISE_WEBBER_WORTOX` on | Webber/Wortox stay pig-safe with or without a mask |

### Pack-specific disguise gaps (all fixed by our equip wrap)

| Pack | Hat source | Stock equip behavior |
|---|---|---|
| Above the Clouds | `pl_hats.lua` | Strips `monster` + `playermonster`; no owner `disguise` tag |
| Tropical Adventures | `hats_hamlet.lua` | Strips `monster` only (+ merm/spiderwhisperer); no owner `disguise` |
| Tropical Experience | `new_hats.lua` | **Visual equip only** — does not strip `monster` at all |

City pigs in TE/TA retarget on `monster` with a **file-local** range of `20`; the guard retarget config filters against `TUNING.CITY_PIG_GUARD_TARGET_DIST`.

## Config

| Option | Default | Effect |
|---|---|---|
| `PROVIDE_MASK` | on | Register own mask when missing |
| `STARTING_MASK` | on | Give mask to Webber/Wortox and other monster players on first spawn (skipped only if stock Shamlet Mask workshop mod is enabled; not gated on TE/ATC detection) |
| `FIX_PIG_AGGRO` | on | Strip `monster` + `playermonster`, add `disguise` / `notmonster`, restore on unequip; Wortox inclination re-strip. Master switch for guard TUNING / KeepTarget options |
| `CITY_PIG_GUARD_TARGET_DIST` | `17` | Override / filter retarget range (`20` = stock, `0` = unchanged) |
| `CITY_PIG_GUARD_KEEP_TARGET_DIST` | `25` | Override `TUNING.CITY_PIG_GUARD_KEEP_TARGET_DIST` (`32` = ATC, `0` = unchanged) |
| `DISABLE_KEEPTARGET_SHARE` | on | Replace city-pig `KeepTarget` so holding aggro no longer `ShareTarget`s (ATC published fix; TE/TA KeepTarget already omit share) |
| `ALWAYS_DISGUISE_WEBBER_WORTOX` | off | Permanently disguise Webber/Wortox even without a mask; unequip will not restore monster tags |
| `DISGUISE_TOPHAT` | off | Normal Top Hat applies the same pig-safe disguise tags as the Shamlet Mask |
| `DISGUISE_TOPHAT_MAGICIAN` | off | Magician's Top Hat (Maxwell's converted `tophat`) applies the same pig-safe disguise tags |


## Layout

```text
modinfo.lua
modmain.lua
modicon.xml / .tex
startitem.lua
scripts/disguise_aggro.lua
scripts/AlwaysDisguise.lua
scripts/PatchWortox.lua
scripts/PatchCityPigCombat.lua
scripts/prefabs/disguisehat.lua
anim/hat_disguise.zip
images/inventoryimages/hat_disguise.tex / .xml
```

## Install

Copy this folder into your DST `mods` directory (or symlink it), enable it in the mods menu.

Detected providers: `1581485409` (Shamlet Mask), `3322803908` / `3330056551` (ATC), `1505270912` (Tropical Experience), `2986194136` (Tropical Adventures).
