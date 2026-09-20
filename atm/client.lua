-- ATM Terminal (in the computer)

local linkedAssistantID

-- Translations moved to lang/*.json, loaded by lang/languages.lua (provides tk())

-------------------- Start
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

os.loadAPI("bankapi.lua")
local serverData = bankapi.getServerData()
local lang = serverData.lang

-- Check for updates against the server before anything else
bankapi.autoUpdate("atm")

local f = fs.open("assistant.txt", "r")
if (f ~= nil) then
	linkedAssistantID = tonumber(f.readLine())
	f.close()
else
	print(tk("atm.finding_assistant"))
	while (true) do
		rednet.broadcast("hiring", "mermediamond_customer")
		local sender, message = rednet.receive("mermediamond_customer", 1)
		if (message == "offering") then
			linkedAssistantID = sender
			break
		end
	end
	print(tk("atm.assistant_found")..linkedAssistantID)
	local f = fs.open("assistant.txt", "w")
	f.write(tostring(linkedAssistantID))
	f.close()
end

local currentAccount = 0

-- Log in with a printed paper card: read its machine line, then validate against the server
local function loginWithCard()
	while (true) do
		local card = bankapi.readPrintedCard(tk("card.login_steps"))
		if (card == nil) then return nil end
		local success, result = bankapi.cardLogin(card)
		if (success) then
			return result -- account id
		else
			local msg = result
			if (msg == nil or msg == "") then msg = tk("card.invalid_card") end
			bankapi.errorScreen(msg)
		end
	end
end

-- Guests can log in by typing their card's machine line
local tempClientData = bankapi.getClientData()

-------------------- Functions
local function calculateValue()
	local message = {
		action = "calculateValue",
		serverData = serverData
	}
	bankapi.waitScreen(tk("atm.calculating_value"))
	while (true) do
		rednet.send(linkedAssistantID, message, "mermediamond_customer")
		local sender, message = rednet.receive("mermediamond_customer")
		if (message.success) then
			return message.response
		end
	end
end

local function deposit()
	local message = {
		action = "deposit",
		serverData = serverData
	}
	bankapi.waitScreen(tk("atm.depositing"))
	rednet.send(linkedAssistantID, message, "mermediamond_customer")
	local sender, message = rednet.receive("mermediamond_customer")
	local amount = message.response
	local success, response = bankapi.deposit(currentAccount, amount)
	bankapi.successScreen(tk("atm.deposited")..amount)
	return success, response
end

local function assistantWithdrawItems(amount)
	if (amount <= 0 or amount == nil) then
		return false, "invalid_amount"
	end

	local message = {
		action = "withdraw",
		amount = amount,
		serverData = serverData
	}
	bankapi.waitScreen(tk("atm.withdrawing"))
	rednet.send(linkedAssistantID, message, "mermediamond_customer")
	local sender, message = rednet.receive("mermediamond_customer")
	return message.success, message.response
end

local function reduceStorage()
	local message = {
		action = "reduce",
		serverData = serverData
	}
	while (true) do
		rednet.send(linkedAssistantID, message, "mermediamond_customer")
		local sender, message = rednet.receive("mermediamond_customer")
		if (message.success) then
			bankapi.successScreen(tk("atm.come_again"))
			return
		end
	end
end
---------------------------

-------------------- Loop
while true do
while true do
	local tempClientData = bankapi.getClientData()
	local command
	if (tempClientData[currentAccount] == nil) then -- Guest screen
		command = bankapi.optionMenu(tk("atm.welcome"), {
			{option = "login",
			text = tk("atm.login")},
			{option = "info",
			text = tk("atm.info")},
			{option = "createaccount",
			text = tk("atm.create_account")},
			{option = "pricing",
			text = tk("atm.pricing")},
		})

		if (command == "login") then
			local account = loginWithCard()
			if (account ~= nil) then
				currentAccount = account
			end
		elseif (command == "info") then
			bankapi.textScreen(tk("atm.info_screen"))
		elseif (command == "createaccount") then
			bankapi.textScreen(tk("atm.create_account_screen"))
		elseif (command == "pricing") then
			bankapi.textScreen({
				"","","","","",
				tk("atm.pricing_screen")[1],
				"",
				tk("atm.pricing_screen")[2],
				"$"..serverData.cumulativePrice..tk("atm.pricing_screen")[3].."$"..serverData.cumulativeLimit,
				tk("atm.pricing_screen")[4],
				"",
				tk("atm.pricing_screen")[5],
				tk("atm.pricing_screen")[6],
			})
		end
	else
		local line = string.rep(string.char(140), 3)
		command = bankapi.optionMenu(line.." "..tempClientData[currentAccount].name.." "..line, {
			{option = "balance",
			text = tk("atm.check_balance")},
			{option = "deposit",
			text =  tk("atm.deposit")},
			{option = "withdraw",
			text =  tk("atm.withdraw")},
			{option = "transaction",
			text =  tk("atm.perform_transaction")},
			{option = "log",
			text =  tk("atm.history")},
			{option = "logout",
			text =  tk("atm.logout")},
		}, 2)

		if (command == "balance") then
			bankapi.showBalance(currentAccount)

		elseif (command == "deposit") then
			local amount = calculateValue()
			local superbreak = false
			while (amount <= 0) do
				local accept = bankapi.confirmScreen(tk("atm.input_money_in_container"))
				if (not accept) then
					superbreak = true
					break
				end
				amount = calculateValue()
			end
			if (superbreak) then break end
			local accept = bankapi.confirmScreen(tk("atm.confirm_deposit"), {amount = "$"..amount})
			if (not accept) then break end
			if (amount > 0) then
				deposit()
			else
				bankapi.textScreen(tk("atm.no_money_to_deposit"))
			end
		elseif (command == "withdraw") then
			local tempClientData = bankapi.getClientData()
			local multiplier = tonumber(serverData.valueMultiplier)
			local steps = {serverData.currency[1].plural[string.sub(lang,1,2)]..tk("atm.amount_to_withdraw")}
			local itemMax = math.floor(tempClientData[currentAccount].balance/multiplier)
			local amount = bankapi.inputNumberScreen(steps, 1, itemMax, itemMax.." "..serverData.currency[1].plural[string.sub(lang,1,2)])
			if (amount == nil) then break end
			amount = tonumber(amount)
			if (amount > itemMax) then
				bankapi.errorScreen(tk("atm.not_enough_balance"))
				break
			end
			local success, message = assistantWithdrawItems(amount)
			if (not success) then
				bankapi.errorScreen(tk("atm."..message))
				break
			end
			local success, message = bankapi.withdraw(currentAccount, amount*multiplier)
			if (success) then
				bankapi.textScreen({
					"",
					"",
					"",
					tk("atm.done"),
					tk("atm.take_money"),
					"",
					serverData.currency[1].plural[string.sub(lang,1,2)]..tk("atm.amount_withdrawn")..tostring(amount),
					"",
					smallestDenomination})
			else
				bankapi.errorScreen(message)
			end

		elseif (command == "log") then
			bankapi.transactionLogScreen(currentAccount)

		elseif (command == "transaction") then
			local tempClientData = bankapi.getClientData()
			local steps = tk("atm.transaction_instructions")
			local to = bankapi.selectAccountScreen(steps, 1, currentAccount)
			if (to == nil) then break end
			local amount = bankapi.inputNumberScreen(steps, 2, tempClientData[currentAccount].balance)
			if (amount == nil) then break end
			local description = bankapi.inputTextScreen(steps, 3, 100)
			if (description == nil) then break end

			local success, message = bankapi.transaction(currentAccount, to, amount, description)
			bankapi.responseScreen(success, message)

		elseif (command == "logout") then
			currentAccount = 0
			bankapi.successScreen(tk("atm.succesful_logout"))
			bankapi.waitScreen(tk("atm.ordering_money"))
			reduceStorage()
			os.shutdown()
		end
	end
end
end
