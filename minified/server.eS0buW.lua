function main()
while true do while true do local ownerName = tk("server.not_assigned")
if (bankOwnerKey ~= nil and bankOwnerKey ~= 0) then if (clientData[bankOwnerKey] == nil) then ownerName = tk("server.deleted_account")
else ownerName = clientData[bankOwnerKey].name end end
local command = bankapi.optionMenu(tk("server.title"), {
{option = "language", text = tk("server.language")..": "..tk("server."..lang)}, {option = "currency_type", text =  tk("server.currency_type")..": "..currency[currencyType][1].name[string.sub(lang,1,2)]}, {option = "value_multiplier", text =  tk("server.value_multiplier")..": "..valueMultiplier.."$"}, {option = "cumulative_limit", text =  tk("server.cumulative_limit")..": "..cumulativeLimit.."$"}, {option = "limit_reach_cost", text =  tk("server.limit_reach_cost")..": "..cumulativePrice.."$"}, {option = "password", text =  tk("server.password")..": "..terminalPassword}, {option = "set_owner", text =  tk("server.set_owner")..": "..ownerName}, {option = "card_prefix", text =  tk("server.card_prefix")..": "..cardPrefix.."-xxxx-xxxx-xxxx"}, {option = "account_prefix", text =  tk("server.account_prefix")..": "..accountPrefix.."-xxxxxxxxxxx"}, {option = "add_currency", text =  tk("server.add_currency")}, {option = "remove_currency", text =  tk("server.remove_currency")}, {option = "version", text =  "Version: "..tostring(updater.readVer("") and updater.readVer("").version or "unknown")}, }, 2, 40)
if (command == "language") then local langOptions = {}
local langFiles = fs.list("lang/")
table.sort(langFiles)
for _, langFile in ipairs(langFiles) do if (string.sub(langFile, -5) == ".json") then local code = string.sub(langFile, 1, -6)
table.insert(langOptions, {
option = code, text = tk("en-us", "server."..code)
}) end end
local subcommand = bankapi.optionMenu(tk("server.language"), langOptions, 1)
lang = subcommand
settings.set("lang", lang)
settings.save(".mermediamond/settings")
_G.activeLang = lang
updateSettingsFile()
break
elseif (command == "currency_type") then local currencyOptions = {}
local currencyKeys = {}
for key in pairs(currency) do table.insert(currencyKeys, key) end
table.sort(currencyKeys)
for _, key in ipairs(currencyKeys) do local item = currency[key][1]
local displayName = item.id
if (item.name[string.sub(lang,1,2)] ~= nil) then displayName = item.name[string.sub(lang,1,2)] end
table.insert(currencyOptions, {option = key, text = displayName}) end
local subcommand = bankapi.optionMenu(tk("server.currency_type"), currencyOptions, 2)
currencyType = subcommand
updateSettingsFile()
break
elseif (command == "add_currency") then local steps = {
tk("server.currency_item_id"), tk("server.currency_item_value"), tk("server.currency_item_name"), tk("server.currency_item_plural"), tk("server.currency_item_short")
}
local id = bankapi.inputTextScreen(steps, 1, 60)
if (id == nil or id == "") then break end
local value = bankapi.inputNumberScreen(steps, 2)
if (value == nil) then break end
local name = bankapi.inputTextScreen(steps, 3, 30)
if (name == nil or name == "") then break end
local plural = bankapi.inputTextScreen(steps, 4, 30)
if (plural == nil or plural == "") then break end
local short = bankapi.inputTextScreen(steps, 5, 3)
if (short == nil or short == "") then break end
local key = string.gsub(string.gsub(id, ":", "_"), "%W", "_")
if (currency[key] ~= nil and customCurrencies[key] == nil) then bankapi.errorScreen(tk("api.invalid_value"))
break end
local langCodes = {"en","es","de","fr","nl","it","pt","pl","ru","ar","tr","sv"}
local names, pluralNames, shorts = {}, {}, {}
for _, langCode in ipairs(langCodes) do names[langCode] = name
pluralNames[langCode] = plural
shorts[langCode] = short end
customCurrencies[key] = {
[1] = {
id = id, value = tonumber(value), name = names, plural = pluralNames, short = shorts
}
}
currency[key] = customCurrencies[key]
saveCustomCurrencies()
bankapi.successScreen(tk("server.currency_added"))
break
elseif (command == "remove_currency") then local customKeys = {}
for key in pairs(customCurrencies) do table.insert(customKeys, key) end
if (#customKeys == 0) then bankapi.errorScreen(tk("server.no_custom_currency"))
break end
table.sort(customKeys)
local removeOptions = {}
for _, key in ipairs(customKeys) do table.insert(removeOptions, {option = key, text = customCurrencies[key][1].id}) end
local subcommand = bankapi.optionMenu(tk("server.remove_currency"), removeOptions, 2)
customCurrencies[subcommand] = nil
saveCustomCurrencies()
if (currencyType == subcommand) then currencyType = "diamond"
updateSettingsFile() end
break
elseif (command == "value_multiplier") then local amount = bankapi.inputNumberScreen({tk("server.value_multiplier_explanation")}, 1)
amount = tonumber(amount)
if (amount == nil) then break end
if (amount <= 0) then bankapi.errorScreen(tk("server.error_invalidamount")) end
valueMultiplier = amount
updateSettingsFile()
break
elseif (command == "password") then local newPassword = bankapi.inputTextScreen({tk("server.password_explanation")}, 1, 10)
if (newPassword == "" or newPassword == nil) then break end
terminalPassword = newPassword
updateSettingsFile()
break
elseif (command == "cumulative_limit") then local amount = bankapi.inputNumberScreen({tk("server.cumulative_limit_explanation")}, 1)
amount = tonumber(amount)
if (amount == nil) then break end
if (amount <= 0) then bankapi.errorScreen(tk("server.error_invalidamount")) end
cumulativeLimit = amount
updateSettingsFile()
break
elseif (command == "limit_reach_cost") then local amount = bankapi.inputNumberScreen({tk("server.limit_reach_cost_explanation")}, 1)
amount = tonumber(amount)
if (amount == nil) then break end
if (amount <= 0) then bankapi.errorScreen(tk("server.error_invalidamount")) end
cumulativePrice = amount
updateSettingsFile()
break
elseif (command == "set_owner") then local account = bankapi.selectAccountScreen({tk("server.set_owner_explanation")}, 1, 0, clientData)
if (account == nil) then break end
bankOwnerKey = account
updateSettingsFile()
elseif (command == "card_prefix") then local prefix = bankapi.inputTextScreen({tk("server.card_prefix_explanation")}, 1, 2)
if (prefix == nil or prefix == "") then break end
if (string.match(prefix, "^%d%d$")) then cardPrefix = prefix
updateSettingsFile()
else bankapi.errorScreen(tk("api.invalid_value")) end
elseif (command == "account_prefix") then local prefix = bankapi.inputTextScreen({tk("server.account_prefix_explanation")}, 1, 3)
if (prefix == nil or prefix == "") then break end
if (string.match(prefix, "^%a%a%a$")) then accountPrefix = string.upper(prefix)
updateSettingsFile()
else bankapi.errorScreen(tk("api.invalid_value")) end
elseif (command == "version") then local ver = nil
ver = updater.readVer("")
bankapi.textScreen({
"Mermediamond bank server", "Version: "..tostring(ver and ver.version or "unknown"), "Commit: "..tostring(ver and ver.commit or "unknown"), "", "Clients check against this version", "at boot and update themselves."
}) end end end end
