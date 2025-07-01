local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")

-- Helper Functions
local function roundify(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = obj
end

local function createLine(parent, yPos)
	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -20, 0, 2)
	line.Position = UDim2.new(0, 10, 0, yPos)
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BorderSizePixel = 0
	line.BackgroundTransparency = 0.5
	line.Parent = parent
	roundify(line, 1)
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MrGlitchGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Intro Text
local intro = Instance.new("TextLabel")
intro.Size = UDim2.new(1, 0, 1, 0)
intro.BackgroundTransparency = 1
intro.TextColor3 = Color3.new(1, 0, 1)
intro.TextStrokeTransparency = 0
intro.Text = "Mr Glitch Hacks"
intro.TextScaled = true
intro.Font = Enum.Font.Arcade
intro.ZIndex = 10
intro.Parent = screenGui

-- Main GUI Frame
local backgroundFrame = Instance.new("Frame")
backgroundFrame.Size = UDim2.new(0, 420, 0, 520)
backgroundFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
backgroundFrame.BorderSizePixel = 0
backgroundFrame.Active = true
backgroundFrame.Draggable = true
backgroundFrame.Visible = false
backgroundFrame.Parent = screenGui
roundify(backgroundFrame, 12)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
title.Text = "Mr Glitch Hacks"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = backgroundFrame
roundify(title, 0)

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 100, 0, 40)
closeButton.Position = UDim2.new(1, -110, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "❌ Close"
closeButton.Parent = backgroundFrame
roundify(closeButton, 8)

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 50, 0, 50)
minimizeButton.Position = UDim2.new(0, 10, 1, -60)
minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
minimizeButton.Text = "+"
minimizeButton.TextScaled = true
minimizeButton.Visible = false
minimizeButton.BorderSizePixel = 0
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Active = true
minimizeButton.Draggable = true
minimizeButton.Parent = screenGui
roundify(minimizeButton, 25)

-- Infinite Jump Toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 130, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "🔘 Infinite Jump: OFF"
toggleButton.TextWrapped = true
toggleButton.Parent = backgroundFrame
roundify(toggleButton, 8)

createLine(backgroundFrame, 100)

-- WalkSpeed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 110)
speedLabel.Text = "Set WalkSpeed"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextScaled = true
speedLabel.Parent = backgroundFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 200, 0, 40)
speedBox.Position = UDim2.new(0, 10, 0, 140)
speedBox.PlaceholderText = "e.g. 100"
speedBox.Text = ""
speedBox.TextScaled = true
speedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextColor3 = Color3.new(0, 0, 0)
speedBox.Parent = backgroundFrame
roundify(speedBox, 8)

local speedApply = Instance.new("TextButton")
speedApply.Size = UDim2.new(0, 120, 0, 40)
speedApply.Position = UDim2.new(0, 220, 0, 140)
speedApply.Text = "Apply Speed"
speedApply.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
speedApply.TextColor3 = Color3.new(1, 1, 1)
speedApply.TextScaled = true
speedApply.Parent = backgroundFrame
roundify(speedApply, 8)

createLine(backgroundFrame, 200)

-- JumpPower
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, -20, 0, 20)
jumpLabel.Position = UDim2.new(0, 10, 0, 210)
jumpLabel.Text = "Set JumpPower"
jumpLabel.TextColor3 = Color3.new(1, 1, 1)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Font = Enum.Font.SourceSans
jumpLabel.TextScaled = true
jumpLabel.Parent = backgroundFrame

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(0, 200, 0, 40)
jumpBox.Position = UDim2.new(0, 10, 0, 240)
jumpBox.PlaceholderText = "e.g. 120"
jumpBox.Text = ""
jumpBox.TextScaled = true
jumpBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.TextColor3 = Color3.new(0, 0, 0)
jumpBox.Parent = backgroundFrame
roundify(jumpBox, 8)

local jumpApply = Instance.new("TextButton")
jumpApply.Size = UDim2.new(0, 120, 0, 40)
jumpApply.Position = UDim2.new(0, 220, 0, 240)
jumpApply.Text = "Apply Jump"
jumpApply.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
jumpApply.TextColor3 = Color3.new(1, 1, 1)
jumpApply.TextScaled = true
jumpApply.Parent = backgroundFrame
roundify(jumpApply, 8)

-- Noclip Toggle
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(0, 140, 0, 40)
noclipButton.Position = UDim2.new(0, 10, 0, 300)
noclipButton.Text = "🚫 Noclip: OFF"
noclipButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
noclipButton.TextColor3 = Color3.new(1, 1, 1)
noclipButton.TextScaled = true
noclipButton.Font = Enum.Font.SourceSansBold
noclipButton.Parent = backgroundFrame
roundify(noclipButton, 8)

-- Fly Toggle
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 140, 0, 40)
flyButton.Position = UDim2.new(0, 10, 0, 360)
flyButton.Text = "✈️ Fly: OFF"
flyButton.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.TextScaled = true
flyButton.Font = Enum.Font.SourceSansBold
flyButton.Parent = backgroundFrame
roundify(flyButton, 8)

-- GUI show
wait(1.5)
ts:Create(intro, TweenInfo.new(2), {TextTransparency = 1}):Play()
wait(2)
intro:Destroy()
backgroundFrame.Visible = true

-- Functionality
local humanoid = nil
local jumpConnection, noclipConnection, flyConnection = nil, nil, nil
local flying = false
local noclipEnabled = false

closeButton.MouseButton1Click:Connect(function()
	backgroundFrame.Visible = false
	minimizeButton.Visible = true
end)

minimizeButton.MouseButton1Click:Connect(function()
	backgroundFrame.Visible = true
	minimizeButton.Visible = false
end)

toggleButton.MouseButton1Click:Connect(function()
	local isOn = toggleButton.Text:find("OFF") ~= nil
	toggleButton.Text = isOn and "✅ Infinite Jump: ON" or "🔘 Infinite Jump: OFF"
	toggleButton.BackgroundColor3 = isOn and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(0, 200, 0)

	humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if jumpConnection then jumpConnection:Disconnect() end
		if isOn then
			jumpConnection = uis.JumpRequest:Connect(function()
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		end
	end
end)

speedApply.MouseButton1Click:Connect(function()
	humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local val = tonumber(speedBox.Text)
		if val then humanoid.WalkSpeed = val end
	end
end)

jumpApply.MouseButton1Click:Connect(function()
	humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local val = tonumber(jumpBox.Text)
		if val then humanoid.JumpPower = val end
	end
end)

noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipButton.Text = noclipEnabled and "✅ Noclip: ON" or "🚫 Noclip: OFF"
	noclipButton.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 60, 60)

	local function setCollide(state)
		local char = player.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.CanCollide = state
				end
			end
		end
	end

	if noclipEnabled then
		setCollide(false)
		noclipConnection = rs.Stepped:Connect(function()
			setCollide(false)
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() end
		setCollide(true)
	end
end)

flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	flyButton.Text = flying and "✅ Fly: ON" or "✈️ Fly: OFF"
	flyButton.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(180, 0, 255)

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if flying and hrp and hum then
		hum.PlatformStand = true
		flyConnection = rs.RenderStepped:Connect(function()
			if uis:IsKeyDown(Enum.KeyCode.W) then
				hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 0.5
			elseif uis:IsKeyDown(Enum.KeyCode.S) then
				hrp.CFrame = hrp.CFrame - hrp.CFrame.LookVector * 0.5
			end
		end)
	else
		if flyConnection then flyConnection:Disconnect() end
		if hum then hum.PlatformStand = false end
	end
end)