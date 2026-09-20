local N = {}
N.bankServerID = 0
N.serverData = nil
N.lang = "en-us"
N.maxRetries = 5
N.retryDelay = 2
local clientDataCache = nil
function N.invalidateClientData() clientDataCache = nil end
local function isReply(sender, response) return response ~= nil and os.computerID() ~= sender and response.response ~= nil end
local spinnerFrames = { "|", "/", "-", "\\" }
local function spin(frame)
local x, y = term.getCursorPos()
term.write(spinnerFrames[(frame % #spinnerFrames)+1])
term.setCursorPos(x, y) end
local function offlineScreen(message)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.red)
term.clear()
term.setCursorPos(1, 2)
print("== Cannot reach the bank server ==")
print("")
term.setTextColor(colors.white)
print(tostring(message or ""))
print("")
print("Check that:")
print("- the bank server is on and chunk-loaded")
print("- both machines have a wireless modem")
print("")
term.setTextColor(colors.yellow)
print("Retrying in "..N.retryDelay.." seconds... (hold Ctrl+T to stop)")
sleep(N.retryDelay) end
function N.call(action, payload, opts)
opts = opts or {}
local message = payload or {}
message.action = action
for attempt = 1, N.maxRetries do rednet.send(N.bankServerID, message, "mermediamond")
local sender, response = rednet.receive("mermediamond", opts.timeout or 5)
if isReply(sender, response) then return response end
if (not opts.retry) then return nil end
sleep(N.retryDelay) end
return nil end
function N.getServerData()
print("Connecting to server...")
local frame = 0
for attempt = 1, N.maxRetries do rednet.broadcast({ action = "getServerData" }, "mermediamond")
local sender, response = rednet.receive("mermediamond", 3)
if isReply(sender, response) then N.bankServerID = sender
N.serverData = response.response
N.lang = response.response.lang or N.lang
_G.activeLang = N.lang
if (setLang ~= nil) then setLang(N.lang) end
print("Connected to server [#"..sender.."]")
return response.response end
frame = frame+1
spin(frame)
sleep(N.retryDelay) end
while true do offlineScreen("The client cannot start without the server.")
rednet.broadcast({ action = "getServerData" }, "mermediamond")
local sender, response = rednet.receive("mermediamond", 3)
if isReply(sender, response) then N.bankServerID = sender
N.serverData = response.response
N.lang = response.response.lang or N.lang
_G.activeLang = N.lang
if (setLang ~= nil) then setLang(N.lang) end
print("Connected to server [#"..sender.."]")
return response.response end
frame = frame+1
spin(frame) end end
function N.getClientData(force)
if (not force and clientDataCache ~= nil) then return clientDataCache end
local response = N.call("getClientData", nil, { retry = true })
if (response == nil) then return nil end
clientDataCache = response.response
return clientDataCache end
function N.getTransactionLog(key)
local response = N.call("getTransactionLog", { key = key }, { retry = true })
if (response == nil) then return nil end
return response.response end
function N.transaction(from, to, amount, description)
local response = N.call("transaction", {
from = from, to = to, amount = amount, description = description
})
if (response == nil) then return false, "No connection to the server" end
return response.success, response.response end
function N.deposit(key, amount)
local response = N.call("deposit", { key = key, amount = amount })
if (response == nil) then return false, "No connection to the server" end
return response.success, response.response end
function N.withdraw(key, amount)
local response = N.call("withdraw", { key = key, amount = amount })
if (response == nil) then return false, "No connection to the server" end
return response.success, response.response end
function N.newAccount(name, balance, color)
local response = N.call("new", { name = name, balance = balance, color = color })
if (response == nil) then return false, "No connection to the server" end
if (response.success) then clientDataCache = nil end
return response.success, response.response end
function N.deleteAccount(key)
local response = N.call("delete", { key = key })
if (response == nil) then return false, "No connection to the server" end
if (response.success) then clientDataCache = nil end
return response.success, response.response end
function N.cardLogin(card)
local response = N.call("cardlogin", { card = card })
if (response == nil) then return false, "No connection to the server" end
return response.success, response.response end
function N.assignCard(account)
local response = N.call("assigncard", { account = account })
if (response == nil) then return false, "No connection to the server" end
return response.success, response.response end
function N.autoUpdate(program, silent)
if (updater ~= nil and updater.autoUpdate ~= nil) then local ok, result = pcall(updater.autoUpdate, program, silent)
if (ok) then return result end end
return false end
return N
