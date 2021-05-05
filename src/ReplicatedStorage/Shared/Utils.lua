-- A General Utility Module

local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

local module = {}

--Get playeer by UserId
function module.GetPlayerByUserId(userId)
	for _, player in pairs(Players:GetPlayers()) do
		if player.UserId == userId then
			return player
		end
	end
end

-- get character form player
function module.GetPlayerFromCharacter(character)
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player.Character == character then
			return player
		end
	end
end

function module.LookAt(eye, target)
	local forwardVector = (target - eye).Unit
	local upVector = Vector3.new(0, 1, 0)
	-- You have to remember the right hand rule or google search to get this right
	local rightVector = forwardVector:Cross(upVector)
	local upVector2 = rightVector:Cross(forwardVector)
	
	return CFrame.fromMatrix(eye, rightVector, upVector2)
end

--// ConvertToHMS - cpmbverts seconds to HH:MM:SS
function module.ConvertToHMS(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end

--// CommaValue - converts a number to have commas
function module.CommaValue(amount)
	local formatted = amount
	while true do  
	  formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	  if (k==0) then
		break
	  end
	end
	return formatted
  end

--// EASY CLONE
function module.EasyClone(object, dictionary)
	local newClone = object:Clone();
	
	for Name, Value in pairs(dictionary) do
		newClone[Name] = Value;
	end
	
	return newClone;
end

--// EASY DEBRIS
function module.EasyDebris(object,duration)
	debris:AddItem(object,duration)
end

--// EASY INSTANCE
function module.EasyInstance(instanceType,dictionary)
	local newInstance = Instance.new(instanceType)
	
	for Name, Value in pairs(dictionary) do
		newInstance[Name] = Value;
	end 
	
	return newInstance
end

--// EASY EVENT
function module.EasyRemoteEvent(eventName,parent)
	local eventFolder = replicatedStorage:FindFirstChild("GameEvents")
	if not eventFolder then
		eventFolder = module.EasyInstance("Folder",{Parent = replicatedStorage,Name = "GameEvents"})
	end
	local newEvent = Instance.new("RemoteEvent")
	newEvent.Name = eventName
	if parent then
		newEvent.Parent = parent
	else
		newEvent.Parent = eventFolder
	end
	return newEvent
end

--// EASY WELD
function module.EasyWeld(part1,part0,parent)
	local newWeld = Instance.new("WeldConstraint")
	newWeld.Parent = parent
	newWeld.Part1 = part1
	newWeld.Part0 = part0
	
	return newWeld
end


--// NEW VALUE OBJECT
function module.NewValueObject(name,value,parent)
	
	local NewValue
	if type(value) == "number" then
		NewValue = Instance.new("NumberValue")
	elseif type(value) == "boolean" then
		NewValue = Instance.new("BoolValue")
	elseif type(value) == "string" then
		NewValue = Instance.new("StringValue")
	elseif value == nil then
		return
	end

	
	-- assign a name if argument exists
	if name then
		NewValue.Name = name
	end
	
	-- set value if argument exists
	if value then
		NewValue.Value = value
	end
	
	-- set parent if argument exists
	if parent then
		NewValue.Parent = parent
	end
	
	return NewValue
	
end

--// shallow copy table
function module.ShallowCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

--// deep copy table
function module.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return module
