-- @ScriptType: Script
-- Backpack Button using TopBarPlus v3 (fixed version)
-- Keep this inside the TopbarPlus setup folder

local container  = script.Parent
local Icon = require(container.Icon)

-- Create TopBarPlus icon
local backpackIcon = Icon.new()
	:setName("Favourite")
	:setLabel("") -- no text
	:setImage(16086868244, "Deselected") -- heart icon
	:oneClick()

backpackIcon.toggled:Connect(function(isSelected)
	local AvatorEditorService = game:GetService("AvatarEditorService")
	AvatorEditorService:PromptSetFavorite(125513871400280, Enum.AvatarItemType.Asset, true)
end)

local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Create TopBarPlus icon
local inviteIcon = Icon.new()
	:setName("InviteFriend")
	:setLabel("") -- No text label
	:setImage(82143359894135, "Deselected") -- Example: person-add icon (change ID if you prefer)
	:oneClick()

-- When clicked, prompt the user to invite a friend
inviteIcon.selected:Connect(function()
	pcall(function()
		SocialService:PromptGameInvite(player)
	end)
end)

