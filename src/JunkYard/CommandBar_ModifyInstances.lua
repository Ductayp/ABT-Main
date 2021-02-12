local ReplicatedStorage = game:GetService("ReplicatedStorage")

for i,v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("Sound") then
        v.Volume = v.Volume  / 2
    end
end