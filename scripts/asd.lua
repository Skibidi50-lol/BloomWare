getgenv().Players = game:GetService("Players")
getgenv().playerData = game:GetService("Players").LocalPlayer:WaitForChild("PlayerData")
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().RunService = game:GetService("RunService")
getgenv().MarketplaceService = game:GetService("MarketplaceService")
getgenv().RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
getgenv().TweenService = game:GetService("TweenService")
getgenv().PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Humanoid, Animator
getgenv().player = Players.LocalPlayer
getgenv().purchasedEmotesFolder = playerData:WaitForChild("Purchased"):WaitForChild("Emotes")
getgenv().Remote = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")

--=Hub=

--[[
WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- You can suggest changes with a pull request or something
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false -- Forces AddToggle to AddCheckbox
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)
local Window = Library:CreateWindow({
-- Set Center to true if you want the menu to appear in the center
-- Set AutoShow to true if you want the menu to appear when it is created
-- Set Resizable to true if you want to have in-game resizable Window
-- Set MobileButtonsSide to "Left" or "Right" if you want the ui toggle & lock buttons to be on the left or right side of the window
-- Set ShowCustomCursor to false if you don't want to use the Linoria cursor
-- NotifySide = Changes the side of the notifications (Left, Right) (Default value = Left)
-- Position and Size are also valid options here
-- but you do not need to define them unless you are changing them :)
Title = "Nyansaken Hub",
Footer = "by LQK",
Icon = 119855670079790,
NotifySide = "Right",
ShowCustomCursor = true,
})
-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.
-- You do not have to set your tabs & groups up this way, just a prefrence.
-- You can find more icons in https://lucide.dev/
local Tabs = {
-- Creates a new tab titled Main
Combat = Window:AddTab("Combat", "swords"),
Generators = Window:AddTab("Generators", "package"),
ESP = Window:AddTab("ESP", "scan-eye"),
StaminaSet = Window:AddTab("Stamina Settings", "footprints"),
Aimbot = Window:AddTab("Aimbot", "crosshair"),
Miscs = Window:AddTab("Misc", "circle-ellipsis"),
AntiSlows = Window:AddTab("Anti Slow", "accessibility"),
AchieveTab = Window:AddTab("Achievements", "medal"),
["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- == Variables ==
local genEnabled = false
local genInterval = 1.25
local re = true
local Check = false
local lt = 0

-- Generators Group
local GeneratorsGroup = Tabs.Generators:AddLeftGroupbox("Generators")

GeneratorsGroup:AddToggle("AutoGenToggle", {
    Text = "Auto Do Generator",
    Default = genEnabled,
    Callback = function(Value)
        genEnabled = Value
    end,
})

GeneratorsGroup:AddSlider("GenIntervalSlider", {
    Text = "Do Generator Interval (Seconds)",
    Default = genInterval,
    Min = 1,
    Max = 15,
    Rounding = 2,
    Suffix = "s",
    Callback = function(Value)
        genInterval = Value
    end,
})

-- == Hook RF/RE để detect vào/ra gen + cooldown ==
local Old
Old = hookmetamethod(game, "__namecall", function(Self, ...)
	local Args = { ... }
	local Method = getnamecallmethod()
	if not checkcaller() and typeof(Self) == "Instance" then
		if Method == "InvokeServer" or Method == "FireServer" then
			if tostring(Self) == "RF" then
				if Args[1] == "enter" then
					Check = true
				elseif Args[1] == "leave" then
					Check = false
				end
			elseif tostring(Self) == "RE" then
				lt = os.clock()
			end
		end
	end
	return Old(Self, unpack(Args))
end)

-- == Auto Generator Loop ==
game:GetService("RunService").Stepped:Connect(function()
	if genEnabled and Check and re and os.clock() - lt >= genInterval then
		re = false
		task.spawn(function()
			for _, gen in ipairs(workspace.Map.Ingame:WaitForChild("Map"):GetChildren()) do
				if gen.Name == "Generator" and gen:FindFirstChild("Remotes") then
					gen.Remotes.RE:FireServer()
				end
			end
			task.wait(genInterval)
			re = true
		end)
	end
end)

-- === ESP Toggles ===
local killersESPToggle = false
local survivorsESPToggle = false
local itemESPEnabled = false

-- ESP Group
local MainESPGroup = Tabs.ESP:AddLeftGroupbox("Main ESP")

MainESPGroup:AddToggle("KillersESP", {
    Text = "Killers ESP",
    Default = false,
    Callback = function(Value)
        killersESPToggle = Value
    end,
})

MainESPGroup:AddToggle("SurvivorsESP", {
    Text = "Survivors ESP",
    Default = false,
    Callback = function(Value)
        survivorsESPToggle = Value
    end,
})

-- === ESP Logic ===
local camera = workspace.CurrentCamera

local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")

local function attachBillboard(model, color)
	if model:FindFirstChild("ESP_NameBillboard") then return end
	local head = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_NameBillboard"
	billboard.Adornee = head
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.Parent = model

	local label = Instance.new("TextLabel")
	label.Name = "NameLabel"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextScaled = false
	label.TextWrapped = false
	label.ClipsDescendants = true
	label.TextTruncate = Enum.TextTruncate.None
	label.AutomaticSize = Enum.AutomaticSize.X
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextSize = 10
	label.Font = Enum.Font.GothamBold
	label.Text = "Loading..."
	label.Parent = billboard
end

local function updateBillboardText(model)
	local billboard = model:FindFirstChild("ESP_NameBillboard")
	if not billboard then return end

	local label = billboard:FindFirstChild("NameLabel")
	if not label then return end

	local actorText = model:GetAttribute("ActorDisplayName") or "???"
	local skinText = model:GetAttribute("SkinNameDisplay")
	local username = model:GetAttribute("Username") or "Unknown"

	-- Use pre-tagged attribute
	if actorText == "Noli" and model:GetAttribute("IsFakeNoli") == true then
		actorText = actorText .. " (FAKE)"
	end

	local displayText = actorText
	if skinText and tostring(skinText) ~= "" then
		displayText = displayText .. " | " .. skinText
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local hp = math.floor(humanoid.Health)
		local maxhp = math.floor(humanoid.MaxHealth)
		displayText = string.format("%s (HP: %d/%d)", displayText, hp, maxhp)
	end

	label.Text = displayText
end

-- Bảng lưu Noli theo username
local noliByUsername = {}

local function clearFakeTags()
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            killer:SetAttribute("IsFakeNoli", false)
        end
    end
end

local function scanNolis()
    noliByUsername = {}

    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            local username = killer:GetAttribute("Username")
            if username then
                if not noliByUsername[username] then
                    noliByUsername[username] = {}
                end
                table.insert(noliByUsername[username], killer)
            end
        end
    end

    for username, models in pairs(noliByUsername) do
        if #models > 1 then
            -- Noli đầu tiên là thật, những cái sau fake
            for i = 2, #models do
                models[i]:SetAttribute("IsFakeNoli", true)
            end
            models[1]:SetAttribute("IsFakeNoli", false)
        else
            -- Chỉ có 1 Noli thì không fake
            models[1]:SetAttribute("IsFakeNoli", false)
        end
    end
end

local function updateFakeNolis()
    clearFakeTags()
    scanNolis()
end

local function setupModel(model, isKiller)
	if not model:IsA("Model") or not model:FindFirstChildOfClass("Humanoid") then return end
	local color = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 0)

	attachBillboard(model, color)
	updateBillboardText(model)

	if not model:FindFirstChild("ESP_Highlight") then
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESP_Highlight"
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
		highlight.OutlineColor = color
		highlight.Adornee = model
		highlight.Parent = model
	end

	model:GetAttributeChangedSignal("ActorDisplayName"):Connect(function()
		updateBillboardText(model)
	end)
	model:GetAttributeChangedSignal("SkinNameDisplay"):Connect(function()
		updateBillboardText(model)
	end)

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			updateBillboardText(model)
		end)
		humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			updateBillboardText(model)
		end)
	end

	model.AncestryChanged:Connect(function(_, parent)
		if not parent then
			local bb = model:FindFirstChild("ESP_NameBillboard")
			if bb then bb:Destroy() end

			local hl = model:FindFirstChild("ESP_Highlight")
			if hl then hl:Destroy() end
		end
	end)
end

local function scanFolder(folder, isKiller)
	for _, model in ipairs(folder:GetChildren()) do
		setupModel(model, isKiller)
	end
end

task.spawn(function()
	while true do
		scanFolder(killersFolder, true)
		scanFolder(survivorsFolder, false)
		task.wait(5)
	end
end)

local function handleChildAdded(folder, isKiller)
	folder.ChildAdded:Connect(function(child)
		task.spawn(function()
			repeat task.wait() until child:IsDescendantOf(folder)
			local timeout = 3
			local timer = 0
			while (not child:FindFirstChild("Head") and not child:FindFirstChildWhichIsA("BasePart")) or not child:FindFirstChildOfClass("Humanoid") do
				task.wait(0.1)
				timer += 0.1
				if timer > timeout then return end
			end
			task.wait(0.2) -- để đảm bảo Attribute đã gán xong
			setupModel(child, isKiller)
		end)
	end)
end

handleChildAdded(killersFolder, true)
handleChildAdded(survivorsFolder, false)
updateFakeNolis()

-- Khi có Noli biến mất, quét lại
killersFolder.ChildRemoved:Connect(function(removed)
    if removed:GetAttribute("ActorDisplayName") == "Noli" then
        updateFakeNolis()
    end
end)

-- Khi có Noli mới thêm vào, quét lại sau 0.2s để attribute được cập nhật
killersFolder.ChildAdded:Connect(function(added)
    if added:GetAttribute("ActorDisplayName") == "Noli" then
        task.defer(function()
            task.wait(0.2)
            updateFakeNolis()
        end)
    end
end)

-- Rescan định kỳ tránh lỗi sai sót
task.spawn(function()
    while true do
        task.wait(10)
        updateFakeNolis()
    end
end)

RunService.RenderStepped:Connect(function()
	for _, folderData in pairs({
		{folder = killersFolder, toggle = killersESPToggle},
		{folder = survivorsFolder, toggle = survivorsESPToggle},
	}) do
		for _, model in ipairs(folderData.folder:GetChildren()) do
			local bb = model:FindFirstChild("ESP_NameBillboard")
			local hl = model:FindFirstChild("ESP_Highlight")

			if bb then bb.Enabled = folderData.toggle end
			if hl then hl.Enabled = folderData.toggle end

			if folderData.toggle and bb and bb.Adornee then
				local dist = (camera.CFrame.Position - bb.Adornee.Position).Magnitude
				local scale = math.clamp(1 / (dist / 20), 0.5, 2)

				local label = bb:FindFirstChild("NameLabel")
				if label then
					label.TextSize = math.clamp(10 * scale, 12, 20)
					bb.Size = UDim2.new(0, label.TextBounds.X + 20, 0, 50 * scale)
				end
			end
		end
	end
end)

local camera = workspace.CurrentCamera

-- Generator thật
local DEFAULT_SIZE = 5
local MIN_SIZE = 3
local MAX_SIZE = 15

-- Fake Generator
local FAKE_DEFAULT_SIZE = 10
local FAKE_MIN_SIZE = 5
local FAKE_MAX_SIZE = 20

local trackedGenerators = {}
local partEspName = "NurbsPath"
local espTransparency = 0.5
local partEspTrigger = nil
local espConnection = nil
local generatorESPEnabled = false

-- == % Progress Format ==
local function getProgressPercent(value)
    if value == 0 then return "0%"
    elseif value == 26 then return "25%"
    elseif value == 52 then return "50%"
    elseif value == 78 then return "75%"
    elseif value == 100 then return "100%"
    else
    return ""
    end
end

-- == Scale Calculation ==
local function calculateScale(pos, isFake)
    if not camera then return DEFAULT_SIZE end
    local distance = (camera.CFrame.Position - pos).Magnitude

    local defaultSize = isFake and FAKE_DEFAULT_SIZE or DEFAULT_SIZE
    local minSize = isFake and FAKE_MIN_SIZE or MIN_SIZE
    local maxSize = isFake and FAKE_MAX_SIZE or MAX_SIZE

    local scale = defaultSize * (20 / distance)
    return math.clamp(scale, minSize, maxSize)
end

-- == BillboardGUI ESP ==
local function createOrUpdateProgressESP(model, progressValue)
    if not model or not model:IsA("Model") then return end

    local adornee = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not adornee then return end

    local billboard = model:FindFirstChild("Progress_ESP")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "Progress_ESP"
        billboard.Adornee = adornee
        billboard.Size = UDim2.new(0, DEFAULT_SIZE*10, 0, DEFAULT_SIZE*3)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = model

        local label = Instance.new("TextLabel")
        label.Name = "ProgressLabel"
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
    end

    local label = billboard:FindFirstChild("ProgressLabel")
    if label then
        if model.Name == "FakeGenerator" then
            label.Text = "Fake Generator"
            label.TextColor3 = Color3.fromRGB(255,0,0)
        else
            label.Text = getProgressPercent(progressValue)
            label.TextColor3 = Color3.fromRGB(255,255,255)
        end
    end

    local isFake = model.Name == "FakeGenerator"
    task.spawn(function()
        while billboard.Parent do
            local scale = calculateScale(adornee.Position, isFake)
            billboard.Size = UDim2.new(0, scale*10, 0, scale*3)
            task.wait(0.1)
        end
    end)
end

-- == BoxHandleAdornment ESP ==
local function attachESP(part)
    if not part or not part:IsA("BasePart") then return end
    if part:FindFirstChild("ESP_Fill") then return end

    local fill = Instance.new("BoxHandleAdornment")
    fill.Name = "ESP_Fill"
    fill.Adornee = part
    fill.AlwaysOnTop = true
    fill.ZIndex = 1
    fill.Size = part.Size
    fill.Transparency = espTransparency

    if part.Parent and part.Parent.Name == "FakeGenerator" then
        fill.Color3 = Color3.fromRGB(255,0,0)
    else
        fill.Color3 = Color3.fromRGB(220,150,255)
    end

    fill.Parent = part
end

local function attachESPForExistingParts()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower() == partEspName:lower() then
            attachESP(v)
        end
    end
end

-- == Update Generators ==
local function updateGenerators()
    local rootMap = workspace:FindFirstChild("Map")
    if not rootMap then return end
    local ingame = rootMap:FindFirstChild("Ingame")
    if not ingame then return end
    local gameMap = ingame:FindFirstChild("Map")
    if not gameMap then return end

    for _, obj in ipairs(gameMap:GetDescendants()) do
        if obj.Name == "Generator" or obj.Name == "FakeGenerator" then
            local progress = obj:FindFirstChild("Progress")
            local lastProgress = trackedGenerators[obj]

            if obj.Name == "Generator" and progress and progress:IsA("ValueBase") then
                if lastProgress ~= progress.Value then
                    createOrUpdateProgressESP(obj, progress.Value)
                    trackedGenerators[obj] = progress.Value
                end
            elseif obj.Name == "FakeGenerator" then
                createOrUpdateProgressESP(obj, 0)
                trackedGenerators[obj] = 0
            elseif lastProgress ~= nil then
                createOrUpdateProgressESP(obj, nil)
                trackedGenerators[obj] = nil
            end
        end
    end
end

-- == Continuous Scale Update ==
local function updateAllESPSizes()
    for gen in pairs(trackedGenerators) do
        local billboard = gen:FindFirstChild("Progress_ESP")
        local adornee = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
        if billboard and adornee then
            local isFake = gen.Name == "FakeGenerator"
            local scale = calculateScale(adornee.Position, isFake)
            billboard.Size = UDim2.new(0, scale*10, 0, scale*3)
        end
    end
end

-- == Start/Stop ESP ==
local updateThrottle = 0
local function startGeneratorESP()
    attachESPForExistingParts()
    if not partEspTrigger then
        partEspTrigger = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("BasePart") and v.Name:lower() == partEspName:lower() then
                attachESP(v)
            end
        end)
    end
    if not espConnection then
        espConnection = RunService.RenderStepped:Connect(function(dt)
            if generatorESPEnabled then
                updateThrottle += dt
                if updateThrottle >= 0.5 then
                    updateGenerators()
            		updateAllESPSizes()
                    updateThrottle = 0
                end
            end
        end)
    end
end

local function stopGeneratorESP()
    if partEspTrigger then
        partEspTrigger:Disconnect()
        partEspTrigger = nil
    end
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    for gen in pairs(trackedGenerators) do
        createOrUpdateProgressESP(gen, nil)
    end
    trackedGenerators = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower() == partEspName:lower() then
            local adorn = v:FindFirstChild("ESP_Fill")
            if adorn then adorn:Destroy() end
        end
    end
end

local colorByName = {
	BloxyCola = Color3.fromRGB(255, 140, 0),
	Medkit = Color3.fromRGB(255, 100, 255),
}

local espParts = {}
local partEspTrigger = nil

local function FindInTable(tbl, value)
	for _, v in pairs(tbl) do
		if v == value then return true end
	end
	return false
end

local function createNameTag(part, tagName, color)
	if part:FindFirstChild("ESP_Billboard") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_Billboard"
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.Parent = part

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0
	textLabel.Text = tagName
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextScaled = false
	textLabel.TextSize = 10
	textLabel.Parent = billboard
end

local function createBoxESP(part)
	if not part or not part:IsA("BasePart") then return end
	if part.Name ~= "ItemRoot" or not part.Parent then return end

	local tagName = part.Parent.Name
	local color = colorByName[tagName] or Color3.fromRGB(255, 255, 255)

	if part:FindFirstChild(tagName.."_PESP") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = tagName.."_PESP"
	box.Adornee = part
	box.Size = part.Size
	box.Transparency = 0.5
	box.Color3 = color
	box.ZIndex = 0
	box.AlwaysOnTop = true
	box.Parent = part

	createNameTag(part, tagName, color)
	table.insert(espParts, tagName)
end

function enableItemESP()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "ItemRoot" then
			createBoxESP(v)
		end
	end

	if not partEspTrigger then
		partEspTrigger = workspace.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") and part.Name == "ItemRoot" then
				createBoxESP(part)
			end
		end)
	end
end

function disableItemESP()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "ItemRoot" then
			if v:FindFirstChild("ESP_Billboard") then
				v:FindFirstChild("ESP_Billboard"):Destroy()
			end
			local tagName = v.Parent and v.Parent.Name
			if tagName and v:FindFirstChild(tagName.."_PESP") then
				v:FindFirstChild(tagName.."_PESP"):Destroy()
			end
		end
	end

	espParts = {}
	if partEspTrigger then
		partEspTrigger:Disconnect()
		partEspTrigger = nil
	end
end

MainESPGroup:AddToggle("ItemESP_Toggle", {
	Text = "Items ESP",
	Default = false,
	Callback = function(Value)
		itemESPEnabled = Value
		if itemESPEnabled then
			enableItemESP()
		else
			disableItemESP()
		end
	end,
})

MainESPGroup:AddToggle("GeneratorsESP", {
    Text = "Generators ESP",
    Default = false,
    Callback = function(Value)
        generatorESPEnabled = Value
        if Value then
            startGeneratorESP()
        else
            stopGeneratorESP()
        end
    end,
})

local ingame = workspace:WaitForChild("Map"):WaitForChild("Ingame")

--=====================
-- Builderman ESP
--=====================
local dispenserPartNames = { "SprayCan", "UpperHolder", "Root" }
local dispenserESPColor = Color3.fromRGB(0, 162, 255)
local sentryESPColor = Color3.fromRGB(128, 128, 128)
local espTransparency = 0.5

local function isDispenser(model)
	return model:IsA("Model") and model.Name:lower():find("dispenser")
end

local function isSentry(model)
	return model:IsA("Model") and model.Name:lower():find("sentry")
end

local function createBillboardESP(part, labelText, color)
	if part:FindFirstChild("BillboardESP") then return end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BillboardESP"
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, part.Size.Y + 1, 0)
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = false
	label.TextSize = 13
	label.Parent = billboard
end

local function createDispenserESP(part)
	if not _G.DispenserESPEnabled then return end
	if not part:IsA("BasePart") then return end
	if not table.find(dispenserPartNames, part.Name) then return end

	if not part:FindFirstChild(part.Name.."_PESP") then
		local adorn = Instance.new("BoxHandleAdornment")
		adorn.Name = part.Name.."_PESP"
		adorn.Adornee = part
		adorn.AlwaysOnTop = true
		adorn.ZIndex = 0
		adorn.Size = part.Size
		adorn.Transparency = espTransparency
		adorn.Color3 = dispenserESPColor
		adorn.Parent = part
	end

	if part.Name == "SprayCan" and not part:FindFirstChild("BillboardESP") then
		createBillboardESP(part, "Dispenser", dispenserESPColor)
	end
end

local function createSentryESP(part)
	if not _G.SentryESPEnabled then return end
	if not part:IsA("BasePart") then return end
	if part.Name ~= "Root" then return end

	if not part:FindFirstChild("Root_PESP") then
		local adorn = Instance.new("BoxHandleAdornment")
		adorn.Name = "Root_PESP"
		adorn.Adornee = part
		adorn.AlwaysOnTop = true
		adorn.ZIndex = 0
		adorn.Size = part.Size
		adorn.Transparency = espTransparency
		adorn.Color3 = sentryESPColor
		adorn.Parent = part
	end

	if not part:FindFirstChild("BillboardESP") then
		createBillboardESP(part, "Sentry", sentryESPColor)
	end
end

--=====================
-- CustomESP cho Taph
--=====================
local CustomESP_tripwarePartNames = { "Hook1", "Hook2", "Wire" }
local CustomESP_tripwareColor = Color3.fromRGB(255, 85, 0)
local CustomESP_subspaceColor = Color3.fromRGB(160, 32, 240)
local CustomESP_espTransparency = 0.5

local function CustomESP_isTripware(model)
	return model:IsA("Model") and model.Name:find("TaphTripwire") ~= nil
end

local function CustomESP_isSubspace(model)
	return model:IsA("Model") and model.Name == "SubspaceTripmine"
end

local function CustomESP_createBillboard(part, labelText, color)
	if part:FindFirstChild("CustomESP_BillboardESP") then return end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CustomESP_BillboardESP"
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, part.Size.Y + 1, 0)
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = false
	label.TextSize = 13
	label.Parent = billboard
end

local function CustomESP_createTripwareESP(part)
	if not _G.CustomESP_TripwareEnabled then return end
	if not part:IsA("BasePart") then return end
	if not table.find(CustomESP_tripwarePartNames, part.Name) then return end

	if not part:FindFirstChild(part.Name.."_CustomESP_PESP") then
		local adorn = Instance.new("BoxHandleAdornment")
		adorn.Name = part.Name.."_CustomESP_PESP"
		adorn.Adornee = part
		adorn.AlwaysOnTop = true
		adorn.ZIndex = 0
		adorn.Size = part.Size
		adorn.Transparency = CustomESP_espTransparency
		adorn.Color3 = CustomESP_tripwareColor
		adorn.Parent = part
	end

	if part.Name == "Wire" and not part:FindFirstChild("CustomESP_BillboardESP") then
		CustomESP_createBillboard(part, "Tripwire", CustomESP_tripwareColor)
	end
end

local function CustomESP_createSubspaceESP(part)
	if not _G.CustomESP_SubspaceEnabled then return end
	if not part:IsA("BasePart") then return end
	if part.Name ~= "SubspaceBox" then return end

	if not part:FindFirstChild("SubspaceBox_CustomESP_PESP") then
		local adorn = Instance.new("BoxHandleAdornment")
		adorn.Name = "SubspaceBox_CustomESP_PESP"
		adorn.Adornee = part
		adorn.AlwaysOnTop = true
		adorn.ZIndex = 0
		adorn.Size = part.Size
		adorn.Transparency = CustomESP_espTransparency
		adorn.Color3 = CustomESP_subspaceColor
		adorn.Parent = part
	end

	if not part:FindFirstChild("CustomESP_BillboardESP") then
		CustomESP_createBillboard(part, "Subspace Tripmine", CustomESP_subspaceColor)
	end
end

--=====================
-- Xoá ESP helper
--=====================
local function removeESPByNamePattern(parent, pattern)
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name:find(pattern) then
			child:Destroy()
		end
	end
end

--=====================
-- Enable/Disable
--=====================
function EnableDispenserESP() _G.DispenserESPEnabled = true end
function DisableDispenserESP()
	_G.DispenserESPEnabled = false
	for _, part in ipairs(ingame:GetDescendants()) do
		if part.Parent and isDispenser(part.Parent) then
			removeESPByNamePattern(part, "_PESP")
			removeESPByNamePattern(part, "BillboardESP")
		end
	end
end

function EnableSentryESP() _G.SentryESPEnabled = true end
function DisableSentryESP()
	_G.SentryESPEnabled = false
	for _, part in ipairs(ingame:GetDescendants()) do
		if part.Parent and isSentry(part.Parent) then
			removeESPByNamePattern(part, "_PESP")
			removeESPByNamePattern(part, "BillboardESP")
		end
	end
end

function EnableTripwareESP() _G.CustomESP_TripwareEnabled = true end
function DisableTripwareESP()
	_G.CustomESP_TripwareEnabled = false
	for _, part in ipairs(ingame:GetDescendants()) do
		if part.Parent and CustomESP_isTripware(part.Parent) then
			removeESPByNamePattern(part, "_CustomESP_PESP")
			removeESPByNamePattern(part, "CustomESP_BillboardESP")
		end
	end
end

function EnableSubspaceESP() _G.CustomESP_SubspaceEnabled = true end
function DisableSubspaceESP()
	_G.CustomESP_SubspaceEnabled = false
	for _, part in ipairs(ingame:GetDescendants()) do
		if part.Parent and CustomESP_isSubspace(part.Parent) then
			removeESPByNamePattern(part, "_CustomESP_PESP")
			removeESPByNamePattern(part, "CustomESP_BillboardESP")
		end
	end
end

--=====================
-- Event lắng nghe object spawn
--=====================
ingame.DescendantAdded:Connect(function(part)
	local parent = part.Parent
	if parent then
		if isDispenser(parent) then createDispenserESP(part) end
		if isSentry(parent) then createSentryESP(part) end
		if CustomESP_isTripware(parent) then CustomESP_createTripwareESP(part) end
		if CustomESP_isSubspace(parent) then CustomESP_createSubspaceESP(part) end
	end
end)

--=====================
-- 1 vòng loop duy nhất update tất cả
--=====================
task.spawn(function()
	while true do
		local parts = ingame:GetDescendants()
		for _, part in ipairs(parts) do
			local parent = part.Parent
			if not parent then continue end
			if _G.DispenserESPEnabled and isDispenser(parent) then createDispenserESP(part) end
			task.wait(0.5)
			if _G.SentryESPEnabled and isSentry(parent) then createSentryESP(part) end
			task.wait(0.5)
			if _G.CustomESP_TripwareEnabled and CustomESP_isTripware(parent) then CustomESP_createTripwareESP(part) end
			task.wait(0.5)
			if _G.CustomESP_SubspaceEnabled and CustomESP_isSubspace(parent) then CustomESP_createSubspaceESP(part) end
			task.wait(0.5)
		end
		task.wait(2)
	end
end)

--=====================
-- Rayfield Toggles
--=====================
local BuildermanGroup = Tabs.ESP:AddLeftGroupbox("Builderman ESP")
BuildermanGroup:AddToggle("ToggleBuilderDispenserESP", {
	Text = "Dispenser ESP",
	Default = false,
	Callback = function(v) if v then EnableDispenserESP() else DisableDispenserESP() end end
})
BuildermanGroup:AddToggle("ToggleBuilderSentryESP", {
	Text = "Sentry ESP",
	Default = false,
	Callback = function(v) if v then EnableSentryESP() else DisableSentryESP() end end
})

local TaphGroup = Tabs.ESP:AddRightGroupbox("Taph ESP")
TaphGroup:AddToggle("ToggleBuilderTripwareESP", {
	Text = "Tripwire ESP",
	Default = false,
	Callback = function(v) if v then EnableTripwareESP() else DisableTripwareESP() end end
})
TaphGroup:AddToggle("ToggleBuilderSubspaceESP", {
	Text = "Subspace Tripmine ESP",
	Default = false,
	Callback = function(v) if v then EnableSubspaceESP() else DisableSubspaceESP() end end
})

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Config global
getgenv().AimbotConfig = getgenv().AimbotConfig or {}

getgenv().AimbotConfig.Slash = getgenv().AimbotConfig.Slash or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 2 }
getgenv().AimbotConfig.Shoot = getgenv().AimbotConfig.Shoot or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 1.5 }
getgenv().AimbotConfig.Punch = getgenv().AimbotConfig.Punch or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 1.5 }
getgenv().AimbotConfig.TrueShoot = getgenv().AimbotConfig.TrueShoot or { Enabled = false, Smoothness = 1, Prediction = 0.6, Duration = 1.5 }
getgenv().AimbotConfig.ThrowPizza = getgenv().AimbotConfig.ThrowPizza or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 1.5 }
getgenv().AimbotConfig.Killers = getgenv().AimbotConfig.Killers or { Enabled = false, Duration = 3 }
getgenv().AimbotConfig.SelectedSkills = getgenv().AimbotConfig.SelectedSkills or {
    "Slash", "Punch", "Stab", "Nova", "VoidRush", 
    "WalkspeedOverride", "Behead", "GashingWound", 
    "CorruptNature", "CorruptEnergy", "MassInfection", "Entanglement"
}
getgenv().AimbotConfig.Mode = getgenv().AimbotConfig.Mode or "Aimlock" -- default

------------------------------------------------
-- GUI
local ShedletskyGroup = Tabs.Aimbot:AddLeftGroupbox("Shedletsky")
-- Slash
ShedletskyGroup:AddToggle("AutoAimSlash", {
    Text = "Aimbot Slash",
    Default = getgenv().AimbotConfig.Slash.Enabled,
    Callback = function(Value)
        getgenv().AimbotConfig.Slash.Enabled = Value
    end,
})

ShedletskyGroup:AddSlider("SmoothnessSlash", {
    Text = "Smoothness Slash",
    Default = getgenv().AimbotConfig.Slash.Smoothness * 100,
    Min = 0,
    Max = 101,
    Rounding = 0,
    Suffix = "ms",
    Callback = function(Value)
        getgenv().AimbotConfig.Slash.Smoothness = Value / 100
    end,
})

ShedletskyGroup:AddSlider("PredictionSlash", {
    Text = "Prediction Slash",
    Default = getgenv().AimbotConfig.Slash.Prediction,
    Min = 0,
    Max = 2,
    Rounding = 2,
    Suffix = "s",
    Callback = function(Value)
        getgenv().AimbotConfig.Slash.Prediction = Value
    end,
})

------------------------------------------------
local ChanceGroup = Tabs.Aimbot:AddLeftGroupbox("Chance")
-- Shoot
ChanceGroup:AddToggle("AutoAimShoot", {
    Text = "Aimbot One Shot",
    Default = getgenv().AimbotConfig.Shoot.Enabled,
    Callback = function(Value)
        getgenv().AimbotConfig.Shoot.Enabled = Value
    end,
})

ChanceGroup:AddSlider("SmoothnessShoot", {
    Text = "Smoothness One Shot",
    Default = getgenv().AimbotConfig.Shoot.Smoothness * 100,
    Min = 0,
    Max = 101,
    Rounding = 0,
    Suffix = "ms",
    Callback = function(Value)
        getgenv().AimbotConfig.Shoot.Smoothness = Value / 100
    end,
})

ChanceGroup:AddSlider("PredictionShoot", {
    Text = "Prediction One Shot",
    Default = getgenv().AimbotConfig.Shoot.Prediction,
    Min = 0,
    Max = 2,
    Rounding = 2,
    Suffix = "s",
    Callback = function(Value)
        getgenv().AimbotConfig.Shoot.Prediction = Value
    end,
})

------------------------------------------------
ChanceGroup:AddLabel("True One Shot Aimbot\nFor Chance True One Shot Only", true)

ChanceGroup:AddToggle("AutoAimTrueShoot", {
    Text = "Aimbot True One Shot",
    Default = getgenv().AimbotConfig.TrueShoot.Enabled,
    Callback = function(Value)
        getgenv().AimbotConfig.TrueShoot.Enabled = Value
    end,
})

ChanceGroup:AddSlider("SmoothnessTrueShoot", {
    Text = "Smoothness True One Shot",
    Default = getgenv().AimbotConfig.TrueShoot.Smoothness * 100,
    Min = 0,
    Max = 101,
    Rounding = 0,
    Suffix = "ms",
    Callback = function(Value)
        getgenv().AimbotConfig.TrueShoot.Smoothness = Value / 100
    end,
})

ChanceGroup:AddSlider("PredictionTrueShoot", {
    Text = "Prediction True One Shot",
    Default = getgenv().AimbotConfig.TrueShoot.Prediction,
    Min = 0,
    Max = 2,
    Rounding = 2,
    Suffix = "s",
    Callback = function(Value)
        getgenv().AimbotConfig.TrueShoot.Prediction = Value
    end,
})

------------------------------------------------
local GuestGroup = Tabs.Aimbot:AddRightGroupbox("Guest 1337")
-- Punch
GuestGroup:AddToggle("AutoAimPunch", {
    Text = "Aimbot Punch",
    Default = getgenv().AimbotConfig.Punch.Enabled,
    Callback = function(Value)
        getgenv().AimbotConfig.Punch.Enabled = Value
    end,
})

GuestGroup:AddSlider("SmoothnessPunch", {
    Text = "Smoothness Punch",
    Default = getgenv().AimbotConfig.Punch.Smoothness * 100,
    Min = 0,
    Max = 101,
    Rounding = 0,
    Suffix = "ms",
    Callback = function(Value)
        getgenv().AimbotConfig.Punch.Smoothness = Value / 100
    end,
})

GuestGroup:AddSlider("PredictionPunch", {
    Text = "Prediction Punch",
    Default = getgenv().AimbotConfig.Punch.Prediction,
    Min = 0,
    Max = 2,
    Rounding = 2,
    Suffix = "s",
    Callback = function(Value)
        getgenv().AimbotConfig.Punch.Prediction = Value
    end,
})

------------------------------------------------
local ElliotGroup = Tabs.Aimbot:AddRightGroupbox("Elliot")
-- ThrowPizza
ElliotGroup:AddToggle("AutoAimThrowPizza", {
    Text = "Aimbot Throw Pizza",
    Default = getgenv().AimbotConfig.ThrowPizza.Enabled,
    Callback = function(Value)
        getgenv().AimbotConfig.ThrowPizza.Enabled = Value
    end,
})

ElliotGroup:AddSlider("SmoothnessThrowPizza", {
    Text = "Smoothness Throw Pizza",
    Default = getgenv().AimbotConfig.ThrowPizza.Smoothness * 100,
    Min = 0,
    Max = 101,
    Rounding = 0,
    Suffix = "ms",
    Callback = function(Value)
        getgenv().AimbotConfig.ThrowPizza.Smoothness = Value / 100
    end,
})

ElliotGroup:AddSlider("PredictionThrowPizza", {
    Text = "Prediction Throw Pizza",
    Default = getgenv().AimbotConfig.ThrowPizza.Prediction,
    Min = 0,
    Max = 2,
    Rounding = 1,
    Suffix = "s",
    Callback = function(Value)
        getgenv().AimbotConfig.ThrowPizza.Prediction = Value
    end,
})

------------------------------------------------
local KillersGroup = Tabs.Aimbot:AddRightGroupbox("Killers")
-- Killers
KillersGroup:AddToggle("EnableAimbotAll", {
    Text = "Killers's Aimbot",
    Default = getgenv().AimbotConfig.Killers.Enabled,
    Callback = function(Value)
        getgenv().AimbotConfig.Killers.Enabled = Value
    end,
})

------------------------------------------------
local AimModeGroup = Tabs.Aimbot:AddRightGroupbox("AimMode")
AimModeGroup:AddDropdown("AimModeSelect", {
    Text = "Aim Mode",
    Values = {"Aimbot", "RootPart"},
    Default = getgenv().AimbotConfig.Mode,
    Callback = function(Value)
        getgenv().AimbotConfig.Mode = Value
    end,
})

------------------------------------------------
-- Hàm kiểm tra skill Killers
local function isKillerSkill(skillName)
    for _, v in ipairs(getgenv().AimbotConfig.SelectedSkills) do
        if v == skillName then return true end
    end
    return false
end

-- Lấy mục tiêu gần nhất theo distance
local function getNearestTargetByDistance()
    local nearest
    local shortestDistance = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                nearest = player
            end
        end
    end
    return nearest
end

-- Lấy mục tiêu MaxHP > 300
local function getNearestTargetByMaxHP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.MaxHealth > 300 then
                return player
            end
        end
    end
end

------------------------------------------------
-- Aim functions
local function aimrootpart(target, duration, prediction, smoothness)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root or not myRoot then return end

    task.spawn(function()
        local start = tick()
        while tick() - start < duration and root.Parent and myRoot.Parent do
            local predictedPos = root.Position + (root.Velocity * prediction)
            local targetCFrame = CFrame.lookAt(myRoot.Position, predictedPos)
            myRoot.CFrame = myRoot.CFrame:Lerp(targetCFrame, math.clamp(smoothness, 0, 1))
            task.wait()
        end
    end)
end

local function aimlock(target, duration, prediction, smoothness)
    local start = tick()
    local cam = workspace.CurrentCamera
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if tick() - start > duration or not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            conn:Disconnect()
            return
        end
        local hrp = target.Character.HumanoidRootPart
        local pos = hrp.Position + (hrp.Velocity * prediction)
        local cf = CFrame.new(cam.CFrame.Position, pos)
        cam.CFrame = cam.CFrame:Lerp(cf, math.clamp(smoothness, 0, 1))
    end)
end

-- Aim theo mode
local function aimTarget(target, duration, prediction, smoothness)
    if not target then return end
    if getgenv().AimbotConfig.Mode == "Aimbot" then
        aimlock(target, duration, prediction, smoothness)
    elseif getgenv().AimbotConfig.Mode == "RootPart" then
        aimrootpart(target, duration, prediction, smoothness)
    end
end

------------------------------------------------
-- Skill event handler
RemoteEvent.OnClientEvent:Connect(function(...)
    local args = {...}
    if args[1] == "UseActorAbility" then
        local skill = args[2]
        local player = getgenv().Player
        local character = getgenv().getCharacter()

        -- Slash
        if skill == "Slash" and getgenv().AimbotConfig.Slash.Enabled and character.Name == "Shedletsky" then
            local target = getNearestTargetByMaxHP()
            aimTarget(target, getgenv().AimbotConfig.Slash.Duration, getgenv().AimbotConfig.Slash.Prediction, getgenv().AimbotConfig.Slash.Smoothness)
        end

        -- Shoot
        if skill == "Shoot" then
            if getgenv().AimbotConfig.Shoot.Enabled then
                local target = getNearestTargetByMaxHP()
                aimTarget(target, getgenv().AimbotConfig.Shoot.Duration, getgenv().AimbotConfig.Shoot.Prediction, getgenv().AimbotConfig.Shoot.Smoothness)
            end
            if getgenv().AimbotConfig.TrueShoot.Enabled then
                local target = getNearestTargetByMaxHP()
                aimlock(target, getgenv().AimbotConfig.TrueShoot.Duration, getgenv().AimbotConfig.TrueShoot.Prediction, getgenv().AimbotConfig.TrueShoot.Smoothness)
            end
        end

        -- Punch
        if skill == "Punch" and getgenv().AimbotConfig.Punch.Enabled then
            local target = getNearestTargetByMaxHP()
            aimTarget(target, getgenv().AimbotConfig.Punch.Duration, getgenv().AimbotConfig.Punch.Prediction, getgenv().AimbotConfig.Punch.Smoothness)
        end

        -- ThrowPizza
        if skill == "ThrowPizza" and getgenv().AimbotConfig.ThrowPizza.Enabled then
            local target = getNearestTargetByDistance()
            aimTarget(target, getgenv().AimbotConfig.ThrowPizza.Duration, getgenv().AimbotConfig.ThrowPizza.Prediction, getgenv().AimbotConfig.ThrowPizza.Smoothness)
        end

        -- Killers
        if getgenv().AimbotConfig.Killers.Enabled and isKillerSkill(skill) then
            local target = getNearestTargetByDistance()
            aimTarget(target, getgenv().AimbotConfig.Killers.Duration, 0, 1)
        end
    end
end)


local staminaLoopToggle = false
local maxStamina = 100
local minStamina = 0
local staminaGain = 20
local staminaLoss = 10
local sprintSpeed = 26
local staminaLossDisabled = false

local StaminaGroup = Tabs.StaminaSet:AddLeftGroupbox("Stamina Settings")

StaminaGroup:AddToggle("StaminaLoopToggle", {
    Text = "Inj3ct Stamina",
    Default = false,
    Callback = function(Value)
        staminaLoopToggle = Value
    end,
})

StaminaGroup:AddInput("MaxStaminaInput", {
    Text = "Max Stamina",
    Default = tostring(maxStamina),
    Placeholder = "e.g. 100",
    Numeric = true,
    Callback = function(Text)
        maxStamina = tonumber(Text) or maxStamina
    end,
})

StaminaGroup:AddInput("MinStaminaInput", {
    Text = "Min Stamina",
    Default = tostring(minStamina),
    Placeholder = "e.g. 0",
    Numeric = true,
    Callback = function(Text)
        minStamina = tonumber(Text) or minStamina
    end,
})

StaminaGroup:AddInput("StaminaGainInput", {
    Text = "Stamina Gain",
    Default = tostring(staminaGain),
    Placeholder = "e.g. 10",
    Numeric = true,
    Callback = function(Text)
        staminaGain = tonumber(Text) or staminaGain
    end,
})

StaminaGroup:AddInput("StaminaLossInput", {
    Text = "Stamina Loss",
    Default = tostring(staminaLoss),
    Placeholder = "e.g. 10",
    Numeric = true,
    Callback = function(Text)
        staminaLoss = tonumber(Text) or staminaLoss
    end,
})

StaminaGroup:AddInput("SprintSpeedInput", {
    Text = "Sprint Speed",
    Default = tostring(sprintSpeed),
    Placeholder = "e.g. 26",
    Numeric = true,
    Callback = function(Text)
        sprintSpeed = tonumber(Text) or sprintSpeed
    end,
})

StaminaGroup:AddToggle("ToggleStaminaLossDisabled", {
    Text = "Disable Stamina Loss",
    Default = false,
    Callback = function(Value)
        staminaLossDisabled = Value
    end,
})

task.spawn(function()
   local Sprinting = game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
   local stamina = require(Sprinting)

   local defaultValues = {
      MaxStamina = 100,
      MinStamina = 0,
      StaminaGain = 20,
      StaminaLoss = 10,
      SprintSpeed = 26,
   }

   while task.wait() do
      if staminaLoopToggle then
         stamina.MaxStamina = maxStamina
         stamina.MinStamina = minStamina
         stamina.StaminaGain = staminaGain
         stamina.StaminaLoss = staminaLoss
         stamina.SprintSpeed = sprintSpeed
         stamina.StaminaLossDisabled = staminaLossDisabled
      else
         stamina.MaxStamina = defaultValues.MaxStamina
         stamina.MinStamina = defaultValues.MinStamina
         stamina.StaminaGain = defaultValues.StaminaGain
         stamina.StaminaLoss = def...(truncated 60518 characters)...tHRP = function()
    local char = getgenv().LocalPlayer.Character or getgenv().LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Get HP
getgenv().getHP = function()
    local char = getgenv().LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then return hum.Health end
    end
    return 0
end

-- Get any Pizza CFrame
getgenv().getPizzaCF = function()
    local pizzaFolder = getgenv().Workspace:FindFirstChild("Map") and getgenv().Workspace.Map:FindFirstChild("Ingame")
    if not pizzaFolder then return nil end
    local pizza = pizzaFolder:FindFirstChild("Pizza")
    if not pizza then return nil end

    if pizza:IsA("BasePart") or pizza:IsA("MeshPart") or pizza:IsA("UnionOperation") then
        return pizza.CFrame
    elseif pizza:IsA("Model") then
        local pp = pizza.PrimaryPart or pizza:FindFirstChildWhichIsA("BasePart")
        if pp then
            if not pizza.PrimaryPart then pizza.PrimaryPart = pp end
            return pp.CFrame
        end
    elseif pizza:IsA("CFrameValue") then
        return pizza.Value
    end
end

local PizzaGroup = Tabs.Miscs:AddLeftGroupbox("Pizza")
    
PizzaGroup:AddToggle("BlinkToggle", {
    Text = "Auto Eat Pizza Instantly",
    Default = false,
    Callback = function(Value)
        getgenv().BlinkToPizzaToggle = Value
    end
})

PizzaGroup:AddInput("HPThresholdInput", {
    Text = "HP Threshold",
    Placeholder = "30",
    Numeric = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            getgenv().HPThreshold = num
        end
    end
})

-- Loop Blink tự động
spawn(function()
    while task.wait(0.9) do
        if getgenv().BlinkToPizzaToggle then
            local hrp = getgenv().getHRP()
            local pizzaCF = getgenv().getPizzaCF()
            if pizzaCF and getgenv().getHP() <= getgenv().HPThreshold then
                local oldCF = hrp.CFrame
                hrp.CFrame = pizzaCF * CFrame.new(0,1,0)
                getgenv().activateRemoteHook("UnreliableRemoteEvent", "UpdCF")
                task.delay(0.2, function()
                    hrp.CFrame = oldCF
                    task.wait(0.3)
                    getgenv().deactivateRemoteHook("UnreliableRemoteEvent", "UpdCF")
                end)
            end
        end
    end
end)


local ItemsGroup = Tabs.Miscs:AddLeftGroupbox("Items")

local RoundTimer = ReplicatedStorage:WaitForChild("RoundTimer")
local autoPickupEnabled = true

-- Check còn sống
local function isAlive(char)
	return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

-- Khi TimeLeft = 0
local hasDropped = false
RoundTimer:GetAttributeChangedSignal("TimeLeft"):Connect(function()
	if not autoPickupEnabled or hasDropped then return end

	local timeLeft = RoundTimer:GetAttribute("TimeLeft")
	if timeLeft and timeLeft <= 0.2 then
		local char = game:GetService("Players").LocalPlayer.Character
		if not char then return end

		-- Equip tất cả tool từ Backpack
		for _, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = char
			end
		end
		task.wait()

		-- Drop tool ra workspace
		for _, v in pairs(char:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = workspace
			end
		end

		hasDropped = true
	end
end)

-- Auto Pickup Tool khi còn sống
task.spawn(function()
	while task.wait(1) do
		local char = game:GetService("Players").LocalPlayer.Character
		if autoPickupEnabled and isAlive(char) then
			local mapIngame = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
			if mapIngame then
				for _, tool in ipairs(mapIngame:GetChildren()) do
					if tool:IsA("Tool") then
						char.Humanoid:EquipTool(tool)
					end
				end
			end
		end
	end
end)

ItemsGroup:AddToggle("AutoPickupTool", {
	Text = "Auto Pickup Drop Items (Working Ingame/Lobby)",
	Default = false,
	Callback = function(Value)
		autoPickupEnabled = Value
	end,
})

_G.pickUpNear = false
_G.pickUpAll = false

local function autoPickUpLoop()
    while task.wait(0.2) do
        if not _G.pickUpNear and not _G.pickUpAll then break end

        pcall(function()
            local items = {}
            for _, v in pairs(workspace.Map.Ingame:GetDescendants()) do
                if v:IsA("Tool") then
                    table.insert(items, v.ItemRoot)
                end
            end

            for _, v in pairs(items) do
                if _G.pickUpNear then
                    local magnitude = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).magnitude
                    if magnitude <= 10 then
                        fireproximityprompt(v.ProximityPrompt)
                    end
                end

                if _G.pickUpAll then
                    if not game.Players.LocalPlayer.Backpack:FindFirstChild(v.Parent.Name) then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                        task.wait(0.3)
                        fireproximityprompt(v.ProximityPrompt)
                    end
                end
            end
        end)
    end
end

ItemsGroup:AddToggle("AutoPickUpItems", {
    Text = "Auto Pick Up Near Items",
    Default = false,
    Callback = function(call)
        _G.pickUpNear = call
        if call then
            task.spawn(autoPickUpLoop)
        end
    end,
})

ItemsGroup:AddToggle("AutoPickUpAll", {
    Text = "Auto Pick Up All Items",
    Default = false,
    Callback = function(call)
        _G.pickUpAll = call
        if call then
            task.spawn(autoPickUpLoop)
        end
    end,
})

-- === Section Creation ===
local InvisibilityGroup = Tabs.Miscs:AddLeftGroupbox("Invisibility")


-- === Animation Loop ===
local animationId = "75804462760596"
local animationSpeed = 0
local loopRunning = false
local loopThread
local currentAnim = nil

InvisibilityGroup:AddToggle("ToggleAnimLoop", {
    Text = "Invisibility",
    Default = false,
    Callback = function(Value)
        loopRunning = Value

        local speaker = Players.LocalPlayer
        if not speaker or not speaker.Character then return end

        local humanoid = speaker.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then
            Library:Notify({
                Title = "R6 Required",
                Description = "This only works with R6 rig!",
                Duration = 5
            })
            return
        end

        if Value then
            loopThread = task.spawn(function()
                while loopRunning do
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://" .. animationId
                    local loadedAnim = humanoid:LoadAnimation(anim)
                    currentAnim = loadedAnim
                    loadedAnim.Looped = false
                    loadedAnim:Play()
                    loadedAnim:AdjustSpeed(animationSpeed)
                    task.wait(0.000001)
                end
            end)
        else
            if loopThread then
                loopRunning = false
                task.cancel(loopThread)
            end
            if currentAnim then
                currentAnim:Stop()
                currentAnim = nil
            end
            local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
            if Humanoid then
                for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do
                    v:AdjustSpeed(100000)
                end
            end
            local animateScript = speaker.Character:FindFirstChild("Animate")
            if animateScript then
                animateScript.Disabled = true
                animateScript.Disabled = false
            end
        end
    end,
})

InvisibilityGroup:AddToggle("GhostingToggle", {
    Text = "CFrame Ghosting (OP)",
    Default = false,
    Callback = function(state)
        if state then
            getgenv().activateRemoteHook("UnreliableRemoteEvent", "UpdCF")
        else
            getgenv().deactivateRemoteHook("UnreliableRemoteEvent", "UpdCF")
        end
    end
})

local FakeLagGroup = Tabs.Miscs:AddLeftGroupbox("Fake Lag")

-- Biến FakeLag
getgenv().FakeLag = {
    Active = false,
    targetRemoteName = "UnreliableRemoteEvent",
    blockedFirstArg = "UpdCF",
    delay = 0.1,
    lastSendTime = 0,
    Hooked = false
}

-- Setup hook 1 lần
getgenv().FakeLag.Setup = function()
    if getgenv().FakeLag.Hooked then return end

    getgenv().FakeLag.SavedHook = hookmetamethod(game, "__namecall", function(self, ...)
        local methodName = getnamecallmethod()
        local arguments = {...}

        if self.Name == getgenv().FakeLag.targetRemoteName and methodName == "FireServer" and arguments[1] == getgenv().FakeLag.blockedFirstArg then
            if getgenv().FakeLag.Active then
                local currentTime = tick()
                if currentTime - getgenv().FakeLag.lastSendTime < getgenv().FakeLag.delay then
                    return -- chặn nếu chưa đủ interval
                else
                    getgenv().FakeLag.lastSendTime = currentTime
                end
            end
        end

        return getgenv().FakeLag.SavedHook(self, ...)
    end)

    getgenv().FakeLag.Hooked = true
end

-- Kích hoạt FakeLag
getgenv().FakeLag.Activate = function()
    getgenv().FakeLag.Active = true
end

-- Tắt FakeLag
getgenv().FakeLag.Deactivate = function()
    getgenv().FakeLag.Active = false
end

-- Khởi tạo hook ngay khi load script
getgenv().FakeLag.Setup()

-- Rayfield Toggle
FakeLagGroup:AddToggle("FakeLagToggle", {
    Text = "Enable Fake Lag",
    Default = false,
    Callback = function(Value)
        if Value then
            getgenv().FakeLag.Activate()
local args = {
	"UpdateSettings",
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Settings"):WaitForChild("Advanced"):WaitForChild("ShowPlayerHitboxes"),
	true
}
game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
        else
            getgenv().FakeLag.Deactivate()
local args = {
	"UpdateSettings",
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Settings"):WaitForChild("Advanced"):WaitForChild("ShowPlayerHitboxes"),
	false
}
game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
        end
    end
})

-- Rayfield Input để set delay dynamically
FakeLagGroup:AddInput("FakeLagDelay", {
    Text = "Delay (seconds)",
    Default = tostring(getgenv().FakeLag.delay),
    Numeric = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            getgenv().FakeLag.delay = num
        else
            warn("Invalid delay value!")
        end
    end
})

getgenv().Players = game:GetService("Players")
getgenv().MarketplaceService = game:GetService("MarketplaceService")
getgenv().RunService = game:GetService("RunService")
getgenv().player = getgenv().Players.LocalPlayer

-- Animation thay thế
getgenv().replacementAnimations = {
    idle = "rbxassetid://134624270247120",
    walk = "rbxassetid://132377038617766",
    run = "rbxassetid://115946474977409"
}

getgenv().animationNameCache = {}
getgenv().currentTrack = nil
getgenv().currentType = nil
getgenv().toggleEnabled = false -- Biến toggle

-- Lấy tên animation từ AssetId
getgenv().getAnimationNameFromId = function(assetId)
    if getgenv().animationNameCache[assetId] then
        return getgenv().animationNameCache[assetId]
    end

    local success, info = pcall(function()
        return getgenv().MarketplaceService:GetProductInfo(assetId)
    end)

    if success and info and info.Name then
        getgenv().animationNameCache[assetId] = info.Name
        return info.Name
    end

    return nil
end

-- Phát animation thay thế
getgenv().playReplacementAnimation = function(animator, animType)
    if getgenv().currentTrack then
        getgenv().currentTrack:Stop()
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = getgenv().replacementAnimations[animType]
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Movement
    track:Play()

    getgenv().currentTrack = track
    getgenv().currentType = animType
end

-- Thiết lập cho nhân vật
getgenv().setupCharacter = function(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    -- Cập nhật tốc độ animation theo WalkSpeed bằng Heartbeat
    getgenv().RunService.Heartbeat:Connect(function()
        if getgenv().toggleEnabled and getgenv().currentTrack then
            if getgenv().currentType == "idle" then
                getgenv().currentTrack:AdjustSpeed(1)
            elseif getgenv().currentType == "walk" then
                getgenv().currentTrack:AdjustSpeed(humanoid.WalkSpeed / 12)
            elseif getgenv().currentType == "run" then
                getgenv().currentTrack:AdjustSpeed(humanoid.WalkSpeed / 26)
            end
        end
    end)

    -- Thay thế animation khi phát
    animator.AnimationPlayed:Connect(function(track)
        if getgenv().toggleEnabled then
            local animationId = track.Animation.AnimationId
            local assetId = animationId:match("%d+")

            if assetId then
                local animName = getgenv().getAnimationNameFromId(tonumber(assetId))
                if animName then
                    local lowerName = animName:lower()

                    if lowerName:find("idle") then
                        track:Stop()
                        getgenv().playReplacementAnimation(animator, "idle")
                    elseif lowerName:find("walk") then
                        track:Stop()
                        getgenv().playReplacementAnimation(animator, "walk")
                    elseif lowerName:find("run") then
                        track:Stop()
                        getgenv().playReplacementAnimation(animator, "run")
                    end
                end
            end
        end
    end)
end

-- Áp dụng khi nhân vật spawn
if getgenv().player.Character then
    getgenv().setupCharacter(getgenv().player.Character)
end
getgenv().player.CharacterAdded:Connect(getgenv().setupCharacter)

local AnimationsGroup = Tabs.Miscs:AddRightGroupbox("Animations")

AnimationsGroup:AddToggle("CustomAnimationsToggle", {
    Text = "Fake Injured Animations",
    Default = false,
    Callback = function(value)
        getgenv().toggleEnabled = value
        if not value and getgenv().currentTrack then
            getgenv().currentTrack:Stop() -- Tắt animation khi toggle off
        end
    end
})

local OneGroup = Tabs.Miscs:AddRightGroupbox("1x1x1x1")

OneGroup:AddToggle("Toggle_1x1Popup", {
    Text = "Auto Close 1x1x1x1 Popups",
    Default = false,
    Callback = function(Value)
        DoLoop = Value
        task.spawn(function()
            local player = game:GetService("Players").LocalPlayer
            local Survivors = workspace:WaitForChild("Players"):WaitForChild("Survivors")
            while DoLoop and task.wait() do
                -- Auto Close 1x1x1x1 Popups
                local temp = player.PlayerGui:FindFirstChild("TemporaryUI")
                if temp and temp:FindFirstChild("1x1x1x1Popup") then
                    temp["1x1x1x1Popup"]:Destroy()
                end

                -- Anti-Slow SlowedStatus
                for _, survivor in pairs(Survivors:GetChildren()) do
                    if survivor:GetAttribute("Username") == player.Name then
                        -- SpeedMultipliers
                        local speedMultipliers = survivor:FindFirstChild("SpeedMultipliers")
                        if speedMultipliers then
                            local val = speedMultipliers:FindFirstChild("SlowedStatus")
                            if val and val:IsA("NumberValue") then
                                val.Value = 1
                            end
                        end
                        -- FOVMultipliers
                        local fovMultipliers = survivor:FindFirstChild("FOVMultipliers")
                        if fovMultipliers then
                            local val = fovMultipliers:FindFirstChild("SlowedStatus")
                            if val and val:IsA("NumberValue") then
                                val.Value = 1
                            end
                        end
                    end
                end
            end
        end)
    end
})

-- Services
getgenv().SoundService = game:GetService("SoundService")
getgenv().RunService = game:GetService("RunService")

-- Ensure folders exist
local folderPath = "NyansakenHub/Assets"
if not isfolder("NyansakenHub") then makefolder("NyansakenHub") end
if not isfolder(folderPath) then makefolder(folderPath) end

-- Track list
getgenv().tracks = {
    ["None"] = "",
    ["----------- UST -----------"] = nil,
    ["A BRAVE SOUL (MS 4 Killer VS MS 4 Survivor)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/A%20BRAVE%20SOUL%20(MS%204%20Killer%20VS%20MS%204%20Survivor).mp3",
    ["BEGGED (MS 4 Coolkidd vs MS 4 007n7)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/BEGGED%20(MS%204%20Coolkidd%20vs%20MS%204%20007n7).mp3",
    ["DOOMSPIRE (HairyTwinkle VS Pedro.EXE)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/DOOMSPIRE%20-%20(HairyTwinkle%20VS%20Pedro.EXE).mp3",
    ["ECLIPSE (xX4ce0fSpadesXx vs dragondudes3)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/ECLIPSE%20(xX4ce0fSpadesXx%20vs%20dragondudes3).mp3",
    ["ERROR 264 (Noob Cosplay VS Yourself)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/ERROR%20264%20-%20(Noob%20Cosplay%20VS%20Yourself).mp3",
    ["GODS SECOND COMING (NOLI VS. 007n7)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/GODS%20SECOND%20COMING%20(NOLI%20VS.%20007n7).mp3",
    ["Entreat (Bluudude Vs 118o8)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Entreat%20(Bluudude%20Vs%20118o8).mp3",
    ["Implore (Comic vs Savior)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Implore%20(Comic%20vs%20Savior)%20-%20YouTube.mp3",
    ["Leftovers (Remix Vanity Jason Vs All)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Leftovers%20(Remix%20Vanity%20Jason%20Vs%20All).mp3",
    ["ORDER UP (Elliot VS c00lkidd)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/ORDER%20UP%20-%20(Elliot%20VS%20c00lkidd).mp3",
    ["PARADOX (Guest 666 Vs Guest 1337)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/PARADOX%20(Guest%20666%20Vs%20Guest%201337).mp3",
    ["TRUE BEAUTY (PRETTYPRINCESS vs 226w6)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/TRUE%20BEAUTY%20(PRETTYPRINCESS%20vs%20226w6).mp3",
    ["Fall of a Hero (SLASHER vs GUEST 1337)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/%5BSLASHER%20vs%20GUEST%201337%20-%20LAST%20MAN%20STANDING%5D%20Fall%20of%20a%20Hero%20-%20Forsaken%20UST.mp3",
    ["21ST CENTURY HUMOR (MLG Chance vs Hood Irony Whistle Occurrence)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/21ST%20CENTURY%20HUMOR%20-%20Last%20Man%20Standing%20(MLG%20Chance%20vs%20Hood%20Irony%20Whistle%20Occurrence)%20%20Forsaken%20UST.mp3",
    ["SHATTERED GRACE (GR1MX 1x1x1x1 vs. ANGEL SHEDLETSKY)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/SHATTERED%20GRACE%20%5BGR1MX%201x1x1x1%20vs.%20ANGEL%20SHEDLETSKY%20LAST%20MAN%20STANDING%5D%20(Roblox%20Forsaken%20UST).mp3",
    ["----------- Scrapped LMS -----------"] = nil,
    ["THE DARKNESS IN YOUR HEART (Old 1x4 Vs Shedletsky)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/THE%20DARKNESS%20IN%20YOUR%20HEART%20(Old%201x4%20Vs%20Shedletsky).mp3",
    ["MEET YOUR MAKING (c00lkidd ~ 1x4 Vs 007n7 ~ Shedletsky)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/MEET%20YOUR%20MAKING%20(c00lkidd%20~%201x4%20Vs%20007n7%20~%20Shedletsky).mp3",
    ["A Creation Of Sorrow (Hacklord vs The Heartbroken)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/A%20Creation%20Of%20Sorrow%20(Hacklord%20vs%20The%20Heartbroken).mp3",
    ["Debth (Natrasha Vs Mafioso)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Debth%20(Natrasha%20Vs%20Mafioso).mp3",
    ["ETERNAL HOPE, ETERNAL FIGHT (Old LMS)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/ETERNAL%20HOPE,%20ETERNAL%20FIGHT%20(Old%20LMS).mp3",
    ["Receading Lifespan (Barber Jason Vs Bald Two Time)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Receading%20Lifespan%20(Barber%20Jason%20Vs%20Bald%20Two%20Time).mp3",
    ["VIP Jason LMS (VIP Jason Vs All)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/VIP%20Jason%20LMS%20(VIP%20Jason%20Vs%20All).mp3",
    ["Jason Hate This Song"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/California%20Gurls%20%20Audio%20Edit%20-%20Neonick.mp3",
    ["----------- Official LMS -----------"] = nil,
    ["A GRAVE SOUL (NOW, RUN) [All Killers Vs All Survivors]"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/A%20GRAVE%20SOUL%20(NOW,%20RUN)%20%5BAll%20Killers%20Vs%20All%20Survivors%5D.mp3",
    ["Plead (c00lkidd Vs 007n7)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Plead%20(c00lkidd%20Vs%20007n7).mp3",
    ["SMILE (Cupcakes Vs All)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/SMILE%20(Cupcakes%20Vs%20All)%20.mp3",
    ["Vanity (Vanity Jason Vs All)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Vanity%20(Vanity%20Jason%20Vs%20All).mp3",
    ["Obsession (Gasharpoon Vs All)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Obsession%20(Gasharpoon%20Vs%20All).MP3",
    ["Burnout (Diva Vs Ghoul)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Burnout%20(Diva%20Vs%20Ghoul).mp3",
    ["Close To Me (Annihilation Vs Friend)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Close%20To%20Me%20(Annihilation%20Vs%20Friend).mp3",
    ["Creation Of Hatred (1X4 Vs Shedletsky)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Creation%20Of%20Hatred%20(1X4%20Vs%20Shedletsky).mp3",
    ["Through Patches of Violet (Hacklord vs The Heartbroken)"] = "https://github.com/NyansakenHub/NyansakenHub/raw/refs/heads/main/Through%20Patches%20of%20Violet%20(Hacklord%20vs%20The%20Heartbroken).mp3"
}

-- Options giữ thứ tự gốc
local options = {
    "None",
    "----------- UST -----------",
    "A BRAVE SOUL (MS 4 Killer VS MS 4 Survivor)",
    "BEGGED (MS 4 Coolkidd vs MS 4 007n7)",
    "DOOMSPIRE (HairyTwinkle VS Pedro.EXE)",
    "ECLIPSE (xX4ce0fSpadesXx vs dragondudes3)",
    "ERROR 264 (Noob Cosplay VS Yourself)",
    "GODS SECOND COMING (NOLI VS. 007n7)",
    "Entreat (Bluudude Vs 118o8)",
    "Implore (Comic vs Savior)",
    "Leftovers (Remix Vanity Jason Vs All)",
    "ORDER UP (Elliot VS c00lkidd)",
    "PARADOX (Guest 666 Vs Guest 1337)",
    "TRUE BEAUTY (PRETTYPRINCESS vs 226w6)",
    "Fall of a Hero (SLASHER vs GUEST 1337)",
    "21ST CENTURY HUMOR (MLG Chance vs Hood Irony Whistle Occurrence)",
    "SHATTERED GRACE (GR1MX 1x1x1x1 vs. ANGEL SHEDLETSKY)",
    "----------- Scrapped LMS -----------",
    "THE DARKNESS IN YOUR HEART (Old 1x4 Vs Shedletsky)",
    "MEET YOUR MAKING (c00lkidd ~ 1x4 Vs 007n7 ~ Shedletsky)",
    "A Creation Of Sorrow (Hacklord vs The Heartbroken)",
    "Debth (Natrasha Vs Mafioso)",
    "ETERNAL HOPE, ETERNAL FIGHT (Old LMS)",
    "Receading Lifespan (Barber Jason Vs Bald Two Time)",
    "VIP Jason LMS (VIP Jason Vs All)",
    "Jason Hate This Song",
    "----------- Official LMS -----------",
    "A GRAVE SOUL (NOW, RUN) [All Killers Vs All Survivors]",
    "Plead (c00lkidd Vs 007n7)",
    "SMILE (Cupcakes Vs All)",
    "Vanity (Vanity Jason Vs All)",
    "Obsession (Gasharpoon Vs All)",
    "Burnout (Diva Vs Ghoul)",
    "Close To Me (Annihilation Vs Friend)",
    "Creation Of Hatred (1X4 Vs Shedletsky)",
    "Through Patches of Violet (Hacklord vs The Heartbroken)"
}

-- Globals
getgenv().currentLastSurvivor = nil
getgenv().currentSongId = nil
getgenv().originalSongId = nil
getgenv().isPlaying = false
getgenv().songStartTime = 0
getgenv().currentSongDuration = 0
getgenv().isToggleOn = false

-- Download track function
function downloadTrack(name, audioUrl)
    local fullPath = folderPath .. "/" .. name:gsub("[^%w]", "_") .. ".mp3"

    if not isfile(fullPath) then
        local request = http_request or syn.request or request
        if not request then error("Executor does not support HTTP requests.") end

        local response = request({
            Url = audioUrl,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Mozilla/5.0",
                ["Accept"] = "*/*"
            }
        })

        -- Try BodyRaw if Body is empty
        local fileData = response.Body
        if (not fileData or #fileData == 0) and response.BodyRaw then
            fileData = response.BodyRaw
        end

        if fileData and #fileData > 0 then
            writefile(fullPath, fileData)
        end
    end

    return fullPath
end

-- Get LastSurvivor function
function getLastSurvivor()
    local theme = workspace:FindFirstChild("Themes")
    if theme then
        return theme:FindFirstChild("LastSurvivor")
    end
    return nil
end

function setLastSurvivorSong(songName)
    local lastSurvivor = getLastSurvivor()
    if not lastSurvivor then return end
    local url = tracks[songName]
    if not url then return end

    local path = downloadTrack(songName, url)
    local soundAsset = getcustomasset(path)

    if getgenv().isToggleOn and not getgenv().originalSongId then
        getgenv().originalSongId = lastSurvivor.SoundId
    end

    lastSurvivor.SoundId = soundAsset
    lastSurvivor.Loaded:Wait()      -- <--- chờ Sound load xong
    getgenv().currentSongDuration = lastSurvivor.TimeLength
    lastSurvivor:Play()

    getgenv().songStartTime = tick()
    getgenv().isPlaying = true
    getgenv().currentLastSurvivor = lastSurvivor
end


-- GUI Section
local LMSGroup = Tabs.Miscs:AddRightGroupbox("Last Man Standing")

LMSGroup:AddToggle("LMS_Toggle", {
    Text = "LMS Replacer Song",
    Default = false,
    Callback = function(value)
        getgenv().isToggleOn = value

        local lastSurvivor = getLastSurvivor()
        if not value then
            -- Reset về bài hát gốc
            if lastSurvivor and getgenv().originalSongId then
                lastSurvivor.SoundId = getgenv().originalSongId
                lastSurvivor:Play()
            end
            -- Reset globals
            getgenv().currentLastSurvivor = nil
            getgenv().currentSongId = nil
            getgenv().originalSongId = nil
            getgenv().isPlaying = false
        end
    end,
})

-- Dropdown LMS song
LMSGroup:AddDropdown("CustomLMSSong", {
    Text = "Custom LMS Song",
    Values = options,
    Default = "None",
    Callback = function(selected)
        getgenv().selectedSong = selected
    end,
})

-- Heartbeat loop
RunService.Heartbeat:Connect(function()
    if getgenv().isToggleOn and not getgenv().isPlaying and getLastSurvivor() then
        setLastSurvivorSong(getgenv().selectedSong)
    elseif not getLastSurvivor() and getgenv().isPlaying then
            getgenv().isPlaying = false
        end

    if getgenv().isPlaying and lastSurvivor then
        if tick() - getgenv().songStartTime >= getgenv().currentSongDuration then
            getgenv().isPlaying = false
        end
    end
end)

-- Input box cho LMS custom
LMSGroup:AddInput("CustomLMSSongURL", {
    Text = "Custom LMS Song URL",
    Placeholder = "Raw Link MP3",
    Callback = function(input)
        if input and input ~= "" then
            getgenv().customSongUrl = input

            local lastSurvivor = getLastSurvivor()
            if lastSurvivor and getgenv().isToggleOn then
                -- Nếu toggle đang bật, set bài nhạc mới ngay lập tức
                local path = downloadTrack("Custom_LMS_Song", getgenv().customSongUrl)
                local soundAsset = getcustomasset(path)

                if not getgenv().originalSongId then
                    getgenv().originalSongId = lastSurvivor.SoundId
                end

                lastSurvivor.SoundId = soundAsset
                lastSurvivor.Loaded:Wait()
                lastSurvivor:Play()

                getgenv().songStartTime = tick()
                getgenv().currentSongDuration = lastSurvivor.TimeLength
                getgenv().isPlaying = true
                getgenv().currentLastSurvivor = lastSurvivor
            end
        end
    end,
})

-- Sử dụng getgenv() để lưu biến toàn cục
getgenv().chatWindow = game:GetService("TextChatService"):WaitForChild("ChatWindowConfiguration")
getgenv().chatEnabled = false
getgenv().connection = nil

local ChatGroup = Tabs.Miscs:AddRightGroupbox("Chat")
ChatGroup:AddToggle("ChatWindowToggle", {
    Text = "Toggle Chat Visibility",
    Default = false,
    Callback = function(value)
        getgenv().chatEnabled = value
        if getgenv().chatEnabled then
            -- Kết nối Heartbeat để bật liên tục
            getgenv().connection = game:GetService("RunService").Heartbeat:Connect(function()
                getgenv().chatWindow.Enabled = true
            end)
        else
            -- Ngắt kết nối Heartbeat khi toggle tắt
            if getgenv().connection then
                getgenv().connection:Disconnect()
                getgenv().connection = nil
            end
            -- Tắt chat window khi toggle off
            getgenv().chatWindow.Enabled = false
        end
    end
})

-- ==== ACHIEVEMENTS SECTION ====
local FunGroup = Tabs.AchieveTab:AddLeftGroupbox("Fun")

local function unlock(achieve)
   local remote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
   remote:FireServer("UnlockAchievement", achieve)
end

FunGroup:AddButton({
    Text = "[.] (Meet ogologl's best friend for the first time)",
    Func = function() unlock("MeetBrandon") end,
})

FunGroup:AddButton({
    Text = "[Meow meow meow] (Interact with the cat in the lobby more than 15 times)",
    Func = function() unlock("ILoveCats") end,
})

FunGroup:AddButton({
    Text = "[Coming straight from YOUR house.] (??? - I Love TV)",
    Func = function() unlock("TVTIME") end,
})

FunGroup:AddButton({
    Text = "[A Captain and his Ship] (Hear his tale)",
    Func = function() unlock("MeetDemophon") end,
})

local roundtime
local positionSet = false -- Để biết đã chỉnh X scale chưa

-- Hàm chỉnh position X scale thêm 0.39 một lần
local function adjustPosition()
    if roundtime and not positionSet then
        roundtime.Position = UDim2.new(
            roundtime.Position.X.Scale + 0.39,
            roundtime.Position.X.Offset,
            roundtime.Position.Y.Scale,
            roundtime.Position.Y.Offset
        )
        positionSet = true -- Đánh dấu đã chỉnh
    end
end

-- Loop check cho đến khi tìm thấy
task.spawn(function()
    while not roundtime do
        roundtime = player:FindFirstChild("PlayerGui")
            and player.PlayerGui:FindFirstChild("RoundTimer")
            and player.PlayerGui.RoundTimer:FindFirstChild("Main")
        task.wait(0.1)
    end

    -- Lần đầu chỉnh
    adjustPosition()

    -- Loop giữ nguyên vị trí
    while roundtime do
        roundtime.Position = UDim2.new(
            roundtime.Position.X.Scale,
            roundtime.Position.X.Offset,
            roundtime.Position.Y.Scale,
            roundtime.Position.Y.Offset
        )
        task.wait(0.5) -- refresh mỗi 0.5 giây
    end
end)

-- Global environment
genv = {}
genv.running = false
genv.animTrack = nil
genv.toggleValue = false

-- Get character & humanoid safely
function genv.getCharacterHumanoid()
    local character = game:GetService("Players").LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return character, humanoid
end

-- Get or create animator safely
function genv.getAnimator(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    return animator
end

-- Handle toggle
function genv.handleToggle(enabled)
    genv.running = enabled

    -- Stop animation & reset transparency if disabling
    if not enabled and genv.animTrack then
        genv.animTrack:Stop()
        genv.animTrack = nil
    end

    local character, _ = genv.getCharacterHumanoid()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Transparency = enabled and rootPart.Transparency or 1
    end
end

-- Survivor check & auto toggle
local survivorValue = playerData:WaitForChild("Equipped"):WaitForChild("Survivor")

function genv.updateToggle()
    local character, humanoid = genv.getCharacterHumanoid()
    local isTarget = (survivorValue.Value == "007n7" or survivorValue.Value == "Noob" or survivorValue.Value == "TwoTime") and humanoid and humanoid.MaxHealth < 300
    genv.handleToggle(isTarget)
end

-- Rayfield Combat UI
local InvisibleGroup = Tabs.Combat:AddLeftGroupbox("Invisible Effect")

-- Toggle thủ công
InvisibleGroup:AddToggle("InvisibleToggle", {
    Text = "Fully Invisible (Invisible Effect)",
    Default = false,
    Callback = function(Value)
        genv.toggleValue = Value
        if Value then
            genv.updateToggle()
        else
            genv.handleToggle(false)
        end
    end
})

-- Update when Survivor changes
survivorValue:GetPropertyChangedSignal("Value"):Connect(function()
    if genv.toggleValue then
        genv.updateToggle()
    end
end)

-- Auto-update on respawn
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
    -- Small delay to ensure character exists
    task.wait(0.1)
    if genv.toggleValue then
        genv.updateToggle()
    end
end)

-- Main loop using RunService.Heartbeat
RunService.Heartbeat:Connect(function()
    if not genv.running then return end

    local character, humanoid = genv.getCharacterHumanoid()
    if not character or not humanoid then return end

    local animator = genv.getAnimator(humanoid)
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local status = game:GetService("Players").LocalPlayer.PlayerGui.MainUI.StatusContainer:FindFirstChild("Invisibility")

    if humanoid.MaxHealth < 300 and torso and torso.Transparency ~= 0 and status then
        if not genv.animTrack or not genv.animTrack.IsPlaying then
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://75804462760596"
            genv.animTrack = animator:LoadAnimation(animation)
            genv.animTrack.Looped = true
            genv.animTrack:Play(0) -- blendTime = 0 để tránh chuyển động mượt quay lại idle
            genv.animTrack:AdjustSpeed(0)
            genv.animTrack.TimePosition = 0 -- cố định frame đầu
            if rootPart then
                rootPart.Transparency = 0.4
            end
        end
    else
        if genv.animTrack and genv.animTrack.IsPlaying then
            genv.animTrack:Stop(0) -- dừng ngay
            genv.animTrack = nil
            if rootPart then
                rootPart.Transparency = 1
            end
        end
    end
end)
-- Hàm lấy danh sách emote từ Purchased.Emotes
local function getEmoteList()
    local list = {}
    for _, emote in ipairs(purchasedEmotesFolder:GetChildren()) do
        table.insert(list, emote.Name)
    end
    return list
end

--==================== GUI 1 (Dropdown) ====================--
local emoteList = getEmoteList()
local selectedEmote = emoteList[1]

local emoteGuiMain = Instance.new("ScreenGui")
emoteGuiMain.Name = "CustomEmoteGuiMain"
emoteGuiMain.ResetOnSpawn = false
emoteGuiMain.DisplayOrder = 999998
emoteGuiMain.Enabled = false
emoteGuiMain.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local emoteGuiToggle = Instance.new("ScreenGui")
emoteGuiToggle.Name = "CustomEmoteGuiToggle"
emoteGuiToggle.ResetOnSpawn = false
emoteGuiToggle.DisplayOrder = 999999
emoteGuiToggle.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local toggleEmoteGuiButton = Instance.new("ImageButton")
toggleEmoteGuiButton.Size = UDim2.new(0, 60, 0, 60)
toggleEmoteGuiButton.Position = UDim2.new(0.05, 340, 0.05, -47.5)
toggleEmoteGuiButton.AnchorPoint = Vector2.new(0.5, 0.5)
toggleEmoteGuiButton.BackgroundTransparency = 1
toggleEmoteGuiButton.Image = "rbxassetid://73335752800725"
toggleEmoteGuiButton.ZIndex = 999999
toggleEmoteGuiButton.Parent = emoteGuiToggle

local survivorValue = playerData:WaitForChild("Equipped"):WaitForChild("Survivor")
local guiVisible = false

local function updateToggle()
    local isTarget = survivorValue.Value == "007n7"
    emoteGuiToggle.Enabled = isTarget
    if not isTarget then
        emoteGuiMain.Enabled = false
        guiVisible = false
    end
end
updateToggle()
survivorValue:GetPropertyChangedSignal("Value"):Connect(updateToggle)

local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0, 160, 0, 36)
playButton.Position = UDim2.new(1, -204, 0, 150)
playButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
playButton.TextColor3 = Color3.new(1,1,1)
playButton.Font = Enum.Font.SourceSans
playButton.TextSize = 18
playButton.Text = "Boombox Clone (007n7)"
playButton.Parent = emoteGuiMain

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, 220, 0, 40)
dropdownFrame.Position = UDim2.new(1, -240, 0, 100)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Parent = emoteGuiMain

local dropdownButton = Instance.new("TextButton")
dropdownButton.Size = UDim2.new(1,0,1,0)
dropdownButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
dropdownButton.TextColor3 = Color3.new(1,1,1)
dropdownButton.Font = Enum.Font.SourceSans
dropdownButton.TextSize = 18
dropdownButton.Text = selectedEmote and ("Emote: "..selectedEmote) or "Chọn Emote"
dropdownButton.Parent = dropdownFrame

local emoteListFrame = Instance.new("ScrollingFrame")
emoteListFrame.Size = UDim2.new(1,0,0, math.clamp(#emoteList,1,8) * 30)
emoteListFrame.Position = UDim2.new(0,0,1,2)
emoteListFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
emoteListFrame.BorderSizePixel = 0
emoteListFrame.Visible = false
emoteListFrame.CanvasSize = UDim2.new(0,0,0, #emoteList * 30)
emoteListFrame.ScrollBarThickness = 6
emoteListFrame.Parent = dropdownFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = emoteListFrame

local function populateDropdown(list)
    for _, child in ipairs(emoteListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, name in ipairs(list) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 30)
        btn.Position = UDim2.new(0, 3, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Text = name
        btn.Parent = emoteListFrame
        btn.MouseButton1Click:Connect(function()
            selectedEmote = name
            dropdownButton.Text = "Emote: " .. name
            emoteListFrame.Visible = false
        end)
    end
    emoteListFrame.CanvasSize = UDim2.new(0,0,0, #list * 30)
    emoteListFrame.Size = UDim2.new(1,0,0, math.clamp(#list,1,8) * 30)
end
populateDropdown(emoteList)

dropdownButton.MouseButton1Click:Connect(function()
    emoteListFrame.Visible = not emoteListFrame.Visible
    if emoteListFrame.Visible then
        Remote:FireServer("StopEmote", "Animations", "0")
    end
end)

playButton.MouseButton1Click:Connect(function()
    if not selectedEmote then return end
    Remote:FireServer("PlayEmote", "Animations", selectedEmote)
    task.wait(0.001)
    Remote:FireServer("StopEmote", "Animations", selectedEmote)
    task.wait(0.001)
    Remote:FireServer("UseActorAbility", "Clone")
    emoteListFrame.Visible = false
end)

toggleEmoteGuiButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    emoteGuiMain.Enabled = guiVisible
    if not guiVisible then
        emoteListFrame.Visible = false
    end
end)

--==================== GUI 2 (Dropdown giống GUI 1) ====================--
local emotes2 = getEmoteList()

local screenGui2 = Instance.new("ScreenGui")
screenGui2.DisplayOrder = 999999
screenGui2.Name = "EmoteGUI2"
screenGui2.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
screenGui2.ResetOnSpawn = false
screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Bỏ background2, thay bằng Frame trong suốt để chứa dropdown và nút Play
local background2 = Instance.new("Frame")
background2.Size = UDim2.new(0, 260, 0, 100)
background2.Position = UDim2.new(0, 0, 0.203, 0)
background2.BackgroundTransparency = 1 -- trong suốt hẳn luôn
background2.BorderSizePixel = 0
background2.Visible = false
background2.Parent = screenGui2

-- Play button GUI 2
local playButton2 = Instance.new("TextButton")
playButton2.Size = UDim2.new(0, 160, 0, 36)
playButton2.Position = UDim2.new(0, 50, 0, 60)
playButton2.BackgroundColor3 = Color3.fromRGB(80,80,80)
playButton2.TextColor3 = Color3.new(1,1,1)
playButton2.Font = Enum.Font.SourceSans
playButton2.TextSize = 18
playButton2.Text = "Play Emote"
playButton2.Parent = background2

-- Dropdown GUI 2
local dropdownFrame2 = Instance.new("Frame")
dropdownFrame2.Size = UDim2.new(0, 220, 0, 40)
dropdownFrame2.Position = UDim2.new(0, 20, 0, 10)
dropdownFrame2.BackgroundColor3 = Color3.fromRGB(40,40,40)
dropdownFrame2.BorderSizePixel = 0
dropdownFrame2.Parent = background2

local dropdownButton2 = Instance.new("TextButton")
dropdownButton2.Size = UDim2.new(1,0,1,0)
dropdownButton2.BackgroundColor3 = Color3.fromRGB(60,60,60)
dropdownButton2.TextColor3 = Color3.new(1,1,1)
dropdownButton2.Font = Enum.Font.SourceSans
dropdownButton2.TextSize = 18
dropdownButton2.Text = emotes2[1] and ("Emote: "..emotes2[1]) or "Chọn Emote"
dropdownButton2.Parent = dropdownFrame2

local emoteListFrame2 = Instance.new("ScrollingFrame")
emoteListFrame2.Size = UDim2.new(1,0,0, math.clamp(#emotes2,1,8) * 30)
emoteListFrame2.Position = UDim2.new(0,0,1,2)
emoteListFrame2.BackgroundColor3 = Color3.fromRGB(50,50,50)
emoteListFrame2.BorderSizePixel = 0
emoteListFrame2.Visible = false
emoteListFrame2.CanvasSize = UDim2.new(0,0,0, #emotes2 * 30)
emoteListFrame2.ScrollBarThickness = 6
emoteListFrame2.Parent = dropdownFrame2

local listLayout2 = Instance.new("UIListLayout")
listLayout2.FillDirection = Enum.FillDirection.Vertical
listLayout2.SortOrder = Enum.SortOrder.LayoutOrder
listLayout2.Parent = emoteListFrame2

-- Selected emote GUI 2
local selectedEmote2 = emotes2[1]

local function populateDropdown2(list)
	for _, child in ipairs(emoteListFrame2:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, name in ipairs(list) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -6, 0, 30)
		btn.Position = UDim2.new(0, 3, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 16
		btn.Text = name
		btn.Parent = emoteListFrame2
		btn.MouseButton1Click:Connect(function()
			selectedEmote2 = name
			dropdownButton2.Text = "Emote: " .. name
			emoteListFrame2.Visible = false
		end)
	end
	emoteListFrame2.CanvasSize = UDim2.new(0,0,0, #list * 30)
	emoteListFrame2.Size = UDim2.new(1,0,0, math.clamp(#list,1,8) * 30)
end
populateDropdown2(emotes2)

dropdownButton2.MouseButton1Click:Connect(function()
	emoteListFrame2.Visible = not emoteListFrame2.Visible
	if emoteListFrame2.Visible then
		Remote:FireServer("StopEmote", "Animations", "0")
	end
end)

playButton2.MouseButton1Click:Connect(function()
	if not selectedEmote2 then return end
	Remote:FireServer("PlayEmote", "Animations", selectedEmote2)
end)

-- Toggle button GUI 2
local toggleButton2 = Instance.new("ImageButton")
toggleButton2.Size = UDim2.new(0, 60, 0, 60)
toggleButton2.Position = UDim2.new(0.05, 248, 0.05, -47.5)
toggleButton2.AnchorPoint = Vector2.new(0.5, 0.5)
toggleButton2.BackgroundTransparency = 1
toggleButton2.Image = "rbxassetid://87214736647237"
toggleButton2.Parent = screenGui2
toggleButton2.ZIndex = 200010

toggleButton2.MouseButton1Click:Connect(function()
	background2.Visible = not background2.Visible
	if background2.Visible then
		Remote:FireServer("StopEmote", "Animations", "0")
	end
end)


--==================== Auto Update ====================--
-- Auto update cả GUI 2
local function refreshAll()
	local newList = getEmoteList()
	emoteList = newList
	populateDropdown(newList) -- GUI 1
	populateDropdown2(newList) -- GUI 2
	if #newList > 0 then
		selectedEmote = selectedEmote or newList[F1]
		selectedEmote2 = selectedEmote2 or newList[1]
		dropdownButton.Text = "Emote: " .. selectedEmote
		dropdownButton2.Text = "Emote: " .. selectedEmote2
	else
		selectedEmote = nil
		selectedEmote2 = nil
		dropdownButton.Text = "Choose Emote"
		dropdownButton2.Text = "Choose Emote"
	end
end

purchasedEmotesFolder.ChildAdded:Connect(refreshAll)
purchasedEmotesFolder.ChildRemoved:Connect(refreshAll)

Library:OnUnload(function()
print("Unloaded!")
end)

-- UI Settings
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
:AddKeyPicker("MenuKeybind", { Default = "K", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()
Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu
-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)
-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()
-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder("NyansakenHub")
SaveManager:SetFolder("NyansakenHub/specific-game")
-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs["UI Settings"])
-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs["UI Settings"])
-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
