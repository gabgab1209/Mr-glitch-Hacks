--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

--// Settings
local aimbotEnabled = false
local tracersEnabled = false
local frameCounter = 0
local checkDelay = 5
local currentTarget = nil
local trackedCharacters = {}
local smoothness = 0.15 -- Lower is faster

--// Draggable helper
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

--// UI creation
local function createButton(name, parent, text, y)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Position = UDim2.new(0, 0, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.fromRGB(200, 200, 255)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	btn.Parent = parent
	return btn
end

--// GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NightGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 130)
mainFrame.Position = UDim2.new(0, 10, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

makeDraggable(mainFrame)

local aimbotBtn = createButton("AimbotToggle", mainFrame, "Aimbot: OFF", 0)
local tracersBtn = createButton("TracersToggle", mainFrame, "Tracers: OFF", 30)
local minimizeBtn = createButton("Minimize", mainFrame, "-", 60)
local closeBtn = createButton("Close", mainFrame, "X", 90)

local expandBtn = Instance.new("TextButton")
expandBtn.Text = "+"
expandBtn.Size = UDim2.new(0, 30, 0, 30)
expandBtn.Position = UDim2.new(0, 10, 0.3, 0)
expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expandBtn.Font = Enum.Font.GothamBold
expandBtn.TextSize = 20
expandBtn.Visible = false
expandBtn.Parent = screenGui

makeDraggable(expandBtn)

--// Wall Check
local function isVisible(part, model)
	local origin = camera.CFrame.Position
	local direction = (part.Position - origin)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {player.Character, camera}
	local result = Workspace:Raycast(origin, direction, rayParams)
	return result and result.Instance and model and result.Instance:IsDescendantOf(model)
end

--// Enemy Targeting
local function getClosestEnemy()
	local closest, shortest = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Team ~= player.Team then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if hrp and hum and hum.Health > 0 and isVisible(hrp, char) then
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

--// Tracers
local function updateTracerForCharacter(char)
	if char == player.Character then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	local plr = Players:GetPlayerFromCharacter(char)
	if not (hrp and humanoid and humanoid.Health > 0) then
		if trackedCharacters[char] then
			trackedCharacters[char].box:Remove()
			trackedCharacters[char].line:Remove()
			trackedCharacters[char] = nil
		end
		return
	end
	if plr and plr.Team == player.Team then return end
	local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
	if not onScreen then
		if trackedCharacters[char] then
			trackedCharacters[char].box.Visible = false
			trackedCharacters[char].line.Visible = false
		end
		return
	end

	local size = Vector2.new(50, 100)
	local topLeft = Vector2.new(screenPos.X, screenPos.Y) - size / 2
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

	if not trackedCharacters[char] then
		local box = Drawing.new("Square")
		box.Thickness = 2
		box.Color = Color3.fromRGB(0, 255, 0)
		box.Filled = false
		box.Visible = true

		local line = Drawing.new("Line")
		line.Thickness = 1.5
		line.Color = Color3.fromRGB(255, 0, 0)
		line.Visible = true

		trackedCharacters[char] = {box = box, line = line}
	end

	local box = trackedCharacters[char].box
	local line = trackedCharacters[char].line

	box.Position = topLeft
	box.Size = size
	box.Visible = tracersEnabled

	line.From = center
	line.To = Vector2.new(screenPos.X, screenPos.Y)
	line.Visible = tracersEnabled
end

--// Main Loop
RunService.RenderStepped:Connect(function()
	frameCounter += 1

	-- Aimbot Logic
	if aimbotEnabled then
		if currentTarget then
			local char = currentTarget.Parent
			local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
			if not humanoid or humanoid.Health <= 0 or not isVisible(currentTarget, char) then
				currentTarget = nil
			end
		end

		if not currentTarget and frameCounter % checkDelay == 0 then
			currentTarget = getClosestEnemy()
		end

		if currentTarget then
			local targetPos = currentTarget.Position
			local newDirection = (targetPos - camera.CFrame.Position).Unit
			local currentDir = camera.CFrame.LookVector
			local lerped = currentDir:Lerp(newDirection, smoothness)
			camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + lerped)
		end
	end

	-- Tracers
	for _, char in ipairs(Workspace:GetChildren()) do
		if char:IsA("Model") and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildWhichIsA("Humanoid") then
			updateTracerForCharacter(char)
		end
	end
end)

--// Buttons
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
	for _, data in pairs(trackedCharacters) do
		if data.box then data.box:Remove() end
		if data.line then data.line:Remove() end
	end
	trackedCharacters = {}
	screenGui:Destroy()
end)