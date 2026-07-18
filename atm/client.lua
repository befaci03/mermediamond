-- ATM Terminal (in the computer)

local linkedAssistantID

local localization = {
	en={
		welcome="Welcome!",
		finding_assistant = "Looking for assistant (please place a turtle, install the assistant program and turn it on)",
		assistant_found = "Assistant found: #",
		calculating_value = "Calculating value...",
		depositing = "Depositing...",
		deposited = "You have deposited $",
		withdrawing = "Withdrawing...",
		not_enough_stored = {"Not enough money in the vault", "Try with lower amount"},
		invalid_amount = "Invalid amount",
		not_enough_balance = "Not enough balance",
		come_again = "Thank you! Come again!",
		login = "Log In",
		info = "What is Mermegold",
		create_account = "How do I make an account",
		insert_card = {"","","","","","Please insert your", "card in the disk drive"},
		info_screen = {
			"","","",
			"Welcome to Mermegold!",
			"",
			"With your Mermegold card you won't need to have",
			"money on you ever again. You will be able to",
			"perform remote transactions and have a full",
			"movement log.",
			"",
			"You will be able to install machines at your",
			"stores, with catalogues and automatic checkout.",
			"All payments will end up in your account. No",
			"more shuffling through chests to collect your",
			"payments!"
		},
		create_account_screen = {
			"","","","","","","",
			"To make an account, contact your local Mermegold",
			"employee and arrange a meeting. You will open an",
			"account together in the bank.",
		},
		pricing_screen = {
			"The Mermegold card is free!",
			"The bank automatically charges",
			" por every ",
			"transfered to or from your account.",
			"Ask about the Mermegold phone, which acts as a",
			"card and lets perform transactions anywhere!"
		},
		check_balance = "Check balance",
		deposit = "Deposit",
		withdraw = "Withdraw",
		perform_transaction = "Perform transaction",
		pricing = "Cost",
		history = "Log",
		logout = "Exit",
		input_money_in_container = {"","","","","",
			"Input money into the container",
			"before continuing."
		},
		confirm_deposit = {"","","","","",
			"Are you sure you want to",
			"deposit this money?"
		},
		no_money_to_deposit = {
			"","","","","","",
			"No money to deposit"
		},
		amount_to_withdraw = " to withdraw",
		done = "Done!",
		take_money = "Take the money from the container",
		amount_withdrawn = " withdrawn: ",
		transaction_instructions = {"Recipient account", "Amount to send", "Transaction description"},
		succesful_logout = "See you later!",
		ordering_money = "Organizing money before shutdown..."
	},
	es={
		welcome="Bienvenido!",
		finding_assistant = "Buscando asistente (por favor coloque y prenda una tortuga con el programa de asistente instalado)",
		assistant_found = "Asistente encontrado: #",
		calculating_value = "Calculando valor...",
		depositing = "Depositando...",
		deposited = "Has depositado $",
		withdrawing = "Retirando...",
		not_enough_stored = {"No hay suficiente dinero en la boveda", "Intente con un monto mas chico"},
		invalid_amount = "Monto invalido",
		not_enough_balance = "No tienes suficiente",
		come_again = "Gracias! Vuelva pronto!",
		login = "Ingresar",
		info = "Que es Mermegold",
		create_account = "Como me hago una cuenta",
		insert_card = {"","","","","","Por favor, ingrese su", "tarjeta en la disquetera"},
		info_screen = {
			"","","","",
			"Bienvenido a Mermegold!",
			"",
			"Con tu tarjeta mermegold, no tendras que llevar",
			"oro encima nunca mas. Podras hacer transacciones",
			"remotas y tendras un historial completo.",
			"",
			"Podras poner maquinas en tu local con catalogos",
			"que calculen el total de forma automatica, y",
			"todos los pagos iran a tu cuenta. No mas",
			"revolver cofres para recolectar pagos!"
		},
		create_account_screen = {
			"","","","","","","",
			"Para hacerse una cuenta, contactese con un",
			"empleado de Mermegold y arregle una cita.",
			"En el banco abriran una cuenta juntos.",
		},
		pricing_screen = {
			"La tarjeta Mermegold es gratis!",
			"El banco cobra automaticamente",
			" por cada ",
			"transferidos desde o hacia tu cuenta.",
			"Consulte por el movil Mermegold, que hace de",
			"tarjeta y puede realizar transacciones donde sea!"
		},
		check_balance = "Consultar balance",
		deposit = "Depositar",
		withdraw = "Retirar",
		perform_transaction = "Realizar transaccion",
		pricing = "Costo",
		history = "Historial",
		logout = "Salir",
		input_money_in_container = {"","","","","",
			"Ingrese dinero en el contenedor",
			"antes de continuar."
		},
		confirm_deposit = {"","","","","",
			"Estas seguro que quieres",
			"depositar este dinero?"
		},
		no_money_to_deposit = {
			"","","","","","",
			"No hay dinero para depositar"
		},
		amount_to_withdraw = " a retirar",
		done = "Listo!",
		take_money = "Tome el dinero del contenedor",
		amount_withdrawn = " retirados: ",
		transaction_instructions = {"Cuenta a recibir los fondos", "Monto a enviar", "Descripcion de la transaccion"},
		succesful_logout = "Hasta luego!",
		ordering_money = "Organizando dinero antes de apagar..."
	},
	de={
		welcome="Willkommen!",
		finding_assistant = "Auf der Suche nach einem Assistenten (bitte eine Schildkröte platzieren, das Assistentenprogramm installieren und einschalten)",
		assistant_found = "Assistent gefunden: #",
		calculating_value = "Wert wird berechnet...",
		depositing = "Einzahlen...",
		deposited = "Sie haben $ eingezahlt",
		withdrawing = "Auszahlen...",
		not_enough_stored = {"Nicht genug Geld im Tresor", "Versuchen Sie es mit geringerer Menge nochmal"},
		invalid_amount = "Ungueltiger Betrag",
		not_enough_balance = "Kontostandt zu niedrig",
		come_again = "Danke! Kommen Sie wieder!",
		login = "Anmelden",
		info = "Was ist Mermegold",
		create_account = "Wie erstelle ich ein Konto?",
		insert_card = {"", "", "", "", "", "Bitte stecken Sie Ihre", "Karte ins Laufwerk"},
		info_screen = {
		"", "", "",
		"Willkommen bei Mermegold!",
		"",
		"Mit Ihrer Mermegold-Karte müssen Sie nie wieder",
		"Bargeld bei sich tragen. Sie können damit",
		"Transaktionen aus der Ferne durchführen und erhalten",
		"ein vollständiges Bewegungsprotokoll.",
		"",
		"Sie können in Ihren Geschäften Geräte mit",
		"Produktkatalogen und automatischer Kasse installieren.",
		"Alle Zahlungen landen direkt auf Ihrem Konto.",
		"Kein mühsames Kisten-Durchsuchen mehr, um Geld",
		"einzusammeln!"
		},
		create_account_screen = {
		"", "", "", "", "", "", "",
		"Um ein Konto zu eröffnen, wenden Sie sich an einen",
		"Mermegold-Mitarbeiter vor Ort und vereinbaren Sie",
		"einen Termin. Die Kontoeröffnung erfolgt gemeinsam",
		"in der Bank."
		},
		pricing_screen = {
		"Die Mermegold-Karte ist kostenlos!",
		"Die Bank erhebt automatisch Gebühren",
		" pro jeder ",
		"Überweisung auf oder von Ihrem Konto.",
		"Fragen Sie nach dem Mermegold-Telefon – es dient",
		"ebenfalls als Karte und ermöglicht Transaktionen",
		"von überall!"
		},
		check_balance = "Kontostandt Ansehen",
		deposit = "Einzahlen",
		withdraw = "Auszahlen",
		perform_transaction = "Transaktion durchführen",
		pricing = "Preis",
		history = "Log",
		logout = "Abmelden",
		input_money_in_container = {"","","","","",
				"Legen Sie  geld in den Behaelter",
				"bevor Sie fortfahren."
		},
		confirm_deposit = {"","","","","",
				"Sind Sie sicher, dass Sie diesen",
				"Betrag einzahlen moechten?"
		},
		no_money_to_deposit = {
				"","","","","","",
				"Kein Geld zum Einzahlen"
		},
		amount_to_withdraw = " zum Auszahlen",
		done = "Done!",
		take_money = "Nehme das Geld aus dem Behälter",
		amount_withdrawn = " Auszahlen: ",
		transaction_instructions = {"Empfaenger Konto", "Betrag zu Senden", "Transaktios Beschreibung"},
		succesful_logout = "Auf Wiedersehen!",
		ordering_money = "Geld vor dem Shutdown organisieren..."
	},
}

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

local diskdrive = peripheral.find("drive")
os.loadAPI("bankapi.lua")
local serverData = bankapi.getServerData()
local lang = serverData.lang

local f = fs.open("assistant.txt", "r")
if (f ~= nil) then
	linkedAssistantID = tonumber(f.readLine())
	f.close()
else
	print(localization[lang].finding_assistant)
	while (true) do
		rednet.broadcast("hiring", "mermegold_customer")
		local sender, message = rednet.receive("mermegold_customer", 1)
		if (message == "offering") then
			linkedAssistantID = sender
			break
		end
	end
	print(localization[lang].assistant_found..linkedAssistantID)
	local f = fs.open("assistant.txt", "w")
	f.write(tostring(linkedAssistantID))
	f.close()
end

local currentAccount = 0

if (diskdrive.isDiskPresent()) then
	local f = fs.open("disk/mermegold.txt", "r")
	if (f ~= nil) then
		local value = f.readLine()
		if (value ~= nil) then
			local tempClientData = bankapi.getClientData()
			if (tempClientData[value] ~= nil) then
				currentAccount = value
			end
		end
	end
end

-------------------- Functions
local function calculateValue()
	local message = {
		action = "calculateValue",
		serverData = serverData
	}
	bankapi.waitScreen(localization[lang].calculating_value)
	while (true) do
		rednet.send(linkedAssistantID, message, "mermegold_customer")
		local sender, message = rednet.receive("mermegold_customer")
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
	bankapi.waitScreen(localization[lang].depositing)
	rednet.send(linkedAssistantID, message, "mermegold_customer")
	local sender, message = rednet.receive("mermegold_customer")
	local amount = message.response
	local success, response = bankapi.deposit(currentAccount, amount)
	bankapi.successScreen(localization[lang].deposited..amount)
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
	bankapi.waitScreen(localization[lang].withdrawing)
	rednet.send(linkedAssistantID, message, "mermegold_customer")
	local sender, message = rednet.receive("mermegold_customer")
	return message.success, message.response
end

local function reduceStorage()
	local message = {
		action = "reduce",
		serverData = serverData
	}
	while (true) do
		rednet.send(linkedAssistantID, message, "mermegold_customer")
		local sender, message = rednet.receive("mermegold_customer")
		if (message.success) then
			bankapi.successScreen(localization[lang].come_again)
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
		command = bankapi.optionMenu(localization[lang].welcome, {
			{option = "login",
			text = localization[lang].login},
			{option = "info",
			text = localization[lang].info},
			{option = "createaccount",
			text = localization[lang].create_account},
			{option = "pricing",
			text = localization[lang].pricing},
		})

		if (command == "login") then
			if (diskdrive.isDiskPresent()) then
				os.reboot()
			end
			local accept = bankapi.confirmScreen(localization[lang].insert_card)
			if (accept) then
				os.reboot()
			end
		elseif (command == "info") then
			bankapi.textScreen(localization[lang].info_screen)
		elseif (command == "createaccount") then
			bankapi.textScreen(localization[lang].create_account_screen)
		elseif (command == "pricing") then
			bankapi.textScreen({
				"","","","","",
				localization[lang].pricing_screen[1],
				"",
				localization[lang].pricing_screen[2],
				"$"..serverData.cumulativePrice..localization[lang].pricing_screen[3].."$"..serverData.cumulativeLimit,
				localization[lang].pricing_screen[4],
				"",
				localization[lang].pricing_screen[5],
				localization[lang].pricing_screen[6],
			})
		end
	else
		local line = string.rep(string.char(140), 3)
		command = bankapi.optionMenu(line.." "..tempClientData[currentAccount].name.." "..line, {
			{option = "balance",
			text = localization[lang].check_balance},
			{option = "deposit",
			text =  localization[lang].deposit},
			{option = "withdraw",
			text =  localization[lang].withdraw},
			{option = "transaction",
			text =  localization[lang].perform_transaction},
			{option = "log",
			text =  localization[lang].history},
			{option = "logout",
			text =  localization[lang].logout},
		}, 2)

		if (command == "balance") then
			bankapi.showBalance(currentAccount)

		elseif (command == "deposit") then
			local amount = calculateValue()
			local superbreak = false
			while (amount <= 0) do
				local accept = bankapi.confirmScreen(localization[lang].input_money_in_container)
				if (not accept) then 
					superbreak = true
					break
				end
				amount = calculateValue()
			end
			if (superbreak) then break end
			local accept = bankapi.confirmScreen(localization[lang].confirm_deposit, {amount = "$"..amount})
			if (not accept) then break end
			if (amount > 0) then
				deposit()
			else
				bankapi.textScreen(localization[lang].no_money_to_deposit)
			end
		elseif (command == "withdraw") then
			local tempClientData = bankapi.getClientData()
			local multiplier = tonumber(serverData.valueMultiplier)
			local steps = {serverData.currency[1].plural[lang]..localization[lang].amount_to_withdraw}
			local itemMax = math.floor(tempClientData[currentAccount].balance/multiplier)
			local amount = bankapi.inputNumberScreen(steps, 1, itemMax, itemMax.." "..serverData.currency[1].plural[lang])
			if (amount == nil) then break end
			amount = tonumber(amount)
			if (amount > itemMax) then
				bankapi.errorScreen(localization[lang].not_enough_balance)
				break
			end
			local success, message = assistantWithdrawItems(amount)
			if (not success) then
				bankapi.errorScreen(localization[lang][message])
				break
			end
			local success, message = bankapi.withdraw(currentAccount, amount*multiplier)
			if (success) then
				bankapi.textScreen({
					"",
					"",
					"",
					localization[lang].done,
					localization[lang].take_money,
					"",
					serverData.currency[1].plural[lang]..localization[lang].amount_withdrawn..tostring(amount),
					"",
					smallestDenomination})
			else
				bankapi.errorScreen(message)
			end

		elseif (command == "log") then
			bankapi.transactionLogScreen(currentAccount)

		elseif (command == "transaction") then
			local tempClientData = bankapi.getClientData()
			local steps = localization[lang].transaction_instructions
			local to = bankapi.selectAccountScreen(steps, 1, currentAccount)
			if (to == nil) then break end
			local amount = bankapi.inputNumberScreen(steps, 2, tempClientData[currentAccount].balance)
			if (amount == nil) then break end
			local description = bankapi.inputTextScreen(steps, 3, 100)
			if (description == nil) then break end

			local success, message = bankapi.transaction(currentAccount, to, amount, description)
			bankapi.responseScreen(success, message)

		elseif (command == "logout") then
			diskdrive.ejectDisk()
			bankapi.successScreen(localization[lang].succesful_logout)
			bankapi.waitScreen(localization[lang].ordering_money)
			reduceStorage()
			os.shutdown()
		end
	end
end
end
