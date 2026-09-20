os.loadAPI("lib/bankapi.lua")
if (updateAvailable == nil) then os.loadAPI("updater.lua") end
dofile("server/config.lua")
dofile("server/db.lua")
dofile("server/menu.lua")
local function processRequest(func, sender, data)
local success, response = func(data)
local message = {
success = success, response = response
}
rednet.send(sender, message, "mermediamond") end
fs.makeDir(".mermediamond")
serverSettings()
settings.set("lang", lang)
settings.save(".mermediamond/settings")
_G.activeLang = lang
os.loadAPI("lang/languages.lua")
if (currency[currencyType] == nil) then currencyType = "diamond" end
local modem = peripheral.find("modem")
while (modem == nil) do modem = peripheral.find("modem")
if (modem == nil) then term.setBackgroundColor(colors.red)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("Ender modem required. Please connect a modem to continue...")
os.pullEvent("peripheral") end end
peripheral.find("modem", rednet.open)
loadClients()
loadCards()
loadCustomCurrencies()
refreshCurrencyTable()
function listen()
while true do local sender, message = rednet.receive("mermediamond")
if (message.action == "getClientData") then processRequest(getClientData, sender, message)
elseif (message.action == "getServerData") then processRequest(getServerData, sender, message)
elseif (message.action == "getVersion") then processRequest(getVersion, sender, message)
elseif (message.action == "getfile") then processRequest(getFile, sender, message)
elseif (message.action == "getTransactionLog") then processRequest(getTransactionLog, sender, message)
elseif (message.action == "transaction") then processRequest(transaction, sender, message)
elseif (message.action == "deposit") then processRequest(deposit, sender, message)
elseif (message.action == "withdraw") then processRequest(withdraw, sender, message)
elseif (message.action == "new") then processRequest(newClient, sender, message)
elseif (message.action == "delete") then processRequest(deleteAccount, sender, message)
elseif (message.action == "cardlogin") then processRequest(cardLogin, sender, message)
elseif (message.action == "assigncard") then processRequest(assignCard, sender, message)
else local message = {
success = false, response = "Invalid request"
}
rednet.send(sender, message, "mermediamond") end end end
parallel.waitForAll(listen, main)
