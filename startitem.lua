-- Give monster players a disguisehat on first spawn (Shamlet Mask behavior).

-- Prefab allowlist: AlwaysDisguise can strip monster tags before OnNewSpawn.
local STARTING_MASK_PREFABS = {
    webber = true,
    wortox = true,
}

local function ShouldGetStartingMask(player)
    if player == nil or not player:IsValid() then
        return false
    end
    if STARTING_MASK_PREFABS[player.prefab] then
        return true
    end
    if player:HasTag("monster") or player:HasTag("playermonster") then
        return true
    end
    -- AlwaysDisguise / early disguise patches strip monster tags and add these.
    if player:HasTag("disguise") or player:HasTag("notmonster") then
        return true
    end
    return false
end

local function OnPlayerSpawn(src, player)
    player.prev_OnNewSpawn = player.OnNewSpawn or function()
        return true
    end

    player.OnNewSpawn = function(...)
        if player.components.inventory ~= nil and ShouldGetStartingMask(player) then
            local item = GLOBAL.SpawnPrefab("disguisehat")
            if item ~= nil then
                player.components.inventory:GiveItem(item)
            else
                print("[Shamlet Mask 2026] STARTING_MASK: SpawnPrefab(disguisehat) failed for " .. tostring(player.prefab))
            end
        end
        return player.prev_OnNewSpawn(...)
    end
end

AddPrefabPostInit("world", function(inst)
    inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn)
end)
