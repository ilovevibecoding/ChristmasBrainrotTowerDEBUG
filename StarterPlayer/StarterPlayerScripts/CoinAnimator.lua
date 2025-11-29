-- @ScriptType: LocalScript
local RunService = game:GetService("RunService")
local CoinsFolder = workspace:WaitForChild("CoinsFolder")

-- SETTINGS
local SPIN_SPEED = 0.6     -- lower = slower spin
local BOB_HEIGHT = 0.6
local BOB_SPEED = 1.4

local basePositions = {}
local sin = math.sin

local function animateCoin(coin)
	if not coin:IsA("BasePart") then return end
	if coin:GetAttribute("ClientAnimated") then return end

	coin:SetAttribute("ClientAnimated", true)
	coin.Anchored = true

	basePositions[coin] = coin.Position

	-- Smooth spin + bob on RenderStepped
	RunService.RenderStepped:Connect(function()
		if not coin or not coin.Parent then return end

		local basePos = basePositions[coin]
		if not basePos then return end

		-- Bobbing
		local bobOffset = sin(tick() * BOB_SPEED) * BOB_HEIGHT
		local bobPosition = basePos + Vector3.new(0, bobOffset, 0)

		-- Slow rotation
		local rotation = CFrame.Angles(0, tick() * SPIN_SPEED, 0)

		-- Apply transform
		coin.CFrame = CFrame.new(bobPosition) * rotation
	end)
end

-- Animate existing coins
for _, coin in ipairs(CoinsFolder:GetChildren()) do
	if coin.Name == "Coin" then
		animateCoin(coin)
	end
end

-- Animate coins added later
CoinsFolder.ChildAdded:Connect(function(coin)
	if coin.Name == "Coin" then
		animateCoin(coin)
	end
end)
