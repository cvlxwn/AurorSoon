--[[
    AURORA SOON - BSS ULTIMATE (PRO VERSION)
    Webhook Integrated: https://discord.com/api/webhooks/1274243292011298959/...
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer

-- // КОНФИГУРАЦИЯ //
getgenv().Config = {
    Enabled = false,
    AutoDig = false,
    CollectTokens = false,
    WalkSpeed = 5,
    SelectedField = "Clover Field",
    Webhook = "https://discord.com/api/webhooks/1274243292011298959/oRJnfq3plUGNIsudT6QU-6a5ELAS_CRQcJ26dIgpTVU92_MeUYMdwxjRfN8jW6zlD1Bo"
}

-- // СИСТЕМА ЛОГИРОВАНИЯ (БАЗА ДАННЫХ) //
local function SendLog()
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = "🚀 AuroraSoon: Новый запуск!",
                ["color"] = 0x00FFAA,
                ["fields"] = {
                    {["name"] = "Никнейм", ["value"] = "```" .. Player.Name .. "```", ["inline"] = true},
                    {["name"] = "ID Игрока", ["value"] = "```" .. tostring(Player.UserId) .. "```", ["inline"] = true},
                    {["name"] = "Возраст аккаунта", ["value"] = Player.AccountAge .. " дней", ["inline"] = true},
                    {["name"] = "Мед (Honey)", ["value"] = tostring(Player.CoreStats.Honey.Value), ["inline"] = false}
                },
                ["footer"] = {["text"] = "AuroraSoon Logger System | " .. os.date("%X")}
            }}
        }
        local request = syn and syn.request or http_request or request
        if request then
            request({
                Url = getgenv().Config.Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end
    end)
end

-- Запускаем логгер при старте
SendLog()

-- // ЛОГИКА СБОРА ТОКЕНОВ //
spawn(function()
    while task.wait(0.01) do
        if getgenv().Config.Enabled and getgenv().Config.CollectTokens then
            pcall(function()
                for _, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                    if v:IsA("Part") then
                        -- Притягиваем все жетоны к персонажу
                        v.CFrame = Player.Character.HumanoidRootPart.CFrame
                    end
                end
            end)
        end
    end
end)

-- // ЛОГИКА БЕСКОНЕЧНОГО ТАПА (AUTO-DIG) //
spawn(function()
    while task.wait(0.05) do
        if getgenv().Config.Enabled and getgenv().Config.AutoDig then
            local tool = Player.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

-- // ПАТТЕРН ДВИЖЕНИЯ ПО ПОЛЮ //
spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.Enabled then
            local zone = game.Workspace.FlowerZones:FindFirstChild(getgenv().Config.SelectedField)
            if zone then
                for i = 1, 8 do
                    if not getgenv().Config.Enabled then break end
                    local angle = i * (math.pi * 2 / 8)
                    local x = math.cos(angle) * 18
                    local z = math.sin(angle) * 18
                    local targetPos = zone.CFrame * CFrame.new(x, 0, z)
                    
                    local dist = (Player.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude
                    local duration = dist / (getgenv().Config.WalkSpeed * 5)
                    
                    local tween = TweenService:Create(Player.Character.HumanoidRootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetPos})
                    tween:Play()
                    tween.Completed:Wait()
                end
            end
        end
    end
end)

-- // ГРАФИЧЕСКИЙ ИНТЕРФЕЙС //
local Window = Rayfield:CreateWindow({
    Name = "AuroraSoon | BSS Pro",
    LoadingTitle = "Atlas Engine V2",
})

local Tab = Window:CreateTab("Фарм", 4483362458)

Tab:CreateToggle({
    Name = "Включить Авто-Фарм",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.Enabled = v end
})

Tab:CreateToggle({
    Name = "Бесконечно копать (Dig)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.AutoDig = v end
})

Tab:CreateToggle({
    Name = "Магнит жетонов (Tokens)",
    CurrentValue = false,
    Callback = function(v) getgenv().Config.CollectTokens = v end
})

Tab:CreateSlider({
    Name = "Скорость движения",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) getgenv().Config.WalkSpeed = v end
})

Tab:CreateDropdown({
    Name = "Выбор поля",
    Options = {"Clover Field", "Dandelion Field", "Pine Tree Forest", "Rose Field", "Coconut Field", "Sunflower Field"},
    CurrentOption = {"Clover Field"},
    Callback = function(v) getgenv().Config.SelectedField = v[1] end
})

local StatsTab = Window:CreateTab("Статистика", 4483362458)
local HoneyLabel = StatsTab:CreateLabel("Твой мед: " .. tostring(Player.CoreStats.Honey.Value))

-- Обновление статистики в реальном времени
spawn(function()
    while task.wait(5) do
        HoneyLabel:Set("Твой мед: " .. tostring(Player.CoreStats.Honey.Value))
    end
end)

Rayfield:Notify({Title = "AuroraSoon", Content = "Данные отправлены на сервер. Скрипт готов!", Duration = 5})
