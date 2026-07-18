-- Bank Server

os.loadAPI("bankapi.lua")

-------------------- Params
local currency = {
	diamond = {
		[1] = {
			id="minecraft:diamond",
			value=1,
			name={en="Diamond",es="Diamante",de="Diamant",},
			plural={en="Diamonds",es="Diamantes",de="Diamanten",},
			short={en="D",es="D",de="D"},
			uprecipe={need=9,yield=1,result="minecraft:diamond_block"}
		},
		[2] = {
			id="minecraft:diamond_block",
			value=9,
			name={en="Diamond Block",es="Bloque de Diamante",de="Diamantblock",},
			plural={en="Diamond Blocks",es="Bloques de Diamante",de="Diamantbloecke",},
			short={en="Bl",es="Bl",de="Bl"},
			downrecipe={need=1,yield=9,result="minecraft:diamond_block"}
		}
	},
	gold = {
		[1] = {
			id="minecraft:gold_nugget",
			value=1,
			name={en="Gold Nugget",es="Pepita de Oro",de="Goldnugget",},
			plural={en="Gold Nuggets",es="Pepitas de Oro",de="Goldnuggets",},
			short={en="N",es="P",de="N"},
			uprecipe={need=9,yield=1,result="minecraft:gold_ingot"}
		},
		[2] = {
			id="minecraft:gold_ingot",
			value=9,
			name={en="Gold Ingot",es="Lingote de Oro",de="Goldbarren",},
			plural={en="Gold Ingots",es="Lingotes de Oro",de="Goldbarren",},
			short={en="I",es="L",de="B"},
			downrecipe={need=1,yield=9,result="minecraft:gold_nugget"},
			uprecipe={need=9,yield=1,result="minecraft:gold_block"}
		},
		[3] = {
			id="minecraft:gold_block",
			value=81,
			name={en="Gold Block",es="Bloque de Oro",de="Goldblock",},
			plural={en="Gold Blocks",es="Bloques de Oro",de="Goldbloecke",},
			short={en="B",es="B",de="B"},
			downrecipe={need=1,yield=9,result="minecraft:gold_ingot"}
		}
	},
	emerald = {
		[1] = {
			id="minecraft:emerald",
			value=1,
			name={en="Emerald",es="Esmeralda",de="Smaragd",},
			plural={en="Emeralds",es="Esmeraldas",de="Smaragde",},
			short={en="E",es="E",de="S"},
			uprecipe={need=9,yield=1,result="minecraft:emerald_block"}
		},
		[2] = {
			id="minecraft:emerald_block",
			value=9,
			name={en="Emerald Block",es="Bloque de Esmeralda",de="Smaragdblock",},
			plural={en="Emerald Blocks",es="Bloques de Esmeralda",de="Smaragdbloecke",},
			short={en="Bl",es="Bl",de="Bl"},
			downrecipe={need=1,yield=9,result="minecraft:emerald_block"}
		}
	},
	-- Simple coin is an unpublished coin mod made by me.
	-- It is compatible with this bank, but the option is hidden.
	simplecoin = {
		[1] = {
			id="simple_coins:copper_coin",
			value=1,
			name={en="Copper piece",es="Pieza de cobre"},
			short={en="cp",es="cp"},
			uprecipe={need=5,yield=1,result="simple_coins:copper_coin_pile"}
		},
		[2] = {
			id="simple_coins:copper_coin_pile",
			value=5,
			name={en="Copper piece pile",es="Pila de piezas de cobre"},
			short={en="cpp",es="cpp"},
			downrecipe={need=1,yield=5,result="simple_coins:copper_coin"},
			uprecipe={need=2,yield=1,result="simple_coins:silver_coin"},
			ingredient=true
		},
		[3] = {
			id="simple_coins:silver_coin",
			value=10,
			name={en="Silver piece",es="Pieza de plata"},
			short={en="sp",es="sp"},
			downrecipe={need=1,yield=2,result="simple_coins:copper_coin_pile"},
			uprecipe={need=5,yield=1,result="simple_coins:silver_coin_pile"}
		},
		[4] = {
			id="simple_coins:silver_coin_pile",
			value=50,
			name={en="Silver piece pile",es="Pila de piezas de plata"},
			short={en="spp",es="spp"},
			downrecipe={need=1,yield=5,result="simple_coins:silver_coin"},
			uprecipe={need=2,yield=1,result="simple_coins:gold_coin"},
			ingredient=true
		},
		[5] = {
			id="simple_coins:gold_coin",
			value=100,
			name={en="Gold Piece",es="Pieza de oro"},
			short={en="gp",es="gp"},
			downrecipe={need=1,yield=2,result="simple_coins:silver_coin"}
		}
	}
}
-----------------------------

local cumulativeLimit = 10000 -- Every x money moved, you get charged
local cumulativePrice = 100 -- How much you pay
local lang = "en"
local currencyType = "diamond"
local terminalPassword = "1234"
local valueMultiplier = 100
local bankOwnerKey = 0

local localization = {
	en={
		title = "Hosting Bank Server, do not turn off",
		account_start_description = "Welcome to Mermegold!",
		error_invalidamount = "Invalid amount",
		error_from = "Invalid origin account",
		error_to = "Invalid target account",
		error_account = "Non-existent account",
		error_same = "Can't use the same account as origin and target",
		error_notenoughbalance = "Insufficient balance",
		success_transaction = "Transaction successful",
		success_update = "Update successful",
		success_account = "Account created successfully",
		account_deleted = "Account deleted successfully",
		withdraw_description = "Withdrawal",
		deposit_description = "Deposit",
		expenses = "Mermegold expenses",
		language = "Language",
		currency_type = "Currency item",
		value_multiplier = "Item value",
		value_multiplier_explanation = "How much $ is a single Currency Item worth",
		password = "Admin terminal password",
		password_explanation = "Password for the admin terminals",
		cumulative_limit = "Cumulative limit",
		cumulative_limit_explanation = "How much a user can exchange before paying expenses",
		limit_reach_cost = "Expenses",
		limit_reach_cost_explanation = "How much to charge a user when they reach the cumulative limit",
		set_owner = "Set owner",
		set_owner_explanation = "Set the account that will collect the bank expenses",
		en="English",
		es="Spanish",
		not_assigned="- not asigned -",
		deleted_account="- deleted -"
	},
	es={
		title = "Hospedando servidor del banco, no apagar",
		account_start_description = "Bienvenido a Mermegold!",
		error_invalidamount = "Monto invalido",
		error_from = "Cuenta origen invalida",
		error_to = "Cuenta destino invalida",
		error_account = "Cuenta inexistente",
		error_same = "No se puede usar la misma cuenta como destino y origen a la vez",
		error_notenoughbalance = "Balance insuficiente",
		success_transaction = "Transaccion exitosa",
		success_update = "Actualizacion exitosa",
		success_account = "Cuenta creada con exito",
		account_deleted = "Cuenta borrada con exito",
		withdraw_description = "Retiro",
		deposit_description = "Deposito",
		expenses = "Expensas de mermegold",
		language = "Lenguaje",
		currency_type = "Objeto Moneda",
		value_multiplier = "Valor del objeto",
		value_multiplier_explanation = "Cuanto $ vale un Objeto Moneda",
		password = "Contrasena de administrador",
		password_explanation = "Contrasena de las terminales de administrador",
		cumulative_limit = "Limite de acumulacion",
		cumulative_limit_explanation = "Cuanto puede mover un usuario antes de pagar expensas",
		limit_reach_cost = "Expensas",
		limit_reach_cost_explanation = "Cuanto debe pagar un usuario al llegar al limite de acumulacion",
		set_owner = "Asignar propietario",
		set_owner_explanation = "Elige la cuenta que cobrara las expensas del banco",
		en="Ingles",
		es="Espanol",
		not_assigned="- no asignado -",
		deleted_account="- borrado -"
	},
	de = {
		title = "Hosting Bank Server, nicht abschalten",
		account_start_description = "Willkommen bei Mermegold!",
		error_invalidamount = "Ungueltige Anzahl",
		error_from = "Ungueltiger Ursprungs Account",
		error_to = "Ungueltiger Empfaenger Account",
		error_account = "Konto existiert nicht",
		error_same = "Sender und Empfaenger koennen nicht gleich sein",
		error_notenoughbalance = "Unzureichender Kontostandt",
		success_transaction = "Transaktion erfolgreich",
		success_update = "Update erfolgreich",
		success_account = "Konto wurde erfolgreich erstellt",
		account_deleted = "Konto wurde erfolgreich geloescht",
		withdraw_description = "Auszahlung",
		deposit_description = "Einzahlung",
		expenses = "Mermegold Zinsen",
		language = "Sprache",
		currency_type = "Waehrungs Item",
		value_multiplier = "Item wert",
		value_multiplier_explanation = "Wie viel $ ein einziges Item wert ist",
		password = "Admin Terminal passwort",
		password_explanation = "Passwort für die Admin-Terminals",
		cumulative_limit = "Kumulatives Limit",
		cumulative_limit_explanation = "Wie viel ein Benutzer vor der Zahlung von Zinsen austauschen kann",
		limit_reach_cost = "Zinsen",
		limit_reach_cost_explanation = "Wie viel Zinsen ein Benutzer bezahlt wenn er das Kumulatives Limit erreicht",
		set_owner ="Besitzer festlegen",
		set_owner_explanation = "Legen Sie das Konto fest, das die Zinsen einsammelt",
		en = "English",
		es = "Spanish",
		de = "Deutsch",
		not_assigned = "- nicht vergeben -",
		deleted_account = "- geloescht -"
	},
}
--------------------

-------------------- Variables
local clientData = {}
local filePath = "bank/"
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
	f.close()
end

local function serverSettings()
	if (fs.exists(filePath.."settings.txt")) then
		local f = fs.open(filePath.."settings.txt", "r")
		f.readLine() -- Language label
		local line = f.readLine()
		if (line == "es") then
			lang = "es"
		else
			lang = "en"
		end
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
		f.close()
	else
		-- Create file with default values
		updateSettingsFile()
	end
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
	return true, {lang = lang, currency = currency[currencyType], valueMultiplier = valueMultiplier, terminalPassword = terminalPassword, cumulativeLimit = cumulativeLimit, cumulativePrice = cumulativePrice}
end

local function updateClientFile(key)
	local f = fs.open(filePath.."clientData/"..key.."/info.txt", "w")
	if (f == nil) then return false, localization[lang].error_account end

	f.writeLine("name")
	f.writeLine(clientData[key].name)
	f.writeLine("balance")
	f.writeLine(tostring(clientData[key].balance))
	f.writeLine("color")
	f.writeLine(tostring(clientData[key].color))
	f.writeLine("cumulative")
	f.writeLine(tostring(clientData[key].cumulative))
	f.close()

	return true, localization[lang].success_update
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
							description = localization[lang].expenses
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
		return false, localization[lang].error_invalidamount
	end

	loadClients()

	if (from == to) then
		return false, localization[lang].error_same
	end
	if (clientData[from] == nil) then
		return false, localization[lang].error_from.." ("..from..")"
	end
	if (clientData[to] == nil) then
		return false, localization[lang].error_to.." ("..to..")"
	end

	local previousFromBalance = clientData[from].balance
	local newFromBalance = previousFromBalance-amount

	if (newFromBalance < 0 and not addToCumulative) then
		return false, localization[lang].error_notenoughbalance
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

	return true, localization[lang].success_transaction
end

local function deposit(data) --key, amount
	local key = data.key
	local amount = tonumber(data.amount)
	local description = localization[lang].deposit_description

	--print(textutils.serialise(data))
	if (amount == 0 or amount == nil) then
		return false, localization[lang].error_invalidamount
	end

	loadClients()

	if (clientData[key] == nil) then
		return false, localization[lang].error_from.." ("..key..")"
	end

	local previousBalance = clientData[key].balance
	local newBalance = previousBalance+amount

	local time = getCurrentTime()

	clientData[key].balance = newBalance
	updateClientFile(key)

	appendTransactionToLog(key, key, -amount, newBalance, time, description)

	return true, localization[lang].success_transaction
end

local function withdraw(data) --key, amount
	local key = data.key
	local amount = tonumber(data.amount)
	local description = localization[lang].withdraw_description

	if (amount == 0 or amount == nil) then
		return false, localization[lang].error_invalidamount
	end

	loadClients()

	if (key == nil or clientData[key] == nil) then
		return false, localization[lang].error_from.." ("..tostring(key)..")"
	end

	local previousBalance = clientData[key].balance
	local newBalance = previousBalance-amount

	if (newBalance < 0) then
		return false, localization[lang].error_notenoughbalance
	end

	local time = getCurrentTime()
	clientData[key].balance = newBalance
	updateClientFile(key)

	appendTransactionToLog(key, key, amount, newBalance, time, description)

	return true, localization[lang].success_transaction
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

	local bankKey = "1000"

	local firstFreeClientNumber = 0
	while firstFreeClientNumber < 9999 do
		firstFreeClientNumber = firstFreeClientNumber+1
		local free = true
		for k, v in pairs(clientData) do
			local clientNumber = tonumber(string.sub(k, 5, 8))
			if (clientNumber == firstFreeClientNumber) then
				free = false
				break
			end
		end
		if (free) then
			break
		end
	end

	local clientNumber = tostring(firstFreeClientNumber)
	clientNumber = string.rep("0", 4-string.len(clientNumber))..clientNumber
	local randomKey = ""
	for i=1, 8 do
		randomKey = randomKey..tostring(math.random(10)-1)
	end
	local key = bankKey..clientNumber..randomKey

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

	return true, localization[lang].success_account
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
	return true, localization[lang].account_deleted
end

local function processRequest(func, sender, data)
	local success, response = func(data)
	local message = {
		success = success,
		response = response
	}
	--print("Responding.")
	rednet.send(sender, message, "mermegold")
end

---------------- Start
serverSettings()
loadClients()

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
		local sender, message = rednet.receive("mermegold")
		--print("#"..sender.." requested "..message.action)

		if (message.action == "getClientData") then --------------- Get Client Data
			processRequest(getClientData, sender, message)

		elseif (message.action == "getServerData") then --------------- Get Client Data
			processRequest(getServerData, sender, message)
			
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

		else ------------------------------------------------------ Not a valid message
			local message = {
				success = false,
				response = "Invalid request"
			}
			rednet.send(sender, message, "mermegold")
		end
	end
end

function main()
	while true do
		while true do
			local ownerName = localization[lang].not_assigned
			if (tonumber(bankOwnerKey) > 0) then
				if (clientData[bankOwnerKey] == nil) then
					ownerName = localization[lang].deleted_account
				else
					ownerName = clientData[bankOwnerKey].name
				end
			end
			local command = bankapi.optionMenu(localization[lang].title, {
				{option = "language",
				text = localization[lang].language..": "..localization[lang][lang]},
				{option = "currency_type",
				text =  localization[lang].currency_type..": "..currency[currencyType][1].name[lang]},
				{option = "value_multiplier",
				text =  localization[lang].value_multiplier..": "..valueMultiplier.."$"},
				{option = "cumulative_limit",
				text =  localization[lang].cumulative_limit..": "..cumulativeLimit.."$"},
				{option = "limit_reach_cost",
				text =  localization[lang].limit_reach_cost..": "..cumulativePrice.."$"},
				{option = "password",
				text =  localization[lang].password..": "..terminalPassword},
				{option = "set_owner",
				text =  localization[lang].set_owner..": "..ownerName},
			}, 2, 40)

			if (command == "language") then
				local subcommand = bankapi.optionMenu(localization[lang].language, {
					{option = "en",
					text =  "English"},
					{option = "es",
					text = "Espanol"},
					{option = "de",
					text = "Deutsch"},
				}, 2)
				lang = subcommand
				updateSettingsFile()
				break
			elseif (command == "currency_type") then
				local subcommand = bankapi.optionMenu(localization[lang].currency_type, {
					{option = "diamond",
					text =  currency.diamond[1].name[lang]},
					{option = "gold",
					text = currency.gold[1].name[lang]},
					{option = "emerald",
					text = currency.emerald[1].name[lang]}
				}, 2)
				currencyType = subcommand
				updateSettingsFile()
				break
			elseif (command == "value_multiplier") then
				local amount = bankapi.inputNumberScreen({localization[lang].value_multiplier_explanation}, 1)
				amount = tonumber(amount)
				if (amount == nil) then break end
				if (amount <= 0) then bankapi.errorScreen(localization[lang].error_invalidamount) end
				valueMultiplier = amount
				updateSettingsFile()
				break
			elseif (command == "password") then
				local newPassword = bankapi.inputTextScreen({localization[lang].password_explanation}, 1, 10)
				if (newPassword == "" or newPassword == nil) then break end
				terminalPassword = newPassword
				updateSettingsFile()
				break
			elseif (command == "cumulative_limit") then
				local amount = bankapi.inputNumberScreen({localization[lang].cumulative_limit_explanation}, 1)
				amount = tonumber(amount)
				if (amount == nil) then break end
				if (amount <= 0) then bankapi.errorScreen(localization[lang].error_invalidamount) end
				cumulativeLimit = amount
				updateSettingsFile()
				break
			elseif (command == "limit_reach_cost") then
				local amount = bankapi.inputNumberScreen({localization[lang].limit_reach_cost_explanation}, 1)
				amount = tonumber(amount)
				if (amount == nil) then break end
				if (amount <= 0) then bankapi.errorScreen(localization[lang].error_invalidamount) end
				cumulativePrice = amount
				updateSettingsFile()
				break
			elseif (command == "set_owner") then
				local account = bankapi.selectAccountScreen({localization[lang].set_owner_explanation}, 1, 0, clientData)
				if (account == nil) then break end
				if (tonumber(account) > 0) then
					bankOwnerKey = account
					updateSettingsFile()
				end
			end
		end
	end
end

parallel.waitForAll(listen, main)
