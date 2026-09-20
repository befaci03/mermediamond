-- Bank API V4 (umbrella)
-- The API is split into focused modules:
--   lib/uilib.lua  -> terminal UI (theme, drawing, menus, inputs, screens)
--   lib/net.lua    -> rednet protocol with the bank server + update bridge
--   lib/cards.lua  -> paper card system (encode/decode, print, validators)
-- This file loads them and re-exports everything under the classic
-- bankapi.* names, so existing programs keep working unchanged.
-- The server keeps this file at lib/bankapi.lua and loads it with
-- os.loadAPI("lib/bankapi.lua") before os.loadAPI resolves the modules.

-- Load the translation helper (tk) if it isn't loaded yet
if (tk == nil) then
    if (fs.exists("lang/languages.lua")) then
        os.loadAPI("lang/languages.lua")
    elseif (fs.exists("../lang/languages.lua")) then
        os.loadAPI("../lang/languages.lua")
    elseif (fs.exists("disk/lang/languages.lua")) then
        os.loadAPI("disk/lang/languages.lua")
    end
end

-- Load the updater API if it isn't loaded yet
if (updateAvailable == nil) then
    if (fs.exists("updater.lua")) then
        os.loadAPI("updater.lua")
    elseif (fs.exists("../updater.lua")) then
        os.loadAPI("../updater.lua")
    end
end

-------------------- Load the modules --------------------
-- Resolve module paths relative to this file (root-installed machines
-- load bankapi.lua from lib/, phones from disk/lib/, etc.)
local function findModule(name)
    local candidates = { "lib/"..name, name, "disk/lib/"..name, "../lib/"..name }
    for _, path in ipairs(candidates) do
        if (fs.exists(path)) then return path end
    end
    return "lib/"..name
end

local uilibPath = findModule("uilib.lua")
local netPath = findModule("net.lua")

if (uilib == nil) then
    os.loadAPI(uilibPath) -- exposes the global `uilib`
end
if (net == nil) then
    os.loadAPI(netPath) -- exposes the global `net`
end
if (uilib == nil) then error("uilib module failed to load from "..uilibPath) end

-- Cards depend on the UI module
if (cards == nil) then
    os.loadAPI(findModule("cards.lua")) -- exposes the global `cards`
end

-------------------- Re-exports under classic bankapi.* names --------------------

-- Expose the sub-modules on the bankapi table too
uilib = uilib
net = net
cards = cards

-- UI
drawBox = uilib.drawBox
drawBackground = uilib.drawBackground
drawButton = uilib.drawButton
mouseInButton = uilib.mouseInButton
drawBackButton = uilib.drawBackButton
drawContinueButton = uilib.drawContinueButton
drawAcceptButton = uilib.drawAcceptButton
optionMenu = uilib.optionMenu
selectAccountScreen = uilib.selectAccountScreen
inputNumberScreen = uilib.inputNumberScreen
inputTextScreen = uilib.inputTextScreen
selectColorScreen = uilib.selectColorScreen
responseScreen = uilib.responseScreen
errorScreen = uilib.errorScreen
successScreen = uilib.successScreen
waitScreen = uilib.waitScreen
confirmScreen = uilib.confirmScreen
textScreen = uilib.textScreen
cancelableRead = uilib.cancelableRead

-- Network
getServerData = net.getServerData
getClientData = net.getClientData
getTransactionLog = net.getTransactionLog
transaction = net.transaction
deposit = net.deposit
withdraw = net.withdraw
newAccount = net.newAccount
deleteAccount = net.deleteAccount
cardLogin = net.cardLogin
assignCard = net.assignCard
autoUpdate = net.autoUpdate

-- Cards
readPrintedCard = cards.readPrintedCard
encodeCardLine = cards.encodeCardLine
decodeCardLine = cards.decodeCardLine
cardPaperLines = cards.cardPaperLines
printCard = cards.printCard
validCardId = cards.validCardId
validExpiration = cards.validExpiration
cardExpired = cards.cardExpired
validCVC = cards.validCVC
generateCardId = cards.generateCardId
generateExpiration = cards.generateExpiration
generateCVC = cards.generateCVC

-------------------- Screens that mix UI + network --------------------

function showBalance(key)
    local tempClientData = getClientData() -- cached; one round-trip at most
    uilib.drawBackground()
    local scrW, scrH = term.getSize()

    local text = tk("api.balance")..":"
    term.setTextColor(uilib.specialTextColor)
    term.setCursorPos(scrW/2-string.len(text)/2+2,scrH/2-3)
    term.write(text)
    local itemMax = math.floor(tempClientData[key].balance/net.serverData.valueMultiplier)

    text = "$"..tempClientData[key].balance
    uilib.drawBox(uilib.backgroundColor, colors.lightGray, 4, scrH/2-1, scrW-6, 5)
    term.setCursorPos(scrW/2-string.len(text)/2+1,scrH/2)
    term.setBackgroundColor(uilib.backgroundColor)
    term.setTextColor(uilib.specialTextColor)
    term.write(text)

    text = itemMax.." "..net.serverData.currency[1].plural[string.sub(net.lang,1,2)]
    term.setCursorPos(scrW/2-string.len(text)/2+1,scrH/2+2)
    term.write(text)

    uilib.drawBackButton()

    while true do
        local event = os.pullEvent()
        if (event == "mouse_click" or event == "key") then
            break
        end
    end
end

function transactionInfoScreen(log)
    local tempClientData = getClientData()

    uilib.drawBackground()
    term.setCursorPos(1,2)
    term.setTextColor(colors.white)
    local amountText
    if (tonumber(log.amount) > 0) then
        print(tk("api.sender")..": "..tempClientData[log.other].name)
        term.write(tk("api.amount")..": ")
        amountText = "+$"..log.amount
        term.setTextColor(colors.green)
    end
    if (tonumber(log.amount) < 0) then
        print(tk("api.recipient")..": "..tempClientData[log.other].name)
        term.write(tk("api.amount")..": ")
        amountText = "-$"..math.abs(log.amount)
        term.setTextColor(colors.red)
    end
    print(amountText)
    term.setTextColor(colors.white)
    print(tk("api.resulting_balance")..": $"..log.balance)
    print(tk("api.date_and_time")..": "..log.time)
    if (string.len(log.description) > 0) then
        print(tk("api.description")..":")
        term.setTextColor(uilib.specialTextColor)
        print(log.description)
    else
        term.setTextColor(uilib.grayedOutColor)
        print(tk("api.no_description"))
    end

    uilib.drawBackButton()
    os.pullEvent("mouse_click")
end

function transactionLogScreen(key)
    local tempClientData = getClientData() -- cached; one round-trip at most
    local backwardsLogs = getTransactionLog(key)
    local logs = {}

    local logCount = #backwardsLogs
    for i=0, logCount do
        logs[logCount-i] = backwardsLogs[i+1] -- Newest first
    end

    local scrW, scrH = term.getSize()
    local y = 2
    local floor = 1
    local x = 1
    local w = scrW

    if (pocket) then
        floor = 2
    end

    local first = 0
    local logHeight = 2
    local max = math.floor((scrH-floor-logHeight)/logHeight)

    local scrollButtonY = scrH-1
    local scrollButtonCenterX = math.floor(scrW/2)+10

    if (pocket) then
        scrollButtonY = scrH-3
        scrollButtonCenterX = math.floor(scrW/2)+1
    end

    while true do
        uilib.drawBackground()

        local prevPage = uilib.drawButton(uilib.buttonColor, uilib.secondaryButtonColor, uilib.buttonTextColor,scrollButtonCenterX-13, scrollButtonY, 7, string.char(27))
        if (first <= 0) then
            uilib.drawButton(colors.lightGray, colors.gray, colors.gray, scrollButtonCenterX-13, scrollButtonY, 7, string.char(27))
        end

        local totalLogs = 0
        local i = 0
        local buttons = {}
        for k, v in ipairs(logs) do
            if (totalLogs >= first and totalLogs < first+max) then
                local order = #logs-k+1
                local amountText
                if (tonumber(v.amount) > 0) then
                    amountText = "+$"..v.amount
                end
                if (tonumber(v.amount) < 0) then
                    amountText = "-$"..math.abs(v.amount)
                end

                -- box
                if (i > 0) then
                    term.setCursorPos(1,y+i-1)
                    term.setBackgroundColor(colors.white)
                    term.setTextColor(colors.lightGray)
                    print(string.rep(string.char(140), scrW))
                    term.setBackgroundColor(colors.white)
                    print(string.rep(" ", scrW))
                else
                    term.setCursorPos(1,y+i)
                    term.setBackgroundColor(colors.white)
                    print(string.rep(" ", scrW))
                end

                -- content
                term.setCursorPos(1,y+i)
                buttons[y+i] = k

                local name
                if (tempClientData[v.other] ~= nil) then
                    name = tempClientData[v.other].name
                else
                    name = tk("api.deleted")
                end

                term.setTextColor(colors.lightGray)
                term.write("#"..order.." ")

                term.setTextColor(colors.black)
                term.write(name.." ")

                term.setCursorPos(scrW*0.3, y+i)
                if (pocket) then
                    term.setCursorPos(scrW*0.5, y+i)
                end
                if (tonumber(v.amount) >= 0) then
                    term.setTextColor(colors.green)
                else
                    term.setTextColor(colors.red)
                end
                term.write(amountText)

                if (pocket == nil) then
                    term.setCursorPos(scrW*0.5, y+i)
                    term.setTextColor(colors.black)
                    term.write(" ($"..v.balance..")")
                end

                term.setTextColor(colors.lightGray)
                local time = v.time
                if (pocket) then
                    time = string.sub(v.time, 1, 5)
                end
                term.setCursorPos(scrW-string.len(time),y+i)
                term.write(" "..time)

                i = i+logHeight
            end
            totalLogs = totalLogs+1
        end

        local nextPage = uilib.drawButton(uilib.buttonColor, uilib.secondaryButtonColor, uilib.buttonTextColor, scrollButtonCenterX+5, scrollButtonY, 7, string.char(26))
        if (first+max >= totalLogs) then
            uilib.drawButton(colors.lightGray, colors.gray, colors.gray, scrollButtonCenterX+5, scrollButtonY, 7, string.char(26))
        end

        -- page indicator
        local pages = math.ceil(totalLogs/max)
        local pageText = tostring((first/max)+1).."/"..pages
        term.setCursorPos(scrollButtonCenterX-string.len(pageText)/2, scrollButtonY)
        term.setBackgroundColor(uilib.backgroundColor)
        term.setTextColor(colors.orange)
        term.write(pageText)

        local backButton = uilib.drawBackButton()

        term.setCursorPos(scrW/2-string.len(tk("api.click_to_expand"))/2+1, 1)

        term.setBackgroundColor(uilib.backgroundColor)
        term.setTextColor(uilib.grayedOutColor)
        term.write(tk("api.click_to_expand"))

        local eventData = {os.pullEvent()}
        local event = eventData[1]

        if event == "mouse_click" then
            local cx = eventData[3]
            local cy = eventData[4]
            if (uilib.mouseInButton(prevPage, cx, cy)) then
                if (first > 0) then
                    first = first-max
                end
            end
            if (uilib.mouseInButton(nextPage, cx, cy)) then
                if (first+max < totalLogs) then
                    first = first+max
                end
            end
            if (cx >= x and cx <= x+w and cy >= y) then
                if buttons[cy] ~= nil then
                    transactionInfoScreen(logs[buttons[cy]])
                end
            end
            if (uilib.mouseInButton(backButton, cx, cy)) then
                return nil
            end
        elseif event == "mouse_scroll" then
            local scroll = eventData[2]
            if (scroll < 0) then
                if (first > 0) then
                    first = first-max
                end
            else
                if (first+max < totalLogs) then
                    first = first+max
                end
            end
        end
    end
end

-------------------- selectAccountScreen wrapper --------------------
-- The UI module expects clientData as a parameter; keep the old
-- bankapi.selectAccountScreen(steps, currentStep, disabled, override) shape.

function selectAccountScreen(steps, currentStep, disabledAccount, overrideClientData)
    local clientData = overrideClientData
    if (clientData == nil) then
        clientData = getClientData()
    end
    return uilib.selectAccountScreen(steps, currentStep, disabledAccount, clientData)
end
