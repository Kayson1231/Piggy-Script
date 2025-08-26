-- Ultimate OP GUI v5 - All Features Integrated
-- Client-side only, persistent, modern style

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- ===== Character Setup =====
local character, humanoid, hrp
local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end
setupCharacter()
player.CharacterAdded:Connect(setupCharacter)

-- ===== Toggles / Settings =====
local flyEnabled, noclipEnabled, godModeEnabled, invisibleEnabled, infiniteJumpEnabled, espEnabled = false,false,false,false,true,false
local flySpeed = 50
local guiOpen = false
local selectedPlayer = nil

-- ===== GUI Setup =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateOPGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Toggle Circle
local toggleCircle = Instance.new("TextButton")
toggleCircle.Size = UDim2.new(0,50,0,50)
toggleCircle.Position = UDim2.new(0,10,0,10)
toggleCircle.BackgroundColor3 = Color3.fromRGB(0,255,0)
toggleCircle.BorderSizePixel = 0
toggleCircle.Text = ""
toggleCircle.Parent = screenGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,400,0,700)
frame.Position = UDim2.new(-1,0,0.1,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.ClipsDescendants = true

-- Scrollable Frame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1,0,1,0)
scrollingFrame.CanvasSize = UDim2.new(0,0,3,0)
scrollingFrame.ScrollBarThickness = 12
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollingFrame

-- ===== Drag Function =====
local function makeDraggable(f)
    local dragging, dragInput, mousePos, framePos
    f.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = UserInputService:GetMouseLocation()
            framePos = f.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    f.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = UserInputService:GetMouseLocation() - mousePos
            f.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame)
makeDraggable(toggleCircle)

-- ===== Slide Animation =====
local function toggleGUI()
    guiOpen = not guiOpen
    if guiOpen then
        TweenService:Create(frame,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {Position = UDim2.new(0,70,0,50)}):Play()
    else
        TweenService:Create(frame,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {Position = UDim2.new(-1,0,0.1,0)}):Play()
    end
end
toggleCircle.MouseButton1Click:Connect(toggleGUI)

-- ===== Helper Functions =====
local function createButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Text = name
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.Parent = scrollingFrame
    return btn
end

local function createSlider(name,min,max,default,callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-20,0,20)
    label.Text = name..": "..default
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Parent = scrollingFrame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-20,0,30)
    box.Text = tostring(default)
    box.PlaceholderText = tostring(default)
    box.TextScaled = true
    box.ClearTextOnFocus = false
    box.BackgroundColor3 = Color3.fromRGB(60,60,60)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Parent = scrollingFrame

    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            val = math.clamp(val,min,max)
            box.Text = tostring(val)
            label.Text = name..": "..val
            callback(val)
        else
            box.Text = tostring(default)
        end
    end)
end

local function createPlayerDropdown(name,callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-20,0,20)
    label.Text = name..": None"
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Parent = scrollingFrame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-20,0,30)
    box.PlaceholderText = "Type exact player name"
    box.Text = ""
    box.TextScaled = true
    box.ClearTextOnFocus = false
    box.BackgroundColor3 = Color3.fromRGB(60,60,60)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Parent = scrollingFrame

    box.FocusLost:Connect(function()
        local p = Players:FindFirstChild(box.Text)
        if p then
            label.Text = name..": "..p.Name
            callback(p)
        else
            label.Text = name..": None"
            callback(nil)
        end
    end)
end

-- ===== Buttons / Sliders / Features =====
-- Fly / Noclip / God / Invisible / Infinite Jump / ESP
local flyBtn = createButton("Fly: OFF")
flyBtn.MouseButton1Click:Connect(function() flyEnabled = not flyEnabled; humanoid.PlatformStand = flyEnabled; flyBtn.Text = "Fly: "..(flyEnabled and "ON" or "OFF") end)

local noclipBtn = createButton("Noclip: OFF")
noclipBtn.MouseButton1Click:Connect(function() noclipEnabled = not noclipEnabled; noclipBtn.Text = "Noclip: "..(noclipEnabled and "ON" or "OFF") end)

local godBtn = createButton("God Mode: OFF")
godBtn.MouseButton1Click:Connect(function() godModeEnabled = not godModeEnabled; godBtn.Text = "God Mode: "..(godModeEnabled and "ON" or "OFF") end)

local invisibleBtn = createButton("Invisible: OFF")
invisibleBtn.MouseButton1Click:Connect(function() invisibleEnabled = not invisibleEnabled; invisibleBtn.Text = "Invisible: "..(invisibleEnabled and "ON" or "OFF") end)

local infiniteJumpBtn = createButton("Infinite Jump: ON")
infiniteJumpBtn.MouseButton1Click:Connect(function() infiniteJumpEnabled = not infiniteJumpEnabled; infiniteJumpBtn.Text = "Infinite Jump: "..(infiniteJumpEnabled and "ON" or "OFF") end)

local espBtn = createButton("ESP: OFF")
espBtn.MouseButton1Click:Connect(function() espEnabled = not espEnabled; espBtn.Text = "ESP: "..(espEnabled and "ON" or "OFF") end)

createSlider("Fly Speed",10,500,50,function(v) flySpeed=v end)
createSlider("Walk Speed",8,500,16,function(v) humanoid.WalkSpeed=v end)
createSlider("Jump Power",10,500,50,function(v) humanoid.JumpPower=v end)

-- Player Actions
createPlayerDropdown("Control Player",function(p) selectedPlayer=p end)
createPlayerDropdown("Yeet Player",function(p) selectedPlayer=p end)
createPlayerDropdown("Say Player",function(p) selectedPlayer=p end)

local killBtn = createButton("Fake Kill All")
killBtn.MouseButton1Click:Connect(function() print("Fake Kill Triggered") end)

local banBtn = createButton("Fake Ban All")
banBtn.MouseButton1Click:Connect(function() print("Fake Ban Triggered") end)

local yeetBtn = createButton("Yeet Player")
yeetBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        selectedPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0,50,0)
    end
end)

local sayBtn = createButton("Make Player Say")
sayBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        print(selectedPlayer.Name.." would say your text (Fake)")
    end
end)

-- Piggy / External Scripts
local xhubBtn = createButton("Load Xhub Protected")
xhubBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kittenpalms/Xhub/refs/heads/main/Protected_8698970680050095.lua"))()
    end)
end)

local mm2Btn = createButton("Load MM2 Unboxer")
mm2Btn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/RobloxScripts91/MM2Scripts/refs/heads/main/MM2Unboxer'))()
    end)
end)

-- ===== Item Spawner =====
local itemBoxLabel = Instance.new("TextLabel")
itemBoxLabel.Size = UDim2.new(1,-20,0,20)
itemBoxLabel.Text = "Item ID:"
itemBoxLabel.TextScaled = true
itemBoxLabel.BackgroundTransparency = 1
itemBoxLabel.TextColor3 = Color3.fromRGB(255,255,255)
itemBoxLabel.Parent = scrollingFrame

local itemBox = Instance.new("TextBox")
itemBox.Size = UDim2.new(1,-20,0,30)
itemBox.PlaceholderText = "Type Asset ID (e.g., 225921000)"
itemBox.Text = ""
itemBox.TextScaled = true
itemBox.ClearTextOnFocus = false
itemBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
itemBox.TextColor3 = Color3.fromRGB(255,255,255)
itemBox.Parent = scrollingFrame

local spawnItemBtn = createButton("Spawn Item")
spawnItemBtn.MouseButton1Click:Connect(function()
    local assetId = tonumber(itemBox.Text)
    if assetId then
        local success, model = pcall(function()
            return InsertService:LoadAsset(assetId)
        end)
        if success and model then
            local primary = model:GetChildren()[1]
            primary.Parent = workspace
            if primary.PrimaryPart then
                primary:SetPrimaryPartCFrame(hrp.CFrame + hrp.CFrame.LookVector*5 + Vector3.new(0,5,0))
            else
                primary:MoveTo(hrp.Position + hrp.CFrame.LookVector*5 + Vector3.new(0,5,0))
            end
        else
            warn("Failed to load asset: "..tostring(assetId))
        end
    else
        warn("Invalid Asset ID")
    end
end)

-- ===== Magic Carpet Spawner =====
local carpetBtn = createButton("Spawn Magic Carpet")
carpetBtn.MouseButton1Click:Connect(function()
    local mouse = player:GetMouse()
    local position = mouse.Hit.Position + Vector3.new(0,5,0)

    local carpet = Instance.new("Part")
    carpet.Name = "MagicCarpet"
    carpet.Size = Vector3.new(10,1,5)
    carpet.Anchored = true
    carpet.Position = position
    carpet.BrickColor = BrickColor.new("Bright red")
    carpet.Material = Enum.Material.Neon
    carpet.Parent = workspace

    local seat = Instance.new("VehicleSeat")
    seat.Size = Vector3.new(2,0.5,2)
    seat.Position = position + Vector3.new(0,1,0)
    seat.Anchored = false
    seat.Parent = workspace
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = carpet
    weld.Part1 = seat
    weld.Parent = carpet
end)

-- ===== Fly / Noclip / Invisible / Infinite Jump / ESP =====
RunService.RenderStepped:Connect(function(delta)
    -- Fly
    if flyEnabled and hrp then
        hrp.Velocity = Vector3.new(0,0,0)
        local cam = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + moveDir.Unit*flySpeed*delta
        end
    end

    -- Noclip
    if noclipEnabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Invisible
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Transparency = invisibleEnabled and 1 or 0
        end
    end

    -- ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrpTarget = p.Character.HumanoidRootPart
            local existing = hrpTarget:FindFirstChild("ESP_Box")
            if espEnabled then
                if not existing then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "ESP_Box"
                    box.Adornee = hrpTarget
                    box.Size = Vector3.new(4,6,2)
                    box.Color3 = Color3.fromRGB(0,255,0)
                    box.AlwaysOnTop = true
                    box.Parent = hrpTarget
                end
            else
                if existing then existing:Destroy() end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
