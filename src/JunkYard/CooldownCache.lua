-- CooldownCache
-- Easily manage remote cooldowns with this OOP-styled module! Quick and efficient. 

-- rek_kie
-- 12/20/20

-- API:

-- function cooldown.new(number timeframe)
	-- Creates a new cache object. The number you supply as a parameter will act as the cooldown time 
	-- for the cache. This object automatically sets up PlayerAdded as well as Removing connections, and 
	-- you can completely wipe the cache object with cache:Clear()

-- function cache:IsReady(userId)
	-- This is the main function you'll actually be using, this handles the functionality of the cooldown.
	-- This checks if the player is eligible to 
	-- It automatically resets the cooldown if this returns true, so it's literally as simple as this to 
	-- use with a remote (below)


-- == EXAMPLE == --

--[[
	local cache = require(script.CooldownCache)
	local remote = game:GetService("ReplicatedStorage").RemoteEvent

	local testCache = cache.new(1)

	remote.OnServerEvent:Connect(function(player)
		
		if not testCache:IsReady(player.UserId) then -- This is all you need to do to get the cooldown in place. 
			warn("Not ready") 				     -- Simple guard clause, and it resets automatically if it
			return 							-- returns true, so you don't have to reset it manually.
		end	
		
		print("YUP")
		
	end)
]]--


-- function cache:Clear()
	-- This completely clears the cache and all connections and wipes everything from memory.
	-- Should only be used if you don't need a cache anymore.

-- Enjoy this simple, but extremely powerful thing I made :)
-- Hope this becomes of use to you.


local players = game:GetService("Players")
local http = game:GetService("HttpService")

local activeCooldowns = {}
local cooldown = {}

cooldown.__index = cooldown

function cooldown.new(timeframe)
	
	local self = {}
	
	local id = http:GenerateGUID(false) 
	
	self.time = timeframe 
	self.name = id -- make a UUID
	self.cache = {}
	
	local function onPlayerAdded(player)
		if not self.cache[tostring(player.UserId)] then 
			self.cache[tostring(player.UserId)] = tick()
		end
	end
	
	local function onRemoving(player)
		if self.cache[tostring(player.UserId)] then 
			self.cache[tostring(player.UserId)] = nil
		end
	end
	
	self.connections = {
		players.PlayerAdded:Connect(onPlayerAdded), 
		players.PlayerRemoving:Connect(onRemoving)
	}
	
	for _, player in ipairs(players:GetPlayers()) do
		coroutine.wrap(onPlayerAdded)(player)
	end
	
	activeCooldowns[id] = self
	
	return setmetatable(self, cooldown)
	
end

function cooldown:IsReady(userId)
	
	local last = self.cache[tostring(userId)]
	
	if last then 
		if tick() - last < self.time then 
			return false 
		end
	end
	
	self.cache[tostring(userId)] = tick() -- automatically reset 
	
	return true 
	
end

function cooldown:Clear()
	
	for index, con in ipairs(self.connections) do -- clear from memory
		if self.connections[index] then
			self.connections[index]:Disconnect()
			self.connections[index] = nil
		end
	end
	
	if activeCooldowns[self.name] then -- clear from the master table
		activeCooldowns[self.name] = nil
	end
end


return cooldown
