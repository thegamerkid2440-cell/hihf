
-- MOVEMENT HUB
-- Noclip, Infinite Jump, Speed 16-50
-- Mobile friendly

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local me = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if type(env.TwoHubMovementStop) == "function" then
    pcall(env.TwoHubMovementStop)
end

local playerGui = me:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("TwoHubMovementGUI")
if old then old:Destroy() end

local connections = {}
local running = true
local noclip = false
local infJump = false
local speedOn = false
local targetSpeed = 25
local savedCollisions = {}
local savedSpeeds = {}
local lastJump = 0

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function humanoid()
    local character = me.Character
    return character and
        character:FindFirstChildOfClass("Humanoid")
end

local function restoreCollisions()
    for p, value in pairs(savedCollisions) do
        if p and p.Parent then
            pcall(function()
                p.CanCollide = value
            end)
        end
    end
    table.clear(savedCollisions)
end

local function restoreSpeed()
    for hum, value in pairs(savedSpeeds) do
        if hum and hum.Parent then
            pcall(function()
                hum.WalkSpeed = value
            end)
        end
    end
    table.clear(savedSpeeds)
end

local gui = Instance.new("ScreenGui")
gui.Name = "TwoHubMovementGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 1010
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MovementPanel"
frame.Size = UDim2.fromOffset(223, 239)
frame.Position = UDim2.new(0, 12, 0.32, 0)
frame.BackgroundColor3 =
    Color3.fromRGB(18, 22, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 12)

local outline = Instance.new("UIStroke", frame)
outline.Color = Color3.fromRGB(75, 175, 255)
outline.Thickness = 2

local function textLabel(content, position, size, fontSize)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = position
    l.Size = size
    l.Font = Enum.Font.GothamBold
    l.Text = content
    l.TextColor3 = Color3.fromRGB(235, 241, 255)
    l.TextSize = fontSize or 13
    l.Parent = frame
    return l
end

textLabel(
    "MOVEMENT HUB",
    UDim2.fromOffset(0, 8),
    UDim2.new(1, 0, 0, 24),
    16
)

local function button(content, x, y, w, h)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(w, h)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 =
        Color3.fromRGB(45, 54, 69)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = content
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = frame

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 8)

    return b
end

local ncButton =
    button("NOCLIP: OFF", 10, 39, 203, 38)

local jumpButton =
    button("INFINITE JUMP: OFF", 10, 83, 203, 38)

local speedButton =
    button("SPEED: OFF", 10, 127, 203, 38)

local minus = button("-", 10, 173, 45, 37)
local plus = button("+", 168, 173, 45, 37)

local speedText = textLabel(
    "25 / 50",
    UDim2.fromOffset(59, 174),
    UDim2.fromOffset(105, 35),
    15
)

local status = textLabel(
    "Ready | Tap to toggle",
    UDim2.fromOffset(6, 215),
    UDim2.fromOffset(211, 19),
    10
)

local function style(b, enabled, content)
    b.Text = content
    b.BackgroundColor3 = enabled
        and Color3.fromRGB(21, 126, 85)
        or Color3.fromRGB(45, 54, 69)
end

local function updateUI()
    style(
        ncButton,
        noclip,
        noclip and "NOCLIP: ON" or "NOCLIP: OFF"
    )

    style(
        jumpButton,
        infJump,
        infJump and "INFINITE JUMP: ON"
            or "INFINITE JUMP: OFF"
    )

    style(
        speedButton,
        speedOn,
        speedOn and "SPEED: ON" or "SPEED: OFF"
    )

    speedText.Text =
        tostring(targetSpeed) .. " / 50"
end

connect(ncButton.Activated, function()
    noclip = not noclip

    if not noclip then
        restoreCollisions()
    end

    status.Text = noclip
        and "Noclip ON"
        or "Normal collisions restored"

    updateUI()
end)

connect(jumpButton.Activated, function()
    infJump = not infJump
    status.Text = infJump
        and "Infinite Jump ON"
        or "Normal jumping"

    updateUI()
end)

connect(speedButton.Activated, function()
    speedOn = not speedOn

    if not speedOn then
        restoreSpeed()
    end

    status.Text = speedOn
        and "Speed enabled"
        or "Normal speed restored"

    updateUI()
end)

local function changeSpeed(amount)
    targetSpeed = math.clamp(
        targetSpeed + amount,
        16,
        50
    )
    updateUI()
end

connect(minus.Activated, function()
    changeSpeed(-5)
end)

connect(plus.Activated, function()
    changeSpeed(5)
end)

-- NOCLIP CONTROLLER

connect(RunService.Stepped, function()
    if not running or not noclip then return end

    local character = me.Character
    if not character then return end

    for _, obj in ipairs(
        character:GetDescendants()
    ) do
        if obj:IsA("BasePart") then
            if savedCollisions[obj] == nil then
                savedCollisions[obj] =
                    obj.CanCollide
            end

            obj.CanCollide = false
        end
    end
end)

-- SPEED CONTROLLER

local timer = 0

connect(RunService.Heartbeat, function(dt)
    timer += dt

    if timer < 0.16 then return end
    timer = 0

    if not running or not speedOn then
        return
    end

    local h = humanoid()

    if not h or h.Health <= 0 then
        return
    end

    if savedSpeeds[h] == nil then
        savedSpeeds[h] = h.WalkSpeed
    end

    if h.WalkSpeed ~= targetSpeed then
        h.WalkSpeed = targetSpeed
    end
end)

-- INFINITE JUMP CONTROLLER

connect(UIS.JumpRequest, function()
    if not infJump or not running then
        return
    end

    if os.clock() - lastJump < 0.12 then
        return
    end

    lastJump = os.clock()

    local character = me.Character
    local h = humanoid()
    local root = character and
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if h and root and h.Health > 0 then
        h:ChangeState(
            Enum.HumanoidStateType.Jumping
        )

        local v = root.AssemblyLinearVelocity

        root.AssemblyLinearVelocity =
            Vector3.new(
                v.X,
                math.max(46, v.Y),
                v.Z
            )
    end
end)

connect(me.CharacterRemoving, function()
    restoreCollisions()
    restoreSpeed()
end)

updateUI()

-- CLEANUP

env.TwoHubMovementStop = function()
    if not running then return end

    running = false

    noclip = false
    infJump = false
    speedOn = false

    restoreCollisions()
    restoreSpeed()

    for _, c in ipairs(connections) do
        c:Disconnect()
    end

    gui:Destroy()
    env.TwoHubMovementStop = nil
end

print(
    "MOVEMENT HUB LOADED | NOCLIP + JUMP + SPEED"
)
