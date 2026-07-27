--[[
    ═══════════════════════════════════════════════════════════════
    🍍 BLOX FRUITS ULTIMATE COMPLETO v4.0 🍍
    ═══════════════════════════════════════════════════════════════
    ✅ Auto Farm NPC
    ✅ Auto Bounty (Kill Players) 
    ✅ Auto Sea Events (Sea Beast, Leviathan, Mirage)
    ✅ Auto Collect Berrys/Bones/Items
    ✅ Auto Katakuri V2
    ✅ Auto Raid
    ✅ Auto Haki
    ✅ Auto Stats
    ✅ ESP Completo
    ✅ Redeem Codes
    ✅ Anti-AFK
    ✅ TUDO em um só script!
    ═══════════════════════════════════════════════════════════════
--]]

-- ==================== CONFIGURAÇÕES DE TECLAS (DENTRO DO JOGO) ====================
-- Altere as teclas aqui dentro do script, no jogo!

local CONFIG = {
    -- ═══ TECLAS DE ATALHO ═══
    TeclaGUI = Enum.KeyCode.F1,              -- Abrir GUI
    TeclaAutoFarm = Enum.KeyCode.F2,         -- Auto Farm NPC
    TeclaBounty = Enum.KeyCode.F3,           -- Auto Bounty (Kill Players)
    TeclaSeaEvent = Enum.KeyCode.F4,         -- Auto Sea Events
    TeclaCollect = Enum.KeyCode.F5,          -- Auto Collect Items
    TeclaKatakuri = Enum.KeyCode.F6,         -- Auto Katakuri V2
    TeclaRedeem = Enum.KeyCode.F7,           -- Redeem Codes
    TeclaESP = Enum.KeyCode.F8,              -- ESP
    TeclaTeleport = Enum.KeyCode.F9,         -- Teleport
    
    -- ═══ CORES ═══
    CorPrincipal = Color3.fromRGB(255, 170, 0),
    CorSecundaria = Color3.fromRGB(255, 50, 50),
    CorFundo = Color3.fromRGB(15, 15, 25),
    
    -- ═══ AUTO BOUNTY ═══
    BountyTeam = "Pirate",                   -- "Pirate" ou "Marine"
    BountyMaxLevelDist = 612,                -- Distância máxima para atacar
    BountySafeZone = 40,                     -- % de vida para fugir
    BountyHealAt = 90,                       -- % de vida para curar
    
    -- ═══ AUTO SEA EVENT ═══
    SeaEventDistance = 5000,                 -- Distância para procurar eventos
    AutoMirageIsland = true,
    AutoSeaBeast = true,
    AutoLeviathan = true,
    
    -- ═══ AUTO KATAKURI ═══
    KatakuriCooldown = 0.5,                  -- Tempo entre ataques
    KatakuriUseSkills = true,
    
    -- ═══ OUTROS ═══
    AutoRedeemCodes = true,
    AutoJoinServer = false,
    AntiAFK = true,
    AutoHaki = true,
}

-- ==================== SERVIÇOS ====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ==================== VARIÁVEIS ====================
local GUI = nil
local ScreenGui = nil
local isGUIOpen = false

-- Estados dos sistemas
local autoFarmActive = false
local bountyActive = false
local seaEventActive = false
local collectActive = false
local katakuriActive = false
local espActive = false

local currentTarget = nil
local isFarming = false
local espObjects = {}

-- ==================== FUNÇÃO DE LOG ====================
local function addLog(message, isError)
    print("[BLOX] " .. message)
    if GUI and GUI:FindFirstChild("Logs") then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 18)
        label.BackgroundTransparency = 1
        label.Text = "[" .. os.date("%H:%M:%S") .. "] " .. message
        label.TextColor3 = isError and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200)
        label.TextSize = 12
        label.Font = Enum.Font.Code
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = GUI.Logs
        label.Parent.CanvasSize = UDim2.new(0, 0, 0, label.Parent.AbsoluteCanvasSize.Y + 18)
        if #label.Parent:GetChildren() > 50 then
            label.Parent:GetChildren()[1]:Destroy()
        end
    end
end

-- ==================== TELEPORT ====================
local function teleportTo(position)
    if rootPart then
        rootPart.CFrame = CFrame.new(position)
        task.wait(0.1)
    end
end

-- ==================== SISTEMA DE ENCONTRAR NPCs ====================
local function findNPCs(nome)
    local found = {}
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name ~= player.Name then
            if nome and string.find(string.lower(v.Name), string.lower(nome)) then
                table.insert(found, v)
            elseif not nome then
                table.insert(found, v)
            end
        end
    end
    return found
end

-- ==================== AUTO FARM NPC ====================
local function autoFarm()
    if not autoFarmActive then
        isFarming = false
        return
    end
    
    isFarming = true
    local npcs = findNPCs()
    if #npcs == 0 then
        addLog("⚠️ Nenhum NPC encontrado!", true)
        task.wait(1)
        isFarming = false
        return
    end
    
    local nearestNPC = nil
    local nearestDist = math.huge
    
    for _, npc in pairs(npcs) do
        if npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
            local dist = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestNPC = npc
            end
        end
    end
    
    if not nearestNPC then
        addLog("⚠️ Nenhum NPC vivo encontrado!", true)
        task.wait(1)
        isFarming = false
        return
    end
    
    currentTarget = nearestNPC
    addLog("🎯 Farmando: " .. nearestNPC.Name)
    
    while autoFarmActive and nearestNPC and nearestNPC.Humanoid and nearestNPC.Humanoid.Health > 0 do
        if rootPart and nearestNPC.HumanoidRootPart then
            local dist = (rootPart.Position - nearestNPC.HumanoidRootPart.Position).Magnitude
            if dist > 15 then
                teleportTo(nearestNPC.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
            end
        end
        
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("AttackRemote")
            if remote then remote:FireServer(nearestNPC) end
        end)
        
        task.wait(0.2)
    end
    
    isFarming = false
    if autoFarmActive then
        task.wait(0.5)
        autoFarm()
    end
end

-- ==================== AUTO BOUNTY (KILL PLAYERS) ====================
local function autoBounty()
    if not bountyActive then return end
    
    addLog("🎯 Procurando jogadores para bounty...")
    
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < CONFIG.BountyMaxLevelDist then
                table.insert(targets, p)
            end
        end
    end
    
    if #targets == 0 then
        addLog("⚠️ Nenhum jogador próximo!", true)
        task.wait(5)
        return
    end
    
    local target = targets[1]
    addLog("⚔️ Atacando: " .. target.Name)
    
    while bountyActive and target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 do
        -- Verificar saúde
        if humanoid.Health / humanoid.MaxHealth * 100 < CONFIG.BountySafeZone then
            addLog("⚠️ Saúde baixa, recuando...")
            teleportTo(rootPart.Position + Vector3.new(0, 50, 0))
            task.wait(3)
            if humanoid.Health / humanoid.MaxHealth * 100 < CONFIG.BountyHealAt then
                humanoid.Health = humanoid.MaxHealth
            end
        end
        
        -- Teleport para o alvo
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            teleportTo(target.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
        end
        
        -- Atacar
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("AttackRemote")
            if remote then remote:FireServer(target.Character) end
        end)
        
        task.wait(0.3)
    end
    
    addLog("✅ Alvo derrotado ou fugiu!")
    task.wait(2)
    if bountyActive then autoBounty() end
end

-- ==================== AUTO SEA EVENTS ====================
local function autoSeaEvent()
    if not seaEventActive then return end
    
    addLog("🌊 Procurando eventos do mar...")
    
    -- Procurar Sea Beast
    if CONFIG.AutoSeaBeast then
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Model") and string.find(string.lower(v.Name), "sea") and string.find(string.lower(v.Name), "beast") then
                if v:FindFirstChild("HumanoidRootPart") then
                    addLog("🐉 Sea Beast encontrado!")
                    teleportTo(v.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
                    
                    while seaEventActive and v and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 do
                        pcall(function()
                            local remote = ReplicatedStorage:FindFirstChild("AttackRemote")
                            if remote then remote:FireServer(v) end
                        end)
                        task.wait(0.2)
                    end
                    addLog("✅ Sea Beast derrotado!")
                end
            end
        end
    end
    
    -- Procurar Mirage Island
    if CONFIG.AutoMirageIsland then
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Model") and string.find(string.lower(v.Name), "mirage") then
                addLog("🏝️ Mirage Island encontrada!")
                if v:FindFirstChild("Part") then
                    teleportTo(v.Part.Position + Vector3.new(0, 5, 0))
                end
            end
        end
    end
    
    task.wait(10)
    if seaEventActive then autoSeaEvent() end
end

-- ==================== AUTO COLLECT (ITEMS/BERRIES/BONES) ====================
local function autoCollect()
    if not collectActive then return end
    
    -- Coletar itens no chão
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Part") then
            local nome = string.lower(v.Name)
            if string.find(nome, "beli") or string.find(nome, "berry") or 
               string.find(nome, "bone") or string.find(nome, "chest") or
               string.find(nome, "fruit") or string.find(nome, "drop") then
                local dist = (rootPart.Position - v.Part.Position).Magnitude
                if dist < 50 then
                    teleportTo(v.Part.Position + Vector3.new(0, 2, 0))
                    addLog("📦 Coletando: " .. v.Name)
                    task.wait(0.5)
                end
            end
        end
    end
    
    task.wait(1)
    if collectActive then autoCollect() end
end

-- ==================== AUTO KATAKURI V2 ====================
local function autoKatakuri()
    if not katakuriActive then return end
    
    addLog("🍩 Auto Katakuri V2 ativado!")
    
    while katakuriActive do
        -- Procurar Katakuri
        local katakuriFound = nil
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Model") and string.find(string.lower(v.Name), "katakuri") then
                katakuriFound = v
                break
            end
        end
        
        if katakuriFound and katakuriFound:FindFirstChild("HumanoidRootPart") then
            addLog("🎯 Katakuri encontrado!")
            teleportTo(katakuriFound.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
            
            while katakuriActive and katakuriFound and katakuriFound:FindFirstChild("Humanoid") and katakuriFound.Humanoid.Health > 0 do
                -- Usar habilidades
                if CONFIG.KatakuriUseSkills then
                    pcall(function()
                        -- Tentar usar habilidades de fruta/espada
                        for _, skill in pairs({"Z", "X", "C", "V", "F"}) do
                            local remote = ReplicatedStorage:FindFirstChild("SkillRemote")
                            if remote then
                                remote:FireServer(skill, katakuriFound)
                            end
                        end
                    end)
                end
                
                -- Atacar normalmente
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild("AttackRemote")
                    if remote then remote:FireServer(katakuriFound) end
                end)
                
                task.wait(CONFIG.KatakuriCooldown)
            end
            addLog("✅ Katakuri derrotado!")
        else
            addLog("⚠️ Katakuri não encontrado, aguardando...")
        end
        
        task.wait(10)
    end
end

-- ==================== REDEEM CODES ====================
local CODES = {
    "SUB2UNCLEKIZARU", "SUB2NOOBMASTER123", "SUB2GAMERROBOT_EXP1",
    "SUB2DAIGROCK", "SUB2OFFICIALTR3X", "EARNPIECES", "ENJ0Y",
    "FUDD10", "FUDD10_V2", "BIGNEWS", "JULYUPDATE_RESET",
    "KITT_RESET", "KITT_GAMING", "MAGICBUS", "NOOB2ADMIN",
    "NOVEMBERUPDATE", "SHUTDOWN", "STOCK_RESET", "TANZANITE",
    "THEGREATACE", "UPDATE14", "UPDATE15", "UPDATE16", "UPDATE17",
    "UPDATE18", "UPDATE19", "UPDATE20", "UPD14", "UPD15", "UPD16",
    "UPD17", "UPD18", "UPD19", "UPD20", "VOLTAGE", "XCODE",
    "YOUTUBE", "2BILLION", "3BILLION", "1MIL", "2MIL", "3MIL",
    "4MIL", "5MIL", "10MIL", "20MIL", "50MIL", "100MIL", "500MIL", "1B",
}

local function redeemCodes()
    addLog("🔄 Resgatando códigos...")
    for _, code in ipairs(CODES) do
        task.wait(0.5)
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("RedeemCode")
            if remote then
                remote:FireServer(code)
                addLog("✅ Código: " .. code)
            end
        end)
    end
    addLog("✅ Todos os códigos processados!")
end

-- ==================== ESP ====================
local function createESP()
    for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
    espObjects = {}
    
    if not espActive then
        addLog("🔴 ESP desativado")
        return
    end
    
    addLog("🟢 ESP ativado")
    
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Name ~= player.Name then
            local esp = Instance.new("BillboardGui")
            esp.Size = UDim2.new(0, 200, 0, 30)
            esp.StudsOffset = Vector3.new(0, 3, 0)
            esp.AlwaysOnTop = true
            esp.Parent = npc
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 0.3
            frame.BackgroundColor3 = npc.Humanoid.Health > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            frame.Parent = esp
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = npc.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 12
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
            label.Parent = frame
            
            table.insert(espObjects, esp)
        end
    end
end

-- ==================== ANTI-AFK ====================
if CONFIG.AntiAFK then
    task.spawn(function()
        while task.wait(30) do
            pcall(function()
                local kb = game:GetService("VirtualUser")
                if kb then
                    kb:CaptureController()
                    kb:ClickButton2(Vector2.new())
                end
            end)
        end
    end)
    addLog("🛡️ Anti-AFK ativado")
end

-- ==================== AUTO HAKI ====================
if CONFIG.AutoHaki then
    task.spawn(function()
        while task.wait(5) do
            pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("HakiRemote")
                if remote then remote:FireServer() end
            end)
        end
    end)
    addLog("⚡ Auto Haki ativado")
end

-- ==================== CRIAÇÃO DA GUI ====================
local function createGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxFruitsUltimate"
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 550, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -260)
    mainFrame.BackgroundColor3 = CONFIG.CorFundo
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = ScreenGui
    mainFrame.Visible = false
    
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 12)
    corners.Parent = mainFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🍍 BLOX FRUITS ULTIMATE COMPLETO"
    title.TextColor3 = CONFIG.CorPrincipal
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -20, 0, 2)
    line.Position = UDim2.new(0, 10, 0, 40)
    line.BackgroundColor3 = CONFIG.CorPrincipal
    line.BackgroundTransparency = 0.3
    line.Parent = mainFrame
    
    -- Scroll de botões
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 320)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = CONFIG.CorPrincipal
    scroll.Parent = mainFrame
    
    local y = 0
    local btnSize = 38
    
    local function createBtn(text, color, callback, desc, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, btnSize)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = color or CONFIG.CorPrincipal
        btn.BackgroundTransparency = 0.4
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.Text = text .. (key and " [" .. tostring(key):gsub("Enum.KeyCode.", "") .. "]" or "")
        btn.BorderSizePixel = 0
        btn.Parent = scroll
        
        local btnCorners = Instance.new("UICorner")
        btnCorners.CornerRadius = UDim.new(0, 5)
        btnCorners.Parent = btn
        
        if desc then
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, -10, 0, 14)
            d.Position = UDim2.new(0, 5, 0, btnSize - 14)
            d.BackgroundTransparency = 1
            d.Text = desc
            d.TextColor3 = Color3.fromRGB(150, 150, 170)
            d.TextSize = 10
            d.Font = Enum.Font.Gotham
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = btn
        end
        
        btn.MouseButton1Click:Connect(callback)
        y = y + btnSize + 4
        scroll.CanvasSize = UDim2.new(0, 0, 0, y)
        return btn
    end
    
    -- Botões
    createBtn("⚔️ Auto Farm NPC", Color3.fromRGB(0, 200, 100), function()
        autoFarmActive = not autoFarmActive
        addLog(autoFarmActive and "🟢 Auto Farm ATIVADO" or "🔴 Auto Farm DESATIVADO")
        if autoFarmActive then task.spawn(autoFarm) end
    end, "Farmar NPCs automaticamente", CONFIG.TeclaAutoFarm)
    
    createBtn("👊 Auto Bounty (Kill Players)", Color3.fromRGB(255