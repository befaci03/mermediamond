-- Bank Server
--
-- Split into focused files, all loaded with dofile() so they share this
-- program's scope (settings, currency and account data stay local to the
-- server process and never leak between machines):
--   server/config.lua -> currency definitions, params, settings file I/O
--   server/db.lua     -> clients, custom currencies, cards, transactions
--   server/menu.lua   -> the admin settings menu (main())
--
-- The shared bank API lives in lib/ (bankapi umbrella + uilib + net + cards).

os.loadAPI("lib/bankapi.lua")
if (updateAvailable == nil) then os.loadAPI("updater.lua") end

dofile("server/config.lua")
dofile("server/db.lua")
dofile("server/menu.lua")

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
fs.makeDir(".mermediamond") -- shared settings/data folder (also used by settings.save below)
serverSettings() -- Reads settings from file, sets lang
-- Persist the active language so every ComputerCraft program picks it up via settings.get("lang")
settings.set("lang", lang)
settings.save(".mermediamond/settings")
_G.activeLang = lang
os.loadAPI("lang/languages.lua") -- Loaded after activeLang is set, so tk() uses the right language

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

loadClients()
loadCards()
loadCustomCurrencies()
refreshCurrencyTable()

function listen()
	while true do
		local sender, message = rednet.receive("mermediamond")
		--print("#"..sender.." requested "..message.action)

		if (message.action == "getClientData") then --------------- Get Client Data
			processRequest(getClientData, sender, message)

		elseif (message.action == "getServerData") then ----------- Get Server Data
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

		elseif (message.action == "withdraw") then ---------------- Make a withdrawal
			processRequest(withdraw, sender, message)

		elseif (message.action == "new") then --------------------- Create an account
			processRequest(newClient, sender, message)

		elseif (message.action == "delete") then ------------------ Delete an account
			processRequest(deleteAccount, sender, message)

		elseif (message.action == "cardlogin") then -------------- Log in with a paper card
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

parallel.waitForAll(listen, main)
