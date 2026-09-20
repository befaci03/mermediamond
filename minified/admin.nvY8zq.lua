local bankServerID
local adminPassword
local text_error_noconnection = "Can't connect to server"
local modem = peripheral.find("modem")
while (modem == nil) do modem = peripheral.find("modem")
if (modem == nil) then term.setBackgroundColor(colors.red)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("Ender modem required. Please connect a modem to continue...")
os.pullEvent("peripheral") end end
peripheral.find("modem", rednet.open)
if (fs.exists("lib/bankapi.lua")) then os.loadAPI("lib/bankapi.lua")
elseif (fs.exists("bankapi.lua")) then os.loadAPI("bankapi.lua")
else error("bankapi not found: lib/bankapi.lua is missing") end
local serverData = bankapi.getServerData()
local lang = serverData.lang
bankapi.autoUpdate("admin")
local pass = ""
repeat
term.setBackgroundColor(colors.black)
term.setTextColor(colors.yellow)
term.clear()
local scrW, scrH = term.getSize()
local title = "Mermediamond"
term.setCursorPos(scrW/2-string.len(title)/2, scrH/2)
term.write(title)
term.setCursorPos(scrW/2-string.len(title)/2, scrH/2+1)
pass = read("*") until (pass == serverData.terminalPassword)
while true do while true do local command = bankapi.optionMenu("Mermediamond", {
{option = "new", text = tk("pocket.create_account")}, {option = "transaction", text = tk("pocket.perform_transaction")}, {option = "balance", text = tk("pocket.check_balance")}, {option = "delete", text = tk("server.delete_account")}, {option = "log", text = tk("server.record")}, {option = "issuecard", text = tk("card.issue")}, {option = "installapp", text = tk("pocket.install_app")}, {option = "logout", text =  tk("pocket.logout")}, }, 2, 36)
if (command == "new") then local steps = tk("server.new_account_steps")
local name = bankapi.inputTextScreen(steps, 1, 25)
if (name == nil) then break end
local color = bankapi.selectColorScreen(steps, 2)
if (color == nil) then break end
local success, message = bankapi.newAccount(name, 0, color)
bankapi.responseScreen(success, message)
elseif (command == "transaction") then local tempClientData = bankapi.getClientData()
local steps = tk("server.transaction_steps")
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
elseif (command == "delete") then local steps = tk("server.delete_account_steps")
local deletion = bankapi.selectAccountScreen(steps, 1, 0)
if (deletion == nil) then break end
local tempClientData = bankapi.getClientData()
local accept = bankapi.confirmScreen({tk("server.confirm_deletion")}, {
name = tempClientData[deletion].name, key = deletion, balance = tempClientData[deletion].balance
})
if (not accept) then break end
local success, message = bankapi.deleteAccount(deletion)
bankapi.responseScreen(success, message)
elseif (command == "log") then local tempClientData = bankapi.getClientData()
local steps = tk("server.check_log")
local account = bankapi.selectAccountScreen(steps, 1, 0)
if (account == nil) then break end
bankapi.transactionLogScreen(account)
elseif (command == "balance") then local account = bankapi.selectAccountScreen(tk("server.check_log"), 1, 0)
if (account == nil) then break end
bankapi.showBalance(account)
elseif (command == "issuecard") then local account = bankapi.selectAccountScreen(tk("pocket.account_to_link"), 1, 0)
if (account == nil) then break end
local tempClientData = bankapi.getClientData()
local name = tempClientData[account].name
local success, card = bankapi.assignCard(account)
if (not success) then bankapi.errorScreen(card)
break end
bankapi.waitScreen({
tk("card.printed_header"), "", tk("card.holder")..": "..name, tk("card.card_id")..": "..card.cardId, tk("card.expires")..": "..card.expiration, tk("card.cvc")..": "..card.cvc, tk("card.account")..": "..card.account
})
local printed = bankapi.printCard(card, name, card.account)
if (printed) then bankapi.successScreen(tk("card.printed"))
else bankapi.successScreen({tk("card.holder")..": "..name, tk("card.card_id")..": "..card.cardId}) end
elseif (command == "installapp") then if (fs.exists("disk")) then term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1,1)
term.clear()
print("Installing Mermediamond app in inserted phone...")
shell.run("delete disk/startup.lua")
local appBranch = "main"
local appBase = "https://raw.githubusercontent.com/befaci03/mermediamond/refs/heads/"..appBranch
if (http ~= nil) then local res = http.get(appBase.."/minified/.min.map")
if (res ~= nil) then local map = textutils.unserialiseJSON(res.readAll())
res.close()
if (map ~= nil) then for minName, srcPath in pairs(map) do if (srcPath == "phone/app.lua") then shell.run("wget "..appBase.."/minified/"..minName.." disk/startup.lua")
break end end end end end
if (not fs.exists("disk/startup.lua")) then shell.run("wget "..appBase.."/phone/app.lua disk/startup.lua") end
if (not fs.exists("disk/startup.lua")) then bankapi.errorScreen("Failed to download the mobile app (no internet?)")
else fs.delete("disk/lib")
fs.makeDir("disk/lib")
fs.copy("lib/bankapi.lua", "disk/lib/bankapi.lua")
fs.copy("lib/uilib.lua", "disk/lib/uilib.lua")
fs.copy("lib/net.lua", "disk/lib/net.lua")
fs.copy("lib/cards.lua", "disk/lib/cards.lua")
fs.makeDir("disk/server")
for _, srvFile in ipairs({"config.lua", "db.lua", "menu.lua"}) do if (fs.exists("server/"..srvFile)) then fs.copy("server/"..srvFile, "disk/server/"..srvFile) end end
fs.delete("disk/lang")
fs.makeDir("disk/lang")
for _, langFile in ipairs(fs.list("lang")) do fs.copy("lang/"..langFile, "disk/lang/"..langFile) end
if (fs.exists("updater.lua")) then fs.copy("updater.lua", "disk/updater.lua") end
if (fs.exists("ver")) then fs.copy("ver", "disk/ver") end
bankapi.successScreen(tk("pocket.installed")) end
else bankapi.errorScreen(tk("pocket.insert_pocket")) end
elseif (command == "logout") then os.reboot() end end end
