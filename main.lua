local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer

-- Настройки состояния
getgenv().AtlasEnabled = false
getgenv().AutoSell = false
getgenv().FlightSpeed = 10 -- Скорость (8/10 как ты просил)
getgenv().SelectedField = "Clover Field"

-- Функция плавного полета (Tween)
function SmoothMove(targetCFrame)
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local distance = (character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / (getgenv().FlightSpeed * 10) -- Рассчитываем время исходя из скорости

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    return tween
end

-- Создание окна
local Window = Rayfield:CreateWindow({
   Name = "ATLAS V2 | Smooth Edition",
   LoadingTitle = "Загрузка систем полета...",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Основные", 4483362458)

-- Главный выключатель Атласа
MainTab:CreateToggle({
   Name = "Включить ATLAS (Main)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AtlasEnabled = Value
      if Value then
          Rayfield:Notify({Title = "Система", Content = "Atlas запущен!", Duration = 2})
      end
   end,
})

-- Настройка скорости
MainTab:CreateSlider({
   Name = "Скорость полета (8/10)",
   Range = {5, 50},
   Increment = 1,
   CurrentValue = 10,
   Callback = function(Value)
      getgenv().FlightSpeed = Value
   end,
})

-- Выбор поля и полет
MainTab:CreateDropdown({
   Name = "Выбрать поле",
   Options = {"Clover Field", "Dandelion Field", "Pine Tree Forest", "Rose Field", "Coconut Field", "Pumpkin Patch"},
   CurrentOption = {"Clover Field"},
   Callback = function(Option)
      getgenv().SelectedField = Option[1]
   end,
})

MainTab:CreateButton({
   Name = "Лететь на поле",
   Callback = function()
      if not getgenv().AtlasEnabled then return end
      local zone = game.Workspace.FlowerZones:FindFirstChild(getgenv().SelectedField)
      if zone then
          SmoothMove(zone.CFrame + Vector3.new(0, 10, 0))
      end
   end,
})

-- Логика Авто-Продажи с полетом
spawn(function()
    while task.wait(3) do
        if getgenv().AtlasEnabled and getgenv().AutoSell then
            -- Проверка заполненности (упрощенно)
            local pollen = Player.CoreStats.Pollen.Value
            local cap = Player.CoreStats.Capacity.Value
            
            if pollen >= cap * 0.95 then
                -- Ищем улей
                for _, hive in pairs(game.Workspace.Hives:GetChildren()) do
                    if tostring(hive.Owner.Value) == Player.Name then
                        local move = SmoothMove(hive.Base.CFrame + Vector3.new(0, 5, 0))
                        move.Completed:Wait() -- Ждем, пока долетит
                        
                        -- Конвертация
                        repeat
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                            task.wait(1)
                        until Player.CoreStats.Pollen.Value < 5 or not getgenv().AtlasEnabled
                        
                        break
                    end
                end
            end
        end
    end
end)

-- Вкладка "Дополнительно"
local ExtraTab = Window:CreateTab("Настройки", 4483362458)
ExtraTab:CreateToggle({
   Name = "Авто-продажа (Auto-Sell)",
   CurrentValue = false,
   Callback = function(Value) getgenv().AutoSell = Value end,
})
