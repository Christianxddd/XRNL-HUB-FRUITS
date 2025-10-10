-- XRNL - Blox Fruits Mega Exploit (usa RedzLibV5)
-- Cargador de la librería (tal como indicaste)
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzLibV5/main/Source.Lua"))()

local Window = redzlib:MakeWindow({
  Title = "XRNL • BloxF Exploit",
  SubTitle = "Mega Hub",
  SaveFolder = "XRNL_Config"
})

-- Variables globales/estados
_G.XRNL = _G.XRNL or {}
local state = {
    speed = 16,
    jump = 50,
    fly = false,
    flySpeed = 100,
    esp = false,
    autofarm = false,
    autoboss = false,
    targetDistance = 1000,
}

-- Utils
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function getChar()
    return LocalPlayer and LocalPlayer.Character
end

local function getHumanoid()
    local c = getChar()
    if c then return c:FindFirstChildOfClass("Humanoid") end
end

local function safeSetWalkSpeed(val)
    pcall(function()
        local h = getHumanoid()
        if h then h.WalkSpeed = val end
    end)
end

local function safeSetJump(val)
    pcall(function()
        local h = getHumanoid()
        if h then h.JumpPower = val end
    end)
end

-- Buscar NPCs comunes en Blox Fruits (heurística)
local function findNearestEnemy()
    local root = workspace
    local best, bestDist = nil, math.huge
    local myPos = getChar() and getChar():FindFirstChild("HumanoidRootPart") and getChar().HumanoidRootPart.Position
    if not myPos then return nil end

    for _, obj in pairs(root:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= getChar() then
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
            if hrp and obj:FindFirstChildOfClass("Humanoid").Health > 0 then
                local dist = (hrp.Position - myPos).Magnitude
                if dist < bestDist and dist <= state.targetDistance then
                    best = obj
                    bestDist = dist
                end
            end
        end
    end
    return best
end

-- ATTACK helper: intenta usar la herramienta equipada
local function tryAttack()
    local char = getChar()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool") or char:FindFirstChildWhichIsA("Tool", true)
    if tool then
        pcall(function()
            tool:Activate()
        end)
    else
        -- Si no hay herramienta, intenta simular click tool: invoke remotes is unreliable/unsafe
        -- Aquí intentamos simular Clicking con MouseClick (si está disponible en executor)
        pcall(function()
            local mt = getrawmetatable(game)
            -- No hacemos exploits peligrosos o illegales (remotes), así que dejamos como fallback vacío
        end)
    end
end

-- AUTO FARM loop
task.spawn(function()
    while task.wait(0.6) do
        if state.autofarm then
            local enemy = findNearestEnemy()
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    -- Teleport cerca del enemigo (offset 3 studs)
                    local hrp = getChar() and getChar():FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        task.wait(0.1)
                        tryAttack()
                        -- Repetir algunos ataques
                        for i=1,3 do
                            tryAttack()
                            task.wait(0.15)
                        end
                    end
                end)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- BOSS FARM loop (igual que autofarm pero busca mobs con "Boss" o mucha vida)
task.spawn(function()
    while task.wait(1) do
        if state.autoboss then
            local root = workspace
            local best
            local myPos = getChar() and getChar():FindFirstChild("HumanoidRootPart") and getChar().HumanoidRootPart.Position
            if not myPos then task.wait(1) goto continue end
            for _, obj in pairs(root:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 1000 then -- heurística: boss suele tener mucha vida
                        best = obj
                        break
                    elseif string.find(obj.Name:lower(),"boss") then
                        best = obj
                        break
                    end
                end
            end
            if best and best:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = getChar() and getChar():FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = best.HumanoidRootPart.CFrame * CFrame.new(0,0,6)
                        task.wait(0.2)
                        for i=1,10 do
                            tryAttack()
                            task.wait(0.2)
                        end
                    end
                end)
            end
        end
        ::continue::
    end
end)

-- FLY implementation (simple)
local flyConnection
local function startFly()
    if state.fly then return end
    state.fly = true
    local char = getChar()
    if not char then state.fly = false return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then state.fly = false return end
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVel.Velocity = Vector3.new(0,0,0)
    bodyVel.Parent = hrp
    flyConnection = RunService.Heartbeat:Connect(function()
        if not state.fly or not hrp or not hrp.Parent then
            if bodyVel and bodyVel.Parent then bodyVel:Destroy() end
            if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
            return
        end
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + workspace.CurrentCamera.CFrame.RightVector end
        move = Vector3.new(move.X,0,move.Z)
        local up = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then up = up - 1 end
        local finalVel = (move.Unit == move.Unit) and move.Unit * state.flySpeed or Vector3.new()
        finalVel = Vector3.new(finalVel.X, up * state.flySpeed * 0.6, finalVel.Z)
        bodyVel.Velocity = finalVel
    end)
end

local function stopFly()
    state.fly = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    local char = getChar()
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _,v in pairs(char.HumanoidRootPart:GetChildren()) do
            if v:IsA("BodyVelocity") then pcall(function() v:Destroy() end) end
        end
    end
end

-- ESP (players & NPCs) simple con Highlight
local espStore = {}
local function createESPForModel(model, color)
    if not model or not model.Parent then return end
    if model:FindFirstChild("XRNL_ESP") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "XRNL_ESP"
    highlight.Parent = model
    if color then
        pcall(function()
            highlight.FillColor = color
            highlight.OutlineColor = Color3.new(0,0,0)
        end)
    end
    return highlight
end

local function removeAllESP()
    for _, obj in pairs(espStore) do
        pcall(function() if obj and obj.Parent then obj:Destroy() end end)
    end
    espStore = {}
end

-- REDZ UI construction
-- Tabs: Main, Combat, Movement, AutoFarm, ESP, Teleports, Credits
local TabMain = Window:MakeTab({"Main", "home"})
local TabCombat = Window:MakeTab({"Combat", "fight"})
local TabMove = Window:MakeTab({"Movement", "move"})
local TabAF = Window:MakeTab({"AutoFarm", "farm"})
local TabESP = Window:MakeTab({"ESP", "see"})
local TabTP = Window:MakeTab({"Teleports", "tp"})
local TabCredits = Window:MakeTab({"Credits", "info"})

-- MAIN: quick toggles
TabMain:AddLabel("XRNL • Blox Fruits Mega Hub")
TabMain:AddButton({"Re-apply speed & jump", function()
    safeSetWalkSpeed(state.speed)
    safeSetJump(state.jump)
end})

TabMain:AddToggle({
    Name = "Anti-AFK (simple)",
    Description = "Mantenerte conectado (VirtualUser)",
    Default = false,
    Callback = function(v)
        if v then
            _G.XRNL.AntiAFK = true
            spawn(function()
                local vu = game:GetService("VirtualUser")
                while _G.XRNL.AntiAFK do
                    task.wait(50)
                    pcall(function()
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new(0,0))
                    end)
                end
            end)
        else
            _G.XRNL.AntiAFK = false
        end
    end
})

-- COMBAT
TabCombat:AddLabel("Combat utilities")
TabCombat:AddToggle({
    Name = "Auto Attack on Equip",
    Description = "Intenta activar la tool para atacar",
    Default = false,
    Callback = function(v) _G.XRNL.AutoAttack = v end
})
TabCombat:AddButton({"Manual Attack (tool:Activate)", function() tryAttack() end})

-- MOVEMENT
TabMove:AddLabel("Movement")
TabMove:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 500,
    Increase = 1,
    Default = 16,
    Callback = function(Value)
        state.speed = Value
        safeSetWalkSpeed(Value)
    end
})
TabMove:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Increase = 1,
    Default = 50,
    Callback = function(Value)
        state.jump = Value
        safeSetJump(Value)
    end
})
TabMove:AddToggle({
    Name = "Fly (W/A/S/D + Space/Ctrl)",
    Description = "Activar/Desactivar vuelo simple",
    Default = false,
    Callback = function(v)
        if v then
            startFly()
        else
            stopFly()
        end
    end
})
TabMove:AddSlider({
    Name = "Fly Speed",
    Min = 50,
    Max = 800,
    Increase = 10,
    Default = 100,
    Callback = function(v) state.flySpeed = v end
})

-- AUTOFARM
TabAF:AddLabel("AutoFarm")
TabAF:AddToggle({
    Name = "AutoFarm: Mobs (cercanos)",
    Description = "Teleporta y ataca mobs cercanos",
    Default = false,
    Callback = function(v)
        state.autofarm = v
    end
})
TabAF:AddToggle({
    Name = "AutoFarm: Bosses",
    Description = "Buscar mobs con vida alta o 'boss' en el nombre",
    Default = false,
    Callback = function(v)
        state.autoboss = v
    end
})
TabAF:AddSlider({
    Name = "Rango objetivo (studs)",
    Min = 50,
    Max = 3000,
    Increase = 10,
    Default = 1000,
    Callback = function(v) state.targetDistance = v end
})

TabAF:AddButton({"Attempt to Equip Best Tool", function()
    local char = getChar()
    if not char then return end
    for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            pcall(function() LocalPlayer.Character.Humanoid:EquipTool(v) end)
            task.wait(0.15)
        end
    end
end})

-- ESP
TabESP:AddToggle({
    Name = "Players ESP",
    Description = "Resalta jugadores",
    Default = false,
    Callback = function(v)
        if v then
            state.esp = true
            for _,pl in pairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character then
                    local h = createESPForModel(pl.Character, Color3.fromRGB(0,200,50))
                    if h then table.insert(espStore, h) end
                end
            end
            if not _G.XRNL.ESPConn then
                _G.XRNL.ESPConn = Players.PlayerAdded:Connect(function(pl)
                    task.wait(0.8)
                    if state.esp and pl.Character then
                        local h = createESPForModel(pl.Character, Color3.fromRGB(0,200,50))
                        if h then table.insert(espStore, h) end
                    end
                end)
            end
        else
            state.esp = false
            removeAllESP()
            if _G.XRNL.ESPConn then _G.XRNL.ESPConn:Disconnect(); _G.XRNL.ESPConn = nil end
        end
    end
})

TabESP:AddToggle({
    Name = "NPCs ESP",
    Description = "Resalta NPCs / Mobs en workspace",
    Default = false,
    Callback = function(v)
        if v then
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    local h = createESPForModel(obj, Color3.fromRGB(200,80,50))
                    if h then table.insert(espStore, h) end
                end
            end
        else
            removeAllESP()
        end
    end
})

TabESP:AddButton({"Clear all ESP", function() removeAllESP() end})

-- TELEPORTS: editar/añadir según mapa del servidor
local teleports = {
    ["Spawn"] = CFrame.new(0, 10, 0),
    ["Dock"] = CFrame.new(220, 15, -450),
    ["Second Island"] = CFrame.new(600, 20, -300),
    ["Boss Island"] = CFrame.new(1000, 50, -900),
}

for name, cf in pairs(teleports) do
    TabTP:AddButton({name, (function(cframe)
        return function()
            local char = getChar()
            if char and char:FindFirstChild("HumanoidRootPart") then
                pcall(function() char.HumanoidRootPart.CFrame = cframe end)
            end
        end
    end)(cf)})
end

TabTP:AddButton({"Copy current pos", function()
    local char = getChar()
    if char and char:FindFirstChild("HumanoidRootPart") then
        setclipboard(tostring(char.HumanoidRootPart.Position))
    end
end})

-- CREDITS
TabCredits:AddLabel("XRNL • Mega Hub")
TabCredits:AddLabel("By: Christianxddd (adaptado)")
TabCredits:AddButton({"Cerrar ventana (hide)", function() 
    -- redzlib generalmente provee método, si no, ocultamos manualmente
    pcall(function() Window:Hide() end)
end})
TabCredits:AddButton({"Destroy (unload script)", function()
    -- limpiamos estados
    state.autofarm = false
    state.autoboss = false
    state.esp = false
    _G.XRNL.AntiAFK = false
    _G.XRNL.AutoAttack = false
    removeAllESP()
    stopFly()
    pcall(function()
        if _G.XRNL.ESPConn then _G.XRNL.ESPConn:Disconnect(); _G.XRNL.ESPConn=nil end
    end)
    -- intentar destruir GUI si RedzLib provee
    pcall(function() Window:Destroy() end)
end})

-- Inicializaciones
safeSetWalkSpeed(state.speed)
safeSetJump(state.jump)

-- Listener simple: auto-attack loop si activado
task.spawn(function()
    while true do
        task.wait(0.25)
        if _G.XRNL.AutoAttack then
            pcall(function() tryAttack() end)
        end
    end
end)

-- Fin del script
print("XRNL • BloxF Mega Hub cargado.")
