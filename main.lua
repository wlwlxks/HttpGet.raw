local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local LocalPlayer=Players.LocalPlayer

local function createBillboard(part,text,offsetY)
    local b=Instance.new("BillboardGui")
    b.Size=UDim2.new(0,140,0,50)
    b.Adornee=part
    b.AlwaysOnTop=true
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,1,0)
    l.BackgroundTransparency=1
    l.TextColor3=Color3.new(1,1,1)
    l.TextScaled=true
    l.Text=text
    l.Parent=b
    b.Parent=part
    b.StudsOffset=Vector3.new(0,offsetY,0)
    return l
end

local function addHitbox(part,color)
    if part:IsA("BasePart") and not part:FindFirstChild("Hitbox") then
        local box=Instance.new("BoxHandleAdornment")
        box.Name="Hitbox"
        box.Adornee=part
        box.Parent=part
        box.Size=part.Size
        box.Color3=color
        box.Transparency=0.5
        box.AlwaysOnTop=true
        return box
    end
end

local function createArrow(from,to,color)
    local dir=to.Position-from.Position
    local arrow=Instance.new("Part")
    arrow.Anchored=true
    arrow.CanCollide=false
    arrow.Size=Vector3.new(0.2,0.2,dir.Magnitude)
    arrow.CFrame=CFrame.new(from.Position,to.Position)*CFrame.new(0,0,-dir.Magnitude/2)
    arrow.Color=color
    arrow.Parent=Workspace
    return arrow
end

local function updatePlayer(player)
    if player==LocalPlayer or not player.Character then return end
    local c=player.Character
    local h=c:FindFirstChild("Humanoid")
    if not h then return end
    for _,p in pairs(c:GetChildren()) do
        if p:IsA("BasePart") then
            local color=p.Name=="Head" and Color3.fromRGB(255,0,0)
                        or p.Name=="Torso" or p.Name=="UpperTorso" or p.Name=="LowerTorso" and Color3.fromRGB(0,255,0)
                        or Color3.fromRGB(0,0,255)
            local box=addHitbox(p,color)
            if box and h.Health<h.MaxHealth then
                box.Color3=Color3.fromRGB(255,255,0)
            end
        end
    end
    local root=c:FindFirstChild("HumanoidRootPart")
    if root then
        createBillboard(root,"SPD:"..h.WalkSpeed,3)
        createBillboard(root,"JH:"..h.JumpPower,5)
        local tool=c:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("MaxRange") and tool:FindFirstChild("MinRange") then
            local sizeMultiplier=(tool.MaxRange.Value+tool.MinRange.Value)/2
            for _,p in pairs(c:GetChildren()) do
                if p:IsA("BasePart") then
                    local box=p:FindFirstChild("Hitbox")
                    if box then
                        box.Size=p.Size*sizeMultiplier
                    end
                end
            end
            createBillboard(root,"Range Max:"..tool.MaxRange.Value,7)
            createBillboard(root,"Range Min:"..tool.MinRange.Value,9)
        end
        local arrow=createArrow(LocalPlayer.Character.HumanoidRootPart,root,Color3.fromRGB(0,1,1))
        RunService.Heartbeat:Connect(function()
            if arrow and root then
                local dir=root.Position-LocalPlayer.Character.HumanoidRootPart.Position
                arrow.Size=Vector3.new(0.2,0.2,dir.Magnitude)
                arrow.CFrame=CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position,root.Position)*CFrame.new(0,0,-dir.Magnitude/2)
            end
        end)
    end
end

local function updateObjects()
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent~=LocalPlayer.Character then
            if obj:GetAttribute("CreatedByLocal") or obj:FindFirstChildOfClass("Tool") then
                addHitbox(obj,Color3.fromRGB(255,255,255))
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local h=LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then
            h.WalkSpeed=200
            h.JumpPower=h.JumpPower*2
        end
    end
    for _,p in pairs(Players:GetPlayers()) do
        updatePlayer(p)
    end
    updateObjects()
end)