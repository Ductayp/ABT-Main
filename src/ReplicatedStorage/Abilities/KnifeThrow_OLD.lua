-- Knife Throw Ability
-- PDab
-- 11-27-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)
local RaycastHitbox = require(Knit.Shared.RaycastHitboxV3)

-- variables
local knifeSpeed = 300 -- studs per second
local knifeDuration = 10 -- how many sencd until we destroy it

local KnifeThrow = {}

function KnifeThrow.Server_ThrowKnife(initPlayer,params,throwParams)

    --[[
    -- make a new hitPart
    local hitPart = Instance.new("Part")
    hitPart.Parent = workspace.RenderedEffects
    hitPart.Name = "KnifeHitPart"
    hitPart.Size = Vector3.new(2,2,2)
    hitPart.Color = Color3.new(170/255,0/255.0/255)
    hitPart.Transparency = .5
    hitPart.CanCollide = false
    hitPart.Anchored = false
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-1)) -- positions somewhere good near the stand
    Debris:AddItem(hitPart,knifeDuration)
    ]]--

    

    -- setup the hitBox with RaycastHitbox
    local newHitbox = RaycastHitbox:Initialize(hitPart, {initPlayer}) -- ignore the initPlayer
    local hitPoints = {}
    newHitbox:SetPoints(hitPart, {Vector3.new(0, 0, 0), Vector3.new(-2, 0, 0), Vector3.new(2, 0, 0)})
    newHitbox:DebugMode(true)

    -- set network owner
    hitPart:SetNetworkOwner(nil)

    -- Makes a new event listener for raycast hits
    newHitbox.OnHit:Connect(function(hit, humanoid)
        print(hit.Parent)
        humanoid:TakeDamage(50)
    end)

    -- add some BodyMovers
    local bodyForce = Instance.new("BodyVelocity")
    bodyForce.MaxForce = Vector3.new(40000,40000,40000)
    bodyForce.P = 1250
    bodyForce.Velocity = initPlayer.Character.HumanoidRootPart.CFrame.LookVector * knifeSpeed
    bodyForce.Parent = hitPart

    newHitbox:HitStart()
    
end

function KnifeThrow.Client_KnifeThrow(initPlayer,params,throwParams)
    
    print("client side")
    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end
    -- move the stand
    targetStand.WeldConstraint.Enabled = false
	targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-2)) -- move
    targetStand.WeldConstraint.Enabled = true
    
    for i,v in pairs(params) do 
        print(i,v)
    end


    -- create the cosmetic part mover
    local moverPart = Instance.new("Part")
    moverPart.Parent = workspace.RenderedEffects
    moverPart.Name = "KnifeMoverPart"
    moverPart.Size = Vector3.new(2,2,2)
    moverPart.Transparency = .5
    moverPart.Color = Color3.new(85/255, 170/255, 0/255)
    moverPart.CanCollide = false
    moverPart.Anchored = false
    moverPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame--:ToWorldSpace(CFrame.new(0,0,-1)) -- positions somewhere good near the stand
    --Debris:AddItem(moverPart,knifeDuration)

    -- add some BodyMovers
    local bodyForce = Instance.new("BodyVelocity")
    bodyForce.MaxForce = Vector3.new(40000,40000,40000)
    bodyForce.P = 1250
    bodyForce.Velocity = initPlayer.Character.HumanoidRootPart.CFrame.LookVector * knifeSpeed
    bodyForce.Parent = moverPart

    -- weld the cosmetic knives
    local knifeModel = ReplicatedStorage.EffectParts.Knives.Knife1
    local knives = {knife1 = knifeModel:Clone(),knife2 = knifeModel:Clone(),knife3 = knifeModel:Clone()}
    knives.knife1.CFrame = moverPart.CFrame * CFrame.new(-2,0,0)
    knives.knife2.CFrame = moverPart.CFrame * CFrame.new(0,0,0)
    knives.knife3.CFrame = moverPart.CFrame * CFrame.new(2,0,0)
    for name,model in pairs(knives) do 
        model.Parent = moverPart
        model.CFrame = moverPart.CFrame
        model.CanCollide = false
        model.Anchored = false
        utils.EasyWeld(moverPart,model,model)

    end


    -- move the stand back
    wait(1)
    targetStand.WeldConstraint.Enabled = false
	targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
	targetStand.WeldConstraint.Enabled = true

end

return KnifeThrow


