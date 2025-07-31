--// Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

--// Feature Settings
local aimbotEnabled = false
local tracersEnabled = false
local currentTarget = nil
local frameCounter = 0
local checkDelay = 5
local drawings = {}

--// UI Theme Helper
local function createButton(name, parent, text, posY)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Size = UDim2.new(1, 0, 0, 30)
	button.Position = UDim2.new(0, 0, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button.TextColor3 = Color3.fromRGB(200, 200, 255)
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 16
	button.BorderSizePixel = 0
	button.Parent = parent
	return button
end

--// Make any Frame or Button draggable
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging and dragInput then
			local delta = dragInput.Position - dragStart
			frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
		end
	end)
end

--// Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NightGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 130)
mainFrame.Position = UDim2.new(0, 10, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false -- handled manually
mainFrame.Parent = screenGui

makeDraggable(mainFrame)

-- Buttons inside main UI
local aimbotBtn = createButton("AimbotToggle", mainFrame, "Aimbot: OFF", 0)
local tracersBtn = createButton("TracersToggle", mainFrame, "Tracers: OFF", 30)
local minimizeBtn = createButton("Minimize", mainFrame, "-", 60)
local closeBtn = createButton("Close", mainFrame, "X", 90)

-- Expand button
local expandBtn = Instance.new("TextButton")
expandBtn.Name = "Expand"
expandBtn.Text = "+"
expandBtn.Size = UDim2.new(0, 30, 0, 30)
expandBtn.Position = UDim2.new(0, 10, 0.3, 0)
expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expandBtn.Font = Enum.Font.GothamBold
expandBtn.TextSize = 20
expandBtn.Visible = false
expandBtn.Active = true
expandBtn.Draggable = false
expandBtn.Parent = screenGui

makeDraggable(expandBtn)

--// Utility Functions
local function isVisible(part)
	local origin = camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 1000

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {player.Character or nil, camera}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = Workspace:Raycast(origin, direction, rayParams)
	return result and part:IsDescendantOf(result.Instance.Parent)
end

local function getClosestEnemy()
	local closest, shortest = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Team ~= player.Team then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")

			if hrp and hum and hum.Health > 0 and isVisible(hrp) then
				local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
					if dist < shortest then
						shortest = dist
						closest = hrp
					end
				end
			end
		end
	end
	return closest
end

local function clearDrawings()
	for _, d in ipairs(drawings) do
		if d.box then d.box:Remove() end
		if d.line then d.line:Remove() end
	end
	drawings = {}
end

local function drawBoxAndLine(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not (hrp and head and hum and hum.Health > 0) then return end

	local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
	if not onScreen then return end

	local boxSize = Vector2.new(50, 100)
	local topLeft = Vector2.new(screenPos.X, screenPos.Y) - boxSize / 2
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

	local box = Drawing.new("Square")
	box.Position = topLeft
	box.Size = boxSize
	box.Color = Color3.fromRGB(0, 255, 0)
	box.Thickness = 1
	box.Visible = true

	local line = Drawing.new("Line")
	line.From = center
	line.To = Vector2.new(screenPos.X, screenPos.Y)
	line.Color = Color3.fromRGB(255, 0, 0)
	line.Thickness = 1
	line.Visible = true

	table.insert(drawings, {box = box, line = line})
end

--// Aimbot + ESP loop
RunService.RenderStepped:Connect(function()
	if aimbotEnabled then
		frameCounter += 1
		if (not currentTarget or not currentTarget.Parent:FindFirstChildWhichIsA("Humanoid") or currentTarget.Parent:FindFirstChildWhichIsA("Humanoid").Health <= 0)
			and frameCounter % checkDelay == 0 then
			currentTarget = getClosestEnemy()
		end

		if currentTarget then
			local dir = (currentTarget.Position - camera.CFrame.Position).Unit
			camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + dir)
		end
	end

	if tracersEnabled then
		clearDrawings()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Team ~= player.Team and plr.Character then
				drawBoxAndLine(plr.Character)
			end
		end
	else
		clearDrawings()
	end
end)

--// Button Events
aimbotBtn.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	aimbotBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

tracersBtn.MouseButton1Click:Connect(function()
	tracersEnabled = not tracersEnabled
	tracersBtn.Text = "Tracers: " .. (tracersEnabled and "ON" or "OFF")
end)

minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	expandBtn.Visible = true
end)

expandBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	expandBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	clearDrawings()
	screenGui:Destroy()
end)