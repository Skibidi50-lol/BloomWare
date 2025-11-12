
getgenv().speed = {
    enabled = false,     
    speed = 16,        
    control = false,
    friction = 2.0,    
    keybind = Enum.KeyCode.KeypadDivide 
}


local function setSpeed(player, speed)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

local function enhanceControl(player, reset)
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        if reset then
    
            rootPart.CustomPhysicalProperties = PhysicalProperties.new()
        else
      
            rootPart.CustomPhysicalProperties = PhysicalProperties.new(
                0.7, 
                speed.friction,
                0.5,
                1.0, 
                0.5  
            )
        end
    end
end

local function applySpeedBoost(player)
    local character = player.Character or player.CharacterAdded:Wait()

    if speed.enabled then
        setSpeed(player, speed.speed)
        if speed.control then
            enhanceControl(player, false) 
        end
    else
        setSpeed(player, 16)
        if speed.control then
            enhanceControl(player, true) 
        end
    end
end


local function toggleSpeedBoost()
    speed.enabled = not speed.enabled
    print("Speed boost enabled:", speed.enabled)
    applySpeedBoost(game.Players.LocalPlayer)
end

local player = game.Players.LocalPlayer


if player.Character then
    applySpeedBoost(player)
end


player.CharacterAdded:Connect(function()
    applySpeedBoost(player)
end)


game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == speed.keybind then
        toggleSpeedBoost()
    end
end)


game:GetService("RunService").RenderStepped:Connect(function()
    if speed.enabled then
        setSpeed(player, speed.speed)
    end
end)
