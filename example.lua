local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/oinkthepig1234/ESP-Library/refs/heads/main/Main.lua'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

table.insert(lib.Config.NametagSettings, -- Set Value to true when you want to enable it
    {
        Value = false,
        Suffix = " Studs",
        Function = function(targetPlr, targetChar)
            if not targetChar then
                return 0
            end
            if not LocalPlayer.Character then
                return 0
            end
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return 0
            end
            local targethrp = targetChar:FindFirstChild("HumanoidRootPart")
            if not targethrp then
                return 0
            end
            local distance = (hrp.Position - targethrp.Position).Magnitude
            return math.round(distance * 100)/100
        end
    }
)

lib.Config.Values.NametagSeperator = "|" --change this to whatever you want, "|" is default

--[[
    lib.TeamColors[TeamInstance] = Color3.new(1, 1, 1) --use this to add custom team colors, remove them from the table and call the change color function when you want to remove it
]]

local Window = Rayfield:CreateWindow({
    Name = "example",
    Icon = 0,
    LoadingTitle = "example",
    LoadingSubtitle = "by oink",
    ShowText = "Rayfield",
    Theme = "Default",
 
    ToggleUIKeybind = "K",
 
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = false
})

local tab = Window:CreateTab("hi")

tab:CreateToggle({
    Name = "esp",
    CurrentValue = false,
    Callback = function(Value)
        lib:PlayerEspToggle(Value)
    end,
})

tab:CreateToggle({
    Name = "nametags",
    CurrentValue = false,
    Callback = function(Value)
        lib:NametagsToggle(Value)
    end,
})

tab:CreateToggle({
    Name = "healthbar",
    CurrentValue = false,
    Callback = function(Value)
        lib:HealthBarToggle(Value)
    end,
})

tab:CreateToggle({
    Name = "skeletons",
    CurrentValue = false,
    Callback = function(Value)
        lib:SkeletonsToggle(Value)
    end,
})

tab:CreateToggle({
    Name = "scale nametags",
    CurrentValue = false,
    Callback = function(Value)
        lib:ScaleNametagsToggle(Value)
    end
})

tab:CreateColorPicker({
    Name = "color",
    Color = Color3.fromRGB(255,255,255),
    Callback = function(Value)
        lib:EspColorSet(Value)
    end
})

tab:CreateSlider({
    Name = "nametag size",
    Range = {0, 200},
    Increment = 1,
    Suffix = "pixels",
    CurrentValue = 10,
    Callback = function(Value)
        lib:NametagSizeSet(Value)
    end,
})
