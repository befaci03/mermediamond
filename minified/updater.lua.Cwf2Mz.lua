local branch = "main"
local function getRepoBase() return "https://raw.githubusercontent.com/befaci03/mermediamond/refs/heads/"..branch end
local pathMap = {
["server/startup.lua"] = "startup.lua", ["lib/bankapi.lua"] = "bankapi.lua", ["admin/startup.lua"] = "startup.lua", ["shopClerk/startup.lua"] = "startup.lua", ["phone/app.lua"] = "startup.lua", ["atm/startup.lua"] = "startup.lua", ["atm/client.lua"] = "startup.lua"
}
local function libFiles()
return { "lib/bankapi.lua", "lib/uilib.lua", "lib/net.lua", "lib/cards.lua" } end
local function updaterFiles()
return { "updater.lua", "ver" } end
local function flatten(list)
local out = {}
for _, v in ipairs(list) do if (type(v) == "table") then for _, p in ipairs(flatten(v)) do table.insert(out, p) end
else table.insert(out, v) end end
return out end
local function filesForRaw(program)
if (program == "server") then return { "server/startup.lua", "server/config.lua", "server/db.lua", "server/menu.lua", libFiles(), updaterFiles() }
elseif (program == "atm") then if (turtle ~= nil) then return { "atm/startup.lua", libFiles(), updaterFiles() }
else return { "atm/client.lua", libFiles(), updaterFiles() } end
elseif (program == "admin") then return { "admin/startup.lua", libFiles(), updaterFiles() }
elseif (program == "shop") then return { "shopClerk/startup.lua", libFiles(), updaterFiles() }
elseif (program == "phone") then return { "phone/app.lua", libFiles(), updaterFiles() }
elseif (program == "installer") then return { "installer.lua", "atm/installer.lua", "atm/bootstrap.lua" }
elseif (program == "updater") then return { "updater.lua", "ver" }
elseif (program == "lang") then return { "lang/languages.lua", "lang/en-us.json", "lang/en-gb.json", "lang/en-au.json", "lang/es-es.json", "lang/de-de.json", "lang/de-at.json", "lang/fr-fr.json", "lang/fr-be.json", "lang/nl-nl.json", "lang/it-it.json", "lang/pt-br.json", "lang/pl-pl.json", "lang/ru-ru.json", "lang/ar-sa.json", "lang/tr-tr.json", "lang/sv-se.json", "lang/ja-jp.json", "lang/zh-cn.json", "lang/ko-kr.json", "lang/hu-hu.json", "lang/fi-fi.json", "lang/da-dk.json", "lang/nb-no.json", "lang/cs-cz.json", "lang/el-gr.json", "lang/ro-ro.json" } end
return nil end
filesFor = function(program)
local files = filesForRaw(program)
if (files == nil) then return nil end
return flatten(files) end
function parseVer(content)
local data = {}
if (content == nil) then return data end
for rawLine in string.gmatch(content.."\n", "(.-)\n") do local line = string.gsub(rawLine, "^%s+", "")
line = string.gsub(line, "%s+$", "")
if (line ~= "" and string.sub(line, 1, 1) ~= "#") then local key, value = string.match(line, "^([%w_]+)%s*=%s*(.*)$")
if (key ~= nil) then value = string.gsub(value, "^\"(.*)\"$", "%1")
value = string.gsub(value, "^'(.*)'$", "%1")
data[key] = value end end end
return data end
function readVer(dir)
if (dir == nil) then dir = "" end
if (not fs.exists(dir.."ver")) then return nil end
local f = fs.open(dir.."ver", "r")
if (f == nil) then return nil end
local content = f.readAll()
f.close()
return parseVer(content) end
function fnv1a(content)
local hash = 2166136261
for i=1, string.len(content) do hash = (hash * 16777619) % 4294967296
hash = bit.bxor(hash, string.byte(content, i)) end
return string.format("%08x", hash) end
function compareVersions(a, b)
local channelRank = { stable = 4, beta = 3, alpha = 2, dev = 1 }
local function split(v)
if (v == nil) then return {0, 0, 0}, "dev" end
local nums, channel = string.match(v, "^([%d%.]+)%-*(%a*)$")
if (nums == nil) then nums, channel = v, "" end
local parts = {}
for part in string.gmatch(nums, "[^.]+") do table.insert(parts, tonumber(part) or 0) end
while (#parts < 3) do table.insert(parts, 0) end
if (channel == "" or channelRank[channel] == nil) then channel = "dev" end
return parts, channel end
local pa, ca = split(a)
local pb, cb = split(b)
for i=1, 3 do if (pa[i] < pb[i]) then return -1 end
if (pa[i] > pb[i]) then return 1 end end
if (channelRank[ca] < channelRank[cb]) then return -1 end
if (channelRank[ca] > channelRank[cb]) then return 1 end
return 0 end
local bankServerID = nil
local function findServer()
if (bankServerID ~= nil) then return bankServerID end
for attempt=1, 5 do rednet.broadcast({ action = "getVersion" }, "mermediamond")
local sender, response = rednet.receive("mermediamond", 3)
if (response ~= nil and response.ver ~= nil) then bankServerID = sender
return sender end end
return nil end
function fetchRemoteVer()
local server = findServer()
if (server == nil) then return nil end
rednet.send(server, { action = "getVersion" }, "mermediamond")
local sender, response = rednet.receive("mermediamond", 5)
if (response ~= nil and response.ver ~= nil) then bankServerID = sender
return response.ver end
return nil end
function updateAvailable()
local localVer = readVer("")
local remoteVer = fetchRemoteVer()
if (remoteVer == nil) then return false, nil, localVer end
if (localVer == nil) then return true, remoteVer, nil end
local cmp = compareVersions(localVer.version, remoteVer.version)
if (cmp ~= 0) then return cmp < 0, remoteVer, localVer end
return (localVer.commit ~= remoteVer.commit or localVer.hash ~= remoteVer.hash), remoteVer, localVer end
local function fetchFile(repoPath)
local server = findServer()
if (server == nil) then return nil end
rednet.send(server, { action = "getfile", path = repoPath, offset = 0 }, "mermediamond")
local _, response = rednet.receive("mermediamond", 10)
if (response == nil or not response.success) then return nil end
local content = response.data or ""
while (response.more) do rednet.send(server, { action = "getfile", path = repoPath, offset = string.len(content) }, "mermediamond")
local _, r2 = rednet.receive("mermediamond", 10)
if (r2 == nil or not r2.success) then return nil end
response = r2
content = content..(r2.data or "") end
return content end
local function fetchFileHTTP(repoPath)
if (http == nil) then return nil end
local response = http.get(getRepoBase().."/"..repoPath)
if (response == nil) then return nil end
local content = response.readAll()
response.close()
return content end
function updateProgram(program, dir)
if (dir == nil) then dir = "" end
local files = flatten(filesFor(program) or {})
if (#files == 0) then return false, "unknown program: "..tostring(program) end
local downloaded = {}
for _, repoPath in ipairs(files) do local content = fetchFile(repoPath)
if (content == nil) then content = fetchFileHTTP(repoPath) end
if (content == nil) then return false, "download failed: "..repoPath end
local localPath = pathMap[repoPath] or repoPath
downloaded[dir..localPath] = content end
for localPath, content in pairs(downloaded) do fs.delete(localPath)
local f = fs.open(localPath, "w")
if (f == nil) then return false, "cannot write "..localPath end
f.write(content)
f.close() end
return true, #downloaded.." file(s) updated" end
function updateLangFiles(dir) return updateProgram("lang", dir) end
function detectProgram(dir)
if (dir == nil) then dir = "" end
if (fs.exists(dir.."catalog.txt") or fs.exists(dir.."owner.txt")) then return "shop" end
if (fs.exists(dir.."phone/app.lua") or fs.exists(dir.."mermeapp.lua")) then return "phone" end
if (fs.exists(dir.."startup.lua")) then local f = fs.open(dir.."startup.lua", "r")
if (f ~= nil) then local firstLine = f.readLine() or ""
f.close()
if (string.find(firstLine, "Bank Server", 1, true) ~= nil) then return "server" end
if (string.find(firstLine, "ATM Terminal", 1, true) ~= nil) then return "atm" end
if (string.find(firstLine, "ATM Assistant", 1, true) ~= nil) then return "atm" end
if (string.find(firstLine, "Admin Terminal", 1, true) ~= nil) then return "admin" end
if (string.find(firstLine, "Store clerk", 1, true) ~= nil) then return "shop" end
if (string.find(firstLine, "Mobile app", 1, true) ~= nil) then return "phone" end
if (turtle ~= nil) then return "atm" end
return "admin" end end
return nil end
function serveFileChunk(path, offset)
if (path == nil) then return false, "no path" end
local allowed = {}
local allPrograms = { "server", "atm", "admin", "shop", "phone", "installer", "updater", "lang" }
for _, program in ipairs(allPrograms) do for _, p in ipairs(flatten(filesFor(program) or {})) do allowed[p] = true end end
if (not allowed[path]) then return false, "not allowed: "..tostring(path) end
local candidates = { path }
if (pathMap[path] ~= nil) then table.insert(candidates, pathMap[path]) end
for _, localPath in ipairs(candidates) do if (fs.exists(localPath)) then local f = fs.open(localPath, "r")
if (f ~= nil) then f.seek("set", offset or 0)
local chunk = f.read(2000) or ""
local rest = f.readAll() or ""
f.close()
return true, { data = chunk, more = (string.len(rest) > 0) } end end end
return false, "not found: "..tostring(path) end
function autoUpdate(program, silent)
if (rednet == nil or not rednet.isOpen()) then return false end
local ok, available, remoteVer, localVer = pcall(updateAvailable)
if (not ok or not available) then return false end
if (silent) then program = program or detectProgram("")
if (program == nil) then return false end
local okU, _ = updateProgram(program, "")
if (okU) then os.reboot() end
return false end
term.setBackgroundColor(colors.black)
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("== Mermediamond update available! ==")
print("")
print("Installed: "..tostring(localVer and localVer.version or "unknown").." ("..tostring(localVer and localVer.commit or "?")..")")
print("Available: "..tostring(remoteVer and remoteVer.version or "unknown").." ("..tostring(remoteVer and remoteVer.commit or "?")..")")
print("")
print("Update now? [Y/N]")
while (true) do local event, key = os.pullEvent("key")
local name = keys.getName(key)
if (name == "y" or name == "enter") then program = program or detectProgram("")
if (program == nil) then return false end
print("")
print("Updating "..program.."...")
local okU, result = updateProgram(program, "")
if (okU) then print(result)
print("Rebooting...")
sleep(1)
os.reboot()
else print("Update failed: "..tostring(result))
sleep(3) end
return true
elseif (name == "n" or name == "escape") then return false end end end
return { parseVer = parseVer, readVer = readVer, fnv1a = fnv1a, compareVersions = compareVersions, fetchRemoteVer = fetchRemoteVer, updateAvailable = updateAvailable, updateProgram = updateProgram, updateLangFiles = updateLangFiles, detectProgram = detectProgram, servedFileChunk = nil, serveFileChunk = serveFileChunk, autoUpdate = autoUpdate, filesFor = filesFor }
