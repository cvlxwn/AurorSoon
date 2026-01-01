--[[
    AURORA SOON - BSS ULTIMATE (FIXED MOVEMENT)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- // КОНФИГУРАЦИЯ //
getgenv().Config = {
    Enabled = false,
    AutoDig = false,
    CollectTokens = false,
    SpeedValue = 30, -- Стандартная скорость в Roblox - 16
    SelectedField = "Clover Field",
    Webhook = "https://discord.com/api/webhooks/1274243292011298959/oRJnfq3plUGNIsudT6QU-6a5ELAS_CRQcJ26dIgpTVU92_MeUYMdwxjRfN8jW6zlD1Bo"
}

-- // ЛОГИКА СБОРА ТОКЕНОВ (МАГНИТ) //
spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.Enabled and getgenv().Config.CollectTokens then
            pcall(function()
                for _, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                    if v:IsA("Part") then
                        local mag = (v.Position - Character.HumanoidRootPart.Position).Magnitude
                        if mag < 30 then -- Собираем в радиусе 30 шпилек
                            v.CFrame = Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        end
    end
end)

-- // ЛОГИКА УДАРОВ ПАЛКОЙ (AUTO-DIG) //
spawn(function()
    while task.wait(0.01) do
        if getgenv().Config.Enabled and getgenv().Config.AutoDig then
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

-- // ЛОГИКА УМНОГО ПЕРЕДВИЖЕНИЯ //
spawn(function()
    while task.wait(0.5) do
        if getgenv().Config.Enabled then
            local zone = game.Workspace.FlowerZones:FindFirstChild(getgenv().Config.SelectedField)
            if zone then
                -- Устанавливаем скорость
                Humanoid.WalkSpeed = getgenv().Config.SpeedValue
                
                -- Генерируем случайную точку внутри поля
                local size = zone.Size
                local randomX = math.random(-size.X/2.5, size.X/2.5)
                local randomZ = math.random(-size.Z/2.5, size.Z/2.5)
                local targetPos = (zone.CFrame * CFrame.new(randomX, 0, randomZ)).Position
                
                -- Идем к точке
                Humanoid:MoveTo(targetPos)
                
                -- Ждем пока дойдет или пока не выключим
                Humanoid.MoveToFinished:Wait()
            end
        end
    end
end)

-- // ИНТЕРФЕЙС //
local Window = Rayfield:CreateWindow({
    Name = "AuroraSoon | BSS Pro Fixed",
    LoadingTitle = "Atlas Engine V3",
})

local Tab = Window:CreateTab("Фарм", 4483362458)

Tab:CreateToggle({
    Name = "Включить Авто-Фарм",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.Enabled = v end
})

Tab:CreateToggle({
    Name = "Бить палкой (Auto-Dig)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoDig = v end
})

Tab:CreateToggle({
    Name = "Собирать все жетоны",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.CollectTokens = v end
})

Tab:CreateSlider({
    Name = "Скорость (1-10)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) 
        -- Преобразуем 1-10 в реальные значения скорости Roblox (16-80)
        getgenv().Config.SpeedValue = 16 + (v * 7)
        Humanoid.WalkSpeed = getgenv().Config.SpeedValue
    end
})

Tab:CreateDropdown({
    Name = "Поле",
    Options = {"Clover Field", "Dandelion Field", "Pine Tree Forest", "Rose Field", "Coconut Field", "Sunflower Field", "Spider Field"},
    CurrentOption = {"Clover Field"},
    Callback = function(v) getgenv().Config.SelectedField = v[1] end
})

Rayfield:Notify({Title = "AuroraSoon", Content = "Движение исправлено. Теперь персонаж бегает!", Duration = 5})
