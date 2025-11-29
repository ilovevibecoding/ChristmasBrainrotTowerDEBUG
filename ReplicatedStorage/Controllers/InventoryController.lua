-- @ScriptType: ModuleScript
--========================================================--
-- ================  Inventory Controller  ===============--
--========================================================--

local InventoryController = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local BrainrotConfig = require(ReplicatedStorage.Shared.Config.BrainrotConfig)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Optional rule modules (playtime + adminOnly)
local PlaytimeUnlocks = require(ReplicatedStorage.Shared.BrainrotRules.PlaytimeUnlocks)
local AdminOnly = require(ReplicatedStorage.Shared.BrainrotRules.AdminOnly)

------------------------------------------------------------
-- UI ANIMATION MODULE (LOCAL)
------------------------------------------------------------
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
		if button and button:FindFirstChild("UIScale") then
			TweenService:Create(button.UIScale, bounceInfo, {Scale = 1.1}):Play()
			task.wait(0.12)
			TweenService:Create(button.UIScale, hoverInfo, {Scale = 1.08}):Play()
		end
	end)
end

------------------------------------------------------------
-- UI REFERENCES
------------------------------------------------------------

local MainGUI
local InventoryFrame
local BackLeft
local BackRight
local ScrollingFrame
local TemplateButton
local CloseButton
local EquipButton
local PreviewBrainrotImage
local PreviewHeader
local InvButton

------------------------------------------------------------
-- DATA
------------------------------------------------------------
local currentInventory = {}
local selectedBrainrot = nil
local currentPlaytime = 0 -- seconds (client-side display only)

------------------------------------------------------------
-- CONNECTION TRACKING (to survive respawns)
------------------------------------------------------------
local uiConnections = {}

local function disconnectUIConnections()
	for _, conn in ipairs(uiConnections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(uiConnections)
end

------------------------------------------------------------
-- UTILS
------------------------------------------------------------

local function clearInventory()
	if not ScrollingFrame or not TemplateButton then return end

	for _, item in ipairs(ScrollingFrame:GetChildren()) do
		if item:IsA("ImageButton") and item ~= TemplateButton then
			item:Destroy()
		end
	end
end

local function updatePreview(id)
	if not BackRight or not PreviewBrainrotImage or not PreviewHeader then return end

	selectedBrainrot = id

	local data = BrainrotConfig[id]
	if not data then return end

	BackRight.Visible = true
	PreviewBrainrotImage.Image = data.icon or ""
	PreviewHeader.Text = data.name or "Unknown"
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%02d:%02d", m, s)
end

------------------------------------------------------------
-- INVENTORY BUILDING (OWNED FIRST, LOCKED BELOW)
------------------------------------------------------------
local function buildInventory()
	if not ScrollingFrame or not TemplateButton then return end

	clearInventory()

	-- Build sorted arrays: owned first, then locked
	local ownedList = {}
	local lockedList = {}

	for id, data in pairs(BrainrotConfig) do
		if currentInventory[id] then
			table.insert(ownedList, id)
		else
			table.insert(lockedList, id)
		end
	end

	local sortedList = {}
	for _, id in ipairs(ownedList) do table.insert(sortedList, id) end
	for _, id in ipairs(lockedList) do table.insert(sortedList, id) end

	for _, id in ipairs(sortedList) do
		local data = BrainrotConfig[id]
		local owned = currentInventory[id] == true

		local item = TemplateButton:Clone()
		item.Visible = true
		item.Name = id
		item.Parent = ScrollingFrame

		item.Image = data.icon or ""

		-- child elements (optional but recommended)
		local lockedOverlay = item:FindFirstChild("LockedOverlay")
		local lockedText = item:FindFirstChild("LockedText")
		local timerIcon = item:FindFirstChild("TimerIcon")
		local timerText = item:FindFirstChild("TimerText")

		-- Playtime + admin locking logic
		local requiredTime = PlaytimeUnlocks[id] -- seconds or nil
		local isAdminOnly = AdminOnly[id] == true
		local isLockedByPlaytime = (not owned) and requiredTime ~= nil
		local remainingTime = 0
		if isLockedByPlaytime then
			remainingTime = math.max(0, (requiredTime or 0) - currentPlaytime)
		end

		----------------------------------------------------
		-- OWNED ITEMS
		----------------------------------------------------
		if owned then
			if lockedOverlay then lockedOverlay.Visible = false end
			if lockedText then lockedText.Visible = false end
			if timerIcon then timerIcon.Visible = false end
			if timerText then timerText.Visible = false end

			item.ImageColor3 = Color3.new(1, 1, 1)

			table.insert(uiConnections, item.MouseEnter:Connect(function()
				UIAnimations.Hover(item)
			end))

			table.insert(uiConnections, item.MouseLeave:Connect(function()
				UIAnimations.Unhover(item)
			end))

			table.insert(uiConnections, item.MouseButton1Down:Connect(function()
				UIAnimations.Click(item)
			end))

			table.insert(uiConnections, item.MouseButton1Click:Connect(function()
				updatePreview(id)
			end))

			----------------------------------------------------
			-- LOCKED ITEMS
			----------------------------------------------------
		else
			item.ImageColor3 = Color3.fromRGB(150, 50, 50)

			if lockedOverlay then lockedOverlay.Visible = true end
			if lockedText then
				lockedText.Visible = true
				if isAdminOnly then
					lockedText.Text = "Admin Only"
				elseif isLockedByPlaytime then
					lockedText.Text = "Playtime"
				else
					lockedText.Text = "Locked"
				end
			end

			if isLockedByPlaytime then
				if timerIcon then timerIcon.Visible = true end
				if timerText then
					timerText.Visible = true
					timerText.Text = formatTime(remainingTime)
				end
			else
				if timerIcon then timerIcon.Visible = false end
				if timerText then timerText.Visible = false end
			end

			-- basic hover anim, click does nothing (or just bounce)
			table.insert(uiConnections, item.MouseEnter:Connect(function()
				UIAnimations.Hover(item)
			end))

			table.insert(uiConnections, item.MouseLeave:Connect(function()
				UIAnimations.Unhover(item)
			end))

			table.insert(uiConnections, item.MouseButton1Down:Connect(function()
				UIAnimations.Click(item)
			end))

			table.insert(uiConnections, item.MouseButton1Click:Connect(function()
				-- locked: do nothing functional
			end))
		end
	end
end

------------------------------------------------------------
-- UI BINDING (REBINDABLE AFTER RESPAWN)
------------------------------------------------------------
local function bindUI()
	disconnectUIConnections()

	local playerGui = Player:WaitForChild("PlayerGui")

	MainGUI = playerGui:WaitForChild("MainGUI")

	InventoryFrame = MainGUI:WaitForChild("InventoryFrame")
	BackLeft = InventoryFrame:WaitForChild("BackLeft"):WaitForChild("BackLeft")
	BackRight = InventoryFrame:WaitForChild("BackRight"):WaitForChild("BackRight")

	ScrollingFrame = BackLeft:WaitForChild("ScrollingFrame")
	TemplateButton = ScrollingFrame:WaitForChild("ImageButton") -- template
	CloseButton = BackLeft:WaitForChild("ImageButton") -- red X

	EquipButton = BackRight:WaitForChild("ImageButton")
	PreviewBrainrotImage = BackRight:WaitForChild("Brainrot")
	PreviewHeader = BackRight:WaitForChild("Header")

	local hud = MainGUI:WaitForChild("HUD")
	InvButton = hud:WaitForChild("InvButton")

	TemplateButton.Visible = false
	BackRight.Visible = false
	InventoryFrame.Visible = false

	------------------------------------------------
	-- BIND OPEN/CLOSE BUTTONS
	------------------------------------------------
	table.insert(uiConnections, InvButton.MouseEnter:Connect(function()
		UIAnimations.Hover(InvButton)
	end))

	table.insert(uiConnections, InvButton.MouseLeave:Connect(function()
		UIAnimations.Unhover(InvButton)
	end))

	table.insert(uiConnections, InvButton.MouseButton1Down:Connect(function()
		UIAnimations.Click(InvButton)
	end))

	table.insert(uiConnections, InvButton.MouseButton1Click:Connect(function()
		InventoryFrame.Visible = true
	end))

	table.insert(uiConnections, CloseButton.MouseEnter:Connect(function()
		UIAnimations.Hover(CloseButton)
	end))

	table.insert(uiConnections, CloseButton.MouseLeave:Connect(function()
		UIAnimations.Unhover(CloseButton)
	end))

	table.insert(uiConnections, CloseButton.MouseButton1Down:Connect(function()
		UIAnimations.Click(CloseButton)
	end))

	table.insert(uiConnections, CloseButton.MouseButton1Click:Connect(function()
		InventoryFrame.Visible = false
		BackRight.Visible = false
	end))

	------------------------------------------------
	-- BIND EQUIP BUTTON
	------------------------------------------------
	table.insert(uiConnections, EquipButton.MouseEnter:Connect(function()
		UIAnimations.Hover(EquipButton)
	end))

	table.insert(uiConnections, EquipButton.MouseLeave:Connect(function()
		UIAnimations.Unhover(EquipButton)
	end))

	table.insert(uiConnections, EquipButton.MouseButton1Down:Connect(function()
		UIAnimations.Click(EquipButton)
	end))

	table.insert(uiConnections, EquipButton.MouseButton1Click:Connect(function()
		if not selectedBrainrot then return end
		print("Equipping:", selectedBrainrot)
		Remotes.EquipBrainrot:FireServer(selectedBrainrot)
	end))

	------------------------------------------------
	-- REBUILD INVENTORY FOR NEW GUI INSTANCE
	------------------------------------------------
	buildInventory()

	if selectedBrainrot and currentInventory[selectedBrainrot] then
		updatePreview(selectedBrainrot)
	else
		BackRight.Visible = false
	end
end

------------------------------------------------------------
-- REMOTE EVENTS
------------------------------------------------------------
local remotesConnected = false

local function onInventoryReceived(brainrotTable)
	currentInventory = brainrotTable or {}
	buildInventory()

	if not selectedBrainrot then
		for id, owned in pairs(currentInventory) do
			if owned then
				updatePreview(id)
				break
			end
		end
	end
end

local function onCollected(id)
	print("Collected brainrot:", id)
end

------------------------------------------------------------
-- INIT
------------------------------------------------------------
function InventoryController.init()
	-- initial bind (first load)
	bindUI()

	-- Re-bind whenever MainGUI is reinserted (e.g., after respawn)
	local playerGui = Player:WaitForChild("PlayerGui")
	playerGui.ChildAdded:Connect(function(child)
		if child.Name == "MainGUI" then
			task.wait(0.1)
			bindUI()
		end
	end)

	-- REMOTES (only once)
	if not remotesConnected then
		remotesConnected = true

		Remotes.SendBrainrotInventory.OnClientEvent:Connect(onInventoryReceived)
		Remotes.BrainrotCollected.OnClientEvent:Connect(onCollected)

		-- OPTIONAL: if you make a SendPlaytime remote, use it:
		-- Remotes.SendPlaytime.OnClientEvent:Connect(function(playtimeSeconds)
		--     currentPlaytime = playtimeSeconds
		--     buildInventory()
		-- end)
	end

	-- Client-side ticking playtime (for UI countdown only)
	task.spawn(function()
		while true do
			task.wait(1)
			currentPlaytime += 1
			buildInventory()
		end
	end)

	print("[InventoryController] Loaded successfully.")
end

return InventoryController
