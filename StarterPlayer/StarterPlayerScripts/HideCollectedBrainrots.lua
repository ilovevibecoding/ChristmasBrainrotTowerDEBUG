-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

Remotes.HideBrainrotCollectible.OnClientEvent:Connect(function(model)
	if model and model.Parent then
		model:Destroy()
	end
end)
