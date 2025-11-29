-- @ScriptType: ModuleScript
local BrainrotConfig = {

-- TO ADD A NEW BRAINROT:
-- 1. Add a new table here, (copy from an existing one, or copy from the example)
-- 2. add a BrainrotCollectible in workspace
-- 3. Add morphModel, idleAnim, walkAnim
-- 4. check ingame if offset is needed
-- 5. check if isflipped is needed
-- 6. add a BrainrotCollectible in workspace

	tung_tung_tung_sahor = {
		name = "Tung Tung Tung Sahor",
		icon = "rbxassetid://84943239102297",
		rarity = "Common",
		description = "He zooms around like crazy",
		
		morphModel = "Tung Tung Tung Sahur",
		-- OPTIONAL: only if a morph exists for it
		-- morphModel = "TungTungMorph",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, 1, 0), 
		isFlipped = true,-- Example: lowers morph slightly
	},

	ballerina_cappucina = {
		name = "Ballerina Cappuccina",
		icon = "rbxassetid://103851093619876",
		rarity = "Rare",
		description = "Cold and silent.",

		-- REQUIRED (since you gave the ballerina morph)
		morphModel = "Ballerina Cappuccina",

		-- Your morph script uses these animation IDs:
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.3, 0),
		isFlipped = false,	-- Example: lowers morph slightly
	},

	six_seven = {
		name = "67",
		icon = "rbxassetid://110444066627259",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "67",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = false,
	},
	
	bombardiro_crocodilo = {
		name = "Bombardiro Crocodilo",
		icon = "rbxassetid://135165723501650",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Bombardiro Crocodilo",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = false,
	},
	brr_brr_patapim = {
		name = "Brr Brr Patapim",
		icon = "rbxassetid://124186142344144",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Brr Brr Patapim",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = true,
	},
	cappuccino_assassino = {
		name = "Cappuccino Assassino",
		icon = "rbxassetid://110360127280016",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Cappuccino Assassino",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = false,
	},
	chimpanzini_bananini = {
		name = "Chimpanzini Bananini",
		icon = "rbxassetid://124874890853745",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Chimpanzini Bananini",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = false,
	},
	lirili_larila = {
		name = "Lirilì Larilà",
		icon = "rbxassetid://99093060996684",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Lirilì Larilà",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = false,
	},
	odin_din_din_dun = {
		name = "Odin Din Din Dun",
		icon = "rbxassetid://132454291074955",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Odin Din Din Dun",
		idleAnim = 82440745163536,
		walkAnim = 95018425394888,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = true,
	},
	tralalero_tralala = {
		name = "Tralalero Tralala",
		icon = "rbxassetid://95934746711773",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Tralalero Tralala",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = true,
	},
	trippi_troppi = {
		name = "Trippi Troppi",
		icon = "rbxassetid://93762804984503",
		rarity = "Mythic",
		description = "stupid ahh kid",

		-- OPTIONAL, add later when morph exists
		morphModel = "Trippi Troppi",
		idleAnim = 0000000000,
		walkAnim = 0000000000,
		offset = CFrame.new(0, -1.2, 0), -- Example: lowers morph slightly
		isFlipped = true,
	},
	

	
}

return BrainrotConfig

-- Commands --
-- IsFlipped (BOOL) - flips morph 180 degrees if true
-- offset (CFrame) - applies an offset to the morph's position
-- idleAnim (string) - ID of the idle animation
-- walkAnim (string) - ID of the walk animation
-- morphModel (string) - name of the morph model in ReplicatedStorage.Morph
-- icon (string) - asset ID for the brainrot icon
-- rarity (string) - rarity tier (Common, Rare, Epic, Legendary, Mythic)
-- description (string) - description of the brainrot
-- name (string) - display name
