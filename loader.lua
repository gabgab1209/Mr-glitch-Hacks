-- Put this LocalScript in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toggles = {
	InfiniteJump = false,
	Noclip = false,
	Fly = false,
}

-- Input State for Fly
local keys = { W = false, A = false, S = false, D = false }
local flying = false
local flyConnection, bodyVel

-- Restore UI button
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TabbedNightGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local restoreButton = Instance.new("TextButton")
restoreButton.Size = UDim2.new(0, 120, 0, 30)
restoreButton.Position = UDim2.new(0, 20, 0.25, 0)
restoreButton.Text = "🔄 Restore GUI"
restoreButton.Visible = false
restoreButton.BackgroundColor3 = Color3.fromRGB(60, 100, 120)
restoreButton.TextColor3 = Color3.new(1, 1, 1)
restoreButton.Font = Enum.Font.Gotham
restoreButton.TextSize = 14
Instance.new("UICorner", restoreButton)
restoreButton.Parent = screenGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 280)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Name = "MainFrame"
frame.Parent = screenGui
Instance.new("UICorner", frame)

-- Top Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
tabBar.Parent = frame
Instance.new("UICorner", tabBar)

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 22, 0, 22)
closeButton.Position = UDim2.new(1, -26, 0, 4)
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
Instance.new("UICorner", closeButton)
closeButton.Parent = tabBar

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 22, 0, 22)
minimizeButton.Position = UDim2.new(1, -54, 0, 4)
minimizeButton.Text = "—"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 100, 120)
Instance.new("UICorner", minimizeButton)
minimizeButton.Parent = tabBar

minimizeButton.MouseButton1Click:Connect(function()
	frame.Visible = false
	restoreButton.Visible = true
end)

restoreButton.MouseButton1Click:Connect(function()
	frame.Visible = true
	restoreButton.Visible = false
end)

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Tab System
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

local pages = {}
local function createPage(name)
	local tabButton = Instance.new("TextButton")
	tabButton.Size = UDim2.new(0, 100, 0, 26)
	tabButton.Position = UDim2.new(0, (#pages * 100) + 4, 0, 2)
	tabButton.Text = name
	tabButton.Font = Enum.Font.GothamSemibold
	tabButton.TextSize = 14
	tabButton.TextColor3 = Color3.new(1, 1, 1)
	tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	Instance.new("UICorner", tabButton)
	tabButton.Parent = tabBar

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentFrame

	table.insert(pages, {Name = name, Button = tabButton, Frame = page})

	tabButton.MouseButton1Click:Connect(function()
		for _, pg in ipairs(pages) do
			pg.Frame.Visible = false
			pg.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
		end
		page.Visible = true
		tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
	end)

	return page
end

-- Movement Page
local movementPage = createPage("Movement")

local function createToggle(parent, text, position, key, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 36)
	btn.Position = UDim2.new(0, 10, 0, position)
	btn.Text = text .. ": OFF"
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 15
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	Instance.new("UICorner", btn)
	btn.Parent = parent

	btn.MouseButton1Click:Connect(function()
		toggles[key] = not toggles[key]
		btn.Text = text .. (toggles[key] and ": ON ✅" or ": OFF")
		if callback then callback(toggles[key]) end
	end)
end

-- Toggle Buttons
createToggle(movementPage, "Infinite Jump", 10, "InfiniteJump")
createToggle(movementPage, "Noclip", 56, "Noclip", function(state)
	if not state then
		local char = player.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end)

createToggle(movementPage, "Fly", 102, "Fly", function(state)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if state then
		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyVel.P = 1250
		bodyVel.Velocity = Vector3.zero
		bodyVel.Name = "FlyVelocity"
		bodyVel.Parent = hrp

		flying = true
		flyConnection = RunService.RenderStepped:Connect(function()
			local dir = Vector3.zero
			local cam = workspace.CurrentCamera
			if keys.W then dir += cam.CFrame.LookVector end
			if keys.S then dir -= cam.CFrame.LookVector end
			if keys.A then dir -= cam.CFrame.RightVector end
			if keys.D then dir += cam.CFrame.RightVector end
			bodyVel.Velocity = dir.Unit * 50
			if dir.Magnitude == 0 then bodyVel.Velocity = Vector3.zero end
		end)
	else
		flying = false
		if flyConnection then flyConnection:Disconnect() flyConnection = nil end
		if bodyVel then bodyVel:Destroy() bodyVel = nil end
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local key = input.KeyCode.Name
	if keys[key] ~= nil then keys[key] = true end
end)
UserInputService.InputEnded:Connect(function(input)
	local key = input.KeyCode.Name
	if keys[key] ~= nil then keys[key] = false end
end)

-- Speed/Jump Input
local function createLabeledInput(parent, label, y, callback)
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = label
	textLabel.Position = UDim2.new(0, 10, 0, y)
	textLabel.Size = UDim2.new(0, 120, 0, 20)
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 13
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = parent

	local input = Instance.new("TextBox")
	input.PlaceholderText = "e.g. 16"
	input.Position = UDim2.new(0, 10, 0, y + 20)
	input.Size = UDim2.new(0.5, -15, 0, 26)
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.TextColor3 = Color3.new(1, 1, 1)
	input.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	input.ClearTextOnFocus = false
	Instance.new("UICorner", input)
	input.Parent = parent

	local apply = Instance.new("TextButton")
	apply.Text = "Apply"
	apply.Size = UDim2.new(0.4, 0, 0, 26)
	apply.Position = UDim2.new(0.55, 0, 0, y + 20)
	apply.Font = Enum.Font.GothamBold
	apply.TextSize = 13
	apply.TextColor3 = Color3.new(1, 1, 1)
	apply.BackgroundColor3 = Color3.fromRGB(70, 100, 90)
	Instance.new("UICorner", apply)
	apply.Parent = parent

	apply.MouseButton1Click:Connect(function()
		local val = tonumber(input.Text)
		if val and player.Character and player.Character:FindFirstChild("Humanoid") then
			callback(player.Character.Humanoid, val)
		end
	end)
end

createLabeledInput(movementPage, "WalkSpeed", 150, function(hum, val)
	hum.WalkSpeed = val
end)

createLabeledInput(movementPage, "JumpPower", 200, function(hum, val)
	hum.JumpPower = val
end)

-- Server Info Page
local serverPage = createPage("Server Info")

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 140)
infoLabel.Position = UDim2.new(0, 10, 0, 20)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 14
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Loading server info..."
infoLabel.Parent = serverPage

RunService.RenderStepped:Connect(function()
	local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
	local jobId = game.JobId
	local playerCount = #Players:GetPlayers()
	infoLabel.Text = string.format(
		"🌐 Server ID:\n%s\n\n👥 Players: %d\n📶 Ping: %d ms",
		jobId, playerCount, ping
	)
end)

-- Default to first tab
task.wait()
if #pages > 0 then
	pages[1].Frame.Visible = true
	pages[1].Button.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
end