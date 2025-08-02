local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local petsModule = require(rs.Shared.Data.Pets)

local webhookUrl = "https://discord.com/api/webhooks/1391374778882986035/KzVd6EaiXL73gd2YN_FIIHt-d36SeaKONLqsjPGiTDin65p_KrRBLfwr7saQpbXUZCFI"
local serverLuckWebhookUrl = "https://discord.com/api/webhooks/1391368932761276436/eUsp8pJMsgzC3APxmw_qN64bWZrWyKEUIZraHTLFLUqi7yh0TMvXWEVBl3AnkHjMSfXi"

local localPlayer = Players.LocalPlayer
print("Roblox Name: " .. localPlayer.Name)
local luckNotificationSent = false

local systemMessageEvent = rs:WaitForChild("Shared"):WaitForChild("Framework")
    :WaitForChild("Utilities"):WaitForChild("SendSystemMessage"):WaitForChild("RemoteEvent")

local remote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("PlayerDataChanged")
local startTime = tick()
local coins, gems, tickets = "N/A", "N/A", "N/A"
local totalHatches = 0

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
        wait(10)
    end
end)()

if remote then
    remote.OnClientEvent:Connect(function(name, value)
        if name == "Coins" then coins = value
        elseif name == "Gems" then gems = value
        elseif name == "Tickets" then tickets = value
        elseif name == "EggsOpened" and typeof(value) == "table" then
            local count = 0
            for _, v in pairs(value) do
                count = count + (tonumber(v) or 0)
            end
            totalHatches = count
        end
    end)
end

local function convertTimeLeftText(timeText)
	timeText = timeText:lower()

	if timeText:match("^%d+:%d+") then
		local h, m, s = timeText:match("(%d+):(%d+):?(%d*)")
		h = tonumber(h) or 0
		m = tonumber(m) or 0
		s = tonumber(s) or 0
		local totalSeconds = h * 3600 + m * 60 + s
		local hours = totalSeconds / 3600
		return string.format("%.2fh", hours)
	end

	local days = timeText:match("(%d+)%s*day")
	if days then
		local hours = tonumber(days) * 24
		return string.format("%dh", hours)
	end

	return timeText
end

local function formatTimeAuto(totalSeconds)
	local d = math.floor(totalSeconds / 86400)
	local h = math.floor((totalSeconds % 86400) / 3600)
	local m = math.floor((totalSeconds % 3600) / 60)
	local s = totalSeconds % 60

	if d > 0 then
		local hours = math.floor(totalSeconds / 3600 * 100) / 100
		return string.format("%.0fd (%sh)", d, hours)
	elseif h > 0 then
		local hours = math.floor(totalSeconds / 3600 * 100) / 100
		return string.format("%.2fh", hours)
	elseif m > 0 then
		local minutes = math.floor(totalSeconds / 60 * 100) / 100
		return string.format("%.2fm", minutes)
	else
		return string.format("%ds", s)
	end
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

local function formatChance(chanceStr)
    local cleanStr = chanceStr:gsub("%%", "")
    local num = tonumber(cleanStr)
    if not num or num <= 0 then return chanceStr end

    local oneIn = 100 / num
    local function approxNumber(n)
        if n >= 1e12 then
            return string.format("%.2fT", n / 1e12)
        elseif n >= 1e9 then
            return string.format("%.2fB", n / 1e9)
        elseif n >= 1e6 then
            return string.format("%.2fM", n / 1e6)
        elseif n >= 1e3 then
            return string.format("%.1fK", n / 1e3)
        else
            return tostring(math.floor(n))
        end
    end

    local percentStr = ""
    if oneIn <= 100_000_000 then
        if num >= 1 then
            percentStr = tostring(math.floor(num * 100 + 0.5) / 100) .. "%"
        elseif num >= 0.01 then
            percentStr = string.format("%.3f", num):gsub("0+$", ""):gsub("%.$", "") .. "%"
        else
            percentStr = string.format("%.6f", num):gsub("0+$", ""):gsub("%.$", "") .. "%"
        end
    else
        percentStr = string.format("%.0e", num) .. "%"
    end

    return string.format("%s (1 in %s)", percentStr, approxNumber(oneIn))
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

local function sendDiscordWebhook(playerName, petName, variant, boostedStats, dropChance, egg, rarity, tier)
    local colorMap = {
        ["Normal"] = 65280,
        ["Shiny"] = 0xFFD700,
        ["Mythic"] = 0x8000FF,
        ["Shiny Mythic"] = 0x00FFFF,
        ["Secret"] = 0xFF0000,
        ["Infinity"] = 0xFFFFFF
    }
    local embedColor = colorMap[rarity] or colorMap[variant] or 65280

    local hatchCount = abbreviateNumber(totalHatches)
    local petImageLink = getPetImageLink(petName, variant)
    local petFullName = (variant ~= "Normal" and (variant .. " ") or "") .. petName

    local description = string.format([[
🎉・**Hatch Info**
- 🥚 **Egg:** `%s`
- 🏆 **Chance:** `%s`
- 🎁 **Rarity:** `%s`
- 🔢 **Tier:** `%s`

✨・**Pet Stats**
- <:bubbles:1392626533826433144> **Bubbles:** `%s`
- <:gems:1392626582929277050> **Gems:** `%s`
- <:coins:1392626598188154977> **Coins:** `%s`

👤・**User Info**
- 🕒 **Playtime:** `%s`
- 🥚 **Hatches:** `%s`
- <:coins:1392626598188154977> **Coins:** `%s`
- <:gems:1392626582929277050> **Gems:** `%s`
- <:ticket:1392626567464747028> **Tickets:** `%s`
    ]],
        egg or "Unknown",
        formatChance(dropChance or "Unknown"),
        rarity or "Legendary",
        tier or "1",
        boostedStats.Bubbles or "N/A",
        boostedStats.Gems or "N/A",
        boostedStats.Coins or "N/A",
        formatPlaytime(),
        hatchCount,
        abbreviateNumber(getCurrencyAmount("Coins") or coins),
        abbreviateNumber(getCurrencyAmount("Gems") or gems),
        abbreviateNumber(getCurrencyAmount("Tickets") or tickets)
    )

    local titleText = ""
    local contentText = ""

    if rarity == "Infinity" then
        titleText = string.format("DAMN! ||%s|| hatched a %s! Unbelievable!", playerName, petFullName)
        contentText = "@everyone"
    elseif rarity == "Secret" then
        titleText = string.format("WOW! ||%s|| hatched a %s! Lucky Guy!", playerName, petFullName)
        contentText = "@everyone"
    else
        titleText = string.format("||%s|| hatched a %s", playerName, petFullName)
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

systemMessageEvent.OnClientEvent:Connect(function(message)
    if typeof(message) ~= "string" then return end
    if not message:find(localPlayer.Name) then return end

    message = message:gsub("<[^>]->", "")
    local petData, chanceStr = string.match(message, "hatched a (.+) %(([%d%.eE%-]+%%)%)")
    if not petData or not chanceStr then return end

    local variant = "Normal"
    local petName = petData

    if string.find(petData, "Shiny") and string.find(petData, "Mythic") then
        variant = "Shiny Mythic"
        petName = petName:gsub("Shiny Mythic ", "")
    elseif string.find(petData, "Shiny") then
        variant = "Shiny"
        petName = petName:gsub("Shiny ", "")
    elseif string.find(petData, "Mythic") then
        variant = "Mythic"
        petName = petName:gsub("Mythic ", "")
    end

    petName = petName:match("^%s*(.-)%s*$")
    local petEntry = petsModule[petName]
    if not petEntry or not petEntry.Stats then
        warn("⚠️ Pet not found in module:", petName)
        return
    end

    local boostedStats = getBoostedStats(petEntry.Stats, variant)
    local egg = petEntry.Egg or "Unknown"
    local rarity = petEntry.Rarity or "Legendary"
    local tier = petEntry.Tier or "1"

    sendDiscordWebhook(localPlayer.Name, petName, variant, boostedStats, chanceStr, egg, rarity, tier)
end)

local function sendServerLuckEmbed(boostPercent, rawTimeLeft)
	local converted = convertTimeLeftText(rawTimeLeft)

	local joinLink = "https://fern.wtf/joiner?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
	local currentPlayers = #Players:GetPlayers()
	local maxPlayers = 12

	local description = string.format([[
🍀・**Luck Status**
- 🔥 **Boost:** `%s`
- ⏳ **Time Remaining:** `%s`
- ⌛ **Hours Left:** `%s`
- 👥 **Players:** `%s/%s`
- 🔗 **Join Link:** [Click Here](%s)
]], boostPercent, rawTimeLeft, converted, currentPlayers, maxPlayers, joinLink)

	local titleText = "ServerLuck Found!"

	HttpService:RequestAsync({
		Url = serverLuckWebhookUrl,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode({
			content = "",
			embeds = {{
				author = {
					name = "aerlrobos",
					icon_url = "https://cdn.discordapp.com/avatars/1129886888958885928/243a7d079a2b7340cb54f43c1b87bfd9.webp?size=2048"
				},
				title = titleText,
				description = description,
				color = tonumber("2F3136", 16)
			}}
		})
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

						if boostText:match("%%") and timeLeft:match("%d") then
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
        ["bee-egg"] = "https://discord.com/api/webhooks/1396399702282473554/Bl0wYsDFPB97EPqKeojXv5JsV2UYaMo_wGwgdo_rjpsQXAUTOHxf2Kzo1JGDZvzpGzFA",
        ["super-chest"] = "https://discord.com/api/webhooks/1391374777981206548/LBpfKoLMiDIjOMLpU_jb_HhPQJ-J5n--U2Ao5PvFzMM2ybzx3eqIJZv1nCz4vb8cjKwn",
        ["neon-egg"] = "https://discord.com/api/webhooks/1391374778195251210/n4Q2mz6h4rVbGxsJxDkFmZ4nIeyOe8jKybLe-G-2ZfqnTTVBJT4pzNWyESRyReolcQaM",
        ["cyber-egg"]       = "https://discord.com/api/webhooks/1391374777335156818/4cKl6U8nMjlOVx4NximkLpXqwT73gShGWILiVmEZL7hP5RrdqdRlc9UIaddEiDiT_Nyu",
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

    local RiftThumbnails = {
        ["bee-egg"] = "https://cdn.discordapp.com/attachments/1392217302153429022/1396395263643353098/Update_13_-_Bee_Rift.png?ex=687dedee&is=687c9c6e&hm=4dd9e3656796054b7d02bcc82880e85f388fa3869b374ca5eb7c6bf334aeec3a&",
        ["cyber-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748857860226/Cyber_Egg.png",
        ["super-chest"] = "https://cdn.discordapp.com/attachments/1392217302153429022/1393866766161018921/Super_Chest.png?ex=6874bb15&is=68736995&hm=9ad0e179e0e4b0bb457af2f8ad0b3551622617aa89e14320b1fa068dfcca3f4d&",
        ["neon-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393866766421332068/Neon_Egg.png?ex=6874bb15&is=68736995&hm=6e9e7a3b226c4184bda547f8008086398f78efe0addfe110e831745ab1185372&",
        ["void-egg"]        = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725650776265/Void_Egg.png",
        ["hell-egg"]        = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359726020006080/Hell_Egg.png",
        ["crystal-egg"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725025824899/Crystal_Egg.png",
        ["royal-chest"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359723872649317/Royal_Chest.png",
        ["golden-chest"]    = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359723578789938/Golden_Chest.png",
        ["nightmare-egg"]   = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748207742986/Nightmare_Egg.png",
        ["dice-rift"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724149211266/Dice_Chest.png",
        ["mining-egg"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748652335164/Mining_Egg.png",
        ["bubble-rift"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393360635596771478/Gum_Rift.png",
        ["spikey-egg"]      = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724384223283/Spikey_Egg.png",
        ["magma-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359724782686250/Magma_Egg.png",
        ["rainbow-egg"]     = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359748442886164/Rainbow_Egg.png",
        ["lunar-egg"]       = "https://cdn.discordapp.com/attachments/1392217302153429022/1393359725336461372/Lunar_Egg.png"
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

                local now = os.time()
                local despawn_time = now + 1800
                local timestamp = "<t:" .. despawn_time .. ":R>"
                local player_count = #Players:GetPlayers()
                local join_link = "https://fern.wtf/joiner?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
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
                    warn("Executorul nu suportă request-uri.")
                end
            end
        end
        task.wait(5)
    end
end)

print("✅ Rifts activat pentru: " .. localPlayer.Name)
