local C = {}
local U = uilib
function C.readPrintedCard(title)
local _, scrH = term.getSize()
while true do U.drawBackground()
term.setTextColor(U.specialTextColor)
term.setCursorPos(1, 2)
if (type(title) == "table") then for _, v in ipairs(title) do print(v) end
elseif (title ~= nil) then print(title) end
term.setTextColor(U.grayedOutColor)
print(tk("card.machine_line")..":")
term.setTextColor(colors.white)
term.setCursorPos(2, scrH-3)
local line = U.cancelableRead(0)
if (line == nil) then return nil end
line = string.gsub(line, "^%s+", ""):gsub("%s+$", "")
local card = C.decodeCardLine(line)
if (card == nil) then U.errorScreen(tk("card.invalid_card"))
else return card end end end
function C.encodeCardLine(card)
if (card.cardId == nil or card.expiration == nil or card.cvc == nil) then return nil end
return string.rep(">", string.len(card.cardId))..card.cardId.. string.rep(">", string.len(card.expiration))..card.expiration.. string.rep(">", string.len(card.cvc))..card.cvc end
function C.decodeCardLine(line)
if (line == nil) then return nil end
local fields = {}
for value in string.gmatch(line, ">+([^>]+)") do if (#fields == 3) then return nil end
fields[#fields+1] = value end
if (#fields ~= 3) then return nil end
local card = { cardId = fields[1], expiration = fields[2], cvc = fields[3] }
if (not C.validCardId(card.cardId)) then return nil end
if (not C.validExpiration(card.expiration)) then return nil end
if (not C.validCVC(card.cvc)) then return nil end
if (C.encodeCardLine(card) ~= line) then return nil end
return card end
function C.cardPaperLines(card, holderName, accountKey)
local lines = {
tk("card.printed_header"), "", tk("card.holder")..": "..tostring(holderName), tk("card.card_id")..": "..card.cardId, tk("card.expires")..": "..card.expiration, tk("card.cvc")..": "..card.cvc, tk("card.account")..": "..tostring(accountKey)
}
return lines end
function C.printCard(card, holderName, accountKey)
while (true) do local printer = peripheral.find("printer")
if (printer ~= nil) then local page = printer.newPage()
if (page ~= nil) then local machineLine = C.encodeCardLine(card)
page.write(machineLine)
page.setCursorPos(1, 2)
local lines = C.cardPaperLines(card, holderName, accountKey)
for _, v in ipairs(lines) do page.write(v)
local _, cy = page.getCursorPos()
page.setCursorPos(1, cy+1) end
if (printer.endPage()) then return true end end end
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
print(tk("card.no_printer"))
local event, key = os.pullEvent("key")
if (key == keys.q) then return false end end end
function C.validCardId(id)
if (type(id) ~= "string") then return false end
return string.match(id, "^%d%d%-%d%d%d%d%-%d%d%d%d%-%d%d%d%d$") ~= nil end
function C.validExpiration(exp)
if (type(exp) ~= "string") then return false end
if (string.match(exp, "^%d%d/%d%d$") == nil) then return false end
local month = tonumber(string.sub(exp, 1, 2))
return month >= 1 and month <= 12 end
function C.cardExpired(exp)
local month = tonumber(string.sub(exp, 1, 2))
local year = tonumber(string.sub(exp, 4, 5))
local nowMonth = tonumber(os.date("%m"))
local nowYear = tonumber(os.date("%y"))
if (year < nowYear) then return true end
if (year == nowYear and month < nowMonth) then return true end
return false end
function C.validCVC(cvc)
if (type(cvc) ~= "string") then return false end
return string.match(cvc, "^%d%d%d%d%d?%d?%d?%d?$") ~= nil end
function C.generateCardId(prefix)
if (prefix == nil) then prefix = "00" end
local digits = prefix
for i=1, 12 do digits = digits..tostring(math.random(10)-1) end
return string.sub(digits, 1, 2).."-"..string.sub(digits, 3, 6).."-"..string.sub(digits, 7, 10).."-"..string.sub(digits, 11, 14) end
function C.generateExpiration()
local nowMonth = tonumber(os.date("%m"))
local nowYear = tonumber(os.date("%y"))
local total = (nowYear*12 + nowMonth) + math.random(24, 48)
local year = math.floor(total/12)
local month = total%12
if (month == 0) then month = 12; year = year-1 end
local m = tostring(month)
if (string.len(m) == 1) then m = "0"..m end
local y = year%100
local ys = tostring(y)
if (string.len(ys) == 1) then ys = "0"..ys end
return m.."/"..ys end
function C.generateCVC()
local length = math.random(4, 8)
local cvc = ""
for i=1, length do cvc = cvc..tostring(math.random(10)-1) end
return cvc end
return C
