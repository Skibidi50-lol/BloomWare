-- // Rivals Script UI LIBRARY - EXACT IMAGE MATCH (Luau Roblox) \\
-- Usage: local RivalsUI = loadstring(game:HttpGet("YOUR_PASTE_LINK"))()
-- RivalsUI:Toggle("ESP", false) -- Creates toggle
-- RivalsUI:Slider("WalkSpeed", 16, 300, 100)
-- RivalsUI:Textbox("Username", "Player1")
-- RivalsUI:Button("Execute", function() print("Clicked") end)
-- RivalsUI:Dropdown("Hitbox", {"Head", "Torso"}, "Head")
-- Right Shift = Toggle GUI

local RivalsUI = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local pgui = player:WaitForChild("PlayerGui")

-- Library Storage
RivalsUI.Toggles = {}
RivalsUI.Sliders = {}
RivalsUI.Textboxes = {}
RivalsUI.Buttons = {}
RivalsUI.Dropdowns = {}

-- Create ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "RivalsScriptGUI"
screen.ResetOnSpawn = false
screen.Parent = pgui

-- Main Frame (EXACT IMAGE: 420x620, Shooting Range active)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 620)
main.Position = UDim2.new(0.5, -210, 0.5, -310)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
main.BackgroundTransparency = 0.35
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Visible = false
main.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 90)
stroke.Thickness = 1.5
stroke.Parent = main

-- Fake Blur (EXACT glassmorphism)
local fakeBlur = Instance.new("Frame")
fakeBlur.Size = UDim2.new(1, 50, 1, 50)
fakeBlur.Position = UDim2.new(0, -25, 0, -25)
fakeBlur.BackgroundColor3 = Color3.new(0,0,0)
fakeBlur.BackgroundTransparency = 0.6
fakeBlur.ZIndex = -1
fakeBlur.Parent = main
Instance.new("UICorner", fakeBlur).CornerRadius = UDim.new(0, 20)

-- Header (EXACT gradient + title)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 70)
header.BackgroundColor3 = Color3.fromRGB(120, 60, 255)
header.BorderSizePixel = 0
header.Parent = main

local headerGrad = Instance.new("UIGradient")
headerGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 60, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 140, 255))
}
headerGrad.Rotation = 90
headerGrad.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Rivals Script"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Parent = header

-- Draggable
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ScrollingFrame (EXACT layout)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -40, 1, -170)
scroll.Position = UDim2.new(0, 20, 0, 90)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 15)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

-- Auto Canvas Size
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 40)
end)

-- EXACT Active Shooting Range (top left)
local activeTask = Instance.new("Frame")
activeTask.Size = UDim2.new(0, 120, 0, 35)
activeTask.Position = UDim2.new(0, 25, 0, 15)
activeTask.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
activeTask.BackgroundTransparency = 0.2
activeTask.ZIndex = 10
activeTask.Parent = main

local activeCorner = Instance.new("UICorner", activeTask)
activeCorner.CornerRadius = UDim.new(0, 8)

local activeLabel = Instance.new("TextLabel")
activeLabel.Size = UDim2.new(1, 0, 1, 0)
activeLabel.BackgroundTransparency = 1
activeLabel.Text = "Shooting Range"
activeLabel.TextColor3 = Color3.new(1,1,1)
activeLabel.Font = Enum.Font.GothamBold
activeLabel.TextSize = 14
activeLabel.TextXAlignment = Enum.TextXAlignment.Left
activeLabel.Parent = activeTask

-- RBLXSCRIPTS Logo (bottom right - EXACT)
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 200, 0, 40)
logo.Position = UDim2.new(1, -220, 1, -50)
logo.BackgroundTransparency = 1
logo.Text = "15m RBLXSCRIPTS"
logo.TextColor3 = Color3.fromRGB(0, 255, 255)
logo.Font = Enum.Font.GothamBold
logo.TextSize = 22
logo.TextXAlignment = Enum.TextXAlignment.Right
logo.Parent = main

-- Right Shift Toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = main.Visible and UDim2.new(0,420,0,620) or UDim2.new(0,0,0,0)}):Play()
    end
end)

-- === LIBRARY FUNCTIONS ===

-- Toggle (EXACT orange for Aimbot)
function RivalsUI:Toggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 65, 0, 34)
    toggle.Position = UDim2.new(1, -75, 0.5, -17)
    toggle.BackgroundColor3 = default and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(60, 60, 80)
    toggle.Parent = frame

    local tCorner = Instance.new("UICorner", toggle)
    tCorner.CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 28, 0, 28)
    circle.Position = default and UDim2.new(0, 33, 0.5, -14) or UDim2.new(0, 3, 0.5, -14)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    circle.Parent = toggle

    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local enabled = default
    RivalsUI.Toggles[name] = function() return enabled end
    
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            local color = name:lower():find("aim") and Color3.fromRGB(255,140,0) or Color3.fromRGB(60,140,255)
            TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = enabled and color or Color3.fromRGB(60,60,80)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.3), {Position = enabled and UDim2.new(0,33,0.5,-14) or UDim2.new(0,3,0.5,-14)}):Play()
            if callback then callback(enabled) end
        end
    end)
end

-- Slider (EXACT style)
function RivalsUI:Slider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 40)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
    fill.Parent = bar

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = UDim2.new((default - min)/(max - min), -12, 0.5, -12)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = bar

    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    knob.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end 
    end)
    knob.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + rel * (max - min))
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -12, 0.5, -12)
            label.Text = name .. ": " .. value
            RivalsUI.Sliders[name] = value
            if callback then callback(value) end
        end
    end)
end

-- TextBox
function RivalsUI:Textbox(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, 0, 0, 35)
    textbox.Position = UDim2.new(0, 0, 0, 22)
    textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.PlaceholderText = "Enter " .. name:lower() .. "..."
    textbox.Text = default or ""
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 16
    textbox.Parent = frame

    Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 10)

    textbox.FocusLost:Connect(function()
        RivalsUI.Textboxes[name] = textbox.Text
        if callback then callback(textbox.Text) end
    end)
end

-- Button
function RivalsUI:Button(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.AutoButtonColor = false
    btn.Parent = scroll

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 80))
    }
    grad.Parent = btn

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 48)}):Play()
        wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 50)}):Play()
        if callback then callback() end
    end)
end

-- Dropdown
function RivalsUI:Dropdown(name, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(1, 0, 0, 35)
    dropBtn.Position = UDim2.new(0, 0, 0, 22)
    dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    dropBtn.Text = "  " .. (default or options[1])
    dropBtn.TextColor3 = Color3.new(1,1,1)
    dropBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.TextSize = 16
    dropBtn.Parent = frame

    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 10)

    local dropList = Instance.new("Frame")
    dropList.Size = UDim2.new(1, 0, 0, #options * 35)
    dropList.Position = UDim2.new(0, 0, 0, 60)
    dropList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropList.Visible = false
    dropList.Parent = frame

    Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 10)
    Instance.new("UIListLayout", dropList)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 1, 0)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = "  " .. opt
        optBtn.TextColor3 = Color3.new(1,1,1)
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 16
        optBtn.Parent = dropList

        optBtn.MouseButton1Click:Connect(function()
            dropBtn.Text = "  " .. opt
            dropList.Visible = false
            RivalsUI.Dropdowns[name] = opt
            if callback then callback(opt) end
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        dropList.Visible = not dropList.Visible
    end)
end

-- Show GUI
function RivalsUI:Show()
    main.Visible = true
    TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0,420,0,620)}):Play()
end

-- Hide GUI  
function RivalsUI:Hide()
    TweenService:Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0)}):Play()
    wait(0.3)
    main.Visible = false
end

print("🟢 RivalsUI Library Loaded! | Right Shift to Toggle")
return RivalsUI
