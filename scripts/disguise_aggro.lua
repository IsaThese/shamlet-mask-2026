-- Shared pig-aggression disguise helpers.
-- Owner markers: "disguise" (ATC / Wortox) and "notmonster" (stock Shamlet Mask).

local always_disguise_enabled = false
local ALWAYS_DISGUISE_PREFABS = {
    webber = true,
    wortox = true,
}

local function SetAlwaysDisguiseEnabled(enabled)
    always_disguise_enabled = enabled == true
end

local function IsAlwaysDisguised(owner)
    if not always_disguise_enabled or owner == nil or not owner:IsValid() then
        return false
    end
    return ALWAYS_DISGUISE_PREFABS[owner.prefab] == true
end

local function ForceDisguised(owner)
    owner:RemoveTag("monster")
    owner:RemoveTag("playermonster")
    owner:AddTag("disguise")
    owner:AddTag("notmonster")
end

local function ForceRestored(owner, had_monster, had_playermonster)
    owner:RemoveTag("disguise")
    owner:RemoveTag("notmonster")
    owner:RemoveTag("monster")
    owner:RemoveTag("playermonster")

    if had_monster then
        owner:AddTag("monster")
    end
    if had_playermonster then
        owner:AddTag("playermonster")
    end
end

-- Wrap an existing (or newly provided) disguisehat so aggro tags are correct
-- even when another mod's onequip/onunequip is incomplete or conflicts.
-- force=true re-applies when something later replaces onequip/onunequip
-- (e.g. Magician's Top Hat via tophat:ConvertToMagician).
local function WrapEquippable(inst, force)
    if inst.components == nil or inst.components.equippable == nil then
        return
    end
    if inst._shamlet_aggro_wrapped and not force then
        return
    end
    inst._shamlet_aggro_wrapped = true

    local equippable = inst.components.equippable
    local old_onequip = equippable.onequipfn
    local old_onunequip = equippable.onunequipfn

    equippable:SetOnEquip(function(hat, owner, ...)
        local had_monster = owner ~= nil and owner:HasTag("monster")
        local had_playermonster = owner ~= nil and owner:HasTag("playermonster")

        if old_onequip ~= nil then
            old_onequip(hat, owner, ...)
        end

        if owner == nil or not owner:IsValid() then
            return
        end

        hat._had_monster = had_monster
        hat._had_playermonster = had_playermonster
        -- Keep ATC's restore flag in sync when present.
        hat.monster = had_monster or nil

        ForceDisguised(owner)
    end)

    equippable:SetOnUnequip(function(hat, owner, ...)
        local had_monster = hat._had_monster
        local had_playermonster = hat._had_playermonster

        if old_onunequip ~= nil then
            old_onunequip(hat, owner, ...)
        end

        if owner == nil or not owner:IsValid() then
            return
        end

        -- Always-disguise characters stay pig-safe after unequip.
        if IsAlwaysDisguised(owner) then
            hat._had_monster = nil
            hat._had_playermonster = nil
            hat.monster = nil
            ForceDisguised(owner)
            return
        end

        -- Fallbacks if we didn't capture (e.g. hat equipped before wrap).
        if had_monster == nil and hat.monster then
            had_monster = true
            had_playermonster = true
        end

        ForceRestored(owner, had_monster, had_playermonster)
        hat._had_monster = nil
        hat._had_playermonster = nil
        hat.monster = nil
    end)
end

local function IsMagicianTophat(inst)
    return inst.components ~= nil and inst.components.magiciantool ~= nil
end

-- Top Hat and Magician's Top Hat share prefab "tophat". Magician conversion
-- (ConvertToMagician / OnLoad) replaces onequip/onunequip, so re-wrap after
-- when Magician disguise is enabled.
-- opts.normal / opts.magician control each variant independently.
local function WrapTophat(inst, opts)
    opts = opts or {}
    local disguise_normal = opts.normal == true
    local disguise_magician = opts.magician == true

    if disguise_normal and not IsMagicianTophat(inst) then
        WrapEquippable(inst)
    elseif disguise_magician and IsMagicianTophat(inst) then
        WrapEquippable(inst)
    end

    if inst.ConvertToMagician ~= nil and not inst._shamlet_magician_convert_wrapped then
        inst._shamlet_magician_convert_wrapped = true
        local old_convert = inst.ConvertToMagician
        inst.ConvertToMagician = function(hat, ...)
            old_convert(hat, ...)
            if disguise_magician then
                WrapEquippable(hat, true)
            end
            -- If only normal was wrapped, ConvertToMagician already replaced
            -- onequip/onunequip with vanilla magician handlers — leave them.
        end
    end

    -- OnLoad calls the local convert fn directly, not inst.ConvertToMagician.
    if inst.OnLoad ~= nil and not inst._shamlet_tophat_onload_wrapped then
        inst._shamlet_tophat_onload_wrapped = true
        local old_onload = inst.OnLoad
        inst.OnLoad = function(hat, data, ...)
            old_onload(hat, data, ...)
            if disguise_magician and IsMagicianTophat(hat) then
                WrapEquippable(hat, true)
            elseif disguise_normal and not IsMagicianTophat(hat) then
                WrapEquippable(hat, true)
            end
        end
    end
end

return {
    WrapEquippable = WrapEquippable,
    WrapTophat = WrapTophat,
    ForceDisguised = ForceDisguised,
    ForceRestored = ForceRestored,
    SetAlwaysDisguiseEnabled = SetAlwaysDisguiseEnabled,
    IsAlwaysDisguised = IsAlwaysDisguised,
}
