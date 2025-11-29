-- @ScriptType: ModuleScript
--// MorphService.lua
-- Handles applying/removing morphs for brainrots

local MorphService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local BrainrotConfig = require(ReplicatedStorage.Shared.Config.BrainrotConfig)
local MorphFolder = ReplicatedStorage:WaitForChild("Morphs")

-- activeMorphs[player] = cloned morph model
local activeMorphs = {}

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------
local function destroyAccessoriesRecursive(char)
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("Accessory") then
			v:Destroy()
		end
	end
end

local function hideBaseRig(char)
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
			child.Transparency = 1
			for _, d in ipairs(child:GetChildren()) do
				if d:IsA("Decal") or d:IsA("Texture") then
					d.Transparency = 1
				end
			end
		elseif child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
			child:Destroy()
		end
	end

	local head = char:FindFirstChild("Head")
	if head then
		for _, d in ipairs(head:GetChildren()) do
			if d:IsA("Decal") or d:IsA("Texture") then
				d.Transparency = 1
			end
		end

		head.ChildAdded:Connect(function(d)
			if d:IsA("Decal") or d:IsA("Texture") then
				d.Transparency = 1
			end
		end)
	end
end

-- Preload animations to avoid T-POSE issue
local function preloadAnimations(animIds)
	local animObjects = {}

	for _, id in ipairs(animIds) do
		if id then
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://" .. id
			table.insert(animObjects, anim)
		end
	end

	if #animObjects > 0 then
		ContentProvider:PreloadAsync(animObjects)
	end

	return animObjects
end

--------------------------------------------------------------------
-- REMOVE MORPH
--------------------------------------------------------------------
function MorphService.RemoveMorph(player)
	local morph = activeMorphs[player]
	if morph then
		morph:Destroy()
		activeMorphs[player] = nil
	end

	local char = player.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local motor = hrp:FindFirstChild("MorphRoot")
			if motor then
				motor:Destroy()
			end
		end
	end
end

--------------------------------------------------------------------
-- APPLY MORPH
--------------------------------------------------------------------
function MorphService.ApplyMorph(player, brainrotId)
	MorphService.RemoveMorph(player)

	local cfg = BrainrotConfig[brainrotId]
	if not cfg then
		warn("MorphService: No config for brainrot", brainrotId)
		return
	end

	local modelName = cfg.morphModel
	if not modelName then
		warn("MorphService: No morphModel in config for:", brainrotId)
		return
	end

	local morphTemplate = MorphFolder:FindFirstChild(modelName)
	if not morphTemplate then
		warn("MorphService: Model not found in ReplicatedStorage.Morphs:", modelName)
		return
	end

	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChild("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end

	-----------------------------------------------------
	-- REMOVE ACCESSORIES + HIDE ORIGINAL PLAYER
	-----------------------------------------------------
	destroyAccessoriesRecursive(char)

	char.ChildAdded:Connect(function(child)
		if child:IsA("Accessory") then
			child:Destroy()
		end
	end)

	hideBaseRig(char)

	-----------------------------------------------------
	-- PRELOAD ANIMATIONS
	-----------------------------------------------------
	local animList = preloadAnimations({
		cfg.idleAnim,
		cfg.walkAnim
	})

	-----------------------------------------------------
	-- CLONE MORPH
	-----------------------------------------------------
	local clone = morphTemplate:Clone()
	clone.Parent = char
	activeMorphs[player] = clone

	local fakeRoot = clone:FindFirstChild("FakeRootPart") or clone:FindFirstChild("RootPart")
	if not fakeRoot then
		warn("MorphService: Morph missing FakeRootPart:", modelName)
		return
	end

	for _, p in ipairs(clone:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = false
			p.Massless = true
		end
	end

	fakeRoot.CFrame = hrp.CFrame

	-----------------------------------------------------
	-- MOTOR ATTACH
	-----------------------------------------------------
	local motor = Instance.new("Motor6D")
	motor.Name = "MorphRoot"
	motor.Part0 = hrp
	motor.Part1 = fakeRoot

	local offset = cfg.offset or CFrame.new(0,0,0)

	-- Offset FIRST, rotation AFTER (so BOTH apply)
	-- Apply rotation ONLY if config says isFlipped
	local rotation = CFrame.new()
	if cfg.isFlipped then
		rotation = CFrame.Angles(0, math.rad(180), 0)
	end

	motor.C0 = offset * rotation

	motor.Parent = hrp

	-----------------------------------------------------
	-- ANIMATION CONTROLLER
	-----------------------------------------------------
	local animController = clone:FindFirstChildOfClass("AnimationController")
	local animator = animController and animController:FindFirstChildOfClass("Animator")

	if not animator then
		warn("MorphService: No AnimationController/Animator on:", modelName)
		return
	end

	local idleTrack, walkTrack

	-- idle
	if cfg.idleAnim then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. cfg.idleAnim
		idleTrack = animator:LoadAnimation(anim)
		idleTrack.Looped = true
		idleTrack:Play()
	end

	-- walk
	if cfg.walkAnim then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. cfg.walkAnim
		walkTrack = animator:LoadAnimation(anim)
		walkTrack.Looped = true
	end

	-- animation switching
	if idleTrack and walkTrack then
		local walking = false

		humanoid.Running:Connect(function(speed)
			if speed > 1 then
				if not walking then
					walking = true
					idleTrack:Stop()
					walkTrack:Play()
				end
			else
				if walking then
					walking = false
					walkTrack:Stop()
					idleTrack:Play()
				end
			end
		end)
	end
end

return MorphService
