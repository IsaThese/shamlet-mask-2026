local function en_zh(en, zh)
    return (locale == "zh" or locale == "zhr" or locale == "zht") and zh or en
end

name = "Shamlet Mask + Pig Aggro Fix"
author = "Isaac"
description = en_zh(
[[Fixes the Shamlet Mask for Wortox and Webber, and restores pig aggression to original Don't Starve / Hamlet behavior.

• Starting Shamlet Mask for Wortox and Webber (and other monster players)
• Wearing the mask properly disguises you from pigs — same idea as the original game
• City pig / guard aggro tuned toward original Don't Starve mechanics (range, keep-target, no KeepTarget aggro-share cascade)

Works alone, or alongside Above the Clouds, Tropical Experience, Tropical Adventures, or the stock Shamlet Mask. If another mod already provides the mask, this one patches it instead of duplicating it. (Tropical Experience's mask is visual-only by default — this makes the disguise actually work.)

Optional: always-disguise Webber/Wortox without a mask; Top Hat / Magician's Top Hat as disguise; full aggro config toggles.

GitHub (open source):
https://github.com/IsaThese/shamlet-mask-2026

YouTube the issue this fixes:
https://www.youtube.com/watch?v=fRCVs2F0lTw]],
[[修复哈姆雷特面具在沃托克斯与韦伯上的问题，并将猪人仇恨恢复为更接近原版 Don't Starve / 哈姆雷特的表现。

• 沃托克斯、韦伯（及其他怪物角色）开局获得面具
• 佩戴后面具真正生效，猪人仇恨与原版伪装一致
• 城镇猪人 / 守卫仇恨贴近原版机制（索敌距离、保持目标、阻止 KeepTarget 仇恨扩散）

可单独使用，也可与云霄国度、热带体验、热带冒险或原版 Shamlet Mask 共存。若其他模组已有面具，本模组只打补丁不重复注册。（热带体验的面具默认只有外观——本模组让伪装真正生效。）

可选：无面具始终伪装韦伯/沃托克斯；高礼帽/魔术师高礼帽伪装；完整仇恨相关设置。

GitHub（开源）：
https://github.com/IsaThese/shamlet-mask-2026

YouTube — 问题演示：
https://www.youtube.com/watch?v=fRCVs2F0lTw]]
)

version = "1.4.4"
forumthread = ""
api_version = 10
api_version_dst = 10

-- After ATC (-1), Tropical Experience (-20), Tropical Adventures (-100).
priority = -101

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

local function Breaker(title_en, title_zh)
    return {
        name = en_zh(title_en, title_zh),
        options = { { description = "", data = false } },
        default = false,
    }
end

configuration_options = {
    Breaker("Mask", "面具"),
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
            "Give a Shamlet Mask to Webber, Wortox, and other monster players on first spawn (skipped if stock Shamlet Mask workshop mod is enabled).",
            "韦伯、沃托克斯及其他怪物角色首次生成时给予面具（若启用了原版 Shamlet Mask 创意工坊模组则跳过，避免重复）。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = true,
    },

    Breaker("Pig aggression", "猪人仇恨"),
    {
        name = "FIX_PIG_AGGRO",
        label = en_zh("Fix pig aggression (tags)", "修复猪人仇恨（标签）"),
        hover = en_zh(
            "Strip monster/playermonster while disguised, restore on unequip, and patch Wortox inclination. Master switch for aggro-related options below.",
            "伪装时移除 monster/playermonster，卸下时恢复，并修补沃托克斯倾向切换。同时作为下方仇恨相关选项的总开关。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = true,
    },
    {
        name = "CITY_PIG_GUARD_TARGET_DIST",
        label = en_zh("Guard retarget range", "守卫索敌距离"),
        hover = en_zh(
            "Retarget range (ATC TUNING; TE/TA use a local 20 and are filtered). Requires Fix pig aggression. Stock 20; published fix 17.",
            "索敌距离(ATC 用 TUNING; 热带体验/热带冒险为本地常量 20, 本模组会过滤)。需要启用「修复猪人仇恨」。原版 20; 已发布修复 17。"
        ),
        options = {
            { description = en_zh("17 (fix)", "17（修复）"), data = 17 },
            { description = en_zh("20 (stock)", "20（原版）"), data = 20 },
            { description = en_zh("Unchanged", "不修改"), data = 0 },
        },
        default = 17,
    },
    {
        name = "CITY_PIG_GUARD_KEEP_TARGET_DIST",
        label = en_zh("Guard keep-target range", "守卫维持仇恨距离"),
        hover = en_zh(
            "TUNING.CITY_PIG_GUARD_KEEP_TARGET_DIST. Requires Fix pig aggression. ATC default is 32; published fix uses 25.",
            "TUNING.CITY_PIG_GUARD_KEEP_TARGET_DIST。需要启用「修复猪人仇恨」。ATC 默认为 32; 已发布修复为 25。"
        ),
        options = {
            { description = en_zh("25 (fix)", "25（修复）"), data = 25 },
            { description = en_zh("32 (ATC)", "32（ATC）"), data = 32 },
            { description = en_zh("Unchanged", "不修改"), data = 0 },
        },
        default = 25,
    },
    {
        name = "DISABLE_KEEPTARGET_SHARE",
        label = en_zh("Disable keep-target hate share", "禁用维持仇恨时蔓延"),
        hover = en_zh(
            "Replace city pig KeepTarget so it no longer ShareTarget while holding aggro (matches published pigman_city fix). Requires Fix pig aggression.",
            "替换城镇猪人 KeepTarget，使其在维持仇恨时不再 ShareTarget（与已发布的 pigman_city 修复一致）。需要启用「修复猪人仇恨」。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = true,
    },
    {
        name = "ALWAYS_DISGUISE_WEBBER_WORTOX",
        label = en_zh("Always disguise Webber/Wortox", "韦伯/沃托克斯始终伪装"),
        hover = en_zh(
            "Keep Webber and Wortox pig-safe even without a Shamlet Mask. Unequipping a mask will not restore monster tags. Independent of wearing a mask.",
            "即使未佩戴哈姆雷特面具，也让韦伯与沃托克斯对猪人保持安全。卸下面具不会恢复怪物标签。与是否佩戴面具无关。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = false,
    },
    {
        name = "DISGUISE_TOPHAT",
        label = en_zh("Top Hat acts as disguise", "高礼帽也算伪装"),
        hover = en_zh(
            "When enabled, the normal Top Hat applies the same pig-safe disguise tags as the Shamlet Mask. Does not affect Magician's Top Hat. Default off.",
            "启用后，普通高礼帽会施加与哈姆雷特面具相同的猪人安全伪装标签。不影响魔术师高礼帽。默认关闭。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = false,
    },
    {
        name = "DISGUISE_TOPHAT_MAGICIAN",
        label = en_zh("Magician's Top Hat acts as disguise", "魔术师高礼帽也算伪装"),
        hover = en_zh(
            "When enabled, Magician's Top Hat (Maxwell's converted tophat) applies the same pig-safe disguise tags as the Shamlet Mask. Default off.",
            "启用后，魔术师高礼帽（麦斯威尔转换后的 tophat）会施加与哈姆雷特面具相同的猪人安全伪装标签。默认关闭。"
        ),
        options = {
            { description = en_zh("Enabled", "启用"), data = true },
            { description = en_zh("Disabled", "禁用"), data = false },
        },
        default = false,
    },
}
