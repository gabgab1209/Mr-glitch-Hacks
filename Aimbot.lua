local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer

-- 📦 ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFireUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 🔴 Autofire Circle
local autofireCircle = Instance.new("Frame")
autofireCircle.Size = UDim2.new(0, 80, 0, 80)
autofireCircle.Position = UDim2.new(0.5, -40, 0.8, -40)
autofireCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
autofireCircle.BackgroundTransparency = 0.5
autofireCircle.BorderSizePixel = 0
autofireCircle.AnchorPoint = Vector2.new(0.5, 0.5)
autofireCircle.Visible = false
autofireCircle.Name = "AutoFireZone"
autofireCircle.ClipsDescendants = true
autofireCircle.Parent = screenGui

local uicorner = Instance.new("UICorner", autofireCircle)
uicorner.CornerRadius = UDim.new(1, 0)

-- 🔘 State
local autoFireEnabled = false
local circleDraggable = true
local dragging = false
local dragOffset

-- 🎮 Drag Events
autofireCircle.InputBegan:Connect(function(input)
	if circleDraggable and input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragOffset = input.Position - autofireCircle.AbsolutePosition
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and circleDraggable and input.UserInputType == Enum.UserInputType.MouseMovement then
		local newPos = input.Position - dragOffset
		autofireCircle.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
	end
end)

-- 🔲 Main UI Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 150)
panel.Position = UDim2.new(0, 20, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local function createButton(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 190, 0, 30)
	btn.Position = UDim2.new(0, 15, 0, yPos)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = panel
	return btn
end

-- 🔘 AutoFire Toggle
local autoFireToggleBtn = createButton("AutoFire: OFF 🔘", 10)
autoFireToggleBtn.MouseButton1Click:Connect(function()
	autoFireEnabled = not autoFireEnabled
	autoFireToggleBtn.Text = autoFireEnabled and "AutoFire: ON 🔫" or "AutoFire: OFF 🔘"
	autofireCircle.Visible = autoFireEnabled
end)

-- 🔒 Draggable Toggle
local draggableToggleBtn = createButton("Draggable: ON 🖱️", 50)
draggableToggleBtn.MouseButton1Click:Connect(function()
	circleDraggable = not circleDraggable
	draggableToggleBtn.Text = circleDraggable and "Draggable: ON 🖱️" or "Draggable: OFF 🔒"
end)

-- 🧠 Button Press Simulation
local function simulateClickOnButton(guiObject)
	if guiObject and (guiObject:IsA("TextButton") or guiObject:IsA("ImageButton")) then
		coroutine.wrap(function()
			guiObject:Activate()
		end)()
	end
end

-- 🔁 AutoFire Detection Loop
RunService.RenderStepped:Connect(function()
	if autoFireEnabled then
		local absPos = autofireCircle.AbsolutePosition
		local absSize = autofireCircle.AbsoluteSize
		local center = absPos + (absSize / 2)

		local uiObjects = GuiService:FindGuiObjectsAtPosition(center.X, center.Y)
		for _, obj in ipairs(uiObjects) do
			if obj:IsA("TextButton") or obj:IsA("ImageButton") then
				simulateClickOnButton(obj)
				break
			end
		end
	end
end)