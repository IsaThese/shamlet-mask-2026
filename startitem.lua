-- Give monster players a disguisehat on first spawn (Shamlet Mask behavior).

local function OnPlayerSpawn(src, player)
    player.prev_OnNewSpawn = player.OnNewSpawn or function()
        return true
    end

    player.OnNewSpawn = function(...)
        if player.components.inventory ~= nil
            and (player:HasTag("monster") or player:HasTag("playermonster")) then
            local item = GLOBAL.SpawnPrefab("disguisehat")
            if item ~= nil then
                player.components.inventory:GiveItem(item)
            end
        end
        return player.prev_OnNewSpawn(...)
    end
end

AddPrefabPostInit("world", function(inst)
    inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn)
end)
