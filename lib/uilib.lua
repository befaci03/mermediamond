-- UI library: theme, drawing primitives, menus, inputs and screens.
-- Split out of bankapi.lua; loaded automatically by lib/bankapi.lua.

local U = {}

-------------------- Theme --------------------
U.backgroundColor = colors.gray
U.buttonShadowColor = colors.brown
U.buttonTextColor = colors.black
U.grayedOutColor = colors.lightGray
U.specialTextColor = colors.lightBlue

U.buttonColor = colors.blue
U.secondaryButtonColor = colors.orange

U.acceptButtonColor = colors.lime
U.acceptSecondaryColor = colors.green

U.cancelButtonColor = colors.red
U.cancelSecondaryColor = colors.brown

-- Text color that reads well on top of `color` (lookup instead of 17 ifs)
local darkText = {
    [colors.white]=true, [colors.orange]=true, [colors.magenta]=true,
    [colors.lightBlue]=true, [colors.yellow]=true, [colors.lime]=true,
    [colors.pink]=true, [colors.gray]=true, [colors.lightGray]=true,
    [colors.green]=true, [colors.red]=true
}
function U.contrastColor(color)
    if (darkText[color]) then return colors.black end
    return colors.white
end

-------------------- Drawing --------------------

function U.drawBox(background, foreground, x, y, w, h)
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
    local sideRows = h-2
    if (sideRows > 0) then
        term.write(string.rep("\n"..string.char(149), sideRows-1))
        term.write("\n")
        term.setCursorPos(x, y+1)
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

function U.drawBackground()
    term.setBackgroundColor(U.backgroundColor)
    term.clear()
end

function U.drawButton(primary, secondary, textColor, x, y, w, text)
    local ch = string.char(127)
    term.setCursorPos(x, y)
    term.setBackgroundColor(secondary)
    term.setTextColor(primary)
    term.write(" ")
    term.write(ch)
    term.setBackgroundColor(primary)
    term.setTextColor(secondary)
    term.write(ch)
    term.write(string.rep(" ", w-6))
    term.write(ch)
    term.setBackgroundColor(secondary)
    term.setTextColor(primary)
    term.write(ch)
    term.write(" ")

    -- Shadow
    term.setBackgroundColor(U.backgroundColor)
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

function U.mouseInButton(button, mousex, mousey)
    return (mousex >= button.x and mousex <= button.x+button.w and button.y == mousey)
end

-- Shared factory for the left/right labelled action buttons
local function sideButton(textKey, primary, secondary, side)
    local scrW, scrH = term.getSize()
    local text = tk(textKey)
    local width = string.len(text)
    local x = (side == "left") and 2 or (scrW-width-7)
    return U.drawButton(primary, secondary, U.buttonTextColor, x, scrH-1, width+6, text)
end

function U.drawBackButton()
    return sideButton("api.back", U.cancelButtonColor, U.cancelSecondaryColor, "left")
end

function U.drawContinueButton()
    return sideButton("api.continue", U.acceptButtonColor, U.acceptSecondaryColor, "right")
end

function U.drawAcceptButton()
    return sideButton("api.accept", U.acceptButtonColor, U.acceptSecondaryColor, "right")
end

function U.optionMenu(title, options, spacing, width)
    if (spacing == nil) then spacing = 2 end
    if (width == nil) then width = 30 end
    -- Shrink spacing so long menus still fit on screen
    local scrW, scrH = term.getSize()
    while (spacing > 1 and (#options+1)*spacing+3 > scrH) do
        spacing = spacing-1
    end
    U.drawBackground()
    local buttons = {}
    local w = width
    local x = scrW/2-w/2+1
    local y = math.floor(scrH/2-(#options+1)*spacing/2)+2
    local i = 0
    term.setCursorPos(scrW/2-string.len(title)/2+1, y+i)
    term.setTextColor(U.specialTextColor)
    term.write(title)
    i = i+spacing

    for k, v in ipairs(options) do
        U.drawButton(U.buttonColor, U.secondaryButtonColor, U.buttonTextColor, x, y+i, w, v.text)

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

-------------------- Text input --------------------

local readingPosX = 0
local readingPosY = 0
local readingString = ""
local readingMax = 10
local readingMask = false

local function drawSteps(steps, currentStep)
    term.setCursorPos(1, 2)
    U.drawBackground()
    local stepCount = #steps
    if (stepCount == 1) then
        term.setTextColor(U.specialTextColor)
        print(steps[1])
    else
        for k, v in ipairs(steps) do
            term.setTextColor(U.grayedOutColor)
            if (k == currentStep) then
                term.setTextColor(U.specialTextColor)
                term.write(string.char(16).." "..k..". ")
            else
                term.write(" "..k..". ")
            end
            print(v)
        end
    end
end
U.drawSteps = drawSteps

local function startRead(maxLength, mask)
    local scrW, scrH = term.getSize()
    readingPosX, readingPosY = term.getCursorPos()
    readingString = ""
    readingMax = maxLength
    readingMask = mask
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
    if (readingMask ~= nil) then
        term.write(string.rep(readingMask, string.len(readingString)))
    else
        term.write(readingString)
    end
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

-- Also used by the cards module (typed machine-line entry)
function U.cancelableRead(maxLength, secondaryButtonX, mask)
    startRead(maxLength, mask)
    local back = U.drawBackButton()
    local accept = U.drawAcceptButton()
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
            if (U.mouseInButton(back, cx, cy)) then
                term.setCursorBlink(false)
                return nil
            elseif (U.mouseInButton(accept, cx, cy)) then
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

-------------------- Screens --------------------

-- Selection list. clientData must be passed in (the bankapi umbrella
-- fetches it) so this module stays independent of the network layer.
function U.selectAccountScreen(steps, currentStep, disabledAccount, clientData)
    local tempClientData = clientData

    local clientCount = 0
    for k, v in pairs(tempClientData) do
        clientCount = clientCount+1
    end

    if (clientCount == 0) then
        U.errorScreen(tk("api.no_accounts"))
        return nil
    end

    local scrW, scrH = term.getSize()
    local x, y, w, h = scrW/4, #steps+4, scrW/2+2, scrH-5

    local first = 0
    local max = scrH-y-2

    local upButtonY = y-2
    local downButtonY = y+1+max

    while true do
        drawSteps(steps, currentStep)
        local back = U.drawBackButton()
        local i = 0
        local buttons = {}

        if (first > 0) then
            term.setCursorPos(scrW/2-3,upButtonY)
            term.setTextColor(U.buttonTextColor)
            term.setBackgroundColor(U.buttonColor)
            term.write("  "..string.char(24).."  ")
        end

        local totalAccounts = 0
        local showAccounts = 0
        for k, v in pairs(tempClientData) do
            if (disabledAccount ~= nil and disabledAccount ~= k) then
                if (totalAccounts >= first and showAccounts < first+max) then
                    buttons[y+i] = k
                    term.setCursorPos(x,y+i)
                    term.setTextColor(U.contrastColor(tonumber(v.color)))
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
            term.setTextColor(U.buttonTextColor)
            term.setBackgroundColor(U.buttonColor)
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
        if (U.mouseInButton(back, cx, cy)) then
            return nil
        end
    end
end

function U.inputNumberScreen(steps, currentStep, max, maxString)
    if (max == nil) then max = 0 end
    local y = #steps+3
    while true do
        drawSteps(steps, currentStep)

        term.setCursorPos(1, y)
        term.setBackgroundColor(U.backgroundColor)
        term.setTextColor(U.specialTextColor)
        local text = tk("api.input_number")
        if (maxString ~= nil and maxString ~= "") then
            text = text.." ("..tk("api.max").." "..maxString..")"
        elseif (max ~= nil and max ~= 0) then
            text = text.." ("..tk("api.max").." $"..max..")"
        end
        text = text..":"
        print(text)
        local scrW, scrH = term.getSize()

        term.setCursorPos(2, y+2)

        local result = U.cancelableRead(max)

        if (result == nil) then
            return nil
        end

        local numberResult = tonumber(result)
        if (numberResult == nil or numberResult <= 0 or numberResult%1 ~= 0) then
            U.errorScreen(tk("api.invalid_value"))
        else
            return result
        end
    end
end

function U.inputTextScreen(steps, currentStep, maxLength, mask)
    if (maxLength == nil) then maxLength = 0 end
    drawSteps(steps, currentStep)
    local y = #steps+3
    term.setCursorPos(1, y)
    term.setBackgroundColor(U.backgroundColor)
    term.setTextColor(U.specialTextColor)
    local text = tk("api.input_text")
    if (maxLength ~= nil and maxLength ~= 0) then
        text = text.." ("..tk("api.max_length").." "..maxLength..")"
    end
    text = text..":"
    print(text)
    local scrW, scrH = term.getSize()
    term.setCursorPos(2, y+2)
    return U.cancelableRead(maxLength, nil, mask)
end

function U.selectColorScreen(steps, currentStep)
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
            term.setTextColor(U.contrastColor(color))
            term.write("[")
            term.write(string.rep(" ", w-2))
            term.write("]")
            buttons[_x][_y] = color
            color = color*2
        end
    end

    local back = U.drawBackButton()

    while true do
        local event, button, cx, cy = os.pullEvent("mouse_click")
        if (cx >= x and cx <= x+w*4 and cy >= y and cy < y+4) then
            local _x = math.floor((cx-x)/w)
            local _y = math.floor((cy-y))
            return buttons[_x][_y]
        end
        if (U.mouseInButton(back, cx, cy)) then
            return nil
        end
    end
end

function U.responseScreen(success, response)
    if (success) then
        U.successScreen(response)
    else
        U.errorScreen(response)
    end
end

-- Shared core for error/success/wait: clear the screen in `bg`, draw the
-- centered message (string or table of lines). Returns the screen size.
local function messageScreen(bg, message)
    if (message == nil) then message = tk("api.no_connection") end
    term.setBackgroundColor(bg)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorBlink(false)
    local scrW, scrH = term.getSize()
    if (type(message) == "table") then
        local startY = scrH/2-math.ceil(#message/2)
        for k, v in ipairs(message) do
            term.setCursorPos(scrW/2-string.len(v)/2+1, startY+k)
            term.write(v)
        end
        return scrW, scrH, #message
    end
    term.setCursorPos(scrW/2-string.len(message)/2+1, scrH/2)
    term.write(message)
    return scrW, scrH, 1
end

function U.errorScreen(message)
    local _, _, lines = messageScreen(colors.red, message)
    sleep(1.5 * lines)
end

function U.successScreen(message)
    local _, _, lines = messageScreen(colors.green, message)
    sleep(1.5 * lines)
end

function U.waitScreen(message)
    messageScreen(U.backgroundColor, message)
end

function U.confirmScreen(message, data, steps, currentStep)
    local y = 2
    U.drawBackground()
    if (steps ~= nil) then
        drawSteps(steps, currentStep)
        y = #steps+3
    end
    local scrW, scrH = term.getSize()
    term.setTextColor(U.specialTextColor)
    for k, v in ipairs(message) do
        term.setCursorPos((scrW-string.len(v))/2, y)
        term.write(v)
        y = y+1
    end
    y = y+1
    if (data ~= nil) then
        for k, v in pairs(data) do
            local text = tk("api."..k)..": "..v
            term.setCursorPos((scrW-string.len(text))/2, y)
            term.write(text)
            y = y+1
        end
        y = y+1
    end

    local buttonY = math.min(scrH-3, y)
    local buttonW = 20
    local buttonX = scrW/2-buttonW/2

    local acceptButton = U.drawButton(U.acceptButtonColor, U.acceptSecondaryColor, U.buttonTextColor, buttonX, buttonY, buttonW, tk("api.accept"))

    local cancelButton = U.drawButton(U.cancelButtonColor, U.cancelSecondaryColor, U.buttonTextColor, buttonX, buttonY+2, buttonW, tk("api.cancel"))

    while true do
        local event, button, cx, cy = os.pullEvent("mouse_click")
        if (U.mouseInButton(acceptButton, cx, cy)) then
            return true
        end
        if (U.mouseInButton(cancelButton, cx, cy)) then
            return false
        end
    end
end

function U.textScreen(message)
    local y = 1
    local scrW, scrH = term.getSize()
    U.drawBackground()
    term.setTextColor(colors.white)
    for k, v in ipairs(message) do
        term.setCursorPos((scrW-string.len(v))/2+1, y)
        term.write(v)
        y = y+1
    end

    U.drawBackButton()

    os.pullEvent("mouse_click")
end

return U
