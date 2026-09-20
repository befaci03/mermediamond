-- Network layer: rednet protocol with the bank server, shared server data
-- and the update-check bridge. Split out of bankapi.lua; loaded
-- automatically by lib/bankapi.lua.

local N = {}

N.bankServerID = 0
N.serverData = nil
N.lang = "en-us"

-- Cached account list; invalidated by any operation that mutates accounts
local clientDataCache = nil

function N.invalidateClientData() clientDataCache = nil end

-------------------- Low-level protocol --------------------

local function isReply(sender, response) return response ~= nil and os.computerID() ~= sender and response.response ~= nil end

-- Spinner shown while waiting for the server to come back
local spinnerFrames = { "|", "/", "-", "\\" }
local function spin(frame)
    local x, y = term.getCursorPos()
    term.write(spinnerFrames[(frame % #spinnerFrames)+1])
    term.setCursorPos(x, y)
end

-- One RPC round-trip.
-- opts.retry: re-send on timeout (safe for read-only actions only;
-- mutations must not retry to avoid executing twice).
function N.call(action, payload, opts)
    opts = opts or {}
    local message = payload or {}
    message.action = action
    local frame = 0
    while true do
        rednet.send(N.bankServerID, message, "mermediamond")
        local sender, response = rednet.receive("mermediamond", opts.timeout or 5)
        if isReply(sender, response) then
            return response
        end
        if (not opts.retry) then
            return nil -- server unreachable; caller decides (matches old blocking behaviour)
        end
        frame = frame+1
        spin(frame)
    end
end

-------------------- Server data --------------------

function N.getServerData()
    print("Connecting to server...")
    local frame = 0
    while true do
        rednet.broadcast({ action = "getServerData" }, "mermediamond")
        local sender, response = rednet.receive("mermediamond", 3)
        if isReply(sender, response) then
            N.bankServerID = sender
            N.serverData = response.response
            N.lang = response.response.lang or N.lang
            _G.activeLang = N.lang -- used by tk() in this API and all client programs
            if (setLang ~= nil) then setLang(N.lang) end
            print("Connected to server [#"..sender.."]")
            return response.response
        end
        frame = frame+1
        spin(frame)
    end
end

function N.getClientData(force)
    if (not force and clientDataCache ~= nil) then
        return clientDataCache
    end
    local response = N.call("getClientData", nil, { retry = true })
    if (response == nil) then return nil end
    clientDataCache = response.response
    return clientDataCache
end

function N.getTransactionLog(key)
    local response = N.call("getTransactionLog", { key = key }, { retry = true })
    if (response == nil) then return nil end
    return response.response
end

-------------------- Bank operations --------------------
-- Mutations are NOT retried on timeout: a retry could execute the
-- operation twice on the server even if the reply was lost.

function N.transaction(from, to, amount, description)
    local response = N.call("transaction", {
        from = from, to = to, amount = amount, description = description
    })
    if (response == nil) then return false, "No connection to the server" end
    return response.success, response.response
end

function N.deposit(key, amount)
    local response = N.call("deposit", { key = key, amount = amount })
    if (response == nil) then return false, "No connection to the server" end
    return response.success, response.response
end

function N.withdraw(key, amount)
    local response = N.call("withdraw", { key = key, amount = amount })
    if (response == nil) then return false, "No connection to the server" end
    return response.success, response.response
end

function N.newAccount(name, balance, color)
    local response = N.call("new", { name = name, balance = balance, color = color })
    if (response == nil) then return false, "No connection to the server" end
    if (response.success) then clientDataCache = nil end
    return response.success, response.response
end

function N.deleteAccount(key)
    local response = N.call("delete", { key = key })
    if (response == nil) then return false, "No connection to the server" end
    if (response.success) then clientDataCache = nil end
    return response.success, response.response
end

-------------------- Cards over the wire --------------------

-- Log in with a printed card: send the decoded card table for validation
function N.cardLogin(card)
    local response = N.call("cardlogin", { card = card })
    if (response == nil) then return false, "No connection to the server" end
    return response.success, response.response
end

-- Ask the server to issue a new card for an account (bank chooses the prefix)
function N.assignCard(account)
    local response = N.call("assigncard", { account = account })
    if (response == nil) then return false, "No connection to the server" end
    return response.success, response.response
end

-------------------- Updates --------------------

-- Check for updates against the bank server and offer to install them.
-- Never blocks when the server has no newer version or the user declines.
function N.autoUpdate(program, silent)
    if (updater ~= nil and updater.autoUpdate ~= nil) then
        local ok, result = pcall(updater.autoUpdate, program, silent)
        if (ok) then return result end
    end
    return false
end

return N
