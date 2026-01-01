--[[
    AURORA SOON - BSS ULTIMATE (FLIGHT & CONVERT)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- // КОНФИГУРАЦИЯ //
getgenv().Config = {
    Enabled = false,
    AutoDig = false,
    CollectTokens = false,
    AutoConvert = false,
    FlightSpeed = 30,
    SelectedField = "Clover Field",
    Webhook = "https://discord.com/api/webhooks/1274243292011298959/oRJnfq3plUGNIsudT6QU-6a5ELAS_CRQcJ26dIgpTVU92_MeUYMdwxjRfN8jW6zlD1Bo"
}

-- // ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ //
local function GetPollenInfo()
    local core = Player:FindFirstChild("CoreStats")
    if core then
        return core.Pollen.Value, core.Capacity.Value
    end
    return 0, 100
end

local function FlyTo(targetPos)
    local distance = (HRP.Position - targetPos).Magnitude
    local duration = distance / getgenv().Config.FlightSpeed
    local tween = game:GetService("TweenService"):Create(HRP, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    return tween
end

-- // ЛОГИКА АВТО-УДАРОВ (БЬЕТ ПАЛКОЙ) //
spawn(function()
    while task.wait(0.01) do
        if getgenv().Config.Enabled and getgenv().Config.AutoDig then
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then 
                tool:Activate() -- Бьет палкой
                -- Принудительный клик для некоторых инструментов
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
            end
        end
    end
end)

-- // МАГНИТ ТОКЕНОВ (МГНОВЕННЫЙ СБОР) //
spawn(function()
    while task.wait(0.01) do
        if getgenv().Config.Enabled and getgenv().Config.CollectTokens then
            for _, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                if v:IsA("Part") and (v.Position - HRP.Position).Magnitude < 50 then
                    v.CFrame = HRP.CFrame -- Притягивает к персонажу
                end
            end
        end
    end
end)

-- // ГЛАВНЫЙ ЦИКЛ: ПОЛЕТ, ФАРМ И КОНВЕРТАЦИЯ //
spawn(function()
    while task.wait(0.5) do
        if getgenv().Config.Enabled then
            local pollen, cap = GetPollenInfo()
            
            -- Проверка на заполнение рюкзака
            if getgenv().Config.AutoConvert and pollen >= cap then
                -- Летим к улью
                for _, hive in pairs(game.Workspace.Hives:GetChildren()) do
                    if tostring(hive.Owner.Value) == Player.Name then
                        local toHive = FlyTo(hive.Base.Position + Vector3.new(0, 10, 0))
                        toHive.Completed:Wait()
                        
                        -- Ждем конвертации
                        repeat
                            task.wait(1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                        until Player.CoreStats.Pollen.Value <= 0 or not getgenv().Config.Enabled
                        break
                    end
                end
            else
                -- Обычный фарм на поле (Летаем хаотично)
                local zone = game.Workspace.FlowerZones:FindFirstChild(getgenv().Config.SelectedField)
                if zone then
                    local size = zone.Size
                    local randX = math.random(-size.X/2.5, size.X/2.5)
                    local randZ = math.random(-size.Z/2.5, size.Z/2.5)
                    local goal = (zone.CFrame * CFrame.new(randX, 0, randZ)).Position
                    
                    local move = FlyTo(goal)
                    move.Completed:Wait()
                end
            end
        end
    end
end)

-- // ИНТЕРФЕЙС //
local Window = Rayfield:CreateWindow({
    Name = "AuroraSoon | BSS V4",
    LoadingTitle = "Smooth Flight Engine",
})

local MainTab = Window:CreateTab("Главная", 4483362458)

MainTab:CreateToggle({
    Name = "Включить Атлас",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.Enabled = v end
})

MainTab:CreateToggle({
    Name = "Авто-Конвертация (Улей)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoConvert = v end
})

MainTab:CreateToggle({
    Name = "Бить палкой (Dig)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoDig = v end
})

MainTab:CreateToggle({
    Name = "Магнит жетонов",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.CollectTokens = v end
})

MainTab:CreateSlider({
    Name = "Скорость полета (1-10)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) getgenv().Config.FlightSpeed = v * 10 end
})

MainTab:CreateDropdown({
    Name = "Выбор Поля",
    Options = {"Clover Field", "Dandelion Field", "Pine Tree Forest", "Rose Field", "Coconut Field", "Spider Field"},
    CurrentOption = {"Clover Field"},
    Callback = function(v) getgenv().Config.SelectedField = v[1] end
})

Rayfield:Notify({Title = "AuroraSoon V4", Content = "Скрипт полностью обновлен! Авто-конверт добавлен.", Duration = 5})
