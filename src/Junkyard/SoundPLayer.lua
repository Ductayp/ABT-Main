-- Sounds

local SoundService = game:GetService("SoundService")

local module = {}

function module.playLocalSound(sound,parent)
	local newSound = sound:Clone()
	if parent then
		newSound.Parent = parent
	end
	SoundService:PlayLocalSound(sound)
	newSound.Ended:Wait()
	newSound:Destroy()
end


return module
