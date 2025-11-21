if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId ~= 96151237893653 then
    game:GetService("TeleportService"):Teleport(96151237893653, game.Players.LocalPlayer)
    return
end


local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skibidi50-lol/me-obsidian-theme/refs/heads/main/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library:Notify({
    Title = "BloomWare",
    Description = "OwO Script made by Skibidi50-lol :3",
    Time = 3,
})

local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game.Workspace

-- Remotes
local MaterialCollectEvent = ReplicatedStorage.Remotes.MaterialCollectEvent
local CashMagnetEvent = ReplicatedStorage.Remotes.CashMagnetEvent

-- Variables
local Player = Players.LocalPlayer
local MyBase = nil
local AutoCollectCandyConnection = nil

-- Find player's base
for _, base in pairs(Workspace.Bases:GetChildren()) do
    for _, obj in pairs(base:GetChildren()) do
        if obj:GetAttribute("Owner") == Player.Name then
            MyBase = base
            break
        end
    end
    if MyBase then break end
end

-- Discord Rich Presence (optional, works on Synapse/Fluxus)
local request = syn and syn.request or http and http.request or request
if request then
    pcall(function()
        request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                args = { code = "fF5bHJDcZt" },
                nonce = HttpService:GenerateGUID(false)
            })
        })
    end)
end


local Window = Library:CreateWindow({
	Title = "BloomWare | ".. (identifyexecutor()),
	Footer = "Version 1.0 - All Executor Supported",
	Icon = nil,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
    Farm = Window:AddTab("Auto Farm", "target"),
    Misc = Window:AddTab("Misc", "eclipse"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local farmBox = Tabs.Farm:AddLeftGroupbox("Auto Farm Settings", "target")

farmBox:AddToggle("FarmToggle", {
    Text = "Instant Kill Brainrots",
    Default = false,
    Tooltip = "Poor Brainrot :("
}):OnChanged(function(enabled)
   if enabled and MyBase then
        task.spawn(function()
            while task.wait() and enabled do
                for _, enemy in pairs(MyBase.Enemies:GetChildren()) do
                    local humanoid = enemy:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        humanoid.Health = 0
                    end
                end
            end
        end)
    end
end)

farmBox:AddToggle("AutoCoinToggle", {
    Text = "Auto Collect Coins",
    Default = false,
    Tooltip = "Automatically Collect Coins For You"
}):OnChanged(function(enabled)
   if enabled then
        task.spawn(function()
            while task.wait() and enabled do
                for _, obj in pairs(Workspace:GetChildren()) do
                    local enemyType = obj:GetAttribute("EnemyType")
                    if enemyType then
                        CashMagnetEvent:FireServer(enemyType)
                        obj:Destroy()
                    end
                end
            end
        end)
    end
end)

local miscBox = Tabs.Misc:AddLeftGroupbox("Misc Settings", "dice")

miscBox:AddSlider("SpeedSlider", {
    Text = "Player Speed",
    Default = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed,
    Min = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed,
    Max = 600,
    Rounding = 0,
    Suffix = "WS"
}):OnChanged(function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

miscBox:AddSlider("JumpSlider", {
    Text = "Player JumpPower",
    Default = game.Players.LocalPlayer.Character.Humanoid.JumpPower,
    Min = game.Players.LocalPlayer.Character.Humanoid.JumpPower,
    Max = 600,
    Rounding = 0,
    Suffix = "JP"
}):OnChanged(function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})


MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu


SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place") -- if the game has multiple places inside of it (for example: DOORS)
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
