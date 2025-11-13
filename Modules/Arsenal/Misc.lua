getgenv().Misc = {
  Bhop = false,
  InstantRespawn = false,
  ThirdPerson = false
}

spawn(function()
    while true do
        wait()
        if getgenv().Misc.Bhop == true then
            game.Players.LocalPlayer.Character.Humanoid.Jump = true
        end
        if getgenv().Misc.InstantRespawn == true then
            if not game.Players.LocalPlayer.Character:FindFirstChild('Spawned') and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Cam") then
                if game.Players.LocalPlayer.PlayerGui.Menew.Enabled == false then
                    game:GetService("ReplicatedStorage").Events.LoadCharacter:FireServer()
                    wait()
                end
            end
        end
    end
end)

if getgenv().Misc.ThirdPerson then
    game:GetService("Players")["LocalPlayer"].PlayerGui.GUI.Client.Variables.thirdperson.Value = true
  else
    game:GetService("Players")["LocalPlayer"].PlayerGui.GUI.Client.Variables.thirdperson.Value = false
end
