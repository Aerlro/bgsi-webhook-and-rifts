-- LocalScript compatibil Delta Executor
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- RemoteEvent corect
local remote = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteEvent")

local autoGrabEnabled = false -- pornim dupa StartMinigame
local grabbedItems = {}       -- pentru a nu trimite duplicate
local savedFile = "RobotClaws.txt"

-- funcție pentru grab
local function grabItem(id)
    if id and autoGrabEnabled and not grabbedItems[id] then
        remote:FireServer("GrabMinigameItem", id)
        grabbedItems[id] = true
        print("✅ Grab trimis pentru UUID:", id)

        -- salvare în fișier Delta Executor
        local content = ""
        if isfile(savedFile) then
            content = readfile(savedFile)
        end
        content = content .. id .. "\n"
        writefile(savedFile, content)
    end
end

-- verifică un obiect dacă e Robot Claw
local function tryGrab(obj)
    if obj and obj.Name == "Robot Claw" then
        local uuid = obj:GetAttribute("UUID")
        if uuid then
            grabItem(uuid)
        end
    end
end

-- loop inițial pentru obiectele deja existente
for _, obj in ipairs(Workspace:GetDescendants()) do
    tryGrab(obj)
end

-- ascultă spawnarea de noi obiecte în Workspace
Workspace.DescendantAdded:Connect(function(obj)
    tryGrab(obj)
end)

-- ascultă evenimentele serverului
remote.OnClientEvent:Connect(function(action, ...)
    if action == "StartMinigame" then
        print("⏳ StartMinigame detectat. Începem grab-ul în 3 secunde...")
        task.delay(3, function()
            autoGrabEnabled = true
            print("🤖 Auto-Grab activ!")
        end)
    elseif action == "FinishMinigame" then
        autoGrabEnabled = false
        print("🛑 Minigame terminat. Auto-Grab oprit.")
    end
end)

print("✅ Script Auto-Grab Robot Claw încărcat! Delta Executor ready.")
