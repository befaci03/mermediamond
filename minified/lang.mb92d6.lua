local function getLangDir()
local candidates = {
"./lang/", "../lang/", "../../lang/", "../../../lang/", "disk/lang/", "/lang/"
}
for _, dir in ipairs(candidates) do if fs.isDir(dir) then return dir end end
return "./lang/" end
local langDir = getLangDir()
local cache = {}
local memo = {}
local persistedSettings = ".mermediamond/settings"
if (fs.exists(persistedSettings) and not settings.get("langLoaded")) then settings.load(persistedSettings)
settings.set("langLoaded", true) end
local aliases = {
en = "en-us", ["en-uk"] = "en-gb", uk = "en-gb", au = "en-au", es = "es-es", de = "de-de", at = "de-at", fr = "fr-fr", be = "fr-be", pl = "pl-pl", nl = "nl-nl", it = "it-it", pt = "pt-br", br = "pt-br", ru = "ru-ru", ar = "ar-sa", sa = "ar-sa", tr = "tr-tr", sv = "sv-se", se = "sv-se", zh = "zh-cn", cn = "zh-cn", ko = "ko-kr", kr = "ko-kr", hu = "hu-hu", fi = "fi-fi", da = "da-dk", dk = "da-dk", no = "nb-no", nb = "nb-no", cs = "cs-cz", cz = "cs-cz", el = "el-gr", gr = "el-gr", ro = "ro-ro"
}
local function normalizeLang(lang)
if (lang == nil) then return nil end
lang = string.lower(lang)
if (aliases[lang] ~= nil) then return aliases[lang] end
return lang end
local function loadLang(lang)
lang = normalizeLang(lang)
if (lang == nil) then return nil end
if (cache[lang] ~= nil) then return cache[lang] end
local file = fs.open(langDir .. lang .. ".json", "r")
if file then local data = file.readAll()
file.close()
local parsed = textutils.unserialiseJSON(data)
if (parsed ~= nil) then cache[lang] = parsed end
return parsed end
return nil end
local tk
local function resolve(table, sel)
if (table == nil) then return nil end
if (sel == nil or sel == "") then return nil end
local current = table
for part in string.gmatch(sel, "[^.]+") do if (type(current) ~= "table") then return nil end
current = current[part]
if (current == nil) then return nil end end
return current end
function tk(lang, sel)
if (sel == nil) then sel = lang
lang = _G.activeLang or settings.get("lang") or "en-us" end
lang = normalizeLang(lang)
if (lang == nil) then lang = "en-us" end
local langMemo = memo[lang]
if (langMemo ~= nil) then local hit = langMemo[sel]
if (hit ~= nil) then return hit end
else langMemo = {}
memo[lang] = langMemo end
local langTable = loadLang(lang)
if (langTable == nil) then lang = "en-us"
langTable = loadLang(lang)
local fallbackMemo = memo[lang]
if (fallbackMemo ~= nil) then local hit = fallbackMemo[sel]
if (hit ~= nil) then return hit end end end
local value = resolve(langTable, sel)
if (value == nil) then return sel end
memo[lang][sel] = value
return value end
local active = normalizeLang(_G.activeLang or settings.get("lang") or "en-us")
local loadedLang = loadLang(active)
if (loadedLang == nil) then loadedLang = loadLang("en-us") end
if (loadedLang ~= nil) then for k, v in pairs(loadedLang) do _G[k] = v end end
_G.tk = tk
return tk
