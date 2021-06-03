-- StateService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local StateService = Knit.CreateService { Name = "StateService", Client = {}}
local utils = require(Knit.Shared.Utils)

--// AddState - add a modfier value, if one of the same name exists then do nothing
function StateService:AddEntryToState(player, stateName, entryName, entryValue, params)

    --print("AddEntryToState: ", player, stateName, entryName, entryValue, params)

    local playerFolder = ReplicatedStorage.StateService:FindFirstChild(player.UserId)
    if not playerFolder then

        -- create a folder for the player
        playerFolder = utils.EasyInstance("Folder",{Name = player.UserId, Parent = ReplicatedStorage.StateService})

        -- create the folders based on scripts parented to StateService
        for _,child in pairs(Knit.StateModules:GetChildren()) do
            if child:IsA("ModuleScript") then
                utils.EasyInstance("Folder",{Name = child.Name, Parent = playerFolder})
            end
        end
    end

    -- see if the state exists and make it if it doesnt
    local stateFolder = playerFolder:FindFirstChild(stateName)
    if not stateFolder then
        print("State Class does not exist")
        return
    end

    -- if entry does not exist, make a new one
    local duplicateEntry
    local thisEntry = ReplicatedStorage.StateService[player.UserId][stateName]:FindFirstChild(entryName)
    if not thisEntry then

        -- create new entry object
        duplicateEntry = false
        thisEntry = utils.NewValueObject(entryName, entryValue, stateFolder)

        -- iterate through params and create new values also based ont their types and parent to the new entry
        if params then
            for key,value in pairs(params) do
                utils.NewValueObject(key, value, thisEntry)
            end
        end

    else
        duplicateEntry = true
    end

    -- run the states module if it exist 
    local results
    local stateModule = Knit.StateModules:FindFirstChild(stateName) 
    if stateModule then
        --local requiredModule = require(stateModule)
        results = require(stateModule).Entry_Added(player, thisEntry, params, duplicateEntry)
    end

    -- return the results
    return results

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

--// PowerChanged
function StateService:PowerChanged(player)

    local playerFolder = ReplicatedStorage.StateService:FindFirstChild(player.UserId)
    if not playerFolder then return end

    for _, state in pairs(playerFolder:GetChildren()) do
        for _, stateEntry in pairs(state:GetChildren()) do
            for _, stateParam in pairs(stateEntry:GetChildren()) do
                if stateParam.Name == "RemoveOnPowerChange" and stateParam.Value == true then
                    self:RemoveEntryFromState(player, state.Name, stateEntry.Name)
                end
            end
        end
    end

end


--// StateTick
function StateService:StateTick()

    local tickTime = 1
    local lastTick = os.clock()

    spawn(function()
        while game:GetService("RunService").Heartbeat:Wait() do

            if os.clock() >= lastTick + tickTime then

                lastTick = os.clock()

                for _, player in pairs(Players:GetPlayers()) do
                    local playerFolder = ReplicatedStorage.StateService:FindFirstChild(player.UserId)
                    if playerFolder then
            
                        for _, state in pairs(playerFolder:GetChildren()) do
                            local stateModule = Knit.StateModules:FindFirstChild(state.Name)
                            if stateModule then
                                local requiredModule = require(stateModule)
                                if requiredModule.OnTick then
                                    requiredModule.OnTick(player)
                                end 
                            end
                        end
                    end
                end

            end
    
            wait()
        end
    end)


end

-----------------------------------------------------------------------------------------------------------------------------
--// PLAYER MANAGEMENT
-----------------------------------------------------------------------------------------------------------------------------

--// PlayerJoining
function StateService:CharacterAdded(character)

    --print("STATE SERVICE: CHARACTER ADDED", character)

end

--// CharacterDied
function StateService:CharacterDied(player, character)

    --print("STATE SERVICE: CHARACTER DIED", player, character)
    
    local playerFolder = ReplicatedStorage.StateService:FindFirstChild(player.UserId)
    if not playerFolder then return end

    for _, state in pairs(playerFolder:GetChildren()) do
        for _, stateEntry in pairs(state:GetChildren()) do
            for _, stateParam in pairs(stateEntry:GetChildren()) do
                if stateParam.Name == "RemoveOnDeath" and stateParam.Value == true then
                    self:RemoveEntryFromState(player, state.Name, stateEntry.Name)
                end
            end
        end
    end

end

--// PlayerJoining
function StateService:PlayerAdded(player)


end

--// PlayerLeaving
function StateService:PlayerRemoved(player)
    -- destroy the players folder
    ReplicatedStorage.StateService:FindFirstChild(player.UserId):Destroy()
end

-----------------------------------------------------------------------------------------------------------------------------
--// KNIT STARTUP
-----------------------------------------------------------------------------------------------------------------------------

--// KnitStart
function StateService:KnitStart()
    self:StateTick()
end

--// KnitInit
function StateService:KnitInit()

    -- create a folder to hold all the states
    local mainFolder = utils.EasyInstance("Folder",{Name = "StateService", Parent = ReplicatedStorage})

    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)

        player.CharacterAdded:Connect(function(character)
            self:CharacterAdded(player)
    
            character:WaitForChild("Humanoid").Died:Connect(function()
                self:CharacterDied(player, character)
            end)
        end)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
        
        player.CharacterAdded:Connect(function(character)
            self:CharacterAdded(player)
    
            character:WaitForChild("Humanoid").Died:Connect(function()
                self:CharacterDied(player, character)
            end)
        end)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoved(player)
    end)


end


return StateService