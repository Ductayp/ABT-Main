local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local enabledBool = ReplicatedFirst:FindFirstChild("LoadingScreenEnabled")
if enabledBool then
    if enabledBool.Value == false then
        return
    end
end

local LoadingScreen = ReplicatedFirst:WaitForChild("LoadingScreen", true)

Players.LocalPlayer:WaitForChild("PlayerGui")
ReplicatedFirst:RemoveDefaultLoadingScreen()
LoadingScreen.Parent = Players.LocalPlayer.PlayerGui

local LoadingInfo = LoadingScreen:FindFirstChild("LoadignInfo", true)
local LoadingBar = LoadingScreen:FindFirstChild("LoadingBar", true)
local SkipButton = LoadingScreen:FindFirstChild("SkipButton", true)
local PlayButton = LoadingScreen:FindFirstChild("PlayButton", true)
local TestServerLabel = LoadingScreen:FindFirstChild("TestServerLabel", true)

SkipButton.Visible = false
PlayButton.Visible = false
TestServerLabel.Visible = false
LoadingBar.Visible = true
LoadingBar.ProgressBar.Visible = false

-- wait for game structure
if not game:IsLoaded() then
	game.Loaded:Wait()
end

LoadingInfo.Text = "Loading Characters ..."

-- wait for character to load
if not Players.LocalPlayer.Character then
    Players.LocalPlayer.CharacterAdded:wait()
end


local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
local dataLoaded = false
for count = 1, 300 do

    local playerDataBoolean = playerDataStatuses:FindFirstChild(Players.LocalPlayer.UserId)
    if playerDataBoolean and playerDataBoolean.Value == true then
        dataLoaded = true
        break
    end

    if count < 60 then
        LoadingInfo.Text = "Loading Player Data ... " .. tostring(count)
    end

    if count >= 60 then
        LoadingInfo.Text = "Data taking longer than usual to load. You could leave and wait 10 minutes to rejoin."  .. tostring(count)
    end

    if count == 300 then
        LoadingInfo.Text = "Player Data can't load right now. Leave the game and try again in 10 minutes."
        Players.LocalPlayer:Kick()
    end

end

-- wait for test server status
local isTestServer = ReplicatedStorage:WaitForChild("TestServer", true)
if isTestServer.Value == true then
    TestServerLabel.Visible = true
else
    TestServerLabel.Visible = false
end

local thisPlayerTesterObject = isTestServer:WaitForChild(Players.LocalPlayer.UserId, true)
local isTester = thisPlayerTesterObject.Value

SkipButton.MouseButton1Down:Connect(function()
    if isTestServer.Value == true then
        if isTester == true then
            LoadingScreen.Frame.Visible = false
        end
    else
        LoadingScreen.Frame.Visible = false
    end
end)

PlayButton.MouseButton1Down:Connect(function()
    if isTestServer.Value == true then
        if isTester == true then
            LoadingScreen.Frame.Visible = false
        end
    else
        LoadingScreen.Frame.Visible = false
    end
end)

print("TESET", isTestServer.Value, isTester)

local accessAllowed
if isTestServer.Value == true and isTester == false then
    LoadingInfo.Text = "You must have the TESTER role to join this game"
    accessAllowed = false
else
    accessAllowed = true
end

if dataLoaded and accessAllowed then

    LoadingBar.ProgressBar.Visible = true
    SkipButton.Visible = true

    LoadingInfo.Text = "Loading Game Assets ... "
    wait(1)
    local MaxAssets = ContentProvider.RequestQueueSize

    repeat
        local CurrentLoaded = MaxAssets - ContentProvider.RequestQueueSize
        if CurrentLoaded < 0 then CurrentLoaded = 0 end
        local PercentLoaded =  CurrentLoaded /  MaxAssets
  
        LoadingBar.ProgressBar.Size = UDim2.new(PercentLoaded, 0, 1, 0)
        LoadingBar.ProgressText.Text = tostring(math.round(PercentLoaded * 100)) .. " % "
        
        wait(.1)
    until ContentProvider.RequestQueueSize <= 0

    LoadingInfo.Text = "All Assets Loaded"
    PlayButton.Visible = true

    LoadingBar.ProgressBar.Size = UDim2.new(1, 0, 1, 0)
    LoadingBar.ProgressText.Text = "100 %"

end






