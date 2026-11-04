
-- TARGETING HUB
-- Aimbot + ESP
-- Select one player or ALL
-- Mobile friendly

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local me = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if type(env.TwoHubTargetStop) == "function" then
    pcall(env.TwoHubTargetStop)
end

local pg = me:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("TwoHubTargetGUI")

if old then
    old:Destroy()
end

local running = true
local aiming = false
local espOn = false
local chosen = nil

local connections = {}
local drawings = {}

local stepName =
    "TwoHubAim_" .. tostring(me.UserId)

local FOV_PIXELS = 260

local function connect(signal, fn)
    local c = signal:Connect(fn)
    connections[#connections+1] = c
    return c
end

-- GUI

local gui = Instance.new("ScreenGui")
gui.Name = "TwoHubTargetGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 1011
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(242, 226)
frame.Position = UDim2.new(0, 12, 0.61, 0)
frame.BackgroundColor3 =
    Color3.fromRGB(27, 20, 37)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 12)

local outline = Instance.new("UIStroke", frame)
outline.Color =
    Color3.fromRGB(214, 98, 255)
outline.Thickness = 2

local function label(content, x, y, w, h, fontSize)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(x, y)
    t.Size = UDim2.fromOffset(w, h)
    t.Text = content
    t.TextColor3 =
        Color3.fromRGB(240, 236, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = fontSize or 13
    t.TextTruncate =
        Enum.TextTruncate.AtEnd
    t.Parent = frame

    return t
end

local function button(content, x, y, w, h)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(x, y)
    b.Size = UDim2.fromOffset(w, h)
    b.BackgroundColor3 =
        Color3.fromRGB(60, 47, 74)
    b.TextColor3 =
        Color3.fromRGB(250, 247, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = content
    b.Parent = frame

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 8)

    return b
end

label(
    "TARGET / ESP HUB",
    0, 6, 242, 25, 16
)

local previous =
    button("<", 9, 37, 43, 37)

local targetText =
    label("ALL PLAYERS", 57, 37, 127, 37, 13)

local nextButton =
    button(">", 190, 37, 43, 37)

local aimButton =
    button("AIMBOT: OFF", 9, 83, 224, 41)

local espButton =
    button("ESP: OFF", 9, 131, 224, 41)

local message = label(
    "ALL = nearest visible player",
    5, 179, 232, 37, 11
)

-- PLAYER SELECTION

local function others()
    local list = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= me then
            list[#list+1] = p
        end
    end

    table.sort(list, function(a,b)
        return a.Name:lower() < b.Name:lower()
    end)

    return list
end

local function updateTargetText()
    if chosen and chosen.Parent ~= Players then
        chosen = nil
    end

    targetText.Text =
        chosen and chosen.DisplayName
        or "ALL PLAYERS"
end

local function cycle(direction)
    local list = others()
    local index = 1

    for i, p in ipairs(list) do
        if p == chosen then
            index = i + 1
            break
        end
    end

    index =
        ((index - 1 + direction) % (#list+1)) + 1

    chosen =
        index == 1 and nil
        or list[index-1]

    updateTargetText()
end

local function setToggle(b, on, title)
    b.Text =
        title .. (on and ": ON" or ": OFF")

    b.BackgroundColor3 = on
        and Color3.fromRGB(110, 42, 160)
        or Color3.fromRGB(60, 47, 74)
end

connect(previous.Activated, function()
    cycle(-1)
end)

connect(nextButton.Activated, function()
    cycle(1)
end)

connect(aimButton.Activated, function()
    aiming = not aiming
    setToggle(aimButton, aiming, "AIMBOT")
end)

connect(espButton.Activated, function()
    espOn = not espOn
    setToggle(espButton, espOn, "ESP")
end)

connect(Players.PlayerRemoving, function(p)
    if chosen == p then
        chosen = nil
        updateTargetText()
    end
end)

-- ESP

local function clearDrawing(p)
    local d = drawings[p]

    if d then
        if d.highlight then
            d.highlight:Destroy()
        end

        if d.billboard then
            d.billboard:Destroy()
        end

        drawings[p] = nil
    end
end

local function addDrawing(p, character)
    clearDrawing(p)

    local head =
        character:FindFirstChild("Head")
        or character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ClientPlayerESP"
    highlight.Adornee = character

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillColor =
        Color3.fromRGB(242, 66, 116)

    highlight.OutlineColor =
        Color3.fromRGB(255, 255, 255)

    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ClientESPName"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(170, 28)
    billboard.StudsOffsetWorldSpace =
        Vector3.new(0, 2.9, 0)

    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local name = Instance.new("TextLabel")
    name.Size = UDim2.fromScale(1, 1)
    name.BackgroundTransparency = 1
    name.TextColor3 =
        Color3.fromRGB(255, 228, 235)
    name.TextStrokeTransparency = 0.25
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14

    name.Text =
        p.DisplayName .. " (@" .. p.Name .. ")"

    name.Parent = billboard

    drawings[p] = {
        highlight = highlight,
        billboard = billboard,
        character = character
    }
end

local function refreshESP()
    for p, _ in pairs(drawings) do
        if p.Parent ~= Players
            or not espOn
            or (chosen and p ~= chosen)
            or not p.Character
            or drawings[p].character ~= p.Character then

            clearDrawing(p)
        end
    end

    if not espOn then return end

    local limit = 0

    for _, p in ipairs(others()) do
        if (not chosen or p == chosen)
            and p.Character then

            local hum =
                p.Character:FindFirstChildOfClass(
                    "Humanoid"
                )

            if hum and hum.Health > 0 then
                limit += 1

                if limit > 60 then break end

                if not drawings[p] then
                    addDrawing(p, p.Character)
                end
            else
                clearDrawing(p)
            end
        end
    end
end

-- AIMBOT

local rayParams = RaycastParams.new()

rayParams.FilterType =
    Enum.RaycastFilterType.Exclude

rayParams.IgnoreWater = true

local function targetPart(p)
    if not p or not p.Character then
        return nil
    end

    local h =
        p.Character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not h or h.Health <= 0 then
        return nil
    end

    return
        p.Character:FindFirstChild("Head")
        or p.Character:FindFirstChild(
            "HumanoidRootPart"
        )
end

local function visible(camera, p, target)
    local projected, onScreen =
        camera:WorldToViewportPoint(
            target.Position
        )

    if not onScreen or projected.Z <= 0 then
        return nil
    end

    rayParams.FilterDescendantsInstances = {
        me.Character
    }

    local delta =
        target.Position - camera.CFrame.Position

    local hit = workspace:Raycast(
        camera.CFrame.Position,
        delta,
        rayParams
    )

    if hit
        and not hit.Instance:IsDescendantOf(
            p.Character
        ) then

        return nil
    end

    return Vector2.new(
        projected.X,
        projected.Y
    )
end

local function findTarget(camera)
    if chosen then
        local part = targetPart(chosen)

        return part
            and visible(
                camera,
                chosen,
                part
            )
            and part
            or nil
    end

    local center = camera.ViewportSize / 2

    local bestPart = nil
    local bestDistance = FOV_PIXELS

    for _, p in ipairs(others()) do
        local part = targetPart(p)

        if part then
            local screen =
                visible(camera, p, part)

            if screen then
                local distance =
                    (screen - center).Magnitude

                if distance < bestDistance then
                    bestPart = part
                    bestDistance = distance
                end
            end
        end
    end

    return bestPart
end

-- CAMERA AIM ASSIST

RunService:BindToRenderStep(
    stepName,
    Enum.RenderPriority.Camera.Value+1,

    function(dt)
        if not running or not aiming then
            return
        end

        local camera = workspace.CurrentCamera

        if not camera then return end

        local part = findTarget(camera)

        if not part then return end

        local desired = CFrame.lookAt(
            camera.CFrame.Position,
            part.Position
        )

        camera.CFrame = camera.CFrame:Lerp(
            desired,
            math.clamp(dt * 13, 0, 1)
        )
    end
)

-- ESP REFRESH

local espClock = 0

connect(RunService.Heartbeat, function(dt)
    espClock += dt

    if espClock >= 0.4 then
        espClock = 0
        refreshESP()
    end
end)

-- CLEANUP

env.TwoHubTargetStop = function()
    if not running then return end

    running = false

    RunService:UnbindFromRenderStep(
        stepName
    )

    for _, c in ipairs(connections) do
        c:Disconnect()
    end

    for p, _ in pairs(drawings) do
        clearDrawing(p)
    end

    gui:Destroy()
    env.TwoHubTargetStop = nil
end

updateTargetText()

print(
    "TARGETING HUB LOADED | AIMBOT + ESP"
)
