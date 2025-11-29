-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local BrainrotService = require(script.Parent.Services.BrainrotService)

Remotes.CollectBrainrot.OnServerEvent:Connect(function(player, brainrotId, collectible)
	if typeof(brainrotId) ~= "string" then return end
	if not collectible or not collectible:IsDescendantOf(workspace) then return end

	if BrainrotService.Give(player, brainrotId) then
		-- Hide collectible for THIS player only
		local hideRemote = Remotes:WaitForChild("HideBrainrotCollectible")
		hideRemote:FireClient(player, collectible)
	end
end)
