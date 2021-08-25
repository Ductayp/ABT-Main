-- GameChatController

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GameChatController = Knit.CreateController { Name = "GameChatController" }
local utils = require(Knit.Shared.Utils)

local ANNOUNCE_WAIT = 600
local announceCount = 1

local messageTable = {
    [1] = "Follow Planet Milo on Twitter for codes.",
    [2] = "Sub to Planet Milo on YT for EPIC livestream giveaways.",
    [3] = "Thanks for playing! We are building a non-toxic community. BE CHILL :)",
}

--// ChatAnnouncements
function GameChatController:ChatAnnouncements()

    spawn(function()

        while true do

            game.StarterGui:SetCore("ChatMakeSystemMessage",{
                Text = "[YEETER]: "..messageTable[announceCount],
                Color = Color3.fromRGB(232, 99, 255)
            })

            announceCount += 1
            if announceCount > #messageTable then
                announceCount = 1
            end

            wait(ANNOUNCE_WAIT)
        end

    end)
end

--// KnitStart
function GameChatController:KnitStart()

    self:ChatAnnouncements()

end

--// KnitInit
function GameChatController:KnitInit()

end

return GameChatController