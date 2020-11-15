-- Powers Service
-- PDab
-- 11/2/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersService = Knit.CreateService { Name = "PowersService", Client = {}}


--// Client:ActivatePower -- fired by client to activate apower
function PowersService.Client:ActivatePower(player,params)
    
    local powerModule = require(Knit.Powers[params.PowerID])
    

    -- RUN CHECKS
    -- sanity check
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData.Character.CurrentPower == params.PowerId then
        print("PlayerData doesn't match the PowerID sent")
        return
    end

    -- cooldown check
    if not powerStatus[player.UserId].Cooldowns[params.AbilityID] then
        powerStatus[player.UserId].Cooldowns[params.AbilityID] = os.time() - 1
    end
    if os.time() < powerStatus[player.UserId].Cooldowns[params.AbilityID] then
        return
    end

    -- override check - if an ability override is true, no other ability can fire while it is toggled on
    for i,v in pairs(powerStatus[player.UserId].Toggles) do
        print(i,v)
        --[[
		if v == true then
			local overrideValue = powerModule.Defs.Abilities[v.Name].Override
			if overrideValue and dictionary.KeyState == "InputBegan" then
				print("override")
				return
			end
        end
        ]]--
    end
    
    -- pre-requisites check
    local thisPreReq = powerModule.Defs.Abilities[params.AbilityID].AbilityPreReq
	if thisPreReq then
		for i,v in pairs(thisPreReq) do
			local thisToggle = powerStatus[player.UserId].Toggles[params.AbilityID]
			if not thisToggle then
                return
			end
		end
    end
    
    -- RUN ABILITY
    -- set cooldowns
	if params.KeyState == "InputBegan" then
		powerStatus[player.UserId].Cooldowns[params.AbilityID] = os.time() + powerModule.Defs.Abilities[params.AbilityID].CoolDown_InputBegan
	end
	if params.KeyState == "InputEnded" then
		powerStatus[player.UserId].Cooldowns[params.AbilityID] = os.time() + powerModule.Defs.Abilities[params.AbilityID].CoolDown_InputEnded
    end

    -- set toggle
    if powerModule.Defs.Abilities[params.AbilityID].Toggles then
        if powerStatus[player.UserId].Toggles[params.AbilityID] then
            powerStatus[player.UserId].Toggles[params.AbilityID] = false
        else
            powerStatus[player.UserId].Toggles[params.AbilityID] = true
        end
        params.Toggle = powerStatus[player.UserId].Toggles[params.AbilityID]
    end
    
    -- activate ability
    params.SystemStage = "Activate"
    params.CanRun = false
    powerModule[params.AbilityID](player,params,toggle)

    if params.CanRun then
        -- fire all clients
    end

end

--// SetPower -- sets the players curret power
function PowersService:SetPower(player,power)
    print("SetPower: ",power," - For player: ",player)
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    playerData.Character.CurrentPower = power
    Knit.Services.DataReplicationService:UpdateAll(player)
end

--// PlayerSetup - fires when the player joins and after each death
function PowersService:PlayerSetup(player)
    
    -- Setup the PlayerStand folder - destroys the stand folder along with contents, then recreates it
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(player.UserId)
    if not playerStandFolder then
        playerStandFolder = Instance.new("Folder")
        playerStandFolder.Name = player.UserId
        playerStandFolder.Parent = workspace:FindFirstChild('PlayerStands')
    end
    
    playerStandFolder:ClearAllChildren() -- clear the stand completely

    -- Setup the PowerStatus folders. clears itself and gets ready for new statuses
    local playerStatusFolder = ReplicatedStorage.PowerStatus:FindFirstChild (player.userId)
    if not playerStatusFolder then
        playerStatusFolder = Instance.new("Folder")
        playerStatusFolder.Name = player.UserId
        playerStatusFolder.Parent = ReplicatedStorage.PowerStatus
    end

    playerStatusFolder:ClearAllChildren()



    --[[
    powerStatus[player.UserId] = {}
    powerStatus[player.UserId].Toggles = {}
    powerStatus[player.UserId].Cooldowns = {}
    ]]--

    Knit.Services.DataReplicationService:UpdateAll(player)
end

--// KnitStart
function PowersService:KnitStart()

end

--// KnitInit - runs at server startup
function PowersService:KnitInit()

    -- setup some folder in Workspace
    local effectFolder = Instance.new("Folder")
    effectFolder.Name = "LocalPowersEffects"
    effectFolder.Parent = workspace

    local standFolder = Instance.new("Folder")
    standFolder.Name = "PlayerStands"
    standFolder.Parent = workspace

    -- setup the Power Status folder in ReplciatedStorage
    local statusFolder - Instance.new("Folder")
    statusFolder.Name = "PowerStatus"
    statusFolder.Parent = ReplicatedStorage

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerSetup(player)
        player.CharacterAdded:Connect(function()
            self:PlayerSetup(player)
        end)
    end)

    -- Player Added event for studio testing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerSetup(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        workspace.PlayerStands:FindFirstChild(player.UserId):Destroy()
        ReplicatedStorage.PowerStatus:FindFirstChild(player.UserId):Destroy()
    end)

    -- Buttons setup - this is for testing, delete it later
    for i,v in pairs (workspace.StandButtons:GetChildren()) do
        v.Touched:Connect(function(hit)
            local db = false
            if db == false then db = true
                local humanoid = hit.Parent:FindFirstChild("Humanoid")
                if humanoid then
                    local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
                    if player then
                        self:SetPower(player,v.Name)
                    end
                end
                wait(0.5)
                db = false
            end
        end)
    end

end

return PowersService