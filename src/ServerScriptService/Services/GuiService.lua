-- Gui Service
-- PDab
-- 12/20/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.CreateService { Name = "GuiService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

function GuiService.Client:UseArrow(player,arrowType,arrowRarity)

    -- check if the player has this arrow
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local hasArrow = false
    for index,arrowTable in pairs(playerData.ArrowInventory) do
        print(arrowTable.Type,arrowType)
        if arrowTable.Type == arrowType then
            if arrowTable.Rarity == arrowRarity then
                table.remove(playerData.ArrowInventory, index) -- remove the arrow
                Knit.Services.DataReplicationService:UpdateCategory(player, "ArrowInventory")
                hasArrow = true
            end
        end
    end

    if hasArrow == true then

    end

end


--// KnitStart
function GuiService:KnitStart()
    
end

--// KnitInit
function GuiService:KnitInit()

end


return GuiService