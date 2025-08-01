-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- CONFIG
local aimbotEnabled = false
local tracersEnabled = false
local smoothness = 0.15
local checkDelay = 5
local currentTarget = nil
local frameCounter = 0
local trackedCharacters = {}

-- GUI HELPERS
local function roundify(ui, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = ui
end

local function glowify(ui)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(100, 100, 255)
	stroke.Transparency = 0.3
	stroke.Parent = ui
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
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55) end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35) end)
	btn.Parent = parent
	roundify(btn)
	glowify(btn)
	return btn
end

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "SilentToolsGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.Active = true
frame.Draggable = true
roundify(frame)
glowify(frame)

local title = Instance.new("TextLabel", frame)
title.Text = "⚙️ SilentTools PRO"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(140, 200, 255)

local aimbotBtn = createStyledButton("AimbotToggle", frame, "Aimbot: OFF", 30)
local tracersBtn = createStyledButton("TracersToggle", frame, "Tracers: OFF", 70)
local minimizeBtn = createStyledButton("Minimize", frame, "-", 110)
local closeBtn = createStyledButton("Close", frame, "X", 145)

local expandBtn = Instance.new("TextButton", gui)
expandBtn.Text = "+"
expandBtn.Size = UDim2.new(0, 30, 0, 30)
expandBtn.Position = UDim2.new(0, 20, 0.3, 0)
expandBtn.Visible = false
expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expandBtn.Font = Enum.Font.GothamBlack
expandBtn.TextSize = 20
roundify(expandBtn)
glowify(expandBtn)

-- WALL CHECK
local function isVisible(part, model)
	local origin = camera.CFrame.Position
	local direction = (part.Position - origin)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {player.Character, camera}
	local result = Workspace:Raycast(origin, direction, rayParams)
	return result and result.Instance and model and result.Instance:IsDescendantOf(model)
end

-- ENEMY HEAD FINDER
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

-- UPDATE TRACERS
local function updateTracerForCharacter(char)
	if char == player.Character then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	local plr = Players:GetPlayerFromCharacter(char)

	if not (hrp and head and hum and hum.Health > 0) or (plr and plr.Team == player.Team) then
		if trackedCharacters[char] then
			for _, obj in pairs(trackedCharacters[char]) do
				if typeof(obj) == "Drawing" then obj:Remove() end
			end
			trackedCharacters[char] = nil
		end
		return
	end

	local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
	if not onScreen or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
		if trackedCharacters[char] then
			for _, obj in pairs(trackedCharacters[char]) do
				obj.Visible = false
			end
		end
		return
	end

	if not trackedCharacters[char] then
		trackedCharacters[char] = {
			box = Drawing.new("Square"),
			line = Drawing.new("Line"),
			hpText = Drawing.new("Text")
		}
		trackedCharacters[char].box.Filled = false
		trackedCharacters[char].box.Thickness = 2
		trackedCharacters[char].line.Thickness = 1.5
		trackedCharacters[char].hpText.Size = 14
		trackedCharacters[char].hpText.Center = true
		trackedCharacters[char].hpText.Outline = true
		trackedCharacters[char].hpText.Font = 2
	end

	local box = trackedCharacters[char].box
	local line = trackedCharacters[char].line
	local text = trackedCharacters[char].hpText

	local distance = (camera.CFrame.Position - hrp.Position).Magnitude
	local size = Vector2.new(50, 100) / (distance / 25)
	local topLeft = Vector2.new(screenPos.X, screenPos.Y) - size / 2
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

	local low = hum.Health <= 30
	box.Color = low and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 0)
	line.Color = low and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 0)

	box.Thickness = (currentTarget and currentTarget.Parent == char) and 3 or 2

	box.Position = topLeft
	box.Size = size
	box.Visible = tracersEnabled

	line.From = center
	line.To = Vector2.new(screenPos.X, screenPos.Y)
	line.Visible = tracersEnabled

	text.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y / 2 - 10)
	text.Text = string.format("%.0f HP", hum.Health)
	text.Color = low and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
	text.Visible = tracersEnabled
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
	frameCounter += 1

	if aimbotEnabled then
		if currentTarget then
			local char = currentTarget.Parent
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if not hum or hum.Health <= 0 or not isVisible(currentTarget, char) then
				currentTarget = nil
			end
		end
		if not currentTarget and frameCounter % checkDelay == 0 then
			currentTarget = getClosestEnemy()
		end
		if currentTarget then
			local dir = (currentTarget.Position - camera.CFrame.Position).Unit
			local smooth = camera.CFrame.LookVector:Lerp(dir, smoothness)
			camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + smooth)
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Team ~= player.Team then
			local char = plr.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
				updateTracerForCharacter(char)
			end
		end
	end
end)

-- UI BUTTON LOGIC
aimbotBtn.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	aimbotBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

tracersBtn.MouseButton1Click:Connect(function()
	tracersEnabled = not tracersEnabled
	tracersBtn.Text = "Tracers: " .. (tracersEnabled and "ON" or "OFF")
end)

minimizeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	expandBtn.Visible = true
end)

expandBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	expandBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	for _, data in pairs(trackedCharacters) do
		for _, obj in pairs(data) do if obj.Remove then obj:Remove() end end
	end
	gui:Destroy()
end)