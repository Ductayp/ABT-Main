-- IMPORTANT!
-- this module is required at serveer start by PowersService, this is important because it let this code run immeditaly
-- this is how we know the IgnoreProjectiles folder is alway available

local Workspace = game:GetService("Workspace")

local ignoreFolder = Instance.new("Folder")
ignoreFolder.Name = "IgnoreProjectiles"
ignoreFolder.Parent = Workspace

local ignoreList = {}

table.insert(ignoreList, ignoreFolder)

for i, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("Folder") then

        local ignore = v:GetAttribute("IgnoreProjectiles")
        if ignore then
            table.insert(ignoreList, v)
        end
    end
end

return {
    ignoreList
}

