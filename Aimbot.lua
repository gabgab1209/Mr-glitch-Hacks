local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PvPGui"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 260, 0, 280)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local titleBar = Instance.new("TextLabel", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleBar.Text = "PvP Script V5"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 16

local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20

local restoreBtn = Instance.new("TextButton", screenGui)
restoreBtn.Size = UDim2.new(0, 30, 0, 30)
restoreBtn.Position = UDim2.new(0, 10, 0.5, -15)
restoreBtn.Text = "+"
restoreBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 20
restoreBtn.Visible = false
restoreBtn.Draggable = true

-- Scrollable toggle holder
local toggleData = {
	"Aimbot", "ESP", "Tracer", "AutoFire", "Prediction",
	"FPS Boost", "Hitbox", "Infinite Jump", "NoClip",
	"TP Walk", "ServerHop"
}

local toggleHolder = Instance.new("ScrollingFrame", mainFrame)
toggleHolder.Size = UDim2.new(1, 0, 1, -30)
toggleHolder.Position = UDim2.new(0, 0, 0, 30)
toggleHolder.CanvasSize = UDim2.new(0, 0, 0, #toggleData * 35)
toggleHolder.ScrollBarThickness = 6
toggleHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleHolder.BorderSizePixel = 0

local UIList = Instance.new("UIListLayout", toggleHolder)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)

local toggles = {}
local toggleStates = {}
for _, name in ipairs(toggleData) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Text = "Toggle " .. name
	btn.Name = name
	btn.Parent = toggleHolder
	toggles[name] = btn
	toggleStates[name] = false
end

-- Minimize/Restore
minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	restoreBtn.Visible = false
end)

-- Mobile-friendly drag function
local function makeDraggable(gui)
	local dragging = false
	local offset = Vector2.zero
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = Vector2.new(input.Position.X - gui.Position.X.Offset, input.Position.Y - gui.Position.Y.Offset)
		end
	end)
	gui.InputChanged:Connect(function(input)
		if dragging then
			gui.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
	gui.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

makeDraggable(mainFrame)
makeDraggable(restoreBtn)

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- FPS Boost: destroy or disable laggy elements
local function applyFPSBoost()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ShirtGraphic") then
			obj:Destroy()
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
		end
	end
end

-- Full Brightness / No Fog override
local function applyFullBright()
	Lighting.Brightness = 2
	Lighting.FogEnd = 1e10
	Lighting.GlobalShadows = false
	Lighting.ClockTime = 14
end

-- Enforce FullBright whenever Lighting changes
Lighting:GetPropertyChangedSignal("FogEnd"):Connect(applyFullBright)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(applyFullBright)
applyFullBright()

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if toggleStates["Infinite Jump"] then
		local char = player.Character
		if char then
			local hum = char:FindFirstChildWhichIsA("Humanoid")
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

-- NoClip logic
RunService.Stepped:Connect(function()
	if toggleStates["NoClip"] then
		local char = player.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(workspace.CurrentCamera) then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- TP Walk movement
RunService.RenderStepped:Connect(function()
	if toggleStates["TP Walk"] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local root = player.Character.HumanoidRootPart
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Vector3.new(0,0,-1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move += Vector3.new(0,0,1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move += Vector3.new(-1,0,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Vector3.new(1,0,0) end
		if move.Magnitude > 0 then
			root.CFrame = root.CFrame + (root.CFrame:VectorToWorldSpace(move.Unit) * (toggleStates["TPWalkSpeed"] or 0.3))
		end
	end
end)

-- Toggle click functions
toggles["FPS Boost"].MouseButton1Click:Connect(function()
	applyFPSBoost()
end)

toggles["Infinite Jump"].MouseButton1Click:Connect(function()
	toggleStates["Infinite Jump"] = not toggleStates["Infinite Jump"]
	toggles["Infinite Jump"].Text = toggleStates["Infinite Jump"] and "Infinite Jump: ON" or "Infinite Jump: OFF"
end)

toggles["NoClip"].MouseButton1Click:Connect(function()
	toggleStates["NoClip"] = not toggleStates["NoClip"]
	toggles["NoClip"].Text = toggleStates["NoClip"] and "NoClip: ON" or "NoClip: OFF"
end)

toggles["TP Walk"].MouseButton1Click:Connect(function()
	toggleStates["TP Walk"] = not toggleStates["TP Walk"]
	if toggleStates["TP Walk"] then
		toggles["TP Walk"].Text = "TP Walk: ON"
		StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[TP Walk] Type walk speed in chat (e.g. 0.3)."})
		player.Chatted:Connect(function(msg)
			local value = tonumber(msg)
			if value then
				toggleStates["TPWalkSpeed"] = value
				StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[TP Walk] Speed set to " .. tostring(value)})
			end
		end)
	else
		toggles["TP Walk"].Text = "TP Walk: OFF"
	end
end)

toggles["Prediction"].MouseButton1Click:Connect(function()
	toggleStates["Prediction"] = not toggleStates["Prediction"]
	toggles["Prediction"].Text = toggleStates["Prediction"] and "Prediction: ON" or "Prediction: OFF"
end)

local camera = workspace.CurrentCamera
local lastHealth = 100
local recentAttackers = {}
local autofireCircle = nil

-- Track recent attackers
local function trackAttackers(humanoid)
	humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Team ~= player.Team then
					local dist = (camera.CFrame.Position - plr.Character.Head.Position).Magnitude
					if dist < 300 then
						recentAttackers[plr] = tick()
					end
				end
			end
		end
		lastHealth = newHealth
	end)
end

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	trackAttackers(hum)
end)

-- Raycast wall check
local function canSee(origin, target, char)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.IgnoreWater = true
	local direction = (target - origin).Unit * 300
	local result = workspace:Raycast(origin, direction, rayParams)

	while result do
		local hitPart = result.Instance
		if hitPart and hitPart:IsDescendantOf(char) then
			return true
		elseif hitPart and hitPart.Transparency > 0.7 then
			direction = (target - result.Position).Unit * 300
			result = workspace:Raycast(result.Position + direction.Unit * 0.05, direction, rayParams)
		else
			return false
		end
	end
	return false
end

-- Get aimbot target
local function getAimbotTarget()
	local best, closest = nil, math.huge

	for plr, t in pairs(recentAttackers) do
		if tick() - t < 3 and plr.Character and plr.Character:FindFirstChild("Head") and plr.Team ~= player.Team then
			local head = plr.Character.Head
			if canSee(camera.CFrame.Position, head.Position, plr.Character) then
				return head
			end
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Team ~= player.Team and plr.Character and plr.Character:FindFirstChild("Head") then
			local head = plr.Character.Head
			local dist = (camera.CFrame.Position - head.Position).Magnitude
			if dist < closest and canSee(camera.CFrame.Position, head.Position, plr.Character) then
				closest = dist
				best = head
			end
		end
	end
	return best
end

-- ESP logic (no distance limit)
local function updateESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			local char = plr.Character
			if toggleStates["ESP"] and not char:FindFirstChild("ESP") then
				local esp = Instance.new("BillboardGui", char)
				esp.Name = "ESP"
				esp.Adornee = char.Head
				esp.Size = UDim2.new(0, 100, 0, 20)
				esp.AlwaysOnTop = true
				local label = Instance.new("TextLabel", esp)
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = plr.Name
				label.TextColor3 = Color3.new(1, 0, 0)
				label.TextScaled = true
			elseif not toggleStates["ESP"] and char:FindFirstChild("ESP") then
				char.ESP:Destroy()
			end
		end
	end
end

-- Autofire Circle UI
autofireCircle = Instance.new("TextButton", screenGui)
autofireCircle.Size = UDim2.new(0, 70, 0, 70)
autofireCircle.Position = UDim2.new(0.5, -35, 0.9, -35)
autofireCircle.Text = ""
autofireCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
autofireCircle.BackgroundTransparency = 0.5
autofireCircle.Visible = false
local circleCorner = Instance.new("UICorner", autofireCircle)
circleCorner.CornerRadius = UDim.new(1, 0)

makeDraggable(autofireCircle)

-- Toggle buttons
toggles["Aimbot"].MouseButton1Click:Connect(function()
	toggleStates["Aimbot"] = not toggleStates["Aimbot"]
	toggles["Aimbot"].Text = toggleStates["Aimbot"] and "Aimbot: ON 🎯" or "Aimbot: OFF"
end)

toggles["ESP"].MouseButton1Click:Connect(function()
	toggleStates["ESP"] = not toggleStates["ESP"]
	toggles["ESP"].Text = toggleStates["ESP"] and "ESP: ON ✅" or "ESP: OFF"
end)

toggles["AutoFire"].MouseButton1Click:Connect(function()
	toggleStates["AutoFire"] = not toggleStates["AutoFire"]
	toggles["AutoFire"].Text = toggleStates["AutoFire"] and "AutoFire: ON 🔫" or "AutoFire: OFF"
	autofireCircle.Visible = toggleStates["AutoFire"]
end)

-- Render loop
RunService.RenderStepped:Connect(function()
	if toggleStates["ESP"] then updateESP() end

	if toggleStates["Aimbot"] then
		local target = getAimbotTarget()
		if target then
			local aimAt = target.Position
			if toggleStates["Prediction"] and target.Parent:FindFirstChild("HumanoidRootPart") then
				local vel = target.Parent.HumanoidRootPart.Velocity
				aimAt = aimAt + vel * 0.125
			end
			camera.CFrame = CFrame.new(camera.CFrame.Position, aimAt)
		end
	end

	if toggleStates["AutoFire"] and autofireCircle.Visible then
		local center = autofireCircle.AbsolutePosition + autofireCircle.AbsoluteSize / 2
		local objects = game:GetService("GuiService"):GetGuiObjectsAtPosition(center.X, center.Y)
		for _, obj in ipairs(objects) do
			if obj:IsA("TextButton") or obj:IsA("ImageButton") then
				pcall(function() obj:Activate() end)
			end
		end
	end
end)

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- 📦 Hitbox Expander
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

-- 🌐 Premium ServerHop
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

	warn("ServerHop failed: No open servers")
end

toggles["ServerHop"].MouseButton1Click:Connect(function()
	serverHop()
end)

-- 🧲 Tracer System
local tracerFolder = Instance.new("Folder", screenGui)
tracerFolder.Name = "Tracers"

local function clearTracers()
	for _, obj in ipairs(tracerFolder:GetChildren()) do
		if obj:IsA("Frame") then obj:Destroy() end
	end
end

toggles["Tracer"].MouseButton1Click:Connect(function()
	toggleStates["Tracer"] = not toggleStates["Tracer"]
	toggles["Tracer"].Text = toggleStates["Tracer"] and "Tracer: ON 🧲" or "Tracer: OFF"
	if not toggleStates["Tracer"] then
		clearTracers()
	end
end)

RunService.RenderStepped:Connect(function()
	clearTracers()
	if not toggleStates["Tracer"] then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Team ~= player.Team and plr.Character and plr.Character:FindFirstChild("Head") then
			local head = plr.Character.Head
			local screenPos, visible = camera:WorldToViewportPoint(head.Position)
			if visible then
				local tracer = Instance.new("Frame", tracerFolder)
				tracer.AnchorPoint = Vector2.new(0.5, 0)
				tracer.Position = UDim2.new(0, camera.ViewportSize.X / 2, 0, camera.ViewportSize.Y)
				tracer.Size = UDim2.new(0, 2, 0, (screenPos - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)).Magnitude)
				tracer.Rotation = math.deg(math.atan2(screenPos.Y - camera.ViewportSize.Y, screenPos.X - camera.ViewportSize.X / 2)) - 90
				tracer.BackgroundColor3 = Color3.new(1, 0, 0)
				tracer.BorderSizePixel = 0
			end
		end
	end
end)

-- Add two new toggle states if not present:
toggleStates["AutoFireLock"] = false
toggleStates["DragLock"] = false

-- Add drag lock toggle button
local lockButton = Instance.new("TextButton", screenGui)
lockButton.Size = UDim2.new(0, 120, 0, 30)
lockButton.Position = UDim2.new(1, -130, 1, -40)
lockButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
lockButton.TextColor3 = Color3.new(1,1,1)
lockButton.Font = Enum.Font.Gotham
lockButton.TextSize = 14
lockButton.Text = "Lock Drag: OFF"
lockButton.Visible = false

-- Lock/unlock drag toggle logic
lockButton.MouseButton1Click:Connect(function()
	toggleStates["AutoFireLock"] = not toggleStates["AutoFireLock"]
	lockButton.Text = toggleStates["AutoFireLock"] and "Lock Drag: ON" or "Lock Drag: OFF"
end)

-- Reconnect drag only if unlocked
local function makeDraggableLimited(gui, stateFunc)
	local dragging, offset = false, Vector2.zero
	gui.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not stateFunc() then
			dragging = true
			offset = Vector2.new(input.Position.X - gui.Position.X.Offset, input.Position.Y - gui.Position.Y.Offset)
		end
	end)
	gui.InputChanged:Connect(function(input)
		if dragging and not stateFunc() then
			gui.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
	gui.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Reapply drag limiter to restore and circle
makeDraggableLimited(autofireCircle, function() return toggleStates["AutoFireLock"] end)
makeDraggableLimited(restoreBtn, function() return false end)

-- Show drag lock button only if autofire is enabled
toggles["AutoFire"].MouseButton1Click:Connect(function()
	toggleStates["AutoFire"] = not toggleStates["AutoFire"]
	toggles["AutoFire"].Text = toggleStates["AutoFire"] and "AutoFire: ON 🔫" or "AutoFire: OFF"
	autofireCircle.Visible = toggleStates["AutoFire"]
	lockButton.Visible = toggleStates["AutoFire"]
end)

-- Optional: future enhancement hook
_G.PvPScriptToggle = toggleStates
_G.PvPScriptToggles = toggles