local function en_zh(en, zh)
    return (locale == "zh" or locale == "zhr" or locale == "zht") and zh or en
end

name = "Shamlet Mask + Pig Aggro Fix"
author = "Isaac"
description = en_zh(
    "Standalone Shamlet Mask with pig aggression fix. Works alone, or alongside Above the Clouds / Tropical Adventures / stock Shamlet Mask (patches existing disguisehat instead of duplicating).",
    "独立哈姆雷特面具 + 猪人仇恨修复。可单独使用，也可与云霄国度 / 热带冒险 / 原版面具共存（检测到已有 disguisehat 时只打补丁不重复注册）。"
)

version = "1.0.0"
forumthread = ""
api_version = 10
api_version_dst = 10

-- Load after Above the Clouds (priority -1) so we can patch their disguisehat.
priority = -2

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
client_only_mod = false
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = { "hat", "shamlet", "hamlet", "disguise", "pig", "webber", "wortox" }

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
    name = name .. "-[" .. folder_name .. "]"
end

configuration_options = {
    {
        name = "FIX_PIG_AGGRO",
        label = en_zh("Fix pig aggression", "修复猪人仇恨"),
        hover = en_zh(
            "Strip monster/playermonster while disguised, restore on unequip, and patch Wortox inclination.",
            "伪装时移除 monster/playermonster，卸下时恢复，并修补沃托克斯倾向切换。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = true,
    },
    {
        name = "PROVIDE_MASK",
        label = en_zh("Provide Shamlet Mask", "提供面具"),
        hover = en_zh(
            "Register own disguisehat (prefab, assets, recipe) when no other mod already provides it.",
            "当其他模组未提供 disguisehat 时，注册本模组的面具（预制体、资源、配方）。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = true,
    },
    {
        name = "STARTING_MASK",
        label = en_zh("Starting mask for monsters", "怪物角色开局面具"),
        hover = en_zh(
            "Give a Shamlet Mask to monster players on first spawn (skipped if stock Shamlet Mask is enabled).",
            "怪物角色首次生成时给予面具（若启用了原版 Shamlet Mask 则跳过，避免重复）。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = true,
    },
}
