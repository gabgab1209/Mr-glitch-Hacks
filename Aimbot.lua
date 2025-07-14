-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- STATE
local aimbotEnabled = false
local autoFireEnabled = false
local predictionEnabled = true
local circleDraggable = true
local guiDraggable = true
local draggingCircle, draggingPanel, draggingRestore = false, false, false
local dragOffset, panelDragInput, panelDragStart, panelStartPos
local recentAttackers = {}
local lastHealth = 100

-- GUI ROOT
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PvP_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- MAIN PANEL
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 310)
panel.Position = UDim2.new(0, 20, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 0
panel.Parent = screenGui

-- CREATE BUTTONS
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

local toggleAimbotBtn = createButton("Toggle Aimbot 🎯", 10)
local boostFpsBtn = createButton("Boost FPS ⚡️", 50)
local autoFireToggleBtn = createButton("AutoFire: OFF 🔘", 90)
local draggableToggleBtn = createButton("Draggable: ON 🖱️", 130)
local predictionToggleBtn = createButton("Prediction: ON 🎯", 170)
local minimizeBtn = createButton("Minimize ⏬", 210)

local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 60, 0, 30)
restoreBtn.Position = UDim2.new(0, 20, 0, 100)
restoreBtn.Text = "Restore ⏫"
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
restoreBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
restoreBtn.Font = Enum.Font.Gotham
restoreBtn.TextSize = 14
restoreBtn.Visible = false
restoreBtn.Parent = screenGui

local autofireCircle = Instance.new("Frame", screenGui)
autofireCircle.Size = UDim2.new(0, 80, 0, 80)
autofireCircle.Position = UDim2.new(0.5, -40, 0.8, -40)
autofireCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
autofireCircle.BackgroundTransparency = 0.5
autofireCircle.BorderSizePixel = 0
autofireCircle.AnchorPoint = Vector2.new(0.5, 0.5)
autofireCircle.ClipsDescendants = true
autofireCircle.Visible = false
Instance.new("UICorner", autofireCircle).CornerRadius = UDim.new(1, 0)

-- BUTTON EVENTS
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

predictionToggleBtn.MouseButton1Click:Connect(function()
    predictionEnabled = not predictionEnabled
    predictionToggleBtn.Text = predictionEnabled and "Prediction: ON 🎯" or "Prediction: OFF 🎯"
end)

minimizeBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
    restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
    panel.Visible = true
    restoreBtn.Visible = false
end)

-- LIGHT FIX
local function forceLighting()
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end
forceLighting()
Lighting:GetPropertyChangedSignal("FogEnd"):Connect(forceLighting)

-- SIMULATE REAL MOUSE CLICK
local function simulateMouseClick()
    VirtualInputManager:SendMouseButtonEvent(
        UserInputService:GetMouseLocation().X,
        UserInputService:GetMouseLocation().Y,
        Enum.UserInputType.MouseButton1,
        true,
        game,
        1
    )
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(
        UserInputService:GetMouseLocation().X,
        UserInputService:GetMouseLocation().Y,
        Enum.UserInputType.MouseButton1,
        false,
        game,
        1
    )
end

-- CAN SEE TARGET (wall-check)
local function canSeeTarget(origin, targetPos, targetCharacter)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = { player.Character }
    rayParams.IgnoreWater = true

    local dir = (targetPos - origin)
    local result = workspace:Raycast(origin, dir, rayParams)

    if result then
        local part = result.Instance
        if part and part:IsDescendantOf(targetCharacter) then
            return true
        end
        return false
    end

    return true -- No hit = visible
end

-- PREDICT HEAD POSITION
local function predictHead(head)
    local root = head.Parent:FindFirstChild("HumanoidRootPart")
    return predictionEnabled and root and head.Position + root.Velocity * 0.15 or head.Position
end

-- ADVANCED PRIORITY
local function findLikelyAttacker()
    local best, bestScore = nil, -math.huge
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Team ~= player.Team then
            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character and p.Character:FindFirstChildWhichIsA("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dir = (myRoot.Position - hrp.Position).Unit
                local score = hrp.CFrame.LookVector:Dot(dir) * 100 - (hrp.Position - myRoot.Position).Magnitude
                if score > bestScore then
                    bestScore = score
                    best = p
                end
            end
        end
    end
    return best
end

local function getTargetHead()
    local now = tick()
    local bestHead, bestTime = nil, 0

    for p, t in pairs(recentAttackers) do
        if now - t <= 5 then
            local head = p.Character and p.Character:FindFirstChild("Head")
            local hum = p.Character and p.Character:FindFirstChildWhichIsA("Humanoid")
            if head and hum and hum.Health > 0 then
                if t > bestTime then
                    bestTime = t
                    bestHead = head
                end
            end
        end
    end

    if not bestHead then
        local nearestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Team ~= player.Team then
                local head = p.Character and p.Character:FindFirstChild("Head")
                local hum = p.Character and p.Character:FindFirstChildWhichIsA("Humanoid")
                if head and hum and hum.Health > 0 then
                    local dist = (camera.CFrame.Position - head.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        bestHead = head
                    end
                end
            end
        end
    end

    return bestHead
end

-- DAMAGE TRACKING
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    forceLighting()
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        lastHealth = hum.Health
        hum.HealthChanged:Connect(function(newHealth)
            if newHealth < lastHealth then
                local attacker = findLikelyAttacker()
                if attacker then
                    recentAttackers[attacker] = tick()
                end
            end
            lastHealth = newHealth
        end)
    end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local head = getTargetHead()
        if head and head.Parent then
            local predicted = predictHead(head)
            if canSeeTarget(camera.CFrame.Position, predicted, head.Parent) then
                camera.CFrame = CFrame.new(camera.CFrame.Position, predicted)
            end
        end
    end

    if autoFireEnabled then
        local head = getTargetHead()
        if head and head.Parent then
            local predicted = predictHead(head)
            if canSeeTarget(camera.CFrame.Position, predicted, head.Parent) then
                local screenPos, onScreen = camera:WorldToViewportPoint(predicted)
                if onScreen then
                    local cursor = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - cursor).Magnitude
                    if dist < 30 then
                        simulateMouseClick()
                    end
                end
            end
        end
    end
end)
