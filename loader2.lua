local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local petsModule = require(rs.Shared.Data.Pets)
local eggsModule = require(rs.Shared.Data.Eggs)
local secretBountyUtil = require(rs.Shared.Utils.Stats.SecretBountyUtil)

local webhookUrl = "https://discord.com/api/webhooks/1391374778882986035/KzVd6EaiXL73gd2YN_FIIHt-d36SeaKONLqsjPGiTDin65p_KrRBLfwr7saQpbXUZCFI"
local serverLuckWebhookUrl = "https://discord.com/api/webhooks/1391368932761276436/eUsp8pJMsgzC3APxmw_qN64bWZrWyKEUIZraHTLFLUqi7yh0TMvXWEVBl3AnkHjMSfXi"
local bountyWebhook = "https://discord.com/api/webhooks/1407847455902662768/xWn94IDXW-ExWhJ0JGX5GF9Uefa9vOAzea2qNMJKVMbKq9yXE9ZHiLxFNX_dpft_XB1S"

local localPlayer = Players.LocalPlayer
print("Roblox Name: " .. localPlayer.Name)
local luckNotificationSent = false

local HatchEvent = rs:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteEvent")

local remote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("PlayerDataChanged")
local chestRemote = rs.Shared.Framework.Network.Remote.RemoteEvent
local startTime = tick()
local coins, gems, tickets, pearls = "N/A", "N/A", "N/A", "N/A"
local totalHatches = 0

local function autoChest()
    local chests = {
        {name = "Giant Chest",    cooldown = 15 * 60, lastClaim = 0},
        {name = "Void Chest",     cooldown = 40 * 60, lastClaim = 0},
        {name = "Ticket Chest",   cooldown = 30 * 60, lastClaim = 0},
        {name = "Infinity Chest", cooldown = 30 * 60, lastClaim = 0},
    }

    while true do
        for _, chest in ipairs(chests) do
            local now = os.time()
            if (now - chest.lastClaim) >= chest.cooldown then
                chestRemote:FireServer("ClaimChest", chest.name, true)
                chest.lastClaim = now
            end
            task.wait(5)
        end
        task.wait(1)
    end
end

local function autoPlaytimeReward()
    local playtimeRemote = rs:WaitForChild("Shared")
        :WaitForChild("Framework")
        :WaitForChild("Network")
        :WaitForChild("Remote")
        :WaitForChild("RemoteFunction")

    local AllRewards = {}

    while true do
        for i = 1, 9 do
            local success, result = pcall(function()
                return playtimeRemote:InvokeServer("ClaimPlaytime", i)
            end)
            if success then
                AllRewards[i] = result
            end
        end
        task.wait(30)
    end
end

local function autoClaimSeasonReward()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RemoteEvent = ReplicatedStorage:WaitForChild("Shared")
                                  :WaitForChild("Framework")
                                  :WaitForChild("Network")
                                  :WaitForChild("Remote")
                                  :WaitForChild("RemoteEvent")

    local function claim()
        RemoteEvent:FireServer("ClaimSeason")
    end

    while true do
        claim()
        task.wait(5)
    end
end

local function getCurrencyAmount(currencyName)
        local success, result = pcall(function()
                local label = localPlayer:WaitForChild("PlayerGui")
                        :WaitForChild("ScreenGui")
                        :WaitForChild("HUD")
                        :WaitForChild("Left")
                        :WaitForChild("Currency")
                        :WaitForChild(currencyName)
                        :WaitForChild("Frame")
                        :WaitForChild("Label")

                local text = label.Text
                local cleanText = text:gsub(",", "")
                local number = tonumber(cleanText)
                return number
        end)

        if success then
                return result
        else
                return nil
        end
end

coroutine.wrap(function()
    while true do
        if coins == "N/A" then
            local value = getCurrencyAmount("Coins")
            if value then coins = value end
        end
        if gems == "N/A" then
            local value = getCurrencyAmount("Gems")
            if value then gems = value end
        end
        if tickets == "N/A" then
            local value = getCurrencyAmount("Tickets")
            if value then tickets = value end
        end
        if pearls == "N/A" then
            local value = getCurrencyAmount("Pearls")
            if value then pearls = value end
        end
        wait(10)
    end
end)()

if remote then
    remote.OnClientEvent:Connect(function(name, value)
        if name == "Coins" then coins = value
        elseif name == "Gems" then gems = value
        elseif name == "Tickets" then tickets = value
        elseif name == "Pearls" then pearls = value
        elseif name == "EggsOpened" and typeof(value) == "table" then
            local count = 0
            for _, v in pairs(value) do
                count = count + (tonumber(v) or 0)
            end
            totalHatches = count
        end
    end)
end

local function getBountyPetImageLink(petName)
    local petEntry = petsModule[petName]
    if not petEntry or not petEntry.Images then return nil end
    local assetStr = petEntry.Images["Normal"]
    local assetId = assetStr and assetStr:match("%d+")
    return assetId and ("https://ps99.biggamesapi.io/image/" .. assetId) or nil
end

local function formatBountyNumber(n)
    local str = tostring(math.floor(n))
    return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function formatBountyChance(chance)
    if not chance or chance <= 0 then return "N/A" end
    local inv = math.floor((1 / chance) * 100 + 0.5)
    return "1 in " .. formatBountyNumber(inv)
end

local function abbreviateNumber(num)
    num = tonumber(num) or 0
    local absNum = math.abs(num)

    if absNum >= 1e12 then
        return string.format("%.1fT", num / 1e12)
    elseif absNum >= 1e9 then
        return string.format("%.1fB", num / 1e9)
    elseif absNum >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif absNum >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

local function formatChance(chanceStr, variant)
    if not chanceStr then return "Unknown", math.huge end

    local cleanStr = tostring(chanceStr):gsub("%%", "")
    local num = tonumber(cleanStr)
    if not num or num <= 0 then 
        return tostring(chanceStr), math.huge 
    end

    if variant == "Shiny" then
        num = num / 40
    elseif variant == "Mythic" then
        num = num / 100
    elseif variant == "Shiny Mythic" then
        num = num / 4000
    end

    local oneIn = 100 / num

    local function approxNumber(n)
        if n >= 1e12 then
            return string.format("%.2fT", n / 1e12)
        elseif n >= 1e9 then
            return string.format("%.2fB", n / 1e9)
        elseif n >= 1e6 then
            return string.format("%.2fM", n / 1e6)
        elseif n >= 1e3 then
            return string.format("%.2fK", n / 1e3)
        else
            return string.format("%.2f", n)
        end
    end

    local percentStr
    if oneIn >= 100_000_000 then
        percentStr = string.format("%.0e", num) .. "%"
    else
        percentStr = string.format("%.10f", num):gsub("0+$", ""):gsub("%.$", "") .. "%"
    end

    return string.format("%s (1 in %s)", percentStr, approxNumber(oneIn)), oneIn
end

local function formatPlaytime()
    local elapsed = math.floor(tick() - startTime)
    local days = math.floor(elapsed / 86400)
    local hours = math.floor((elapsed % 86400) / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = elapsed % 60

    local parts = {}
    if days > 0 then table.insert(parts, days .. "d") end
    if hours > 0 or #parts > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 or #parts > 0 then table.insert(parts, minutes .. "m") end
    table.insert(parts, seconds .. "s")

    return table.concat(parts, " ")
end

local function isSecretBounty(petName)
    local ok, result = pcall(function()
        return secretBountyUtil.Get()
    end)

    if ok and typeof(result) == "table" and result.Name == petName then
        return true, result
    end
    return false, nil
end

local lastSentDate = nil
local function getDateKey()
    local now = os.date("!*t")
    return string.format("%04d-%02d-%02d", now.year, now.month, now.day)
end

local function getBoostedStats(stats, variant)
    local multiplier = 1
    if variant == "Shiny" then multiplier = 1.5
    elseif variant == "Mythic" then multiplier = 1.75
    elseif variant == "Shiny Mythic" then multiplier = 2.25 end

    local boosted = {}
    for stat, value in pairs(stats) do
        if typeof(value) == "number" then
            boosted[stat] = math.floor(value * multiplier)
        else
            boosted[stat] = value
        end
    end
    return boosted
end

local function getPetImageLink(petName, variant)
    local petEntry = petsModule[petName]
    if not petEntry or not petEntry.Images then return nil end

    local imageKey = ({
        ["Normal"] = "Normal",
        ["Shiny"] = "Shiny",
        ["Mythic"] = "Mythic",
        ["Shiny Mythic"] = "MythicShiny"
    })[variant]

    local assetStr = petEntry.Images[imageKey]
    local assetId = assetStr and assetStr:match("%d+")
    return assetId and ("https://ps99.biggamesapi.io/image/" .. assetId) or nil
end

local function sendBountyEmbed()
    local today = getDateKey()
    if lastSentDate == today then
        return
    end

    local current = secretBountyUtil:Get()
    if not current then return end

    local chanceFormatted = formatBountyChance(current.Chance)
    local petImage = getBountyPetImageLink(current.Name)

    local now = os.time()
    local tomorrowMidnightUTC = os.time(os.date("!*t", now))
    tomorrowMidnightUTC = tomorrowMidnightUTC - (tomorrowMidnightUTC % 86400) + 86400

    local embed = {
        title = "🎯 Secret Bounty",
        color = 16777215,
        fields = {
            { name = "Pet", value = current.Name, inline = true },
            { name = "Egg", value = current.Egg, inline = true },
            { name = "Chance", value = chanceFormatted, inline = true },
            { name = "Next", value = string.format("<t:%d:R>", tomorrowMidnightUTC), inline = false }
        },
        image = { url = petImage or "" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", now)
    }

    local payload = HttpService:JSONEncode({ embeds = { embed } })

    http_request({
        Url = bountyWebhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = payload
    })

    lastSentDate = today
end

coroutine.wrap(function()
    while true do
        local now = os.time()
        local utcNow = os.date("!*t", now)

        local nextMidnightUTC = os.time({
            year = utcNow.year,
            month = utcNow.month,
            day = utcNow.day,
            hour = 0,
            min = 0,
            sec = 0
        })
        if nextMidnightUTC <= now then
            nextMidnightUTC = nextMidnightUTC + 86400
        end

        local secondsToWait = nextMidnightUTC - now
        print("Aștept " .. secondsToWait .. "s până la 00:00 UTC (03:00 România)")

        task.wait(secondsToWait)

        sendBountyEmbed()

        while true do
            task.wait(86400)
            sendBountyEmbed()
        end
    end
end)()

local function sendDiscordWebhook(playerName, petName, variant, boostedStats, dropChance, egg, rarity, tier)
    local colorMap = {
        ["Normal"] = 65280,
        ["Shiny"] = 0xFFD700,
        ["Mythic"] = 0x8000FF,
        ["Shiny Mythic"] = 0x00FFFF,
        ["Secret"] = 0xFF0000,
        ["Secret Bounty"] = 0xFF8800,
        ["Infinity"] = 0xFFFFFF
    }
    local embedColor = colorMap[rarity] or colorMap[variant] or 65280

    local hatchCount = abbreviateNumber(totalHatches)
    local petImageLink = getPetImageLink(petName, variant)

    local petCurrencyLabel, petCurrencyValue = "", ""
    if boostedStats.Tickets then
        petCurrencyLabel = "<:ticket:1392626567464747028> Tickets"
        petCurrencyValue = tostring(boostedStats.Tickets)
    elseif boostedStats.Pearls then
        petCurrencyLabel = "<:pearls:1403707150513213550> Pearls"
        petCurrencyValue = tostring(boostedStats.Pearls)
    else
        petCurrencyLabel = "<:coins:1392626598188154977> Coins"
        petCurrencyValue = tostring(boostedStats.Coins or "N/A")
    end

    local userCoins = abbreviateNumber(getCurrencyAmount("Coins") or coins)
    local userPearls = abbreviateNumber(getCurrencyAmount("Pearls") or pearls)

    local displayPetName = petName
    if variant ~= "Normal" then
        displayPetName = variant .. " " .. petName
    end

    local description = string.format([[
🎉・**Hatch Info**
- 🥚 **Egg:** `%s`
- 🏆 **Chance:** `%s`
- 🎁 **Rarity:** `%s`
- 🔢 **Tier:** `%s`

✨・**Pet Stats**
- <:bubbles:1392626533826433144> **Bubbles:** `%s`
- <:gems:1392626582929277050> **Gems:** `%s`
- %s: `%s`

👤・**User Info**
- 🕒 **Playtime:** `%s`
- 🥚 **Hatches:** `%s`
- <:coins:1392626598188154977> **Coins:** `%s`
- <:pearls:1403707150513213550> **Pearls:** `%s`
- <:gems:1392626582929277050> **Gems:** `%s`
- <:ticket:1392626567464747028> **Tickets:** `%s`
    ]],
        egg or "Unknown",
        dropChance,
        rarity or "Legendary",
        tostring(tier or "1"),
        boostedStats.Bubbles or "N/A",
        boostedStats.Gems or "N/A",
        petCurrencyLabel,
        petCurrencyValue,
        formatPlaytime(),
        hatchCount,
        userCoins,
        userPearls,
        abbreviateNumber(getCurrencyAmount("Gems") or gems),
        abbreviateNumber(getCurrencyAmount("Tickets") or tickets)
    )

    local titleText, contentText = "", ""

    local variantPrefix = (variant ~= "Normal") and variant:upper() .. " " or "NORMAL "

    local contentRarity = rarity:upper()

    if rarity == "Infinity" then
        titleText = string.format("DAMN! ||%s|| hatched a %s! Unbelievable!", playerName, displayPetName)
        contentText = "@everyone " .. variantPrefix .. contentRarity .. "!"
    elseif rarity == "Secret" or rarity == "Secret Bounty" then
        titleText = string.format("WOW! ||%s|| hatched a %s! Lucky Guy!", playerName, displayPetName)
        contentText = "@everyone " .. variantPrefix .. contentRarity .. "!"
    else
        titleText = string.format("||%s|| hatched a %s", playerName, displayPetName)
    end

    http_request({
        Url = webhookUrl,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            content = contentText,
            embeds = {{
                author = {
                    name = "Pet Notification",
                    icon_url = "https://cdn.discordapp.com/avatars/1129886888958885928/243a7d079a2b7340cb54f43c1b87bfd9.webp?size=2048"
                },
                title = titleText,
                description = description,
                color = embedColor,
                thumbnail = petImageLink and { url = petImageLink } or nil
            }}
        })
    })
end

HatchEvent.OnClientEvent:Connect(function(action, data)
    if action ~= "HatchEgg" and action ~= "ExclusiveHatch" then return end
    if not data or not data.Pets then return end

    for _, petInfo in pairs(data.Pets) do
        local pet = petInfo.Pet
        if not pet then continue end

        local petName = pet.Name or "Unknown"
        local variant = "Normal"
        if pet.Shiny and pet.Mythic then
            variant = "Shiny Mythic"
        elseif pet.Shiny then
            variant = "Shiny"
        elseif pet.Mythic then
            variant = "Mythic"
        end

        local petEntry = petsModule[petName]
        if not petEntry then continue end

        local boostedStats = getBoostedStats(petEntry.Stats, variant)

        local eggName
        if action == "ExclusiveHatch" then
            eggName = petInfo.EggName or petEntry.Egg or "Unknown Egg"
        else
            if data.Name == "Infinity Egg" then
                eggName = petEntry.Egg or "Unknown"
            else
                eggName = eggsModule[data.Name] and eggsModule[data.Name].Name or data.Name or "Unknown"
            end
        end

        local rarity = petEntry.Rarity or "Unknown"
        local tier = petEntry.Tier or 1

        local bounty, secret = isSecretBounty(petName)
        local rawChance
        if bounty then
            rarity = "Secret Bounty"
            if secret then
                eggName = secret.Egg or eggName
                rawChance = secret.Chance or petEntry.Chance
            end
        else
            rawChance = petEntry.Chance or "Unknown"
        end

        local dropChance, oneIn = formatChance(rawChance, variant)

        if action == "ExclusiveHatch" then
            if oneIn < 500 then
                continue
            end
        else
            if oneIn < 1e6 then
                continue
            end
        end

        sendDiscordWebhook(
            localPlayer.Name, 
            petName, 
            variant, 
            boostedStats, 
            dropChance,
            eggName,  
            rarity,   
            tier      
        )
    end
end)

local function sendServerLuckEmbed(boostPercent, rawTimeLeft)
        local function parseTimeStringToSeconds(text)
                text = text:lower()
                local d = tonumber(text:match("(%d+)%s*day")) or 0
                local h, m, s = text:match("(%d+):(%d+):?(%d*)")
                h = tonumber(h) or 0
                m = tonumber(m) or 0
                s = tonumber(s) or 0
                return d * 86400 + h * 3600 + m * 60 + s
        end

        local function formatTimeAuto(totalSeconds)
                local hours = math.floor(totalSeconds / 3600 * 100) / 100

                if totalSeconds >= 86400 then
                        return string.format("%.0fh", hours) -- afieaz doar ore pentru zile
                elseif totalSeconds >= 3600 then
                        return string.format("%.2fh", hours)
                elseif totalSeconds >= 60 then
                        local minutes = math.floor(totalSeconds / 60 * 100) / 100
                        return string.format("%.2fm", minutes)
                else
                        return string.format("%ds", totalSeconds)
                end
        end

        local converted = formatTimeAuto(parseTimeStringToSeconds(rawTimeLeft))
        local joinLink = "https://fern.wtf/joiner?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
        local currentPlayers = #Players:GetPlayers()
        local maxPlayers = 12

        local description = string.format([[
🍀・**Luck Status**
- 🔥 **Boost:** `%s`
- ⏳ **Time Remaining:** `%s`
- ⌛ **Hours Left:** `%s`
- 👥 **Players:** `%d/%d`
- 🔗 **Join Link:** [Click Here](%s)
]], boostPercent, rawTimeLeft, converted, currentPlayers, maxPlayers, joinLink)

        local payload = {
                content = "",
                embeds = {{
                        author = {
                                name = "aerlrobos",
                                icon_url = "https://cdn.discordapp.com/avatars/1129886888958885928/243a7d079a2b7340cb54f43c1b87bfd9.webp?size=2048"
                        },
                        title = "ServerLuck Found!",
                        description = description,
                        color = tonumber("2F3136", 16)
                }}
        }

        http_request({
                Url = serverLuckWebhookUrl,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
        })
end

task.spawn(function()
        while not luckNotificationSent do
                local success, result = pcall(function()
                        local buffs = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Buffs")
                        local serverLuck = buffs:FindFirstChild("ServerLuck")

                        if serverLuck then
                                local button = serverLuck:FindFirstChild("Button")
                                if button then
                                        local amount = button:FindFirstChild("Amount")
                                        local label = button:FindFirstChild("Label")

                                        if amount and label and amount:IsA("TextLabel") and label:IsA("TextLabel") then
                                                local boostText = amount.Text
                                                local timeLeft = label.Text

                                                -- Ignor text default
                                                local defaultTimes = { "4:31:05", "0:00:00", "" }
                                                local isDefault = false
                                                for _, t in ipairs(defaultTimes) do
                                                        if timeLeft == t then
                                                                isDefault = true
                                                                break
                                                        end
                                                end

                                                if boostText:match("%%") and timeLeft:match("%d") and not isDefault then
                                                        if not luckNotificationSent then
                                                                luckNotificationSent = true
                                                                sendServerLuckEmbed(boostText, timeLeft)
                                                        end
                                                end
                                        end
                                end
                        end
                end)

                if not success then
                        warn("Eroare verificare ServerLuck:", result)
                end

                task.wait(5)
        end
end)

print("✅ Pet notifier & Server Luck activat pentru: " .. localPlayer.Name)

task.spawn(function()
    local RiftWebhooks = {
        ["brainrot-rift"]  = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["super-chest"]    = "https://discord.com/api/webhooks/1407847409450487829/G2T6NlRwrZecqXI4lxCp0VtT_1_bWn6CnENY2pUbj3rOW3n65MZE1_ZJ2lDsCPWcnKIG",
        ["neon-egg"]       = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["cyber-egg"]      = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["void-egg"]       = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["hell-egg"]       = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["crystal-egg"]    = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["royal-chest"]    = "https://discord.com/api/webhooks/1407847449594167306/sgv7c3PLn29bK1R4VCD4zLFyoijy0m3OSvRzcmB38cGyicfYLvKsp9nMUgjhiXQ6PjKp",
        ["golden-chest"]   = "https://discord.com/api/webhooks/1407847526928744529/t2EFKD7KPttgcaiZVRzRjw4WO6w2NZUj_n1x_Y7c4bSc0BB1y5YxzBK75PwAPEmCnuXG",
        ["nightmare-egg"]  = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["dice-rift"]      = "https://discord.com/api/webhooks/1407847452543025332/8wt1564_dILYw6Ncwpdf6qGm625JBYWObTXrAvg3G3no2FZdii3wI97U0k5tzThrkYbc",
        ["mining-egg"]     = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["bubble-rift"]    = "https://discord.com/api/webhooks/1391374774734946374/JK3ertej6d3Dkcp2zhXbGLJpFXHC4RRhJNGs-3UPmsV_vm4-2m-V4mGzAClLB0jOk4_o",
        ["spikey-egg"]     = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["magma-egg"]      = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["rainbow-egg"]    = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["lunar-egg"]      = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA"
    }

    local RiftThumbnails = {
        ["brainrot-rift"]  = "https://cdn.discordapp.com/attachments/1392217302153429022/1396395263643353098/Update_13_-_Bee_Rift.png",
        ["cyber-egg"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748857860226/Cyber_Egg.png",
        ["super-chest"]    = "https://cdn.discordapp.com/attachments/1392217302153429022/1393866766161018921/Super_Chest.png",
        ["neon-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393866766421332068/Neon_Egg.png",
        ["void-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725650776265/Void_Egg.png",
        ["hell-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359726020006080/Hell_Egg.png",
        ["crystal-egg"]    = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725025824899/Crystal_Egg.png",
        ["royal-chest"]    = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359723872649317/Royal_Chest.png",
        ["golden-chest"]   = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359723578789938/Golden_Chest.png",
        ["nightmare-egg"]  = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748207742986/Nightmare_Egg.png",
        ["dice-rift"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724149211266/Dice_Chest.png",
        ["mining-egg"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748652335164/Mining_Egg.png",
        ["bubble-rift"]    = "https://cdn.discordapp.com/attachments/1392217302153429022/1393360635596771478/Gum_Rift.png",
        ["spikey-egg"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724384223283/Spikey_Egg.png",
        ["magma-egg"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724782686250/Magma_Egg.png",
        ["rainbow-egg"]    = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748442886164/Rainbow_Egg.png",
        ["lunar-egg"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725336461372/Lunar_Egg.png"
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
                
                -- verificare multiplier special
                if rift.Name == "brainrot-rift" then
                    if not multiplier or (multiplier ~= 5 and multiplier ~= 10 and multiplier ~= 25) then
                        continue
                    end
                elseif rift.Name == "bubble-rift" then
                    -- bubble-rift NU verifică multiplier
                elseif not isChestRift then
                    if not multiplier or multiplier ~= 25 then
                        continue
                    end
                end

                local riftId = rift:GetDebugId() or (rift.Name .. game.JobId)
                if alreadyNotified[riftId] then continue end

                local primary = rift.PrimaryPart or rift:FindFirstChildWhichIsA("BasePart")
                if not primary then continue end

                alreadyNotified[riftId] = true

                local now = os.time()
                local despawn_time = now + 1800
                local timestamp = "<t:" .. despawn_time .. ":R>"
                local player_count = #Players:GetPlayers()
                local join_link = "https://fern.wtf/joiner?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
                local displayName = rift.Name:gsub("-", " ")
                local height = tostring(math.floor(primary.Position.Y))
                local thumbnail_url = RiftThumbnails[rift.Name] or ""

                local riftInfo = {
                    "**Server Info**",
                    "- **Players:** " .. tostring(player_count) .. "/12",
                    "- **Join Link:** [Click Here](" .. join_link .. ")",
                    "",
                    "**Rift Info**"
                }

                if multiplier then
                    table.insert(riftInfo, "- **Luck:** " .. multiplier .. "x")
                end

                table.insert(riftInfo, "- **Type:** " .. displayName)
                table.insert(riftInfo, "- **Despawns:** " .. timestamp)
                table.insert(riftInfo, "- **Height:** " .. height)

                local embedData = {
                    ["content"] = (rift.Name == "brainrot-rift") and "@everyone BRAINROT RIFT APPEARED! JOIN NOW!" or nil,
                    ["embeds"] = {{
                        ["title"] = formatTitle(rift.Name),
                        ["description"] = table.concat(riftInfo, "\n"),
                        ["color"] = (rift.Name == "brainrot-rift") and 0x00FF00 or tonumber("2F3136", 16),
                        ["author"] = {
                            ["name"] = "aerlrobos",
                            ["icon_url"] = "https://cdn.discordapp.com/attachments/1256255133545660511/1391365982353883266/1.png"
                        },
                        ["footer"] = { ["text"] = "Auto Rifts Notification" },
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
                    warn("Executorul nu suport request-uri.")
                end
            end
        end
        task.wait(5)
    end
end)

print("✅ Rifts activat pentru: " .. localPlayer.Name)

task.spawn(autoChest)
task.spawn(autoPlaytimeReward)
task.spawn(autoClaimSeasonReward)