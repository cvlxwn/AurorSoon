--[[
    AURORA SOON - BSS PRO V5 (REALISTIC RUN & FLY)
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
    Speed = 5,
    SelectedField = "Clover Field",
    Webhook = "https://discord.com/api/webhooks/1274243292011298959/oRJnfq3plUGNIsudT6QU-6a5ELAS_CRQcJ26dIgpTVU92_MeUYMdwxjRfN8jW6zlD1Bo"
}

-- // СИСТЕМА ПОЛЕТА (ДЛЯ ПЕРЕМЕЩЕНИЯ К ПОЛЮ/УЛЬЮ) //
local function FlyTo(targetPos)
    local distance = (HRP.Position - targetPos).Magnitude
    local speed = getgenv().Config.Speed * 10
    local tween = game:GetService("TweenService"):Create(HRP, TweenInfo.new(distance/speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    return tween
end

-- // ЛОГИКА АВТО-УДАРОВ (ПАЛКА) //
spawn(function()
    while task.wait(0.05) do
        if getgenv().Config.Enabled and getgenv().Config.AutoDig then
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then 
                tool:Activate()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
            end
        end
    end
end)

-- // МАГНИТ ЖЕТОНОВ (ОТДЕЛЬНАЯ ОПЦИЯ) //
spawn(function()
    while task.wait(0.01) do
        if getgenv().Config.Enabled and getgenv().Config.CollectTokens then
            for _, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                if v:IsA("Part") and (v.Position - HRP.Position).Magnitude < 60 then
                    v.CFrame = HRP.CFrame
                end
            end
        end
    end
end)

-- // ГЛАВНЫЙ ЦИКЛ ПЕРЕДВИЖЕНИЯ //
spawn(function()
    while task.wait(0.5) do
        if getgenv().Config.Enabled then
            local pollen = Player.CoreStats.Pollen.Value
            local cap = Player.CoreStats.Capacity.Value
            
            -- 1. ЕСЛИ РЮКЗАК ПОЛОН -> ЛЕТИМ К УЛЬЮ
            if getgenv().Config.AutoConvert and pollen >= cap then
                for _, hive in pairs(game.Workspace.Hives:GetChildren()) do
                    if tostring(hive.Owner.Value) == Player.Name then
                        FlyTo(hive.Base.Position + Vector3.new(0, 8, 0)).Completed:Wait()
                        repeat
                            task.wait(1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                        until Player.CoreStats.Pollen.Value <= 0 or not getgenv().Config.Enabled
                        break
                    end
                end
            else
                -- 2. ФАРМ НА ПОЛЕ
                local zone = game.Workspace.FlowerZones:FindFirstChild(getgenv().Config.SelectedField)
                if zone then
                    -- Если мы далеко от поля — летим к нему
                    if (HRP.Position - zone.Position).Magnitude > 50 then
                        FlyTo(zone.Position + Vector3.new(0, 5, 0)).Completed:Wait()
                    end
                    
                    -- Бегаем по полю (MoveTo)
                    Humanoid.WalkSpeed = 16 + (getgenv().Config.Speed * 5)
                    local size = zone.Size
                    local randX = math.random(-size.X/2.5, size.X/2.5)
                    local randZ = math.random(-size.Z/2.5, size.Z/2.5)
                    local goal = (zone.CFrame * CFrame.new(randX, 0, randZ)).Position
                    
                    Humanoid:MoveTo(goal)
                    Humanoid.MoveToFinished:Wait()
                end
            end
        end
    end
end)

-- // ГРАФИЧЕСКИЙ ИНТЕРФЕЙС //
local Window = Rayfield:CreateWindow({
    Name = "AuroraSoon | BSS Pro V5",
    LoadingTitle = "Atlas Engine v5",
})

local MainTab = Window:CreateTab("Главная", 4483362458)

MainTab:CreateToggle({
    Name = "ВКЛЮЧИТЬ ФАРМ",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.Enabled = v end
})

MainTab:CreateToggle({
    Name = "Бить палкой (Auto-Dig)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoDig = v end
})

MainTab:CreateToggle({
    Name = "Магнит жетонов (Tokens)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.CollectTokens = v end
})

MainTab:CreateToggle({
    Name = "Авто-Конверт (Улей)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoConvert = v end
})

MainTab:CreateSlider({
    Name = "Скорость (1-10)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) getgenv().Config.Speed = v end
})

MainTab:CreateDropdown({
    Name = "Выбрать поле",
    Options = {"Clover Field", "Dandelion Field", "Pine Tree Forest", "Rose Field", "Coconut Field", "Pumpkin Patch", "Spider Field", "Strawberry Field"},
    CurrentOption = {"Clover Field"},
    Callback = function(v) getgenv().Config.SelectedField = v[1] end
})

Rayfield:Notify({Title = "AuroraSoon V5", Content = "Скрипт загружен! Теперь он бегает ногами по полю.", Duration = 5})
