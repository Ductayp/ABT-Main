-- A General Utility Module

local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

local module = {}

function module.GetPlayerFromCharacter(character)
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player.Character == character then
			return player
		end
	end
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

function module.GetPlayerByUserId(userId)
	print("Utils first ",userId)
	
	for _, player in pairs(Players:GetPlayers()) do
		print("Utils second ",player.UserId)
		if player.UserId == userId then
			print("Utils third ",player)
			return player
		end
	end
end



return module
