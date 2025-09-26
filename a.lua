-- Wizard UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local lp = game.Players.LocalPlayer

-- Sửa thông báo
local function showNoti(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 2
    })
end

-- helper teleport
local function tp(cf)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = cf
        showNoti("Teleport", "Dịch chuyển đến part!")
    end
end

-- helper invoke - SỬA LẠI CHO EXECUTOR
local function collect(code)
    if code and code ~= "" then
        -- Thử nhiều cách để debug trong executor
        rconsoleprint("=== EXECUTING CODE ===\n")
        rconsoleprint(code .. "\n")
        rconsoleprint("=== OUTPUT ===\n")
        
        -- Chạy code và bắt output
        local func = loadstring(code)
        if func then
            -- Redirect print để hiển thị trong executor console
            local oldprint = print
            print = function(...)
                local args = {...}
                local output = ""
                for i,v in ipairs(args) do
                    output = output .. tostring(v) .. " "
                end
                rconsoleprint(output .. "\n")
                oldprint(...) -- Vẫn giữ print gốc
            end
            
            local success, err = pcall(func)
            
            -- Khôi phục print gốc
            print = oldprint
            
            if success then
                rconsoleprint("✓ Code executed successfully\n")
                showNoti("Collect", "Đã chạy code!")
            else
                rconsoleprint("✗ Error: " .. tostring(err) .. "\n")
                showNoti("Lỗi", "Lỗi: " .. tostring(err))
            end
        else
            rconsoleprint("✗ Failed to load code\n")
        end
        rconsoleprint("====================\n")
    else
        rconsoleprint("No code provided\n")
    end
end

-- positions (CFrame)
local positions = {
    CFrame.new(-54.040, 104.454, 469.482, -0.875110269, 9.74059304e-08, -0.483923525, 9.67963274e-08, 1, 2.6240647e-08, 0.483923525, -2.38785596e-08, -0.875110269),
    CFrame.new(-79.5975571, 100.734673, 522.244507, -0.851041913, 3.37455042e-08, -0.525097787, -4.3390993e-09, 1, 7.12976913e-08, 0.525097787, 6.29557775e-08, -0.851041913),
    CFrame.new(-216.509262, 100.734673, 573.694092, 1, -1.44622918e-08, 2.35162665e-13, 1.44622918e-08, 1, -1.26297426e-08, -2.34980031e-13, 1.26297426e-08, 1),
    CFrame.new(106.348709, 104.733131, 432.794159, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

-- store user inputs
local codeStrings = {"", "", "", ""}

-- UI
local Window = Library:NewWindow("UGC Auto")
local Tab = Window:NewSection("Main")

-- Ensure console exists
if rconsolecreate then
    rconsolecreate()
    rconsoleprint("UGC Auto loaded\n")
end

-- Part textboxes and buttons (fixed)
for i = 1, 4 do
    local idx = i -- capture safe index

    -- Use the two-argument signature: label + callback
    Tab:CreateTextbox("Code for Part "..idx, function(value)
        codeStrings[idx] = tostring(value or "")
        rconsoleprint(("Updated Part %d code: %s\n"):format(idx, codeStrings[idx]))
        showNoti("Textbox", ("Part %d code updated"):format(idx))
    end)

    Tab:CreateButton("Go Part "..idx, function()
        rconsoleprint(("Go Part %d pressed. Current code: %s\n"):format(idx, tostring(codeStrings[idx])))
        tp(positions[idx])
        task.wait(0.5)
        collect(codeStrings[idx])
    end)
end


-- Auto toggle
local looping = false
Tab:CreateToggle("Auto Run Parts", function(state)
    looping = state
    if looping then
        task.spawn(function()
            while looping do
                for i=1,4 do
                    if not looping then break end
                    tp(positions[i])
                    task.wait(0.5)
                    collect(codeStrings[i])
                    task.wait(2)
                end
                task.wait(0.5)
            end
        end)
    else
        rconsoleprint("Auto stopped\n")
    end
end)

-- Mở console nếu executor hỗ trợ
if rconsolecreate then
    rconsolecreate()
    rconsoleprint("UGC Auto Script loaded!\n")
end
