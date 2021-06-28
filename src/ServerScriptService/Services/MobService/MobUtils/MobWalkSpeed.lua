-- MobWalkSpeed

local module = {}

function module.AddModifier(thisMob, modifierName, modifierValue)

    local humanoid = thisMob.Model:FindFirstChild("Humanoid")
    if not humanoid then return end

    local walkSpeedFolder = humanoid:FindFirstChild("WalkSpeed_Modifiers")
    if not walkSpeedFolder then
        walkSpeedFolder = Instance.new("Folder")
        walkSpeedFolder.Name = "WalkSpeed_Modifiers"
        walkSpeedFolder.Parent = humanoid
    end

    local thisModifier = walkSpeedFolder:FindFirstChild(modifierName, true)
    if thisModifier then return end

    thisModifier = Instance.new("NumberValue")
    thisModifier.Name = modifierName
    thisModifier.Value = modifierValue
    thisModifier.Parent = walkSpeedFolder

    -- calculate new walkspeed
    local newWalkSpeed = thisMob.Defs.WalkSpeed
    for _, valueObject in pairs(walkSpeedFolder:GetChildren()) do
        newWalkSpeed += valueObject.Value
    end

    humanoid.WalkSpeed = newWalkSpeed
end

function module.RemoveModifier(thisMob, modifierName)

    local humanoid = thisMob.Model:FindFirstChild("Humanoid")
    if not humanoid then return end

    local walkSpeedFolder = humanoid:FindFirstChild("WalkSpeed_Modifiers")
    if not walkSpeedFolder then 
        return
    end

    local thisModifier = walkSpeedFolder:FindFirstChild(modifierName, true)
    if thisModifier then
        thisModifier:Destroy()
    end

    -- calculate new walkspeed
    local newWalkSpeed = thisMob.Defs.WalkSpeed
    for _, valueObject in pairs(walkSpeedFolder:GetChildren()) do
        newWalkSpeed += valueObject.Value
    end

    humanoid.WalkSpeed = newWalkSpeed

end 

function module.GetWalkSpeed(thisMob)

    local humanoid = thisMob.Model:FindFirstChild("Humanoid")
    if not humanoid then return end

    local walkSpeed = thisMob.Defs.WalkSpeed

    local walkSpeedFolder = humanoid:FindFirstChild("WalkSpeed_Modifiers")
    if walkSpeedFolder then
        for _, valueObject in pairs(walkSpeedFolder:GetChildren()) do
            walkSpeed += valueObject.Value
        end
    end

    return walkSpeed

end


return module