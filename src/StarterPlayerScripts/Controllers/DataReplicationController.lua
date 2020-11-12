-- Data Replcaition Controller
-- PDab
-- 11/10/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local DataReplicationController = Knit.CreateController { Name = "DataReplicationController" }

-- instance references
local MainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
local ValueObjectFolder = ReplicatedStorage.ReplicatedPlayerData:WaitForChild(Players.LocalPlayer.UserId)

function DataReplicationController:ConnectValue(descendant)
    if descendant:IsA("ValueBase") then
        local key = descendant.Name
        local guiInstances = MainGui:GetDescendants(true)
		for i,v in pairs(guiInstances) do
            if v.Name == key then
                v.Text = descendant.Value -- we do this first so we dont have to wait for the ObjectValues to change
				descendant.Changed:Connect(function()
                    v.Text = descendant.Value
                end)
            end
        end
    end
end

function DataReplicationController:KnitStart()
    
    -- connect any values that already exist
	for _,descendant in pairs(ValueObjectFolder:GetDescendants()) do 
		self:ConnectValue(descendant)
    end
    
    -- connect values when they are added
	ValueObjectFolder.DescendantAdded:Connect(function(descendant)
        self:ConnectValue(descendant)
    end)
	
end

return DataReplicationController
