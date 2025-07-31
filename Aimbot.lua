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