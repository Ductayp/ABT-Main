-- AnchoredSound

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local AnchoredSound = {}

function AnchoredSound.NewSound(position, sound, params)

    -- options params
    --params.fadeTime
    --params.DebrisTime

    -- clone new part
	local thisSpeaker = SoundService.AnchoredSoundPart:Clone()
    thisSpeaker.Name = sound.Name
    thisSpeaker.Position = position
    thisSpeaker.Parent = Workspace.RenderedEffects
    
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
function AnchoredSound.StopSound(parent, name, fadeTime)
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

return AnchoredSound