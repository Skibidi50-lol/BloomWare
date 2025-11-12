-- Configurable Arsenal Mods Settings (No Rayfield GUI)
getgenv().ArsenalMods = {
    Enabled = true,
    
    InfiniteAmmo = true,
    NoSpread = true,
    NoRecoil = true,
    FastFireRate = true,
    Auto = true
}

-- Remove ban parts
for i,v in ipairs(game:GetDescendants()) do
    if v.Name == "ban" or v.Name == "ban2" then
        v:Destroy()
    end
end

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Weapon cache for original values
local weaponCache = {}

-- Cache original weapon values
local function cacheWeaponValues(weapon)
    if not weaponCache[weapon] then
        weaponCache[weapon] = {}
        if weapon:FindFirstChild("Ammo") then
            weaponCache[weapon].Ammo = weapon.Ammo.Value
        end
        if weapon:FindFirstChild("StoredAmmo") then
            weaponCache[weapon].StoredAmmo = weapon.StoredAmmo.Value
        end
        if weapon:FindFirstChild("Spread") then
            weaponCache[weapon].Spread = weapon.Spread
        end
        if weapon:FindFirstChild("MaxSpread") then
            weaponCache[weapon].MaxSpread = weapon.MaxSpread
        end
        if weapon:FindFirstChild("RecoilControl") then
            weaponCache[weapon].RecoilControl = weapon.RecoilControl
        end
        if weapon:FindFirstChild("FireRate") then
            weaponCache[weapon].FireRate = weapon.FireRate
        end
        if weapon:FindFirstChild("BFireRate") then
            weaponCache[weapon].BFireRate = weapon.BFireRate
        end
        if weapon:FindFirstChild("Auto") then
            weaponCache[weapon].Auto = weapon.Auto
        end
    end
end

-- Main modification loop
RunService.Heartbeat:Connect(function()
    if not getgenv().ArsenalMods.Enabled then return end

    pcall(function()
        local weapons = ReplicatedStorage:WaitForChild("Weapons"):GetChildren()
        
        for _, weapon in ipairs(weapons) do
            cacheWeaponValues(weapon)
            local cached = weaponCache[weapon]
            
            -- Infinite Ammo
            if getgenv().ArsenalMods.InfiniteAmmo then
                if weapon:FindFirstChild("Ammo") then
                    weapon.Ammo.Value = 300
                end
                if weapon:FindFirstChild("StoredAmmo") then
                    weapon.StoredAmmo.Value = 300
                end
            end
            
            -- No Spread
            if getgenv().ArsenalMods.NoSpread then
                if weapon:FindFirstChild("Spread") then
                    weapon.Spread = 0
                end
                if weapon:FindFirstChild("MaxSpread") then
                    weapon.MaxSpread = 0
                end
            end
            
            -- No Recoil
            if getgenv().ArsenalMods.NoRecoil then
                if weapon:FindFirstChild("RecoilControl") then
                    weapon.RecoilControl = 300
                end
            end
            
            -- Fast Fire Rate
            if getgenv().ArsenalMods.FastFireRate then
                if weapon:FindFirstChild("FireRate") then
                    weapon.FireRate = 0.003
                end
                if weapon:FindFirstChild("BFireRate") then
                    weapon.BFireRate = 0.003
                end
            end
            
            -- Auto Fire
            if getgenv().ArsenalMods.Auto then
                if weapon:FindFirstChild("Auto") then
                    weapon.Auto = true
                end
            end
        end
    end)
end)
