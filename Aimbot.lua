-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- STATE
local aimbotEnabled = false
local dragging = false
local dragInput, dragStart, startPos

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PvPGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 190)
panel.Position = UDim2.new(0, 20, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = screenGui

-- Dragging
panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

panel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Button Maker
local function createButton(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 190, 0, 30)
	btn.Position = UDim2.new(0, 15, 0, yPos)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	btn.Parent = panel
	return btn
end

local toggleAimbotBtn = createButton("Toggle Premium Aimbot 🎯", 10)
local boostFpsBtn = createButton("Boost FPS ⚡️", 50)

-- Minimize & Close
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 150)
minimizeBtn.Text = "🔽"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 10)
closeBtn.Text = "❌"
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = panel

local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 60, 0, 30)
restoreBtn.Position = UDim2.new(0, 20, 0, 100)
restoreBtn.Text = "📂"
restoreBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
restoreBtn.Visible = false
restoreBtn.Parent = screenGui

-- Force Lighting (Full Bright & No Fog)
local function forceLighting()
	Lighting.FogEnd = 1e10
	Lighting.Brightness = 2
	Lighting.GlobalShadows = false
	Lighting.ClockTime = 14
	Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

forceLighting()
Lighting:GetPropertyChangedSignal("FogEnd"):Connect(forceLighting)
player.CharacterAdded:Connect(function()
	task.wait(1)
	forceLighting()
end)

-- FPS Boost
boostFpsBtn.MouseButton1Click:Connect(function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") then
			obj:Destroy()
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
		end
	end
	forceLighting()
end)

-- GUI Control
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

minimizeBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
	restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
	panel.Visible = true
	restoreBtn.Visible = false
end)

-- ESP Management
local function clearESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("ESP") then
			p.Character.ESP:Destroy()
		end
	end
end

local function createESP(p)
	local char = p.Character
	if char and not char:FindFirstChild("ESP") then
		local head = char:FindFirstChild("Head")
		if head then
			local esp = Instance.new("BillboardGui")
			esp.Name = "ESP"
			esp.Adornee = head
			esp.Size = UDim2.new(0, 100, 0, 20)
			esp.AlwaysOnTop = true
			esp.StudsOffset = Vector3.new(0, 2, 0)
			esp.Parent = char

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = p.Name
			label.TextColor3 = Color3.new(1, 0, 0)
			label.TextStrokeTransparency = 0.5
			label.TextScaled = true
			label.Parent = esp
		end
	end
end

local function updateESP()
	if not aimbotEnabled then
		clearESP()
		return
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Team ~= player.Team then
			local char = p.Character
			local head = char and char:FindFirstChild("Head")
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if head and hum and hum.Health > 0 then
				local dist = (camera.CFrame.Position - head.Position).Magnitude
				if dist <= 300 then
					createESP(p)
				end
			end
		end
	end
end

-- Raycast with penetrable material skip
local function canSeeTarget(origin, targetPos, character)
	local direction = (targetPos - origin).Unit * 300
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, rayParams)

	while result do
		local hit = result.Instance
		if hit and hit:IsDescendantOf(character) then
			return true
		end

		local material = result.Material
		if material == Enum.Material.Glass
			or material == Enum.Material.Neon
			or material == Enum.Material.ForceField
			or material == Enum.Material.Air
			or (hit and hit.Transparency > 0.7)
		then
			local newOrigin = result.Position + direction.Unit * 0.1
			local newDirection = (targetPos - newOrigin).Unit * (300 - (newOrigin - origin).Magnitude)
			result = workspace:Raycast(newOrigin, newDirection, rayParams)
		else
			return false
		end
	end

	return false
end

-- Closest Target
local function getClosestTarget()
	local closest = nil
	local shortest = 300

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Team ~= player.Team then
			local char = p.Character
			local head = char and char:FindFirstChild("Head")
			local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")

			if head and humanoid and humanoid.Health > 0 then
				local dist = (camera.CFrame.Position - head.Position).Magnitude
				if dist < shortest then
					local _, onScreen = camera:WorldToViewportPoint(head.Position)
					if onScreen and canSeeTarget(camera.CFrame.Position, head.Position, char) then
						closest = head
						shortest = dist
					end
				end
			end
		end
	end

	return closest
end

-- Aimbot Toggle
toggleAimbotBtn.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	toggleAimbotBtn.Text = aimbotEnabled and "Aimbot: ON 🎯" or "Toggle Premium Aimbot 🎯"
	if not aimbotEnabled then clearESP() end
end)

-- Main Runtime
RunService.RenderStepped:Connect(function()
	if aimbotEnabled then
		local target = getClosestTarget()
		if target then
			camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
		end
	end
	updateESP()
end)