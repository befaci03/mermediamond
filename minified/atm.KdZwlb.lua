local linkedInterfaceID
local clientInterface = peripheral.wrap("front")
local storage = peripheral.wrap("bottom")
local workChest = peripheral.wrap("top")
local serverData
print("Looking for modem...")
peripheral.find("modem", rednet.open)
print("Found modem!")
local f = fs.open("interface.txt", "r")
if (f ~= nil) then linkedInterfaceID = f.readLine()
print("Connected to interface #"..linkedInterfaceID)
f.close()
else print("Finding interface...")
local sender, message = rednet.receive("mermediamond_customer")
if (message == "hiring") then rednet.send(sender, "offering", "mermediamond_customer")
linkedInterfaceID = sender end
print("interface found! #"..linkedInterfaceID)
local f = fs.open("interface.txt", "w")
f.write(tostring(linkedInterfaceID))
f.close() end
local function processRequest(func, sender, data)
serverData = data.serverData
local success, response = func(data)
local message = {
success = success, response = response
}
rednet.send(sender, message, "mermediamond_customer") end
local function calculateValue()
local value = 0
for slot, item in pairs(clientInterface.list()) do for k, v in ipairs(serverData.currency) do if (item.name == v.id) then value = value + v.value*item.count*serverData.valueMultiplier
break end end end
return true, value end
local function countValueInside()
local value = 0
for i=1, 16 do local item = turtle.getItemDetail(i)
if (item ~= nil) then local isCurrency = false
for k, v in ipairs(serverData.currency) do if (item.name == v.id) then value = value + v.value*item.count*serverData.valueMultiplier
isCurrency = true
break end end
if (not isCurrency) then turtle.select(i)
turtle.drop() end end end
return value end
local function reduceStorage(data)
for k, v in ipairs(serverData.currency) do if(v.uprecipe ~= nil) then local stored = 0
for _, item in pairs(storage.list()) do if (item.name == v.id) then stored = stored + item.count end end
local craftsremaining = math.floor(stored/v.uprecipe.need)
if (craftsremaining > 0) then for slot, item in pairs(storage.list()) do if (item.name ~= v.id) then storage.pushItems(peripheral.getName(workChest), slot) end end end
while (craftsremaining > 0) do local crafts = math.min(craftsremaining, 64)
craftsremaining = craftsremaining - crafts
for i=1, v.uprecipe.need do local turtleSlot = i
if (i > 3) then turtleSlot = turtleSlot + 1 end
if (i > 6) then turtleSlot = turtleSlot + 1 end
turtle.select(turtleSlot)
local remaining = crafts - turtle.getItemCount(turtleSlot)
while (remaining > 0) do turtle.suckDown(remaining)
remaining = crafts - turtle.getItemCount(turtleSlot) end end
turtle.craft()
for i=1, 16 do if (turtle.getItemCount(i) > 0) then turtle.select(i)
turtle.dropUp() end end end
for slot, item in pairs(workChest.list()) do workChest.pushItems(peripheral.getName(storage), slot) end end end
return true, "done" end
local function deposit()
while (turtle.suck()) do end
local message = countValueInside()
for i=1, 16 do if (turtle.getItemCount(i) > 0) then turtle.select(i)
turtle.dropDown() end end
return true, message end
local function craftFromHigherCurrency(currency, amount)
local higherCurrency
local downgradeYield
if (not currency.uprecipe) then return false end
for k, v in ipairs(serverData.currency) do if (v.id == currency.uprecipe.result) then higherCurrency = v
downgradeYield = higherCurrency.downrecipe.yield
break end end
if (higherCurrency == nil) then return false end
local higherCurrencyPresent = 0
local higherCurrencyNeeded = amount/downgradeYield
for slot, item in pairs(storage.list()) do if (item.name == higherCurrency.id) then higherCurrencyPresent = higherCurrencyPresent+item.count
if (higherCurrencyPresent >= higherCurrencyNeeded) then break end end end
if (higherCurrencyPresent < higherCurrencyNeeded) then craftFromHigherCurrency(higherCurrency,  math.ceil(higherCurrencyNeeded-higherCurrencyPresent)) end
local crafts = math.ceil(amount/downgradeYield)
for slot, item in pairs(storage.list()) do if (item.name == higherCurrency.id) then turtle.select(1)
turtle.suckDown(crafts)
turtle.craft()
while(turtle.dropDown()) do end
break
else storage.pushItems(peripheral.getName(workChest), slot) end end
for slot, item in pairs(workChest.list()) do workChest.pushItems(peripheral.getName(storage), slot) end end
local function giveItems(currency, amount)
print(currency.id..": "..amount)
local stock = 0
for slot, item in pairs(storage.list()) do if (item.name == currency.id) then stock = stock + item.count end end
if (stock < amount) then craftFromHigherCurrency(currency, amount-stock) end
local remaining = amount
for slot, item in pairs(storage.list()) do if (item.name == currency.id) then print("Giving client "..math.min(remaining, item.count).." "..item.name)
storage.pushItems(peripheral.getName(clientInterface), slot, math.min(remaining, item.count))
remaining = remaining - item.count
if (remaining < 1) then break end end end end
local function withdraw(data)
if (data.amount == "" or data.amount == nil) then return false, "invalid_amount" end
print("Counting vault...")
local storedValue = 0
for i = #serverData.currency, 1, -1 do local currency = serverData.currency[i]
if (not currency.ingredient) then for slot, item in pairs(storage.list()) do if (item.name == currency.id) then storedValue = storedValue + currency.value*item.count end end end end
print("Stored amount: "..storedValue)
if (storedValue < data.amount) then return false, "not_enough_stored" end
local remainingValue = data.amount
print("Withdrawing: "..remainingValue)
for i = #serverData.currency, 1, -1 do local currency = serverData.currency[i]
if (currency.ingredient == nil or currency.ingredient == false) then local give = math.floor(remainingValue/(currency.value))
if (give > 0) then remainingValue = remainingValue - give*(currency.value)
giveItems(currency, give) end end end
return true, "Success" end
while (true) do local sender, message = rednet.receive("mermediamond_customer")
if (tonumber(sender) == tonumber(linkedInterfaceID)) then if (message.action == "calculateValue") then processRequest(calculateValue, sender, message)
elseif (message.action == "deposit") then processRequest(deposit, sender, message)
elseif (message.action == "withdraw") then processRequest(withdraw, sender, message)
elseif (message.action == "reduce") then processRequest(reduceStorage, sender, message) end end end
