-- Zone Service
-- PDab
-- 12/24/2020

--[[ ZONE SERVICE
Zone service defines some zones using Part to Region3 math and/or magnitude checks to detemrine if players are in a zone or not. 
Any number of actions can be taken depending on the zone, for example adding a Safe State to ZoneService for the player if they enter a safe zone

ZoneService is paired with ZoneController
Actively looping zone checks are done by the client for themselves. Ff they enter a zone, ZoneController contact ZoneService to verify, and then action can be taken.
]]--

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ZoneService = Knit.CreateService { Name = "ZoneService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)

-- a table to hold all the zone
local zoneTable = {}


--// PartToRegion3 -- this has some voodoo magic in it that i havent bothered to understand but it probably works
-- if you give it a part that is rotated, it will return a region3 based ont he bounding box of the part
function ZoneService:PartToRegion3(part)
	local abs = math.abs

	local cf = part.CFrame -- this causes a LuaBridge invocation + heap allocation to create CFrame object - expensive! - but no way around it. we need the cframe
	local size = part.Size -- this causes a LuaBridge invocation + heap allocation to create Vector3 object - expensive! - but no way around it
	local sx, sy, sz = size.X, size.Y, size.Z -- this causes 3 Lua->C++ invocations

	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() -- this causes 1 Lua->C++ invocations and gets all components of cframe in one go, with no allocations

	-- https://zeuxcg.org/2010/10/17/aabb-from-obb-with-component-wise-abs/
	local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz) -- this requires 3 Lua->C++ invocations to call abs, but no hash lookups since we cached abs value above; otherwise this is just a bunch of local ops
	local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz) -- same
	local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz) -- same
	
	-- just a bunch of local ops
	local minx = x - wsx
	local miny = y - wsy
	local minz = z - wsz

	local maxx = x + wsx
	local maxy = y + wsy
	local maxz = z + wsz
   
	local minv, maxv = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return Region3.new(minv, maxv)
end

--// Client:UpdateZones
function ZoneService.Client:UpdateZones(player,activeZones)
    
    for zoneName,_ in pairs(activeZones) do

        if zoneName == "Safe" then
            self:
        end
    end

end

--// Client:GetAllZones
function ZoneService.Client:GetAllZones()
    return zoneTable
end

--// CreateZoneFromPart
function ZoneService:CreateZoneFromPart(part)

    local newZone = self:PartToRegion3(part)
    zoneTable[part.Name] = newZone
end

--// PlayerJoined
function ZoneService:PlayerAdded(player)


end

--// KnitStart
function ZoneService:KnitStart()

    for _,descendant in pairs(Workspace:GetDescendants()) do
        if descendant.Name == "ZoneService" then
            for _,part in pairs(descendant:GetChildren()) do
                self:CreateZoneFromPart(part)
            end
        end
    end
 


end

--// KnitInit
function ZoneService:KnitInit()

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        --self:PlayerRemoved(player)
    end)

end


return ZoneService