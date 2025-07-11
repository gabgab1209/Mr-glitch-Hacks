-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- State
local aimbotEnabled = false
local dragging = false
local dragInput, dragStart, startPos

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotControlUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 130)
panel.Position = UDim2.new(0, 20, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = false
panel.Parent = screenGui

-- Drag Handler
panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

panel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Toggle Aimbot Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Toggle Aimbot"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleButton.Parent = panel

-- FPS Boost Button
local fpsButton = Instance.new("TextButton")
fpsButton.Size = UDim2.new(0, 180, 0, 30)
fpsButton.Position = UDim2.new(0, 10, 0, 45)
fpsButton.Text = "Boost FPS"
fpsButton.TextColor3 = Color3.new(1, 1, 1)
fpsButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
fpsButton.Parent = panel

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 90)
minimizeButton.Text = "🔽"
minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Parent = panel

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.Text = "❌"
closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Parent = panel

-- Restore Button (Hidden initially)
local restoreButton = Instance.new("TextButton")
restoreButton.Size = UDim2.new(0, 60, 0, 30)
restoreButton.Position = UDim2.new(0, 20, 0, 100)
restoreButton.Text = "📂"
restoreButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
restoreButton.TextColor3 = Color3.new(1, 1, 1)
restoreButton.Visible = false
restoreButton.Parent = screenGui

-- 🎯 Aimbot Logic
toggleButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	toggleButton.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

local function getClosestTarget()
	local closestTarget = nil
	local shortestDistance = 300 -- Max range

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Team ~= player.Team then
			local char = otherPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local head = char and char:FindFirstChild("Head")
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")

			if hrp and head and humanoid and humanoid.Health > 0 then
				local dist = (Camera.CFrame.Position - head.Position).Magnitude
				if dist < shortestDistance then
					local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 300)
					local hit = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
					if hit and hit:IsDescendantOf(char) then
						closestTarget = head
						shortestDistance = dist
					end
				end
			end
		end
	end

	return closestTarget
end

RunService.RenderStepped:Connect(function()
	if aimbotEnabled then
		local target = getClosestTarget()
		if target then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
		end
	end
end)

-- ⚡ FPS Boost Logic (One-Time)
fpsButton.MouseButton1Click:Connect(function()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") then
			obj:Destroy()
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
		end
	end

	local lighting = game:GetService("Lighting")
	lighting.GlobalShadows = false
	lighting.FogEnd = 1e10
	lighting.Brightness = 1
end)

-- ❌ Close GUI
closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- 🔽 Minimize GUI
minimizeButton.MouseButton1Click:Connect(function()
	panel.Visible = false
	restoreButton.Visible = true
end)

-- 📂 Restore GUI
restoreButton.MouseButton1Click:Connect(function()
	panel.Visible = true
	restoreButton.Visible = false
end)