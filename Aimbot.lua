-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- STATE
local aimbotEnabled = false
local autoFireEnabled = false
local circleDraggable = true
local guiDraggable = true
local draggingCircle = false
local draggingPanel = false
local dragOffset = nil
local panelDragInput, panelDragStart, panelStartPos
local priorityTarget = nil
local priorityTimeout = 0
local lastHealth = 100

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PvP_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 250)
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

-- GUI Buttons
local toggleAimbotBtn = createButton("Toggle Aimbot 🎯", 10)
local boostFpsBtn = createButton("Boost FPS ⚡️", 50)
local autoFireToggleBtn = createButton("AutoFire: OFF 🔘", 90)
local draggableToggleBtn = createButton("Draggable: ON 🖱️", 130)
local minimizeBtn = createButton("Minimize ⏬", 170)
local restoreBtn = createButton("Restore ⏫", 210)
restoreBtn.Visible = false

-- AUTO FIRE CIRCLE
local autofireCircle = Instance.new("Frame", screenGui)
autofireCircle.Size = UDim2.new(0, 80, 0, 80)
autofireCircle.Position = UDim2.new(0.5, -40, 0.8, -40)
autofireCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
autofireCircle.BackgroundTransparency = 0.5
autofireCircle.BorderSizePixel = 0
autofireCircle.AnchorPoint = Vector2.new(0.5, 0.5)
autofireCircle.ClipsDescendants = true
autofireCircle.Visible = false
autofireCircle.Name = "AutoFireCircle"

local uicorner = Instance.new("UICorner", autofireCircle)
uicorner.CornerRadius = UDim.new(1, 0)

-- DRAGGING: GUI Panel
panel.InputBegan:Connect(function(input)
	if guiDraggable and input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPanel = true
		panelDragStart = input.Position
		panelStartPos = panel.Position
	end
end)

panel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		panelDragInput = input
	end
end)

-- DRAGGING: Autofire Circle
autofireCircle.InputBegan:Connect(function(input)
	if circleDraggable and input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingCircle = true
		dragOffset = input.Position - autofireCircle.AbsolutePosition
	end
end)

-- SHARED DRAG LOGIC
UserInputService.InputChanged:Connect(function(input)
	-- Panel drag
	if input == panelDragInput and draggingPanel and guiDraggable then
		local delta = input.Position - panelDragStart
		panel.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X,
			panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
	end

	-- Circle drag
	if draggingCircle and circleDraggable and input.UserInputType == Enum.UserInputType.MouseMovement then
		local newPos = input.Position - dragOffset
		autofireCircle.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPanel = false
		draggingCircle = false
	end
end)

-- BUTTON LOGIC
toggleAimbotBtn.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	toggleAimbotBtn.Text = aimbotEnabled and "Aimbot: ON 🎯" or "Toggle Aimbot 🎯"
end)

boostFpsBtn.MouseButton1Click:Connect(function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy()
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = false end
	end
end)

autoFireToggleBtn.MouseButton1Click:Connect(function()
	autoFireEnabled = not autoFireEnabled
	autoFireToggleBtn.Text = autoFireEnabled and "AutoFire: ON 🔫" or "AutoFire: OFF 🔘"
	autofireCircle.Visible = autoFireEnabled
end)

draggableToggleBtn.MouseButton1Click:Connect(function()
	circleDraggable = not circleDraggable
	guiDraggable = circleDraggable
	draggableToggleBtn.Text = circleDraggable and "Draggable: ON 🖱️" or "Draggable: OFF 🔒"
end)

minimizeBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
	restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
	panel.Visible = true
	restoreBtn.Visible = false
end)

-- FULL BRIGHT
local function forceLighting()
	Lighting.FogEnd = 1e10
	Lighting.Brightness = 2
	Lighting.GlobalShadows = false
	Lighting.ClockTime = 14
	Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

forceLighting()
Lighting:GetPropertyChangedSignal("FogEnd"):Connect(forceLighting)

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	forceLighting()
	local humanoid = char:WaitForChild("Humanoid", 5)
	if humanoid then
		lastHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(newHealth)
			if newHealth < lastHealth then
				local closest, closestDist = nil, math.huge
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= player and p.Team ~= player.Team then
						local char = p.Character
						local head = char and char:FindFirstChild("Head")
						local hum = char and char:FindFirstChildWhichIsA("Humanoid")
						if head and hum and hum.Health > 0 then
							local dist = (camera.CFrame.Position - head.Position).Magnitude
							local _, onScreen = camera:WorldToViewportPoint(head.Position)
							if onScreen and canSeeTarget(camera.CFrame.Position, head.Position, char) and dist < closestDist then
								closest = p
								closestDist = dist
							end
						end
					end
				end
				if closest then
					priorityTarget = closest
					priorityTimeout = tick() + 3
				end
			end
			lastHealth = newHealth
		end)
	end
end)

-- WALL CHECK
function canSeeTarget(origin, targetPos, char)
	local dir = (targetPos - origin).Unit * 300
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {player.Character}
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, dir, params)
	while result do
		local part = result.Instance
		if not part then break end
		if part:IsDescendantOf(char) then return true end

		local mat = part.Material
		if mat == Enum.Material.Glass or mat == Enum.Material.Neon or mat == Enum.Material.ForceField or mat == Enum.Material.Air or part.Transparency > 0.7 then
			local newOrigin = result.Position + dir.Unit * 0.1
			local newDir = (targetPos - newOrigin).Unit * (300 - (newOrigin - origin).Magnitude)
			result = workspace:Raycast(newOrigin, newDir, params)
		else
			break
		end
	end
	return false
end

-- TARGETING
local function getPredictedHead(head)
	local root = head.Parent:FindFirstChild("HumanoidRootPart")
	if not root then return head.Position end
	local velocity = root.Velocity
	local predictionTime = 0.15
	return head.Position + (velocity * predictionTime)
end

local function getClosestTarget()
	if priorityTarget and tick() < priorityTimeout then
		local char = priorityTarget.Character
		local head = char and char:FindFirstChild("Head")
		local hum = char and char:FindFirstChildWhichIsA("Humanoid")
		if head and hum and hum.Health > 0 and canSeeTarget(camera.CFrame.Position, head.Position, char) then
			return head
		end
	end

	local best, shortest = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Team ~= player.Team then
			local char = p.Character
			local head = char and char:FindFirstChild("Head")
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if head and hum and hum.Health > 0 then
				local dist = (camera.CFrame.Position - head.Position).Magnitude
				local _, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen and dist < shortest and canSeeTarget(camera.CFrame.Position, head.Position, char) then
					best = head
					shortest = dist
				end
			end
		end
	end
	return best
end

-- BUTTON CLICK SIMULATOR
local function simulateClickOnButton(guiObject)
	if guiObject and (guiObject:IsA("TextButton") or guiObject:IsA("ImageButton")) then
		coroutine.wrap(function()
			guiObject:Activate()
		end)()
	end
end

-- RENDER LOOP
RunService.RenderStepped:Connect(function()
	if aimbotEnabled then
		local target = getClosestTarget()
		if target then
			local predicted = getPredictedHead(target)
			camera.CFrame = CFrame.new(camera.CFrame.Position, predicted)
		end
	end

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