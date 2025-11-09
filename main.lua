local GetName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window(GetName.Name)
local serv = win:Server("Interface", "")

---------------------------------------------------
-- ABA TOOLS
---------------------------------------------------
local tools = serv:Channel("Tools")

-- Speed
tools:Textbox("Speed", "Digite a velocidade", true, function(value)
    local speed = tonumber(value)
    if speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
        print("Velocidade ajustada para:", speed)
    end
end)

-- Fly (controla velocidade de voo)
tools:Textbox("Fly", "Digite quantidade", true, function(value)
    print("Fly ajustado para:", value)
    -- Implementação do fly não inclusa aqui, pois depende de script adicional externo
end)

-- Noclip toggle
local noclipEnabled = false
tools:Toggle("Noclip", function(state)
    noclipEnabled = state
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
    print("Noclip está agora:", noclipEnabled)
end)

---------------------------------------------------
-- ABA TELEPORTE
---------------------------------------------------
local teleport = serv:Channel("Teleporte")

local playerList = {}

local function updatePlayerList()
    playerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerList, p.Name)
        end
    end
end

updatePlayerList()

local selectedTPPlayer
teleport:Dropdown("Escolher Jogador", playerList, function(v)
    selectedTPPlayer = v
    print("Jogador selecionado para teleporte:", v)
end)

teleport:Button("Teleporte para o Jogador", function()
    if selectedTPPlayer then
        local target = Players:FindFirstChild(selectedTPPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            print("Teletransportado para:", selectedTPPlayer)
        else
            warn("Jogador alvo inválido para teleporte")
        end
    else
        warn("Nenhum jogador selecionado para teleporte.")
    end
end)

-- Teleporte Temporário
teleport:Textbox("Duração Teleporte (segundos)", "Digite quanto tempo ficar preso no jogador", true, function(value)
    teleport.duration = tonumber(value) or 5
end)

teleport:Button("Teleporte Temporário", function()
    if selectedTPPlayer then
        local target = Players:FindFirstChild(selectedTPPlayer)
        local duration = teleport.duration or 5
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local startTime = tick()
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if tick() - startTime > duration then
                    connection:Disconnect()
                    print("Teleporte temporário finalizado após "..duration.." segundos.")
                else
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                    end
                end
            end)
            print("Teleportando temporariamente para "..selectedTPPlayer.." por "..duration.." segundos.")
        else
            warn("Jogador alvo inválido para teleporte temporário")
        end
    else
        warn("Nenhum jogador selecionado para teleporte temporário.")
    end
end)

Players.PlayerAdded:Connect(function(p)
    updatePlayerList()
    teleport:RefreshDropdown("Escolher Jogador", playerList, function(v)
        selectedTPPlayer = v
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    updatePlayerList()
    teleport:RefreshDropdown("Escolher Jogador", playerList, function(v)
        selectedTPPlayer = v
    end)
end)

---------------------------------------------------
-- ABA ADMIN
---------------------------------------------------
local admin = serv:Channel("Admin")

local function updateAdminPlayerLists()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local adminPlayerList = updateAdminPlayerLists()

-- Xray toggle
local xrayEnabled = false
admin:Toggle("Xray", function(state)
    xrayEnabled = state
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
        end
    end
    print("Xray está:", xrayEnabled)
end)

-- ESP toggle
local espEnabled = false
local espBoxes = {}
admin:Toggle("ESP", function(state)
    espEnabled = state
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if espEnabled then
                if not espBoxes[plr.Name] then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Adornee = plr.Character.HumanoidRootPart
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.AlwaysOnTop = true
                    local label = Instance.new("TextLabel", billboard)
                    label.Text = plr.Name
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.new(1, 0, 0)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    espBoxes[plr.Name] = billboard
                    billboard.Parent = game.CoreGui
                end
            else
                if espBoxes[plr.Name] then
                    espBoxes[plr.Name]:Destroy()
                    espBoxes[plr.Name] = nil
                end
            end
        end
    end
    print("ESP está:", espEnabled)
end)

local selectedKickPlayer
admin:Dropdown("Kick Player", adminPlayerList, function(v)
    selectedKickPlayer = v
    print("Jogador selecionado para kick:", v)
end)

admin:Button("Kickar Jogador", function()
    if selectedKickPlayer then
        local target = Players:FindFirstChild(selectedKickPlayer)
        if target then
            target:Kick("Você foi kickado pelo executor")
            print("Jogador "..selectedKickPlayer.." foi kickado.")
        else
            warn("Jogador não encontrado para kick.")
        end
    else
        warn("Nenhum jogador selecionado para kick.")
    end
end)

local selectedFreezePlayer
admin:Dropdown("Freezer Player", adminPlayerList, function(v)
    selectedFreezePlayer = v
    print("Jogador selecionado para freezer:", v)
end)

admin:Button("Freezer Jogador", function()
    if selectedFreezePlayer then
        local target = Players:FindFirstChild(selectedFreezePlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local char = target.Character
            if char.Humanoid then
                char.Humanoid.WalkSpeed = 0
                char.Humanoid.JumpPower = 0
            end
            print("Jogador "..selectedFreezePlayer.." congelado.")
        else
            warn("Jogador não encontrado para freezer.")
        end
    else
        warn("Nenhum jogador selecionado para freezer.")
    end
end)

local selectedFirePlayer
admin:Dropdown("Fire Player", adminPlayerList, function(v)
    selectedFirePlayer = v
    print("Jogador selecionado para fogo:", v)
end)

admin:Button("Colocar Fogo no Jogador", function()
    if selectedFirePlayer then
        local target = Players:FindFirstChild(selectedFirePlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local fire = Instance.new("Fire")
            fire.Parent = target.Character.HumanoidRootPart
            print("Jogador "..selectedFirePlayer.." está pegando fogo!")
            if target.Character:FindFirstChild("Humanoid") then
                local hum = target.Character.Humanoid
                spawn(function()
                    while fire.Parent do
                        hum:TakeDamage(5)
                        wait(1)
                    end
                end)
            end
        else
            warn("Jogador não encontrado para fogo.")
        end
    else
        warn("Nenhum jogador selecionado para fogo.")
    end
end)

Players.PlayerAdded:Connect(function(p)
    adminPlayerList = updateAdminPlayerLists()
    admin:RefreshDropdown("Kick Player", adminPlayerList, function(v)
        selectedKickPlayer = v
    end)
    admin:RefreshDropdown("Freezer Player", adminPlayerList, function(v)
        selectedFreezePlayer = v
    end)
    admin:RefreshDropdown("Fire Player", adminPlayerList, function(v)
        selectedFirePlayer = v
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    adminPlayerList = updateAdminPlayerLists()
    admin:RefreshDropdown("Kick Player", adminPlayerList, function(v)
        selectedKickPlayer = v
    end)
    admin:RefreshDropdown("Freezer Player", adminPlayerList, function(v)
        selectedFreezePlayer = v
    end)
    admin:RefreshDropdown("Fire Player", adminPlayerList, function(v)
        selectedFirePlayer = v
    end)
end)

---------------------------------------------------
-- ABA TROLL
---------------------------------------------------
local troll = serv:Channel("Troll")

local function updateTrollList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local trollPlayerList = updateTrollList()

local trollPlayer

troll:Dropdown("Escolher Jogador para troll", trollPlayerList, function(v)
    trollPlayer = v
    print("Jogador selecionado para troll:", v)
end)

local rotateCharConn
local loopFireConn
local loopFireActive = false

-- Girar personagem
troll:Button("Girar Personagem", function()
    if trollPlayer then
        local target = Players:FindFirstChild(trollPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            if rotateCharConn then rotateCharConn:Disconnect() end
            rotateCharConn = RunService.Heartbeat:Connect(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end)
            print("Girando personagem de", trollPlayer)
        else
            warn("Jogador inválido para girar personagem")
        end
    else
        warn("Nenhum jogador selecionado para girar personagem.")
    end
end)

troll:Button("Parar Girar", function()
    if rotateCharConn then
        rotateCharConn:Disconnect()
        rotateCharConn = nil
        print("Parou de girar personagem.")
    end
end)

-- Loop Fire
troll:Button("Loop Fire ON", function()
    if trollPlayer then
        local target = Players:FindFirstChild(trollPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            if loopFireConn then loopFireConn:Disconnect() end
            local fire = Instance.new("Fire")
            fire.Parent = hrp
            loopFireConn = RunService.Heartbeat:Connect(function()
                local hum = target.Character:FindFirstChild("Humanoid")
                if hum then
                    hum:TakeDamage(5)
                end
                if not fire.Parent then
                    fire.Parent = hrp
                end
            end)
            loopFireActive = true
            print("Loop fire ativado para", trollPlayer)
        else
            warn("Jogador inválido para loop fire")
        end
    else
        warn("Nenhum jogador selecionado para loop fire.")
    end
end)

troll:Button("Loop Fire OFF", function()
    if loopFireConn then
        loopFireConn:Disconnect()
        loopFireConn = nil
        loopFireActive = false
        if trollPlayer then
            local target = Players:FindFirstChild(trollPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character.HumanoidRootPart
                for _, v in pairs(hrp:GetChildren()) do
                    if v:IsA("Fire") then
                        v:Destroy()
                    end
                end
            end
        end
        print("Loop fire desativado.")
    end
end)

-- Função para inverter controles (funcionalidade limitada dependendo do executor)
local function invertControls(target)
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        -- Exemplo básico: altere a direção do movimento aplicando força contrária (implementação customizada pode ser necessária)
        local hum = target.Character.Humanoid
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 1250
        bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
        bodyVelocity.Parent = target.Character.HumanoidRootPart

        -- Remover BodyVelocity após 5 segundos para evitar bugs
        delay(5, function()
            bodyVelocity:Destroy()
        end)
        print("Controles invertidos não suportado plenamente - função básica aplicada para", target.Name)
    end
end

troll:Button("Inverter Controles", function()
    if trollPlayer then
        local target = Players:FindFirstChild(trollPlayer)
        invertControls(target)
    else
        warn("Nenhum jogador selecionado para inverter controles.")
    end
end)

Players.PlayerAdded:Connect(function(p)
    trollPlayerList = updateTrollList()
    troll:RefreshDropdown("Escolher Jogador para troll", trollPlayerList, function(v)
        trollPlayer = v
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    trollPlayerList = updateTrollList()
    troll:RefreshDropdown("Escolher Jogador para troll", trollPlayerList, function(v)
        trollPlayer = v
    end)
end)
