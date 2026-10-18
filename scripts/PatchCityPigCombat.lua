-- City pig / royal guard combat patches for ATC + Tropical Adventures.
-- - KeepTarget: distance keep without ShareTarget side effects (ATC published fix).
-- - Retarget: filter candidates beyond TUNING.CITY_PIG_GUARD_TARGET_DIST
--   (TA uses a file-local range of 20, so TUNING alone would not apply).

local CITY_PIG_PREFABS = {
    -- Shared ATC / TA
    "pigman_beautician",
    "pigman_florist",
    "pigman_erudite",
    "pigman_hatmaker",
    "pigman_storeowner",
    "pigman_banker",
    "pigman_collector",
    "pigman_hunter",
    "pigman_professor",
    "pigman_usher",
    "pigman_farmer",
    "pigman_miner",
    "pigman_beautician_shopkeep",
    "pigman_florist_shopkeep",
    "pigman_erudite_shopkeep",
    "pigman_hatmaker_shopkeep",
    "pigman_storeowner_shopkeep",
    "pigman_banker_shopkeep",
    "pigman_shopkeep",
    "pigman_hunter_shopkeep",
    "pigman_farmer_shopkeep",
    "pigman_miner_shopkeep",
    "pigman_collector_shopkeep",
    "pigman_professor_shopkeep",
    "pigman_mechanic_shopkeep",
    "pigman_mayor_shopkeep",
    "pigman_royalguard",
    "pigman_royalguard_2",
    "pigman_mechanic",
    "pigman_mayor",
    "pigman_queen",
    -- Tropical Adventures–only
    "pigman_royalguard_3",
    "pig_royalguard_rich",
    "pig_royalguard_rich_2",
    "pig_eskimo",
    "pigman_eskimo_shopkeep",
    "pig_shopkeeper",
}

local function KeepTargetNoShare(inst, target)
    if target == nil or not target:IsValid() then
        return false
    end
    if inst.components.combat == nil or not inst.components.combat:CanTarget(target) then
        return false
    end
    if target.LightWatcher ~= nil and not target.LightWatcher:IsInLight() then
        return false
    end

    local keep_dist = TUNING.CITY_PIG_GUARD_KEEP_TARGET_DIST or 32
    return inst:GetDistanceSqToInst(target) < keep_dist * keep_dist
end

local function WrapRetargetRange(inst)
    local combat = inst.components.combat
    if combat == nil or combat.retargetfn == nil or inst._shamlet_retarget_patched then
        return
    end
    inst._shamlet_retarget_patched = true

    local old_retarget = combat.retargetfn
    local period = combat.retargetperiod or 3

    combat:SetRetargetFunction(period, function(pig)
        local target = old_retarget(pig)
        if target == nil or not target:IsValid() then
            return target
        end

        local dist = TUNING.CITY_PIG_GUARD_TARGET_DIST
        if dist ~= nil and dist > 0 and pig:GetDistanceSqToInst(target) > dist * dist then
            return nil
        end
        return target
    end)
end

local function PatchInst(inst, opts)
    if inst.components == nil or inst.components.combat == nil then
        return
    end

    if opts.keep_target and not inst._shamlet_keeptarget_patched then
        inst._shamlet_keeptarget_patched = true
        inst.components.combat:SetKeepTargetFunction(KeepTargetNoShare)
    end

    if opts.retarget_range then
        WrapRetargetRange(inst)
    end
end

local function Apply(AddPrefabPostInit, opts)
    opts = opts or {}
    local keep_target = opts.keep_target == true
    local retarget_range = opts.retarget_range == true
    if not keep_target and not retarget_range then
        return
    end

    for _, prefab in ipairs(CITY_PIG_PREFABS) do
        AddPrefabPostInit(prefab, function(inst)
            if not TheWorld.ismastersim then
                return
            end
            PatchInst(inst, {
                keep_target = keep_target,
                retarget_range = retarget_range,
            })
        end)
    end
end

return {
    Apply = Apply,
    KeepTargetNoShare = KeepTargetNoShare,
    WrapRetargetRange = WrapRetargetRange,
    CITY_PIG_PREFABS = CITY_PIG_PREFABS,
}
