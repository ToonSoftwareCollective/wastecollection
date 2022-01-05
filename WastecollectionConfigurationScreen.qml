import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0
import FileIO 1.0

Screen {
	id: wasteConfigurationScreen

	property string helpText
	property url providerUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/wastecollection_plugins/main/plugin_index.json"
	property url pluginUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/wastecollection_plugins/main/"

	property variant providersNameArray: []
	property variant providersDataArray: []
	property variant providersIdArray: []
	property variant providersInfoArray: []
	property variant availableProviders: {}
	property string providersListText

	property string activeProvider
	property int activeProviderIndex
	property string activeScriptVersion
	property string onlineScriptVersion

	property bool enableZipcode
	property bool enableHouseNr
	property bool enableStreet
	property bool enableCity
	property bool enableICSId

	property bool scriptUpdateAvailable: false
	property bool restartRequired: false
	
	FileIO {id: pluginFile;	source: "wastecollectionProvider.js"}
			
	Component.onCompleted: {   //kick off regular version checks of the downloaded javascript module)
		try{
			tscsignals.tscSignal.connect(performVersionCheck);
		} catch(e) {
		}
	}

	function performVersionCheck(appName, appArguments) {

		if ((appName == "wastecollection") || (appArguments = "perform javascript version check")) {
			checkforUpdates("DoNotUpdateYet");
		}
	}

	function showDialogWasteCollection() {
		if (!app.dialogShown) {
			qdialog.showDialog(qdialog.SizeLarge, "Afvalkalender mededeling", "Indien er een nieuwe afvalverwerker is geselekteerd zal de app de juiste module downloaden voor die afvalverwerker.\nWijzigingen worden pas actief als U op de knop 'Opslaan' heeft gedrukt.\nDe Toon zal daarna direct opnieuw opstarten om de nieuwe module te activeren.\nIndien de afvalverwerker niet is gewijzigd zullen de afval datums direct worden ververst." , "Sluiten");
			app.dialogShown = true;
		}
	}

	function getProviders(){

		//get id of installed provider
		var currentPluginFileString = pluginFile.read()
		var n1 = currentPluginFileString.indexOf('<provider>')
		var n2 = currentPluginFileString.indexOf('</provider>',n1)
		activeProvider =  currentPluginFileString.substring(n1 + 10, n2);
		if (activeProvider !== app.wasteCollector) scriptUpdateAvailable = true;	

		if (providersNameArray.length < 1 ){
			var http = new XMLHttpRequest()
			http.onreadystatechange=function() {
				if (http.readyState === 4){
					if (http.status === 200 || http.status === 300  || http.status === 302) {
						providersNameArray= [];
						providersDataArray= [];
						providersInfoArray= [];
						providersIdArray= [];
						providersListText = "";
						availableProviders = JSON.parse(http.responseText)
						var tmpArray = availableProviders.plugins
						for (var i in tmpArray){
							providersNameArray[i] = tmpArray[i].friendlyName
							providersInfoArray[i] = tmpArray[i].info
							providersIdArray[i] = tmpArray[i].provider
							if (tmpArray[i].provider === activeProvider) activeProviderIndex = i;
							providersDataArray[i] = tmpArray[i].data
							providersListText = providersListText + "\n" + tmpArray[i].provider + " : " + tmpArray[i].friendlyName;
						}

							// enable applicable data entry fields

						infoProvider.text =  "Actieve plugin: " + providersInfoArray[activeProviderIndex];
						enableZipcode = (providersDataArray[activeProviderIndex].indexOf("zipcode") > -1);
						enableHouseNr = (providersDataArray[activeProviderIndex].indexOf("housenr") > -1);
						enableStreet = (providersDataArray[activeProviderIndex].indexOf("streetName") > -1);
						enableCity = (providersDataArray[activeProviderIndex].indexOf("city") > -1);
						enableICSId = (providersDataArray[activeProviderIndex].indexOf("ICSId") > -1);
						checkforUpdates("update");	
					}
				}
			}
			http.open("GET",providerUrl, true)
			http.send()
		}	
	}

	function checkforUpdates(action) {

		//check current version
		var scriptUpdateAvailable = false

		var currentPluginFileString = pluginFile.read()
		var n1 = currentPluginFileString.indexOf('<provider>')
		var n2 = currentPluginFileString.indexOf('</provider>',n1)
		activeProvider =  currentPluginFileString.substring(n1 + 10, n2);
		if (activeProvider !== app.wasteCollector) {scriptUpdateAvailable = true; app.scriptUpdateAvailable  = true; return}

		var currentPluginFileString = pluginFile.read()
		var n1 = currentPluginFileString.indexOf('<version>')
		var n2 = currentPluginFileString.indexOf('</version>',n1)
		activeScriptVersion = (currentPluginFileString.substring(n1 + 9, n2)).trim()	

		//check online version

		var http = new XMLHttpRequest()
		http.onreadystatechange=function() {
			if (http.readyState === 4){
				if (http.status === 200) {
					var onlinePluginFileString = http.responseText
					var n1 = onlinePluginFileString.indexOf('<version>')
					var n2 = onlinePluginFileString.indexOf('</version>',n1)
					onlineScriptVersion =  (onlinePluginFileString.substring(n1 + 9, n2)).trim()	

						// compare versions

					scriptUpdateAvailable = false
					var activeVersionArray = activeScriptVersion.split(".")
					var onlineVersionArray = onlineScriptVersion.split(".")

					if (parseInt(onlineVersionArray[0]) > parseInt(activeVersionArray[0])) {
						scriptUpdateAvailable = true
					}
					if (!scriptUpdateAvailable && (parseInt(onlineVersionArray[1]) > parseInt(activeVersionArray[1]))) {
						scriptUpdateAvailable = true
					}
					if (!scriptUpdateAvailable && (parseInt(onlineVersionArray[2]) > parseInt(activeVersionArray[2]))) {
						scriptUpdateAvailable = true
					}
					if (scriptUpdateAvailable && (action == "update") ) updateProviderScript();
					app.scriptUpdateAvailable = scriptUpdateAvailable; 
				}
			}
		}
		http.open("GET", pluginUrl + "wastecollectionProvider_" + activeProvider + ".js"  , true)
		http.send()

	}

	function updateProviderScript(){

		activeProviderIndex = -1;
		for (var i=0;i<providersIdArray.length;i++) {
			if (providersIdArray[i] == app.wasteCollector) {
				activeProviderIndex = i;
			}
		}

		if (activeProviderIndex > -1) {

			var http = new XMLHttpRequest()
			http.onreadystatechange=function() {
				if (http.readyState === 4){
					if (http.status === 200) {
				   		var doc2 = new XMLHttpRequest();
						doc2.onreadystatechange=function() {
							if (doc2.readyState === 4){
								if (doc2.status === 0) {
									qdialog.showDialog(qdialog.SizeLarge, "Belangrijk: Herstart nodig", "Een nieuwe plugin is opgehaald voor " + providersNameArray[activeProviderIndex] + "...\nDe Toon zal over 10 seconden herstarten om de nieuwe module te activeren.", "Sluiten");
									restartTimer.start();
								}
							}
						}
						doc2.open("PUT", "file:///qmf/qml/apps/wastecollection/wastecollectionProvider.js");
   						doc2.send(http.responseText);
					}
				}
			}
			http.open("GET",pluginUrl + "wastecollectionProvider_" + app.wasteCollector + ".js"  , true)
			http.send()
		}
	}

	function saveWasteZipcode(text) {

		if (text) {
			app.wasteZipcode = text.toUpperCase();
			wasteZipcodeLabel.inputText = app.wasteZipcode;
			showDialogWasteCollection()
		}
	}

	function saveWasteIconHour(text) {

		if (text) {
			app.wasteIconHour = parseInt(text);
			wasteIconHourLabel.inputText = app.wasteIconHour;
			showDialogWasteCollection()
		}
	}

	function saveWasteHouseNr(text) {

		if (text) {
			app.wasteHouseNr = text;
			wasteHouseNrLabel.inputText = app.wasteHouseNr;
			showDialogWasteCollection()
		}
	}

	function saveWasteCollector(text) {

		if (text) {
			app.wasteCollector = text;
			wasteCollectorLabel.inputText = text;

			for (var i=0;i<providersIdArray.length;i++) {
				if (providersIdArray[i] == text) {
					activeProviderIndex = i;
					enableZipcode = (providersDataArray[activeProviderIndex].indexOf("zipcode") > -1);
					enableHouseNr = (providersDataArray[activeProviderIndex].indexOf("housenr") > -1);
					enableStreet = (providersDataArray[activeProviderIndex].indexOf("streetName") > -1);
					enableCity = (providersDataArray[activeProviderIndex].indexOf("city") > -1);
					enableICSId = (providersDataArray[activeProviderIndex].indexOf("ICSId") > -1);
					infoProvider.text =  providersInfoArray[activeProviderIndex];
				}
			}
			showDialogWasteCollection()
		}
	}

	function saveWasteStreet(text) {

		if (text) {
			app.wasteStreetName = text;
			wasteStreetLabel.inputText = app.wasteStreetName;
			showDialogWasteCollection()
		}
	}

	function saveWasteCity(text) {

		if (text) {
			app.wasteCity = text;
			wasteCityLabel.inputText = app.wasteCity;
			showDialogWasteCollection()
		}
	}

	function saveWasteICSId(text) {

		if (text) {
			app.wasteICSId = text;
			wasteICSIdLabel.inputText = app.wasteICSId;
			showDialogWasteCollection()
		}
	}

	function saveWasteExtraDates(text) {

		if (text) {
			app.wasteExtraDatesURL = text;
			wasteExtraDatesLabel.inputText = app.wasteExtraDatesURL;
			showDialogWasteCollection()
		}
	}

	function saveWasteExtraIcons(text) {

		if (text) {
			app.wasteExtraIconsURL = text;
			wasteExtraIconsLabel.inputText = app.wasteExtraIconsURL;
			showDialogWasteCollection();
		}
	}


	function validateIconHour(text, isFinalString) {
		if (isFinalString) {
			if (parseInt(text) < 24)
				return null;
			else
				return {title: "Ongeldig uur", content: "Voer een getal in kleiner dan 24"};
		}
		return null;
	}

	function validateAfvalverwerker(text, isFinalString) {
		if (isFinalString) {
			var found =false
			for (var i=0;i<providersIdArray.length;i++) {
				if (providersIdArray[i] == text) found=true;
			}
			if (found)
				return null;
			else
				return {title: "Onbekende provider", content: "Kies uit onderstaaande providers:\n" + providersListText};
		}
		return null;
	}

	screenTitle: "Afvalkalender configuratie"

	onShown: {
		addCustomTopRightButton("Opslaan");
		wasteHouseNrLabel.inputText = app.wasteHouseNr;
		wasteZipcodeLabel.inputText = app.wasteZipcode;
		wasteCollectorLabel.inputText = app.wasteCollector;
		wasteStreetLabel.inputText = app.wasteStreetName;
		wasteCityLabel.inputText = app.wasteCity;
		wasteICSIdLabel.inputText = app.wasteICSId;
		wasteIconHourLabel.inputText = app.wasteIconHour;
		wasteExtraDatesLabel.inputText = app.wasteExtraDatesURL;
		wasteExtraIconsLabel.inputText = app.wasteExtraIconsURL;
		wasteCustomIconsToggle.isSwitchedOn = app.wasteCustomIcons;
		enableThermostatModToggle.isSwitchedOn = app.enableThermostatMod;
		enableSystrayToggle.isSwitchedOn = app.enableSystray;
		enableCreateICSToggle.isSwitchedOn = app.enableCreateICS;
		getProviders();
	}

	onCustomButtonClicked: {
		app.saveWasteSettingsJson();
		if (activeProvider !== app.wasteCollector) {
			updateProviderScript("updateAndRestart");
		} else {
			checkforUpdates("update");
		}
		app.wastecollectionListDates = "\nBezig met ophalen gegevens, ogenblikje.....";
		app.restartTimerAfterConfigChange();
		hide();
	}

	function validateTime(text, isFinalString) {
		return null;
	}

	EditTextLabel4421 {
		id: wasteCollectorLabel
		width: wasteZipcodeLabel.width
		leftTextAvailableWidth: isNxt ? 250 : 200
		height: isNxt ? 44 : 35
		leftText: "Afvalverwerker:"

		anchors {
			left: parent.left
			leftMargin : isNxt ? 10 : 8
			top: parent.top
			topMargin: 6
		}

		onClicked: {
			qnumKeyboard.open("Selekteer afvalverwerker", wasteCollectorLabel.inputText, app.wasteCollector, 1 , saveWasteCollector, validateAfvalverwerker);
			qnumKeyboard.maxTextLength = 2;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}

	TextEdit {
		id: infoProvider
		width: wasteZipcodeLabel.width + btnHelpwasteCollector.width + 10
		height: wasteZipcodeLabel.height * 2
	        wrapMode: TextEdit.Wrap
		font.pixelSize: isNxt ? 20 : 15
		font.family: qfont.regular.name
		color: (activeProvider !== app.wasteCollector) ? "#FF0000" : "#000000"
	        readOnly:true
		anchors {
			left: wasteCollectorLabel.left
			top: wasteCollectorLabel.bottom
			topMargin: 6
		}
	}


	StandardButton {
		id: btnHelpwasteCollector
		text: "?"
		anchors.left: wasteCollectorLabel.right
		anchors.bottom: wasteCollectorLabel.bottom
		anchors.leftMargin: 10
		onClicked: qdialog.showDialog(qdialog.SizeLarge, "Kies een van de volgende opties:", providersListText , "Sluiten");
	}

	EditTextLabel4421 {
		id: wasteZipcodeLabel
		width: isNxt ? 375 : 300
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 160 : 120
		leftText: "Postcode:"
		visible : enableZipcode
		anchors {
			left: wasteCollectorLabel.left
			top: infoProvider.bottom
			topMargin: isNxt ? 20 : 15
		}
		onClicked: {
			qkeyboard.open("Voer postcode in (1111AA)", wasteZipcodeLabel.inputText, saveWasteZipcode)
		}
	}

	EditTextLabel4421 {
		id: wasteStreetLabel
		width: wasteZipcodeLabel.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 160 : 120
		leftText: "Straatnaam:"
		visible : enableStreet
		anchors {
			left: wasteCollectorLabel.left
			top: wasteZipcodeLabel.bottom
			topMargin: 6
		}

		onClicked: qkeyboard.open("Voer (eerste deel van de) straatnaam in", wasteStreetLabel.inputText, saveWasteStreet)
	}

	EditTextLabel4421 {
		id: wasteCityLabel
		width: wasteZipcodeLabel.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 160 : 120
		leftText: "Plaatsnaam:"
		visible : enableStreet
		anchors {
			left: wasteCollectorLabel.left
			top: wasteStreetLabel.bottom
			topMargin: 6
		}

		onClicked: qkeyboard.open("Voer (eerste deel van de) plaatsnaam in", wasteCityLabel.inputText, saveWasteCity)
	}

	EditTextLabel4421 {
		id: wasteHouseNrLabel
		width: wasteStreetLabel.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 160 : 120
		leftText: "Huisnr:"
		visible : enableHouseNr
		anchors {
			left: wasteCollectorLabel.left
			top: wasteCityLabel.bottom
			topMargin: 6
		}
		onClicked: {
			qkeyboard.open("Voer huisnummer in", wasteHouseNrLabel.inputText, saveWasteHouseNr)
		}
	}

	EditTextLabel4421 {
		id: wasteICSIdLabel
		width: wasteZipcodeLabel.width
		leftTextAvailableWidth: isNxt ?  160 : 120
		height: isNxt ? 44 : 35
		leftText: "ICS Nr:"
		visible : enableICSId
		anchors {
			left: wasteCollectorLabel.left
			top: wasteHouseNrLabel.bottom
			topMargin: 6
		}
		onClicked: {
			qkeyboard.open("Voer ICS nummer in", wasteICSIdLabel.inputText, saveWasteICSId)
		}
	}

	EditTextLabel4421 {
		id: wasteIconHourLabel
		width: wasteZipcodeLabel.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 300 : 240
		leftText: "Display icon vanaf uur:"
		anchors {
			left: btnHelpwasteCollector.right
			leftMargin: isNxt ? 50 : 40
			top: btnHelpwasteCollector.top
		}
		onClicked: {
			qnumKeyboard.open("Voer uur in voor display icon", wasteIconHourLabel.inputText, app.wasteIconHour, 1 , saveWasteIconHour, validateIconHour);
			qnumKeyboard.maxTextLength = 2;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}

	StandardButton {
		id: btnHelpwasteIconHour
		text: "?"
		anchors.left: btnHelpCustomIcons.left
		anchors.bottom: wasteIconHourLabel.bottom
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Disply icon vanaf .. uur", "Voer het uur in vanaf wanneer je het afval-icoon wilt zien op de dag voorafgaand aan de ophaaldag.\n" +
					"Standaard waarde is 18, toont icons vanaf 6 uur 's avonds.\nWijzigingen worden pas actief op het vorige tijdstip voor icoon wissel " , "Sluiten");
		}
	}


	EditTextLabel4421 {
		id: wasteCustomIconsLabel
		width: wasteHouseNrLabel.width
		height: isNxt ? 44 : 35
		leftText: "Custom Icons gebruiken"
		leftTextAvailableWidth: wasteHouseNrLabel.width
		anchors {
			left: wasteIconHourLabel.left
			top: wasteIconHourLabel.bottom
			topMargin: 6
		}
	}

	OnOffToggle {
		id: wasteCustomIconsToggle
		height: isNxt ? 45 : 36
		anchors.left: wasteCustomIconsLabel.right
		anchors.leftMargin: 10
		anchors.top: wasteCustomIconsLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.wasteCustomIcons = true
			} else {
				app.wasteCustomIcons = false
			}
		}
	}

	StandardButton {
		id: btnHelpCustomIcons
		text: "?"
		anchors.left: wasteCustomIconsToggle.right
		anchors.bottom: wasteCustomIconsLabel.bottom
		anchors.leftMargin: isNxt ? 15 : 10
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Gebruik custom icons", "Zet de switch aan als je eigen icons wilt gebruiken voor standaard afval types. Locatie van de icons is de folder voor extra icons hieronder. Gebruik dezelfde naamgeving als in\n/qmf/qml/apps/wastecollection/drawables/" , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: enableSystrayLabel
		width: wasteHouseNrLabel.width
		height: isNxt ? 44 : 35
		leftText: "Icons weergeven in systray"
		leftTextAvailableWidth: wasteHouseNrLabel.width
		anchors {
			top: wasteCustomIconsLabel.bottom
			left: wasteCustomIconsLabel.left
			topMargin: 6
		}
	}

	OnOffToggle {
		id: enableSystrayToggle
		height: isNxt ? 45 : 36
		anchors.left: enableSystrayLabel.right
		anchors.leftMargin: 10
		anchors.top: enableSystrayLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.enableSystray = true
			} else {
				app.enableSystray = false
			}
		}
	}

	EditTextLabel4421 {
		id: enableThermostatModLabel
		width: wasteHouseNrLabel.width
		height: isNxt ? 44 : 35
		leftText: "Afvalicons in thermostaat"
		leftTextAvailableWidth: wasteHouseNrLabel.width
		anchors {
			top: enableSystrayLabel.bottom
			topMargin: 6
			left: enableSystrayLabel.left
		}
	}

	OnOffToggle {
		id: enableThermostatModToggle
		height: isNxt ? 45 : 36
		anchors.left: enableThermostatModLabel.right
		anchors.leftMargin: 10
		anchors.top: enableThermostatModLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.enableThermostatMod = true
			} else {
				app.enableThermostatMod = false
			}
		}
	}

	StandardButton {
		id: btnHelpenableThermostatMod
		text: "?"
		anchors.left: enableThermostatModToggle.right
		anchors.bottom: enableThermostatModToggle.bottom
		anchors.leftMargin: isNxt ? 15 : 10
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Icons boven thermostaat", "Zet de switch aan als je de afval icons wilt tonen boven de standaard thermostaat. Je hoeft dan geen aparte tegel op je eerste homescreen te zetten.\nDeze functie werkt alleen op een recente resourcefile die deze functie ondersteunt." , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: enableCreateICSLabel
		width: wasteHouseNrLabel.width
		height: isNxt ? 44 : 35
		leftText: "Maak ICS kalender file"
		leftTextAvailableWidth: wasteHouseNrLabel.width
		anchors {
			top: enableThermostatModLabel.bottom
			topMargin: 6
			left: enableThermostatModLabel.left
		}
	}

	OnOffToggle {
		id: enableCreateICSToggle
		height: isNxt ? 45 : 36
		anchors.left: enableCreateICSLabel.right
		anchors.leftMargin: 10
		anchors.top: enableCreateICSLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.enableCreateICS = true
			} else {
				app.enableCreateICS = false
			}
		}
	}

	StandardButton {
		id: btnHelpenableCreateICS
		text: "?"
		anchors.left: enableCreateICSToggle.right
		anchors.bottom: enableCreateICSToggle.bottom
		anchors.leftMargin: isNxt ? 15 : 10
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Kalender ICS file", 'Zet de switch aan voor het aanmaken van een ICS file voor de kalender app.\nKalender file wordt aangemaakt als: /var/volatile/tmp/wasteDates.ics' , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteExtraDatesLabel
		width: isNxt ? 850 : 680
		leftText : "Bestand extra datums:"
		leftTextAvailableWidth: isNxt ? 287 : 230
		height: isNxt ? 44 : 35
		anchors {
			left: wasteICSIdLabel.left
			top: wasteICSIdLabel.bottom
			topMargin: isNxt ? 15 : 12
		}

		onClicked: {
			qkeyboard.open("Invoer URL of lokaal bestand (zie helptekst)", wasteExtraDatesLabel.inputText, saveWasteExtraDates)
		}
	}

	IconButton {
		id: wasteExtraDatesLabelDeleteButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/icon_delete.png"
		anchors {
			right: btnHelpExtraDates.left
			rightMargin: 10
			top: wasteExtraDatesLabel.top
		}

		topClickMargin: 3
		onClicked: {
			saveWasteExtraDates(" ");
		}
	}

	StandardButton {
		id: btnHelpExtraDates
		text: "?"
		anchors.left: btnHelpCustomIcons.left
		anchors.bottom: wasteExtraDatesLabelDeleteButton.bottom

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Extra ophaaldagen tonen", "Voer de URL of de volledige bestandsnaam in van het bestand met de extra ophaaldagen. Voorbeeld:\n" +
					"http://www.jouwserver.nl/extraDates.txt   of\n" +
					"file:///root/waste/extraDates.txt\n\n" +
					"Inhoud van het bestand:\n" +
					"YYYY-MM-DD,X\n" +
					"waarin X is 0 t/m 9:\n" +
					"0 = Restafval\n"+
					"1 = Plastic, metaal en drankpakken\n"+
					"2 = Papier\n"+
					"3 = Groente, fruit en tuinafval\n"+
					"4 = Snoeiafval\n"+
					"5 = Textiel\n"+
					"6 = Puin\n"+
					"7 = KGA, klein chemisch afval\n"+
					"8 = Grofvuil\n"+
					"9 = Kunstoffen\n\n"+
					"of A t/m Z voor custom categorieen", "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteExtraIconsLabel
		width: isNxt ? 850 : 680
		leftText : "Lokatie extra icons:"
		leftTextAvailableWidth: isNxt ? 287 : 230
		height: isNxt ? 44 : 35
		anchors {
			left: wasteExtraDatesLabel.left
			top: wasteExtraDatesLabel.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Invoer URL of lokale folder (zie helptekst)", wasteExtraIconsLabel.inputText, saveWasteExtraIcons)
		}
	}

	IconButton {
		id: wasteExtraIconsLabelDeleteButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/icon_delete.png"
		anchors {
			right: btnHelpExtraIcons.left
			rightMargin: 10
			top: wasteExtraIconsLabel.top
		}

		topClickMargin: 3
		onClicked: {
			saveWasteExtraIcons(" ");
		}
	}
	StandardButton {
		id: btnHelpExtraIcons
		text: "?"
		anchors.left: btnHelpCustomIcons.left
		anchors.bottom: wasteExtraIconsLabelDeleteButton.bottom

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Extra icons en omschrijvingen tonen", "Voer de URL of de foldernaam van de locatie van de custom icons. Voorbeeld:\n" +
					"http://www.jouwserver.nl/waste/icons/  of\n" +
					"file:///root/waste/icons/ \n\n" +
					"De filenamen van de icons moeten zijn X.png waarin X = A t/m Z\n"+
					"Dezelfde folder moet ook een bestand bevatten wat heet iconLabels.txt met daarin (voorbeeld):\n" +
					"{\"A\": \"Feestje 1\", \"B\": \"Verjaardag\", \"C\" : \"Dierentuin\"}\n"+
					"De lettercodes komen evereen met de custom icons in de datum file." , "Sluiten");
		}
	}

	Timer {
		id: restartTimer
		interval: 10000
		repeat: false
		running: false
		onTriggered: Qt.quit() 
	}

}
