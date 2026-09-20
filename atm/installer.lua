local chests = 0
local barrels = 0
local modems = 0
local computers = 0
local enderModems = 0
local craftingTables = 0
local diskDrives = 0
local disks = 0

local branch = "main"
local baseUrl = "https://raw.githubusercontent.com/befaci03/mermediamond/refs/heads/"..branch

-- Minified build map: source path -> randomized name in minified/.
-- Cached on first use; false means "not available, use source files".
local minifiedMap = nil
local function getMinifiedMap()
    if (minifiedMap ~= nil) then return minifiedMap end
    minifiedMap = false
    if (http ~= nil) then
        local res = http.get(baseUrl.."/minified/.min.map")
        if (res ~= nil) then
            local content = res.readAll()
            res.close()
            local map = textutils.unserialiseJSON(content)
            if (map ~= nil) then
                local bySource = {}
                for minName, srcPath in pairs(map) do bySource[srcPath] = minName end
                minifiedMap = bySource
            end
        end
    end
    return minifiedMap
end

-- Download one repo file (minified version when available, source fallback).
local function mfGet(repoPath, localPath)
    fs.delete(localPath)
    local map = getMinifiedMap()
    if (map ~= false and map[repoPath] ~= nil) then
        shell.run("wget "..baseUrl.."/minified/"..map[repoPath].." "..localPath)
    end
    if (not fs.exists(localPath)) then
        shell.run("wget "..baseUrl.."/"..repoPath.." "..localPath)
    end
    return fs.exists(localPath)
end

function checklistItem(text, currentAmount, amountNeeded)
    local check = "[ ] "
    if (currentAmount >= amountNeeded) then
        check = "[x] "
    end
    print(check..text..": "..currentAmount.."/"..amountNeeded)
    return currentAmount >= amountNeeded
end

term.clear()
term.setCursorPos(1,1)
print("=== ATM Setup ===")
print("Hello! I am an ATM Assistant. I'm not the one that does customer service, but I help move and manage the stored money in an ATM. I can be a normal turtle, no need for an Advanced one.")
print("The ATM contraption itself requires a specific setup which I can build for you. I just need some items in my inventory.")
print("")
print("Press any key to continue...")
os.pullEvent("key")

-------------------- Position check --------------------
-- I must be placed ONE BLOCK UP (on top of a single block) with empty
-- surroundings. I break the block below me: its spot is used for the
-- ATM's disk drive, so there must NOT be a disk drive below me.
print("")
print("Checking my position...")

while (turtle.detectDown()) do
    if (peripheral.getType("bottom") == "drive") then
        term.clear()
        term.setCursorPos(1,1)
        print("=== ATM Setup cancelled ===")
        print("")
        print("There is a disk drive below me - I can't break that!")
        print("(If you started me from an installer disk, run the")
        print("installer from my own filesystem instead.)")
        print("")
        print("Place me ONE BLOCK UP on a single block instead:")
        print("I will break that block and use its spot for the")
        print("ATM's disk drive.")
        return
    end
    if (not turtle.digDown()) then
        term.clear()
        term.setCursorPos(1,1)
        print("=== ATM Setup cancelled ===")
        print("")
        print("The block below me is unbreakable!")
        print("Place me one block up on a block I can dig.")
        return
    end
end

-- True when front/back/left/right and the space above are all clear
local function surroundingsClear()
    local clear = (not turtle.detect()) and (not turtle.detectUp())
    turtle.turnRight()
    if (turtle.detect()) then clear = false end
    turtle.turnRight()
    if (turtle.detect()) then clear = false end
    turtle.turnRight()
    if (turtle.detect()) then clear = false end
    turtle.turnRight() -- face the original direction again
    return clear
end

if (not surroundingsClear()) then
    term.clear()
    term.setCursorPos(1,1)
    print("=== ATM Setup cancelled ===")
    print("")
    print("I need to be in an empty space: all of my surroundings")
    print("(front, back, left, right and above) must be clear.")
    print("")
    print("I also need to be placed ONE BLOCK UP, on top of a single")
    print("block, so I have room to build the ATM around me.")
    print("")
    print("Reposition me and run me again.")
    return
end
print("Position OK!")
sleep(1)

local requiredFuel = 10
while (turtle.getFuelLevel() < requiredFuel) do
    term.clear()
    term.setCursorPos(1,1)
    print("First I'm going to need a bit of fuel.")
    print("")
    print("Fuel level: "..turtle.getFuelLevel().."/"..requiredFuel)
    print("Press any key to consume fuel...")
    os.pullEvent("key")
    print("")
    print("Refuelling...")
    for i=1, 16 do
        if (turtle.getFuelLevel() < requiredFuel) then
            while (turtle.getItemCount(i) > 0) do
                turtle.select(i)
                if (turtle.refuel(1)) then
                    if (turtle.getFuelLevel() >= requiredFuel) then
                        break
                    end
                end
            end
        end
    end
    sleep(0.1)
    if (turtle.getFuelLevel() < requiredFuel) then
        print("I still don't have enough fuel...")
        sleep(2)
    else
        print("All fueled up!")
        sleep(1)
    end
end

-- I also need to be able to reach the level below me: that is where
-- the ATM's disk drive goes (directly under the ATM computer).
if (not turtle.down()) then
    term.clear()
    term.setCursorPos(1,1)
    print("=== ATM Setup cancelled ===")
    print("")
    print("The space one level below me is blocked!")
    print("")
    print("I need to be placed ONE BLOCK UP, on top of a single block")
    print("above the ground, so I can build the ATM in the air.")
    print("")
    print("Reposition me and run me again.")
    return
end
turtle.up()

while (true) do
    chests = 0
    barrels = 0
    modems = 0
    computers = 0
    enderModems = 0
    craftingTables = 0
    diskDrives = 0
    disks = 0
    for i=1, 16 do
        local item = turtle.getItemDetail(i)
        if (item ~= nil) then
            if (item.name == "minecraft:chest") then chests = chests + item.count
            elseif (item.name == "minecraft:barrel") then barrels = barrels + item.count
            elseif (item.name == "computercraft:wireless_modem_normal") then modems = modems + item.count
            elseif (item.name == "computercraft:wireless_modem_advanced") then enderModems = enderModems + item.count
            elseif (item.name == "computercraft:computer_advanced") then computers = computers + item.count
            elseif (item.name == "minecraft:crafting_table") then craftingTables = craftingTables + item.count
            elseif (item.name == "computercraft:disk_drive") then diskDrives = diskDrives + item.count
            elseif (item.name == "computercraft:disk") then disks = disks + item.count
            end
        end
    end

    local leftEquipment = peripheral.getType("left")
    local rightEquipment = peripheral.getType("right")
    if (leftEquipment == "workbench" or rightEquipment == "workbench") then
        craftingTables = craftingTables + 1
    end
    if (leftEquipment == "modem" or rightEquipment == "modem") then
        modems = modems + 1
    end

    term.clear()
    term.setCursorPos(1,1)

    print("What I need:")
    print("")
    local ready = true
    if (not checklistItem("4 chests", chests, 4)) then ready = false end
    if (not checklistItem("A barrel", barrels, 1)) then ready = false end
    if (not checklistItem("A regular modem", modems, 1)) then ready = false end
    if (not checklistItem("An ender modem", enderModems, 1)) then ready = false end
    if (not checklistItem("An advanced computer", computers, 1)) then ready = false end
    if (not checklistItem("A crafting table", craftingTables, 1)) then ready = false end
    if (not checklistItem("A disk drive", diskDrives, 1)) then ready = false end
    if (not checklistItem("A floppy disk", disks, 1)) then ready = false end

    if (ready) then
        print("")
        print("All ready! Press any key to continue...")
        os.pullEvent("key")
        break
    end

    while true do
        local event = os.pullEvent()
        if event == "turtle_inventory" or event == "peripheral" or event == "peripheral_detach" then
            break
        end
    end
end

function selectItem(itemName)
    while (true) do
        for i=1, 16 do
            local item = turtle.getItemDetail(i)
            if (item ~= nil) then
                if (item.name == itemName) then
                    turtle.select(i)
                    return true
                end
            end
        end
        print("Missing item... please insert a '"..itemName.."' in my inventory to continue.")
        os.pullEvent("turtle_inventory")
    end
end

function place()
    while (not turtle.place()) do
        print("Something is blocking the way in front of me")
        sleep(1)
    end
end
function placeUp()
    while (not turtle.placeUp()) do
        print("Something is blocking the way above me")
        sleep(1)
    end
end
function placeDown()
    while (not turtle.placeDown()) do
        print("Something is blocking the way below me")
        sleep(1)
    end
end

function forward()
    while (not turtle.forward()) do
        print("Something is blocking the way in front of me")
        sleep(1)
    end
end
function up()
    while (not turtle.up()) do
        print("Something is blocking the way above me")
        sleep(1)
    end
end
function down()
    while (not turtle.down()) do
        print("Something is blocking the way below me")
        sleep(1)
    end
end
function back()
    while (not turtle.back()) do
        print("Something is blocking the way behind me")
        sleep(1)
    end
end

-- Building sequence
term.clear()
term.setCursorPos(1,1)
print("Let's begin!")

-- Equip upgrades
---- Equip modem
local leftEquipment = peripheral.getType("left")
local rightEquipment = peripheral.getType("right")
local hasModem = leftEquipment == "modem" or rightEquipment == "modem"
if (not hasModem) then
    selectItem("computercraft:wireless_modem_normal")
    turtle.equipLeft()
end
---- Equip workbench
leftEquipment = peripheral.getType("left")
rightEquipment = peripheral.getType("right")
local hasWorkbench = leftEquipment == "workbench" or rightEquipment == "workbench"
if (not hasWorkbench) then
    selectItem("minecraft:crafting_table")
    turtle.equipRight()
end

-- Place the disk drive in the spot freed by breaking the block below,
-- then write the ATM Terminal setup onto the floppy inside it. The ATM
-- computer (placed on top of the drive afterwards) boots from this disk
-- and installs its terminal by itself.
back()
down()

selectItem("computercraft:disk_drive")
while (not turtle.place()) do
    -- the spot should be free (I broke the block below me), but clear
    -- it anyway in case I was placed on a taller pillar
    if (not turtle.dig()) then
        print("The spot in front of/below me is blocked and unbreakable!")
        sleep(2)
    end
end
selectItem("computercraft:disk")
while (not turtle.place()) do
    print("Could not insert the floppy disk into the disk drive...")
    print("(Make sure the drive is empty and the disk is a data disk.)")
    sleep(2)
end

local diskPath = disk.getMountPath("front")
if (diskPath == nil) then
    print("WARNING: can't read the floppy disk I just inserted!")
    print("The ATM Terminal will have to be installed manually")
    print("(use the installer's 'Install ATM Terminal' option).")
    sleep(3)
else
    print("Writing the ATM Terminal setup to the floppy disk...")
    for _, stale in ipairs({"startup.lua", "installer.lua", "autosetup.lua"}) do
        if (fs.exists(diskPath.."/"..stale)) then fs.delete(diskPath.."/"..stale) end
    end
    mfGet("atm/bootstrap.lua", diskPath.."/startup.lua")
    if (fs.exists(diskPath.."/startup.lua")) then
        print("Setup disk ready!")
    else
        print("WARNING: failed to write the setup disk (no internet?)")
        print("The ATM Terminal will have to be installed manually.")
    end
    sleep(2)
end

up()
selectItem("computercraft:computer_advanced")
place()
sleep(1)
peripheral.call("front", "turnOn")
sleep(1)
up()
forward()
forward()
down()
turtle.turnRight()
turtle.turnRight()

selectItem("minecraft:chest")
placeDown()
selectItem("minecraft:chest")
placeUp()

back()
selectItem("computercraft:wireless_modem_advanced")
place()
turtle.turnLeft()
forward()
turtle.turnRight()
forward()

selectItem("minecraft:chest")
placeDown()
selectItem("minecraft:chest")
placeUp()
selectItem("minecraft:barrel")
place()

print("Installing Mermediamond ATM Assistant ...")

-- NOTE: absolute "/..." destinations so everything lands on this
-- turtle's own filesystem and not on the boot disk.

-- Download the lang/ folder (translation files + tk() helper)
print("Downloading language files...")
fs.delete("/lang")
fs.makeDir("/lang")
mfGet("lang/languages.lua", "/lang/languages.lua")
local languages = { "en-us", "en-gb", "en-au", "es-es", "de-de", "de-at", "fr-fr", "fr-be", "nl-nl", "it-it", "pt-br", "pl-pl", "ru-ru", "ar-sa", "tr-tr", "sv-se", "ja-jp", "zh-cn", "ko-kr", "hu-hu", "fi-fi", "da-dk", "nb-no", "cs-cz", "el-gr", "ro-ro" }
for _, lang in ipairs(languages) do
    mfGet("lang/"..lang..".json", "/lang/"..lang..".json")
end
if (fs.exists("lang/languages.lua")) then
    print("Language files installed!")
else
    print("WARNING: language files failed to download.")
    print("The ATM will show raw translation keys instead of text.")
end

print("Downloading updater...")
mfGet("updater.lua", "/updater.lua")
mfGet("ver", "/ver")

-- Download the split bank API modules into /lib/
print("Downloading bank API...")
fs.delete("/lib")
fs.makeDir("/lib")
mfGet("lib/bankapi.lua", "/lib/bankapi.lua")
mfGet("lib/uilib.lua", "/lib/uilib.lua")
mfGet("lib/net.lua", "/lib/net.lua")
mfGet("lib/cards.lua", "/lib/cards.lua")

fs.delete("/startup.lua")
mfGet("atm/startup.lua", "/startup.lua") -- ATM Assistant

print("Dropping leftover items...")
for i=1, 16 do
    if (turtle.getItemCount(i) > 0) then
        turtle.select(i)
        turtle.drop()
    end
end

print("All done, the ATM is ready-for-use!")
sleep(1)
os.reboot()
