-- @ScriptType: ModuleScript
--// ReferralService.lua
local ReferralService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import coin service once Main loads it
local CoinService = nil

-- EDITABLE VARIABLE (YOU WILL CONNECT TO LIVE OPS LATER)
local ReferralCoins = 200

-- session memory (per server, resets when server closes)
local sessionReferrers = {} -- [inviterUserId] = true

-- Temporary folder so other systems can detect referrals (optional)
local ReferralSession = ReplicatedStorage:FindFirstChild("ReferralSession")
if not ReferralSession then
	ReferralSession = Instance.new("Folder")
	ReferralSession.Name = "ReferralSession"
	ReferralSession.Parent = ReplicatedStorage
end

----------------------------------------------------
-- INTERNAL: Award reward to inviter
----------------------------------------------------
local function giveReward(inviter)
	if not inviter then return end

	-- Prevent duplicates in same server
	if sessionReferrers[inviter.UserId] then
		print("[ReferralService] Already rewarded", inviter.Name)
		return
	end

	-- Give coins (uses your modular CoinService)
	CoinService:Add(inviter, ReferralCoins)
	print("[ReferralService] Gave", ReferralCoins, "to", inviter.Name)

	-- Mark in session memory
	sessionReferrers[inviter.UserId] = true

	-- Add marker object for other systems (optional)
	local marker = Instance.new("BoolValue")
	marker.Name = tostring(inviter.UserId)
	marker.Value = true
	marker.Parent = ReferralSession
end

----------------------------------------------------
-- PLAYER JOIN HANDLING
----------------------------------------------------
local function playerAdded(player)
	local joinData = player:GetJoinData()
	local referrerId = joinData and joinData.ReferredByPlayerId

	if referrerId and referrerId ~= 0 then
		print("[ReferralService] Player joined via referral:", player.Name, " → Inviter:", referrerId)

		local inviter = Players:GetPlayerByUserId(referrerId)

		if inviter then
			-- inviter is already in server
			giveReward(inviter)
		else
			-- inviter not here; wait for them to join
			local connection
			connection = Players.PlayerAdded:Connect(function(p)
				if p.UserId == referrerId then
					task.wait(2)
					giveReward(p)
					connection:Disconnect()
				end
			end)
		end
	else
		print("[ReferralService] Player joined normally:", player.Name)
	end
end

----------------------------------------------------
-- INIT (called from Main.server.lua)
----------------------------------------------------
function ReferralService.init(services)
	CoinService = services.CoinService

	Players.PlayerAdded:Connect(playerAdded)
	print("[ReferralService] Initialised and listening for referrals.")
end

return ReferralService
