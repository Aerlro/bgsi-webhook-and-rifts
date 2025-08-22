local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Webhook-ul tău
local WEBHOOK_URL = "https://discord.com/api/webhooks/1407847455902662768/xWn94IDXW-ExWhJ0JGX5GF9Uefa9vOAzea2qNMJKVMbKq9yXE9ZHiLxFNX_dpft_XB1S"

-- SecretBountyUtil
local secretBountyUtil = require(ReplicatedStorage.Shared.Utils.Stats:WaitForChild("SecretBountyUtil"))

-- Imagini pentru pet-uri
local petImages = {
    ["Giant D.I.Y Robot"] = "https://static.wikia.nocookie.net/bgs-infinity/images/2/2d/Giant_D.I.Y_Robot.png/revision/latest?cb=20250727223840",
    ["Gumdrop King"] = "https://static.wikia.nocookie.net/bgs-infinity/images/8/89/Gumdrop_King.png/revision/latest?cb=20250727223840",
}

-- Șanse fixe pentru embed
local petChances = {
    ["Gumdrop King"] = "1 in 80,000,000",
    ["Giant D.I.Y Robot"] = "1 in 250,000,000"
}

-- Obține bounty actual
local function getCurrentBounty()
    return secretBountyUtil:Get()
end

-- Trimite embed la Discord
local function sendBountyEmbed()
    local current = getCurrentBounty()

    -- Ora următorului bounty: 3 AM România = 00:00 UTC
    local now = os.time()
    local tomorrow = os.date("!*t", now)
    tomorrow.day = tomorrow.day + 1
    tomorrow.hour = 0
    tomorrow.min = 0
    tomorrow.sec = 0
    local nextBountyTime = os.time(tomorrow)

    local embed = {
        title = "✨ Secret Bounty",
        color = 16777215, -- alb
        fields = {
            {name = "Pet", value = current.Name, inline = true},
            {name = "Egg", value = current.Egg, inline = true},
            {name = "Chance", value = petChances[current.Name] or "N/A", inline = true},
            {name = "Next", value = string.format("<t:%d:R>", nextBountyTime), inline = false}
        },
        image = {url = petImages[current.Name] or ""},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", now)
    }

    local payload = HttpService:JSONEncode({embeds = {embed}})

    http_request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = payload
    })
end

-- === Trimite imediat la start
sendBountyEmbed()

-- === Calculează cât timp până la următorul 00:00 UTC
local now = os.time()
local todayUTC = os.date("!*t", now)
todayUTC.hour, todayUTC.min, todayUTC.sec = 0,0,0
local midnightUTC = os.time(todayUTC)

if now >= midnightUTC then
    midnightUTC = midnightUTC + 86400 -- dacă a trecut, mergem la următoarea zi
end

local waitUntilMidnight = midnightUTC - now
task.wait(waitUntilMidnight)

-- === Trimite exact la 00:00 UTC (03:00 România)
sendBountyEmbed()

-- === De aici rulează la fiecare 24h fix
while true do
    task.wait(86400)
    sendBountyEmbed()
end
