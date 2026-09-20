-- Mermediamond Installer Disk

local repoBase = "https://raw.githubusercontent.com/befaci03/mermediamond"
local languages = { "en-us", "en-gb", "en-au", "es-es", "de-de", "de-at", "fr-fr", "fr-be", "nl-nl", "it-it", "pt-br", "ru-ru", "ar-sa", "tr-tr", "sv-se", "ja-jp", "zh-cn", "ko-kr", "hu-hu", "fi-fi", "da-dk", "nb-no", "cs-cz", "el-gr", "ro-ro" }

-- Downloads the lang/ folder (translation files + tk() helper)
-- plus the updater API and its ver file.
-- Required by bankapi.lua and every program's localization.
function installLangFiles()
    print("Downloading language files...")
    fs.delete("lang")
    fs.makeDir("lang")
    shell.run("wget "..repoBase.."/lang/languages.lua lang/languages.lua")
    for _, lang in ipairs(languages) do shell.run("wget "..repoBase.."/lang/"..lang..".json lang/"..lang..".json") end
    if (fs.exists("lang/languages.lua")) then print("Language files installed!") else
        print("WARNING: language files failed to download.")
        print("Programs will show raw translation keys instead of text.")
    end

    print("Downloading updater...")
    shell.run("wget "..repoBase.."/updater.lua updater.lua")
    shell.run("wget "..repoBase.."/ver .mermediamond/ver")
end

function quit()
    local diskdrive = peripheral.find("drive")
    if (diskdrive.isDiskPresent()) then diskdrive.ejectDisk() end
    print("Disk ejected")
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

        for _, v in pairs(description) do print(v) end
        print()
        for k, v in pairs(options) do
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

-- Downloads the split bank API modules into lib/
function installBankAPI()
    print("Downloading bank API...")
    fs.delete("lib")
    fs.makeDir("lib")
    shell.run("wget "..repoBase.."/lib/bankapi.lua lib/bankapi.lua")
    shell.run("wget "..repoBase.."/lib/uilib.lua lib/uilib.lua")
    shell.run("wget "..repoBase.."/lib/net.lua lib/net.lua")
    shell.run("wget "..repoBase.."/lib/cards.lua lib/cards.lua")
    if (fs.exists("lib/bankapi.lua") and fs.exists("lib/uilib.lua") and fs.exists("lib/net.lua") and fs.exists("lib/cards.lua")) then
        print("Bank API installed!")
    else print("WARNING: bank API failed to download.") end
end

function installStoreClerk()
    print("Installing Mermediamond Store Clerk...")
    installLangFiles()
    installBankAPI()
    fs.delete("startup.lua")
    shell.run("wget "..repoBase.."/shopClerk/startup.lua startup.lua") -- Store clerk
    quit()
end

function installATMTurtle()
    print("Installing Mermediamond ATM Assistant ...")
    installLangFiles()
    fs.delete("autosetup.lua")
    shell.run("wget "..repoBase.."/atm/installer.lua autosetup.lua") -- ATM Assistant autosetup
    print("Running autosetup...")
    sleep(1)
    shell.run("autosetup")
    -- dont quit, need the disk to install ATM Interface
end

function installBankServer()
    print("Installing Mermediamond Bank Server...")
    installLangFiles()
    installBankAPI()
    fs.delete("startup.lua")
    shell.run("wget "..repoBase.."/server/startup.lua startup.lua") -- Bank Server
    quit()
end

function installAdminTerminal()
    print("Installing Mermediamond Admin terminal...")
    installLangFiles()
    installBankAPI()
    fs.delete("startup.lua")
    shell.run("wget "..repoBase.."/admin/startup.lua startup.lua") -- Admin Terminal
    quit()
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
            print("These are password protected terminals for bank employees only. It is on these terminals that employees can create and delete accounts, link cards to users, install the mobile app on pocket computers, and other admin-only operations.")
            print("")
            print("Press any key to go back...")
            os.pullEvent("key")
        elseif (selectedOption == 3) then
            print("=== ATM ===")
            print("")
            print("The ATMs are a multi-block, multi-computer machine. They consist of a regular Turtle that takes care of crafting and moving items, and a terminal that acts as a user interface.")
            print("There is an automatic setup with instructions to automatically construct and install an ATM. All you have to do is place a regular turtle on top of a disk drive, then using this disk install the 'ATM Turtle w/ auto-setup' program and follow the instructions.")
            print("")
            print("Press any key to go back...")
            os.pullEvent("key")
        elseif (selectedOption == 4) then
            print("=== Store Clerk ===")
            print("")
            print("The Store Clerk is an Advanced Turtle with an Ender modem on top of a disk drive, looking at a barrel or chest.")
            print("It acts as a checkout for stores, where you can configure prices and names. People who use your shop can insert their card into the disk drive, get an automatic tally of the price of their items, and pay with their Mermediamond account directly.")
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
            "Install ATM",
            "Cancel and eject",
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
            "Cancel and eject"
        })
        if (selectedOption == 1) then showHelp()
        elseif (selectedOption == 2) then installBankServer()
        elseif (selectedOption == 3) then installAdminTerminal()
        else quit() end
    end
end
