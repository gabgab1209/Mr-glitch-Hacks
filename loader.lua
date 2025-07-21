local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Hitbox logic
local function setHitboxSize(state)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local root = plr.Character.HumanoidRootPart
			root.Size = state and Vector3.new(10, 10, 10) or Vector3.new(2, 2, 1)
			root.Transparency = state and 0.5 or 0
			root.CanCollide = not state
		end
	end
end

toggles["Hitbox"].MouseButton1Click:Connect(function()
	toggleStates["Hitbox"] = not toggleStates["Hitbox"]
	toggles["Hitbox"].Text = toggleStates["Hitbox"] and "Hitbox: ON 📦" or "Hitbox: OFF"
	setHitboxSize(toggleStates["Hitbox"])
end)

-- ServerHop Logic
local function serverHop()
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	local success, data = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)

	if success and data and data.data then
		for _, server in ipairs(data.data) do
			if server.id ~= game.JobId and server.playing < server.maxPlayers then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
				return
			end
		end
	end

	warn("ServerHop failed: No available servers found.")
end

toggles["ServerHop"].MouseButton1Click:Connect(function()
	serverHop()
end)