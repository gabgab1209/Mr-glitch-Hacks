local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toggles = {
	InfiniteJump = false,
	Noclip = false,
}

-- ============ SETUP CHARACTER ============
local function setupCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	UserInputService.JumpRequest:Connect(function()
		if toggles.InfiniteJump and humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	RunService.RenderStepped:Connect(function()
		if toggles.Noclip and character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then setupCharacter() end

-- ============ UI BUILD ============

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TabbedNightGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

-- 🔳 Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Name = "MainFrame"
frame.Parent = screenGui
Instance.new("UICorner", frame)

-- 🔹 Top Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
tabBar.BorderSizePixel = 0
tabBar.Parent = frame
Instance.new("UICorner", tabBar)

-- 🛑 Close Button
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

-- 🔼 Page container
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Name = "Content"
contentFrame.Parent = frame

-- 🧩 Utility: Create Tabs and Pages
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

-- 🟦 Movement Page
local movementPage = createPage("Movement")

local function createToggleButton(parent, labelText, order, toggleKey)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, 10 + ((order - 1) * 50))
	btn.Text = labelText .. ": OFF"
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	Instance.new("UICorner", btn)
	btn.Parent = parent

	btn.MouseButton1Click:Connect(function()
		toggles[toggleKey] = not toggles[toggleKey]
		btn.Text = labelText .. (toggles[toggleKey] and ": ON ✅" or ": OFF")
	end)

	return btn
end

createToggleButton(movementPage, "Infinite Jump", 1, "InfiniteJump")
createToggleButton(movementPage, "Noclip", 2, "Noclip")

-- 🟩 Server Info Page
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

-- ❌ Close GUI
closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)