-- @ScriptType: ModuleScript
--// DataService.lua
local DataService = {}

local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("BrainrotData_v1")

-- Profiles[userId] = { Brainrots = {}, SelectedBrainrot = string or nil }
local Profiles = {}


----------------------------------------------------
-- PLAYER LOADING
----------------------------------------------------

function DataService.playerAdded(player)
	local userId = player.UserId
	local data

	local success, err = pcall(function()
		data = store:GetAsync(userId)
	end)

	if not success then
		warn("Data load error for", userId, err)
	end

	if not data then
		data = {
			Brainrots = {},
			SelectedBrainrot = nil,
		}
	end

	-- safety
	data.Brainrots = data.Brainrots or {}
	if data.SelectedBrainrot == nil then
		data.SelectedBrainrot = nil
	end

	Profiles[userId] = data
	
	if not data.Coins then
		data.Coins = 0
	end

end

----------------------------------------------------
-- PLAYER SAVING
----------------------------------------------------

function DataService.playerRemoving(player)
	local userId = player.UserId
	local data = Profiles[userId]
	if not data then return end

	local success, err = pcall(function()
		store:SetAsync(userId, data)
	end)

	if not success then
		warn("Save error for", userId, err)
	end

	Profiles[userId] = nil
end

----------------------------------------------------
-- API
----------------------------------------------------

function DataService:GetProfile(player)
	return Profiles[player.UserId]
end

function DataService:AddBrainrot(player, id)
	local profile = Profiles[player.UserId]
	if not profile then return end

	profile.Brainrots[id] = true
end

function DataService:SetSelectedBrainrot(player, id)
	local profile = Profiles[player.UserId]
	if not profile then return end

	profile.SelectedBrainrot = id
end


function DataService:SetCoins(player, amount)
	local profile = Profiles[player.UserId]
	if not profile then return end

	profile.Coins = amount
end


return DataService
