-- @ScriptType: ModuleScript
local TweenService = game:GetService("TweenService")

local UIAnimations = {}

local hoverInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local clickInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bounceInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function UIAnimations.Hover(button)
	if not button:FindFirstChild("UIScale") then
		local s = Instance.new("UIScale")
		s.Scale = 1
		s.Parent = button
	end

	TweenService:Create(button.UIScale, hoverInfo, {Scale = 1.08}):Play()
end

function UIAnimations.Unhover(button)
	if button:FindFirstChild("UIScale") then
		TweenService:Create(button.UIScale, hoverInfo, {Scale = 1}):Play()
	end
end

function UIAnimations.Click(button)
	if not button:FindFirstChild("UIScale") then return end
	TweenService:Create(button.UIScale, clickInfo, {Scale = 0.92}):Play()

	task.delay(0.1, function()
		if button and button.UIScale then
			TweenService:Create(button.UIScale, bounceInfo, {Scale = 1.1}):Play()
			task.wait(0.12)
			TweenService:Create(button.UIScale, hoverInfo, {Scale = 1.08}):Play()
		end
	end)
end

return UIAnimations
