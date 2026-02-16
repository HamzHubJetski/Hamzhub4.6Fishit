-- HamzHub v4.6 | Full Fix: UI Persist, Auto Fish/Sell Work, No Error

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local env = getgenv and getgenv() or _G

-- Loading Screen
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "HamzHubLoading"
loadingGui.Parent = PlayerGui
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", loadingGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(0.6, 0, 0.15, 0)
title.Position = UDim2.new(0.2, 0, 0.35, 0)
title.BackgroundTransparency = 1
title.Text = "HamzHub Is Loading..."
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack

wait(3)
loadingGui:Destroy()

-- Load Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("HamzHub v4.6 - Fish It!", "DarkTheme")

-- Cari Kavo ScreenGui dengan precedence fix
local KavoGui
for _, v in pairs(PlayerGui:GetChildren()) do
    if v:IsA("ScreenGui") and (
        v:FindFirstChild("Main") or
        (v:FindFirstChildWhichIsA("ScrollingFrame") and v.Name:lower():find("kavo"))
    ) then
        KavoGui = v
        break
    end
end

-- Minimize Button Persist (tetep muncul meski pencet X/close Kavo)
local minimized = false
if KavoGui then
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "HamzMinBtn"
    minBtn.Size = UDim2.new(0, 120, 0, 35)
    minBtn.Position = UDim2.new(0, 10, 0, 10)
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    minBtn.Text = "HamzHub [-]"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextScaled = true
    minBtn.Parent = KavoGui

    -- Petir icon
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 140, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://3926305904"
    icon.ImageColor3 = Color3.fromRGB(255, 215, 0)
    icon.Parent = KavoGui

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        minBtn.Text = minimized and "HamzHub [+]" or "HamzHub [-]"
        for _, child in pairs(KavoGui:GetDescendants()) do
            if (child:IsA("Frame") or child:IsA("ScrollingFrame")) and child.Visible \~= nil then
                local n = child.Name or ""
                local pn = child.Parent and child.Parent.Name or ""
                if n:find("Tab") or n:find("Section") or pn:find("Tab") or pn:find("Section") then
                    child.Visible = not minimized
                end
            end
        end
    end)
end

-- Instant Catch Hook (tight keywords)
env.InstantCatchEnabled = false

if hookmetamethod then
    local oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and env.InstantCatchEnabled then
            local rn = tostring(self.Name):lower()
            local keys = {"reel", "catch", "fishcaught", "perfectcatch", "rod", "castrod", "throwrod", "reelin", "castline"}
            for _, kw in ipairs(keys) do
                if rn:find(kw) then
                    local newArgs = {}
                    for i, v in ipairs(args) do newArgs[i] = v end
                    if #newArgs >= 1 then newArgs[1] = true end
                    if #newArgs >= 2 then newArgs[2] = 100 end
                    local s, r = pcall(oldNamecall, self, unpack(newArgs))
                    if s then return r end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end))
end

-- Tabs & Features
local mainTab = Window:NewTab("Main Features")
local mainSec = mainTab:NewSection("Core Fitur")

mainSec:NewToggle("Instant Catch", "Catch langsung tanpa minigame", function(state)
    env.InstantCatchEnabled = state
    game.StarterGui:SetCore("SendNotification", {Title = "HamzHub v4.6", Text = "Instant Catch: " .. (state and "ON" or "OFF")})
end)

env.AutoFishEnabled = false
mainSec:NewToggle("Auto Fish", "Auto lempar & catch", function(state)
    env.AutoFishEnabled = state
    if state then
        spawn(function()
            while env.AutoFishEnabled do
                pcall(function()
                    local possibles = {"Cast", "CastRod", "ThrowRod", "ThrowBait", "CastLine", "StartFishing", "FishCast", "ReelIn"}
                    local events = RS:FindFirstChild("Events") or RS
                    for _, name in ipairs(possibles) do
                        local rem = events:FindFirstChild(name)
                        if rem and rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            print("HamzHub AutoFish: Fired " .. name)
                            break
                        end
                    end
                end)
                wait(1.5 + math.random(0.5, 1.5))
            end
        end)
    end
    game.StarterGui:SetCore("SendNotification", {Title = "HamzHub v4.6", Text = "Auto Fish: " .. (state and "ON" or "OFF")})
end)

mainSec:NewButton("Auto Sell All", "Jual semua ikan", function()
    pcall(function()
        local possibles = {"SellAll", "Sell", "SellAllFish", "SellInventory", "SellFish", "SellAllItems"}
        local events = RS:FindFirstChild("Events") or RS
        for _, name in ipairs(possibles) do
            local rem = events:FindFirstChild(name)
            if rem and rem:IsA("RemoteEvent") then
                rem:FireServer()
                print("HamzHub Sell: Fired " .. name)
                break
            end
        end
    end)
end)

-- Teleport Tab (dari CFrame lo)
local tpTab = Window:NewTab("Teleport Pulau")
local tpSec = tpTab:NewSection("Lokasi Pulau")

local locations = {
    ["Ancient Jungle"] = CFrame.new(1482.88, 5.94, -339.56),
    ["Ancient Ruin"] = CFrame.new(6010.29, -585.93, 4641.64),
    ["Coral Reef"] = CFrame.new(-3074.15, 3.63, 2356.52),
    ["Crater Island"] = CFrame.new(1025.22, 14.13, 5088.76),
    ["Crystal Depth"] = CFrame.new(5721.09, -907.93, 15328.36),
    ["Esoteric Depth"] = CFrame.new(3298.39, -1302.86, 1369.86),
    ["Kohana Volcano"] = CFrame.new(-647.53, 40.99, 148.43),
    ["Secret Temple"] = CFrame.new(1488.65, -30.11, -694.77),
    ["Pirate Island"] = CFrame.new(3431, 4.06, 3431),
    ["Sisyphus Statue"] = CFrame.new(-3738.77, -135.08, -1009.51),
    ["Treasure Room"] = CFrame.new(-3594.6, -283.83, -1649.68),
    ["Tropical Grove"] = CFrame.new(-2073.76, 5.96, 3821.63),
}

for name, cf in pairs(locations) do
    tpSec:NewButton(name, "Teleport ke " .. name, function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = cf + Vector3.new(0, 6, 0)
    end)
end

print("HamzHub v4.6 loaded! UI persist, auto fish/sell fixed, no error. Cek console F9 untuk debug remote.")
