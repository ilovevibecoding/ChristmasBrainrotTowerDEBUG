-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local player = Players.LocalPlayer

-- Detect touches for ALL collectibles in the world
workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("Part") and desc.Name == "TouchTrigger" then
		desc.Touched:Connect(function(hit)
			local character = player.Character
			if not character then return end
			if not hit:IsDescendantOf(character) then return end

			local collectible = desc.Parent
			local brainrotIdValue = collectible:FindFirstChild("BrainrotId")

			if brainrotIdValue then
				local id = brainrotIdValue.Value
				Remotes.CollectBrainrot:FireServer(id, collectible)
				
			end
		end)
	end
end)

-- Also scan all existing ones (in case tower already loaded)
for _, desc in ipairs(workspace:GetDescendants()) do
	if desc:IsA("Part") and desc.Name == "TouchTrigger" then
		desc.Touched:Connect(function(hit)
			local character = player.Character
			if not character then return end
			if not hit:IsDescendantOf(character) then return end

			local collectible = desc.Parent
			local brainrotIdValue = collectible:FindFirstChild("BrainrotId")

			if brainrotIdValue then
				local id = brainrotIdValue.Value
				Remotes.CollectBrainrot:FireServer(id, collectible)
			end
		end)
	end
end
