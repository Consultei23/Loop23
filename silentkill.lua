-- silentkill.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local target, active, highlight = nil, false, nil

local Screen = Instance.new("ScreenGui")
Screen.Name = "SilentKill"
Screen.ResetOnSpawn = false
Screen.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size, Main.Position = UDim2.fromOffset(220, 130), UDim2.fromOffset(40, 40)
Main.BackgroundColor3, Main.BorderSizePixel = Color3.fromRGB(25, 25, 25), 0
Main.Active, Main.Draggable = true, true
Main.Parent = Screen

local Top = Instance.new("TextLabel")
Top.Size, Top.BackgroundColor3 = UDim2.new(1, 0, 0, 20), Color3.fromRGB(40, 40, 40)
Top.Text, Top.TextColor3, Top.Font, Top.TextSize = "Silent Kill", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16
Top.Parent = Main

local Box = Instance.new("TextBox")
Box.Size, Box.Position = UDim2.fromOffset(90, 25), UDim2.fromOffset(10, 30)
Box.BackgroundColor3, Box.PlaceholderText, Box.Font = Color3.fromRGB(35, 35, 35), "Nome", Enum.Font.SourceSans
Box.TextColor3, Box.TextSize = Color3.new(1, 1, 1), 14
Box.Parent = Main

local Set = Instance.new("TextButton")
Set.Size, Set.Position = UDim2.fromOffset(40, 25), UDim2.fromOffset(105, 30)
Set.BackgroundColor3, Set.Text, Set.Font = Color3.fromRGB(55, 55, 55), "SET", Enum.Font.SourceSans
Set.TextColor3, Set.TextSize = Color3.new(1, 1, 1), 12
Set.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Size, Toggle.Position = UDim2.fromOffset(55, 25), UDim2.fromOffset(150, 30)
Toggle.BackgroundColor3, Toggle.Text, Toggle.Font = Color3.fromRGB(70, 25, 25), "OFF", Enum.Font.SourceSans
Toggle.TextColor3, Toggle.TextSize = Color3.new(1, 1, 1), 12
Toggle.Parent = Main

local Log = Instance.new("ScrollingFrame")
Log.Size, Log.Position = UDim2.fromOffset(200, 70), UDim2.fromOffset(10, 60)
Log.BackgroundColor3, Log.BorderSizePixel, Log.ScrollBarThickness = Color3.fromRGB(30, 30, 30), 0, 4
Log.Parent = Main

local List = Instance.new("UIListLayout")
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Log

local function msg(m)
    local lbl = Instance.new("TextLabel")
    lbl.Size, lbl.BackgroundTransparency = UDim2.new(1, 0, 0, 16), 1
    lbl.Text, lbl.TextColor3, lbl.Font, lbl.TextSize = m, Color3.new(1, 1, 1), Enum.Font.SourceSans, 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Log
    Log.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
end

local function clearHL() if highlight and highlight.Parent then highlight:Destroy() end end
local function addHL(char)
    clearHL()
    if not char then return end
    highlight = Instance.new("Highlight")
    highlight.FillTransparency, highlight.OutlineColor, highlight.DepthMode = 0.5, Color3.fromRGB(255, 0, 0), Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
end

Set.MouseButton1Click:Connect(function()
    local nome, plr = Box.Text, Players:FindFirstChild(Box.Text)
    if plr then target, addHL(plr.Character), msg("🎯 " .. nome) else msg("❌ não achado") end
end)

Toggle.MouseButton1Click:Connect(function()
    active = not active
    Toggle.Text = active and "ON" or "OFF"
    Toggle.BackgroundColor3 = active and Color3.fromRGB(25, 70, 25) or Color3.fromRGB(70, 25, 25)
    msg(active and "🔴 Ativado" or "⏹ Desativado")
end)

RunService.Heartbeat:Connect(function()
    if not (active and target and target.Character) then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then hum.Health = 0; msg("☠ " .. target.Name) end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char) if plr == target then addHL(char) end end)
end)

msg("✅ carregado")

