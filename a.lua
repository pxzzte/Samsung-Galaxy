-- === REPLACE/ADD THIS UI BLOCK ===
-- Creates a compact on-screen UI using Roblox Instances so buttons read TextBox.Text directly.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local lp = Players.LocalPlayer

-- remove old UI if present
local existing = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("UGC_Auto_UI")
if existing then existing:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UGC_Auto_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 380, 0, 190)
main.Position = UDim2.new(0, 20, 0, 60)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
local mc = Instance.new("UICorner", main)
mc.CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -12, 0, 30)
title.Position = UDim2.new(0,6,0,6)
title.BackgroundTransparency = 1
title.Text = "UGC Auto — Direct TextBox UI"
title.TextColor3 = Color3.fromRGB(220,220,220)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local ypos = 42
local textboxes = {}
local goButtons = {}

for i=1,4 do
    -- label
    local lbl = Instance.new("TextLabel", main)
    lbl.Size = UDim2.new(0, 70, 0, 28)
    lbl.Position = UDim2.new(0, 8, 0, ypos)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Part "..i..":"
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- textbox
    local tb = Instance.new("TextBox", main)
    tb.Size = UDim2.new(0, 220, 0, 28)
    tb.Position = UDim2.new(0, 80, 0, ypos)
    tb.BackgroundColor3 = Color3.fromRGB(45,45,45)
    tb.TextColor3 = Color3.fromRGB(235,235,235)
    tb.Text = "" -- start empty
    tb.PlaceholderText = 'e.g. print("abc") or loadstring(...)'
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 13
    tb.ClearTextOnFocus = false
    local tbc = Instance.new("UICorner", tb)
    tbc.CornerRadius = UDim.new(0,6)

    -- Go button
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0, 70, 0, 28)
    b.Position = UDim2.new(0, 308, 0, ypos)
    b.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = "Go "..i
    local bc = Instance.new("UICorner", b)
    bc.CornerRadius = UDim.new(0,6)

    textboxes[i] = tb
    goButtons[i] = b

    ypos = ypos + 34
end

-- Auto toggle button
local autoBtn = Instance.new("TextButton", main)
autoBtn.Size = UDim2.new(0, 120, 0, 28)
autoBtn.Position = UDim2.new(0, 8, 0, ypos)
autoBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
autoBtn.Text = "Auto: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBtn.Font = Enum.Font.GothamBold
local ac = Instance.new("UICorner", autoBtn)
ac.CornerRadius = UDim.new(0,6)

-- Clear console button
local clearBtn = Instance.new("TextButton", main)
clearBtn.Size = UDim2.new(0, 120, 0, 28)
clearBtn.Position = UDim2.new(0, 136, 0, ypos)
clearBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
clearBtn.Text = "Clear Console"
clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
clearBtn.Font = Enum.Font.GothamBold
local cc = Instance.new("UICorner", clearBtn)
cc.CornerRadius = UDim.new(0,6)

-- Notification helper (reuse showNoti if exists)
local function notify(a,b) pcall(function() StarterGui:SetCore("SendNotification",{Title=a,Text=b,Duration=2}) end) end

-- Hook buttons: read textbox.Text directly
for i=1,4 do
    local idx = i
    goButtons[idx].MouseButton1Click:Connect(function()
        local code = tostring(textboxes[idx].Text or "")
        rconsoleprint(("Go Part %d pressed. Code length: %d\n"):format(idx, #code))
        tp(positions[idx])
        task.wait(0.45)
        collect(code)
    end)
end

-- Auto behavior
local auto = false
local autoTask = nil
autoBtn.MouseButton1Click:Connect(function()
    auto = not auto
    autoBtn.Text = auto and "Auto: ON" or "Auto: OFF"
    autoBtn.BackgroundColor3 = auto and Color3.fromRGB(0,170,0) or Color3.fromRGB(100,100,100)
    notify("Auto", auto and "Started" or "Stopped")
    if auto then
        autoTask = task.spawn(function()
            while auto do
                for i=1,4 do
                    if not auto then break end
                    local code = tostring(textboxes[i].Text or "")
                    tp(positions[i])
                    task.wait(0.45)
                    collect(code)
                    task.wait(1.0)
                end
                task.wait(0.4)
            end
        end)
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    if rconsoleclear then pcall(rconsoleclear) end
    rconsoleprint("Console cleared\n")
    notify("Console","Cleared")
end)
-- === END UI BLOCK ===

