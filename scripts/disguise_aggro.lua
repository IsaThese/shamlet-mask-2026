-- Shared pig-aggression disguise helpers.
-- Owner markers: "disguise" (ATC / Wortox) and "notmonster" (stock Shamlet Mask).

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
local function WrapEquippable(inst)
    if inst.components == nil or inst.components.equippable == nil then
        return
    end
    if inst._shamlet_aggro_wrapped then
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

return {
    WrapEquippable = WrapEquippable,
    ForceDisguised = ForceDisguised,
    ForceRestored = ForceRestored,
}
