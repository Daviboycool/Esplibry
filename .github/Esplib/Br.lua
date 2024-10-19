-- ESP Library Personalizável
local ESP = {}
ESP.Enabled = false
ESP.TeamCheck = false -- Checa se o ESP será só para o time específico
ESP.Boxes = true
ESP.Names = true
ESP.Distance = true
ESP.TeamColors = {} -- Cores customizadas por time (Player.Team.Name como chave)
ESP.DefaultColor = Color3.new(1, 1, 1) -- Cor padrão se o time não estiver definido

local camera = game:GetService("Workspace").CurrentCamera
local players = game:GetService("Players")
local runService = game:GetService("RunService")

-- Função para modificar a cor do ESP para cada time
function ESP:SetTeamColor(teamName, color)
    ESP.TeamColors[teamName] = color
end

-- Função para definir a cor padrão
function ESP:SetDefaultColor(color)
    ESP.DefaultColor = color
end

-- Função para alterar configurações de texto (nomes, distância)
function ESP:ToggleText(showNames, showDistance)
    ESP.Names = showNames
    ESP.Distance = showDistance
end

-- Função para ativar/desativar a checagem por time
function ESP:SetTeamCheck(state)
    ESP.TeamCheck = state
end

local function GetPlayerColor(player)
    -- Pega a cor baseada no time
    if ESP.TeamColors[player.Team and player.Team.Name] then
        return ESP.TeamColors[player.Team.Name]
    end
    return ESP.DefaultColor
end

local function DrawESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 2
    box.Filled = false

    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 18
    name.Center = true
    name.Outline = true

    local distance = Drawing.new("Text")
    distance.Visible = false
    distance.Size = 18
    distance.Center = true
    distance.Outline = true

    local function Update()
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and ESP.Enabled then
            local vector, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
            
            -- Checa se o jogador está na tela e no time certo (se TeamCheck estiver ativo)
            if onScreen and (not ESP.TeamCheck or player.Team == players.LocalPlayer.Team) then
                local size = (camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0)).Y -
                              camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                box.Size = Vector2.new(2000 / vector.Z, size)
                box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
                box.Color = GetPlayerColor(player)
                box.Visible = ESP.Boxes
                
                -- Exibe nome se habilitado
                if ESP.Names then
                    name.Text = player.Name
                    name.Position = Vector2.new(vector.X, vector.Y - box.Size.Y / 2 - 16)
                    name.Color = GetPlayerColor(player)
                    name.Visible = true
                else
                    name.Visible = false
                end

                -- Exibe distância se habilitado
                if ESP.Distance then
                    distance.Text = math.floor((humanoidRootPart.Position - camera.CFrame.Position).Magnitude) .. "m"
                    distance.Position = Vector2.new(vector.X, vector.Y + box.Size.Y / 2)
                    distance.Color = GetPlayerColor(player)
                    distance.Visible = true
                else
                    distance.Visible = false
                end
            else
                box.Visible = false
                name.Visible = false
                distance.Visible = false
            end
        else
            box.Visible = false
            name.Visible = false
            distance.Visible = false
        end
    end

    runService.RenderStepped:Connect(Update)
end

-- Função para ativar/desativar o ESP
function ESP:Toggle(state)
    ESP.Enabled = state
    if state then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= players.LocalPlayer then
                DrawESP(player)
            end
        end
        players.PlayerAdded:Connect(DrawESP)
    end
end

return ESP
