-- Ejemplo seguro: panel cosmético con Obsidian + icono flotante
local Obsidian = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()

-- Crear GUI local (solo cosmetic)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XRNL_CosmeticGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.5, -80)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Parent = screenGui
frame.Visible = false

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 40)
label.Position = UDim2.new(0,10,0,10)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255,255,255)
label.Text = "XRNL • Cosmeticos (solo local)"
label.TextScaled = true
label.Parent = frame

-- Slider para "brillo" local de la cámara (solo efecto visual en cliente)
local cam = workspace.CurrentCamera
local sliderLabel = Instance.new("TextLabel", frame)
sliderLabel.Size = UDim2.new(1, -20, 0, 28)
sliderLabel.Position = UDim2.new(0,10,0,60)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(200,200,200)
sliderLabel.Text = "Exposición (solo cliente): 1.0"

local function setExposure(v)
    pcall(function()
        if cam and cam:FindFirstChildOfClass("BloomEffect") == nil then
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "XRNL_Bloom"
            bloom.Intensity = v - 1
            bloom.Parent = cam
        else
            local b = cam:FindFirstChild("XRNL_Bloom")
            if b then b.Intensity = v - 1 end
        end
    end)
end

-- Slider visual simple (no depende de Obsidian)
local slider = Instance.new("TextBox", frame)
slider.Size = UDim2.new(1, -20, 0, 28)
slider.Position = UDim2.new(0,10,0,95)
slider.Text = "1.0"
slider.PlaceholderText = "0.5 - 3.0"
slider.ClearTextOnFocus = false
slider.FocusLost:Connect(function(enter)
    local v = tonumber(slider.Text)
    if v and v >= 0.5 and v <= 3 then
        sliderLabel.Text = "Exposición (solo cliente): "..tostring(v)
        setExposure(v)
    else
        slider.Text = "1.0"
    end
end)

-- Icono flotante cuadrado movible (para móvil)
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "XRNL_FloatIcon"
iconGui.ResetOnSpawn = false
iconGui.Parent = game.Players.LocalPlayer:PlayerGui

local icon = Instance.new("Frame", iconGui)
icon.Size = UDim2.new(0,50,0,50)
icon.Position = UDim2.new(0.88,0,0.12,0)
icon.AnchorPoint = Vector2.new(0.5,0.5)
icon.BackgroundColor3 = Color3.fromRGB(30,30,30)
local corner = Instance.new("UICorner", icon); corner.CornerRadius = UDim.new(0,8)

local btn = Instance.new("TextButton", icon)
btn.Size = UDim2.fromScale(1,1)
btn.BackgroundTransparency = 1
btn.Text = "▣"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 26
btn.TextColor3 = Color3.fromRGB(255,255,255)

local dragging = false
local dragInput, dragStart, startPos

btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = icon.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
btn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
game:GetService("RunService").RenderStepped:Connect(function()
    if dragging and dragInput and dragStart then
        local delta = dragInput.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        local vx, vy = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
        newX = math.clamp(newX, 0, vx - icon.AbsoluteSize.X)
        newY = math.clamp(newY, 0, vy - icon.AbsoluteSize.Y)
        icon.Position = UDim2.new(0, newX, 0, newY)
    end
end)

btn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

print("Panel cosmético cargado (seguro).")
