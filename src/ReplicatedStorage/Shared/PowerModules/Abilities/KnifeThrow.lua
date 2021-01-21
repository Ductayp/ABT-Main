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

-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)

-- Effect modules
local Damage = require(Knit.Effects.Damage)

local KnifeThrow = {}

function KnifeThrow.Server_Activate(initPlayer,params)
    
    local hitPart = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.KnifeThrow_Server:Clone()
    hitPart.Parent = workspace.RenderedEffects
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-3)) -- positions somewhere good near the stand
    
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
                            Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,params.KnifeThrow.HitEffects)
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
            params.FlightTime
        )
    local tween = TweenService:Create(hitPart,tweenInfo,{CFrame = params.DestinatonCFrame})
    tween:Play()

    tween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            hitPart:Destroy()
        end
    end)
end

function KnifeThrow.Client_Execute(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end

    -- run animation
    spawn(function()
        ManageStand.PlayAnimation(initPlayer,params,"KnifeThrow")
        ManageStand.MoveStand(initPlayer,{AnchorName = "Front"})
        wait(.5)
        ManageStand.MoveStand(initPlayer,{AnchorName = "Idle"})
    end)
    
    -- clone in all parts
    local mainPart = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.KnifeThrow_Client:Clone()
    mainPart.Parent = workspace.RenderedEffects
    mainPart.CFrame = params.OriginCFrame
    mainPart.Name = "MainPart" -- name it so its easy to find later 

    -- Tween the thrown parts
    local newSpeed = params.ArrivalTime - os.time()
    if newSpeed < 1 then
        newSpeed = 1
    end
    local tweenInfo2 = TweenInfo.new(newSpeed, Enum.EasingStyle.Linear)
    local tweenMainPart = TweenService:Create(mainPart,tweenInfo2,{CFrame = params.DestinatonCFrame})

    -- CFrame the parts A SECOND TIME right before we launch them
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
        local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.Parent.Name ~= initPlayer.Name then
                mainPart:Destroy()
            end
        end
    end)

end

return KnifeThrow


