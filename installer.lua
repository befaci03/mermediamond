-- Mermediamond Installer Disk

local branch = "main"
local repoBase = "https://raw.githubusercontent.com/befaci03/mermediamond/refs/heads/"..branch
local languages = { "en-us", "en-gb", "en-au", "es-es", "de-de", "de-at", "fr-fr", "fr-be", "nl-nl", "it-it", "pt-br", "pl-pl", "ru-ru", "ar-sa", "tr-tr", "sv-se", "ja-jp", "zh-cn", "ko-kr", "hu-hu", "fi-fi", "da-dk", "nb-no", "cs-cz", "el-gr", "ro-ro" }

-- NOTE: all downloads use absolute "/..." destinations on purpose!
-- This installer runs FROM the boot disk (current directory = /disk),
-- so relative paths would install everything onto the disk instead of
-- the machine's own filesystem.

-- Minified build map: maps source paths -> randomized names in minified/.
-- Cached on first use; false means "not available, use source files".
local minifiedMap = nil
local function getMinifiedMap()
    if (minifiedMap ~= nil) then return minifiedMap end
    minifiedMap = false
    if (http ~= nil) then
        local res = http.get(repoBase.."/minified/.min.map")
        if (res ~= nil) then
            local content = res.readAll()
            res.close()
            local map = textutils.unserialiseJSON(content)
            if (map ~= nil) then
                -- invert: source path -> minified name
                local bySource = {}
                for minName, srcPath in pairs(map) do bySource[srcPath] = minName end
                minifiedMap = bySource
            end
        end
    end
    return minifiedMap
end

-- Downloads one file from the repo (minified version when available).
-- Returns true when it exists afterwards.
function installFile(repoPath, localPath)
    fs.delete(localPath)
    local map = getMinifiedMap()
    if (map ~= false and map[repoPath] ~= nil) then
        shell.run("wget "..repoBase.."/minified/"..map[repoPath].." "..localPath)
    end
    if (not fs.exists(localPath)) then
        shell.run("wget "..repoBase.."/"..repoPath.." "..localPath)
    end
    if (fs.exists(localPath)) then return true end
    print("WARNING: failed to download '"..repoPath.."' (no internet?)")
    return false
end

-- Downloads the lang/ folder (translation files + tk() helper)
function installLangFiles()
    print("Downloading language files...")
    fs.delete("/lang")
    fs.makeDir("/lang")
    installFile("lang/languages.lua", "/lang/languages.lua")
    for _, lang in ipairs(languages) do installFile("lang/"..lang..".json", "/lang/"..lang..".json") end
    if (fs.exists("/lang/languages.lua")) then print("Language files installed!") else
        print("WARNING: language files failed to download.")
        print("Programs will show raw translation keys instead of text.")
    end
end

-- Downloads the updater API and its ver file (at the root, where
-- updater.readVer() and updateProgram() expect them).
function installUpdater()
    print("Downloading updater...")
    installFile("updater.lua", "/updater.lua")
    installFile("ver", "/ver")
end

-- Downloads the split bank API modules into /lib
function installBankAPI()
    print("Downloading bank API...")
    fs.delete("/lib")
    fs.makeDir("/lib")
    installFile("lib/bankapi.lua", "/lib/bankapi.lua")
    installFile("lib/uilib.lua", "/lib/uilib.lua")
    installFile("lib/net.lua", "/lib/net.lua")
    installFile("lib/cards.lua", "/lib/cards.lua")
    if (fs.exists("/lib/bankapi.lua") and fs.exists("/lib/uilib.lua") and fs.exists("/lib/net.lua") and fs.exists("/lib/cards.lua")) then
        print("Bank API installed!")
    else print("WARNING: bank API failed to download.") end
end

-- Removes the installer's boot file from the disk it is running from,
-- so the next reboot starts the freshly installed program instead of
-- this installer. The disk can simply stay in the drive.
function clearDiskBoot()
    local running = shell.getRunningProgram()
    if (running == nil) then return end
    local dir = fs.getDir(running)
    if (dir == nil or dir == "") then return end -- running from the root, not a disk
    if (fs.exists(dir.."/startup.lua")) then fs.delete(dir.."/startup.lua") end
end

function quit()
    print("Rebooting...")
    sleep(1)
    os.reboot()
end

function optionsMenu(title, description, options)
    local selectedOption = 1
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("=== "..title.." ===")
        print()

        for _, v in ipairs(description) do print(v) end
        print()
        for k, v in ipairs(options) do
            local text = v
            if (selectedOption == k) then text = "-> "..v.." <-"
            else text = "   "..v end
            print(text)
        end

        local _,k,_ = os.pullEvent("key")
        local keyName = keys.getName(k)
        if (keyName == "up") then
            selectedOption = selectedOption - 1
            if (selectedOption <= 0) then selectedOption = #options end
        elseif (keyName == "down") then
            selectedOption = selectedOption + 1
            if (selectedOption > #options) then
                selectedOption = 1
            end
        elseif (keyName == "right" or keyName == "enter" or keyName == "space") then
            return selectedOption
        end
    end
end

function installStoreClerk()
    print("Installing Mermediamond Store Clerk...")
    installLangFiles()
    installUpdater()
    installBankAPI()
    fs.delete("/startup.lua")
    installFile("shopClerk/startup.lua", "/startup.lua") -- Store clerk
    clearDiskBoot()
    quit()
end

function installBankServer()
    print("Installing Mermediamond Bank Server...")
    installLangFiles()
    installUpdater()
    installBankAPI()
    fs.makeDir("/server")
    installFile("server/startup.lua", "/server/startup.lua") -- Bank Server
    installFile("server/config.lua", "/server/config.lua")
    installFile("server/db.lua", "/server/db.lua")
    installFile("server/menu.lua", "/server/menu.lua")
    fs.delete("/startup.lua")
    fs.copy("/server/startup.lua", "/startup.lua") -- boot from the installed copy
    clearDiskBoot()
    quit()
end

function installAdminTerminal()
    print("Installing Mermediamond Admin terminal...")
    installLangFiles()
    installUpdater()
    installBankAPI()
    fs.delete("/startup.lua")
    installFile("admin/startup.lua", "/startup.lua") -- Admin Terminal
    clearDiskBoot()
    quit()
end

function installATMTerminal()
    print("Installing Mermediamond ATM Terminal...")
    installLangFiles()
    installUpdater()
    installBankAPI()
    fs.delete("/startup.lua")
    installFile("atm/client.lua", "/startup.lua") -- ATM Terminal
    clearDiskBoot()
    quit()
end

function installATMTurtle()
    print("Installing Mermediamond ATM Turtle (with auto-setup)...")
    print("")
    print("IMPORTANT - before the auto-setup starts, place me:")
    print("  - ONE BLOCK UP, on top of a single block (I will break")
    print("    that block and build the ATM in the air around me)")
    print("  - with empty surroundings: nothing in front, behind,")
    print("    left, right or above me")
    print("  - NO disk drive below me!")
    print("And put in my inventory: 4 chests, a barrel, a normal")
    print("modem, an ender modem, an advanced computer, a crafting")
    print("table, a disk drive and a floppy disk.")
    print("")
    print("Press any key to download and start the auto-setup...")
    os.pullEvent("key")
    fs.delete("/autosetup.lua")
    installFile("atm/installer.lua", "/autosetup.lua")
    print("Running auto-setup...")
    sleep(1)
    shell.run("/autosetup")
end

function showHelp()
    term.clear()
    term.setCursorPos(1,1)
    while (true) do
        local selectedOption = optionsMenu("Help", {"Mermediamond Bank needs a few different computers and turtles to run."},
        {
            "Bank Server",
            "Admin Terminal",
            "ATM",
            "Store Clerk",
            "[Go Back]"
        })
        term.clear()
        term.setCursorPos(1,1)
        if (selectedOption == 1) then
            print("=== The Bank Server ===")
            print("")
            print("This should be a single Advanced Computer, with a disk drive and an Ender Modem")
            print("It must be placed in a chunk that will remain loaded at all times.")
            print("This is the brains and database of the bank. Keep it always on! In it you can configure your bank. There should only be one. You may want to put it in a place where only you can access.")
            print("")
            print("Press any key to go back...")
            os.pullEvent("key")
        elseif (selectedOption == 2) then
            print("=== Admin Terminals ===")
            print("")
            print("They should be an Advanced Computer, with a disk drive and an Ender Modem.")
            print("These are password protected terminals for bank employees only. It is on these terminals that employees can create and delete accounts, issue paper cards, install the mobile app on pocket computers, and other admin-only operations.")
            print("")
            print("Press any key to go back...")
            os.pullEvent("key")
        elseif (selectedOption == 3) then
            print("=== ATM ===")
            print("")
            print("The ATMs are a multi-block, multi-computer machine. They consist of a regular Turtle that takes care of crafting and moving items, and a terminal that acts as a user interface.")
            print("There is an automatic setup which builds the whole ATM for you. Place a regular turtle ONE BLOCK UP, on top of a single block, with empty space all around it (it breaks that block and builds there - no disk drive below it!). Give it 4 chests, a barrel, a normal modem, an ender modem, an advanced computer, a crafting table, a disk drive and a floppy disk.")
            print("Then use this disk to run 'Install ATM Turtle (with auto-setup)' on the turtle and follow the instructions: it builds the contraption, installs itself as the money assistant, and writes a setup disk that makes the ATM's computer install its terminal automatically on first boot.")
            print("")
            print("Press any key to go back...")
            os.pullEvent("key")
        elseif (selectedOption == 4) then
            print("=== Store Clerk ===")
            print("")
            print("The Store Clerk is an Advanced Turtle with an Ender modem on top of a disk drive, looking at a barrel or chest.")
            print("It acts as a checkout for stores, where you can configure prices and names. Customers read out their paper card: the clerk enters the card details, gets an automatic tally of the price of their items, and charges their Mermediamond account directly.")
            print("")
            print("Press any key to go back...")
            os.pullEvent("key")
        elseif (selectedOption == 5) then
            mainMenu()
            break
        end
    end
end

function mainMenu()
    if (turtle) then
        local options = {
            "Help",
            "Install Store Clerk",
            "Install ATM Turtle (with auto-setup)",
            "Cancel",
        }
        local selectedOption = optionsMenu("Install Mermediamond program", {"For Turtles"}, options)
        if (selectedOption == 1) then showHelp()
        elseif (selectedOption == 2) then installStoreClerk()
        elseif (selectedOption == 3) then installATMTurtle()
        else quit() end
    else
        local selectedOption = optionsMenu("Install Mermediamond program", {"For Computer"}, {
            "Help",
            "Install Bank Server",
            "Install Admin terminal",
            "Install ATM Terminal",
            "Cancel"
        })
        if (selectedOption == 1) then showHelp()
        elseif (selectedOption == 2) then installBankServer()
        elseif (selectedOption == 3) then installAdminTerminal()
        elseif (selectedOption == 4) then installATMTerminal()
        else quit() end
    end
end

mainMenu()
