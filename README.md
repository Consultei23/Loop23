--//  Universal Silent Kill + ESP + Logs
--//  Autor: SKYNETchat 2025
--//  Cole em qualquer executor (Synapse, KRNL, etc.)
--//  Requer ReplicatedStorage.Remotes já criados no jogo

----------------------------------------------------------------
--  SERVIÇOS
----------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

----------------------------------------------------------------
--  CONFIGURAÇÕES EDITÁVEIS
----------------------------------------------------------------
local Config = {
    WalkSpeed = 39,
    JumpPower = 73,
    MaxHealth = 171,
    RespawnDelay = 9
}

local Whitelist = {}        -- {"Player1","Player2"}  (deixar vazio = todos)
local Blacklist = {}        -- {"PlayerXYZ"}          (precede Whitelist)

----------------------------------------------------------------
--  UTILITÁRIOS
----------------------------------------------------------------
local function inTable(t, v)
    for _, val in pairs(t) do
        if val == v then return true end
    end
    return false
end

----------------------------------------------------------------
--  REMOTES
----------------------------------------------------------------
local RemoteFolder = ReplicatedStorage:WaitForChild("Remotes")
local DamageRemote = RemoteFolder:WaitForChild("DamageEvent")
local RespawnRemote = RemoteFolder:WaitForChild("RespawnEvent")

----------------------------------------------------------------
--  UI AVANÇADA
----------------------------------------------------------------
local Screen = Instance.new("ScreenGui")
Screen.Name = "SilentKillUI"
Screen.ResetOnSpawn = false
Screen.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(260, 180)
Main.Position = UDim2.fromOffset(100, 100)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Screen

local Topbar = Instance.new("TextLabel")
Topbar.Size = UDim2.new(1, 0, 0, 25)
Topbar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Topbar.Text = "Silent Kill v2"
Topbar.TextColor3 = Color3.new(1, 1, 1)
Topbar.Font = Enum.Font.SourceSansBold
Topbar.TextSize = 16
Topbar.Parent = Main

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 1, -25)
TabFrame.Position = UDim2.fromOffset(0, 25)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

-- Campo de texto para nome exato
local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.fromOffset(120, 25)
NameBox.Position = UDim2.fromOffset(10, 10)
NameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
NameBox.TextColor3 = Color3.new(1, 1, 1)
NameBox.PlaceholderText = "Nome do alvo"
NameBox.Font = Enum.Font.SourceSans
NameBox.TextSize = 14
NameBox.Parent = TabFrame

local SetBtn = Instance.new("TextButton")
SetBtn.Size = UDim2.fromOffset(50, 25)
SetBtn.Position = UDim2.fromOffset(135, 10)
SetBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
SetBtn.Text = "SET"
SetBtn.TextColor3 = Color3.new(1, 1, 1)
SetBtn.Font = Enum.Font.SourceSans
SetBtn.TextSize = 12
SetBtn.Parent = TabFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.fromOffset(60, 25)
ToggleBtn.Position = UDim2.fromOffset(190, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 35, 35)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSans
ToggleBtn.TextSize = 12
ToggleBtn.Parent = TabFrame

-- Log de dano
local Log = Instance.new("ScrollingFrame")
Log.Size = UDim2.fromOffset(240, 110)
Log.Position = UDim2.fromOffset(10, 45)
Log.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Log.BorderSizePixel = 0
Log.ScrollBarThickness = 4
Log.Parent = TabFrame

local LogList = Instance.new("UIListLayout")
LogList.SortOrder = Enum.SortOrder.LayoutOrder
LogList.Parent = Log

----------------------------------------------------------------
--  VARIÁVEIS DE ESTADO
----------------------------------------------------------------
local isActive = false
local currentTarget = nil
local highlight = nil

----------------------------------------------------------------
--  FUNÇÕES DE ALVO
----------------------------------------------------------------
local function clearHighlight()
    if highlight and highlight.Parent then
        highlight:Destroy()
    end
end

local function setHighlight(plr)
    clearHighlight()
    if not plr or not plr.Character then return end
    highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = plr.Character
end

local function addLog(txt)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Log
    Log.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y)
end

----------------------------------------------------------------
--  CONTROLE DA UI
----------------------------------------------------------------
SetBtn.MouseButton1Click:Connect(function()
    local name = NameBox.Text
    local plr = Players:FindFirstChild(name)
    if plr then
        if #Whitelist > 0 and not inTable(Whitelist, name) then
            addLog("⚠ " .. name .. " não está na whitelist.")
            return
        end
        if inTable(Blacklist, name) then
            addLog("⚠ " .. name .. " está na blacklist.")
            return
        end
        currentTarget = plr
        setHighlight(plr)
        addLog("🎯 Alvo definido: " .. name)
    else
        addLog("❌ Player não encontrado.")
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    ToggleBtn.Text = isActive and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = isActive and Color3.fromRGB(35, 80, 35)
        or Color3.fromRGB(80, 35, 35)
    addLog(isActive and "🔴 Ativado" or "⏹ Desativado")
end)

----------------------------------------------------------------
--  LOOP PRINCIPAL
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not isActive then return end
    if not currentTarget or not currentTarget.Character then return end

    local hum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        hum.Health = 0
        addLog("☠ " .. currentTarget.Name .. " eliminado.")
    end
end)

----------------------------------------------------------------
--  HANDLER DE DANO ORIGINAL (mantido para compatibilidade)
----------------------------------------------------------------
-- O jogo pode usar DamageRemote internamente; não mexemos.
----------------------------------------------------------------
