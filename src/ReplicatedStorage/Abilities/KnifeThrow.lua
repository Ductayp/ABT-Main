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
local powerUtils = require(Knit.Shared.PowerUtils)
local RaycastHitbox = require(Knit.Shared.RaycastHitboxV3)

local KnifeThrow = {}

function KnifeThrow.Server_ThrowKnife(initPlayer,params)


    
    local hitPart = ReplicatedStorage.EffectParts.Projectiles.KnifeThrow.KnifeThrow_Server:Clone()
    hitPart.Parent = workspace.RenderedEffects
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-3)) -- positions somewhere good near the stand
    
    -- set network owner
    hitPart:SetNetworkOwner(nil)

    -- setup hitPart Touched event
    hitPart.Touched:Connect(function(hit)

        Debris:AddItem(hitPart,1) -- debris it 1 second after its first hit

        local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.Parent.Name == initPlayer.Name then
                print("this is the casting player")
            else
                print(hit.Parent)
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

function KnifeThrow.Client_KnifeThrow(initPlayer,params)
    
    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end
    -- move the stand
    targetStand.WeldConstraint.Enabled = false
	targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-2)) -- move
    targetStand.WeldConstraint.Enabled = true

    -- create the cosmetic part mover
    local clientPart = ReplicatedStorage.EffectParts.Projectiles.KnifeThrow.KnifeThrow_Client:Clone()
    clientPart.Parent = workspace.RenderedEffects
    clientPart.CFrame = params.OriginCFrame

    -- add it to Debris
    Debris:AddItem(clientPart,params.ArrivalTime)

    -- Tween it
    local tweenInfo = TweenInfo.new(
        params.ArrivalTime - os.time()
        )
    local tween = TweenService:Create(clientPart,tweenInfo,{CFrame = params.DestinatonCFrame})
    tween:Play()

    tween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            clientPart:Destroy()
        end
    end)

    -- move the stand back
    spawn(function()
        wait(1)
        targetStand.WeldConstraint.Enabled = false
        targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
        targetStand.WeldConstraint.Enabled = true
    end)
   

end

return KnifeThrow


