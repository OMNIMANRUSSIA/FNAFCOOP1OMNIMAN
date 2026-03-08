-- OMNI-MAN V4: NIGHT 6 SUPREME (CLEAN STABLE EDITION)

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Remotes = RS:WaitForChild("RemoteEvents")

-- Эвенты только для защиты от Голдена
local openCam = Remotes:WaitForChild("openCamerasEvent")

-- GUI
local parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
if parent:FindFirstChild("OmniV4") then parent.OmniV4:Destroy() end
local sg = Instance.new("ScreenGui", parent); sg.Name = "OmniV4"; sg.ResetOnSpawn = false

local mb = Instance.new("TextButton", sg)
mb.Size, mb.Position, mb.Text = UDim2.new(0, 140, 0, 40), UDim2.new(0, 50, 0, 100), "OMNI-MAN V4"
mb.BackgroundColor3, mb.TextColor3, mb.Draggable = Color3.fromRGB(180, 0, 0), Color3.new(1, 1, 1), true
Instance.new("UICorner", mb)

local fr = Instance.new("Frame", sg)
fr.Size, fr.Position, fr.AnchorPoint = UDim2.new(0, 200, 0, 180), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5)
fr.BackgroundColor3, fr.Visible = Color3.fromRGB(20, 20, 25), false
Instance.new("UICorner", fr)
Instance.new("UIListLayout", fr).HorizontalAlignment = Enum.HorizontalAlignment.Center

local Set = {Door = false, ESP = true, Bright = true}
local doorStates = {left = false, right = false}
local ANIMATRONICS = {"Bonnie", "Chica", "Foxy", "Freddy"}

local function addTog(n, k)
    local b = Instance.new("TextButton", fr)
    b.Size, b.BackgroundColor3 = UDim2.new(0.9, 0, 0, 40), Color3.fromRGB(40, 40, 50)
    b.Text = n .. ": " .. (Set[k] and "ON" or "OFF")
    b.TextColor3 = Set[k] and Color3.fromRGB(0, 255, 150) or Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Set[k] = not Set[k]
        b.Text = n .. ": " .. (Set[k] and "ON" or "OFF")
        b.TextColor3 = Set[k] and Color3.fromRGB(0, 255, 150) or Color3.new(1, 1, 1)
    end)
end

addTog("AUTO DOORS", "Door"); addTog("ESP SCAN", "ESP"); addTog("FULL BRIGHT", "Bright")
mb.MouseButton1Click:Connect(function() fr.Visible = not fr.Visible end)

-- ESP
local function applyESP(m, c)
    local h = m:FindFirstChild("OmniHighlight") or Instance.new("Highlight", m)
    h.Name, h.FillColor, h.OutlineColor, h.FillTransparency, h.Enabled = "OmniHighlight", c, Color3.new(1,1,1), 0.4, true
end

-- ЦИКЛ ДВЕРЕЙ И ESP (ТВОИ КООРДИНАТЫ)
RunS.Heartbeat:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    if Set.Bright then Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 2, 14, false end
    local events = RS:FindFirstChild("OfficeControls", true)
    local dangerZone = {left = false, right = false}

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            local name = v.Name:lower()
            local isEnemy = false
            for _, anim in pairs(ANIMATRONICS) do if name:find(anim:lower()) then isEnemy = true break end end
            
            if isEnemy then
                pcall(function()
                    local root = v.PrimaryPart or v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
                    if root then
                        local rel = LP.Character.HumanoidRootPart.CFrame:PointToObjectSpace(root.Position)
                        local dist = (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                        
                        if Set.ESP then
                            local col = Color3.new(1, 1, 1)
                            if name:find("foxy") then col = Color3.new(1, 0, 0)
                            elseif name:find("bonnie") then col = Color3.new(0.6, 0, 1)
                            elseif name:find("chica") then col = Color3.new(1, 1, 0)
                            elseif name:find("freddy") then col = Color3.fromRGB(139, 69, 19) end
                            applyESP(v, col)
                        end
                        if Set.Door then
                            -- Фокси (дистанция 28)
                            if name:find("foxy") and dist < 28 then 
                                if rel.X < 0 then dangerZone.left = true else dangerZone.right = true end 
                            end
                            -- Твои оригинальные координаты Бонни и Чики
                            if name:find("bonnie") and rel.X < -7 and rel.X > -12 and rel.Z < -10 and rel.Z > -18 then dangerZone.left = true end
                            if name:find("chica") and rel.X > 7 and rel.X < 12 and rel.Z < -10 and rel.Z > -18 then dangerZone.right = true end
                        end
                    end
                end)
            end
        end
    end

    if Set.Door and events then
        for _, side in pairs({"left", "right"}) do
            local isDangerous, ev = dangerZone[side], events:FindFirstChild(side .. "DoorEvent", true)
            if ev and ((isDangerous and not doorStates[side]) or (not isDangerous and doorStates[side])) then
                ev:FireServer(); doorStates[side] = isDangerous
            end
        end
    end
end)

-- АВТО-ЗАЩИТА ОТ ГОЛДЕНА 
task.spawn(function()
    while task.wait(0.2) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("golden") then
                local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                if root and LP.Character and (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude < 25 then
                    openCam:FireServer(true); task.wait(0.2); openCam:FireServer(false); task.wait(2)
                end
            end
        end
    end
end)

