-- WeldedSound
-- PDab
-- 12-8-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

--modules
local utils = require(Knit.Shared.Utils)

local WeldedSound = {}

function WeldedSound.NewSound(parent, sound, params)

    -- options params
    --params.fadeTime
    --params.DebrisTime

    -- clone new part
	local thisSpeaker = SoundService.WeldedSoundPart:Clone()
    thisSpeaker.Name = sound.Name
    thisSpeaker.CFrame = parent.CFrame
    thisSpeaker.Parent = parent
    utils.EasyWeld(thisSpeaker, parent, thisSpeaker)

    -- clone the sound
    local thisSound = sound:Clone()
	thisSound.Parent = thisSpeaker
	thisSound.SoundGroup = SoundService.SFX

	if params then

		-- set speaker part properties
		if params.SpeakerProperties ~= nil then
			for propertyName,propertyValue in pairs(params.SpeakerProperties) do 
				thisSpeaker[propertyName] = propertyValue
			end
		end

		-- set properties for sound
		if params.SoundProperties ~= nil then
			for propertyName,propertyValue in pairs(params.SoundProperties) do 
				thisSound[propertyName] = propertyValue
			end
		end

		-- set Debris
		if params.Debris ~= nil then
			Debris:AddItem(thisSpeaker, params.Debris)
		end
	end

	-- play it
	wait()
	thisSound:Play()

	-- if the sound isnt looping, destroy this speaker when its done
	spawn(function()
		thisSound.Ended:Wait()
		thisSpeaker:Destroy()
	end)
	
	return thisSpeaker
    
end

--// StopSpeakerSound - stops a sound by name by destroying its speaker, can also optionally fade
function WeldedSound.StopSound(parent, name, fadeTime)
	local thisSpeaker = parent:FindFirstChild(name)
	
	if thisSpeaker then
		for _,sound in pairs(thisSpeaker:GetChildren()) do 
			if sound:IsA ("Sound") then
				sound.Looped = false
				if fadeTime then
					local tween = TweenService:Create(sound,TweenInfo.new(fadeTime),{Volume = 0})
					tween:Play()
					tween.Completed:Connect(function(State)
						if State == Enum.PlaybackState.Completed then
							sound:Destroy()
							tween = nil
							thisSpeaker:Destroy()
						end
					end)
				else
					thisSpeaker:Destroy()
				end
			end
		end
	end 
end

return WeldedSound