-- Mobile app

-- bankapi lives in lib/ since the API split (root copy = legacy layout)
if (fs.exists("lib/bankapi.lua")) then os.loadAPI("lib/bankapi.lua")
elseif (fs.exists("bankapi.lua")) then os.loadAPI("bankapi.lua")
else error("bankapi not found: lib/bankapi.lua is missing") end

local modemSide = "back"

local modem = peripheral.find("modem")

if (modem == nil) then
	while (true) do
		shell.run("equip")
		modem = peripheral.find("modem")
		if (modem == nil) then
			term.setBackgroundColor(colors.red)
			term.setTextColor(colors.white)
			term.clear()
			term.setCursorPos(1,1)
			print("This app needs an Ender Modem. This app will auto-equip an Ender Modem from your inventory.")
			print("")
			print("Retrying in")
			for i=1, 5 do
				term.write(6-i.."...")
				sleep(1)
			end
			print("Attempting auto-equip")
			sleep(1)
		else
			os.reboot()
		end
	end
end

peripheral.find("modem", rednet.open)
local serverData = bankapi.getServerData()
local lang = serverData.lang

-- Check for updates against the server before anything else
bankapi.autoUpdate("phone")

local currentAccount = 0

-- Translations moved to lang/*.json, loaded by lang/languages.lua (provides tk())

-- Log in with a printed paper card: type the card's machine line, then validate against the server
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

if (fs.exists("mermediamond.txt")) then
	local f = fs.open("mermediamond.txt", "r")
	if (f ~= nil) then
		local value = f.readLine()
		if (value ~= nil) then
			local tempClientData = bankapi.getClientData()
			if (tempClientData[value] ~= nil) then
				currentAccount = value
			end
		end
		f.close()
	end
end

while true do
while true do
	local tempClientData = bankapi.getClientData()
	local command
	if (tempClientData[currentAccount] == nil) then -- Guest screen
		command = bankapi.optionMenu(tk("pocket.welcome"), {
			[1] = {
			["option"] = "login",
			["text"] = tk("pocket.login")},
			[2] = {
			["option"] = "info",
			["text"] = tk("pocket.info")},
			[3] = {
			["option"] = "createaccount",
			["text"] = tk("pocket.create_account")},
		})

		if (command == "login") then
			local account = loginWithCard()
			if (account ~= nil) then
				currentAccount = account
				-- Remember the account on the phone for next time
				local f = fs.open("mermediamond.txt", "w")
				f.writeLine(account)
				f.close()
			end
		elseif (command == "info") then
			bankapi.textScreen(tk("pocket.info_screen"))
		elseif (command == "createaccount") then
			bankapi.textScreen(tk("pocket.create_account_screen"))
		end
	else
		local line = string.rep(string.char(140), 3)
		command = bankapi.optionMenu(line.." "..tempClientData[currentAccount].name.." "..line, {
			[1] = {
			["option"] = "balance",
			["text"] = tk("pocket.check_balance")},
			[2] = {
			["option"] = "transaction",
			["text"] = tk("pocket.perform_transaction")},
			[3] = {
			["option"] = "log",
			["text"] = tk("pocket.history")},
			[4] = {
			["option"] = "quit",
			["text"] = tk("pocket.logout")},
		}, 2, 24)

		if (command == "balance") then
			bankapi.showBalance(currentAccount)

		elseif (command == "log") then
			bankapi.transactionLogScreen(currentAccount)

		elseif (command == "transaction") then
			local tempClientData = bankapi.getClientData()
			local steps = tk("pocket.transaction_instructions")
			local to = bankapi.selectAccountScreen(steps, 1, currentAccount)
			if (to == nil) then break end
			local amount = bankapi.inputNumberScreen(steps, 2, tempClientData[currentAccount].balance)
			if (amount == nil) then break end
			local description = bankapi.inputTextScreen(steps, 3, 100)
			if (description == nil) then break end

			local success, message = bankapi.transaction(currentAccount, to, amount, description)
			bankapi.responseScreen(success, message)

		elseif (command == "quit") then
			fs.delete("mermediamond.txt")
			os.shutdown()
		end
	end
end
end
