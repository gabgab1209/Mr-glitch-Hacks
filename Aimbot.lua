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