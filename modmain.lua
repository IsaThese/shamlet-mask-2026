--[[
  Shamlet Mask + Pig Aggro Fix

  - Provides disguisehat when missing (standalone).
  - Patches equip/unequip + Wortox when disguisehat already exists (ATC / TE / TA / Shamlet Mask).
  - Never blindly PrefabFiles = { "disguisehat" } alongside those mods.
]]

local FIX_PIG_AGGRO = GetModConfigData("FIX_PIG_AGGRO")
local PROVIDE_MASK = GetModConfigData("PROVIDE_MASK")
local STARTING_MASK = GetModConfigData("STARTING_MASK")
local GUARD_TARGET_DIST = GetModConfigData("CITY_PIG_GUARD_TARGET_DIST")
local GUARD_KEEP_TARGET_DIST = GetModConfigData("CITY_PIG_GUARD_KEEP_TARGET_DIST")
local DISABLE_KEEPTARGET_SHARE = GetModConfigData("DISABLE_KEEPTARGET_SHARE")
local ALWAYS_DISGUISE_WEBBER_WORTOX = GetModConfigData("ALWAYS_DISGUISE_WEBBER_WORTOX")
local DISGUISE_TOPHAT = GetModConfigData("DISGUISE_TOPHAT")
local DISGUISE_TOPHAT_MAGICIAN = GetModConfigData("DISGUISE_TOPHAT_MAGICIAN")

-- Mods known to register disguisehat (workshop IDs and common local folder names).
local DISGUISEHAT_PROVIDERS = {
    "workshop-1581485409", -- Shamlet Mask [DST]
    "workshop-3322803908", -- Above the Clouds
    "workshop-3330056551", -- Above The Clouds - Strange New Powers
    "workshop-2986194136", -- Tropical Adventures
    "workshop-1505270912", -- Tropical Experience | SW HAM Biomes
}

local DISGUISEHAT_FOLDER_HINTS = {
    "1581485409",
    "3322803908",
    "3330056551",
    "2986194136",
    "1505270912",
    "shamlet",
    "above the clouds",
    "above_the_clouds",
    "porklandbugfixing",
    "tropical adventures",
    "tropical_adventures",
    "tropicaladventures",
    "ship of theseus",
    "ship_of_theseus",
    "tropical experience",
    "tropical_experience",
    "tropicalexperience",
    "from beyond",
}

local OUR_MODNAME = modname -- folder name injected by the mod loader

local function ModNameMatchesProvider(name)
    if name == nil then
        return false
    end
    local lower = string.lower(name)
    for _, id in ipairs(DISGUISEHAT_PROVIDERS) do
        if name == id or lower == string.lower(id) then
            return true
        end
    end
    for _, hint in ipairs(DISGUISEHAT_FOLDER_HINTS) do
        if lower:find(hint, 1, true) then
            return true
        end
    end
    return false
end

local function GetEnabledModNames()
    local names = {}
    local index = GLOBAL.KnownModIndex
    if index == nil then
        return names
    end

    if index.GetModsToLoad ~= nil then
        local list = index:GetModsToLoad(true)
        if list ~= nil then
            for _, name in ipairs(list) do
                names[#names + 1] = name
            end
        end
    end

    if #names == 0 and index.GetServerModNames ~= nil then
        local list = index:GetServerModNames()
        if list ~= nil then
            for _, name in ipairs(list) do
                if index:IsModEnabled(name) then
                    names[#names + 1] = name
                end
            end
        end
    end

    return names
end

local function FindDisguiseHatProvider()
    for _, name in ipairs(GetEnabledModNames()) do
        if name ~= OUR_MODNAME and ModNameMatchesProvider(name) then
            return name
        end
    end
    return nil
end

local function PrefabAlreadyExists(name)
    return GLOBAL.Prefabs ~= nil and GLOBAL.Prefabs[name] ~= nil
end

local other_provider = FindDisguiseHatProvider()
local disguisehat_known = PrefabAlreadyExists("disguisehat")
local should_provide = PROVIDE_MASK and other_provider == nil and not disguisehat_known

print(string.format(
    "[Shamlet Mask 2026] FIX_PIG_AGGRO=%s PROVIDE_MASK=%s STARTING_MASK=%s | target_dist=%s keep_dist=%s no_share=%s always_disguise=%s disguise_tophat=%s disguise_magician_tophat=%s | other_provider=%s prefab_known=%s => provide_own=%s",
    tostring(FIX_PIG_AGGRO),
    tostring(PROVIDE_MASK),
    tostring(STARTING_MASK),
    tostring(GUARD_TARGET_DIST),
    tostring(GUARD_KEEP_TARGET_DIST),
    tostring(DISABLE_KEEPTARGET_SHARE),
    tostring(ALWAYS_DISGUISE_WEBBER_WORTOX),
    tostring(DISGUISE_TOPHAT),
    tostring(DISGUISE_TOPHAT_MAGICIAN),
    tostring(other_provider),
    tostring(disguisehat_known),
    tostring(should_provide)
))

--------------------------------------------------------------------------
-- Own mask: assets, prefab, recipe, strings
--------------------------------------------------------------------------

if should_provide then
    PrefabFiles = { "disguisehat" }

    Assets = {
        Asset("ATLAS", "images/inventoryimages/hat_disguise.xml"),
        Asset("IMAGE", "images/inventoryimages/hat_disguise.tex"),
    }

    local STRINGS = GLOBAL.STRINGS
    STRINGS.NAMES.DISGUISEHAT = "Shamlet Mask"
    STRINGS.RECIPE_DESC.DISGUISEHAT = "A fresh face."
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.DISGUISEHAT = "For swindling a swine."
    STRINGS.CHARACTERS.WILLOW.DESCRIBE.DISGUISEHAT = "Who would fall for that disguise?"
    STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DISGUISEHAT = "Hehe. Is funny little pig mask."
    STRINGS.CHARACTERS.WENDY.DESCRIBE.DISGUISEHAT = "Full of deception."
    STRINGS.CHARACTERS.WX78.DESCRIBE.DISGUISEHAT = "FACIAL ENCRYPTION"
    STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DISGUISEHAT = "Clever."
    STRINGS.CHARACTERS.WOODIE.DESCRIBE.DISGUISEHAT = "Hehe. It's like a halloween mask."
    STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DISGUISEHAT = "Doesn't fool me."
    STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DISGUISEHAT = "One of Loki's tricks."
    STRINGS.CHARACTERS.WEBBER.DESCRIBE.DISGUISEHAT = "I bet we can fool those pigs with this!"
    STRINGS.CHARACTERS.WINONA.DESCRIBE.DISGUISEHAT = "A pig face."

    -- ATC-style: craftable by playermonster (Webber, Wortox-as-monster, etc.).
    AddRecipe2(
        "disguisehat",
        {
            Ingredient("twigs", 2),
            Ingredient("pigskin", 1),
            Ingredient("beardhair", 1),
        },
        TECH.NONE,
        {
            atlas = "images/inventoryimages/hat_disguise.xml",
            image = "hat_disguise.tex",
            builder_tag = "playermonster",
        },
        { "CHARACTER", "CLOTHING" }
    )
end

--------------------------------------------------------------------------
-- Always disguise Webber / Wortox (no mask required)
--------------------------------------------------------------------------

local disguise_aggro = nil
if FIX_PIG_AGGRO or ALWAYS_DISGUISE_WEBBER_WORTOX or DISGUISE_TOPHAT or DISGUISE_TOPHAT_MAGICIAN then
    disguise_aggro = GLOBAL.require("disguise_aggro")
end

if ALWAYS_DISGUISE_WEBBER_WORTOX then
    disguise_aggro.SetAlwaysDisguiseEnabled(true)

    local always_disguise = GLOBAL.require("AlwaysDisguise")
    local function ApplyAlwaysDisguise(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        always_disguise.Apply(inst)
    end
    AddPrefabPostInit("webber", ApplyAlwaysDisguise)
    AddPrefabPostInit("wortox", ApplyAlwaysDisguise)
end

--------------------------------------------------------------------------
-- Aggression fix: disguise tags, Wortox, TUNING ranges, KeepTarget share
--------------------------------------------------------------------------

-- Wrap mask whenever tags matter (normal fix, or always-disguise unequip protection).
if FIX_PIG_AGGRO or ALWAYS_DISGUISE_WEBBER_WORTOX then
    AddPrefabPostInit("disguisehat", function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        disguise_aggro.WrapEquippable(inst)
    end)
end

-- Top Hat + Magician's Top Hat share prefab "tophat"; Magician is a converted state.
if DISGUISE_TOPHAT or DISGUISE_TOPHAT_MAGICIAN then
    AddPrefabPostInit("tophat", function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        disguise_aggro.WrapTophat(inst, {
            normal = DISGUISE_TOPHAT,
            magician = DISGUISE_TOPHAT_MAGICIAN,
        })
    end)
end

if FIX_PIG_AGGRO then
    -- Skip weak PatchWortox when AlwaysDisguise already owns Wortox inclination.
    if not ALWAYS_DISGUISE_WEBBER_WORTOX then
        local wortoxPatch = GLOBAL.require("PatchWortox")
        AddPrefabPostInit("wortox", function(inst)
            wortoxPatch.PatchWortox(inst)
        end)
    end

    -- Range overrides (0 = leave alone). Needed for ATC TUNING; also drives TA retarget filter.
    local retarget_range = GUARD_TARGET_DIST ~= nil and GUARD_TARGET_DIST ~= 0
    if retarget_range then
        GLOBAL.TUNING.CITY_PIG_GUARD_TARGET_DIST = GUARD_TARGET_DIST
    end
    if GUARD_KEEP_TARGET_DIST ~= nil and GUARD_KEEP_TARGET_DIST ~= 0 then
        GLOBAL.TUNING.CITY_PIG_GUARD_KEEP_TARGET_DIST = GUARD_KEEP_TARGET_DIST
    end

    if DISABLE_KEEPTARGET_SHARE or retarget_range then
        local cityPigPatch = GLOBAL.require("PatchCityPigCombat")
        cityPigPatch.Apply(AddPrefabPostInit, {
            keep_target = DISABLE_KEEPTARGET_SHARE == true,
            retarget_range = retarget_range,
        })
    end
end

--------------------------------------------------------------------------
-- Starting mask (skip only if stock Shamlet Mask already grants one)
--------------------------------------------------------------------------

local function IsStockShamletMaskEnabled()
    for _, name in ipairs(GetEnabledModNames()) do
        if name == "workshop-1581485409"
            or string.find(string.lower(tostring(name)), "1581485409", 1, true) ~= nil then
            return true
        end
    end
    return false
end

-- Always import when enabled: do not gate on provider/prefab detection at load
-- time (Prefabs may not be registered yet; TE detection can also miss).
-- startitem.lua eligibility no longer depends only on monster tags (AlwaysDisguise
-- strips those before OnNewSpawn for Wortox/Webber).
if STARTING_MASK and not IsStockShamletMaskEnabled() then
    modimport("startitem.lua")
end
