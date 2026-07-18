-- Mermegold Installer Disk

function quit()
    local diskdrive = peripheral.find("drive")
    if (diskdrive.isDiskPresent()) then
        diskdrive.ejectDisk()
    end
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

        for k, v in pairs(description) do
            print(v)
        end
        print()

        for k, v in pairs(options) do
            local text = v
            if (selectedOption == k) then
                text = "-> "..v.." <-"
            else
                text = "   "..v
            end
            print(text)
        end

        local event, key, is_held = os.pullEvent("key")
        local keyName = keys.getName(key)
        if (keyName == "w" or keyName == "up") then
            selectedOption = selectedOption - 1
            if (selectedOption <= 0) then
                selectedOption = #options
            end
        elseif (keyName == "s" or keyName == "down") then
            selectedOption = selectedOption + 1
            if (selectedOption > #options) then
                selectedOption = 1
            end
        elseif (keyName == "d" or keyName == "right" or keyName == "enter" or keyName == "space") then
            return selectedOption
        end
    end
end

function installStoreClerk()
    print("Installing Mermegold Store Clerk...")
    fs.delete("bankapi.lua")
    shell.run("pastebin get wSKUaGG0 bankapi.lua") -- Bank API
    fs.delete("startup.lua")
    shell.run("pastebin get pgw11ZAq startup.lua") -- Store clerk
    quit()
end

function installATMTurtle()
    print("Installing Mermegold ATM Assistant ...")
    fs.delete("bankapi.lua")
    shell.run("pastebin get wSKUaGG0 bankapi.lua") -- Bank API
    fs.delete("startup.lua")
    shell.run("pastebin get 32EJUy53 startup.lua") -- ATM Assistant
    quit()
end

function installATMTurtleWithAutoSetup()
    print("Installing Mermegold ATM Assistant ...")
    fs.delete("autosetup.lua")
    shell.run("pastebin get 0dSekuU1 autosetup.lua") -- ATM Assistant autosetup
    print("Running autosetup...")
    sleep(1)
    shell.run("autosetup")
    -- dont quit, need the disk to install ATM Interface
end

function installBankServer()
    print("Installing Mermegold Bank Server...")
    fs.delete("bankapi.lua")
    shell.run("pastebin get wSKUaGG0 bankapi.lua") -- Bank API
    fs.delete("startup.lua")
    shell.run("pastebin get NFdQ6Epa startup.lua") -- Bank Server
    quit()
end

function installAdminTerminal()
    print("Installing Mermegold Admin terminal...")
    fs.delete("bankapi.lua")
    shell.run("pastebin get wSKUaGG0 bankapi.lua") -- Bank API
    fs.delete("startup.lua")
    shell.run("pastebin get eksCPqRa startup.lua") -- Admin Terminal
    quit()
end

function installATMInterface()
    print("Installing Mermegold ATM terminal...")
    fs.delete("bankapi.lua")
    shell.run("pastebin get wSKUaGG0 bankapi.lua") -- Bank API
    fs.delete("startup.lua")
    shell.run("pastebin get cWMVXkrv startup.lua") -- ATN Terminal
    quit()
end

function manuallyInstallATMInterface()
    local selectedOption = optionsMenu("Manually install program", {"There is a turtle program that will automatically setup an entire ATM machine, including a computer with this program. Are you sure you want to install manually anyways?"}, {
        "No, go back",
        "Yes, I know what I'm doing"
    })
    if (selectedOption == 1) then
        mainMenu()
    elseif (selectedOption == 2) then
        installATMInterface()
    end
end

function manuallyInstallATMTurtle()
    local selectedOption = optionsMenu("Manually install program", {"There is a turtle program that will automatically setup not only this turtle, but an entire ATM machine, including building the contraption and installing the terminal. Are you sure you want to install manually anyways?"}, {
        "No, go back",
        "Yes, I know what I'm doing"
    })
    if (selectedOption == 1) then
        mainMenu()
    elseif (selectedOption == 2) then
        installATMTurtle()
    end
end

function showHelp()
    term.clear()
    term.setCursorPos(1,1)
    while (true) do
        local selectedOption = optionsMenu("Help", {"Mermegold Bank needs a few different computers and turtles to run."},
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
            print("It acts as a checkout for stores, where you can configure prices and names. People who use your shop can insert their card into the disk drive, get an automatic tally of the price of their items, and pay with their Mermegold account directly.")
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
            "Install ATM turtle w/ auto-setup",
            "(Manually Install ATM turtle)",
            "Cancel and eject",
        }
        if (fs.exists("autosetup.lua")) then
            table.insert(options, "Run ATM Turtle autosetup")
        end
        local selectedOption = optionsMenu("Install Mermegold program", {"For Turtles"}, options)
        if (selectedOption == 1) then
            showHelp()
        elseif (selectedOption == 2) then
            installStoreClerk()
        elseif (selectedOption == 3) then
            installATMTurtleWithAutoSetup()
        elseif (selectedOption == 4) then
            manuallyInstallATMTurtle()
        elseif (selectedOption == 5) then
            quit()
        elseif (selectedOption == 6) then
            shell.run("autosetup")
        end
    else
        local selectedOption = optionsMenu("Install Mermegold program", {"For Computer"}, {
            "Help",
            "Install Bank Server",
            "Install Admin terminal",
            "(Manually Install ATM interface)",
            "Cancel and eject"
        })
        if (selectedOption == 1) then
            showHelp()
        elseif (selectedOption == 2) then
            installBankServer()
        elseif (selectedOption == 3) then
            installAdminTerminal()
        elseif (selectedOption == 4) then
            manuallyInstallATMInterface()
        else
            quit()
        end
    end
end
