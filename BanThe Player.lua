-- By:CaptArgo24 (2024-09-08)


local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- DataStore for player data
local playerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

-- Function to load player data
local function loadPlayerData(userId)
	local success, data = pcall(function()
		return playerDataStore:GetAsync(tostring(userId))
	end)

	if success then
		return data or { Server = 0, Total = 0 }
	else
		warn("Failed to load data for player " .. tostring(userId) .. ": " .. tostring(data))
		return { Server = 0, Total = 0 }
	end
end

-- Function to save player data
local function savePlayerData(userId, data)
	local success, err = pcall(function()
		playerDataStore:SetAsync(tostring(userId), data)
	end)

	if not success then
		warn("Failed to save data for player " .. tostring(userId) .. ": " .. tostring(err))
	end
end

-- Function to handle player joining
local function onPlayerAdded(player)
	local userId = player.UserId
	local data = loadPlayerData(userId)

	-- Check if the player should be kicked immediately
	if data.Total >= 10 then
		player:Kick("You have reached the maximum number of infractions.")
		return
	end

	-- Monitor the values in the player's "LineMod" folder
	local lineModFolder = player:WaitForChild("LineMod", 5)
	if lineModFolder then
		local serverValue = lineModFolder:FindFirstChild("Server")
		local totalValue = lineModFolder:FindFirstChild("Total")

		if serverValue and totalValue then
			-- Initialize values from DataStore
			serverValue.Value = data.Server
			totalValue.Value = data.Total

			-- Function to handle the "Server" value
			local function checkPlayerData()
				if serverValue.Value >= 10 then
					data.Total = totalValue.Value + 1
					data.Server = 0
					serverValue.Value = 0
					totalValue.Value = data.Total

					-- Save data to DataStore before kicking the player
					savePlayerData(userId, data)

					wait(1)  -- Add a delay to ensure data is saved

					player:Kick("You have been kicked due to excessive infractions.")
				end
			end

			-- Listen for changes in the "Server" value
			serverValue:GetPropertyChangedSignal("Value"):Connect(function()
				data.Server = serverValue.Value
				checkPlayerData()
			end)

			-- Constantly check player data in a while loop
			spawn(function()
				while player and player.Parent do
					if totalValue.Value >= 10 then
						player:Kick("You have reached the maximum number of infractions.")
						break
					end
					wait(1) -- Adjust the wait time as needed
				end
			end)
		else
			warn("Player " .. player.Name .. " does not have the required values in the LineMod folder.")
		end
	else
		warn("Player " .. player.Name .. " does not have a LineMod folder.")
	end
end

-- Connect the function to the PlayerAdded event
Players.PlayerAdded:Connect(onPlayerAdded)

-- Function to handle player leaving and saving data
local function onPlayerRemoving(player)
	local userId = player.UserId
	local lineModFolder = player:FindFirstChild("LineMod")

	if lineModFolder then
		local serverValue = lineModFolder:FindFirstChild("Server")
		local totalValue = lineModFolder:FindFirstChild("Total")

		if serverValue and totalValue then
			local data = {
				Server = serverValue.Value,
				Total = totalValue.Value
			}
			savePlayerData(userId, data)
		end
	end
end

-- Connect the function to the PlayerRemoving event
Players.PlayerRemoving:Connect(onPlayerRemoving)
