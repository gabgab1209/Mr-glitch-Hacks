-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- States
local aimbotEnabled = false
local tracersEnabled = false
local currentTarget = nil
local frameCounter = 0
local checkDelay = 5
local trackedCharacters = {}
local smoothness = 0.15

-- Aesthetic UI functions
local function roundify(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = instance
end

local function glowify(instance)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(100, 100, 255)
	stroke.Transparency = 0.3
	stroke.Parent = instance
end

local function createStyledButton(name, parent, text, y)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	btn.TextColor3 = Color3.fromRGB(220, 220, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	end)
	btn.Parent = parent
	roundify(btn)
	glowify(btn)
	return btn
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AestheticGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 180)
mainFrame.Position = UDim2.new(0, 20, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
roundify(mainFrame)
glowify(mainFrame)

local title = Instance.new("TextLabel")
title.Text = "⚙️ SilentTools"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(140, 200, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.Parent = mainFrame

local aimbotBtn = createStyledButton("AimbotToggle", mainFrame, "Aimbot: OFF", 30)
local tracersBtn = createStyledButton("TracersToggle", mainFrame, "Tracers: OFF", 70)
local minimizeBtn = createStyledButton("Minimize", mainFrame, "-", 110)
local closeBtn = createStyledButton("Close", mainFrame, "X", 145)

local expandBtn = Instance.new("TextButton")
expandBtn.Text = "+"
expandBtn.Size = UDim2.new(0, 30, 0, 30)
expandBtn.Position = UDim2.new(0, 20, 0.3, 0)
expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expandBtn.Font = Enum.Font.GothamBlack
expandBtn.TextSize = 20
expandBtn.Visible = false
expandBtn.Parent = screenGui
roundify(expandBtn)
glowify(expandBtn)

-- Visibility Check
local function isVisible(part, model)
	local origin = camera.CFrame.Position
	local direction = (part.Position - origin)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {player.Character, camera}
	local result = Workspace:Raycast(origin, direction, rayParams)
	return result and result.Instance and model and result.Instance:IsDescendantOf(model)
end

-- Get Closest Enemy (Head)
local function getClosestEnemy()
	local closest, shortest = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Team ~= player.Team then
			local char = plr.Character
			local head = char and char:FindFirstChild("Head")
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if head and hum and hum.Health > 0 and isVisible(head, char) then
				local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
					if dist < shortest then
						shortest = dist
						closest = head
					end
				end
			end
		end
	end
	return closest
end

-- Tracer Drawing
local function updateTracerForCharacter(char)
	if char == player.Character then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	local plr = Players:GetPlayerFromCharacter(char)

	if not (hrp and head and humanoid and humanoid.Health > 0) then
		if trackedCharacters[char] then
			trackedCharacters[char].box:Remove()
			trackedCharacters[char].line:Remove()
			trackedCharacters[char] = nil
		end
		return
	end
	if plr and plr.Team == player.Team then return end

	local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

	if not onScreen or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
		if trackedCharacters[char] then
			trackedCharacters[char].box.Visible = false
			trackedCharacters[char].line.Visible = false
		end
		return
	end

	local size = Vector2.new(50, 100)
	local topLeft = Vector2.new(screenPos.X, screenPos.Y) - size / 2

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

-- Render Loop
RunService.RenderStepped:Connect(function()
	frameCounter += 1

	-- Aimbot
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
			local newDir = (currentTarget.Position - camera.CFrame.Position).Unit
			local lerp = camera.CFrame.LookVector:Lerp(newDir, smoothness)
			camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + lerp)
		end
	end

	-- Tracers
	for _, char in ipairs(Workspace:GetChildren()) do
		if char:IsA("Model") and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildWhichIsA("Humanoid") then
			updateTracerForCharacter(char)
		end
	end
end)

-- Button Callbacks
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