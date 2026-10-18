-- Permanently keep Webber / Wortox in pig-safe disguise tag state (no mask required).

local disguise_aggro = require("disguise_aggro")

local function Apply(inst)
    if inst == nil or not inst:IsValid() then
        return
    end

    disguise_aggro.ForceDisguised(inst)

    if inst.prefab == "wortox" and not inst._shamlet_always_disguise_wortox then
        inst._shamlet_always_disguise_wortox = true
        inst:ListenForEvent("wortox_inclination_changed", function(player)
            if player ~= nil and player:IsValid() then
                disguise_aggro.ForceDisguised(player)
            end
        end)
    end
end

return {
    Apply = Apply,
}
