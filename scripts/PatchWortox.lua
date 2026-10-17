-- Wortox's skill-tree inclination can re-add monster / playermonster while disguised.
-- Re-strip those tags whenever inclination changes, if the player still wears a disguise.

local function StripMonsterTags(player)
    if player ~= nil and player:IsValid() and player:HasTag("disguise") then
        player:RemoveTag("monster")
        player:RemoveTag("playermonster")
    end
end

local function PatchWortox(inst)
    inst:ListenForEvent("wortox_inclination_changed", StripMonsterTags)
    StripMonsterTags(inst)
end

return {
    PatchWortox = PatchWortox,
    StripMonsterTags = StripMonsterTags,
}
