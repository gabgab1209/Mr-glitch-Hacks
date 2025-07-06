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

	-- Main GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MrGlitchGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Fly Controls GUI
	local flyGui = Instance.new("ScreenGui")
	flyGui.Name = "FlyControlsGui"
	flyGui.ResetOnSpawn = false
	flyGui.Enabled = false
	flyGui.Parent = playerGui

	local flyControlFrame = Instance.new("Frame")
	flyControlFrame.Size = UDim2.new(0, 220, 0, 250)
	flyControlFrame.Position = UDim2.new(1, -240, 1, -270)
	flyControlFrame.BackgroundTransparency = 0.3
	flyControlFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	flyControlFrame.Parent = flyGui
	roundify(flyControlFrame, 10)

	local function createFlyButton(name, pos, symbol)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0, 50, 0, 50)
		btn.Position = pos
		btn.Text = symbol
		btn.TextScaled = true
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.AutoButtonColor = true
		btn.Parent = flyControlFrame
		roundify(btn, 10)
		return btn
	end

	local btnUp = createFlyButton("FlyUp", UDim2.new(0.5, -25, 0, 10), "⬆️")
	local btnDown = createFlyButton("FlyDown", UDim2.new(0.5, -25, 0, 190), "⬇️")
	local btnLeft = createFlyButton("FlyLeft", UDim2.new(0, 10, 0, 100), "⬅️")
	local btnRight = createFlyButton("FlyRight", UDim2.new(1, -60, 0, 100), "➡️")
	local btnForward = createFlyButton("FlyForward", UDim2.new(0.5, -25, 0, 60), "🔼")
	local btnBack = createFlyButton("FlyBack", UDim2.new(0.5, -25, 0, 140), "🔽")

	local speedSliderLabel = Instance.new("TextLabel")
	speedSliderLabel.Size = UDim2.new(1, -20, 0, 20)
	speedSliderLabel.Position = UDim2.new(0, 10, 0, 220)
	speedSliderLabel.Text = "Fly Speed"
	speedSliderLabel.TextColor3 = Color3.new(1, 1, 1)
	speedSliderLabel.TextScaled = true
	speedSliderLabel.BackgroundTransparency = 1
	speedSliderLabel.Parent = flyControlFrame

	local speedSlider = Instance.new("TextBox")
	speedSlider.Size = UDim2.new(1, -20, 0, 30)
	speedSlider.Position = UDim2.new(0, 10, 0, 240)
	speedSlider.PlaceholderText = "100"
	speedSlider.Text = "100"
	speedSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	speedSlider.TextColor3 = Color3.new(0, 0, 0)
	speedSlider.TextScaled = true
	speedSlider.ClearTextOnFocus = false
	speedSlider.Parent = flyControlFrame
	roundify(speedSlider, 6)

	-- Intro
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

	-- Main Frame
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Size = UDim2.new(0, 420, 0, 500)
	backgroundFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
	backgroundFrame.BorderSizePixel = 0
	backgroundFrame.Active = true
	backgroundFrame.Draggable = true
	backgroundFrame.Visible = false
	backgroundFrame.Parent = screenGui
	roundify(backgroundFrame, 12)

	-- UI Elements
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.7, 0, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
	title.Text = "Mr Glitch Hacks"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.SourceSansBold
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = backgroundFrame
	roundify(title, 0)

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 60, 0, 40)
	closeButton.Position = UDim2.new(1, -150, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Text = "-"
	closeButton.Parent = backgroundFrame
	roundify(closeButton, 8)

	local deleteButton = Instance.new("TextButton")
	deleteButton.Size = UDim2.new(0, 60, 0, 40)
	deleteButton.Position = UDim2.new(1, -80, 0, 10)
	deleteButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	deleteButton.TextColor3 = Color3.new(1, 1, 1)
	deleteButton.Text = "X"
	deleteButton.Parent = backgroundFrame
	roundify(deleteButton, 8)
	deleteButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
		if flyGui then
			flyGui:Destroy()
		end
	end)

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

	-- WalkSpeed and JumpPower UI setup (same as before)
	-- [Cut here for space — this section is identical to earlier script]
	-- WalkSpeed Label
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

	-- WalkSpeed TextBox
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

	-- Apply Button
	local speedApply = Instance.new("TextButton")
	speedApply.Size = UDim2.new(0, 120, 0, 40)
	speedApply.Position = UDim2.new(0, 220, 0, 140)
	speedApply.Text = "Apply Speed"
	speedApply.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	speedApply.TextColor3 = Color3.new(1, 1, 1)
	speedApply.TextScaled = true
	speedApply.Parent = backgroundFrame
	roundify(speedApply, 8)

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

	-- Noclip & Fly Buttons
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

	local afkButton = Instance.new("TextButton")
    afkButton.Size = UDim2.new(0, 140, 0, 40)
    afkButton.Position = UDim2.new(0, 10, 0, 420)
    afkButton.Text = "❌ Anti-AFK: OFF"
    afkButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    afkButton.TextColor3 = Color3.new(1, 1, 1)
    afkButton.TextScaled = true
    afkButton.Font = Enum.Font.SourceSansBold
    afkButton.Parent = backgroundFrame
    roundify(afkButton, 8)
    
    local godButton = Instance.new("TextButton")
godButton.Size = UDim2.new(0, 140, 0, 40)
godButton.Position = UDim2.new(0, 10, 0, 480)
godButton.Text = "❌ God Mode: OFF"
godButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
godButton.TextColor3 = Color3.new(1, 1, 1)
godButton.TextScaled = true
godButton.Font = Enum.Font.SourceSansBold
godButton.Parent = backgroundFrame
roundify(godButton, 8)


	-- Show GUI
	-- Initial position (off screen to the left)
	intro.Position = UDim2.new(-1, 0, 0, 0)
	-- Create and play the slide-in animation
	local slideIn = ts:Create(intro, TweenInfo.new(
		1.5, -- Duration
		Enum.EasingStyle.Back, -- Easing style
		Enum.EasingDirection.Out -- Easing direction
		), {
			Position = UDim2.new(0, 0, 0, 0), -- Final position
			TextTransparency = 0 -- Fade in simultaneously
		})
	slideIn.Completed:Connect(function()
		wait(1) -- Wait before fading out
		-- Create and play fade out animation
		local fadeOut = ts:Create(intro, TweenInfo.new(2), {
			TextTransparency = 1
		})
		fadeOut.Completed:Connect(function()
			intro:Destroy()
			backgroundFrame.Visible = true
		end)
		fadeOut:Play()
	end)
	slideIn:Play()

	-- Functionality
	local humanoid = nil
	local jumpConnection, noclipConnection, flyConnection = nil, nil, nil
	local flying = false
	local noclipEnabled = false
	local flyBV = nil
	local flyDir = Vector3.zero
	local movement = {Forward = false, Back = false, Left = false, Right = false, Up = false, Down = false}

	-- GUI Logic
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

	-- Replace with your WalkSpeed & JumpPower logic here (omitted for brevity)
	speedApply.MouseButton1Click:Connect(function()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local val = tonumber(speedBox.Text)
			if val then
				humanoid.WalkSpeed = val
			end
		end
	end)

	jumpApply.MouseButton1Click:Connect(function()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local val = tonumber(jumpBox.Text)
			if val then
				humanoid.JumpPower = val
			end
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

	-- ✈️ Fly System
	flyButton.MouseButton1Click:Connect(function()
		flying = not flying
		flyButton.Text = flying and "✅ Fly: ON" or "✈️ Fly: OFF"
		flyButton.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(180, 0, 255)
		flyGui.Enabled = flying

		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if flying and hrp and hum then
			hum.PlatformStand = true
			flyBV = Instance.new("BodyVelocity")
			flyBV.MaxForce = Vector3.new(1, 1, 1) * math.huge
			flyBV.Velocity = Vector3.zero
			flyBV.P = 10000
			flyBV.Name = "FlyVelocity"
			flyBV.Parent = hrp

			flyConnection = rs.RenderStepped:Connect(function()
				local cam = workspace.CurrentCamera
				flyDir = Vector3.zero

				local flySpeed = tonumber(speedSlider.Text) or 100

				if uis:IsKeyDown(Enum.KeyCode.W) or movement.Forward then flyDir += cam.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.S) or movement.Back then flyDir -= cam.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.A) or movement.Left then flyDir -= cam.CFrame.RightVector end
				if uis:IsKeyDown(Enum.KeyCode.D) or movement.Right then flyDir += cam.CFrame.RightVector end
				if uis:IsKeyDown(Enum.KeyCode.Space) or movement.Up then flyDir += cam.CFrame.UpVector end
				if uis:IsKeyDown(Enum.KeyCode.LeftControl) or movement.Down then flyDir -= cam.CFrame.UpVector end

				if flyDir.Magnitude > 0 then
					flyBV.Velocity = flyDir.Unit * flySpeed
				else
					flyBV.Velocity = Vector3.zero
				end
			end)
		else
			if flyConnection then flyConnection:Disconnect() end
			if flyBV then flyBV:Destroy() end
			if hum then hum.PlatformStand = false end
			flyGui.Enabled = false
		end
	end)

	-- Mobile Controls
	local function bindFlyButton(btn, key)
		btn.MouseButton1Down:Connect(function() movement[key] = true end)
		btn.MouseButton1Up:Connect(function() movement[key] = false end)
	end

	bindFlyButton(btnUp, "Up")
	bindFlyButton(btnDown, "Down")
	bindFlyButton(btnLeft, "Left")
	bindFlyButton(btnRight, "Right")
	bindFlyButton(btnForward, "Forward")
	bindFlyButton(btnBack, "Back")
	-- Anti-AFK
	local antiAfkEnabled = false
    local afkConnection = nil

    afkButton.MouseButton1Click:Connect(function()
		antiAfkEnabled = not antiAfkEnabled
		afkButton.Text = antiAfkEnabled and "✅ Anti-AFK: ON" or "❌ Anti-AFK: OFF"
		afkButton.BackgroundColor3 = antiAfkEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)

			if antiAfkEnabled then
			if afkConnection then afkConnection:Disconnect() end
			afkConnection = rs.Stepped:Connect(function()
			-- simulate user activity every few minutes
				if math.random(1, 600) == 1 then
					local virtualUser = game:GetService("VirtualUser")
					virtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
					wait(1)
					virtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				end
			end)
		else
			if afkConnection then afkConnection:Disconnect() afkConnection = nil end
		end
	end)

local godModeEnabled = false
local healthConnection = nil
local stateBlockConnection = nil

godButton.MouseButton1Click:Connect(function()
	godModeEnabled = not godModeEnabled
	godButton.Text = godModeEnabled and "✅ God Mode: ON" or "❌ God Mode: OFF"
	godButton.BackgroundColor3 = godModeEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(180, 0, 0)

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if godModeEnabled and hum then
		hum.MaxHealth = math.huge
		hum.Health = math.huge

		-- Prevent health drops
		healthConnection = hum.HealthChanged:Connect(function()
			if hum.Health < hum.MaxHealth then
				hum.Health = hum.MaxHealth
			end
		end)

		-- Block death state
		stateBlockConnection = hum.StateChanged:Connect(function(_, new)
			if new == Enum.HumanoidStateType.Dead then
				hum:ChangeState(Enum.HumanoidStateType.Running)
				hum.Health = hum.MaxHealth
			end
		end)

	else
		if healthConnection then healthConnection:Disconnect() end
		if stateBlockConnection then stateBlockConnection:Disconnect() end
	end
end)