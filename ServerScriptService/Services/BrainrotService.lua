-- @ScriptType: ModuleScript
--// BrainrotService.lua
-- Owns / gives / equips brainrots and talks to MorphService

local BrainrotService = {}

local ADMIN_GROUP_ID = 0    --if not in use , set nil   -- put your group id here if needed
local MIN_ADMIN_RANK = 200  -- if not in use, set 0  -- example rank threshold


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BrainrotConfig = require(ReplicatedStorage.Shared.Config.BrainrotConfig)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local BrainrotCollectedRemote = Remotes:WaitForChild("BrainrotCollected")
local SendBrainrotInventoryRemote = Remotes:WaitForChild("SendBrainrotInventory")
local HideCollectibleRemote = Remotes:WaitForChild("HideBrainrotCollectible")

local MorphService = require(script.Parent:WaitForChild("MorphService"))

-- injected by init
local DataService = nil

-- Runtime cache: PlayerCollections[userId] = profile.Brainrots (table)
local PlayerCollections = {}

local PlaytimeUnlocks = require(ReplicatedStorage.Shared.BrainrotRules.PlaytimeUnlocks)
local AdminOnly = require(ReplicatedStorage.Shared.BrainrotRules.AdminOnly)


----------------------------------------------------
-- INIT
----------------------------------------------------
function BrainrotService.init(services)
	DataService = services.DataService
end

----------------------------------------------------
-- HELPERS
----------------------------------------------------
function BrainrotService.Exists(id)
	return BrainrotConfig[id] ~= nil
end

function BrainrotService.PlayerHas(player, id)
	local col = PlayerCollections[player.UserId]
	return col and col[id] == true
end

----------------------------------------------------
-- PLAYER LIFECYCLE
----------------------------------------------------
function BrainrotService.playerAdded(player)
	if not DataService then
		warn("BrainrotService.init was not called before playerAdded")
		return
	end

	local profile = DataService:GetProfile(player)
	if not profile then return end

	profile.Brainrots = profile.Brainrots or {}
	PlayerCollections[player.UserId] = profile.Brainrots

	-- Hide already-owned collectibles in the world
	for _, collectible in ipairs(workspace:GetDescendants()) do
		if collectible:IsA("Model") and collectible:FindFirstChild("BrainrotId") then
			local id = collectible.BrainrotId.Value
			if profile.Brainrots[id] then
				HideCollectibleRemote:FireClient(player, collectible)
			end
		end
	end

	-- Send current inventory to client
	SendBrainrotInventoryRemote:FireClient(player, profile.Brainrots)
end

function BrainrotService.playerRemoving(player)
	PlayerCollections[player.UserId] = nil
end

----------------------------------------------------
-- GIVE BRAINROT
----------------------------------------------------
function BrainrotService.Give(player, id)

	----------------------------------------------------
	-- ADMIN-ONLY CHECK
	----------------------------------------------------
	if AdminOnly[id] then
		if not ADMIN_GROUP_ID then
			return false
		end

		local rank = player:GetRankInGroup(ADMIN_GROUP_ID)

		if rank < MIN_ADMIN_RANK then
			return false
		end
	end

	----------------------------------------------------
	-- PLAYTIME CHECK
	----------------------------------------------------
	local requiredTime = PlaytimeUnlocks[id]
	if requiredTime then
		local profile = DataService:GetProfile(player)
		if profile then
			local playtime = profile.Playtime or 0
			if playtime < requiredTime then
				return false
			end
		end
	end

	----------------------------------------------------
	-- NORMAL GIVE LOGIC
	----------------------------------------------------
	if not BrainrotService.Exists(id) then
		warn("BrainrotService.Give: invalid id", id)
		return false
	end

	if BrainrotService.PlayerHas(player, id) then
		return false
	end

	local col = PlayerCollections[player.UserId]

	if not col then
		local profile = DataService and DataService:GetProfile(player)
		if not profile then return false end

		profile.Brainrots = profile.Brainrots or {}
		col = profile.Brainrots
		PlayerCollections[player.UserId] = col
	end

	col[id] = true

	if DataService and DataService.AddBrainrot then
		DataService:AddBrainrot(player, id)
	end

	BrainrotCollectedRemote:FireClient(player, id)
	SendBrainrotInventoryRemote:FireClient(player, col)

	return true
end


----------------------------------------------------
-- EQUIP BRAINROT (→ MORPH)
----------------------------------------------------
function BrainrotService.Equip(player, id)
	if not BrainrotService.Exists(id) then
		warn("Equip: invalid brainrot id", id)
		return false
	end

	if not BrainrotService.PlayerHas(player, id) then
		warn(string.format("Equip: %s tried to equip brainrot they don't own: %s",
			player.Name, tostring(id)))
		return false
	end

	-- save selected in datastore
	if DataService and DataService.SetSelectedBrainrot then
		DataService:SetSelectedBrainrot(player, id)
	end

	-- save attribute for client side usage
	player:SetAttribute("SelectedBrainrot", id)

	-- apply morph
	MorphService.ApplyMorph(player, id)

	return true
end

return BrainrotService
