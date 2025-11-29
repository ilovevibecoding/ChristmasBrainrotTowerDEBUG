-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local Players = game:GetService("Players")

local CoinService = require(script.Parent.Services.CoinService)
local CoinConfig = require(ReplicatedStorage.Shared.Config.CoinConfig)

-- Per-player cooldown table
local lastCollect = {}

Remotes.CollectCoin.OnServerEvent:Connect(function(player, coin)
	-- Basic sanity checks
	if typeof(coin) ~= "Instance" then return end
	if not coin:IsDescendantOf(game.Workspace) then return end
	if coin.Name ~= "Coin" then return end

	-- Debounce (prevent spamming exploit)
	local t = tick()
	if lastCollect[player] and t - lastCollect[player] < 0.2 then
		return -- ignore spam attempts
	end
	lastCollect[player] = t

	-- Make sure coin hasn't already been collected
	if coin:GetAttribute("Collected") then return end

	-- SERVER-SIDE DISTANCE CHECK  
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then return end

	local dist = (coin.Position - root.Position).Magnitude
	if dist > 10 then
		-- too far away, likely an exploit
		return
	end

	-- Mark coin as used
	coin:SetAttribute("Collected", true)

	-- Reward coins
	CoinService.AddCoins(player, CoinConfig.ValuePerCoin)

	-- Remove coin FOR THIS PLAYER ONLY
	Remotes.HideCoin:FireClient(player, coin)
end)
