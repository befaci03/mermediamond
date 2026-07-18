-- Bank API V4

local backgroundColor = colors.gray
local buttonShadowColor = colors.brown
local buttonTextColor = colors.black
local grayedOutColor = colors.lightGray
local specialTextColor = colors.yellow

local buttonColor = colors.yellow
local secondaryButtonColor = colors.orange

local acceptButtonColor = colors.lime
local acceptSecondaryColor = colors.green

local cancelButtonColor = colors.red
local cancelSecondaryColor = colors.brown

local bankServerID = 0
local readingPosX = 0
local readingPosY = 0
local readingString = ""
local reading = false
local readingMax = 10

local function contrastColor(color)
    if (color == colors.white) then return colors.black end
    if (color == colors.orange) then return colors.black end
    if (color == colors.magenta) then return colors.black end
    if (color == colors.lightBlue) then return colors.black end
    if (color == colors.yellow) then return colors.black end
    if (color == colors.lime) then return colors.black end
    if (color == colors.pink) then return colors.black end
    if (color == colors.gray) then return colors.black end
    if (color == colors.lightGray) then return colors.black end
    if (color == colors.cyan) then return colors.white end
    if (color == colors.purple) then return colors.white end
    if (color == colors.blue) then return colors.white end
    if (color == colors.brown) then return colors.white end
    if (color == colors.green) then return colors.black end
    if (color == colors.red) then return colors.black end
    if (color == colors.black) then return colors.white end
    return colors.black
end

local serverData = nil
local lang = "en"
local localization = {
    en={
        back = "Back",
        continue = "Continue",
        sender = "Sender",
        recipient = "Recipient",
        amount = "Amount",
        resulting_balance = "Resulting balance",
        date_and_time = "Date and time",
        description = "Description",
        no_description = "No description",
        click_to_expand = "Click entry for more info",
        balance = "Balance",
        name = "Name",
        key = "Key",
        deleted = "<deleted>",
        accept = "Accept",
        cancel = "Cancel",
        input_text = "Input text",
        max_length = "Max length",
        input_number = "Input number",
        max = "Max",
        product = "Product",
        quantity = "Quantity",
        price = "Price",
        item_name = "Item",
        invalid_value = "Invalid value",
        no_accounts = "There are no accounts at the moment"
    },
    es={
        back = "Volver",
        continue = "Continuar",
        sender = "Remitente",
        recipient = "Destinatario",
        amount = "Monto",
        resulting_balance = "Balance resultante",
        date_and_time = "Fecha y hora",
        description = "Descripcion",
        no_description = "Sin descripcion",
        click_to_expand = "Toca una para mas info",
        balance = "Balance",
        name = "Nombre",
        key = "Clave",
        deleted = "<borrada>",
        accept = "Aceptar",
        cancel = "Cancelar",
        input_text = "Ingresa un texto",
        max_length = "largo maximo",
        input_number = "Ingresa un numero",
        max = "Maximo",
        product = "Producto",
        quantity = "Cantidad",
        price = "Precio",
        item_name = "Articulo",
        invalid_value = "Valor invalido",
        no_accounts = "No hay cuentas por el momento"
    },
    de={
        back = "Zurueck",
        continue = "Weiter",
        sender = "Sender",
        recipient = "Empfaenger",
        amount = "Betrag",
        resulting_balance = "Verbleibender Kontostandt",
        date_and_time = "Datum und Zeit",
        description = "Beschreibung",
        no_description = "Keine Beschreibung",
        click_to_expand = "Klicke führ mehr Infos",
        balance = "Kontostandt",
        name = "Name",
        key = "Schluessel",
        deleted = "<geloescht>",
        accept = "Aktzeptieren",
        cancel = "Abbrechen",
        input_text = "Eingabe Text",
        max_length = "Maximale Laenge",
        input_number = "Zahl eingeben",
        max = "Max",
        product = "Produkt",
        quantity = "Anzahl",
        price = "Preis",
        item_name = "Artikel",
        invalid_value = "Ungültiger Wert",
        no_accounts = "Es gibt im Moment keine Konten"
    }
}

function getServerData()
    print("Connecting to server...")
    local message = {
        action = "getServerData"
    }
    while (true) do
        rednet.broadcast(message, "mermegold")
        local sender, message = rednet.receive("mermegold", 3)
        if (message ~= nil and os.computerID() ~= sender and message.response ~= nil) then
            bankServerID = sender
            print("Successfully connected to server [#"..sender.."]")
            lang = message.response.lang
            serverData = message.response
            return message.response
        end
    end
end

function getClientData()
    local message = {
        action = "getClientData"
    }
    while(true) do
        rednet.send(bankServerID, message, "mermegold")
        local sender, message = rednet.receive("mermegold", 3)
        if (message ~= nil and os.computerID() ~= sender and message.response ~= nil) then
            return message.response
        end
    end
end

local function drawBox(background, foreground, x, y, w, h)
    term.setBackgroundColor(background)
    term.setTextColor(foreground)
    -- Top
    term.setCursorPos(x, y)
    term.write(string.char(151))
    term.write(string.rep(string.char(131), w-2))
    term.setBackgroundColor(foreground)
    term.setTextColor(background)
    term.write(string.char(148))
    -- Left
    term.setBackgroundColor(background)
    term.setTextColor(foreground)
    for i=y+1, y+h-2 do
        term.setCursorPos(x, i)
        term.write(string.char(149))
    end
    -- Right
    term.setBackgroundColor(foreground)
    term.setTextColor(background)
    for i=y+1, y+h-2 do
        term.setCursorPos(x+w-1, i)
        term.write(string.char(149))
    end
    -- Bottom
    term.setCursorPos(x, y+h-1)
    term.write(string.char(138))
    term.write(string.rep(string.char(143), w-2))
    term.setBackgroundColor(foreground)
    term.setTextColor(background)
    term.write(string.char(133))
end

local function drawBackground()
    local scrW, scrH = term.getSize()
    term.setBackgroundColor(backgroundColor)
    term.clear()
end

function drawButton(primary, secondary, textColor, x, y, w, text)
    local ch = string.char(127)
    term.setCursorPos(x, y)
    term.setBackgroundColor(secondary)
    term.setTextColor(primary)
    term.write(" ")
    term.write(ch)
    term.setBackgroundColor(primary)
    term.setTextColor(secondary)
    term.write(ch)
    term.setBackgroundColor(primary)
    term.write(string.rep(" ", w-6))
    term.setBackgroundColor(primary)
    term.setTextColor(secondary)
    term.write(ch)
    term.setBackgroundColor(secondary)
    term.setTextColor(primary)
    term.write(ch)
    term.write(" ")

    -- Shadow
    term.setBackgroundColor(backgroundColor)
    term.setTextColor(colors.black)
    term.write(string.char(148))
    local scrW, scrH = term.getSize()
    if (y < scrH) then
        term.setCursorPos(x, y+1)
        term.write(string.char(130))
        term.write(string.rep(string.char(131), w-1))
        term.write(string.char(129))
    end

    term.setBackgroundColor(primary)
    term.setTextColor(textColor)

    term.setCursorPos(x+w/2-string.len(text)/2, y)
    term.write(text)

    return {x=x, y=y, w=w}
end

function mouseInButton(button, mousex, mousey)
    return (mousex >= button.x and mousex <= button.x+button.w and button.y == mousey)
end

function drawBackButton()
    local scrW, scrH = term.getSize()
    local text = localization[lang].back
    local x = 2
    local y = scrH-1

    local ch = string.char(127)

    local width = string.len(text)

    return drawButton(cancelButtonColor, cancelSecondaryColor, buttonTextColor, x, y, width+6, text)
end

function drawContinueButton()
    local scrW, scrH = term.getSize()
    local text = localization[lang].continue
    local x = 2
    local y = scrH-1

    local ch = string.char(127)

    local width = string.len(text)

    return drawButton(acceptButtonColor, acceptSecondaryColor, buttonTextColor, scrW-width-7, y, width+6, text)
end

function drawAcceptButton()
    local scrW, scrH = term.getSize()
    local text = localization[lang].accept
    local x = 2
    local y = scrH-1

    local ch = string.char(127)

    local width = string.len(text)

    return drawButton(acceptButtonColor, acceptSecondaryColor, buttonTextColor, scrW-width-7, y, width+6, text)
end

function transaction(from, to, amount, description)
    --local success, response = transaction(from, to, amount, description)
    local message = {
        action = "transaction",
        from = from,
        to = to,
        amount = amount,
        description = description
    }
    rednet.send(bankServerID, message, "mermegold")
    local sender, message = rednet.receive("mermegold")
    return message.success, message.response
end

function deposit(key, amount)
    local message = {
        action = "deposit",
        key = key,
        amount = amount
    }
    rednet.send(bankServerID, message, "mermegold")
    local sender, message = rednet.receive("mermegold")
    return message.success, message.response
end

function withdraw(key, amount)
    local message = {
        action = "withdraw",
        key = key,
        amount = amount
    }
    rednet.send(bankServerID, message, "mermegold")
    local sender, message = rednet.receive("mermegold")
    return message.success, message.response
end

function newAccount(name, balance, color)
    local message = {
        action = "new",
        name = name,
        balance = balance,
        color = color
    }
    rednet.send(bankServerID, message, "mermegold")
    local sender, message = rednet.receive("mermegold")
    return message.success, message.response
end

function deleteAccount(key)
    local message = {
        action = "delete",
        key = key
    }
    rednet.send(bankServerID, message, "mermegold")
    local sender, message = rednet.receive("mermegold")
    return message.success, message.response
end

function getTransactionLog(key)
    local message = {
        action = "getTransactionLog",
        key = key
    }
    rednet.send(bankServerID, message, "mermegold")
    local sender, message = rednet.receive("mermegold")
    if (sender == nil) then
        print(text_error_noconnection)
    end
    return message.response
end

function transactionInfoScreen(log)
    local tempClientData = getClientData()

    drawBackground()
    term.setCursorPos(1,2)
    term.setTextColor(colors.white)
    local amountText
    if (tonumber(log.amount) > 0) then
        print(localization[lang].sender..": "..tempClientData[log.other].name)
        term.write(localization[lang].amount..": ")
        amountText = "+$"..log.amount
        term.setTextColor(colors.green)
    end
    if (tonumber(log.amount) < 0) then
        print(localization[lang].recipient..": "..tempClientData[log.other].name)
        term.write(localization[lang].amount..": ")
        amountText = "-$"..math.abs(log.amount)
        term.setTextColor(colors.red)
    end
    print(amountText)
    term.setTextColor(colors.white)
    print(localization[lang].resulting_balance..": $"..log.balance)
    print(localization[lang].date_and_time..": "..log.time)
    if (string.len(log.description) > 0) then
        print(localization[lang].description..":")
        term.setTextColor(specialTextColor)
        print(log.description)
    else
        term.setTextColor(grayedOutColor)
        print(localization[lang].no_description)
    end

    drawBackButton()
    os.pullEvent("mouse_click")
end

function transactionLogScreen(key)
    local tempClientData = getClientData()
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
        drawBackground()

        local prevPage = drawButton(buttonColor, secondaryButtonColor, buttonTextColor,scrollButtonCenterX-13, scrollButtonY, 7, string.char(27))
        if (first <= 0) then
            drawButton(colors.lightGray, colors.gray, colors.gray, scrollButtonCenterX-13, scrollButtonY, 7, string.char(27))
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

                local text = "#"..order.." "..v.description
                
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
                    name = localization[lang].deleted
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

        local nextPage = drawButton(buttonColor, secondaryButtonColor, buttonTextColor, scrollButtonCenterX+5, scrollButtonY, 7, string.char(26))
        if (first+max >= totalLogs) then
            drawButton(colors.lightGray, colors.gray, colors.gray, scrollButtonCenterX+5, scrollButtonY, 7, string.char(26))
        end

        -- page indicator
        local pages = math.ceil(totalLogs/max)
        local pageText = tostring((first/max)+1).."/"..pages
        term.setCursorPos(scrollButtonCenterX-string.len(pageText)/2, scrollButtonY)
        term.setBackgroundColor(backgroundColor)
        term.setTextColor(colors.orange)
        term.write(pageText)

        local backButton = drawBackButton()

        term.setCursorPos(scrW/2-string.len(localization[lang].click_to_expand)/2+1, 1)

        term.setBackgroundColor(backgroundColor)
        term.setTextColor(grayedOutColor)
        term.write(localization[lang].click_to_expand)
        
        --local event, button, cx, cy = os.pullEvent("mouse_click")

        local eventData = {os.pullEvent()}
        local event = eventData[1]

        if event == "mouse_click" then
            local cx = eventData[3]
            local cy = eventData[4]
            if (mouseInButton(prevPage, cx, cy)) then
                if (first > 0) then
                    first = first-max
                end
            end
            if (mouseInButton(nextPage, cx, cy)) then
                if (first+max < totalLogs) then
                    first = first+max
                end
            end
            if (cx >= x and cx <= x+w and cy >= y) then
                if buttons[cy] ~= nil then
                    transactionInfoScreen(logs[buttons[cy]])
                end
            end
            if (mouseInButton(backButton, cx, cy)) then
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

function optionMenu(title, options, spacing, width)
    if (spacing == nil) then spacing = 2 end
    if (width == nil) then width = 30 end
    drawBackground()
    local buttons = {}
    local scrW, scrH = term.getSize()
    local w = width
    local x = scrW/2-w/2+1
    local y = math.floor(scrH/2-(#options+1)*spacing/2)+2
    local i = 0
    term.setCursorPos(scrW/2-string.len(title)/2+1, y+i)
    term.setTextColor(specialTextColor)
    term.write(title)
    i = i+spacing

    term.setBackgroundColor(buttonColor)
    term.setTextColor(buttonTextColor)
    for k, v in ipairs(options) do
        drawButton(buttonColor, secondaryButtonColor, buttonTextColor, x, y+i, w, v.text)
        
        buttons[y+i] = v.option
        i = i+spacing
    end

    while true do
        local event, button, cx, cy = os.pullEvent("mouse_click")
        if (cx >= x-1 and cx <= x+width-1 and cy >= y and cy < y+(#options+1)*spacing) then
            if buttons[cy] ~= nil then
                return buttons[cy]
            end
        end
    end
end

local function drawSteps(steps, currentStep)
    term.setCursorPos(1, 2)
    drawBackground()
    local stepCount = #steps
    if (stepCount == 1) then
        term.setTextColor(specialTextColor)
        print(steps[1])
    else
        for k, v in ipairs(steps) do
            term.setTextColor(grayedOutColor)
            if (k == currentStep) then
                term.setTextColor(specialTextColor)
                term.write(string.char(16).." "..k..". ")
            else
                term.write(" "..k..". ")
            end
            print(v)
        end
    end
end

local function startRead(maxLength)
    local scrW, scrH = term.getSize()
    readingPosX, readingPosY = term.getCursorPos()
    reading = true
    readingString = ""
    readingMax = maxLength
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(readingPosX, readingPosY)
    term.write(string.rep(" ", scrW-2))
    term.setCursorBlink(true)
end

local function processChar(char)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(readingPosX, readingPosY)
    readingString = readingString..char
    term.write(readingString)
end

local function processKey(key)
    if (key == keys.backspace) then
        readingString = string.sub(readingString, 1, string.len(readingString)-1)
        term.setBackgroundColor(colors.white)
        term.setCursorPos(readingPosX+string.len(readingString), readingPosY)
        term.write(" ")
        term.setCursorPos(readingPosX+string.len(readingString), readingPosY)
    elseif (key == keys.enter) then
        term.setCursorBlink(false)
        return readingString
    end
    return nil
end

local function cancelableRead(maxLength, secondaryButtonX)
    startRead(maxLength)
    local back = drawBackButton()
    local accept = drawAcceptButton()
    term.setCursorPos(readingPosX, readingPosY)
    local input = nil
    while input == nil do
        local event, a, b, c = os.pullEvent()
        if (event == "char") then
            processChar(a)
        elseif (event == "key") then
            input = processKey(a)
        elseif (event == "mouse_click") then
            local cx = b
            local cy = c
            if (mouseInButton(back, cx, cy)) then
                term.setCursorBlink(false)
                return nil
            elseif (mouseInButton(accept, cx, cy)) then
                term.setCursorBlink(false)
                input = readingString
                break
            elseif (secondaryButtonX ~= nil) then
                if (cy == back.y and cx >= secondaryButtonX) then
                    return true
                end
            end
        end
    end
    term.setCursorBlink(false)
    if (readingMax > 0 and string.len(input) > readingMax) then
        input = string.sub(input, 1, readingMax)
    end
    return input
end

function showBalance(key)
    local tempClientData = getClientData()
    drawBackground()
    local scrW, scrH = term.getSize()
    
    local text = localization[lang].balance..":"
    term.setTextColor(specialTextColor)
    term.setCursorPos(scrW/2-string.len(text)/2+2,scrH/2-3)
    term.write(text)
    local itemMax = math.floor(tempClientData[key].balance/serverData.valueMultiplier)

    text = "$"..tempClientData[key].balance
    drawBox(backgroundColor, colors.lightGray, 4, scrH/2-1, scrW-6, 5)
    term.setCursorPos(scrW/2-string.len(text)/2+1,scrH/2)
    term.setBackgroundColor(backgroundColor)
    term.setTextColor(specialTextColor)
    term.write(text)

    text = itemMax.." "..serverData.currency[1].plural[lang]
    term.setCursorPos(scrW/2-string.len(text)/2+1,scrH/2+2)
    term.write(text)

    drawBackButton()

    while true do
        local event = os.pullEvent()
        if (event == "mouse_click" or event == "key") then
            break
        end
    end
end

function selectAccountScreen(steps, currentStep, disabledAccount, overrideClientData)
    local tempClientData
    
    if (overrideClientData == nil) then
        tempClientData = getClientData()
    else
        tempClientData = overrideClientData
    end

    local clientCount = 0
    for k, v in pairs(tempClientData) do
        clientCount = clientCount+1
    end

    if (clientCount == 0) then
        errorScreen(localization[lang].no_accounts)
        return nil
    end
    
    local scrW, scrH = term.getSize()
    local x, y, w, h = scrW/4, #steps+4, scrW/2+2, scrH-5

    local back = drawBackButton()

    local first = 0
    local max = scrH-y-2

    local upButtonY = y-2
    local downButtonY = y+1+max

    while true do
        drawSteps(steps, currentStep)
        drawBackButton()
        local i = 0
        local buttons = {}

        if (first > 0) then
            term.setCursorPos(scrW/2-3,upButtonY)
            term.setTextColor(buttonTextColor)
            term.setBackgroundColor(buttonColor)
            term.write("  "..string.char(24).."  ")
        end

        local totalAccounts = 0
        local showAccounts = 0
        for k, v in pairs(tempClientData) do
            if (disabledAccount ~= nil and disabledAccount ~= k) then
                if (totalAccounts >= first and showAccounts < first+max) then
                    buttons[y+i] = k
                    term.setCursorPos(x,y+i)
                    term.setTextColor(contrastColor(tonumber(v.color)))
                    term.setBackgroundColor(tonumber(v.color))
                    term.write(string.rep(" ", w))
                    term.setCursorPos(x+w/2-string.len(v.name)/2-1,y+i)
                    term.write(v.name)
                    i = i+1
                end
                showAccounts = showAccounts+1
            end
            totalAccounts = totalAccounts+1
        end

        if (first+max < showAccounts) then
            term.setCursorPos(scrW/2-3,downButtonY)
            term.setTextColor(buttonTextColor)
            term.setBackgroundColor(buttonColor)
            term.write("  "..string.char(25).."  ")
        end

        local event, button, cx, cy = os.pullEvent("mouse_click")
        if (cx >= scrW/2-3 and cx < scrW/2+3 and cy == upButtonY) then
            if (first > 0) then
                first = first-max
            end
        end
        if (cx >= scrW/2-3 and cx < scrW/2+3 and cy == downButtonY) then
            if (first+max < showAccounts) then
                first = first+max
            end
        end
        if (cx >= x and cx <= x+w and cy >= y and cy < y+i) then
            return buttons[cy]
        end
        if (mouseInButton(back, cx, cy)) then
            return nil
        end
    end
end

function inputNumberScreen(steps, currentStep, max, maxString)
    if (max == nil) then max = 0 end
    local y = #steps+3
    while true do
        drawSteps(steps, currentStep)

        term.setCursorPos(1, y)
        term.setBackgroundColor(backgroundColor)
        term.setTextColor(specialTextColor)
        local text = localization[lang].input_number
        if (maxString ~= nil and maxString ~= "") then
            text = text.." ("..localization[lang].max.." "..maxString..")"
        elseif (max ~= nil and max ~= 0) then
            text = text.." ("..localization[lang].max.." $"..max..")"
        end
        text = text..":"
        print(text)
        local scrW, scrH = term.getSize()

        term.setCursorPos(2, y+2)
    
        local result = cancelableRead(max)

        if (result == nil) then
            return nil
        end

        local numberResult = tonumber(result)
        if (numberResult == nil or numberResult <= 0 or numberResult%1 ~= 0) then
            errorScreen(localization[lang].invalid_value)
        else
            return result
        end
    end
end

function inputTextScreen(steps, currentStep, maxLength)
    if (maxLength == nil) then maxLength = 0 end
    drawSteps(steps, currentStep)
    local y = #steps+3
    term.setCursorPos(1, y)
    term.setBackgroundColor(backgroundColor)
    term.setTextColor(specialTextColor)
    local text = localization[lang].input_text
    if (maxLength ~= nil and maxLength ~= 0) then
        text = text.." ("..localization[lang].max_length.." "..maxLength..")"
    end
    text = text..":"
    print(text)
    local scrW, scrH = term.getSize()
    term.setCursorPos(2, y+2)
    return cancelableRead(maxLength)
end

function selectColorScreen(steps, currentStep)
    drawSteps(steps, currentStep)
    local y = #steps+3
    local color = 1
    local buttons = {}
    local scrW, scrH = term.getSize()
    local x = scrW/2-10
    local w = 5 --button width
    for _x=0, 3 do
        buttons[_x] = {}
        for _y= 0, 3 do
            term.setCursorPos(x+_x*w+1, y+_y)
            term.setBackgroundColor(color)
            term.setTextColor(contrastColor(color))
            term.write("[")
            term.write(string.rep(" ", w-2))
            term.write("]")
            buttons[_x][_y] = color
            color = color*2
        end
    end

    local backx, backy, backw = drawBackButton()

    while true do
        local event, button, cx, cy = os.pullEvent("mouse_click")
        if (cx >= x and cx <= x+w*4 and cy >= y and cy < y+4) then
            local _x = math.floor((cx-x)/w)
            local _y = math.floor((cy-y))
            return buttons[_x][_y]
        end
        if (cx >= backx and cx <= backx+backw and cy == backy) then
            return nil
        end
    end
end

function responseScreen(success, response)
    if (success) then
        successScreen(response)
    else
        errorScreen(response)
    end
end

function errorScreen(message)
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorBlink(false)
    term.setBackgroundColor(colors.black)
    local scrW, scrH = term.getSize()
    term.setBackgroundColor(colors.red)
    if (type(message) == 'table') then
        for k, v in pairs(message) do
            term.setCursorPos(scrW/2-string.len(v)/2+1, scrH/2-math.ceil(#message/2)+k)
            term.write(v)
        end
        sleep(1.5 * #message)
    else
        term.setCursorPos(scrW/2-string.len(message)/2+1, scrH/2)
        term.write(message)
        sleep(1.5)
    end
end

function successScreen(message)
    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorBlink(false)
    local scrW, scrH = term.getSize()
    if (type(message) == 'table') then
        for k, v in pairs(message) do
            term.setCursorPos(scrW/2-string.len(v)/2+1, scrH/2-math.ceil(#message/2)+k)
            term.write(v)
        end
        sleep(1.5 * #message)
    else
        term.setCursorPos(scrW/2-string.len(message)/2+1, scrH/2)
        term.write(message)
        sleep(1.5)
    end
end

function waitScreen(message)
    drawBackground()
    term.setTextColor(colors.white)
    local scrW, scrH = term.getSize()
    if (type(message) == 'table') then
        for k, v in pairs(message) do
            term.setCursorPos(scrW/2-string.len(v)/2+1, scrH/2-math.ceil(#message/2)+k)
            term.write(v)
        end
    else
        term.setCursorPos(scrW/2-string.len(message)/2+1, scrH/2)
        term.write(message)
    end
end

function confirmScreen(message, data, steps, currentStep)
    local y = 2
    drawBackground()
    if (steps ~= nil) then
        drawSteps(steps, currentStep)
        y = #steps+3
    end
    local scrW, scrH = term.getSize()
    term.setTextColor(specialTextColor)
    for k, v in pairs(message) do
        term.setCursorPos((scrW-string.len(v))/2, y)
        term.write(v)
        y = y+1
    end
    y = y+1
    if (data ~= nil) then
        for k, v in pairs(data) do
            local text = localization[lang][k]..": "..v
            term.setCursorPos((scrW-string.len(text))/2, y)
            term.write(text)
            y = y+1
        end
        y = y+1
    end

    local buttonY = math.min(scrH-3, y)
    local buttonW = 20
    local buttonX = scrW/2-buttonW/2

    local acceptButton = drawButton(acceptButtonColor, acceptSecondaryColor, buttonTextColor, buttonX, buttonY, buttonW, localization[lang].accept)

    local cancelButton = drawButton(cancelButtonColor, cancelSecondaryColor, buttonTextColor, buttonX, buttonY+2, buttonW, localization[lang].cancel)

    while true do
        local event, button, cx, cy = os.pullEvent("mouse_click")
        if (mouseInButton(acceptButton, cx, cy)) then
            return true
        end
        if (mouseInButton(cancelButton, cx, cy)) then
            return false
        end
    end
end

function textScreen(message)
    local y = 1
    local scrW, scrH = term.getSize()
    drawBackground()
    term.setTextColor(colors.white)
    for k, v in pairs(message) do
        term.setCursorPos((scrW-string.len(v))/2+1, y)
        term.write(v)
        y = y+1
    end

    drawBackButton()
    
    os.pullEvent("mouse_click")
end
