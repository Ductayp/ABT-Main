local ADMINS = {
    [1] = true,
    [340006099] = true,
}

return function(registry)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Group == "DefaultAdmin" and not ADMIN[context.Executor.UserId] then
            return "You don't have permission to run this command"
        end
    end)
end