currency = {
diamond = {
[1] = {
id="minecraft:diamond", value=1, name={en="Diamond",es="Diamante",de="Diamant",fr="Diamant",pl="Diament"}, plural={en="Diamonds",es="Diamantes",de="Diamanten",fr="Diamants",pl="Diamenty"}, short={en="D",es="D",de="D",fr="D",pl="D"}, uprecipe={need=9,yield=1,result="minecraft:diamond_block"}
}, [2] = {
id="minecraft:diamond_block", value=9, name={en="Diamond Block",es="Bloque de Diamante",de="Diamantblock",fr="Bloc de Diamant",pl="Blok Diamentu"}, plural={en="Diamond Blocks",es="Bloques de Diamante",de="Diamantbloecke",fr="Blocs de Diamant",pl="Bloki Diamentu"}, short={en="Bl",es="Bl",de="Bl",fr="Bl",pl="Bl"}, downrecipe={need=1,yield=9,result="minecraft:diamond_block"}
}
}, gold = {
[1] = {
id="minecraft:gold_nugget", value=1, name={en="Gold Nugget",es="Pepita de Oro",de="Goldnugget",fr="Pepite d'Or",pl="Samorodek Zlota"}, plural={en="Gold Nuggets",es="Pepitas de Oro",de="Goldnuggets",fr="Pepites d'Or",pl="Samorodki Zlota"}, short={en="N",es="P",de="N",fr="P",pl="S"}, uprecipe={need=9,yield=1,result="minecraft:gold_ingot"}
}, [2] = {
id="minecraft:gold_ingot", value=9, name={en="Gold Ingot",es="Lingote de Oro",de="Goldbarren",fr="Lingot d'Or",pl="Sztabka Zlota"}, plural={en="Gold Ingots",es="Lingotes de Oro",de="Goldbarren",fr="Lingots d'Or",pl="Sztabki Zlota"}, short={en="I",es="L",de="B",fr="L",pl="Z"}, downrecipe={need=1,yield=9,result="minecraft:gold_nugget"}, uprecipe={need=9,yield=1,result="minecraft:gold_block"}
}, [3] = {
id="minecraft:gold_block", value=81, name={en="Gold Block",es="Bloque de Oro",de="Goldblock",fr="Bloc d'Or",pl="Blok Zlota"}, plural={en="Gold Blocks",es="Bloques de Oro",de="Goldbloecke",fr="Blocs d'Or",pl="Bloki Zlota"}, short={en="B",es="B",de="B",fr="B",pl="B"}, downrecipe={need=1,yield=9,result="minecraft:gold_ingot"}
}
}, emerald = {
[1] = {
id="minecraft:emerald", value=1, name={en="Emerald",es="Esmeralda",de="Smaragd",fr="Emeraude",pl="Szmaragd"}, plural={en="Emeralds",es="Esmeraldas",de="Smaragde",fr="Emeraudes",pl="Szmaragdy"}, short={en="E",es="E",de="S",fr="E",pl="S"}, uprecipe={need=9,yield=1,result="minecraft:emerald_block"}
}, [2] = {
id="minecraft:emerald_block", value=9, name={en="Emerald Block",es="Bloque de Esmeralda",de="Smaragdblock",fr="Bloc d'Emeraude",pl="Blok Szmaragdu"}, plural={en="Emerald Blocks",es="Bloques de Esmeralda",de="Smaragdbloecke",fr="Blocs d'Emeraude",pl="Bloki Szmaragdu"}, short={en="Bl",es="Bl",de="Bl",fr="Bl",pl="Bl"}, downrecipe={need=1,yield=9,result="minecraft:emerald_block"}
}
}
}
cumulativeLimit = 5000
cumulativePrice = 100
lang = "en-us"
currencyType = "diamond"
terminalPassword = "1234"
valueMultiplier = 100
bankOwnerKey = 0
cardPrefix = "10"
accountPrefix = "MER"
clientData = {}
customCurrencies = {}
filePath = ".mermediamond/"
function updateSettingsFile()
local f = fs.open(filePath.."settings.txt", "w")
f.writeLine("Language:")
f.writeLine(lang)
f.writeLine("Currency type:")
f.writeLine(currencyType)
f.writeLine("Currency value multiplier:")
f.writeLine(valueMultiplier)
f.writeLine("Admin password:")
f.writeLine(terminalPassword)
f.writeLine("Cumulative limit:")
f.writeLine(cumulativeLimit)
f.writeLine("Limit reach cost:")
f.writeLine(cumulativePrice)
f.writeLine("Bank owner ID:")
f.writeLine(bankOwnerKey)
f.writeLine("Card prefix:")
f.writeLine(cardPrefix)
f.writeLine("Account prefix:")
f.writeLine(accountPrefix)
f.close() end
function serverSettings()
if (fs.exists(filePath.."settings.txt")) then local f = fs.open(filePath.."settings.txt", "r")
f.readLine()
local line = f.readLine()
if (line ~= nil and fs.exists("lang/"..line..".json")) then lang = line else lang = "en-us" end
f.readLine()
currencyType = f.readLine()
f.readLine()
valueMultiplier = tonumber(f.readLine()) or 100
f.readLine()
terminalPassword = f.readLine()
f.readLine()
cumulativeLimit = tonumber(f.readLine()) or 5000
f.readLine()
cumulativePrice = tonumber(f.readLine()) or 100
f.readLine()
bankOwnerKey = f.readLine()
f.readLine()
local cp = f.readLine()
if (cp ~= nil and string.match(cp, "^%d%d$")) then cardPrefix = cp end
f.readLine()
local ap = f.readLine()
if (ap ~= nil and string.match(ap, "^%a%a%a$")) then accountPrefix = string.upper(ap) end
f.close()
else updateSettingsFile() end end
