--[[
    AURORA BSS - PROFESSIONAL SCRIPT
    Функции: Полет, Бег по полю, Магнит, Авто-Конверт
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
    Speed = 30,
    SelectedField = "Clover Field"
}

-- // СИСТЕМА ПЛАВНОГО ПОЛЕТА //
local function FlyTo(targetPos)
    local distance = (HRP.Position - targetPos).Magnitude
    local duration = distance / getgenv().Config.Speed
    local tween = game:GetService("TweenService"):Create(HRP, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    return tween
end

-- // ЛОГИКА АВТО-УДАРОВ (DIG) //
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

-- // МАГНИТ ЖЕТОНОВ //
spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.Enabled and getgenv().Config.CollectTokens then
            for _, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                if v:IsA("Part") and (v.Position - HRP.Position).Magnitude < 60 then
                    v.CFrame = HRP.CFrame
                end
            end
        end
    end
end)

-- // ГЛАВНЫЙ ЦИКЛ ФАРМА //
spawn(function()
    while task.wait(0.5) do
        if getgenv().Config.Enabled then
            local pollen = Player.CoreStats.Pollen.Value
            local cap = Player.CoreStats.Capacity.Value
            
            -- Проверка на заполнение рюкзака
            if getgenv().Config.AutoConvert and pollen >= cap then
                -- Летим к улью
                for _, hive in pairs(game.Workspace.Hives:GetChildren()) do
                    if tostring(hive.Owner.Value) == Player.Name then
                        FlyTo(hive.Base.Position + Vector3.new(0, 10, 0)).Completed:Wait()
                        -- Ждем конвертации
                        repeat
                            task.wait(1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                        until Player.CoreStats.Pollen.Value <= 0 or not getgenv().Config.Enabled
                        break
                    end
                end
            else
                -- Процесс фарма на поле
                local zone = game.Workspace.FlowerZones:FindFirstChild(getgenv().Config.SelectedField)
                if zone then
                    -- Если далеко - летим к полю
                    if (HRP.Position - zone.Position).Magnitude > 50 then
                        FlyTo(zone.Position + Vector3.new(0, 5, 0)).Completed:Wait()
                    end
                    
                    -- Бегаем ногами по полю в случайные точки
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

-- // ИНТЕРФЕЙС //
local Window = Rayfield:CreateWindow({
    Name = "Aurora BSS | Ultimate",
    LoadingTitle = "Загрузка систем Atlas...",
})

local Tab = Window:CreateTab("Фарм", 4483362458)

Tab:CreateToggle({
    Name = "ВКЛЮЧИТЬ АВТОФАРМ",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.Enabled = v end
})

Tab:CreateToggle({
    Name = "Бить палкой (Auto-Dig)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoDig = v end
})

Tab:CreateToggle({
    Name = "Собирать токены (Magnet)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.CollectTokens = v end
})

Tab:CreateToggle({
    Name = "Авто-Конвертация (Улей)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoConvert = v end
})

Tab:CreateDropdown({
    Name = "Выбор Поля",
    Options = {"Clover Field", "Dandelion Field", "Pine Tree Forest", "Rose Field", "Coconut Field", "Spider Field", "Strawberry Field"},
    CurrentOption = {"Clover Field"},
    Callback = function(v) getgenv().Config.SelectedField = v[1] end
})

Rayfield:Notify({Title = "Aurora BSS", Content = "Скрипт успешно запущен!", Duration = 5})
