import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0

Screen {
	id: wasteConfigurationScreen

	property string helpText

	function showDialogWasteCollection() {
		if (!app.dialogShown) {
			qdialog.showDialog(qdialog.SizeLarge, "Afvalkalender mededeling", "Wijzigingen worden pas actief als U op de knop 'Opslaan' heeft gedrukt, rechtsboven op het scherm.\nDe tegel zal na 5-10 seconden worden ververst met de nieuwe informatie." , "Sluiten");
			app.dialogShown = true;
		}
	}

	function getICSUrl() {
		switch (app.wasteCollector) {
			case "3" : return "https://afvalkalender.cure-afvalbeheer.nl/ical/";
			case "4" : return "https://afvalkalender.cyclusnv.nl/ical/";
			case "6" : return "https://inzamelkalender.hvcgroep.nl/ical/";
			case "7" : return "https://afvalkalender.dar.nl/ical/";
			case "12" : return "https://inzamelschema.rmn.nl/ical/";
			case "13" : return "https://inzamelwijzer.suez.nl/ical/";
			case "18" : return "http://afvalkalender.zrd.nl/ical/";
			case "23" : return "https://afvalkalender.alphenaandenrijn.nl/ical/";
			case "24" : return "https://www.avalex.nl/ical/";
			case "26" : return "https://inzamelkalender.gad.nl/ical/";
			case "37" : return "https://inzamelkalender.stadswerk072.nl/ical/";
			default: break;
		}
		return "---";
	}

	function saveWasteZipcode(text) {

		if (text) {
			app.wasteZipcode = text;
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
			wasteCollectorLabel.inputText = app.wasteCollector;
			showDialogWasteCollection()
		}
	}

	function saveWasteStreet(text) {

		if (text) {
			app.wasteStreet = text;
			wasteStreetLabel.inputText = app.wasteStreet;
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
			if (parseInt(text) < 39)
				return null;
			else
				return {title: "Ongeldig keuze", content: "Voer een getal in kleiner dan 39"};
		}
		return null;
	}

	screenTitle: "Afvalkalender configuratie"

	onShown: {
		addCustomTopRightButton("Opslaan");
		wasteHouseNrLabel.inputText = app.wasteHouseNr;
		wasteZipcodeLabel.inputText = app.wasteZipcode;
		wasteCollectorLabel.inputText = app.wasteCollector;
		wasteStreetLabel.inputText = app.wasteStreet;
		wasteICSIdLabel.inputText = app.wasteICSId;
		wasteIconHourLabel.inputText = app.wasteIconHour;
		wasteExtraDatesLabel.inputText = app.wasteExtraDatesURL;
		wasteExtraIconsLabel.inputText = app.wasteExtraIconsURL;
		wasteCustomIconsToggle.isSwitchedOn = app.wasteCustomIcons;
		enableThermostatModToggle.isSwitchedOn = app.enableThermostatMod;
		enableSystrayToggle.isSwitchedOn = app.enableSystray;
		enableCreateICSToggle.isSwitchedOn = app.enableCreateICS;
	}

	onCustomButtonClicked: {
		hide();
		app.saveWasteSettingsJson();
		app.wastecollectionListDates = "\nBezig met ophalen gegevens (>10 seconden).....";
		app.restartTimerAfterConfigChange();
	}

	function validateTime(text, isFinalString) {
		return null;
	}

	Text {
		id: title
		x: isNxt ? 38 : 30
		y: 10
		visible : (wasteICSIdLabel.leftText.length < 5)
		text: "Invoeren postcode (formaat 1111AA)"
		font.pixelSize: isNxt ? 20 : 16
		font.family: qfont.semiBold.name
		color: colors.rbTitle
	}

	EditTextLabel4421 {
		id: wasteZipcodeLabel
		width: isNxt ? 350 : 280
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 250 : 200
		leftText: "Postcode:"
		visible : (wasteICSIdLabel.leftText.length < 5)
		anchors {
			left: title.left
			top: title.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Voer postcode in (1111AA)", wasteZipcodeLabel.inputText, saveWasteZipcode)
		}
	}

	IconButton {
		id: wasteZipcodeLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"
		visible : (wasteICSIdLabel.leftText.length < 5)
		anchors {
			left: wasteZipcodeLabel.right
			leftMargin: 6
			top: title.bottom
			topMargin: 6
		}

		bottomClickMargin: 3
		onClicked: {
			qkeyboard.open("Voer postcode in (1111AA)", wasteZipcodeLabel.inputText, saveWasteZipcode)
		}
	}

	StandardButton {
		id: btnHelpZipcode
		text: "?"
		anchors.left: wasteZipcodeLabelButton.right
		anchors.bottom: wasteZipcodeLabelButton.bottom
		anchors.leftMargin: 10
		visible : (wasteICSIdLabel.leftText.length < 5)
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Postcode", "Alleen invoeren voor de volgende afvalverwerkers:\n" +
					"              mijnafvalwijzer.nl\n" +
					"              limburg.net\n" +
					"              iok.be\n" +
					"              cranendonck.nl\n" +
					"              rd4info.nl\n" +
					"              afvalalert.nl\n" +
					"              drimmelen.nl\n" +
					"              afvalstoffendienstkalender.nl\n" +
					"              venlo.nl\n" +
					"              bar-afbalbeheer.nl\n" +
					"              twentemilieu.nl\n" +
					"              reinis.nl\n" +
					"              hellendoorn.nl\n" +
					"              almere.nl\n" +
					"              meerlanden.nl\n" +
					"              deafvalapp.nl" , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteStreetLabel
		width: wasteZipcodeLabel.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 250 : 200
		leftText: "Straatnr(BE):"
		visible : (wasteICSIdLabel.leftText.length < 5)
		anchors {
			left: title.left
			top: wasteZipcodeLabel.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Voer straatnummer in", wasteStreetLabel.inputText, saveWasteStreet)
		}
	}

	IconButton {
		id: wasteStreetLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"
		visible : (wasteICSIdLabel.leftText.length < 5)
		anchors {
			left: wasteStreetLabel.right
			leftMargin: 6
			top: wasteZipcodeLabel.bottom
			topMargin: 6
		}

		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Voer straatnummer in", wasteStreetLabel.inputText, saveWasteStreet)
		}
	}

	StandardButton {
		id: btnHelpStreet
		text: "?"
		anchors.left: wasteStreetLabelButton.right
		anchors.bottom: wasteStreetLabelButton.bottom
		anchors.leftMargin: 10
		visible : (wasteICSIdLabel.leftText.length < 5)
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Straat", "Alleen invoeren voor de volgende afvalverwerkers:\n" +
					"              limburg.net\n" +
					"              iok.be\n" , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteHouseNrLabel
		width: wasteStreetLabel.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 250 : 200
		leftText: "Huisnummer:"
		visible : (wasteICSIdLabel.leftText.length < 5)
		anchors {
			left: btnHelpZipcode.left
			leftMargin : 40
			top: wasteZipcodeLabel.top
		}

		onClicked: {
			qkeyboard.open("Voer huisnummer in", wasteHouseNrLabel.inputText, saveWasteHouseNr)
		}
	}

	IconButton {
		id: wasteHouseNrLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"
		visible : (wasteICSIdLabel.leftText.length < 5)
		anchors {
			left: wasteHouseNrLabel.right
			leftMargin: 6
			top: wasteHouseNrLabel.top
		}

		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Voer huisnummer in", wasteHouseNrLabel.inputText, saveWasteHouseNr)
		}
	}

	StandardButton {
		id: btnHelpHouseNr
		text: "?"
		anchors.left: enableCreateICSToggle.right
		anchors.bottom: wasteHouseNrLabelButton.bottom
		anchors.leftMargin: 10
		visible : (wasteICSIdLabel.leftText.length < 5)
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Huisnummer", "Alleen invoeren voor de volgende afvalverwerkers:\n" +
					"              mijnafvalwijzer.nl\n" +
					"              limburg.net\n" +
					"              cranendonck.nl\n" +
					"              rd4info.nl\n" +
					"              afvalalert.nl\n" +
					"              drimmelen.nl\n" +
					"              afvalstoffendienstkalender.nl\n" +
					"              venlo.nl\n" +
					"              bar-afbalbeheer.nl\n" +
					"              twentemilieu.nl\n" +
					"              reinis.nl\n" +
					"              meerlanden.nl\n" +
					"              hellendoorn.nl\n" +
					"              almere.nl\n" +
					"              deafvalapp.nl" , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteCollectorLabel
		width: wasteZipcodeLabel.width
		leftTextAvailableWidth: isNxt ? 250 : 200
		height: isNxt ? 44 : 35
		leftText: "Afvalverwerker:"

		anchors {
			left: wasteStreetLabel.left
			top: wasteStreetLabel.bottom
			topMargin: 6
		}

		onClicked: {
			qnumKeyboard.open("Selekteer afvalverwerker", wasteCollectorLabel.inputText, app.wasteCollector, 1 , saveWasteCollector, validateAfvalverwerker);
			qnumKeyboard.maxTextLength = 2;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}

	IconButton {
		id: wasteCollectorLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"

		anchors {
			left: wasteCollectorLabel.right
			leftMargin: 6
			top: wasteStreetLabel.bottom
			topMargin: 6
		}

		topClickMargin: 3
		onClicked: {
			qnumKeyboard.open("Selekteer afvalverwerker", wasteCollectorLabel.inputText, app.wasteCollector, 1 , saveWasteCollector, validateAfvalverwerker);
			qnumKeyboard.maxTextLength = 2;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}

	StandardButton {
		id: btnHelpCollectors
		text: "?"
		anchors.left: wasteCollectorLabelButton.right
		anchors.bottom: wasteCollectorLabelButton.bottom
		anchors.leftMargin: 10
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Afvalverwerker", "Keuzes:  1 : mijnafvalwijzer.nl             2 : deafvalapp.nl\n" +
					"                3 : cure-afvalbeheer.nl         4 : cyclusnv.nl\n" +
					"                5 : katwijk.nl                           6 : hvcgroep.nl\n" +
					"                7 : dar.nl                                 8 : cranendonck.nl\n" +
					"                9 : iok.be                              10 : limburg.net\n" +
					"              11 : denhaag.nl                     12 : rmn.nl\n" +
					"              13 : inzamelwijzer.suez.nl  14 : rova.nl\n" +
					"              15 : afvalalert.nl            16 : meerlanden.nl\n" +
					"              17 : rd4info.nl(Toon2)        18 : zrd.nl\n" +
					"              19 : drimmelen.nl               20: circulus-berkel.nl\n" +
					"              21 : omrin.nl      22:afvalstoffendienstkalender.nl\n" +
					"              23 : alphenaandenrijn.nl  24:avalex.nl\n" +
					"              25 : area-afval.nl        26: gad.nl\n" +
					"              27 : venlo.nl             28: rd4info.nl (Toon1)\n" +
					"              29 : veldhoven.nl            30: meppel.nl\n" +
					"              31 : mijnafvalwijzer.nl (html)32: groningen.nl\n" +
					"              33 : bar-afvalbeheer.nl   34: twentemilieu.nl\n" +
					"              35:  reinis.nl           36:hellendoorn.nl\n" +
					"              37:  stadswerk072.nl     38:almere.nl\n" +
					"               0 : overig (handmatig)" , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteICSIdLabel
		width: isNxt ? 750 : 600
		leftTextAvailableWidth: isNxt ? 567 : 450
		height: isNxt ? 44 : 35
		leftText: getICSUrl()
		visible : (leftText.length > 5)
		anchors {
			left: wasteCollectorLabel.left
			top: wasteCollectorLabel.bottom
			topMargin: 16
		}

		onClicked: {
			qkeyboard.open("Voer ICS nummer in", wasteICSIdLabel.inputText, saveWasteICSId)
		}
	}

	IconButton {
		id: wasteICSIdLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"
		visible : (wasteICSIdLabel.leftText.length > 5)
		anchors {
			left: wasteICSIdLabel.right
			leftMargin: 6
			top: wasteCollectorLabel.bottom
			topMargin: 16
		}

		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Voer ICS nummer in", wasteICSIdLabel.inputText, saveWasteICSId)
		}
	}

	StandardButton {
		id: btnHelpICSId
		text: "?"
		anchors.left: wasteICSIdLabelButton.right
		anchors.bottom: wasteICSIdLabelButton.bottom
		anchors.leftMargin: 20
		visible : (wasteICSIdLabel.leftText.length > 5)

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "ICS nummer", "Alleen invoeren voor de volgende afvalverwerkers:\n" +
					"              cure-afvalbeheer.nl\n" +
					"              dar.nl\n" +
					"              hvcgroep.nl\n" +
					"              meerlanden.nl\n" +
					"              alphenaandenrijn.nl\n" +
					"              avalex.nl\n" +
					"              gad.nl\n" +
					"              cyclusnv.nl\n" , "Sluiten");
		}
	}

	Text {
		id: explainWasteCalendar
		text: "Downloaden afvalkalender via https"
		font.pixelSize: 16
		font.family: qfont.semiBold.name
		color: colors.rbTitle
		visible : (wasteICSIdLabel.leftText.length < 5)
		width: wasteZipcodeLabel.width
		height: isNxt ? 44 : 35
		anchors {
			left: wasteZipcodeLabel.left
			top: wasteICSIdLabel.bottom
			topMargin: 16
		}
	}

	StandardButton {
		id: btnHelpCalendars
		text: "?"
		anchors.left: btnHelpCollectors.left
		anchors.bottom: explainWasteCalendar.bottom
		visible : (wasteICSIdLabel.leftText.length < 5)
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Downloaden afvalkalender", "Voor de volgende afvalverwerkers moet de afvalkalender " +
					"worden gedownload via een cron job en wget. " +
					"Dit is beschreven in de sectie 'manuals' op domoticaforum.eu.\n\n" +
					"              cyclusnv.nl, katwijk.nl\n" +
					"              dar.nl, denhaag.nl\n" +
					"              rmn.nl\n" +
					"              Via PC: rova.nl, rd4info.nl, circulus-berkel.nl, omrin.nl" , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteIconHourLabel
		width: wasteZipcodeLabel.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 275 : 220
		leftText: "Display icon vanaf uur:"
		anchors {
			left: title.left
			top: explainWasteCalendar.bottom
			topMargin: 6
		}

		onClicked: {
			qnumKeyboard.open("Voer uur in voor display icon", wasteIconHourLabel.inputText, app.wasteIconHour, 1 , saveWasteIconHour, validateIconHour);
			qnumKeyboard.maxTextLength = 2;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}

	IconButton {
		id: wasteIconHourLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"
		anchors {
			left: wasteIconHourLabel.right
			leftMargin: 6
			top: explainWasteCalendar.bottom
			topMargin: 6
		}

		topClickMargin: 3
		onClicked: {
			qnumKeyboard.open("Voer uur in voor display icon", wasteIconHourLabel.inputText, app.wasteIconHour, 1 , saveWasteIconHour, validateIconHour);
			qnumKeyboard.maxTextLength = 2;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}

	StandardButton {
		id: btnHelpwasteIconHour
		text: "?"
		anchors.left: wasteIconHourLabelButton.right
		anchors.bottom: wasteIconHourLabelButton.bottom
		anchors.leftMargin: 10
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
			left: btnHelpZipcode.left
			leftMargin : 40
			top: wasteIconHourLabel.top
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
		anchors.leftMargin: 10
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
			left: btnHelpZipcode.left
			leftMargin : 40
			top: btnHelpCalendars.top
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

	StandardButton {
		id: btnHelpenableSystray
		text: "?"
		anchors.left: enableSystrayToggle.right
		anchors.bottom: enableSystrayToggle.bottom
		anchors.leftMargin: 10
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "App-icons in system tray", "Zet de switch aan als je een icon in de systray wilt hebben voor directe toegang tot het detailscherm." , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: enableThermostatModLabel
		width: wasteHouseNrLabel.width
		height: isNxt ? 44 : 35
		leftText: "Afvalicons in thermostaat"
		leftTextAvailableWidth: wasteHouseNrLabel.width
		anchors {
			left: btnHelpZipcode.left
			leftMargin : 40
			top: wasteCollectorLabel.top
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
		anchors.leftMargin: 10
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
			left: btnHelpZipcode.left
			leftMargin : 40
			top: wasteStreetLabel.top
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
		anchors.leftMargin: 10
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "Kalender ICS file", 'Zet de switch aan voor het aanmaken van een ICS file voor de kalender app.\nOpen het volgende bestand met een editor:\n/qmf/qml/calendar/userSettings.json\n\en voeg de volgende kalender toe:\n"file:///var/volatile/tmp/wasteDates.ics"' , "Sluiten");
		}
	}

	EditTextLabel4421 {
		id: wasteExtraDatesLabel
		width: isNxt ? 760 : 610
		leftText : "Bestand extra datums:"
		leftTextAvailableWidth: isNxt ? 287 : 230
		height: isNxt ? 44 : 35
		anchors {
			left: wasteIconHourLabel.left
			top: wasteIconHourLabel.bottom
			topMargin: 16
		}

		onClicked: {
			qkeyboard.open("Invoer URL of lokaal bestand (zie helptekst)", wasteExtraDatesLabel.inputText, saveWasteExtraDates)
		}
	}

	IconButton {
		id: wasteExtraDatesLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"
		anchors {
			left: wasteExtraDatesLabel.right
			leftMargin: 6
			top: wasteIconHourLabel.bottom
			topMargin: 16
		}

		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Invoer URL of lokaal bestand (zie helptekst)", wasteExtraDatesLabel.inputText, saveWasteExtraDates)
		}
	}

	IconButton {
		id: wasteExtraDatesLabelDeleteButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/icon_delete.png"
		anchors {
			left: wasteExtraDatesLabelButton.right
			leftMargin: 6
			top: wasteIconHourLabel.bottom
			topMargin: 16
		}

		topClickMargin: 3
		onClicked: {
			saveWasteExtraDates(" ");
		}
	}

	StandardButton {
		id: btnHelpExtraDates
		text: "?"
		anchors.left: wasteExtraDatesLabelDeleteButton.right
		anchors.bottom: wasteExtraDatesLabelButton.bottom
		anchors.leftMargin: 10

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
		width: isNxt ? 760 : 610
		leftText : "Lokatie extra icons:"
		leftTextAvailableWidth: isNxt ? 287 : 230
		height: isNxt ? 44 : 35
		anchors {
			left: wasteIconHourLabel.left
			top: wasteExtraDatesLabelButton.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Invoer URL of lokale folder (zie helptekst)", wasteExtraIconsLabel.inputText, saveWasteExtraIcons)
		}
	}

	IconButton {
		id: wasteExtraIconsLabelButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/edit.png"
		anchors {
			left: wasteExtraIconsLabel.right
			leftMargin: 6
			top: wasteExtraIconsLabel.top
		}

		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Invoer URL of lokale folder (zie helptekst)", wasteExtraIconsLabel.inputText, saveWasteExtraIcons)
		}
	}

	IconButton {
		id: wasteExtraIconsLabelDeleteButton;
		width: isNxt ? 50 : 40
		iconSource: "qrc:/tsc/icon_delete.png"
		anchors {
			left: wasteExtraIconsLabelButton.right
			leftMargin: 6
			top: wasteExtraIconsLabelButton.top
		}

		topClickMargin: 3
		onClicked: {
			saveWasteExtraIcons(" ");
		}
	}
	StandardButton {
		id: btnHelpExtraIcons
		text: "?"
		anchors.left: wasteExtraIconsLabelDeleteButton.right
		anchors.bottom: wasteExtraIconsLabelDeleteButton.bottom
		anchors.leftMargin: 10

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
}
