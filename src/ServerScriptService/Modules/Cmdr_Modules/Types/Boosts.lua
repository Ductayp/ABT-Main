return function (registry)
    registry:RegisterType("currency", registry.Cmdr.Util.MakeEnumType("Currency", {"Cash", "SoulOrbs"}))
end