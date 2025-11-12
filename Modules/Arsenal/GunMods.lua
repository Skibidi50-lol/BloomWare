getgenv().GunMods = {
    Enabled = false,
    
    InfiniteAmmo = true,
    NoSpread = false,
    NoRecoil = false,
    FastFireRate = false,
    Auto = false
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

local function cacheWeaponValues(weapon)
    if not weaponCache[weapon] then
        weaponCache[weapon] = {}
        
        -- Ammo
        if weapon:FindFirstChild("Ammo") then
            weaponCache[weapon].Ammo = weapon.Ammo.Value
        end
        if weapon:FindFirstChild("StoredAmmo") then
            weaponCache[weapon].StoredAmmo = weapon.StoredAmmo.Value
        end
        
        -- Spread
        if weapon:FindFirstChild("Spread") then
            weaponCache[weapon].Spread = weapon.Spread.Value or weapon.Spread
        end
        if weapon:FindFirstChild("MaxSpread") then
            weaponCache[weapon].MaxSpread = weapon.MaxSpread.Value or weapon.MaxSpread
        end
        
        -- **RECOIL FIX** - Key properties that cause camera spin
        if weapon:FindFirstChild("RecoilControl") then
            weaponCache[weapon].RecoilControl = weapon.RecoilControl.Value or weapon.RecoilControl
        end
        if weapon:FindFirstChild("Recoil") then
            weaponCache[weapon].Recoil = weapon.Recoil.Value or weapon.Recoil
        end
        if weapon:FindFirstChild("RecoilAmount") then
            weaponCache[weapon].RecoilAmount = weapon.RecoilAmount.Value or weapon.RecoilAmount
        end
        
        -- Fire Rate
        if weapon:FindFirstChild("FireRate") then
            weaponCache[weapon].FireRate = weapon.FireRate.Value or weapon.FireRate
        end
        if weapon:FindFirstChild("BFireRate") then
            weaponCache[weapon].BFireRate = weapon.BFireRate.Value or weapon.BFireRate
        end
        
        -- Auto
        if weapon:FindFirstChild("Auto") then
            weaponCache[weapon].Auto = weapon.Auto.Value or weapon.Auto
        end
    end
end

-- Main gun modification loop
RunService.Heartbeat:Connect(function()
    if not getgenv().GunMods.Enabled then return end

    pcall(function()
        local weapons = ReplicatedStorage:WaitForChild("Weapons"):GetChildren()
        
        for _, weapon in ipairs(weapons) do
            cacheWeaponValues(weapon)
            local cached = weaponCache[weapon]
            
            -- 🌟 Infinite Ammo
            if getgenv().GunMods.InfiniteAmmo then
                if weapon:FindFirstChild("Ammo") then
                    weapon.Ammo.Value = 300
                end
                if weapon:FindFirstChild("StoredAmmo") then
                    weapon.StoredAmmo.Value = 300
                end
            end
            
            -- 🎯 No Spread
            if getgenv().GunMods.NoSpread then
                if weapon:FindFirstChild("Spread") then
                    weapon.Spread.Value = 0
                    weapon.Spread = 0
                end
                if weapon:FindFirstChild("MaxSpread") then
                    weapon.MaxSpread.Value = 0
                    weapon.MaxSpread = 0
                end
            end
            
            -- 🔫 **NO CAMERA SPIN/ROTATION FIX**
            if getgenv().GunMods.NoRecoil then
                -- Arsenal/CounterBlox: High RecoilControl = less recoil
                if weapon:FindFirstChild("RecoilControl") then
                    weapon.RecoilControl.Value = math.huge  -- or 999 (was 300 - too low)
                    weapon.RecoilControl = math.huge
                end
                
                -- Other games: Set recoil to 0
                if weapon:FindFirstChild("Recoil") then
                    weapon.Recoil.Value = 0
                    weapon.Recoil = 0
                end
                if weapon:FindFirstChild("RecoilAmount") then
                    weapon.RecoilAmount.Value = 0
                    weapon.RecoilAmount = 0
                end
            end
            
            -- ⚡ Fast Fire Rate
            if getgenv().GunMods.FastFireRate then
                if weapon:FindFirstChild("FireRate") then
                    weapon.FireRate.Value = 0.003
                    weapon.FireRate = 0.003
                end
                if weapon:FindFirstChild("BFireRate") then
                    weapon.BFireRate.Value = 0.003
                    weapon.BFireRate = 0.003
                end
            end
            
            -- 🔄 Auto Fire
            if getgenv().GunMods.Auto then
                if weapon:FindFirstChild("Auto") then
                    weapon.Auto.Value = true
                    weapon.Auto = true
                end
            end
        end
    end)
end)

print("🚀 True Gun Mode LOADED - FIXED: No Camera Spin!")
print("Use getgenv().GunMods.NoRecoil = false to test original recoil")
