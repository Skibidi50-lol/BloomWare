-- Configurable Hitbox Settings
getgenv().Hitbox = {
    Enabled = false,
    HitboxVisual = false,
    HitboxColor = Color3.fromRGB(255, 0, 0),
    HitboxSize = Vector3.new(5, 5, 5)
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Main hitbox expansion loop
RunService.Stepped:Connect(function()
    if not getgenv().Hitbox.Enabled then return end

    for _, player in Players:GetPlayers() do
        if player == LocalPlayer or not player.Character then continue end

        local char = player.Character
        local size = getgenv().Hitbox.HitboxSize
        local transparency = getgenv().Hitbox.HitboxVisual and 0.5 or 1
        local color = getgenv().Hitbox.HitboxColor

        local parts = {
            "RightUpperLeg",
            "LeftUpperLeg",
            "HeadHB",
            "HumanoidRootPart"
        }

        for _, partName in parts do
            local part = char:FindFirstChild(partName)
            if part then
                part.CanCollide = false
                part.Transparency = transparency
                part.Size = size
                part.Color = color
                part.Material = Enum.Material.ForceField
            end
        end
    end
end)

-- Auto-create HeadHB if it doesn't exist
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if char:FindFirstChild("Head") and not char:FindFirstChild("HeadHB") then
            local headHB = Instance.new("Part")
            headHB.Name = "HeadHB"
            headHB.Size = Vector3.new(2, 1, 1)
            headHB.Transparency = 1
            headHB.CanCollide = false
            headHB.Parent = char

            -- Keep HeadHB aligned with Head
            char.Head.AncestryChanged:Connect(function()
                if char.Head and char.HeadHB then
                    char.HeadHB.CFrame = char.Head.CFrame
                end
            end)
        end
    end)
end)
