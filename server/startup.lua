-- Bank Server

-- Bank API is split into lib/bankapi.lua + lib/uilib.lua + lib/net.lua + lib/cards.lua
-- (lib/bankapi.lua loads the others; bankapi.* keeps all the classic functions)
os.loadAPI("lib/bankapi.lua")
if (updateAvailable == nil) then os.loadAPI("updater.lua") end

-------------------- Params
local currency = {
	diamond = {
		[1] = {
			id="minecraft:diamond",
			value=1,
			name={en="Diamond",es="Diamante",de="Diamant",fr="Diamant",pl="Diament"},
			plural={en="Diamonds",es="Diamantes",de="Diamanten",fr="Diamants",pl="Diamenty"},
			short={en="D",es="D",de="D",fr="D",pl="D"},
			uprecipe={need=9,yield=1,result="minecraft:diamond_block"}
		},
		[2] = {
			id="minecraft:diamond_block",
			value=9,
			name={en="Diamond Block",es="Bloque de Diamante",de="Diamantblock",fr="Bloc de Diamant",pl="Blok Diamentu"},
			plural={en="Diamond Blocks",es="Bloques de Diamante",de="Diamantbloecke",fr="Blocs de Diamant",pl="Bloki Diamentu"},
			short={en="Bl",es="Bl",de="Bl",fr="Bl",pl="Bl"},
			downrecipe={need=1,yield=9,result="minecraft:diamond_block"}
		}
	},
	gold = {
		[1] = {
			id="minecraft:gold_nugget",
			value=1,
			name={en="Gold Nugget",es="Pepita de Oro",de="Goldnugget",fr="Pepite d'Or",pl="Samorodek Zlota"},
			plural={en="Gold Nuggets",es="Pepitas de Oro",de="Goldnuggets",fr="Pepites d'Or",pl="Samorodki Zlota"},
			short={en="N",es="P",de="N",fr="P",pl="S"},
			uprecipe={need=9,yield=1,result="minecraft:gold_ingot"}
		},
		[2] = {
			id="minecraft:gold_ingot",
			value=9,
			name={en="Gold Ingot",es="Lingote de Oro",de="Goldbarren",fr="Lingot d'Or",pl="Sztabka Zlota"},
			plural={en="Gold Ingots",es="Lingotes de Oro",de="Goldbarren",fr="Lingots d'Or",pl="Sztabki Zlota"},
			short={en="I",es="L",de="B",fr="L",pl="Z"},
			downrecipe={need=1,yield=9,result="minecraft:gold_nugget"},
			uprecipe={need=9,yield=1,result="minecraft:gold_block"}
		},
		[3] = {
			id="minecraft:gold_block",
			value=81,
			name={en="Gold Block",es="Bloque de Oro",de="Goldblock",fr="Bloc d'Or",pl="Blok Zlota"},
			plural={en="Gold Blocks",es="Bloques de Oro",de="Goldbloecke",fr="Blocs d'Or",pl="Bloki Zlota"},
			short={en="B",es="B",de="B",fr="B",pl="B"},
			downrecipe={need=1,yield=9,result="minecraft:gold_ingot"}
		}
	},
	emerald = {
		[1] = {
			id="minecraft:emerald",
			value=1,
			name={en="Emerald",es="Esmeralda",de="Smaragd",fr="Emeraude",pl="Szmaragd"},
			plural={en="Emeralds",es="Esmeraldas",de="Smaragde",fr="Emeraudes",pl="Szmaragdy"},
			short={en="E",es="E",de="S",fr="E",pl="S"},
			uprecipe={need=9,yield=1,result="minecraft:emerald_block"}
		},
		[2] = {
			id="minecraft:emerald_block",
			value=9,
			name={en="Emerald Block",es="Bloque de Esmeralda",de="Smaragdblock",fr="Bloc d'Emeraude",pl="Blok Szmaragdu"},
			plural={en="Emerald Blocks",es="Bloques de Esmeralda",de="Smaragdbloecke",fr="Blocs d'Emeraude",pl="Bloki Szmaragdu"},
			short={en="Bl",es="Bl",de="Bl",fr="Bl",pl="Bl"},
			downrecipe={need=1,yield=9,result="minecraft:emerald_block"}
		}
	}
}
-----------------------------

local cumulativeLimit = 5000 -- Every x money moved, you get charged
local cumulativePrice = 100 -- How much you pay
local lang = "en-us"
local currencyType = "diamond"
local terminalPassword = "1234"
local valueMultiplier = 100
local bankOwnerKey = 0
local cardPrefix = "10" -- First 2 digits of every card id (xx-xxxx-xxxx-xxxx)
local accountPrefix = "MER" -- First 3 letters of every account id (xxx-xxxxxxxxxxx)

-------------------- Variables
local clientData = {}
local filePath = "bank/"
-- Custom currencies defined by the bank owner (name -> currency table),
-- stored in bank/customCurrencies.txt
local customCurrencies = {}
--------------------

-------------------- Functions
local function updateSettingsFile()
	local f = fs.open(filePath.."settings.txt", "w")
	f.writeLine("Language:") -- Language label
	f.writeLine(lang)
	f.writeLine("Currency type:") -- Currency label
	f.writeLine(currencyType)
	f.writeLine("Currency value multiplier:") -- Value multiplier label
	f.writeLine(valueMultiplier)
	f.writeLine("Admin password:") -- Password label
	f.writeLine(terminalPassword)
	f.writeLine("Cumulative limit:") -- Cumulative limit label
	f.writeLine(cumulativeLimit)
	f.writeLine("Limit reach cost:") -- Cumulative price label
	f.writeLine(cumulativePrice)
	f.writeLine("Bank owner ID:") -- Bank owner label
	f.writeLine(bankOwnerKey)
	f.writeLine("Card prefix:") -- Card prefix label
	f.writeLine(cardPrefix)
	f.writeLine("Account prefix:") -- Account prefix label
	f.writeLine(accountPrefix)
	f.close()
end

local function serverSettings()
	if (fs.exists(filePath.."settings.txt")) then
		local f = fs.open(filePath.."settings.txt", "r")
		f.readLine() -- Language label
		local line = f.readLine()
		if (line ~= nil and fs.exists("lang/"..line..".json")) then lang = line else lang = "en-us" end
		f.readLine() -- Currency type label
		currencyType = f.readLine()
		f.readLine() -- Value multiplier label
		valueMultiplier = f.readLine()
		f.readLine() -- Password label
		terminalPassword = f.readLine()
		f.readLine() -- Cumulative limit label
		cumulativeLimit = f.readLine()
		f.readLine() -- Cumulative price label
		cumulativePrice = f.readLine()
		f.readLine() -- Bank Owner label
		bankOwnerKey = f.readLine()
		f.readLine() -- Card prefix label
		local cp = f.readLine()
		if (cp ~= nil and string.match(cp, "^%d%d$")) then cardPrefix = cp end
		f.readLine() -- Account prefix label
		local ap = f.readLine()
		if (ap ~= nil and string.match(ap, "^%a%a%a$")) then accountPrefix = string.upper(ap) end
		f.close()
	else updateSettingsFile() end
end

local function loadClients()
	local f = fs.open(filePath.."clientList.txt", "r")
	if (f ~= nil) then
		local line = f.readLine()
		clientData = {}
		repeat
			local key = line
			clientData[key] = {}
			local cf = fs.open(filePath.."clientData/"..key.."/info.txt", "r")
			local cline = cf.readLine()
			repeat
				if (cline == "name") then
					cline = cf.readLine()
					clientData[key].name = cline
				elseif (cline == "balance") then
					cline = cf.readLine()
					clientData[key].balance = tonumber(cline)
				elseif (cline == "color") then
					cline = cf.readLine()
					clientData[key].color = tonumber(cline)
				elseif (cline == "cumulative") then
					cline = cf.readLine()
					clientData[key].cumulative = tonumber(cline)
				end
				cline = cf.readLine()
			until cline == nil or cline == ""
			cf.close()

			line = f.readLine()
		until line == nil or line == ""
		f.close()
	end
end

local function getClientData(data)
	loadClients()
	return true, clientData
end

local function getServerData(data)
	return true, {lang = lang, currency = currency[currencyType], valueMultiplier = valueMultiplier, terminalPassword = terminalPassword, cumulativeLimit = cumulativeLimit, cumulativePrice = cumulativePrice, cardPrefix = cardPrefix, accountPrefix = accountPrefix}
end

-------------------- Custom currencies -------------------
-- A custom currency looks exactly like a built-in one:
--   customCurrencies["mycoin"] = { [1] = { id=..., value=..., name={...}, plural={...}, short={...} } }
-- They are merged into `currency` so everything downstream (ATM,
-- shop, transactions) treats them identically.

local function loadCustomCurrencies()
	customCurrencies = {}
	if (not fs.exists(filePath.."customCurrencies.txt")) then return end
	local f = fs.open(filePath.."customCurrencies.txt", "r")
	if (f == nil) then return end
	local line = f.readLine()
	local block = {}
	while line ~= nil do
		if (line == "currency") then
			block = {}	elseif (line == "end") then
		if (block.id ~= nil) then
			customCurrencies[block.key] = {
				[1] = {
					id = block.id,
					value = tonumber(block.value) or 1,
					name = block.name or {},
					plural = block.plural or {},
					short = block.short or {}
				}
			}
		end
		block = {}
	elseif (line ~= "" and line ~= nil) then
			local key, value = string.match(line, "^(%w+) (.*)$")
			if (key == "name" or key == "plural" or key == "short") then
				local langCode, text = string.match(value, "^(%S+) (.*)$")
				block[key] = block[key] or {}
				block[key][langCode] = text
			elseif (key ~= nil) then
				block[key] = value
			end
		end
		line = f.readLine()
	end
	f.close()
end

local function saveCustomCurrencies()
	local f = fs.open(filePath.."customCurrencies.txt", "w")
	for key, denominations in pairs(customCurrencies) do
		for _, item in pairs(denominations) do
			f.writeLine("currency")
			f.writeLine("key "..key)
			f.writeLine("id "..item.id)
			f.writeLine("value "..tostring(item.value))
			for langCode, text in pairs(item.name) do
				f.writeLine("name "..langCode.." "..text)
			end
			for langCode, text in pairs(item.plural) do
				f.writeLine("plural "..langCode.." "..text)
			end
			for langCode, text in pairs(item.short) do
				f.writeLine("short "..langCode.." "..text)
			end
			f.writeLine("end")
		end
	end
	f.close()
end

-- Merge custom currencies into the currency table (built-ins win on name clash)
local function refreshCurrencyTable()
	for key, denominations in pairs(customCurrencies) do
		if (currency[key] == nil) then currency[key] = denominations end
	end
end

-- ver data (dotenv file) served to updating clients
local function getVersion(data) return true, { ver = updater.readVer("") } end

-- Serve one file (chunked) to a client that is updating itself
local function getFile(data)
	local success, response = updater.serveFileChunk(data.path, tonumber(data.offset) or 0)
	if (success) then return true, response end
	return false, response
end

-------------------- Card registry (paper cards) -------------------
-- cards.txt: one card per block:
--   cardId / expiration / cvc / account
local cardRegistry = {}

local function loadCards()
	cardRegistry = {}
	if (not fs.exists(filePath.."cards.txt")) then return end
	local f = fs.open(filePath.."cards.txt", "r")
	if (f == nil) then return end
	local line = f.readLine()
	while line ~= nil do
		local card = {}
		while line ~= nil and line ~= "" do
			if (line == "cardId") then
				card.cardId = f.readLine()
			elseif (line == "expiration") then
				card.expiration = f.readLine()
			elseif (line == "cvc") then
				card.cvc = f.readLine()
			elseif (line == "account") then
				card.account = f.readLine()
			end
			line = f.readLine()
		end
		if (card.cardId ~= nil) then
			cardRegistry[card.cardId] = card
		end
		line = f.readLine()
	end
	f.close()
end

local function saveCards()
	local f = fs.open(filePath.."cards.txt", "w")
	for _, card in pairs(cardRegistry) do
		f.writeLine("cardId")
		f.writeLine(card.cardId)
		f.writeLine("expiration")
		f.writeLine(card.expiration)
		f.writeLine("cvc")
		f.writeLine(card.cvc)
		f.writeLine("account")
		f.writeLine(card.account)
		f.writeLine("")
	end
	f.close()
end

local function updateCardsFile()
	saveCards()
end

-- Issue a new card for an account. Bank chooses the 2-digit prefix.
local function assignCard(data) --account
	local account = data.account
	loadClients()
	if (account == nil or clientData[account] == nil) then
		return false, tk("server.error_account")
	end
	loadCards()

	local card = {
		cardId = bankapi.generateCardId(cardPrefix),
		expiration = bankapi.generateExpiration(),
		cvc = bankapi.generateCVC(),
		account = account
	}
	while (cardRegistry[card.cardId] ~= nil) do
		card.cardId = bankapi.generateCardId(cardPrefix)
	end

	cardRegistry[card.cardId] = card
	saveCards()

	return true, card
end

-- Log in with a printed card: the client sends the decoded card table
local function cardLogin(data) --card = {cardId, expiration, cvc}
	local card = data.card
	if (card == nil or card.cardId == nil) then
		return false, tk("card.invalid_card")
	end
	loadCards()
	local stored = cardRegistry[card.cardId]
	if (stored == nil) then
		return false, tk("card.invalid_card")
	end
	if (stored.expiration ~= card.expiration or stored.cvc ~= card.cvc) then
		return false, tk("card.invalid_card")
	end
	if (bankapi.cardExpired(stored.expiration)) then
		return false, tk("card.card_expired")
	end
	loadClients()
	if (clientData[stored.account] == nil) then
		return false, tk("server.error_account")
	end
	return true, stored.account
end

local function updateClientFile(key)
	local f = fs.open(filePath.."clientData/"..key.."/info.txt", "w")
	if (f == nil) then return false, tk("server.error_account") end

	f.writeLine("name")
	f.writeLine(clientData[key].name)
	f.writeLine("balance")
	f.writeLine(tostring(clientData[key].balance))
	f.writeLine("color")
	f.writeLine(tostring(clientData[key].color))
	f.writeLine("cumulative")
	f.writeLine(tostring(clientData[key].cumulative))
	f.close()

	return true, tk("server.success_update")
end

local function appendTransactionToLog(from, to, amount, balance, time, description)
	local f = fs.open(filePath.."clientData/"..from.."/log.txt", "a")
	f.writeLine("other")
	f.writeLine(to)
	f.writeLine("amount")
	f.writeLine(tostring(-amount))
	f.writeLine("balance")
	f.writeLine(tostring(balance))
	f.writeLine("time")
	f.writeLine(time)
	f.writeLine("description")
	f.writeLine(description)
	f.writeLine("")
	f.close()
end

local function getCurrentTime()
	return os.date("%d/%m/%Y %H:%M")
end

local function addCumulative(key, amount)
	if (cumulativeLimit == 0) then return nil end
	if (cumulativePrice == 0) then return nil end
	clientData[key].cumulative = clientData[key].cumulative+amount
	if (bankOwnerKey ~= 0) then
		if (key ~= bankOwnerKey) then
			if (clientData[bankOwnerKey] ~= nil) then
				local tax = 0
				local cumulative = clientData[key].cumulative
				while cumulative >= cumulativeLimit do
					tax = tax+cumulativePrice
					cumulative = cumulative-cumulativeLimit
				end
				if (tax > 0) then
					if clientData[key].balance >= tax then
						transaction({
							from = key,
							to = bankOwnerKey,
							amount = tax,
							description = tk("server.expenses")
						}, false)
						clientData[key].cumulative = cumulative
					end
				end
			end
		end
	end
end

-- Move money from one account to another
function transaction(data, addToCumulative) --from, to, amount, description
	if (addToCumulative == nil) then addToCumulative = true end
	local from = tostring(data.from)
	local to = tostring(data.to)
	local amount = tonumber(data.amount)
	local description = data.description

	amount = math.ceil(amount*100)/100

	if (amount == 0 or amount == nil) then
		return false, tk("server.error_invalidamount")
	end

	loadClients()

	if (from == to) then
		return false, tk("server.error_same")
	end
	if (clientData[from] == nil) then
		return false, tk("server.error_from").." ("..from..")"
	end
	if (clientData[to] == nil) then
		return false, tk("server.error_to").." ("..to..")"
	end

	local previousFromBalance = clientData[from].balance
	local newFromBalance = previousFromBalance-amount

	if (newFromBalance < 0 and not addToCumulative) then
		return false, tk("server.error_notenoughbalance")
	end

	local previousToBalance = clientData[to].balance
	local newToBalance = previousToBalance+amount
	local time = getCurrentTime()

	clientData[from].balance = newFromBalance
	clientData[to].balance = newToBalance

	updateClientFile(from)
	updateClientFile(to)

	appendTransactionToLog(from, to, amount, newFromBalance, time,description)
	appendTransactionToLog(to, from, -amount, newToBalance, time, description)

	if (addToCumulative) then
		loadClients()
		addCumulative(from, amount)
		addCumulative(to, amount)
		updateClientFile(from)
		updateClientFile(to)
	end

	return true, tk("server.success_transaction")
end

local function deposit(data) --key, amount
	local key = data.key
	local amount = tonumber(data.amount)
	local description = tk("server.deposit_description")

	--print(textutils.serialise(data))
	if (amount == 0 or amount == nil) then
		return false, tk("server.error_invalidamount")
	end

	loadClients()

	if (clientData[key] == nil) then
		return false, tk("server.error_from").." ("..key..")"
	end

	local previousBalance = clientData[key].balance
	local newBalance = previousBalance+amount

	local time = getCurrentTime()

	clientData[key].balance = newBalance
	updateClientFile(key)

	appendTransactionToLog(key, key, -amount, newBalance, time, description)

	return true, tk("server.success_transaction")
end

local function withdraw(data) --key, amount
	local key = data.key
	local amount = tonumber(data.amount)
	local description = tk("server.withdraw_description")

	if (amount == 0 or amount == nil) then
		return false, tk("server.error_invalidamount")
	end

	loadClients()

	if (key == nil or clientData[key] == nil) then
		return false, tk("server.error_from").." ("..tostring(key)..")"
	end

	local previousBalance = clientData[key].balance
	local newBalance = previousBalance-amount

	if (newBalance < 0) then
		return false, tk("server.error_notenoughbalance")
	end

	local time = getCurrentTime()
	clientData[key].balance = newBalance
	updateClientFile(key)

	appendTransactionToLog(key, key, amount, newBalance, time, description)

	return true, tk("server.success_transaction")
end

local function getTransactionLog(data) --key
	local key = data.key

	local log = {}
	local logCounter = 1
	local f = fs.open(filePath.."clientData/"..key.."/log.txt", "r")
	local line = f.readLine()
	while line ~= nil do
		local lline = line
		local other = ""
		local amount = 0
		local balance = 0
		local time = ""
		local description = ""

		while lline ~= "" and lline ~= nil do
			if (lline == "other") then
				other = f.readLine()
			elseif (lline == "amount") then
				amount = f.readLine()
			elseif (lline == "balance") then
				balance = f.readLine()
			elseif (lline == "time") then
				time = f.readLine()
			elseif (lline == "description") then
				description = f.readLine()
			end
			lline = f.readLine()
		end

		log[logCounter] = {
			other = other,
			amount = amount,
			balance = balance,
			time = time,
			description = description
		}

		logCounter = logCounter+1

		line = f.readLine()
	end

	return true, log
end

-- Create a new client, with its files and folders, given a name, a starting balance and a color
local function newClient(data) --name, balance, color
	local name = data.name
	local color = data.color

	-- Account id: xxx-xxxxxxxxxxx (prefix chosen by the bank + 11 random digits)
	local key
	repeat
		key = accountPrefix.."-"
		for i=1, 11 do
			key = key..tostring(math.random(10)-1)
		end
	until clientData[key] == nil

	local f = fs.open(filePath.."clientList.txt", "a")
	f.writeLine(key)
	f.close()

	fs.makeDir(filePath.."clientData")
	fs.makeDir(filePath.."clientData/"..key)

	-- Create basic info
	clientData[key] = {
		name = name,
		balance = 0,
		color = color,
		cumulative = 0
	}
	updateClientFile(key)

	-- Create transaction log
	local f = fs.open(filePath.."clientData/"..key.."/log.txt", "w")
	f.close()

	return true, tk("server.success_account")
end

local function deleteAccount(data) --key
	local key = data.key

	clientData[key] = nil
	local f = fs.open(filePath.."clientList.txt", "w")
	for k, v in pairs(clientData) do
		f.writeLine(k)
	end
	f.close()
	fs.delete(filePath.."clientData/"..key)
	return true, tk("server.account_deleted")
end

local function processRequest(func, sender, data)
	local success, response = func(data)
	local message = {
		success = success,
		response = response
	}
	--print("Responding.")
	rednet.send(sender, message, "mermediamond")
end

---------------- Start
serverSettings() -- Reads settings from file, sets lang
-- Persist the active language so every ComputerCraft program picks it up via settings.get("lang")
settings.set("lang", lang)
settings.save(".mermediamond_settings")
_G.activeLang = lang
os.loadAPI("lang/languages.lua") -- Loaded after activeLang is set, so tk() uses the right language	loadClients()
loadCards()
loadCustomCurrencies()
refreshCurrencyTable()
if (currency[currencyType] == nil) then
	currencyType = "diamond" -- saved currency was removed or never existed
end

local modem = peripheral.find("modem")
while (modem == nil) do
	modem = peripheral.find("modem")
	if (modem == nil) then
		term.setBackgroundColor(colors.red)
		term.setTextColor(colors.white)
		term.clear()
		term.setCursorPos(1,1)
		print("Ender modem required. Please connect a modem to continue...")
		os.pullEvent("peripheral")
	end
end
peripheral.find("modem", rednet.open)

function listen()
	while true do
		local sender, message = rednet.receive("mermediamond")
		--print("#"..sender.." requested "..message.action)

		if (message.action == "getClientData") then --------------- Get Client Data
			processRequest(getClientData, sender, message)

	elseif (message.action == "getServerData") then --------------- Get Client Data
		processRequest(getServerData, sender, message)

	elseif (message.action == "getVersion") then ---------------- Version check (updater)
		processRequest(getVersion, sender, message)

	elseif (message.action == "getfile") then ------------------- File transfer (updater)
		processRequest(getFile, sender, message)

		elseif (message.action == "getTransactionLog") then ------- Get Transaction Log
			processRequest(getTransactionLog, sender, message)

		elseif (message.action == "transaction") then ------------- Make a transaction
			processRequest(transaction, sender, message)

		elseif (message.action == "deposit") then ----------------- Make a deposit
			processRequest(deposit, sender, message)

			elseif (message.action == "withdraw") then ------------- Make a withdrawal
			processRequest(withdraw, sender, message)

		elseif (message.action == "new") then --------------------- Create an account
			processRequest(newClient, sender, message)

		elseif (message.action == "delete") then ------------------ Delete an account
			processRequest(deleteAccount, sender, message)

		-- Look up an account by its printed card (cardId + expiration + cvc must all match)
	elseif (message.action == "cardlogin") then ------------- Log in with a paper card
		processRequest(cardLogin, sender, message)

	elseif (message.action == "assigncard") then ------------ Issue a card for an account
		processRequest(assignCard, sender, message)

	else ------------------------------------------------------ Not a valid message
			local message = {
				success = false,
				response = "Invalid request"
			}
			rednet.send(sender, message, "mermediamond")
		end
	end
end

function main()
	while true do
		while true do
			local ownerName = tk("server.not_assigned")
			if (tonumber(bankOwnerKey) > 0) then
				if (clientData[bankOwnerKey] == nil) then
					ownerName = tk("server.deleted_account")
				else
					ownerName = clientData[bankOwnerKey].name
				end
			end
			local command = bankapi.optionMenu(tk("server.title"), {
				{option = "language",
				text = tk("server.language")..": "..tk("server."..lang)},
				{option = "currency_type",
				text =  tk("server.currency_type")..": "..currency[currencyType][1].name[string.sub(lang,1,2)]},
				{option = "value_multiplier",
				text =  tk("server.value_multiplier")..": "..valueMultiplier.."$"},
				{option = "cumulative_limit",
				text =  tk("server.cumulative_limit")..": "..cumulativeLimit.."$"},
				{option = "limit_reach_cost",
				text =  tk("server.limit_reach_cost")..": "..cumulativePrice.."$"},
				{option = "password",
				text =  tk("server.password")..": "..terminalPassword},
				{option = "set_owner",
				text =  tk("server.set_owner")..": "..ownerName},
				{option = "card_prefix",
				text =  tk("server.card_prefix")..": "..cardPrefix.."-xxxx-xxxx-xxxx"},
				{option = "account_prefix",
				text =  tk("server.account_prefix")..": "..accountPrefix.."-xxxxxxxxxxx"},
				{option = "add_currency",
				text =  tk("server.add_currency")},
				{option = "remove_currency",
				text =  tk("server.remove_currency")},
				{option = "version",
				text =  "Version: "..tostring(updater.readVer("") and updater.readVer("").version or "unknown")},
			}, 2, 40)

			if (command == "language") then
				-- Build the language menu from the installed lang/*.json files
				local langOptions = {}
				local langFiles = fs.list("lang/")
				table.sort(langFiles)
				for _, langFile in ipairs(langFiles) do
					if (string.sub(langFile, -5) == ".json") then
						local code = string.sub(langFile, 1, -6)
						table.insert(langOptions, {
							option = code,
							text = tk("en-us", "server."..code)
						})
					end
				end
				local subcommand = bankapi.optionMenu(tk("server.language"), langOptions, 1)
				lang = subcommand
				-- Keep the persisted language in sync when it changes in the menu
				settings.set("lang", lang)
				settings.save(".mermediamond_settings")
				_G.activeLang = lang
				updateSettingsFile()
				break
			elseif (command == "currency_type") then
				-- Build the currency menu dynamically so custom currencies appear too
				local currencyOptions = {}
				local currencyKeys = {}
				for key in pairs(currency) do
					table.insert(currencyKeys, key)
				end
				table.sort(currencyKeys)
				for _, key in ipairs(currencyKeys) do
					local item = currency[key][1]
					local displayName = item.id
					if (item.name[string.sub(lang,1,2)] ~= nil) then
						displayName = item.name[string.sub(lang,1,2)]
					end
					table.insert(currencyOptions, {option = key, text = displayName})
				end
				local subcommand = bankapi.optionMenu(tk("server.currency_type"), currencyOptions, 2)
				currencyType = subcommand
				updateSettingsFile()
				break
			elseif (command == "add_currency") then
				local steps = {
					tk("server.currency_item_id"),
					tk("server.currency_item_value"),
					tk("server.currency_item_name"),
					tk("server.currency_item_plural"),
					tk("server.currency_item_short")
				}
				local id = bankapi.inputTextScreen(steps, 1, 60)
				if (id == nil or id == "") then break end
				local value = bankapi.inputNumberScreen(steps, 2)
				if (value == nil) then break end
				local name = bankapi.inputTextScreen(steps, 3, 30)
				if (name == nil or name == "") then break end
				local plural = bankapi.inputTextScreen(steps, 4, 30)
				if (plural == nil or plural == "") then break end
				local short = bankapi.inputTextScreen(steps, 5, 3)
				if (short == nil or short == "") then break end

				-- Key derived from the item id: minecraft:gold_block -> minecraft_gold_block
				local key = string.gsub(string.gsub(id, ":", "_"), "%W", "_")
				if (currency[key] ~= nil and customCurrencies[key] == nil) then
					bankapi.errorScreen(tk("api.invalid_value"))
					break
				end

				-- Reuse the typed name for every language (clients slice the 2-letter code)
				local langCodes = {"en","es","de","fr","nl","it","pt","pl","ru","ar","tr","sv"}
				local names, pluralNames, shorts = {}, {}, {}
				for _, langCode in ipairs(langCodes) do
					names[langCode] = name
					pluralNames[langCode] = plural
					shorts[langCode] = short
				end
				customCurrencies[key] = {
					[1] = {
						id = id,
						value = tonumber(value),
						name = names,
						plural = pluralNames,
						short = shorts
					}
				}
				currency[key] = customCurrencies[key]
				saveCustomCurrencies()
				bankapi.successScreen(tk("server.currency_added"))
				break
			elseif (command == "remove_currency") then
				local customKeys = {}
				for key in pairs(customCurrencies) do
					table.insert(customKeys, key)
				end
				if (#customKeys == 0) then
					bankapi.errorScreen(tk("server.no_custom_currency"))
					break
				end
				table.sort(customKeys)
				local removeOptions = {}
				for _, key in ipairs(customKeys) do
					table.insert(removeOptions, {option = key, text = customCurrencies[key][1].id})
				end
				local subcommand = bankapi.optionMenu(tk("server.remove_currency"), removeOptions, 2)
				customCurrencies[subcommand] = nil
				saveCustomCurrencies()
				if (currencyType == subcommand) then
					currencyType = "diamond"
					updateSettingsFile()
				end
				break
			elseif (command == "value_multiplier") then
				local amount = bankapi.inputNumberScreen({tk("server.value_multiplier_explanation")}, 1)
				amount = tonumber(amount)
				if (amount == nil) then break end
				if (amount <= 0) then bankapi.errorScreen(tk("server.error_invalidamount")) end
				valueMultiplier = amount
				updateSettingsFile()
				break
			elseif (command == "password") then
				local newPassword = bankapi.inputTextScreen({tk("server.password_explanation")}, 1, 10)
				if (newPassword == "" or newPassword == nil) then break end
				terminalPassword = newPassword
				updateSettingsFile()
				break
			elseif (command == "cumulative_limit") then
				local amount = bankapi.inputNumberScreen({tk("server.cumulative_limit_explanation")}, 1)
				amount = tonumber(amount)
				if (amount == nil) then break end
				if (amount <= 0) then bankapi.errorScreen(tk("server.error_invalidamount")) end
				cumulativeLimit = amount
				updateSettingsFile()
				break
			elseif (command == "limit_reach_cost") then
				local amount = bankapi.inputNumberScreen({tk("server.limit_reach_cost_explanation")}, 1)
				amount = tonumber(amount)
				if (amount == nil) then break end
				if (amount <= 0) then bankapi.errorScreen(tk("server.error_invalidamount")) end
				cumulativePrice = amount
				updateSettingsFile()
				break
			elseif (command == "set_owner") then
				local account = bankapi.selectAccountScreen({tk("server.set_owner_explanation")}, 1, 0, clientData)
				if (account == nil) then break end
				if (tonumber(account) > 0) then
					bankOwnerKey = account
					updateSettingsFile()
				end
			elseif (command == "card_prefix") then
				local prefix = bankapi.inputTextScreen({tk("server.card_prefix_explanation")}, 1, 2)
				if (prefix == nil or prefix == "") then break end
				if (string.match(prefix, "^%d%d$")) then
					cardPrefix = prefix
					updateSettingsFile()
				else
					bankapi.errorScreen(tk("api.invalid_value"))
				end
			elseif (command == "account_prefix") then
				local prefix = bankapi.inputTextScreen({tk("server.account_prefix_explanation")}, 1, 3)
				if (prefix == nil or prefix == "") then break end
				if (string.match(prefix, "^%a%a%a$")) then
					accountPrefix = string.upper(prefix)
					updateSettingsFile()
				else
					bankapi.errorScreen(tk("api.invalid_value"))
				end
			elseif (command == "version") then
				-- Show version info; clients update themselves at boot via the updater
				local ver = nil
				ver = updater.readVer("")
				bankapi.textScreen({
					"Mermediamond bank server",
					"Version: "..tostring(ver and ver.version or "unknown"),
					"Commit: "..tostring(ver and ver.commit or "unknown"),
					"",
					"Clients check against this version",
					"at boot and update themselves."
				})
			end
		end
	end
end

parallel.waitForAll(listen, main)
