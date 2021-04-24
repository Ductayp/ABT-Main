local ADMINS = {
    [1] = true, -- OG
    [340006099] = true, -- PlanetDad
    [33684438] = true, -- JakeCenZ
    [-1] = true -- test player
}

local MODERATORS = {
    [1] = true, -- OG
    [340006099] = true, -- PlanetDad
    [33684438] = true, -- JakeCenZ
    [1666632536] = true, -- LegitPlanet_Alt
    [1429855001] = true, -- Cool_Shallow/DespacitEgg
    [738431325] = true, -- Alpha_Bois
    [-1] = true -- test player
}

return function(registry)
    registry:RegisterHook("BeforeRun", function(context)
        
        if context.Group == "DefaultAdmin" and not ADMINS[context.Executor.UserId] then
            return "You don't have permission to run this command"
        end

        if context.Group == "DefaultDebug" and not ADMINS[context.Executor.UserId] then
            return "You don't have permission to run this command"
        end

        if context.Group == "DefaultUtil" and not ADMINS[context.Executor.UserId] then
            return "You don't have permission to run this command"
        end

        if context.Group == "Moderator" and not MODERATORS[context.Executor.UserId] then
            return "You don't have permission to run this command"
        end

    end)
end