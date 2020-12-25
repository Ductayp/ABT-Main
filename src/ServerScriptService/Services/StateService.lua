-- State Service
-- PDab
-- 12/6/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local StateService = Knit.CreateService { Name = "StateService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)


--// AddState - add a modfier value, if one of the same name exists then do nothing
function StateService:AddState(player, className, modifierName, modifierValue, params)

    -- see if the modifier exists and make it if it doesnt
    local thisClassFolder = ReplicatedStorage.StateService[player.UserId]:FindFirstChild(className)
    if thisClassFolder then

        local thisState = ReplicatedStorage.StateService[player.UserId][className]:FindFirstChild(modifierName)

        if thisState then
            print("This modifier already exists, nothing changed: ",modifierName)
        else
            -- make a new value object based on its type
            thisState = utils.NewValueObject(modifierName,modifierValue,thisClassFolder)

            -- iterate through params and create new values also based ont heir types and parent to the modifier
            if params then
                for key,value in pairs(params) do
                    utils.NewValueObject(key,value,thisState)
                end
            end
        end

        -- run the modifiers module if it exist 
        local results = thisState -- this are default results if there is no module for this modifier, it will just return the modifier object
        local modifierModule = script:FindFirstChild(className) -- modifier modules can do a lot of thingsm its cusomt for each value we might modify
        if modifierModule then
            local requiredModule = require(modifierModule)
            results = requiredModule.AddState(player,thisState,params) -- if we have a module to run, we will overwite the above results with that module
        end

        -- return the results
        return results
    else
        print("State Class does not exist")
    end
        
    

end

--// RemoveState -- removes  a modfier by name
function StateService:RemoveState(player, className, modifierName, params)
    local thisClassFolder = ReplicatedStorage.StateService[player.UserId]:FindFirstChild(className)
    if thisClassFolder then
        thisState = thisClassFolder:FindFirstChild(modifierName)
        if thisState then
            local modifierModule = script:FindFirstChild(className) -- modifier modules can do a lot of thingsm its cusomt for each value we might modify
            if modifierModule then
                local requiredModule = require(modifierModule)
                results = requiredModule.RemoveState(player, thisState, params) -- if we have a module to run, we will overwite the above results with that module
                return results -- not sure what we might return here, but lets do it just in case
            end
        end
    end 
end

--// PlayerJoining
function StateService:PlayerJoined(player)

    -- create a folder for the player
    local playerFolder = utils.EasyInstance("Folder",{Name = player.UserId, Parent = ReplicatedStorage.StateService})

    -- create the folders based on scripts parented to StateService
    for _,child in pairs(script:GetChildren()) do
        if child:IsA("ModuleScript") then
            utils.EasyInstance("Folder",{Name = child.Name, Parent = playerFolder})
        end
    end

end

--// PlayerLeaving
function StateService:PlayerRemoving(player)

    -- destroy the players folder
    ReplicatedStorage.StateService:FindFirstChild(player.UserId):Destroy()
end

--// KnitStart
function StateService:KnitStart()

end

--// KnitInit
function StateService:KnitInit()

    -- create a folde rto hold al the modifiers
    local mainFolder = utils.EasyInstance("Folder",{Name = "StateService", Parent = ReplicatedStorage})

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        
        player.CharacterAdded:Connect(function(character)
            self:PlayerJoined(player)

            character:WaitForChild("Humanoid").Died:Connect(function()
                --self:PlayerJoined(player)
            end)
        end)
    end)

    -- Player Added event for studio testing
    for _, player in ipairs(Players:GetPlayers()) do


        player.CharacterAdded:Connect(function(character)
            self:PlayerJoined(player)

            character:WaitForChild("Humanoid").Died:Connect(function()
                --self:PlayerJoined(player)
            end)
        end)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoving(player)
    end)

end


return StateService