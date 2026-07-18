-- Mobile app

os.loadAPI("bankapi.lua")

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

local currentAccount = 0

local localization = {
	en={
		welcome="Welcome!",
		unregistered={"Please register","this device with","a Mermegold","employee"},
		login = "Log In",
		info = "What is Mermegold",
		info_screen = {
			"Welcome to Mermegold!",
			"",
			"With your Mermegold card",
			"you won't need to have",
			"money on you ever again. ",
			"You will be able to make",
			"remote transactions and",
			"have a full movement log.",
			"",
			"You can also install",
			"automated store clerks at",
			"your shops with catalogues",
			"and automatic checkout.",
			"",
			"Payments will end up in",
			"your account. No more",
			"shuffling through chests",
			"to collect your payments!"
		},
		create_account = "How to make an account",
		create_account_screen = {
			"","","","","","","",
			"To make an account,",
			"contact your local",
			"Mermegold employee and",
			"arrange a meeting.",
			"You will open an account",
			"together at the bank."
		},
		check_balance = "Balance",
		perform_transaction = "Transaction",
		history = "Log",
		logout = "Exit",
		transaction_instructions = {"Recipient account", "Amount to send", "Description"}
	},
	es={
		welcome="Bienvenido!",
		unregistered={"Por favor registre","el dispositivo","con un empleado","de Mermegold"},
		login = "Ingresar",
		info = "Que es Mermegold",
		create_account = "Como crear una cuenta",
		info_screen = {
			"Bienvenido a Mermegold!",
			"",
			"Con tu tarjeta mermegold,",
			"no tendras que llevar",
			"dinero encima nunca mas.",
			"Podras hacer transacciones",
			"remotas y tendras un",
			"historial completo.",
			"",
			"Podras poner maquinas en",
			"tu local con catalogos",
			"que calculen el total de",
			"forma automatica, y todos",
			"los pagos iran a tu",
			"cuenta. No mas revolver",
			"cofres para recolectar",
			"pagos!"
		},
		create_account_screen = {
			"",
			"",
			"Para hacerse una cuenta,",
			"contactese con un empleado",
			"de Mermegold y arregle una",
			"cita. Abriran juntos la",
			"cuenta en el banco."
		},
		check_balance = "Balance",
		perform_transaction = "Transaccion",
		history = "Historial",
		logout = "Exit",
		transaction_instructions = {"Cuenta a recibir los fondos", "Monto a enviar", "Descripcion"}
	},
	de={
		welcome="Willkommen!",
		unregistered={"Bitte melde","dieses Geraet mit","einem Mermegold","Mitarbeiter an"},
		login = "Anmelden",
		info = "Was ist Mermegold",
		info_screen = {
		"Willkommen bei Mermegold!",
		"",
		"Mit ihrer Mermegold Karte",
		"brauchst du nie wieder",
		"geld dabei zu haben. ",
		"Du wirst in der Lage sein",
		"Transaktionen ferngesteuert mit",
		 "vollstaendigen Log zu erledigen.",
		"",
		"Außerdem koennen Sie",
		"automatisierte shop clerks",
		"mit katalogen und automatischem",
		"checkout an ihren shops installieren.",
		"",
		"Zahlungen werden automatisch in",
		"Ihrem Konto landen ",
		"ohne das sie mueselig durch",
		"Kisten suchen muessen"
		},
		create_account = "Wie erstelle ich ein Konto?",
		create_account_screen = {
		"", "", "", "", "", "", "",
		"Um ein Konto zu eröffnen,",
		"wenden Sie sich an eine*n",
		"Mermegold-Mitarbeiter*in",
		"und vereinbaren Sie einen Termin.",
		"Das Konto wird gemeinsam",
		"in der Bank eröffnet."
		},
		check_balance = "Kontostandt",
		perform_transaction = "Transaktion",
		history = "Log",
		logout = "Abmelden",
		transaction_instructions = {"Empfaenger Konto", "Zu Sendender Betrag", "Beschreibung"}
	},
}


if (fs.exists("mermegold.txt")) then
	local f = fs.open("mermegold.txt", "r")
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

while true do
while true do
	local tempClientData = bankapi.getClientData()
	local command
	if (tempClientData[currentAccount] == nil) then -- Guest screen
		command = bankapi.optionMenu(localization[lang].welcome, {
			[1] = {
			["option"] = "login",
			["text"] = localization[lang].login},
			[2] = {
			["option"] = "info",
			["text"] = localization[lang].info},
			[3] = {
			["option"] = "createaccount",
			["text"] = localization[lang].create_account},
		})

		if (command == "login") then
			local accept = bankapi.confirmScreen(localization[lang].unregistered)
			if (accept) then
				os.reboot()
			end
		elseif (command == "info") then
			bankapi.textScreen(localization[lang].info_screen)
		elseif (command == "createaccount") then
			bankapi.textScreen(localization[lang].create_account_screen)
		end
	else
		local line = string.rep(string.char(140), 3)
		command = bankapi.optionMenu(line.." "..tempClientData[currentAccount].name.." "..line, {
			[1] = {
			["option"] = "balance",
			["text"] = localization[lang].check_balance},
			[2] = {
			["option"] = "transaction",
			["text"] = localization[lang].perform_transaction},
			[3] = {
			["option"] = "log",
			["text"] = localization[lang].history},
			[4] = {
			["option"] = "quit",
			["text"] = localization[lang].logout},
		}, 2, 24)

		if (command == "balance") then
			bankapi.showBalance(currentAccount)

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

		elseif (command == "quit") then
			os.shutdown()
		end
	end
end
end
