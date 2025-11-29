-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServicesFolder = script.Parent:WaitForChild("Services")

local DataService = require(ServicesFolder:WaitForChild("DataService"))
local BrainrotService = require(ServicesFolder:WaitForChild("BrainrotService"))
local CoinService = require(ServicesFolder:WaitForChild("CoinService"))
local ReferralService = require(ServicesFolder:WaitForChild("ReferralService"))
-- Initialize services
BrainrotService.init({
	DataService = DataService,
})

CoinService.init({
	DataService = DataService
})

ReferralService.init({
	CoinService = CoinService
})


Players.PlayerAdded:Connect(function(player)

	-- Load profile FIRST
	DataService.playerAdded(player)

	-- Create leaderstats BEFORE services run
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local canes = Instance.new("IntValue")
	canes.Name = "CandyCanes"
	canes.Parent = stats

	-- Now safe to run service setup
	CoinService.playerAdded(player)
	BrainrotService.playerAdded(player)

	-- Sync equipped attribute if exists
	local profile = DataService:GetProfile(player)
	if profile and profile.SelectedBrainrot then
		player:SetAttribute("SelectedBrainrot", profile.SelectedBrainrot)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	BrainrotService.playerRemoving(player)
	CoinService.playerRemoving(player)
	DataService.playerRemoving(player)
end)
