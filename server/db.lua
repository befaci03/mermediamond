-- Bank Server database: clients, custom currencies, cards, transactions
-- Loaded by server/startup.lua with dofile() (shares startup's scope;
-- uses the config globals defined in server/config.lua).

-------------------- Clients --------------------

function loadClients()
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

function getClientData(data)
	loadClients()
	return true, clientData
end

function getServerData(data)
	return true, {lang = lang, currency = currency[currencyType], valueMultiplier = valueMultiplier, terminalPassword = terminalPassword, cumulativeLimit = cumulativeLimit, cumulativePrice = cumulativePrice, cardPrefix = cardPrefix, accountPrefix = accountPrefix}
end

-------------------- Custom currencies -------------------
-- A custom currency looks exactly like a built-in one:
--   customCurrencies["mycoin"] = { [1] = { id=..., value=..., name={...}, plural={...}, short={...} } }
-- They are merged into `currency` so everything downstream (ATM,
-- shop, transactions) treats them identically.

function loadCustomCurrencies()
	customCurrencies = {}
	if (not fs.exists(filePath.."customCurrencies.txt")) then return end
	local f = fs.open(filePath.."customCurrencies.txt", "r")
	if (f == nil) then return end
	local line = f.readLine()
	local block = {}
	while line ~= nil do
		if (line == "currency") then
			block = {}
		elseif (line == "end") then
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

function saveCustomCurrencies()
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
function refreshCurrencyTable()
	for key, denominations in pairs(customCurrencies) do
		if (currency[key] == nil) then currency[key] = denominations end
	end
end

-------------------- ver / file serving (updater) --------------------

-- ver data (dotenv file) served to updating clients
function getVersion(data) return true, { ver = updater.readVer("") } end

-- Serve one file (chunked) to a client that is updating itself
function getFile(data)
	local success, response = updater.serveFileChunk(data.path, tonumber(data.offset) or 0)
	if (success) then return true, response end
	return false, response
end

-------------------- Card registry (paper cards) -------------------
-- cards.txt: one card per block:
--   cardId / expiration / cvc / account
cardRegistry = {}

function loadCards()
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

function saveCards()
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

-- Issue a new card for an account. Bank chooses the 2-digit prefix.
function assignCard(data) --account
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
function cardLogin(data) --card = {cardId, expiration, cvc}
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

-------------------- Transactions --------------------

function updateClientFile(key)
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

function appendTransactionToLog(from, to, amount, balance, time, description)
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

function getCurrentTime()
	return os.date("%d/%m/%Y %H:%M")
end

function addCumulative(key, amount)
	if (cumulativeLimit == 0) then return nil end
	if (cumulativePrice == 0) then return nil end
	clientData[key].cumulative = clientData[key].cumulative+amount
	if (bankOwnerKey ~= nil and bankOwnerKey ~= 0) then
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

	appendTransactionToLog(from, to, amount, newFromBalance, time, description)
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

function deposit(data) --key, amount
	local key = data.key
	local amount = tonumber(data.amount)
	local description = tk("server.deposit_description")

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

function withdraw(data) --key, amount
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

function getTransactionLog(data) --key
	local key = data.key

	local log = {}
	local logCounter = 1
	local f = fs.open(filePath.."clientData/"..key.."/log.txt", "r")
	if (f == nil) then return true, log end
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
function newClient(data) --name, balance, color
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

function deleteAccount(data) --key
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
