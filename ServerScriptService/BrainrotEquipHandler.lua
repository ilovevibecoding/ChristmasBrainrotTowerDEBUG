-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local BrainrotService = require(script.Parent.Services:WaitForChild("BrainrotService"))

Remotes.EquipBrainrot.OnServerEvent:Connect(function(player, brainrotId)
	if not brainrotId then return end

	local success = BrainrotService.Equip(player, brainrotId)
	if success then
		print(player.Name .. " equipped brainrot:", brainrotId)
	end
end)
