-- Stand Reveal
-- PDab
-- 1/3/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.GetService("InventoryService")
local GamePassService = Knit.GetService("GamePassService")
local PowersService = Knit.GetService("PowersService")
local CutSceneService = Knit.GetService("CutSceneService")

-- utils
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui_OLD", 120)

-- Constants
local GUI_COLOR = {
    COMMON = Color3.new(239/255, 239/255, 239/255),
    RARE = Color3.new(10/255, 202/255, 0/255),
    LEGENDARY = Color3.new(255/255, 149/255, 43/255)
}

local StandReveal = {}

StandReveal.Main_Frame = mainGui.Overlays:FindFirstChild("Stand_Reveal", true)
StandReveal.Button_Frame = StandReveal.Main_Frame:FindFirstChild("Button_Frame", true)
StandReveal.Stand_Name = StandReveal.Main_Frame:FindFirstChild("Stand_Name", true)
StandReveal.Stand_Rank = StandReveal.Main_Frame:FindFirstChild("Stand_Rank", true)
StandReveal.Equip_Button = StandReveal.Main_Frame:FindFirstChild("Equip_Button", true)
StandReveal.Store_Button = StandReveal.Main_Frame:FindFirstChild("Store_Button", true)

-- a table of elements for convenience
local elements = {
    StandReveal.Main_Frame,
    StandReveal.Button_Frame,
    StandReveal.Stand_Name,
    --StandReveal.Stand_Rank,
}

local revealedStandData 
local buttonsEnabled = true



--// Setup_StandReveal ------------------------------------------------------------
function StandReveal.Setup()

    -- turn off all elements
    for _,element in pairs(elements) do
        element.Visible = false
    end

    -- setup the buttons
    StandReveal.Equip_Button.Activated:Connect(function()
        StandReveal.ActivateClose()
        Knit.Controllers.GuiController.InventoryWindow.Close()
    end)
    StandReveal.Store_Button.Activated:Connect(function()
        InventoryService:SellStand(revealedStandData.GUID)
        StandReveal.ActivateClose()
        Knit.Controllers.GuiController.InventoryWindow.Open("Item_Panel")
    end)

end

--// ActivateClose ------------------------------------------------------------
function StandReveal.ActivateClose()

    -- hide all
    for _,element in pairs(elements) do
        element.Visible = false
    end

    -- show the stand in BottomGui when we close this
    --require(Knit.GuiModules.BottomGui).ShowStand()

    local sceneParams = {}
    sceneParams.Stage = "End"
    sceneParams.SceneName = "UseArrow"
    CutSceneService:LoadScene_SinglePlayer(sceneParams)
end

--// Update ------------------------------------------------------------
function StandReveal.Update(standData, params)

    print("STAND REVEAL UPDATE", data, params)

    -- hide the current stand text until after the reveal
    --require(Knit.GuiModules.BottomGui).HideStand()

    StandReveal.Equip_Button.Visible = false
    StandReveal.Store_Button.Visible = false
    buttonsEnabled = false

    revealedStandData = standData
    
    -- get the module for the stand that just got revealed, also the players CurrentStand, we need this to get the actual name
    local currentPowerModule = Knit.Powers:FindFirstChild(standData.Power)
    local powerModule = require(currentPowerModule)

    local allStandNames = {}
    for name, _ in pairs(params.AllStands) do
        table.insert(allStandNames, name)
    end

        -- turn on all elements
    for _,element in pairs(elements) do
        element.Visible = true
    end

    if params.HasArrowPass then
        StandReveal.Stand_Rank.Visible = true
    else
        StandReveal.Stand_Rank.Visible = false
    end

    local iterations = 20
    local iterationWait = .01
    for count = 1, iterations do

        local namePick = math.random(1, #allStandNames)
        local randomName = allStandNames[namePick]
        StandReveal.Stand_Name.Text = randomName

        local tempRank = math.random(1,100)
        if tempRank < 33 then
            StandReveal.Stand_Rank.star_1.Visible = true
            StandReveal.Stand_Rank.star_2.Visible = false
            StandReveal.Stand_Rank.star_3.Visible = false
        elseif tempRank < 66 then
            StandReveal.Stand_Rank.star_1.Visible = true
            StandReveal.Stand_Rank.star_2.Visible = true
            StandReveal.Stand_Rank.star_3.Visible = false
        else
            StandReveal.Stand_Rank.star_1.Visible = true
            StandReveal.Stand_Rank.star_2.Visible = true
            StandReveal.Stand_Rank.star_3.Visible = true
        end

        wait(iterationWait)
        iterationWait = iterationWait + .01
        
    end

    --wait(params.RevealDelay)

    -- set things based on Rank
    StandReveal.Stand_Name.Text = powerModule.Defs.PowerName
    if standData.Rank == 1 then
        StandReveal.Stand_Rank.star_1.Visible = true
        StandReveal.Stand_Rank.star_2.Visible = false
        StandReveal.Stand_Rank.star_3.Visible = false
    elseif standData.Rank == 2 then
        StandReveal.Stand_Rank.star_1.Visible = true
        StandReveal.Stand_Rank.star_2.Visible = true
        StandReveal.Stand_Rank.star_3.Visible = false
    elseif standData.Rank == 3 then
        StandReveal.Stand_Rank.star_1.Visible = true
        StandReveal.Stand_Rank.star_2.Visible = true
        StandReveal.Stand_Rank.star_3.Visible = true
    end



    require(Knit.GuiModules.BottomGui).ShowStand()
    buttonsEnabled = true
    StandReveal.Equip_Button.Visible = true
    StandReveal.Store_Button.Visible = true



end

--// RevealStand ------------------------------------------------------------
function StandReveal.RevealStand()


end

return StandReveal