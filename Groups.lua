-- By:CaptArgo24 (2024-09-08)


local HttpService = game:GetService("HttpService")

-- Pastebin raw URL
local pastebinURL = "https://pastebin.com/raw/AYMv6NiN"  -- replace with your Pastebin raw URL

-- Function to fetch banned group IDs from Pastebin
local function fetchBannedGroups()
	local success, response = pcall(function()
		return HttpService:GetAsync(pastebinURL)
	end)

	if success then
		local bannedGroups = {}
		for groupId in string.gmatch(response, "%d+") do
			table.insert(bannedGroups, tonumber(groupId))
		end
		return bannedGroups
	else
		warn("Failed to fetch banned groups: " .. tostring(response))
		return {}
	end
end

-- Function to check if a player is in any of the banned groups
local function isInBannedGroup(player, bannedGroups)
	for _, groupId in pairs(bannedGroups) do
		if player:IsInGroup(groupId) then
			return groupId
		end
	end
	return nil
end

-- Function to handle player joining
local function onPlayerAdded(player)
	local bannedGroups = fetchBannedGroups()
	local bannedGroupId = isInBannedGroup(player, bannedGroups)
	if bannedGroupId then
		player:Kick("You are in a blacklisted group. Please leave the offending group inorder to continue. Offending Group  ID: " .. tostring(bannedGroupId))
	end
end

-- Connect the function to the PlayerAdded event
game.Players.PlayerAdded:Connect(onPlayerAdded)
