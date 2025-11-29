-- @ScriptType: LocalScript
-- ClientMain.client.lua
-- Bootstraps all client-side controllers

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ControllersFolder = ReplicatedStorage:WaitForChild("Controllers")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local controllers = {}

-- Load all ModuleScripts inside ReplicatedStorage/Controllers
for _, module in ipairs(ControllersFolder:GetChildren()) do
	if module:IsA("ModuleScript") then
		local controller = require(module)
		controllers[#controllers + 1] = controller
	end
end

-- Run .init() on all controllers (if they have it)
for _, controller in ipairs(controllers) do
	if typeof(controller.init) == "function" then
		controller.init(Remotes)
	end
end

print("Client controllers loaded.")
