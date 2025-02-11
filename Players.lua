-- By:CaptArgo24 (2024-09-08)

local HttpService = game:GetService("HttpService")

-- Pastebin raw URL
local pastebinURL = "https://pastebin.com/raw/uvRi47cS"  -- replace with your Pastebin raw URL

-- Function to fetch banned user IDs from Pastebin
local function fetchBannedUsers()
	local success, response = pcall(function()
		return HttpService:GetAsync(pastebinURL)
	end)

	if success then
		local bannedUsers = {}
		for userId in string.gmatch(response, "%d+") do
			table.insert(bannedUsers, tonumber(userId))
		end
		return bannedUsers
	else
		warn("Failed to fetch banned users: " .. tostring(response))
		return {}
	end
end

-- Function to check if a player is in the banned user list
local function isBannedUser(player, bannedUsers)
	for _, userId in pairs(bannedUsers) do
		if player.UserId == userId then
			return true
		end
	end
	return false
end

-- Function to handle player joining
local function onPlayerAdded(player)
	local bannedUsers = fetchBannedUsers()
	if isBannedUser(player, bannedUsers) then
		player:Kick("You are banned from this game and all other games using this script. Contact an admin or submit an appeal in order to rejoin or if you have questions.")
	end
end

-- Connect the function to the PlayerAdded event
game.Players.PlayerAdded:Connect(onPlayerAdded)
