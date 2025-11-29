-- @ScriptType: ModuleScript
--// CoinService.lua
local CoinService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local CoinCollectedRemote = Remotes:WaitForChild("CoinCollected")
local UpdateCoinsRemote = Remotes:WaitForChild("UpdateCoins")

local CoinConfig = require(ReplicatedStorage.Shared.Config.CoinConfig)

local DataService = nil
local PlayerCoins = {} -- [userId] = number

function CoinService.init(services)
	DataService = services.DataService
end

-- Load coins on join
function CoinService.playerAdded(player)
	local profile = DataService:GetProfile(player)
	if not profile then return end

	local savedCoins = profile.Coins or 0
	PlayerCoins[player.UserId] = savedCoins

	-- Create/reload leaderstat
	player.leaderstats.CandyCanes.Value = savedCoins

	-- Send to client (if needed)
	UpdateCoinsRemote:FireClient(player, savedCoins)
end

-- Save on leave
function CoinService.playerRemoving(player)
	PlayerCoins[player.UserId] = nil
end

-- Add coins
function CoinService.AddCoins(player, amount)
	local userId = player.UserId
	local current = PlayerCoins[userId] or 0

	local newAmount = current + amount
	PlayerCoins[userId] = newAmount

	-- update save
	DataService:SetCoins(player, newAmount)

	-- update leaderboard
	player.leaderstats.CandyCanes.Value = newAmount

	-- notify client
	UpdateCoinsRemote:FireClient(player, newAmount)
end

return CoinService
