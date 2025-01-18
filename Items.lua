-- By:CaptArgo24 (2024-09-08)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Pastebin raw URL
local pastebinURL = "https://pastebin.com/raw/x8e62ZBp"  -- replace with your Pastebin raw URL

-- Function to fetch banned asset IDs from Pastebin
local function fetchBannedAssets()
	print("Fetching banned assets...")
	local success, response = pcall(function()
		return HttpService:GetAsync(pastebinURL)
	end)

	if success then
		-- Split the response by commas and convert to numbers
		local bannedAssets = {}
		for _, id in pairs(string.split(response, ",")) do
			table.insert(bannedAssets, tonumber(id))
		end
		print("Banned assets fetched successfully")
		return bannedAssets
	else
		warn("Failed to fetch banned assets: " .. tostring(response))
		return {}
	end
end

-- Retry function to handle HTTP failures
local function retryFetchBannedAssets(retries)
	local bannedAssets = {}
	for i = 1, retries do
		bannedAssets = fetchBannedAssets()
		if #bannedAssets > 0 then
			return bannedAssets
		end
		task.wait(2)  -- Delay before retrying
	end
	return bannedAssets
end

-- Function to check if a player is wearing any of the banned assets
local function isWearingBannedAsset(player, bannedAssets)
	local humanoid = player.Character:WaitForChild("Humanoid")
	local humanoidDescription = humanoid:WaitForChild("HumanoidDescription")

	-- Function to check accessories
	local function checkAccessories(accessoryIds)
		for _, assetId in pairs(bannedAssets) do
			for _, id in pairs(accessoryIds) do
				if tonumber(id) == assetId then
					return assetId
				end
			end
		end
		return nil
	end

	-- Check all accessory types
	local accessoryTypes = {
		humanoidDescription.HairAccessory,
		humanoidDescription.HatAccessory,
		humanoidDescription.FaceAccessory,
		humanoidDescription.NeckAccessory,
		humanoidDescription.ShouldersAccessory,
		humanoidDescription.FrontAccessory,
		humanoidDescription.BackAccessory,
		humanoidDescription.WaistAccessory
	}

	for _, accessory in pairs(accessoryTypes) do
		local offendingAssetId = checkAccessories(string.split(accessory, ","))
		if offendingAssetId then
			return offendingAssetId
		end
	end

	-- Check clothing types
	local clothingTypes = {
		humanoidDescription.Shirt,
		humanoidDescription.Pants,
		humanoidDescription.GraphicTShirt
	}

	for _, clothing in pairs(clothingTypes) do
		for _, assetId in pairs(bannedAssets) do
			if tonumber(clothing) == assetId then
				return assetId
			end
		end
	end

	return nil
end

-- Function to handle player joining
local function onPlayerAdded(player)
	print("Player added: " .. player.Name)
	player.CharacterAdded:Connect(function(character)
		-- Wait for the character to be fully loaded
		character:WaitForChild("Humanoid")
		character.Humanoid:WaitForChild("HumanoidDescription")

		local bannedAssets = retryFetchBannedAssets(3)
		local offendingAssetId = isWearingBannedAsset(player, bannedAssets)
		if offendingAssetId then
			print("Player " .. player.Name .. " is wearing a banned item: " .. offendingAssetId)
			player:Kick("You are wearing a restricted item. Please take off the offending item(s) inorder to continue. Offending Item ID: " .. offendingAssetId)
		else
			print("Player " .. player.Name .. " is not wearing any banned items.")
		end
	end)
end

-- Connect the function to the PlayerAdded event
Players.PlayerAdded:Connect(onPlayerAdded)
