-- Store clerk

-------------------- Start
print("Finding ender modem...")
peripheral.find("modem", rednet.open)
print("Modem found!")
local diskdrive = peripheral.find("drive")
os.loadAPI("bankapi.lua")
local serverData = bankapi.getServerData()
local lang = serverData.lang

local text_error_noconnection = "Can't connect to server"
--------------------------

local owner = nil
local ownerView = false
local catalog = {}
local caralogueDirty = false
local backgroundColor = colors.gray

local currentAccount = 0

local localization = {
	en={
		claimed={"You are now the owner", "of this machine"},
		invalid_card="Invalid card",
		unregistered_disk="The inserted disk is not registered",
		insert_card_to_configure="Insert a card to configure",
		registering_payment={"Registering payment. Please wait.","Do not remove the items","from my inventory yet..."},
		purchase_canceled="Purchase cancelled",
		foul_play={"","","Dont remove or add items","while I'm counting.","Please try again."},
		thanks_for_shopping_at="Thanks for buying at ",
		items_ready={"You can now take your items","from the chest"},
		please_return_items={"Please return the items","to their places before leaving."},
		come_again="Come again!",
		add_item_steps={
			"Products to register",
			"Product name",
			"Price",
			"Amount"
		},
		add_item_instructions={"Put one or more items in", "my inventory, and then press", "accept to continue"},
		detected_items=" Detected items ",
		various="<various>",
		register_confirm="Register these products?",
		register_complete="Product registered",
		button_editname="Edit name",
		button_editprice="Edit price",
		button_editcount="Edit amount",
		button_remove="Remove",
		button_back="Back",
		choose_item_name="Choose item's name",
		rename_successful="Item successfully renamed",
		choose_item_price="Choose item's price",
		reprice_successful="Price changed successfully",
		choose_item_count="Choose item amount",
		recount_successful="Amount changed successfully",
		remove_confirm={"Are you sure you want","to remove this item?"},
		remove_successful="Item removed successfully",
		add_items="Add item(s)",
		edit_shop_name="Edit shop name",
		edit_catalog="Edit catalog",
		resign="Resign as owner",
		quit="Exit",
		choose_shop_name="Choose shop name",
		shop_renamed_to="Shop renamed to ",
		resign_confirm={"Do you want to resign", "as the owner of this machine?"},
		resign_successful="Successfully resigned as owner.",
		see_you_later="See you later!",
		see_catalog="View catalog",
		buy="Buy",
		cant_buy_missing_card={
			"To buy, insert a Mermegold",
			"card into the disk drive."
		},
		buy_instructions={"Put the items you want to buy", "into my inventory"},
		your_balance="Your balance",
		total_price="Total price",
		final_balance="Final balance",
		buy_and_continue="Buy and continue",
		buy_and_quit="Buy and exit",
		cancel="Cancel",
		thanks_come_again="Thank you! Come again!",
		default_shop_name="Shop"
	},
	es={
		claimed="Ahora eres el propietario de esta maquina",
		invalid_card="Tarjeta invalida",
		unregistered_disk="El disco ingresado no esta registrado",
		insert_card_to_configure="Inserte tarjeta para configurar",
		registering_payment={"Registrando pago. Espere por favor.","No tome los articulos","de mi inventario todavia..."},
		purchase_canceled="Compra cancelada",
		foul_play={"","","No quite ni agregue articulos","a mi inventario mientras cuento.","Por favor intente nuevamente."},
		thanks_for_shopping_at="Gracias por comprar en",
		items_ready={"Ya puede llevarse su","compra del cofre"},
		please_return_items={"Por favor devuelva los articulos","a su lugar antes de irse."},
		come_again="Vuelva pronto!",
		add_item_steps={
			"Productos a registrar",
			"Nombre de estos productos",
			"Precio",
			"Cantidad"
		},
		add_item_instructions={"Ingresa uno o mas productos en", "mi inventario, y luego presiona", "aceptar para continuar"},
		detected_items=" Articulos detectados ",
		various="<varios>",
		register_confirm="Quieres registrar estos productos?",
		register_complete="Producto registrado",
		button_editname="Editar nombre",
		button_editprice="Editar precio",
		button_editcount="Editar cantidad",
		button_remove="Remover",
		button_back="Volver",
		choose_item_name="Elija el nombre del articulo",
		rename_successful="Articulo renombrado con exito",
		choose_item_price="Elija el precio del articulo",
		reprice_successful="Precio cambiado con exito",
		choose_item_count="Elija la cantidad del articulo",
		recount_successful="Cantidad cambiada con exito",
		remove_confirm={"Esta seguro que quiere","remover este articulo?"},
		remove_successful="Articulo removido con exito",
		add_items="Agregar articulo(s)",
		edit_shop_name="Editar nombre de la tienda",
		edit_catalog="Editar catalogo",
		resign="Renunciar como propietario",
		quit="Salir",
		choose_shop_name="Elija el nombre del local",
		shop_renamed_to="Local renombrado a ",
		resign_confirm={"Deseas desasignarte como", "propietario de esta maquina?"},
		resign_successful="Te desasignaste como propietario.",
		see_you_later="Hasta luego!",
		see_catalog="Ver catalogo",
		buy="Comprar",
		cant_buy_missing_card={
			"Para comprar, ingrese su tarjeta",
			"Mermegold en la disquetera."
		},
		buy_instructions={"Ingrese los articulos que quiera", "comprar dentro de mi inventario"},
		your_balance="Tu Balance",
		total_price="Precio Total",
		final_balance="Balance Final",
		buy_and_continue="Comprar y seguir",
		buy_and_quit="Comprar y salir",
		cancel="Cancelar",
		thanks_come_again="Gracias! Vuelva pronto!",
		default_shop_name="Tienda"
	},
	de = {
		claimed = {"Du bist jetzt der Besitzer", "dieser Maschine"},
		invalid_card = "Ungueltige Karte",
		unregistered_disk = "Die eingelegte Karte ist nicht registriert",
		insert_card_to_configure = "Karte einlegen, um zu konfigurieren",
		registering_payment = {"Zahlung wird registriert. Bitte warten.", "Noch keine Gegenstaende", "aus meinem Inventar entfernen..."},
		purchase_canceled = "Kauf abgebrochen",
		foul_play = {"", "", "Bitte keine Gegenstaende entfernen oder hinzufuegen,", "waehrend ich zaehle.", "Versuche es noch einmal."},
		thanks_for_shopping_at = "Danke fuer deinen Einkauf bei ",
		items_ready = {"Du kannst deine Gegenstaende", "jetzt aus der Truhe nehmen"},
		please_return_items = {"Bitte lege die Gegenstaende", "vor dem Verlassen wieder zurueck."},
		come_again = "Komm bald wieder!",
		add_item_steps = {
			"Zu registrierende Produkte",
			"Produktname",
			"Preis",
			"Anzahl"
		},
		add_item_instructions = {"Lege einen oder mehrere Gegenstaende", "in mein Inventar und druecke dann", "auf 'Bestaetigen', um fortzufahren"},
		detected_items = " Erkannte Gegenstaende ",
		various = "<verschiedenes>",
		register_confirm = "Diese Produkte registrieren?",
		register_complete = "Produkt registriert",
		button_editname = "Name bearbeiten",
		button_editprice = "Preis bearbeiten",
		button_editcount = "Anzahl bearbeiten",
		button_remove = "Entfernen",
		button_back = "Zurueck",
		choose_item_name = "Waehle einen Namen fuer den Gegenstand",
		rename_successful = "Name erfolgreich geaendert",
		choose_item_price = "Waehle einen Preis fuer den Gegenstand",
		reprice_successful = "Preis erfolgreich geaendert",
		choose_item_count = "Waehle eine Anzahl fuer den Gegenstand",
		recount_successful = "Anzahl erfolgreich geaendert",
		remove_confirm = {"Moechtest du diesen Gegenstand", "wirklich entfernen?"},
		remove_successful = "Gegenstand erfolgreich entfernt",
		add_items = "Gegenstand/Gegenstaende hinzufuegen",
		edit_shop_name = "Shopnamen bearbeiten",
		edit_catalog = "Katalog bearbeiten",
		resign = "Als Besitzer zuruecktreten",
		quit = "Beenden",
		choose_shop_name = "Waehle einen Shopnamen",
		shop_renamed_to = "Shop umbenannt in ",
		resign_confirm = {"Moechtest du wirklich", "als Besitzer dieser Maschine zuruecktreten?"},
		resign_successful = "Erfolgreich als Besitzer zurueckgetreten.",
		see_you_later = "Bis bald!",
		see_catalog = "Katalog ansehen",
		buy = "Kaufen",
		cant_buy_missing_card = {
			"Zum Kauf bitte eine Mermegold-Karte",
			"in das Laufwerk einlegen."
		},
		buy_instructions = {"Lege die Gegenstaende, die du kaufen moechtest,", "in mein Inventar"},
		your_balance = "Dein Kontostand",
		total_price = "Gesamtpreis",
		final_balance = "Restguthaben",
		buy_and_continue = "Kaufen und weitermachen",
		buy_and_quit = "Kaufen und beenden",
		cancel = "Abbrechen",
		thanks_come_again = "Danke! Komm bald wieder!",
		default_shop_name = "Shop"
	}
}

local shopName = localization[lang].default_shop_name

if (not fs.exists("owner.txt")) then
	if (diskdrive.isDiskPresent()) then
		local tempClientData = bankapi.getClientData()
		local f = fs.open("disk/mermegold.txt", "r")
		if (f ~= nil) then
			local key = f.readLine()
			if (tempClientData[key] ~= nil) then
				local cf = fs.open("owner.txt", "w")
				cf.writeLine(key)
				cf.close()
				bankapi.successScreen(localization[lang].claimed)
			else
				bankapi.errorScreen(localization[lang].invalid_card)
			end
		else
			bankapi.errorScreen(localization[lang].unregistered_disk)
		end
		f.close()
		os.reboot()
	else
		bankapi.errorScreen(localization[lang].insert_card_to_configure)
		os.shutdown()
	end
else
	local f = fs.open("owner.txt", "r")
	owner = f.readLine()
	f.close()
end

local currentAccount = 0

local function readDisk()
	if (fs.exists("disk")) then
		local f = fs.open("disk/mermegold.txt", "r")
		if (f ~= nil) then
			local value = f.readLine()
			if (value ~= nil) then
				local tempClientData = bankapi.getClientData()
				if (tempClientData[value] ~= nil) then
					currentAccount = value
				else
					currentAccount = 0
				end
			end
			f.close()
		end
	end
end

readDisk()

local function loadShopName()
	local f = fs.open("shopname.txt", "r")
	if (f ~= nil) then
		local value = f.readLine()
		if (value ~= nil) then
			shopName = value
		end
		f.close()
	else
		local f = fs.open("shopname.txt", "w")
		f.writeLine("Tienda")
		f.close()
	end
end

local function loadCatalog()
	local f = fs.open("catalog.txt", "r")
	if (f ~= nil) then
		catalog = {}
		local line = f.readLine()
		while line ~= nil do
			local lline = line
			local item = ""
			local damage = 0
			local count = 0
			local price = 0
			local name = ""

			while lline ~= "" and lline ~= nil do
				if (lline == "item") then
					item = f.readLine()
				elseif (lline == "damage") then
					damage = tonumber(f.readLine())
				elseif (lline == "count") then
					count = tonumber(f.readLine())
				elseif (lline == "price") then
					price = tonumber(f.readLine())
				elseif (lline == "name") then
					name = f.readLine()
				end
				lline = f.readLine()
			end

			if (catalog[item] == nil) then
				catalog[item] = {}
			end
			catalog[item][damage] = {
				count=count,
				price=price,
				name=name
			}

			line = f.readLine()
		end

		f.close()
	else
		local f = fs.open("catalog.txt", "w")
		f.close()
	end
end

local function updateCatalog()
	caralogueDirty = true
	local f = fs.open("catalog.txt", "w")
	for name, damagetypes in pairs(catalog) do
		print(name, damagetypes)
		for damage, detail in pairs(damagetypes) do
			print(damage, detail)
			for k, v in pairs(detail) do
				print(k, v)
			end
			f.writeLine("item")
			f.writeLine(name)
			f.writeLine("damage")
			f.writeLine(tostring(damage))
			f.writeLine("count")
			f.writeLine(tostring(detail.count))
			f.writeLine("name")
			f.writeLine(detail.name)
			f.writeLine("price")
			f.writeLine(tostring(detail.price))
			f.writeLine("")
		end
	end
	f.close()
end

local function printWithPadding(x, leftText, rightText, newLine, color, dotColor)
	local scrW, scrH = term.getSize()
	leftText = string.rep(" ", x-1)..leftText
	if (newLine == nil) then newLine = true end
	local space = string.len(leftText)+string.len(rightText)
	local padding = scrW-space
	local paddingText = ""
	if (padding > 0) then
		paddingText = string.rep(".", padding)
	else
		leftText = string.sub(leftText, 1, string.len(leftText)+padding-1)
		paddingText = "."
	end
	if (color == nil) then
		term.setTextColor(colors.white)
	else
		term.setTextColor(color)
	end
	if (dotColor == nil) then dotColor = colors.gray end
	term.write(leftText)
	term.setTextColor(dotColor)
	term.write(paddingText)
	if (color == nil) then
		term.setTextColor(colors.white)
	else
		term.setTextColor(color)
	end
	term.write(rightText)
	if (newLine) then
		print("")
	end
end

local function buy(previousEstimatedPrice)
	local scrW, scrH = term.getSize()
	bankapi.waitScreen(localization[lang].registering_payment)

	local buyingItems = {}
	for i=1, 16 do
		turtle.select(i)
		local detail = turtle.getItemDetail(i)
		turtle.drop()
		if (detail ~= nil) then
			local item = detail.name
			if (catalog[item] ~= nil) then
				local damage = detail.damage
				if detail.damage == nil then
					damage = 1
				end
				if (catalog[item][damage] ~= nil) then
					local product = catalog[item][damage]

					if (buyingItems[item] == nil) then
						buyingItems[item] = {}
					end
					if (buyingItems[item][damage] == nil) then
						buyingItems[item][damage] = detail.count
					else
						buyingItems[item][damage] = buyingItems[item][damage]+detail.count
					end
				end
			end
		end
	end

	local totalPrice = 0

	local totalReceitDescription = shopName..": "

	for item, damagetypes in pairs(buyingItems) do
		for damage, count in pairs(damagetypes) do
			local product = catalog[item][damage]
			local estimatedPrice = math.ceil(count*product.price/product.count)
			totalPrice = totalPrice+estimatedPrice
			totalReceitDescription = totalReceitDescription.." "..product.name.." x"..count.." ($"..estimatedPrice..") |"
		end
	end

	if (previousEstimatedPrice ~= totalPrice) then
		bankapi.waitScreen(localization[lang].purchase_canceled)
		while (turtle.suck()) do
		end
		bankapi.textScreen(localization[lang].foul_play)
	else
		bankapi.transaction(currentAccount, owner, totalPrice, totalReceitDescription)
		bankapi.successScreen({localization[lang].thanks_for_shopping_at, shopName.."!"})
		bankapi.successScreen(localization[lang].items_ready)
	end
end

local function logout()
	for i=1, 16 do
		local detail = turtle.getItemDetail(i)
		if (detail ~= nil) then
			bankapi.waitScreen(localization[lang].please_return_items)
			diskdrive.ejectDisk()
			sleep(2.5)
			break
		end
	end
	diskdrive.ejectDisk()
	bankapi.successScreen(localization[lang].come_again)
	os.shutdown()
end

local function addItemToCatalog()
	turtle.select(1)
	local steps = localization[lang].add_item_steps
	local count
	local returning = false
	local totalItems
	repeat 
		count = {}
		local accept = bankapi.confirmScreen(localization[lang].add_item_instructions, {}, steps, 1)
		if (not accept) then
			returning = true
			break
		end
		totalItems = 0
		for i=1, 16 do
			local itemCount = turtle.getItemCount(i)
				if (itemCount > 0) then
				count[i] = itemCount
				totalItems = totalItems+itemCount
			end
		end
	until totalItems > 0
	if (returning) then return end

	local detail = {}
	local itemList = {}
	itemList[1] = string.char(31)..localization[lang].detected_items..string.char(31)

	for i=1, 16 do
		local itemDetail = turtle.getItemDetail(i)
		if (itemDetail ~= nil) then
			detail[i] = itemDetail
			if (i < 9) then
				itemList[i+1] = itemDetail.name
			elseif (i == 9) then
				itemList[i+1] = "..."
			end
		end
	end

	bankapi.waitScreen(itemList)
	local continueButton = bankapi.drawContinueButton()
	os.pullEvent("mouse_click")

	local name = bankapi.inputTextScreen(steps, 2)
	if (name == nil) then return end

	local price = bankapi.inputNumberScreen(steps, 3)
	if (price == nil) then return end

	local count = bankapi.inputNumberScreen(steps, 4)
	if (count == nil) then return end

	local displayName = nil
	local oneName = true
	local set = false
	for k, v in pairs(detail) do
		if (not set) then
			displayName = v.name
			set = true
		else
			if (displayName ~= v.name) then
				oneName = false
				displayName = localization[lang].various
			end
		end
	end

	local confirmData = {
		name = name,
		product = displayName,
		quantity = "x"..count,
		price = "$"..price
	}
	local accept = bankapi.confirmScreen({localization[lang].register_confirm}, confirmData)
	if (not accept) then return end

	for k, v in pairs(detail) do
		if (catalog[v.name] == nil) then
			catalog[v.name] = {}
		end
		local damage = v.damage
		if v.damage == nil then
			damage = 1
		end
		catalog[v.name][damage] = {
			["name"] = name,
			["count"] = tonumber(count),
			["price"] = tonumber(price)
		}
	end

	updateCatalog()

	bankapi.successScreen(localization[lang].register_complete)
end

local function editItem(itemID)
	local item = catalog[itemID.name][itemID.damage]
	while (true) do
		local command = bankapi.optionMenu(item.name, {
			[1] = {
			["option"] = "editname",
			["text"] = localization[lang].button_editname},
			[2] = {
			["option"] = "editprice",
			["text"] = localization[lang].button_editprice},
			[3] = {
			["option"] = "editcount",
			["text"] = localization[lang].button_editcount},
			[4] = {
			["option"] = "remove",
			["text"] = localization[lang].button_remove},
			[5] = {
			["option"] = "back",
			["text"] = localization[lang].button_back},
		})

		if (command == "editname") then
			local newname = bankapi.inputTextScreen({localization[lang].choose_item_name}, 1, 30)
			if (newname ~= nil) then
				catalog[itemID.name][itemID.damage].name = newname
				updateCatalog()
				bankapi.successScreen(localization[lang].rename_successful)
			end
		elseif(command == "editprice") then
			local newprice = bankapi.inputNumberScreen({localization[lang].choose_item_price}, 1)
			if (newprice ~= nil) then
				catalog[itemID.name][itemID.damage].price = tonumber(newprice)
				updateCatalog()
				bankapi.successScreen(localization[lang].reprice_successful)
			end
		elseif(command == "editcount") then
			local newcount = bankapi.inputNumberScreen({localization[lang].choose_item_count}, 1)
			if (newcount ~= nil) then
				catalog[itemID.name][itemID.damage].count = tonumber(newcount)
				updateCatalog()
				bankapi.successScreen(localization[lang].recount_successful)
			end
		elseif(command == "remove") then
			local confirm = bankapi.confirmScreen(localization[lang].remove_confirm, {item_name=item.name})
			if (confirm) then
				term.setBackgroundColor(colors.black)
				catalog[itemID.name][itemID.damage] = nil
				updateCatalog()
				bankapi.successScreen(localization[lang].remove_successful)
				return
			end
		elseif(command == "back") then
			return
		end
	end
end

local function displayCatalogItem(item, x, y, w)
	term.setCursorPos(x,y)
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.gray)
	term.write(string.rep(string.char(131), w))
	term.setCursorPos(x,y+1)
	term.setTextColor(colors.lightGray)
	term.write(" ")
	term.write(string.rep(".", w-2))
	term.write(" ")
	term.setCursorPos(x+1,y+1)
	term.setTextColor(colors.black)
	term.write(item.name)
	local text = "$"..item.price
	if (item.count > 1) then
		text = item.count.." x $"..item.price
	end
	term.setCursorPos(x+w-string.len(text)-1,y+1)
	term.write(text)
end

local function displayCatalog(edit)
	local scrW, scrH = term.getSize()
	local first = 0

	if (caralogueDirty) then
		loadCatalog()
	end

	while (true) do

		local encounteredItems = {}

		term.setBackgroundColor(backgroundColor)
		term.clear()

		local row = 0
		local max = 5
		local buttons = {}
		local total = 0
		local width = scrW-2
		if (edit) then 
			max = 4
			width = scrW-7
		end
		for name, damagetypes in pairs(catalog) do
			for damage, detail in pairs(damagetypes) do
				if (total >= first and total < first+max) then
					if (encounteredItems[detail.name]) == nil then
						term.setBackgroundColor(backgroundColor)
						displayCatalogItem(detail, 2, row*2+1, width)
						if (edit) then
							term.setBackgroundColor(colors.cyan)
							term.setTextColor(backgroundColor)
							term.setCursorPos(scrW-5, row*2+1)
							term.write(string.rep(string.char(143), 5))
							term.setBackgroundColor(colors.cyan)
							term.setTextColor(colors.white)
							term.setCursorPos(scrW-5, row*2+2)
							term.write(" Edit")
							buttons[row*2+1] = {name=name, damage=damage}
							buttons[row*2+2] = {name=name, damage=damage}
						end
						row = row+1
					end
				end
				total = total+1
				encounteredItems[detail.name] = true
			end
		end

		local backButton = bankapi.drawBackButton()

		local prevPage = bankapi.drawButton(colors.yellow, colors.orange, colors.black, 16, scrH-1, 7, string.char(27))
		if (first <= 0) then
			bankapi.drawButton(colors.lightGray, colors.gray, colors.gray, 16, scrH-1, 7, string.char(27))
		end

		local nextPage = bankapi.drawButton(colors.yellow, colors.orange, colors.black, 32, scrH-1, 7, string.char(26))
		if (first+max >= total) then
			bankapi.drawButton(colors.lightGray, colors.gray, colors.gray, 32, scrH-1, 7, string.char(26))
		end

		local addButton
		if (edit) then
			addButton = bankapi.drawButton(colors.lime, colors.green, colors.black, 2, scrH-3, scrW-2, localization[lang].add_items)
		end

		-- page indicator
		local pages = math.max(1,math.ceil(total/max))
		local pageText = tostring((first/max)+1).."/"..pages
		term.setCursorPos(28-string.len(pageText)/2, scrH-1)
		term.setBackgroundColor(backgroundColor)
		term.setTextColor(colors.orange)
		term.write(pageText)

		local eventData = {os.pullEvent()}
		local event = eventData[1]

		if event == "mouse_click" then
			local cx = eventData[3]
			local cy = eventData[4]
			if (edit and bankapi.mouseInButton(addButton, cx, cy)) then
				addItemToCatalog()
			end
			if (bankapi.mouseInButton(prevPage, cx, cy)) then
				if (first > 0) then
					first = first-max
				end
			end
			if (bankapi.mouseInButton(nextPage, cx, cy)) then
				if (first+max < total) then
					first = first+max
				end
			end
			if (bankapi.mouseInButton(backButton, cx, cy)) then
				return nil
			end
			if buttons[cy] ~= nil then
				local itemID = buttons[cy]
				editItem(itemID)
			end
		elseif event == "mouse_scroll" then
			local scroll = eventData[2]
			if (scroll < 0) then
				if (first > 0) then
					first = first-max
				end
			else
				if (first+max < total) then
					first = first+max
				end
			end
		end
	end
end

local function noCardScreen()
	displayCatalog()
	os.shutdown()
end

loadShopName()
loadCatalog()

while true do -- Second while to allow the use of breaks as continues
	ownerView = owner == currentAccount
	breaking = false
	while true do
		
		if (ownerView) then
			while true do -- Sub menu
				local command = bankapi.optionMenu(shopName, {
					[1] = {
					["option"] = "name",
					["text"] = localization[lang].edit_shop_name},
					[2] = {
					["option"] = "catalog",
					["text"] = localization[lang].edit_catalog},
					[3] = {
					["option"] = "resign",
					["text"] = localization[lang].resign},
					[4] = {
					["option"] = "quit",
					["text"] = localization[lang].quit},
				})

				if (command == "name") then
					local newname = bankapi.inputTextScreen({localization[lang].choose_shop_name}, 1, 30)
					if (newname ~= nil) then
						shopName = newname
						os.setComputerLabel(newname)
			
						local f = fs.open("shopname.txt", "w")
						f.writeLine(shopName)
						f.close()
			
						bankapi.successScreen(localization[lang].shop_renamed_to..shopName)
					end

				elseif (command == "catalog") then
					displayCatalog(true)

				elseif (command == "resign") then
					local accept = bankapi.confirmScreen(localization[lang].resign_confirm)
					if (accept) then
						fs.delete("owner.txt")
						diskdrive.ejectDisk()
						bankapi.successScreen(localization[lang].resign_successful)
						os.shutdown()
					end
				
				elseif (command == "quit") then
					diskdrive.ejectDisk()
					bankapi.successScreen(localization[lang].see_you_later)
					os.shutdown()
					break
				end

			end
		else -- Valid account
			while true do -- Sub menu
				local command = bankapi.optionMenu(shopName, {
					[1] = {
					["option"] = "catalog",
					["text"] = localization[lang].see_catalog},
					[2] = {
					["option"] = "buy",
					["text"] = localization[lang].buy},
					[3] = {
					["option"] = "quit",
					["text"] = localization[lang].quit},
				})

				if (command == "catalog") then
					displayCatalog()
				elseif (command == "buy") then
					while (true) do
						readDisk()
						if (currentAccount == 0) then -- Invalid client
							bankapi.waitScreen(localization[lang].cant_buy_missing_card)
							local backButton = bankapi.drawBackButton()
							while (true) do
								local eventData = {os.pullEvent()}
								local event = eventData[1]
								if (event == "mouse_click") then
									local cx = eventData[3]
									local cy = eventData[4]
									if (bankapi.mouseInButton(backButton, cx, cy)) then
										breaking = true
										break
									end
								elseif (event == "disk") then
									break
								end
							end
							readDisk()
						else -- Valid client
							local scrW, scrH = term.getSize()
							local tempClientData = bankapi.getClientData()
							local first = 0
							while true do
								term.setBackgroundColor(backgroundColor)
								term.clear()
								local buyingItems = {}
								for i=1, 16 do
									local detail = turtle.getItemDetail(i)
									if (detail ~= nil) then
										local item = detail.name
										if (catalog[item] ~= nil) then
											local damage = detail.damage
											if detail.damage == nil then
												damage = 1
											end
											if (catalog[item][damage] ~= nil) then
												local product = catalog[item][damage]

												if (buyingItems[item] == nil) then
													buyingItems[item] = {}
												end
												if (buyingItems[item][damage] == nil) then
													buyingItems[item][damage] = detail.count
												else
													buyingItems[item][damage] = buyingItems[item][damage]+detail.count
												end
											end
										end
									end
								end

								local totalPrice = 0

								local encounteredItems = {}
						
								local row = 0
								local max = 4

								local total = 0
								for name, damagetypes in pairs(buyingItems) do
									for damage, detail in pairs(damagetypes) do
										local product = catalog[name][damage]
										local count = buyingItems[name][damage]
										local estimatedPrice = math.ceil(count*product.price/product.count)
										if (total >= first and total < first+max) then
											--if (encounteredItems[name]) == nil then
												displayCatalogItem({name=product.name, price=estimatedPrice, count=count}, 2, row*2+1, scrW-2)
												row = row+1
											--end
										end
										totalPrice = totalPrice+estimatedPrice
										total = total+1
										encounteredItems[name] = true
									end
								end

								if (total == 0) then
									bankapi.waitScreen(localization[lang].buy_instructions)
								end
						
								local backButton = bankapi.drawBackButton()
						
								local balance = tempClientData[currentAccount].balance
								local prevPage, nextPage = nil
								
								if (total > 0) then
									prevPage = bankapi.drawButton(colors.yellow, colors.orange, colors.black, 20, scrH-4, 7, string.char(27))
									if (first <= 0) then
										bankapi.drawButton(colors.lightGray, colors.gray, colors.gray, 20, scrH-4, 7, string.char(27))
									end
							
									nextPage = bankapi.drawButton(colors.yellow, colors.orange, colors.black, 32, scrH-4, 7, string.char(26))
									if (first+max >= total) then
										bankapi.drawButton(colors.lightGray, colors.gray, colors.gray, 32, scrH-4, 7, string.char(26))
									end

								
									-- page indicator
									local pages = math.max(1,math.ceil(total/max))
									local pageText = tostring((first/max)+1).."/"..pages
									term.setCursorPos(30-string.len(pageText)/2, scrH-4)
									term.setBackgroundColor(backgroundColor)
									term.setTextColor(colors.orange)
									term.write(pageText)
								

									print("")
									print("")

									term.setCursorPos(1, scrH-2)
									term.setTextColor(colors.lightGray)
									term.setBackgroundColor(backgroundColor)

									printWithPadding(20, localization[lang].your_balance, "$"..balance, true, colors.white, colors.lightGray)
									printWithPadding(20, localization[lang].total_price, "$"..totalPrice, nil, colors.white, colors.lightGray)
									local finalBalance = balance-totalPrice
									if (finalBalance < 0) then
										printWithPadding(20, localization[lang].final_balance, "$"..finalBalance, false, colors.red, colors.lightGray)
									else
										printWithPadding(20, localization[lang].final_balance, "$"..finalBalance, false, colors.white, colors.lightGray)
									end
								end

								local buyButton, buyAndExitButton = nil
								if (total > 0 and totalPrice <= balance) then
									buyButton = bankapi.drawButton(colors.lime, colors.green, colors.black, 1, scrH-3, 18, localization[lang].buy_and_continue)
									buyAndExitButton = bankapi.drawButton(colors.yellow, colors.orange, colors.black, 1, scrH-2, 18, localization[lang].buy_and_quit)
								end
								local cancelButton = bankapi.drawButton(colors.red, colors.brown, colors.black, 1, scrH-1, 18, localization[lang].cancel)


								while true do
									local eventData = {os.pullEvent()}
									local event = eventData[1]
									if event == "mouse_click" then
										local cx = eventData[3]
										local cy = eventData[4]
										if (total > 0) then
											if (bankapi.mouseInButton(prevPage, cx, cy)) then
												if (first > 0) then
													first = first-max
													break
												end
											end
											if (bankapi.mouseInButton(nextPage, cx, cy)) then
												if (first+max < total) then
													first = first+max
													break
												end
											end
										end
										if (bankapi.mouseInButton(cancelButton, cx, cy)) then
											breaking = true
											break
										end
										if (totalPrice > 0 and totalPrice < balance and total >= 0) then
											if (bankapi.mouseInButton(buyButton, cx, cy)) then
												buy(totalPrice)
												break
											end
											if (bankapi.mouseInButton(buyAndExitButton, cx, cy)) then
												buy(totalPrice)
												logout()
												break
											end
										end
										if (bankapi.mouseInButton(cancelButton, cx, cy)) then
											logout()
										end
									elseif event == "mouse_scroll" then
										if (total > 0) then
											local scroll = eventData[2]
											if (scroll < 0) then
												if (first > 0) then
													first = first-max
													break
												end
											else
												if (first+max < total) then
													first = first+max
													break
												end
											end
										end
									elseif (event == "turtle_inventory") then
										if (first > 1 and first >= total-1) then
											first = first-max
										end
										break
									end
								end
								if (breaking) then break end
							end
						end			
						if (breaking) then break end
					end
				elseif (command == "quit") then
					diskdrive.ejectDisk()
					bankapi.successScreen(localization[lang].thanks_come_again)
					os.shutdown()
					break
				end
			end
		end
	end
end
