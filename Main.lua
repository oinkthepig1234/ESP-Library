local cloneref = cloneref or function(a) return a end
local Services = setmetatable({}, {
    __index = function(self, i)
        local service = game:GetService(i)
        service = service and cloneref(service)
        self[i] = service
        return service
    end
})
local EspLib = {
    Config = {
        MainToggles = {
            PlayerEsp = false,
            Nametags = false,
            HealthBar = false,
            Skeletons = false
        },
        Values = {
            ScaleNametags = false,
            NametagSize = 20,
            NametagSeperator = "|",
            EspColor = Color3.new(1, 1, 1)
        },
        NametagSettings = {}
    },
    Dependencies = {
        UpdateFunctions = {},
        CreateFunctions = {}
    },
    Values = {
        UpdateConnection = nil,
    },
    EspTable = {},
    TeamColors = {},
}

function EspLib.Dependencies.StudsToPixels(studs, depth)
    local camera = workspace.CurrentCamera
    local fov = math.rad(camera.FieldOfView)
    local viewportHeight = camera.ViewportSize.Y

    return (studs / (2 * depth * math.tan(fov / 2))) * viewportHeight
end

function EspLib.Dependencies.convertTo2D(pos, width, height)
    local camera = workspace.CurrentCamera
    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
    if width and height then
        local depth = screenPos.Z
        local screenWidth = EspLib.Dependencies.StudsToPixels(width, depth)
        local screenHeight = EspLib.Dependencies.StudsToPixels(height, depth)
        return Vector2.new(screenPos.X, screenPos.Y), Vector2.new(screenWidth, screenHeight), onScreen
    end
    return Vector2.new(screenPos.X, screenPos.Y)
end

function EspLib.Dependencies.UpdateFunctions.PlayerEsp(plr, char, hrp, humanoid, items, pos, size, onScreen)
    local visible = onScreen
    local transparency = (visible) and 1 or 0
    items.Position = pos - (size/2)
    items.Size = size
    items.Visible = visible
    items.Transparency = transparency
end

function EspLib.Dependencies.UpdateFunctions.Nametags(plr, char, hrp, humanoid, items, pos, size, onScreen)
    local str = plr.Name
    for _, Info in ipairs(EspLib.Config.NametagSettings) do
        if not Info.Value then
            continue
        end
        local value = Info.Function(plr, char)
        if not value or value == "" then
            continue
        end
        str = str .. EspLib.Config.Values.NametagSeperator .. tostring(value) .. Info.Suffix
    end
    items.Text = str
    items.Visible = onScreen
    items.Transparency = onScreen and 1 or 0
    if EspLib.Config.Values.ScaleNametags then
        items.Position = Vector2.new(pos.X, pos.Y - size.Y * (0.5 + (EspLib.Config.Values.NametagSize/100)))
        items.Size = size.Y * (EspLib.Config.Values.NametagSize/100)
    else
        items.Position = Vector2.new(pos.X, pos.Y - size.Y * 0.5 - (EspLib.Config.Values.NametagSize))
    end
end

function EspLib.Dependencies.UpdateFunctions.Skeletons(plr, char, hrp, humanoid, items, pos, size, onScreen)
    local Character = plr.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then
        return
    end
    for i,v in pairs(items) do
        v.Visible = onScreen
    end
    local ConvertFunc = EspLib.Dependencies.convertTo2D
    local r6 = Humanoid.RigType == Enum.HumanoidRigType.R6
    local offset = r6 and CFrame.new(0, -0.8, 0) or CFrame.identity
    local head = ConvertFunc((Character.Head.CFrame).p)
    local headfront = ConvertFunc((Character.Head.CFrame * CFrame.new(0, 0, -0.5)).p)
    local toplefttorso = ConvertFunc((Character[(r6 and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(-1.5, 0.8, 0)).p)
    local toprighttorso = ConvertFunc((Character[(r6 and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(1.5, 0.8, 0)).p)
    local toptorso = ConvertFunc((Character[(r6 and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, 0.8, 0)).p)
    local bottomtorso = ConvertFunc((Character[(r6 and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, -0.8, 0)).p)
    local bottomlefttorso = ConvertFunc((Character[(r6 and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(-0.5, -0.8, 0)).p)
    local bottomrighttorso = ConvertFunc((Character[(r6 and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0.5, -0.8, 0)).p)
    local leftarm = ConvertFunc((Character[(r6 and 'Left Arm' or 'LeftHand')].CFrame * offset).p)
    local rightarm = ConvertFunc((Character[(r6 and 'Right Arm' or 'RightHand')].CFrame * offset).p)
    local leftleg = ConvertFunc((Character[(r6 and 'Left Leg' or 'LeftFoot')].CFrame * offset).p)
    local rightleg = ConvertFunc((Character[(r6 and 'Right Leg' or 'RightFoot')].CFrame * offset).p)
    items.Head.From = toptorso
    items.Head.To = head
    items.HeadFacing.From = head
    items.HeadFacing.To = headfront
    items.UpperTorso.From = toplefttorso
    items.UpperTorso.To = toprighttorso
    items.Torso.From = toptorso
    items.Torso.To = bottomtorso
    items.LowerTorso.From = bottomlefttorso
    items.LowerTorso.To = bottomrighttorso
    items.LeftArm.From = toplefttorso
    items.LeftArm.To = leftarm
    items.RightArm.From = toprighttorso
    items.RightArm.To = rightarm
    items.LeftLeg.From = bottomlefttorso
    items.LeftLeg.To = leftleg
    items.RightLeg.From = bottomrighttorso
    items.RightLeg.To = rightleg
end

function EspLib.Dependencies.UpdateFunctions.HealthBar(plr, char, hrp, humanoid, items, pos, size, onScreen)
    items.HealthBar.From = pos + Vector2.new(size.X * -0.65, size.Y * 0.5)
    items.HealthBar.To = items.HealthBar.From - Vector2.new(0, size.Y * (humanoid.Health/humanoid.MaxHealth))
    items.HealthBar.Thickness = size.X * 0.1
    items.HealthBar.Visible = onScreen
    items.HealthBar.Transparency = onScreen and 1 or 0
    items.Backdrop.From = pos + Vector2.new(size.X * -0.65, size.Y * -0.5)
    items.Backdrop.To = items.HealthBar.To
    items.Backdrop.Thickness = size.X * 0.1
    items.Backdrop.Visible = onScreen
    items.Backdrop.Transparency = onScreen and 1 or 0
end

function EspLib.Dependencies.UpdateFunction()
    local EnabledFeatures = {}
    for name, value in EspLib.Config.MainToggles do
        if not value then
            continue
        end
        EnabledFeatures[#EnabledFeatures + 1] = name
    end
    for player, espitems in EspLib.EspTable do
        local char = player.Character
        if not char then
            continue
        end
        local hmd = char:FindFirstChild("Humanoid")
        if not hmd then
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            continue
        end
        local rigcheck = hmd.RigType == Enum.HumanoidRigType.R15
        local h = rigcheck and hmd:FindFirstChild("BodyHeightScale")
        local w = rigcheck and hmd:FindFirstChild("BodyWidthScale")
        local head = rigcheck and hmd:FindFirstChild("HeadScale")
        local prop = rigcheck and hmd:FindFirstChild("BodyProportionScale")
        local bodyType = rigcheck and hmd:FindFirstChild("BodyTypeScale")
        h = h and h.Value or 1
        w = w and w.Value or 1
        head = head and head.Value or 1
        prop = prop and prop.Value or 1
        bodyType = bodyType and bodyType.Value or 1
        local WidthScale = w * 0.65 + head * 0.25 + bodyType * 0.10
        local HeightScale = h * 0.70 + prop * 0.20 + head * 0.10
        local pos, size, onScreen = EspLib.Dependencies.convertTo2D(hrp.Position - Vector3.new(0, 0.4, 0), 4 * WidthScale, 6 * HeightScale)
        for _, feature in ipairs(EnabledFeatures) do
            pcall(EspLib.Dependencies.UpdateFunctions[feature], player, char, hrp, hmd, espitems[feature], pos, size, onScreen)
        end
    end
end

function EspLib.Dependencies.StartUpdateThread()
    if EspLib.Values.UpdateConnection then
        return
    end
    EspLib.Values.UpdateConnection = Services.RunService.RenderStepped:Connect(EspLib.Dependencies.UpdateFunction)
end

function EspLib.Dependencies.EndUpdateThread()
    for _, enabled in ipairs(EspLib.Config.MainToggles) do
        if enabled then
            return
        end
    end
    if EspLib.Values.UpdateConnection then
        EspLib.Values.UpdateConnection:Disconnect()
        EspLib.Values.UpdateConnection = nil
    end
end

function EspLib.Dependencies.CreateFunctions.PlayerEsp(plr, char, enabled, color)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = color
    box.Visible = false
    box.Transparency = 0
    return box
end

function EspLib.Dependencies.CreateFunctions.Nametags(plr, char, enabled, color)
    local text = Drawing.new("Text")
    text.Center = true
    text.Outline = false
    text.Color = color
    text.Text = plr.Name
    text.Visible = false
    text.Transparency = 0
    if not EspLib.Config.Values.ScaleNametags then
        text.Size = EspLib.Config.Values.NametagSize
    end
    return text
end

function EspLib.Dependencies.CreateFunctions.Skeletons(plr, char, enabled, color)
    local bodyParts = {}
    bodyParts.Head = Drawing.new('Line')
    bodyParts.HeadFacing = Drawing.new('Line')
    bodyParts.Torso = Drawing.new('Line')
    bodyParts.UpperTorso = Drawing.new('Line')
    bodyParts.LowerTorso = Drawing.new('Line')
    bodyParts.LeftArm = Drawing.new('Line')
    bodyParts.RightArm = Drawing.new('Line')
    bodyParts.LeftLeg = Drawing.new('Line')
    bodyParts.RightLeg = Drawing.new('Line')

    for i,v in pairs(bodyParts) do
        v.Visible = false
        v.Thickness = 2
        v.Color = color
    end
    return bodyParts
end

function EspLib.Dependencies.CreateFunctions.HealthBar(plr, char, enabled, color)
    local healthBar, backdrop = Drawing.new("Line"), Drawing.new("Line")
    healthBar.Color = Color3.new(0, 1, 0)
    backdrop.Color = Color3.new(0, 0, 0)
    backdrop.Visible = false
    backdrop.Transparency = 0
    healthBar.Transparency = 0
    healthBar.Visible = false
    return {HealthBar = healthBar, Backdrop = backdrop}
end

function EspLib.Dependencies.AddEspToCharacter(plr, char)
    local esptable = EspLib.EspTable[plr]
    local teamColorInfo = EspLib.TeamColors[plr.Team]
    local color = teamColorInfo or EspLib.Config.Values.EspColor
    for name, value in EspLib.Config.MainToggles do
        esptable[name] = EspLib.Dependencies.CreateFunctions[name](plr, char, value, color)
    end
end

function EspLib.Dependencies.AddEspToPlayer(plr)
    EspLib.EspTable[plr] = {}
    plr.CharacterAdded:Connect(function(char)
        EspLib.Dependencies.AddEspToCharacter(plr, char)
    end)
    if plr.Character then
        EspLib.Dependencies.AddEspToCharacter(plr, plr.Character)
    end
end

for _, plr in ipairs(Services.Players:GetPlayers()) do
    EspLib.Dependencies.AddEspToPlayer(plr)
end

Services.Players.PlayerAdded:Connect(EspLib.Dependencies.AddEspToPlayer)
Services.Players.PlayerRemoving:Connect(function(plr)
    for i, v in EspLib.EspTable[plr] do
        if i == "Skeletons" then
            for _, drawing in v do
                drawing:Remove()
            end
            continue
        end
        v:Remove()
    end
    EspLib.EspTable[plr] = nil
end)

function EspLib:PlayerEspToggle(value:boolean)
    if value then
        self.Dependencies.StartUpdateThread()
        self.Config.MainToggles.PlayerEsp = value
        return
    end
    self.Config.MainToggles.PlayerEsp = value
    self.Dependencies.EndUpdateThread()
    for plr, espitems in self.EspTable do
        espitems.PlayerEsp.Visible = false
    end
end

function EspLib:NametagsToggle(value:boolean)
    self.Config.MainToggles.Nametags = value
    if value then
        self.Dependencies.StartUpdateThread()
        return
    end
    self.Dependencies.EndUpdateThread()
    for plr, espitems in self.EspTable do
        espitems.Nametags.Visible = false
    end
end

function EspLib:HealthBarToggle(value:boolean)
    self.Config.MainToggles.Nametags = value
    if value then
        self.Dependencies.StartUpdateThread()
        return
    end
    self.Dependencies.EndUpdateThread()
    for plr, espitems in self.EspTable do
        espitems.Nametags.Visible = false
    end
end

function EspLib:SkeletonsToggle(value:boolean)
    self.Config.MainToggles.Skeletons = value
    if value then
        self.Dependencies.StartUpdateThread()
        return
    end
    self.Dependencies.EndUpdateThread()
    for plr, espitems in self.EspTable do
        for i,v in espitems.Skeletons do
            v.Visible = false
        end
    end
end

function EspLib:EspColorSet(value:Color3)
    self.Config.Values.EspColor = value
    for plr, espitems in self.EspTable do
        local color = self.TeamColors[plr.Team] or value
        for i, v in espitems do
            if i == "Skeletons" then
                for _, drawing in v do
                    drawing.Color = color
                end
                continue
            end
            if i == "HealthBar" then
                continue
            end
            v.Color = color
        end
    end
end

function EspLib:ScaleNametagsToggle(value:boolean)
    self.Config.Values.ScaleNametags = value
    if not value then
        for plr, espitems in self.EspTable do
            espitems.Nametags.Size = EspLib.Config.Values.NametagSize
        end
    end
end

function EspLib:NametagSizeSet(value:number)
    self.Config.Values.NametagSize = value
    if not self.Config.Values.ScaleNametags then
        for plr, espitems in self.EspTable do
            espitems.Nametags.Size = value
        end
    end
end

return EspLib
