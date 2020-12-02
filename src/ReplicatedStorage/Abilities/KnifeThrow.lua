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
local ManageStand = require(Knit.Abilities.ManageStand)

local KnifeThrow = {}

function KnifeThrow.Server_ThrowKnife(initPlayer,params)

    local hitPart = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.KnifeThrow_Server:Clone()
    hitPart.Parent = workspace.RenderedEffects
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-3)) -- positions somewhere good near the stand
    
    -- set network owner
    hitPart:SetNetworkOwner(nil)

    -- setup hitBox and Touched event
    local hitParams = {}
    hitParams.Damage = params.KnifeThrow.Damage

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
                            Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,hitParams)
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

function KnifeThrow.Client_KnifeThrow(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end

    -- run animation
    ManageStand.PlayAnimation(initPlayer,params,"KnifeThrow")
    
    -- clone in all parts
    local mainPart = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.KnifeThrow_Client_3:Clone()
    mainPart.Parent = workspace.RenderedEffects
    mainPart.CFrame = params.OriginCFrame
    mainPart.Name = "MainPart" -- name it so its easy to find later 

    local shock_1 = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.Shock1:Clone()
    local shock_2 = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.Shock2:Clone()
    shock_1.Parent = workspace.RenderedEffects
    shock_2.Parent = workspace.RenderedEffects
    shock_1.CFrame = params.OriginCFrame:ToWorldSpace(CFrame.new(0,0,-2.5))
    shock_2.CFrame = params.OriginCFrame:ToWorldSpace(CFrame.new(0,0,-2.5))

    local spiral_1 = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.Spiral:Clone()
    local spiral_2 = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.Spiral:Clone()
    local spiral_3 = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.Spiral:Clone()
    spiral_1.Parent = workspace.RenderedEffects
    spiral_2.Parent = workspace.RenderedEffects
    spiral_3.Parent = workspace.RenderedEffects
    spiral_1.CFrame = mainPart.Spindle_1.CFrame
    spiral_2.CFrame = mainPart.Spindle_2.CFrame
    spiral_3.CFrame = mainPart.Spindle_3.CFrame

    -- spawn the stand move and shockwave aniamtions
    spawn(function()
        -- move the stand
        targetStand.WeldConstraint.Enabled = false
        targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-2)) -- move
        targetStand.WeldConstraint.Enabled = true

        -- create shock tween effects
        local tweenInfo1 = TweenInfo.new(.7)
        local shockSize_1 = TweenService:Create(shock_1.Shock,tweenInfo1,{Size = (shock_1.Size + Vector3.new(5,5,5))})
        local shockSize_2 = TweenService:Create(shock_2.Shock,tweenInfo1,{Size = (shock_1.Size + Vector3.new(3,3,3))})
        local shockTransparency_1 = TweenService:Create(shock_1.Shock,tweenInfo1,{Transparency = 1})
        local shockTransparency_2 = TweenService:Create(shock_2.Shock,tweenInfo1,{Transparency = 1})

        shockSize_1:Play()
        shockSize_2:Play()
        shockTransparency_1:Play()
        shockTransparency_2:Play()

        shockSize_1.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                shock_1:Destroy()
                shock_2:Destroy()
            end
        end)

        -- move the stand back
        wait(.5)
        targetStand.WeldConstraint.Enabled = false
        targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
        targetStand.WeldConstraint.Enabled = true
    end)
    

    -- create spiral effect destinations for tweens
    local spiral_1_Destination = spiral_1.CFrame:ToWorldSpace(CFrame.new( 0, 0, -params.KnifeThrow.Range))
    local spiral_2_Destination = spiral_2.CFrame:ToWorldSpace(CFrame.new( 0, 0, -params.KnifeThrow.Range))
    local spiral_3_Destination = spiral_3.CFrame:ToWorldSpace(CFrame.new( 0, 0, -params.KnifeThrow.Range))

    -- Tween the thrown parts
    local newSpeed = params.ArrivalTime - os.time()
    if newSpeed < 1 then
        newSpeed = 1
    end
    local tweenInfo2 = TweenInfo.new(newSpeed)
    local tweenMainPart = TweenService:Create(mainPart,tweenInfo2,{CFrame = params.DestinatonCFrame})
    local tweenSpiral_1 = TweenService:Create(spiral_1,tweenInfo2,{CFrame = spiral_1_Destination})
    local tweenSpiral_2 = TweenService:Create(spiral_2,tweenInfo2,{CFrame = spiral_2_Destination})
    local tweenSpiral_3 = TweenService:Create(spiral_3,tweenInfo2,{CFrame = spiral_3_Destination})

    -- CFrame the parts A SECOND TIME right before we launch them
    mainPart.CFrame = params.OriginCFrame
    tweenMainPart:Play()

    spiral_1.CFrame = mainPart.Spindle_1.CFrame
    tweenSpiral_1:Play()

    spiral_2.CFrame = mainPart.Spindle_2.CFrame
    tweenSpiral_2:Play()

    spiral_3.CFrame = mainPart.Spindle_3.CFrame
    tweenSpiral_3:Play()
    
    -- destroy when tween is done
    tweenMainPart.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            local parts = {mainPart,spiral_1,spiral_2,spiral_3}
            local endingCFrame = mainPart.CFrame
            KnifeThrow.DestroyCosmetics(parts,endingCFrame)
        end
    end)

    -- setup destroying cosmetic parts, destroy when it hits a humanoid
    mainPart.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.Parent.Name ~= initPlayer.Name then
                --wait(.5)
                local parts = {mainPart,spiral_1,spiral_2,spiral_3}
                local endingCFrame = hit.CFrame
                KnifeThrow.DestroyCosmetics(parts,endingCFrame)
            end
        end
    end)
end


function KnifeThrow.DestroyCosmetics(parts,endingCFrame)

    -- run explosion effect only if the cosmetics parts are still in workspace.RenderedEffects
    if parts[1].Parent == workspace.RenderedEffects then 
        local swirlShock = ReplicatedStorage.EffectParts.Abilities.KnifeThrow.SwirlShock:Clone()
        swirlShock.CFrame = endingCFrame
        swirlShock.Parent = workspace.RenderedEffects

        local tweenInfo = TweenInfo.new(.5)
        local swirlSize = TweenService:Create(swirlShock,tweenInfo,{Size = (swirlShock.Size + Vector3.new(5,5,5))})
        swirlSize:Play()

        swirlSize.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                swirlShock:Destroy()
            end
        end)
    end

    for i,v in pairs(parts) do 
        v:Destroy()
    end

end

return KnifeThrow


