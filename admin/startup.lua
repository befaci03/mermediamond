-- Admin Terminal

-----------------------Params
local bankServerID
local adminPassword

local text_error_noconnection = "Can't connect to server"
--------------------------
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
--------------------------

local localization = {
	en={
		create_account = "Create new account",
		perform_transaction = "Perform transaction",
		check_balance = "Check balance",
		delete_account = "Delete account",
		record = "Transaction Logs",
		assign_card = "Link account to card/phone",
		install_app = "Install application on phone",
		logout = "Exit",
		new_account_steps = {"Username", "Representative color"},
		transaction_steps = {"Sender account", "Recipient account", "Amount", "Transaction description"},
		delete_account_steps = {"Cuenta a eliminar"},
		check_log = {"Account to check"},
		account_to_link = {"Account to link"},
		linked_to = "Card linked to ",
		insert_card = "Please insert disk or phone into disk drive",
		installed = "Application installed!",
		insert_pocket = "Please insert phone into disk drive",
		confirm_deletion = "Are you sure you want to delete this account?"
	},
	es={
		create_account = "Crear nueva cuenta",
		perform_transaction = "Realizar transaccion",
		check_balance = "Consultar balance",
		delete_account = "Borrar cuenta",
		record = "Historial de transacciones",
		assign_card = "Vincular cuenta a tarjeta/movil",
		install_app = "Instalar aplicacion en movil",
		logout = "Salir",
		new_account_steps = {"Nombre del usuario", "Color representativo"},
		transaction_steps = {"Cuenta a proveer los fondos", "Cuenta a recibir los fondos", "Monto a enviar", "Descripcion de la transaccion"},
		delete_account_steps = {"Cuenta a eliminar"},
		check_log = {"Cuenta a consultar"},
		account_to_link = {"Cuenta a vincular"},
		linked_to = "Tarjeta asignada a ",
		insert_card = "Por favor inserte un disco o un movil en la disquetera",
		installed = "Aplicacion instalada!",
		insert_pocket = "Por favor inserte un movil en la disquetera",
		confirm_deletion = "Estas seguro que quieres borrar esta cuenta?"
	},
	de={
		create_account = "Neues Konto erstellen",
		perform_transaction = "Transaktion Durchfuehren",
		check_balance = "Kontostand ueberpruefen",
		delete_account = "Konto loeschen",
		record = "Transaktions Logs",
		assign_card = "Verbinde ein Konto mit eine/r/m Karte/Telefon",
		install_app = "Installiere die Anwendung auf dem Telefon",
		logout = "Ausloggen",
		new_account_steps = {"Nutzername", "Anzeige Farbe"},
		transaction_steps = {"Sender Konto", "Empfaenger Konto", "Betrag", "Transaktions Beschreibung"},
		delete_account_steps = {"Konto zum Loeschen"},
		check_log = {"Konto zum ueberpruefen"},
		account_to_link = {"Konto zum Verbinden"},
		linked_to = "Karte verbunden mit ",
		insert_card = "Bitte legen Sie eine Disk oder ein Telefon in das Laufwerk ein",
		installed = "Anwendung installiert!",
		insert_pocket = "Bitte lege ein Telefon in das Laufwerk ein",
		confirm_deletion = "Sind Sie sicher, dass Sie dieses Konto löschen möchten?"
	}
}

-- Password protection
local pass = ""
repeat
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.yellow)
	term.clear()
	local scrW, scrH = term.getSize()
	local title = "Mermegold"
	term.setCursorPos(scrW/2-string.len(title)/2, scrH/2)
	term.write(title)
	term.setCursorPos(scrW/2-string.len(title)/2, scrH/2+1)
	pass = read("*")
until (pass == serverData.terminalPassword)

while true do -- Second while to allow the use of breaks as continues
while true do
	
	local command = bankapi.optionMenu("Mermegold", {
		{option = "new",
		text = localization[lang].create_account},
		{option = "transaction",
		text = localization[lang].perform_transaction},
		{option = "balance",
		text = localization[lang].check_balance},
		{option = "delete",
		text = localization[lang].delete_account},
		{option = "log",
		text = localization[lang].record},
		{option = "assigncard",
		text = localization[lang].assign_card},
		{option = "installapp",
		text = localization[lang].install_app},
		{option = "logout",
		text =  localization[lang].logout},
	}, 2, 36)

	if (command == "new") then
		local steps = localization[lang].new_account_steps
		local name = bankapi.inputTextScreen(steps, 1, 25)
		if (name == nil) then break end
		local color = bankapi.selectColorScreen(steps, 2)
		if (color == nil) then break end

		local success, message = bankapi.newAccount(name, 0, color)
		bankapi.responseScreen(success, message)

	elseif (command == "transaction") then
		local tempClientData = bankapi.getClientData()
		local steps = localization[lang].transaction_steps
		local from = bankapi.selectAccountScreen(steps, 1, 0)
		if (from == nil) then break end
		local to = bankapi.selectAccountScreen(steps, 2, from)
		if (to == nil) then break end
		local amount = bankapi.inputNumberScreen(steps, 3, tempClientData[from].balance)
		if (amount == nil) then break end
		local description = bankapi.inputTextScreen(steps, 4, 100)
		if (description == nil) then break end

		local success, message = bankapi.transaction(from, to, amount, description)
		bankapi.responseScreen(success, message)

	elseif (command == "delete") then
		local steps = localization[lang].delete_account_steps
		local deletion = bankapi.selectAccountScreen(steps, 1, 0)
		if (deletion == nil) then break end

		local tempClientData = bankapi.getClientData()
		local accept = bankapi.confirmScreen({localization[lang].confirm_deletion}, {
			name = tempClientData[deletion].name,
			key = deletion,
			balance = tempClientData[deletion].balance
		})
		if (not accept) then break end

		local success, message = bankapi.deleteAccount(deletion)
		bankapi.responseScreen(success, message)

	elseif (command == "log") then
		local tempClientData = bankapi.getClientData()
		local steps = localization[lang].check_log
		local account = bankapi.selectAccountScreen(steps, 1, 0)
		if (account == nil) then break end
		bankapi.transactionLogScreen(account)

	elseif (command == "balance") then
		
		local account = bankapi.selectAccountScreen(localization[lang].check_log, 1, 0)
		if (account == nil) then break end
		bankapi.showBalance(account)

	elseif (command == "assigncard") then
		if (fs.exists("disk")) then
			local account = bankapi.selectAccountScreen(localization[lang].account_to_link, 1, 0)
			if (account == nil) then break end
			local tempClientData = bankapi.getClientData()
			local name = tempClientData[account].name
			local f = fs.open("disk/mermegold.txt", "w")
			f.write(account)
			f.close()
			local diskdrive = peripheral.find("drive")
			diskdrive.setDiskLabel("Mermegold | "..name)
			bankapi.successScreen(localization[lang].linked_to..name)
		else
			bankapi.errorScreen(localization[lang].insert_card)
		end
	
	elseif (command == "installapp") then
		if (fs.exists("disk")) then
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
			term.setCursorPos(1,1)
			term.clear()
			print("Installing Mermegold app in inserted phone...")
			shell.run("delete disk/startup.lua")
			shell.run("pastebin get GpTzmZts disk/startup.lua")
			shell.run("delete disk/bankapi.lua")
			shell.run("pastebin get wSKUaGG0 disk/bankapi.lua")
			shell.run("delete disk/mermeapp.lua")
			shell.run("pastebin get Nc59jRaa disk/mermeapp.lua")
			bankapi.successScreen(localization[lang].installed)
		else
			bankapi.errorScreen(localization[lang].insert_pocket)
		end

	elseif (command == "logout") then
		os.reboot()
	end
end
end
