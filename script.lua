local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer

-- CONFIGURATION
local SOUND_ID = "rbxassetid://6968135315"
local TARGET_TOOL_NAME = "Gun"
local COOLDOWN_DURATION = 2 -- Seconds to keep stopping animations after unequip

-- SETUP SOUND
local actionSound = Instance.new("Sound")
actionSound.SoundId = SOUND_ID
actionSound.Volume = 1
actionSound.Parent = SoundService

--------------------------------------------------
-- CORE LOGIC
--------------------------------------------------
local function setupGunSystem(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local animator = humanoid and humanoid:WaitForChild("Animator", 10)
	
	-- Track when the gun was last put away
	local lastUnequippedTime = 0
	
	-- 1. ANIMATION STOPPER LOGIC
	if animator then
		animator.AnimationPlayed:Connect(function(track)
			local tool = character:FindFirstChildOfClass("Tool")
			local isHoldingGun = (tool and tool.Name == TARGET_TOOL_NAME)
			
			-- Calculate how long it has been since we unequipped using os.clock()
			local timeSinceUnequip = os.clock() - lastUnequippedTime
			local withinCooldown = timeSinceUnequip <= COOLDOWN_DURATION
			
			-- Stop animation if holding the gun OR if we are within the cooldown window
			if isHoldingGun or withinCooldown then
				if track.Priority == Enum.AnimationPriority.Action then
					track:Stop()
				end
			end
		end)
	end
	
	-- 2. SOUND EFFECT & TIMESTAMP LOGIC
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child.Name == TARGET_TOOL_NAME then
			actionSound:Play()
		end
	end)
	
	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") and child.Name == TARGET_TOOL_NAME then
			actionSound:Play()
			-- Update the timestamp the moment the gun is unequipped
			lastUnequippedTime = os.clock()
		end
	end)
end

--------------------------------------------------
-- INITIALIZATION
--------------------------------------------------
local function onCharacterAdded(character)
	setupGunSystem(character)
end

-- Handle the case where the character already exists
if player.Character then
	onCharacterAdded(player.Character)
end

-- Handle characters spawning in the future (เติมส่วนนี้ที่ขาดหายไป)
player.CharacterAdded:Connect(onCharacterAdded)
