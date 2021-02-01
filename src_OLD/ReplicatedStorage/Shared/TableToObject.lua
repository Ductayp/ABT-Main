local module = {}
module.storage = game.ReplicatedStorage.DataReplication_2 -- change this to the right folder

module.Returned = nil -- not working, "deprecated; Don't use it."


local NewObject

local newValue = function(v, index, fold)
	local i
	if index and v and fold then
		i = index
	else
		i = #fold:GetChildren()
	end
	if typeof(fold) == "Instance" then
		if type(v) == "boolean" then
			local value = Instance.new("BoolValue")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif type(v) == "number" then
			local value = Instance.new("IntValue")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif type(v) == "string" then
			local value = Instance.new("StringValue")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif typeof(v) == "Vector3" then
			local value = Instance.new("Vector3Value")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif typeof(v) == "BrickColor" then
			local value = Instance.new("BrickColorValue")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif typeof(v) == "CFrame" then
			local value = Instance.new("CFrameValue")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif typeof(v) == "Color3" then
			local value = Instance.new("Color3Value")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif typeof(v) == "Ray" then
			local value = Instance.new("RayValue")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif typeof(v) == "Instance" then
			local value = Instance.new("ObjectValue")
			value.Name = i
			value.Value = v
			value.Parent = fold
		elseif type(v) == "table" then
			local internTable = Instance.new("Folder")
			internTable.Name = i
			internTable.Parent = fold
			NewObject(v, internTable)
		else
			warn("functions, and threads are not compatible with this module. The rest will load in correctly.")
		end	
	end
end

NewObject = function(table1, fold)
	for i, v in pairs(table1) do
		newValue(v, i, fold)
	end
	return table1
end

module.CreateObject = function(table1, tableName)
	print("yeet")
	print(table1,tableName)
	if type(table1) == "table" and tableName and not module.storage:FindFirstChild(tableName) then
		local fold = Instance.new("Folder")
		fold.Name = tostring(tableName)
		NewObject(table1, fold)
		fold.Parent = module.storage
	end
end

local insertToTable
insertToTable = function(fold, tableResult)
	for i, v in pairs(fold:GetChildren()) do
		local s, x = pcall(function()
			if v:IsA("Folder") then
				if tableResult[v.Name] ~= nil then
					print("There's a duplicated value inside of the object-based table, the actual value will be: ".. v, " The index of this update is = ".. v.Name)
				end
				if tonumber(v.Name) then
					tableResult[tonumber(v.Name)] = {}
					insertToTable(v, tableResult[tonumber(v.Name)])
				else
					tableResult[v.Name] = {}
					insertToTable(v, tableResult[v.Name])
				end
			else
				if tonumber(v.Name) then
					tableResult[tonumber(v.Name)] = v.Value
				else
					tableResult[v.Name] = v.Value
				end
			end
		end)
		if x then warn(x) end
	end
	return tableResult
end

module.CreateTable = function(tableName)
	if tableName then
		if module.storage:FindFirstChild(tableName) then
			local fold = module.storage[tableName]
			local tableMake = {}
			local tableResult = insertToTable(fold, tableMake)
			wait()
			return tableResult
		else
			return
		end
	else
		return
	end
end

function module.InsertValueInto(foldName, value, index)
	if module.storage:FindFirstChild(foldName) then
		local fold = module.storage[foldName]
		newValue(value, index, fold)
	end
end
--

return module