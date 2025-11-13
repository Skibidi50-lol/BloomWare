getgenv().GunMods = {
    InfiniteAmmo = false,
    NoSpread = false,
    NoRecoil = false,-- Camera spin FIXED
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

-- Weapon cache
local weaponCache = {}

local function cacheWeaponValues(weapon)
    if weaponCache[weapon] then return end
    weaponCache[weapon] = {}

    local function cache(name)
        local obj = weapon:FindFirstChild(name)
        if obj then
            weaponCache[weapon][name] = obj:IsA("ValueBase") and obj.Value or obj
        end
    end

    cache("Ammo"); cache("StoredAmmo")
    cache("Spread"); cache("MaxSpread")
    cache("RecoilControl"); cache("Recoil"); cache("RecoilAmount")
    cache("FireRate"); cache("BFireRate")
    cache("Auto")
end

-- Main loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        local weapons = ReplicatedStorage:WaitForChild("Weapons"):GetChildren()
        
        for _, weapon in ipairs(weapons) do
            cacheWeaponValues(weapon)

            -- Infinite Ammo
            if getgenv().GunMods.InfiniteAmmo then
                if weapon:FindFirstChild("Ammo") then
                    weapon.Ammo.Value = 9999999
                end
                if weapon:FindFirstChild("StoredAmmo") then
                    weapon.StoredAmmo.Value = 9999999
                end
            end

            -- No Spread
            if getgenv().GunMods.NoSpread then
                local spread = weapon:FindFirstChild("Spread")
                local maxspread = weapon:FindFirstChild("MaxSpread")
                if spread then spread.Value = 0; spread = 0 end
                if maxspread then maxspread.Value = 0; maxspread = 0 end
            end

            -- No Recoil (Camera Spin FIXED)
            if getgenv().GunMods.NoRecoil then
                local rc = weapon:FindFirstChild("RecoilControl")
                local r = weapon:FindFirstChild("Recoil")
                local ra = weapon:FindFirstChild("RecoilAmount")
                if rc then rc.Value = math.huge; rc = math.huge end
                if r then r.Value = 0; r = 0 end
                if ra then ra.Value = 0; ra = 0 end
            end

            -- Fast Fire Rate
            if getgenv().GunMods.FastFireRate then
                local fr = weapon:FindFirstChild("FireRate")
                local bfr = weapon:FindFirstChild("BFireRate")
                if fr then fr.Value = 0.003; fr = 0.003 end
                if bfr then bfr.Value = 0.003; bfr = 0.003 end
            end

            -- Auto Fire
            if getgenv().GunMods.Auto then
                local auto = weapon:FindFirstChild("Auto")
                if auto then auto.Value = true; auto = true end
            end
        end
    end)
end)
