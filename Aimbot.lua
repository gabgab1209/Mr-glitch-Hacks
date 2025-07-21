local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- GUI creation
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PvPGui"
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 260, 0, 370)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -185)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Top bar
local titleBar = Instance.new("TextLabel", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleBar.Text = "PvP Script V5"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 16
titleBar.TextXAlignment = Enum.TextXAlignment.Center

-- Minimize button
local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20

-- Restore button
local restoreBtn = Instance.new("TextButton", screenGui)
restoreBtn.Size = UDim2.new(0, 30, 0, 30)
restoreBtn.Position = UDim2.new(0, 10, 0.5, -15)
restoreBtn.Text = "+"
restoreBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 20
restoreBtn.Visible = false
restoreBtn.Active = true
restoreBtn.Draggable = true

-- Toggle Buttons Setup
local toggleData = {
    "Aimbot", "ESP", "AutoFire", "Prediction",
    "FPS Boost", "Hitbox", "Infinite Jump", "NoClip",
    "TP Walk", "ServerHop"
}

local toggles = {}
for i, name in ipairs(toggleData) do
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, 35 + (i - 1) * 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = "Toggle " .. name
    toggles[name] = btn
end

-- Toggle logic states
local toggleStates = {}
for _, name in ipairs(toggleData) do
    toggleStates[name] = false
end

-- Minimize / restore behavior
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    restoreBtn.Visible = false
end)

-- Touch/mobile drag support
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

-- FPS Boost logic
local function applyFPSBoost()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ShirtGraphic") then
			obj:Destroy()
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
		end
	end
end

-- Full Bright / No Fog
local function applyFullBright()
	Lighting.Brightness = 2
	Lighting.FogEnd = 1e10
	Lighting.GlobalShadows = false
	Lighting.ClockTime = 14
end

Lighting:GetPropertyChangedSignal("FogEnd"):Connect(applyFullBright)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(applyFullBright)
applyFullBright()

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if toggleStates["Infinite Jump"] then
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

-- NoClip
RunService.Stepped:Connect(function()
	if toggleStates["NoClip"] then
		local char = player.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(workspace.Camera) then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- Toggle Behavior Connections
toggles["FPS Boost"].MouseButton1Click:Connect(function()
	applyFPSBoost()
end)

toggles["Infinite Jump"].MouseButton1Click:Connect(function()
	toggleStates["Infinite Jump"] = not toggleStates["Infinite Jump"]
	local btn = toggles["Infinite Jump"]
	btn.Text = toggleStates["Infinite Jump"] and "Infinite Jump: ON" or "Infinite Jump: OFF"
end)

toggles["NoClip"].MouseButton1Click:Connect(function()
	toggleStates["NoClip"] = not toggleStates["NoClip"]
	local btn = toggles["NoClip"]
	btn.Text = toggleStates["NoClip"] and "NoClip: ON" or "NoClip: OFF"
end)

toggles["TP Walk"].MouseButton1Click:Connect(function()
	toggleStates["TP Walk"] = not toggleStates["TP Walk"]
	local btn = toggles["TP Walk"]
	if toggleStates["TP Walk"] then
		btn.Text = "TP Walk: ON"
		local input = StarterGui:GetCore("ChatMakeSystemMessage") and tostring(game:GetService("StarterGui"):PromptTextInput("TP Walk Speed (e.g. 0.3)")) or "0.3"
		toggleStates["TPWalkSpeed"] = tonumber(input) or 0.3
	else
		btn.Text = "TP Walk: OFF"
	end
end)

toggles["Prediction"].MouseButton1Click:Connect(function()
	toggleStates["Prediction"] = not toggleStates["Prediction"]
	local btn = toggles["Prediction"]
	btn.Text = toggleStates["Prediction"] and "Prediction: ON" or "Prediction: OFF"
end)

-- TP Walk Movement
RunService.RenderStepped:Connect(function()
	if toggleStates["TP Walk"] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local root = player.Character.HumanoidRootPart
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
		if move.Magnitude > 0 then
			root.CFrame = root.CFrame + (root.CFrame.LookVector * toggleStates["TPWalkSpeed"])
		end
	end
end)