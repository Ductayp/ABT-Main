-- State Service
-- PDab
-- 12/6/2020

--[[ STATE SERVICE
service habdle all forms of state, besides the acyual player data, in one central location. This is useful for things like damage or walkspeed modifiers,
not temporary or permanent. It is also useful for thing like safe zones, or bonueses given by gamepasses.
Keeping all of these states and/or modifiers in one place allows us to stack them easily, remove them when needed, and always know exactly what any player
has at any given time.

States are managed as ValueBase objects so that that can easily be listened to by the client or other services.

We are not using playerData storage for these states, because they are not always saved, sometimes temporary, and we dont want to clutter up the playerData code.
]]--

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local StateService = Knit.CreateService { Name = "StateService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)

--// AddState - add a modfier value, if one of the same name exists then do nothing
function StateService:AddEntryToState(player, stateName, entryName, entryValue, params)

    --print("STATE SERVICE SAYS: ", player, stateName, entryName, entryValue, params)

    -- see if the state exists and make it if it doesnt
    local stateFolder = ReplicatedStorage.StateService[player.UserId]:FindFirstChild(stateName)
    if stateFolder then

        local thisEntry = ReplicatedStorage.StateService[player.UserId][stateName]:FindFirstChild(entryName)
        if not thisEntry then
        
            -- make a new value object based on its type
            thisEntry = utils.NewValueObject(entryName, entryValue, stateFolder)

            --[[
            -- iterate through params and create new values also based ont their types and parent to the new entry
            if params then
                for key,value in pairs(params) do
                    utils.NewValueObject(key, value, thisEntry)
                end
            end
            ]]--
            
        else
            print("Duplicate State Entry Found - No New Entry Created")
        end
        
        -- run the states module if it exist 
        local results = nil
        local stateModule = Knit.StateModules:FindFirstChild(stateName) 
        if stateModule then
            local requiredModule = require(stateModule)
            results = requiredModule.Entry_Added(player,thisEntry,params)
        end

        -- return the results
        return results
    else
        print("State Class does not exist")
    end
end

--// UpdateEntryInState 
function StateService:UpdateTimedEntryInState(player, stateName, entryName, entryValue, params)
    print("UpdateEntryInState", player, stateName, entryName, entryValue, params)
end 

--// RemoveState -- removes a modfier by name
function StateService:RemoveEntryFromState(player, stateName, entryName, params)

    -- be sure the players fodler is still there, sometimes its not if they left game
    if not ReplicatedStorage.StateService:FindFirstChild(player.UserId) then
        return
    end

    local thisState = ReplicatedStorage.StateService[player.UserId]:FindFirstChild(stateName)
    if thisState then

        local thisEntry = thisState:FindFirstChild(entryName)
        if thisEntry then

            -- destroy the state entry
            thisEntry:Destroy()

            local stateModule = Knit.StateModules:FindFirstChild(stateName) -- state modules can do a lot of thingsm its cusomt for each value we might modify
            if stateModule then
                local requiredModule = require(stateModule)
                local results = requiredModule.Entry_Removed(player, thisState, params) -- if we have a module to run, we will overwite the above results with that module
                return results -- not sure what we might return here, but lets do it just in case
            end
        end
    end 
end

--// PlayerJoining
function StateService:PlayerAdded(player)

    print("StateService:PlayerJoined")

    -- create a folder for the player
    local playerFolder = utils.EasyInstance("Folder",{Name = player.UserId, Parent = ReplicatedStorage.StateService})

    -- create the folders based on scripts parented to StateService
    for _,child in pairs(Knit.StateModules:GetChildren()) do
        if child:IsA("ModuleScript") then
            utils.EasyInstance("Folder",{Name = child.Name, Parent = playerFolder})
        end
    end

end

--// PlayerLeaving
function StateService:PlayerRemoved(player)
    -- destroy the players folder
    ReplicatedStorage.StateService:FindFirstChild(player.UserId):Destroy()
end

--// KnitStart
function StateService:KnitStart()

    --[[
    -- start the tickupdate loop
    local lastUpdate = os.time()
    local loopTime = 1
    while game:GetService("RunService").Heartbeat:Wait() do

        if lastUpdate <= (os.time() -loopTime) then
            lastUpdate = os.time()

            for _, thisModule in pairs(Knit.StateModules:GetChildren()) do
                local module = require(thisModule)
                if module.Timer_Update then
                    module.Timer_Update()
                end
            end
        end
        
    end
    ]]--

end

--// KnitInit
function StateService:KnitInit()

    -- create a folde rto hold al the states
    local mainFolder = utils.EasyInstance("Folder",{Name = "StateService", Parent = ReplicatedStorage})

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoved(player)
    end)


end


return StateService