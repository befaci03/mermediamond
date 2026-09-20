-- Mermediamond ATM Terminal bootstrap
--
-- The ATM turtle auto-setup writes this file to the installer disk that
-- sits in the drive below the ATM's computer. When that computer boots
-- with the disk present, this script installs the ATM Terminal onto the
-- computer (first boot only) and then always launches the locally
-- installed copy.
--
-- To force a reinstall from the disk: delete /startup.lua or /ver.

local branch = "main"
local repoBase = "https://raw.githubusercontent.com/befaci03/mermediamond/refs/heads/"..branch
local languages = { "en-us", "en-gb", "en-au", "es-es", "de-de", "de-at", "fr-fr", "fr-be", "nl-nl", "it-it", "pt-br", "pl-pl", "ru-ru", "ar-sa", "tr-tr", "sv-se", "ja-jp", "zh-cn", "ko-kr", "hu-hu", "fi-fi", "da-dk", "nb-no", "cs-cz", "el-gr", "ro-ro" }

-- Minified build map: source path -> randomized name in minified/.
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
                local bySource = {}
                for minName, srcPath in pairs(map) do bySource[srcPath] = minName end
                minifiedMap = bySource
            end
        end
    end
    return minifiedMap
end

local function installFile(repoPath, localPath)
    fs.delete(localPath)
    local map = getMinifiedMap()
    if (map ~= false and map[repoPath] ~= nil) then
        shell.run("wget "..repoBase.."/minified/"..map[repoPath].." "..localPath)
    end
    if (not fs.exists(localPath)) then
        shell.run("wget "..repoBase.."/"..repoPath.." "..localPath)
    end
    if (fs.exists(localPath)) then return true end
    print("WARNING: failed to download '"..repoPath.."'")
    return false
end

term.clear()
term.setCursorPos(1,1)

-- Already installed? Just run the local copy (updates are handled by the
-- updater itself, so we never overwrite a newer local install here).
if (fs.exists("/startup.lua") and fs.exists("/ver") and fs.isDir("/lib") and fs.isDir("/server")) then
    shell.run("/startup.lua")
    return
end

print("== Mermediamond ATM Terminal setup ==")
print("")
print("Installing the ATM Terminal onto this computer...")
print("")

local ok = true

print("Downloading bank API...")
fs.delete("/lib")
fs.makeDir("/lib")
for _, f in ipairs({"bankapi.lua", "uilib.lua", "net.lua", "cards.lua"}) do
    if (not installFile("lib/"..f, "/lib/"..f)) then ok = false end
end

if (ok) then
    print("Downloading language files...")
    fs.delete("/lang")
    fs.makeDir("/lang")
    installFile("lang/languages.lua", "/lang/languages.lua")
    for _, lang in ipairs(languages) do installFile("lang/"..lang..".json", "/lang/"..lang..".json") end

    print("Downloading updater...")
    installFile("updater.lua", "/updater.lua")
    installFile("ver", "/ver")

    print("Downloading ATM Terminal...")
    fs.delete("/startup.lua")
    ok = installFile("atm/client.lua", "/startup.lua")

    print("Downloading server modules (shared by the bank network)...")
    fs.makeDir("/server")
    installFile("server/config.lua", "/server/config.lua")
    installFile("server/db.lua", "/server/db.lua")
    installFile("server/menu.lua", "/server/menu.lua")
end

if (not ok) then
    print("")
    print("Installation failed. Check the internet connection and")
    print("reboot this computer to try again.")
    return
end

print("")
print("ATM Terminal installed! Starting it up...")
sleep(1)
shell.run("/startup.lua")
