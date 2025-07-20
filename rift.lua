local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Webhook-uri pentru fiecare rift/entitate
local RiftWebhooks = {
    ["bee-egg"] = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
    ["cyber-egg"]       = "https://discord.com/api/webhooks/1391374777335156818/4cKl6U8nMjlOVx4NximkLpXqwT73gShGWILiVmEZL7hP5RrdqdRlc9UIaddEiDiT_Nyu",
    ["super-chest"] = "https://discord.com/api/webhooks/1391374777981206548/LBpfKoLMiDIjOMLpU_jb_HhPQJ-J5n--U2Ao5PvFzMM2ybzx3eqIJZv1nCz4vb8cjKwn",
    ["neon-egg"] = "https://discord.com/api/webhooks/1391374778195251210/n4Q2mz6h4rVbGxsJxDkFmZ4nIeyOe8jKybLe-G-2ZfqnTTVBJT4pzNWyESRyReolcQaM",
    ["void-egg"]        = "https://discord.com/api/webhooks/1391374778832519219/99_q4mMSFaxJJuhXiTAmImdgWhU9pwcOyebXiFuIhy-D6u0OhMaOCwRDXsZNER2GLDf9",
    ["hell-egg"]        = "https://discord.com/api/webhooks/1391374778832519219/99_q4mMSFaxJJuhXiTAmImdgWhU9pwcOyebXiFuIhy-D6u0OhMaOCwRDXsZNER2GLDf9",
    ["crystal-egg"]     = "https://discord.com/api/webhooks/1391374778832519219/99_q4mMSFaxJJuhXiTAmImdgWhU9pwcOyebXiFuIhy-D6u0OhMaOCwRDXsZNER2GLDf9",
    ["royal-chest"]     = "https://discord.com/api/webhooks/1391374773296304200/qwV3xucsLvjS80GiwMPDYqmQopuLwJiVVbGuXkGWLnbAPOOJ6SAKE32FGnRnB97T--mm",
    ["golden-chest"]    = "https://discord.com/api/webhooks/1391374774189424740/9KZFT5Sn_z6PrLZdFUfg4XOEYv6bBlVw2ekMtilHJ3I7RircHotDyT_9KNlv7kkI6iny",
    ["nightmare-egg"]   = "https://discord.com/api/webhooks/1391374778832519219/99_q4mMSFaxJJuhXiTAmImdgWhU9pwcOyebXiFuIhy-D6u0OhMaOCwRDXsZNER2GLDf9",
    ["dice-rift"]       = "https://discord.com/api/webhooks/1391374774617505912/fuAXY-6soaocZ7GE1lK1Hd97crjdx3wvo2hszKJnpQSPJ4K3vRUw2bAzLQ_prjpt5vl7",
    ["mining-egg"]      = "https://discord.com/api/webhooks/1391374777826021406/POnyWa2YhIYIN2CqaeVswxaL8wveGMfDT94yVk2BuOQDdYw4Z-4Z-EYiSZnhUCG6iLgw",
    ["bubble-rift"]     = "https://discord.com/api/webhooks/1391374774734946374/JK3ertej6d3Dkcp2zhXbGLJpFXHC4RRhJNGs-3UPmsV_vm4-2m-V4mGzAClLB0jOk4_o",
    ["spikey-egg"]      = "https://discord.com/api/webhooks/1391374778832519219/99_q4mMSFaxJJuhXiTAmImdgWhU9pwcOyebXiFuIhy-D6u0OhMaOCwRDXsZNER2GLDf9",
    ["magma-egg"]       = "https://discord.com/api/webhooks/1391374778832519219/99_q4mMSFaxJJuhXiTAmImdgWhU9pwcOyebXiFuIhy-D6u0OhMaOCwRDXsZNER2GLDf9",
    ["rainbow-egg"]     = "https://discord.com/api/webhooks/1391374772822081536/T1WM9qtMDNiyUsbicJ0fwVtg8Gt_DXlCuRKkswQh2lh4WyCXgT78GJ5EBIO-J-rPZEjL",
    ["lunar-egg"]       = "https://discord.com/api/webhooks/1391374778832519219/99_q4mMSFaxJJuhXiTAmImdgWhU9pwcOyebXiFuIhy-D6u0OhMaOCwRDXsZNER2GLDf9"
}

-- Thumbnails pentru fiecare tip
local RiftThumbnails = {
    ["bee-egg"] = "https://cdn.discordapp.com/attachments/1392217302153429022/1396395263643353098/Update_13_-_Bee_Rift.png?ex=687dedee&is=687c9c6e&hm=4dd9e3656796054b7d02bcc82880e85f388fa3869b374ca5eb7c6bf334aeec3a&",
    ["cyber-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748857860226/Cyber_Egg.png?ex=6872e2e3&is=68719163&hm=9574fe5010e671d9eb774b11e92a9a130d40b073354700066a3e965a540a3aad&",
    ["super-chest"] = "https://cdn.discordapp.com/attachments/1392217302153429022/1393866766161018921/Super_Chest.png?ex=6874bb15&is=68736995&hm=9ad0e179e0e4b0bb457af2f8ad0b3551622617aa89e14320b1fa068dfcca3f4d&",
    ["neon-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393866766421332068/Neon_Egg.png?ex=6874bb15&is=68736995&hm=6e9e7a3b226c4184bda547f8008086398f78efe0addfe110e831745ab1185372&",
    ["void-egg"]        = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725650776265/Void_Egg.png?ex=6872e2dd&is=6871915d&hm=3402e7c76f7c2771964a263c86c92728243da0e9367665e2b52e09c15665d232&",
    ["hell-egg"]        = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359726020006080/Hell_Egg.png?ex=6872e2de&is=6871915e&hm=13b8f0a08e179fb51a967d79e0bcb566be94c450acfd0844b474a68ec5e93d16&",
    ["crystal-egg"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725025824899/Crystal_Egg.png?ex=6872e2dd&is=6871915d&hm=c128d78d6b29290746ab55a6acc5dbd47d8fa1ea9751e2db6b26f42a5d77df2b&",
    ["royal-chest"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359723872649317/Royal_Chest.png?ex=6872e2dd&is=6871915d&hm=b387839be66a40f9ea1eee0080e3fbc005871b0ecb944f1320b94b5801d4311b&",
    ["golden-chest"]    = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359723578789938/Golden_Chest.png?ex=6872e2dd&is=6871915d&hm=ca77b395f185e34685e43f67874bd119e21d2779487f80ea6d77395cc99848ef&",
    ["nightmare-egg"]   = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748207742986/Nightmare_Egg.png?ex=6872e2e3&is=68719163&hm=1933ebba675368cf1876aa1fd015d3765c78231e871dcdfd4d89781a6a75d8c2&",
    ["dice-rift"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724149211266/Dice_Chest.png?ex=6872e2dd&is=6871915d&hm=0f29c55eb3aa32b45224c78a732625dc64b00160c826b151717b6bcb37c32927&",
    ["mining-egg"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748652335164/Mining_Egg.png?ex=6872e2e3&is=68719163&hm=e13cadeb452447be61172e8f452eb3a030c48140220edd7db63fc345b4ff653e&",
    ["bubble-rift"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393360635596771478/Gum_Rift.png?ex=6872e3b6&is=68719236&hm=400773fa39f20c9292c040ddea45fc50f6593ef50404790db07b876a6a162153&",
    ["spikey-egg"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724384223283/Spikey_Egg.png?ex=6872e2dd&is=6871915d&hm=2b070ba614e77a144b0f4dcda5f7d5154dc1249b8990c42b62e2861e7455afe8&",
    ["magma-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724782686250/Magma_Egg.png?ex=6872e2dd&is=6871915d&hm=eb4884a399a59e846bf168b3bd51a8f62070977aea194e31dda438a12e09d166&",
    ["rainbow-egg"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748442886164/Rainbow_Egg.png?ex=6872e2e3&is=68719163&hm=4ba53a5ee5fed9d35afa4e36ecc9ca2457849f50056c5a1905e922ad0f28d54e&",
    ["lunar-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725336461372/Lunar_Egg.png?ex=6872e2dd&is=6871915d&hm=7846c09402dc3b75f1a6a38fbef15fbfcdf389f21e49a67fd0e5c5436e216ef9&"
}

local alreadyNotified = {}

local function formatTitle(name)
    local displayName = name:gsub("-", " ")
    return displayName:gsub("(%a)([%w_']*)", function(f, r) return f:upper() .. r:lower() end) .. " Rift Found!"
end

local function getRiftMultiplier(rift)
    for _, d in ipairs(rift:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextBox") then
            local text = d.Text:lower()
            local m = text:match("(%d+)%s*x") or text:match("x%s*(%d+)")
            if m then
                return tonumber(m)
            end
        end
    end
    return nil
end

while true do
    for _, rift in pairs(workspace:GetDescendants()) do
        if rift:IsA("Model") and RiftWebhooks[rift.Name] then
            local multiplier = getRiftMultiplier(rift)

            local isChestRift = rift.Name == "golden-chest" or rift.Name == "royal-chest" or rift.Name == "dice-rift" or rift.Name == "super-chest"
            if not isChestRift then
                if not multiplier or multiplier ~= 25 then
                    continue
                end
            end

            local riftId = rift:GetDebugId() or (rift.Name .. game.JobId)
            if alreadyNotified[riftId] then continue end

            local primary = rift.PrimaryPart or rift:FindFirstChildWhichIsA("BasePart")
            if not primary then continue end

            alreadyNotified[riftId] = true

            -- 🕒 Rift va exista timp de 30 minute
            local now = os.time()
            local despawn_time = now + 1800
            local timestamp = "<t:" .. despawn_time .. ":R>"

            local player_count = #Players:GetPlayers()
            local join_link = "https://www.roblox.com/games/" .. game.PlaceId .. "/--?launchData&gameInstanceId=" .. game.JobId
            local displayName = rift.Name:gsub("-", " ")
            local height = tostring(math.floor(primary.Position.Y))
            local thumbnail_url = RiftThumbnails[rift.Name] or ""

            local riftInfo = {
                "・**Server Info**",
                "- **Players:** " .. tostring(player_count) .. "/12",
                "- **Join Link:** [Click Here](" .. join_link .. ")",
                "",
                "・**Rift Info**"
            }

            if multiplier then
                table.insert(riftInfo, "- **Luck:** " .. multiplier .. "x")
            end

            table.insert(riftInfo, "- **Type:** " .. displayName)
            table.insert(riftInfo, "- **Despawns:** " .. timestamp)
            table.insert(riftInfo, "- **Height:** " .. height)

            local embedData = {
                ["embeds"] = {{
                    ["title"] = formatTitle(rift.Name),
                    ["description"] = table.concat(riftInfo, "\n"),
                    ["color"] = tonumber("2F3136", 16),
                    ["author"] = {
                        ["name"] = "aerlrobos",
                        ["icon_url"] = "https://cdn.discordapp.com/attachments/1256255133545660511/1391365982353883266/1.png"
                    },
                    ["footer"] = { ["text"] = "Festival Rift Auto Notification" },
                    ["timestamp"] = DateTime.now():ToIsoDate(),
                    ["thumbnail"] = { ["url"] = thumbnail_url }
                }}
            }

            local req = http_request or request or syn and syn.request
            local webhook_url = RiftWebhooks[rift.Name]

            if req and webhook_url then
                pcall(function()
                    req({
                        Url = webhook_url,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode(embedData)
                    })
                end)
            else
                warn("Executorul nu suportă request-uri.")
            end

            -- 🐝 Teleportare directă dacă e un bee-egg
            if rift.Name == "bee-egg" and LocalPlayer and LocalPlayer.Character and primary then
                local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = primary.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
    wait(5)
end
