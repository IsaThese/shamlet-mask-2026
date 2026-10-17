--[[
  Shamlet Mask + Pig Aggro Fix

  - Provides disguisehat when missing (standalone).
  - Patches equip/unequip + Wortox when disguisehat already exists (ATC / TA / Shamlet Mask).
  - Never blindly PrefabFiles = { "disguisehat" } alongside those mods.
]]

local FIX_PIG_AGGRO = GetModConfigData("FIX_PIG_AGGRO")
local PROVIDE_MASK = GetModConfigData("PROVIDE_MASK")
local STARTING_MASK = GetModConfigData("STARTING_MASK")

-- Mods known to register disguisehat (workshop IDs and common local folder names).
local DISGUISEHAT_PROVIDERS = {
    "workshop-1581485409", -- Shamlet Mask [DST]
    "workshop-3322803908", -- Above the Clouds
    "workshop-3330056551", -- Above The Clouds - Strange New Powers
    "workshop-2986194136", -- Tropical Adventures
}

local DISGUISEHAT_FOLDER_HINTS = {
    "1581485409",
    "3322803908",
    "3330056551",
    "2986194136",
    "shamlet",
    "above the clouds",
    "above_the_clouds",
    "porklandbugfixing",
    "tropical adventures",
    "tropical_adventures",
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
    "[Shamlet Mask 2026] FIX_PIG_AGGRO=%s PROVIDE_MASK=%s STARTING_MASK=%s | other_provider=%s prefab_known=%s => provide_own=%s",
    tostring(FIX_PIG_AGGRO),
    tostring(PROVIDE_MASK),
    tostring(STARTING_MASK),
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
-- Aggression fix: wrap disguisehat + Wortox inclination
--------------------------------------------------------------------------

if FIX_PIG_AGGRO then
    local disguise_aggro = GLOBAL.require("disguise_aggro")

    AddPrefabPostInit("disguisehat", function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        disguise_aggro.WrapEquippable(inst)
    end)

    local wortoxPatch = GLOBAL.require("PatchWortox")
    AddPrefabPostInit("wortox", function(inst)
        wortoxPatch.PatchWortox(inst)
    end)
end

--------------------------------------------------------------------------
-- Starting mask (skip if stock Shamlet Mask already grants one)
--------------------------------------------------------------------------

local shamlet_mask_enabled = other_provider ~= nil and (
    other_provider == "workshop-1581485409"
    or string.find(string.lower(tostring(other_provider)), "1581485409", 1, true) ~= nil
    or string.find(string.lower(tostring(other_provider)), "shamlet", 1, true) ~= nil
)

if STARTING_MASK and not shamlet_mask_enabled then
    if should_provide or other_provider ~= nil or disguisehat_known then
        modimport("startitem.lua")
    end
end
