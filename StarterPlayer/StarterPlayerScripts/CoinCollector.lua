-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local player = Players.LocalPlayer

local CoinsFolder = Workspace:WaitForChild("CoinsFolder")

local pickupSound = ReplicatedStorage.Assets:WaitForChild("CoinPickup")
local pickupParticle = ReplicatedStorage.Assets:WaitForChild("PickupParticle")
local floatingText = ReplicatedStorage.Assets:WaitForChild("FloatingText")

local CHARACTER = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(char)
	CHARACTER = char
end)


---------------------------------------------------------------------
-- PLAY SOUND AT POSITION (NEVER INTERRUPTED)
---------------------------------------------------------------------
local function playSoundAt(position)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.CFrame = CFrame.new(position)
	part.Parent = workspace

	local sound = pickupSound:Clone()
	sound.Parent = part
	sound:Play()

	Debris:AddItem(part, 2)
end


---------------------------------------------------------------------
-- FLOATING +10 CANDY CANES TEXT (PERSISTS)
---------------------------------------------------------------------
local function showFloatingText(position, amount)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace

	local textGui = floatingText:Clone()
	textGui.Parent = workspace
	textGui.Adornee = anchor
	textGui.TextLabel.Text = "+" .. amount .. " Candy Canes"

	-- Rise up
	local tween1 = TweenService:Create(
		textGui,
		TweenInfo.new(1, Enum.EasingStyle.Quad),
		{ StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0) }
	)

	-- Fade out
	local tween2 = TweenService:Create(
		textGui.TextLabel,
		TweenInfo.new(1, Enum.EasingStyle.Quad),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)

	tween1:Play()
	tween2:Play()

	Debris:AddItem(anchor, 1.1)
	Debris:AddItem(textGui, 1.1)
end


---------------------------------------------------------------------
-- PARTICLE BURST
---------------------------------------------------------------------
local function playParticle(coin)
	local p = pickupParticle:Clone()
	p.Parent = coin
	p:Emit(20)
	task.delay(1, function()
		if p then p:Destroy() end
	end)
end


---------------------------------------------------------------------
-- SMOOTH COIN FADE + SHRINK
---------------------------------------------------------------------
local function fadeAndRemove(coin)
	local tween = TweenService:Create(
		coin,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad),
		{
			Transparency = 1,
			Size = coin.Size * 0.2
		}
	)
	tween:Play()
	tween.Completed:Wait()

	coin:Destroy()
end


---------------------------------------------------------------------
-- COIN TOUCH HANDLER
---------------------------------------------------------------------
local function hookCoin(coin)
	if not coin:IsA("BasePart") then return end
	if coin.Name ~= "Coin" then return end
	if coin:GetAttribute("Hooked") then return end

	coin:SetAttribute("Hooked", true)

	coin.Touched:Connect(function(hit)
		if not CHARACTER then return end
		if not hit:IsDescendantOf(CHARACTER) then return end

		-- Prevent duplicate activation
		if coin:GetAttribute("CollectedLocal") then return end
		coin:SetAttribute("CollectedLocal", true)

		local pos = coin.Position

		-- Local effects (play once)
		playSoundAt(pos)
		showFloatingText(pos, 10)
		playParticle(coin)

		-- Fade animation
		fadeAndRemove(coin)

		-- Tell server
		Remotes.CollectCoin:FireServer(coin)
	end)
end


---------------------------------------------------------------------
-- HOOK EXISTING COINS
---------------------------------------------------------------------
for _, coin in ipairs(CoinsFolder:GetChildren()) do
	hookCoin(coin)
end

-- HOOK NEW COINS
CoinsFolder.ChildAdded:Connect(function(coin)
	hookCoin(coin)
end)
