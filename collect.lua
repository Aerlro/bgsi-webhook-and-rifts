local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local spawnRemote = ReplicatedStorage.Remotes.Pickups.SpawnPickups
local collectRemote = ReplicatedStorage.Remotes.Pickups.CollectPickup

-- Așteptăm character-ul și HumanoidRootPart
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local playerRoot = Character:WaitForChild("HumanoidRootPart")

local retryDelay = 0.1 -- secunde între retry
local maxRetries = 10   -- retry maxim pentru fiecare pickup

-- funcție care găsește primul Part descendant (Model sau Folder)
local function getPickupPart(root)
    if root and typeof(root) == "Instance" then
        for _, child in pairs(root:GetDescendants()) do
            if child:IsA("BasePart") then
                return child
            end
        end
    end
    return nil
end

-- funcție care ascunde pickup-ul client-side
local function hidePickup(pickup)
    if pickup.Root and typeof(pickup.Root) == "Instance" then
        for _, child in pairs(pickup.Root:GetDescendants()) do
            if child:IsA("BasePart") then
                child.Transparency = 1
                child.CanCollide = false
            end
        end
    end
end

-- funcție de colectare cu retry + hide + debug
local function tryCollectWithRetry(pickup)
    if pickup.Id then
        task.defer(function()
            local retries = 0
            while retries < maxRetries do
                collectRemote:FireServer(pickup.Id)
                retries += 1
                task.wait(retryDelay)
            end
            hidePickup(pickup)
            print("Pickup colectat și ascuns:", pickup.Visual or "Unknown", "-> ID:", pickup.Id)
        end)
    end
end

-- handler pentru SpawnPickups
spawnRemote.OnClientEvent:Connect(function(data)
    if typeof(data) == "table" then
        if data.Id then
            tryCollectWithRetry(data)
        else
            for _, pickup in pairs(data) do
                if typeof(pickup) == "table" then
                    tryCollectWithRetry(pickup)
                end
            end
        end
    end
end)