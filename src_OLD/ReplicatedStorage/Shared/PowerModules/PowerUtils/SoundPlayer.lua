-- SoundPlayer
-- PDab
-- 12-8-2020

-- applies both pracitcal effects and visual effects if needed

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


--modules
local utils = require(Knit.Shared.Utils)

local SoundPlayer = {}

function SoundPlayer.WeldSound(parent, sound, params)

    -- options params
    --params.fadeTime
    --params.DebrisTime

    -- find a speaker part, if not exists create it, name it the same as sound
    local thisSpeaker = Instance.new("Part")
    thisSpeaker.Name = sound.Name
    thisSpeaker.CFrame =parent.CFrame
    thisSpeaker.Size = Vector3.new(1,1,1)
    thisSpeaker.Anchored = false
    thisSpeaker.Massless = true
    thisSpeaker.CanCollide = false
    thisSpeaker.Transparency = 1
    thisSpeaker.Parent = parent
    utils.EasyWeld(thisSpeaker,target,thisSpeaker)


    -- clone the sound
    local thisSound = sound:Clone()
    thisSound.Parent = thisSpeaker


	if params then
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
	thisSound:Play()

	-- if the sound isnt looping, destroy this speaker when its done
	spawn(function()
		thisSound.Ended:Wait()
		thisSpeaker:Destroy()
    end)
    
end

--// StopSpeakerSound - stops a sound by name by destroying its speaker, can also optionally fade
function SoundPlayer.StopWeldedSound(parent, name, fadeTime)
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
							tween:Destroy()
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

--// Client_RenderEffect
function SoundPlayer.Client_RenderEffect(params)


end 


return SoundPlayer