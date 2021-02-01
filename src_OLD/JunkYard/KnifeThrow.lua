-- Knife Throw Ability
-- PDab
-- 11-27-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)

local KnifeThrow = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function KnifeThrow.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end
    
    -- tween effects
	KnifeThrow.Tween_Effects(params, abilityDefs)

end

--// Activate
function KnifeThrow.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end
    

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

     -- require toggles to be inactive, excluding "Q"
     if not AbilityToggle.RequireOff(params.InitUserId, abilityDefs.RequireToggle_Off) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- set toggle
    AbilityToggle.QuickToggle(params.InitUserId, params.InputId, true)

    -- tween hitbox
    --KnifeThrow.Tween_HitBox(params, abilityDefs)

end

--// Execute
function KnifeThrow.Execute(params, abilityDefs)

	if Players.LocalPlayer.UserId == params.InitUserId then
		print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end

    -- tween effects
	KnifeThrow.Tween_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function KnifeThrow.Tween_HitBox(params, abilityDefs)


    local hitPart = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.KnifeThrow_Server:Clone()
    hitPart.Parent = workspace.RenderedEffects
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-6)) -- positions somewhere good near the stand
    hitPart.Transparency = 1
    
    -- set network owner
    hitPart:SetNetworkOwner(nil)

    local charactersHit = {} -- a list of player hit
    local canHit = true -- a boolean the toggles if the hitbox can add player to the charactersHit table
    local reportOnce = true -- this boolean gets set once and makes it so the funcytion reports damage only once
    hitPart.Touched:Connect(function(hit)
        if canHit == true then

            local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                if humanoid.Parent.Name ~= initPlayer.Name then
                    charactersHit[hit.Parent] = true
                end
            end

            if reportOnce == true then
                reportOnce = false
                spawn(function()

                    wait(.5)
                    hitPart:Destroy()
                    canHit = false
                    if charactersHit ~= nil then
                        for characterHit,boolean in pairs (charactersHit) do -- we stored the character hit in the InputId above
                            print("boop")
                            Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,params.KnifeThrow.HitEffects)
                            print("boop")
                        end
                    end	
                end)
            end
        end
    end)

    -- calculate flight data
    params.OriginCFrame = hitPart.CFrame
    params.DestinatonCFrame = hitPart.CFrame:ToWorldSpace(CFrame.new( 0, 0, -params.KnifeThrow.Range))
    params.FlightTime = (params.KnifeThrow.Range / params.KnifeThrow.Speed)
    params.DepartureTime = os.time()
    params.ArrivalTime = os.time() + params.FlightTime

    -- add to Debris
    Debris:AddItem(hitPart,params.FlightTime)

    -- Tween hitbox
    local tweenInfo = TweenInfo.new(
            params.FlightTime - Knit.Services.PlayerUtilityService:GetPing(initPlayer)
        )
    local tween = TweenService:Create(hitPart,tweenInfo,{CFrame = params.DestinatonCFrame})
    tween:Play()

    tween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            hitPart:Destroy()
        end
    end)
end

function KnifeThrow.Tween_Effects(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		ManageStand.QuickRender(params)
    end

    -- run animation
    ManageStand.PlayAnimation(params, "KnifeThrow")
    ManageStand.MoveStand(params, {AnchorName = "Front"})
    spawn(function()
        wait(.5)
        ManageStand.MoveStand(params, {AnchorName = "Idle"})
    end)

    -- clone in all parts
    local mainPart = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.KnifeThrow_Client:Clone()
    --mainPart.Name = "MainPart" -- name it so its easy to find later 
    mainPart.Parent = workspace.RenderedEffects
    --mainPart.CFrame = params.OriginCFrame
    

    -- Tween the thrown parts
    local ping = Knit.Controllers.PlayerUtilityController:GetPing()
    local newSpeed = params.FlightTime - ping
    local tweenInfo2 = TweenInfo.new(newSpeed, Enum.EasingStyle.Linear)
    local tweenMainPart = TweenService:Create(mainPart,tweenInfo2,{CFrame = params.DestinatonCFrame})

    -- CFrame the parts right before we launch them
    mainPart.CFrame = params.OriginCFrame
    tweenMainPart:Play()

    -- destroy when tween is done
    tweenMainPart.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            mainPart:Destroy()
        end
    end)

    -- setup destroying cosmetic parts, destroy when it hits a humanoid
    mainPart.Touched:Connect(function(hit)
        local hitToggle = true
        local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.Parent.Name ~= initPlayer.Name then

                if hitToggle == true then
                    hitToggle = false
                    local effectParams = {
                        HideNumbers = true,
                        HitCharacter = humanoid.Parent
                    }
                    require(Knit.Effects.Damage).Client_RenderEffect(effectParams)
                end

                wait(.25)
                mainPart:Destroy()
            end
        end
    end) 

end

return KnifeThrow
