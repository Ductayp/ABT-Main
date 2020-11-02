local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MainGui = players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
local ValueObjectFolder = ReplicatedStorage.ReplicatedPlayerData:WaitForChild(players.LocalPlayer.UserId)

local module = {}

local function ConnectValue(descendant)
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

function module.Start()
	
	for i,v in pairs(ValueObjectFolder:GetDescendants()) do 
		ConnectValue(v)
	end
	ValueObjectFolder.DescendantAdded:Connect(ConnectValue)
	
end

return module
