import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
import "wastecollection.js" as WastecollectionJS

/// Application to manage retrieve the list of date for the waste bin collection
/// Actual display is handled via the ThermostatApp.qml and/or via the Tile

App {
	id: wastecollectionApp

	property string wasteCollector : "10"
			//possible values for now: 	1: "mijnafvalwijzer.nl"
			//				2: "deafvalapp.nl"
			//				3: "cure-afvalbeheer.nl"
			//				4: "cyclusnv.nl"
			//				5: "katwijk.nl"
			//				6: "hvcgroep.nl"
			//				7: "dar.nl"
			//				8: "cranendonck.nl"
			//				9: "iok.be"
			//				10: "limburg.net"
			//				11: "denhaag.nl"
			//				12: "rmn.nl"
			//				13: "inzamelwijzer.suez.nl"
			//				14: "rova.nl"
			//				15: "afvalalert.nl"
			//				16: "meerlanden.nl"
			//				17: "rd4info.nl"  only on Toon 2
			//				18: "zrd.nl"
			//				19: "drimmelen.nl"
			//				20: "circulus-berkel.nl"
			//				21: "omrin.nl"
			//				22: "afvalstoffendienstkalender.nl"
			//				23: "alphenaandenrijn.nl"
			//				24: "avalex.nl"
			//				25: "www.area-afval.nl"
			//				26: "gad.nl"
			//				27: "venlo.nl"
			//				28: "rd4info.nl"  only on Toon 1
			//				29: "veldhoven.nl"
			//				30: "meppel.nl"
			//				31: "mijnafvalwijzer.nl(html)"
			//				32: "groningen.nl"
			//				33: "bar-afvalbeheer.nl"
			//				34: "twentemilieu.nl"
			//				35: "reinis.nl"
			//				36: "hellendoorn.nl"
			//				37: "stadswerk072.nl"
			//				38: "almere.nl"
			//				39: "purmerend.nl"
			//				40: "spaarnelanden.nl"
			//				0: "overig (handmatig)"
			//		
	property string wasteZipcode : "72030"	// or PC variable for iok.be / limburg.net
	property string wasteHouseNr : "2"
	property string wasteStreet : "223"
	property string wasteICSId: "0"

	property url tileUrl : "WastecollectionTile.qml"
	property WastecollectionConfigurationScreen wastecollectionConfigurationScreen
 	property WastecollectionListDatesScreen wastecollectionListDatesScreen 
	property url wastecollectionConfigurationScreenUrl : "WastecollectionConfigurationScreen.qml"
	property url wastecollectionListDatesScreenUrl : "WastecollectionListDatesScreen.qml"
	property url trayUrl: "WastecollectionTray.qml"
	property SystrayIcon wastecollectionTray

	property url thumbnailIcon: "qrc:/tsc/waste_menu.png"
	property string wasteDatesString
	property string wasteType
	property string wasteType2
	property string wasteIcon
	property bool wasteIconShow
	property string wasteIcon2
	property bool wasteIcon2Show
	property bool wasteIconBackShow
	property bool wasteIcon2BackShow
	property bool wasteCustomIcons : false
	property bool enableThermostatMod : true
	property bool enableSystray : false
	property bool enableCreateICS : false
	property string wasteControlIcon
	property string wasteDateNext
	property string wasteDateNextType
	property string wasteDateNext2
	property string wasteDateNext2Type
	property string wasteDateNext3
	property string wasteDateNext3Type
	property bool dialogShown: false
	property int wasteIconHour : 18
	property string wastecollectionListDates
	property variant extraDates : []
	property variant addressJson
	property variant calendar2goMobile
	property string wasteExtraDatesURL
	property string wasteExtraIconsURL
	property variant iconLabelsJson : {}
	property variant wasteSettingsJson : {
		'Afvalverwerker': "",
		'Postcode': "",
		'Huisnummer': "",
		'Straatnummer': "",
		'ICSnummer': "",
		'DisplayIconVanafUur': "",
		'ExtraDatumsFile': "",
		'ExtraDatumsIconsFolder': "",
		'CustomIcons' : "No",
		'ThermostaatIcon' : "Yes",
		'TrayIcon' : "No",
		'CreateICS' : "No"
	}

	FileIO {
		id: userSettingsFile
		source: "file:///mnt/data/tsc/wastecollection.userSettings.json"
	}

	function saveWasteSettingsJson() {  // save for use in future version to get rid of individual setting txt file per paramater
		var strCustomIcons = "";
		var strThermostatMod = "";
		var strSystray = "";
		var strCreateICS = "";

		if (wasteCustomIcons) {
			strCustomIcons = "Yes";
		} else {
			strCustomIcons = "No";
		}

		if (enableThermostatMod) {
			strThermostatMod = "Yes";
		} else {
			strThermostatMod = "No";
  		}

		if (enableSystray) {
			strSystray = "Yes";
		} else {
			strSystray = "No";
  		}

		if (enableCreateICS) {
			strCreateICS = "Yes";
		} else {
			strCreateICS = "No";
  		}

		var wasteSettingsJson = {
			"Afvalverwerker" : wasteCollector,
			"Postcode" : wasteZipcode,
			"Huisnummer" : wasteHouseNr,
			"Straatnummer" : wasteStreet,
			"ICSnummer" : wasteICSId,
			"DisplayIconVanafUur" : wasteIconHour,
			"ExtraDatumsFile" : wasteExtraDatesURL,
			"ExtraDatumsIconsFolder" : wasteExtraIconsURL,
			"CustomIcons" : strCustomIcons,
			"ThermostaatIcon" : strThermostatMod,
			"CreateICS" : strCreateICS,
			"TrayIcon" : strSystray
		};

   		var doc2 = new XMLHttpRequest();
		doc2.open("PUT", "file:///mnt/data/tsc/wastecollection.userSettings.json");
   		doc2.send(JSON.stringify(wasteSettingsJson));
	}

	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: "Afvalkalender", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", wastecollectionConfigurationScreenUrl, this, "wastecollectionConfigurationScreen");
		registry.registerWidget("screen", wastecollectionListDatesScreenUrl, this, "wastecollectionListDatesScreen");
		registry.registerWidget("systrayIcon", trayUrl, wastecollectionApp);
	}

	Component.onCompleted: {

		readDefaults();
		datetimeTimerWaste.start();
	}

	function readExtraDates() {

		var newArray = [];
		extraDates = [];
		var newEntry = "";
		var doc2 = new XMLHttpRequest();
		doc2.onreadystatechange = function() {
			if (doc2.readyState == XMLHttpRequest.DONE) {
				if (doc2.responseText.length > 2) {
					var dateEntries = doc2.responseText.split("\n");
					for (var i = 0; i < dateEntries.length; i++) {
						newEntry = dateEntries[i]
						if (newEntry.length > 5) {
							newEntry = newEntry + "------------";
							newEntry = newEntry.substring(0,12);
							newArray.push(newEntry);
						}
					}
					extraDates = newArray;
					if (wasteCollector == "0") {	// manual waste provider, just write extra dates
						wasteDatesString = "";
						var tmp = WastecollectionJS.sortArray(extraDates);
						for (i = 0; i < tmp.length; i++) {
							wasteDatesString = wasteDatesString + tmp[i] + "\n";
						}
						writeWasteDates();
					}
				}
 			}
		}  
		doc2.open("GET", wasteExtraDatesURL, true);
		doc2.send();
	}

	function readDefaults() {

		// read userSettings

		wasteSettingsJson = JSON.parse(userSettingsFile.read());		
		wasteHouseNr = wasteSettingsJson ['Huisnummer'];
		wasteStreet = wasteSettingsJson ['Straatnummer'];
		wasteZipcode = wasteSettingsJson ['Postcode'];
		wasteICSId = wasteSettingsJson ['ICSnummer'];
		wasteCollector = wasteSettingsJson ['Afvalverwerker'];
		wasteExtraDatesURL = wasteSettingsJson ['ExtraDatumsFile'];
		wasteExtraIconsURL = wasteSettingsJson ['ExtraDatumsIconsFolder'];
		wasteIconHour = wasteSettingsJson ['DisplayIconVanafUur'];
		try {
			enableCreateICS = (wasteSettingsJson ['CreateICS'] == "Yes");
		} catch (e) {
		}

		try {
			enableThermostatMod = (wasteSettingsJson ['ThermostaatIcon'] == "Yes");
		} catch (e) {
		}

		try {
			wasteCustomIcons = (wasteSettingsJson ['CustomIcons'] == "Yes");
		} catch (e) {
		}

		try {
			enableSystray = (wasteSettingsJson ['TrayIcon'] == "Yes");
		} catch (e) {
		}


		readExtraDates();		// read extra dates to be displayed
		getExtraIconLabels();		// read folder locations for custom icons
	}

	function getExtraIconLabels() {
	
		var doc2 = new XMLHttpRequest();
		doc2.onreadystatechange = function() {
			if (doc2.readyState == XMLHttpRequest.DONE) {
				if (doc2.responseText.length > 4) {
		   			iconLabelsJson = JSON.parse(doc2.responseText);
 				}
			}
		}  
		doc2.open("GET", wasteExtraIconsURL + "iconLabels.txt", true);
		doc2.send();
	}


	function readWasteDates() {

		if (wasteCollector == "1") {
			readMijnafvalwijzerHTML();
		}
		if (wasteCollector == "31") {
			readMijnafvalwijzerHTML();
		}
		if (wasteCollector == "22") {
			readMijnafvalwijzer();  //afvalstoffendienstcalender, same format
		}
		if (wasteCollector == "2") {   
			readDeafvalapp();
		}
		if (wasteCollector == "6") {   
			readCureAfvalbeheerNew();		//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "9") {
			readIok();
		}
		if (wasteCollector == "10") {
			readLimburgNet();
		}
		if (wasteCollector == "11") {
			readDenHaag();
		}
		if (wasteCollector == "12") {
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "13") {
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "14") {
			readMijnafvalwijzerHTML();
		}
		if (wasteCollector == "15") {
			readAfvalalert();
		}
		if ((wasteCollector == "17") || (wasteCollector == "28"))  {
			readRd4info();
		}
		if (wasteCollector == "3") {   
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "5") {   
			readCureAfvalbeheer();		//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "8") {   
			readCureAfvalbeheer();		//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "20") {   
			readCureAfvalbeheer();		//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "4") {   
			readCureAfvalbeheerNew();		//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "7") {   
			readCureAfvalbeheerNew();		//only waste description and date formatting differs from cure-afvalbeheer
		}
		if (wasteCollector == "16") {   
			read2goMobile();			//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "18") {   
			readCureAfvalbeheerNew();		//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "23") {   
			readCureAfvalbeheerNew();		//only waste description differs from cure-afvalbeheer
		}
		if (wasteCollector == "24") {   
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "26") {   
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "27") {   
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "19") {   
			readDrimmelen();
		}
		if (wasteCollector == "21") {   
			readOmrin();
//			readOmrinDirect(); under development
		}
		if (wasteCollector == "25") {		//only waste description and date formatting differs from cure-afvalbeheer
			readAreaAfval();
		}
		if (wasteCollector == "29") {		//only waste description and date formatting differs from cure-afvalbeheer
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "30") {
			read2goMobile();
		}
		if (wasteCollector == "32") {
			readGroningen();
		}
		if (wasteCollector == "33") {
			read2goMobile();
		}
		if (wasteCollector == "34") {
			read2goMobile();
		}
		if (wasteCollector == "35") {
			read2goMobile();
		}
		if (wasteCollector == "36") {
			read2goMobile();
		}
		if (wasteCollector == "37") {
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "38") {
			read2goMobile();
		}
		if (wasteCollector == "39") {
			readCureAfvalbeheerNew();
		}
		if (wasteCollector == "40") {
			readCureAfvalbeheerNew();
		}
	}

	function wasteTypeMijnafvalwijzer(shortName) {
			switch (shortName) {
				case "grofvuil": return 8;
				case "grofvuil\\/oud ijzer": return 8;
				case "tuinafval": return 4;
				case "papier": return 2;
				case "gft": return 3;
				case "gft-afval": return 3;
				case "gft+e(tensresten)": return 3;
				case "opk": return 2;
				case "pmd": return 1;
				case "pbd": return 1;
				case "gft ": return 3;
				case "groente, fruit en tuinafval": return 3;
				case "pbd": return 2;
				case "restafval": return 0;
				case "fijn huishoudelijk restafval": return 0;
				case "takken": return 4;
				case "kerstbomen": return 4;
				case "papier & karton": return 2;
				case "papier en karton": return 2;
				case "los papier": return 2;
				case "plastic verpakking & drankkartons": return 1;
				case "plastic, metalen en drankkartons": return 1;
				case "plastic, blik en drankenkartons": return 1;
				case "plastic": return 1;
				case "grofvuil (op afroep)": return 8;
				case "snoeihout (op afroep)": return 4;
				case "reinigen containers": return "z";
				default: break;
			}
		return "?";
	}

	function wasteTypeCureAfvalbeheer(shortName) {
		switch (shortName) {
			case "De res": return 0;	//area-afval.nl
			case "Het re": return 0;	//area-afval.nl
			case "Zet uw": return 0;	//area-afval.nl
			case "Het gf": return 3;	//area-afval.nl
			case "De con": return 1;	//area-afval.nl
			case "Groent": return 3;	//cyclusnv plus cureafvalbeheer gad.nl
			case "Groent": return 3;	//cyclusnv plus cureafvalbeheer gad.nl
			case "Groene": return 3;	//katwijk.nl
			case "GFT wo": return 3;	//cranendonck.nl
			case "Gft & ": return 3;	//hvcgroep.nl
			case "gft & ": return 3;	//hvcgroep.nl
			case "Gft-af": return 3;	//meppel.nl
			case "Gft en": return 3;	//spaarnelanden.nl
			case "Papier": return 2;	//cureafvalbeheer plus cranendonck.nl gad.nl
			case "papier": return 2;	//hvc
			case "Oud pa": return 2;	//cyclusnv.nl
			case "Plasti": return 1;	//cyclusnv.nl plus cranendonck.nl gad.nl
			case "plasti": return 1;	//hvc
			case "PMD-za": return 1;	//cyclusnv.nl plus cranendonck.nl gad.nl
			case "PMD-af": return 1;	//cyclusnv.nl plus cranendonck.nl gad.nl
			case "PMD": return 1;		//rmn
			case "Restaf": return 0;	//cyclusnv plus cureafvalbeheer gad.nl
			case "restaf": return 0;	//hvc
			case "Grijze": return 0;	//katwijk.nl
			case "Rest w": return 0;	//cranendonck.nl
			case "Textie": return 5;	//gad.nl
			case "Chemok": return 7;	//veldhoven.nl
			case "Klein ": return 7;	//cyclus nv
			case "VET-go": return 7;	//meppel.nl
			case "GFT": return 3;
			default: break;
		}
		return "?";
	}

	function wasteTypeRmn(shortName) {
		switch (shortName) {
			case "Gro": return 3;
			case "Pap": return 2;
			case "PMD": return 1;
			case "Res": return 0;
			default: break;
		}
		return "?";
	}


	function wasteTypeMeerlanden(shortName) {  //and zrd.nl circulus-berkel.nl alphenaandenrijn.nl as well
		switch (shortName) {
			case "GFT": return 3;
			case "Gft": return 3;
			case "Res": return 0;
			case "Pla": return 1;
			case "Gla": return 2;
			case "PMD": return 1;
			case "Pap": return 2;
			case "Tak": return 4;
			case "Tex": return 5;
			case "KCA": return 7;
			case "Gro": return 8;
			default: break;
		}
		return "?";
	}

	function wasteTypeHvcgroep(shortName) {
		switch (shortName) {
			case "GFT": return 3;
			case "PMD": return 1;
			case "PAPIER": return 2;
			case "REST": return 0;
			default: break;
		}
		return "?";
	}

	function wasteTypeCranendonck(shortName) {
		switch (shortName) {
			case "GFT ": return 3;
			case "Papi": return 2;
			case "Plas": return 1;
			case "Rest": return 0;
			default: break;
		}
		return "?";
	}

	function wasteTypeDarNL(shortName) {
		switch (shortName) {
			case "Gft-a": return 3;
			case "Papie": return 2;
			case "Plast": return 1;
			case "Resta": return 0;
			default: break;
		}
		return "?";
	}

	function wasteTypeIokBe(shortName) {
		switch (shortName) {
			case "GV": return 8;		//groot vuil
			case "KG": return 7;		//klein gevaarlijk (chemisch) afval
			case "SP": return 6;		//steen, puin
			case "TE": return 5;		//textiel
			case "GF": return 3;
			case "P/": return 2;
			case "PM": return 1;
			case "RA": return 0;
			default: break;
		}
		return "?";
	}

	function wasteTypeLimburgNet(shortName) {
		switch (shortName) {
			case "kun": return 9;		//kunststoffen
			case "hui": return 0;		//huisvuil
			case "tui": return 4;		//tuin en snoeiafval
			case "gro": return 8;		//grofvuil
			case "pap": return 2;		//papier en karton
			case "tex": return 5;		//textiel
			case "pmd": return 1;		//plastic metaal drankpakken
			default: break;
		}
		return "?";
	}

	function wasteTypeDenHaag(shortName) {
		switch (shortName) {
			case "GFT": return 3;		//groente/fruit		//denhaag.nl
			case "Res": return 0;		//huisvuil			//denhaag.nl + rmn.nl
			case "Pap": return 2;		//papier en karton		//denhaag.nl
			case "Ker": return 4;		//kerstbomen (snoeiafval)
			case "Gro": return 3;		//groente/fruit		//rmn.nl
			case "Pap": return 2;		//papier en karton		//rmn.nl
			case "PMD": return 1;		//plastic metaal drankpakken//rmn.nl
			case "Tex": return 5;		//textiel			//rmn.nl
			default: break;
		}
		return "?";
	}

	function wasteTypeArnhem(shortName) {
		switch (shortName) {
			case "Ophaaldag GFT": return 3;		//groente/fruit	
			case "Ophaaldag Res": return 0;		//huisvuil
			case "Ophaaldag Pap": return 2;		//papier en karton
			case "Ophaaldag Pla": return 1;		//plastic, drankpakken, metaal
			case "Ophaaldag Tex": return 5;		//textiel
			default: break;
		}
		return "?";
	}

	function wasteTypeRd4info(shortName) {
		switch (shortName) {
			case "GFT": return 3;		//groente/fruit	
			case "Restafval": return 0;		//huisvuil
			case "PMD-afval": return 1;		//plastic metaal drankpakken
			case "Oud papier": return 2;		//papier en karton
			case "Snoeiafval op afspraak": return 4;		//tuin en snoeiafval
			case "Kerstbomen": return 4;		//tuin en snoeiafval
			case "BEST-tas": return "!";		//BEST-tas
			default: break;
		}
		return "?";
	}

	function wasteTypeAfvalalert(shortName) {
		switch (shortName) {
			case "gft": return 3;		//groente/fruit	
			case "res": return 0;		//huisvuil
			case "mil": return 1;		//milieu boer
			case "pap": return 2;		//papier
			default: break;
		}
		return "?";
	}

	function wasteType2goMobile(shortName) {
		switch (shortName) {
			case "GREEN": return 3;		//groente/fruit	
			case "PAPER": return 2;		//papier
			case "PACKAGES": return 1;	//pmd
			case "PLASTIC": return 1;	//pmd
			case "VET": return 7;		//KGA meppel.nl
			case "GREY": return 0;		//restafval
			default: break;
		}
		return "?";
	}

	function fullMonth(monthNum) {
		switch (monthNum) {
			case "01": return "januari";
			case "02": return "februari";
			case "03": return "maart";
			case "04": return "april";
			case "05": return "mei";
			case "06": return "juni";
			case "07": return "juli";
			case "08": return "augustus";
			case "09": return "september";
			case "10": return "oktober";
			case "11": return "november";
			case "12": return "december";
			default: break;
		}
		return "error_month";
	}

	function formatWasteDate(dateyymmdd) {
		var today = new Date();
		var todayPlus1Date = new Date(today.getTime() + (24 * 60 * 60 * 1000));
		var todayPlus2Date = new Date(today.getTime() + (48 * 60 * 60 * 1000));

		if (dateyymmdd == formatDate(today)) {
			return "Vandaag";
		} else {
			if (dateyymmdd == formatDate(todayPlus1Date)) {
				return "Morgen";
			} else {
				if (dateyymmdd == formatDate(todayPlus2Date)) {
					return "Overmorgen";
				} else {
					return dateyymmdd.substring(8,10) + " " + fullMonth(dateyymmdd.substring(5,7));
				}
			}
		}
	}

	function readOmrinDirect() {

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("POST", "https://www.omrin.nl/bij-mij-thuis/afval-regelen/afvalkalender", true);
        	xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        	xmlhttp.setRequestHeader("Content-length", 0);
//        	xmlhttp.setRequestHeader("Connection", "close");
       		xmlhttp.setRequestHeader("zipcode", wasteZipcode.substring(0,4));
       		xmlhttp.setRequestHeader("zipcodeend", wasteZipcode.substring(4,6));
       		xmlhttp.setRequestHeader("housenumber", wasteHouseNr);
       		xmlhttp.setRequestHeader("addition", "");
       		xmlhttp.setRequestHeader("Connection", "close");
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
  				var doc4 = new XMLHttpRequest();
   				doc4.open("PUT", "file:///var/volatile/tmp/omrin_source.txt");
   				doc4.send(xmlhttp.responseText);

				var i = 0;
				var j = 0;
				var k = 0;
				var l = 0;
				var m = 0;
				var n = 0;
				wasteDatesString = "";
				var wasteType = "";
				var omrinAfvalbeheerDates = [];
				var omrinYear = "";
				var monthStr = "";
				var aNode = xmlhttp.responseText;

				i = aNode.indexOf("omrinDataGroups");
	 			aNode = aNode.slice(i);	
				i = aNode.indexOf("{");
	 			aNode = aNode.slice(i);
			
				// read year

				omrinYear = aNode.substring(2,6);

				//read sortibak entries

				i = aNode.indexOf("Sortibak");
				m = aNode.indexOf("dates", i);

				for (k = 1; k < 13; k++) {

					monthStr = ("00" + k).slice(-2);
					i = aNode.indexOf('"' + k + '"', m);
					n = aNode.indexOf("[", i);
					m = aNode.indexOf("]", i);
					var monthDates = aNode.substring(n + 1, m).split(',');  //get array for the month

					for (l = 0; l < monthDates.length; l++) {
						omrinAfvalbeheerDates.push(omrinYear + "-" + monthStr + "-" + monthDates[l].replace(/['"]+/g, '') + ",0");    //restafval
					}
				}

				//read biobak entries

				i = aNode.indexOf("Biobak");
				m = aNode.indexOf("dates", i);

				for (k = 1; k < 13; k++) {

					monthStr = ("00" + k).slice(-2);
					i = aNode.indexOf('"' + k + '"', m);
					n = aNode.indexOf("[", i);
					m = aNode.indexOf("]", i);
					var monthDates = aNode.substring(n + 1, m).split(',');  //get array for the month

					for (l = 0; l < monthDates.length; l++) {
						omrinAfvalbeheerDates.push(omrinYear + "-" + monthStr + "-" + monthDates[l].replace(/['"]+/g, '') + ",3");    //gft
					}
				}

				//read oudpapier entries (contribution by Arcidodo , thanks)

				i = aNode.indexOf("Oud Papier en Karton");
				m = aNode.indexOf("dates", i);

				for (k = 1; k < 13; k++) {
					monthStr = ("00" + k).slice(-2);
					i = aNode.indexOf('"' + k + '"', m);
					n = aNode.indexOf("[", i);
					m = aNode.indexOf("]", i);
					var monthDates = aNode.substring(n + 1, m).split(',');  //get array for the month

					for (l = 0; l < monthDates.length; l++) {
						omrinAfvalbeheerDates.push(omrinYear + "-" + monthStr + "-" + monthDates[l].replace(/['"]+/g, '') + ",2");    //oudpapier
					}
				}

				var tmp = WastecollectionJS.sortArray2(omrinAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.send();
	}

	function read2goMobile() {

		if (wasteCollector == "33") {   //barAfvalbeheer.nl
	       		var params = "companyCode=bb58e633-de14-4b2a-9941-5bc419f1c4b0&postCode=" + wasteZipcode + "&houseNumber=" + wasteHouseNr + "&houseLetter=&houseNumberAddition=";
		}
		if (wasteCollector == "34") {   //twentemilieu.nl
	       		var params = "companyCode=8d97bb56-5afd-4cbc-a651-b4f7314264b4&postCode=" + wasteZipcode + "&houseNumber=" + wasteHouseNr + "&houseLetter=&houseNumberAddition=";
		}
		if (wasteCollector == "35") {   //reinis.nl
	       		var params = "companyCode=9dc25c8a-175a-4a41-b7a1-83f237a80b77&postCode=" + wasteZipcode + "&houseNumber=" + wasteHouseNr + "&houseLetter=&houseNumberAddition=";
		}
		if (wasteCollector == "36") {   //hellendoorn.nl
	       		var params = "companyCode=24434f5b-7244-412b-9306-3a2bd1e22bc1&postCode=" + wasteZipcode + "&houseNumber=" + wasteHouseNr + "&houseLetter=&houseNumberAddition=";
		}
		if (wasteCollector == "38") {   //almere.nl
	       		var params = "companyCode=53d8db94-7945-42fd-9742-9bbc71dbe4c1&postCode=" + wasteZipcode + "&houseNumber=" + wasteHouseNr + "&houseLetter=&houseNumberAddition=";
		}
		if (wasteCollector == "16") {   //meerlanden.nl
	       		var params = "companyCode=800bf8d7-6dd1-4490-ba9d-b419d6dc8a45&postCode=" + wasteZipcode + "&houseNumber=" + wasteHouseNr + "&houseLetter=&houseNumberAddition=";
		}
		if (wasteCollector == "30") {   //meppel.nl
	       		var params = "companyCode=b7a594c7-2490-4413-88f9-94749a3ec62a&postCode=" + wasteZipcode + "&houseNumber=" + wasteHouseNr + "&houseLetter=&houseNumberAddition=";
		}
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("POST", "https://wasteapi.2go-mobile.com/api/FetchAdress", true);
        	xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        	xmlhttp.setRequestHeader("Content-length", params.length);
        	xmlhttp.setRequestHeader("Connection", "close");
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				addressJson = JSON.parse(xmlhttp.responseText);
				read2goMobileCalendar(addressJson['dataList'][0]['UniqueId']);
			}
		}
		xmlhttp.send(params);
	}

	function read2goMobileCalendar(uniqueId) {

		var now = new Date;
		var strMonNow = now.getMonth() + 1;
		if (strMonNow < 10) {
			strMonNow = "0" + strMonNow;
		}
		var strDayNow = now.getDate();
		if (strDayNow < 10) {
			strDayNow = "0" + strDayNow;
		}

		var later = new Date(now.getTime() + 7772000000); // 3 months later
		var strMonLater = later.getMonth() + 1;
		if (strMonLater < 10) {
			strMonLater = "0" + strMonLater;
		}
		var strDayLater = later.getDate();
		if (strDayLater < 10) {
			strDayLater = "0" + strDayLater;
		}

		var startDate = now.getFullYear() + "-" + strMonNow + "-" +  strDayNow; 
		var endDate = later.getFullYear() + "-" + strMonLater + "-" +  strDayLater;

		if (wasteCollector == "33") {   //barAfvalbeheer.nl
    	   		var params = "companyCode=bb58e633-de14-4b2a-9941-5bc419f1c4b0&uniqueAddressId=" + uniqueId + "&startDate=" + startDate + "&endDate=" + endDate;
		}
		if (wasteCollector == "34") {   //twentemilieu.nl
    	   		var params = "companyCode=8d97bb56-5afd-4cbc-a651-b4f7314264b4&uniqueAddressId=" + uniqueId + "&startDate=" + startDate + "&endDate=" + endDate;
		}
		if (wasteCollector == "35") {   //reinis.nl
    	   		var params = "companyCode=9dc25c8a-175a-4a41-b7a1-83f237a80b77&uniqueAddressId=" + uniqueId + "&startDate=" + startDate + "&endDate=" + endDate;
		}
		if (wasteCollector == "36") {   //hellendoorn.nl
	       		var params = "companyCode=24434f5b-7244-412b-9306-3a2bd1e22bc1&uniqueAddressId=" + uniqueId + "&startDate=" + startDate + "&endDate=" + endDate;
		}
		if (wasteCollector == "38") {   //almere.nl
	       		var params = "companyCode=53d8db94-7945-42fd-9742-9bbc71dbe4c1&uniqueAddressId=" + uniqueId + "&startDate=" + startDate + "&endDate=" + endDate;
		}
		if (wasteCollector == "16") {   //meerlanden.nl
	       		var params = "companyCode=800bf8d7-6dd1-4490-ba9d-b419d6dc8a45&uniqueAddressId=" + uniqueId + "&startDate=" + startDate + "&endDate=" + endDate;
		}
		if (wasteCollector == "30") {   //meppel.nl
	       		var params = "companyCode=b7a594c7-2490-4413-88f9-94749a3ec62a&uniqueAddressId=" + uniqueId + "&startDate=" + startDate + "&endDate=" + endDate;
		}

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("POST", "https://wasteapi.2go-mobile.com/api/GetCalendar", true);
        	xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        	xmlhttp.setRequestHeader("Content-length", params.length);
        	xmlhttp.setRequestHeader("Connection", "close");
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				wasteDatesString = "";
				var wasteType = "";
				var mobileAfvalbeheerDates = [];
				calendar2goMobile = JSON.parse(xmlhttp.responseText)
				for (var i= 0; i < calendar2goMobile['dataList'].length; i++) {
					for (var j= 0; j < calendar2goMobile['dataList'][i]['pickupDates'].length; j++) {
						if (calendar2goMobile['dataList'][i]['_pickupTypeText'] == "GREENGREY") {
							mobileAfvalbeheerDates.push(calendar2goMobile['dataList'][i]['pickupDates'][j].substring(0,10) + "-" + wasteType2goMobile("GREEN"));
							mobileAfvalbeheerDates.push(calendar2goMobile['dataList'][i]['pickupDates'][j].substring(0,10) + "-" + wasteType2goMobile("GREY"));
						} else {
							mobileAfvalbeheerDates.push(calendar2goMobile['dataList'][i]['pickupDates'][j].substring(0,10) + "-" + wasteType2goMobile(calendar2goMobile['dataList'][i]['_pickupTypeText']));
						}
					}
				}
				var tmp = WastecollectionJS.sortArray2(mobileAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.send(params);
	}

	function readOmrin() {

		var i = 0;
		var j = 0;
		var k = 0;
		var l = 0;
		var m = 0;
		var n = 0;
		wasteDatesString = "";
		var wasteType = "";
		var omrinAfvalbeheerDates = [];
		var omrinYear = "";
		var monthStr = "";

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				i = aNode.indexOf("omrinDataGroups");
	 			aNode = aNode.slice(i);	
				i = aNode.indexOf("{");
	 			aNode = aNode.slice(i);
			
				// read year

				omrinYear = aNode.substring(2,6);

				//read sortibak entries

				i = aNode.indexOf("Sortibak");
				m = aNode.indexOf("dates", i);

				for (k = 1; k < 13; k++) {

					monthStr = ("00" + k).slice(-2);
					i = aNode.indexOf('"' + k + '"', m);
					n = aNode.indexOf("[", i);
					m = aNode.indexOf("]", i);
					var monthDates = aNode.substring(n + 1, m).split(',');  //get array for the month

					for (l = 0; l < monthDates.length; l++) {
						omrinAfvalbeheerDates.push(omrinYear + "-" + monthStr + "-" + monthDates[l].replace(/['"]+/g, '') + ",0");    //restafval
					}
				}

				//read biobak entries

				i = aNode.indexOf("Biobak");
				m = aNode.indexOf("dates", i);

				for (k = 1; k < 13; k++) {

					monthStr = ("00" + k).slice(-2);
					i = aNode.indexOf('"' + k + '"', m);
					n = aNode.indexOf("[", i);
					m = aNode.indexOf("]", i);
					var monthDates = aNode.substring(n + 1, m).split(',');  //get array for the month

					for (l = 0; l < monthDates.length; l++) {
						omrinAfvalbeheerDates.push(omrinYear + "-" + monthStr + "-" + monthDates[l].replace(/['"]+/g, '') + ",3");    //gft
					}
				}

				//read oudpapier entries (contribution by Arcidodo , thanks)

				i = aNode.indexOf("Oud Papier en Karton");
				m = aNode.indexOf("dates", i);

				for (k = 1; k < 13; k++) {
					monthStr = ("00" + k).slice(-2);
					i = aNode.indexOf('"' + k + '"', m);
					n = aNode.indexOf("[", i);
					m = aNode.indexOf("]", i);
					var monthDates = aNode.substring(n + 1, m).split(',');  //get array for the month

					for (l = 0; l < monthDates.length; l++) {
						omrinAfvalbeheerDates.push(omrinYear + "-" + monthStr + "-" + monthDates[l].replace(/['"]+/g, '') + ",2");    //oudpapier
					}
				}

				var tmp = WastecollectionJS.sortArray2(omrinAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "file:///root/waste/omrin.htm", true);
		xmlhttp.send();
	}


	function readArnhem() {
	
		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				// read specific waste collection dates

				i = aNode.indexOf("DTSTART");

				if ( i > 0 ) {
					while (i > 0) {
						j = aNode.indexOf("SUMMARY", i);

						wasteType = wasteTypeArnhem(aNode.substring(j+8, j+21));
						cureAfvalbeheerDates.push(aNode.substring(i+19, i+23) + "-" + aNode.substring(i+23, i+25) + "-" + aNode.substring(i+25, i+27) + "," + wasteType);
						i = aNode.indexOf("DTSTART", i + 10);
					}
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "http://www.afvalwijzer-arnhem.nl/GenerateICal.ashx?ZipCode=" + wasteZipcode + "&HouseNumber=" + wasteHouseNr + "&HouseNumberAddition=&categories=", true);
		xmlhttp.send();
	}

	function readLimburgNet() {
	
		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				// read specific waste collection dates

				j = aNode.indexOf("BEGIN:VEVENT");
				i = aNode.indexOf("DTSTART",j);

				if ( i > 0 ) {
					while (i > 0) {
						j = aNode.indexOf("SUMMARY", i);

						wasteType = wasteTypeLimburgNet(aNode.substring(j+8, j+11));
						cureAfvalbeheerDates.push(aNode.substring(i+19, i+23) + "-" + aNode.substring(i+23, i+25) + "-" + aNode.substring(i+25, i+27) + "," + wasteType);
						i = aNode.indexOf("DTSTART", i + 10);
					}
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "http://www.limburg.net/ics/afvalkalender/" + wasteZipcode + "/" + wasteStreet + "/" + wasteHouseNr + "/0", true);
		xmlhttp.send();
	}

	function formatDate(date) {
    		var d = new Date(date),
        	month = '' + (d.getMonth() + 1),
        	day = '' + d.getDate(),
        	year = d.getFullYear();
		if (month.length < 2) month = '0' + month;
		if (day.length < 2) day = '0' + day;
		return [year, month, day].join('-');
	}

	function readRd4info() {

		var i = 0;
		var j = 0;
		var k = 0;
		var l = 0;
		var m = 0;
		var d = new Date();
		var tmpdate = "";
		var n = "yyyy-mm-dd";
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();

		xmlhttp.onreadystatechange = function() {

			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				// read specific waste collection dates

				i = aNode.indexOf("<strong>Januari");
				j = aNode.indexOf("</div>", i);
				k = aNode.indexOf("<td>", i);
				while ( k < j ) {
					l = aNode.indexOf("</td>", k);
					m = aNode.indexOf(" ", k);
					tmpdate = aNode.substring(m+1, l);
					tmpdate = tmpdate.replace("januari", "january");
					tmpdate = tmpdate.replace("februari", "february");
					tmpdate = tmpdate.replace("maart", "march");
					tmpdate = tmpdate.replace("juni", "june");
					tmpdate = tmpdate.replace("mei", "may");
					tmpdate = tmpdate.replace("juli", "july");
					tmpdate = tmpdate.replace("augustus", "august");
					tmpdate = tmpdate.replace("oktober", "october");
					d = new Date(tmpdate);
					n = formatDate(d);
					k = aNode.indexOf("<td>", l);
					l = aNode.indexOf("</td>", k);
					wasteType = wasteTypeRd4info(aNode.substring(k+4, l));
					cureAfvalbeheerDates.push(n + "," + wasteType);
					k = aNode.indexOf("<td>", l);
					if (k < 0) k = j;
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		} 
		if (wasteCollector == "17") {
			xmlhttp.open("GET", "https://www.rd4info.nl/NSI/Burger/Aspx/afvalkalender_public_text.aspx?pc=" + wasteZipcode + "&nr=" + wasteHouseNr + "&t=", true);
		} else {
			xmlhttp.open("GET", "file:///root/waste/rd4info.txt", true);
		}
		xmlhttp.send();
	}

	function readDenHaag() {

		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				// read specific waste collection dates

				i = aNode.indexOf("DTSTART");
				if (i > 0) {
					if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
				}


				if ( i > 0 ) {
					while (i > 0) {
						j = aNode.indexOf("SUMMARY", i);
						wasteType = wasteTypeDenHaag(aNode.substring(j+8, j+11));
						cureAfvalbeheerDates.push(aNode.substring(i+8, i+12) + "-" + aNode.substring(i+12, i+14) + "-" + aNode.substring(i+14, i+16) + "," + wasteType);
						i = aNode.indexOf("DTSTART", i + 10);
						if (i > 0) {
							if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
						}

					}
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "file:///root/waste/waste_calendar.ics", true);
		xmlhttp.send();
	}


	function readIok() {
	
		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				// read specific waste collection dates

				i = aNode.indexOf("DTSTART");

				if ( i > 0 ) {
					while (i > 0) {
						j = aNode.indexOf("SUMMARY", i);

						wasteType = wasteTypeIokBe(aNode.substring(j+8, j+10));
						if (wasteType !== 8) {   // ignore 8 and 6 (groot vuil and steen/puin)
							if (wasteType !== 6) {
								cureAfvalbeheerDates.push(aNode.substring(i+31, i+35) + "-" + aNode.substring(i+35, i+37) + "-" + aNode.substring(i+37, i+39) + "," + wasteType);
							}
						}
						i = aNode.indexOf("DTSTART", i + 10);
					}
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "http://www.iok.be/afvalkalender.ics?st=" + wasteStreet + "&pc=" + wasteZipcode + "&z=-1", true);
		xmlhttp.send();
	}

	// cure-afvalbeheer via dseparate download of ICS file (old method)

	function readAreaAfval() {
	
		var i = 0;
		var j = 0;
		var k = 0;
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				// read specific waste collection dates
				i = aNode.indexOf("DTSTART");

				if (i > 0) {
					if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
				}

				if ( i > 0 ) {
					while (i > 0) {
						j = aNode.indexOf("SUMMARY", i);

						wasteType = wasteTypeMeerlanden(aNode.substring(j+23, j+26)); //also for area-afval.nk

						if (wasteType = "?") {
							wasteType = wasteTypeMeerlanden(aNode.substring(j+8, j+11)); //also for area-afval.nk
						}
						cureAfvalbeheerDates.push(aNode.substring(i+8, i+12) + "-" + aNode.substring(i+12, i+14) + "-" + aNode.substring(i+14, i+16) + "," + wasteType);

						k = aNode.indexOf("END:VEVENT", j);
						if (k < 0) {
							i = -1;
						} else {
							i = aNode.indexOf("DTSTART", k);
						}

						if (i > 0) {
							if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
						}
					}
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "file:///root/waste/waste_calendar.ics", true);
		xmlhttp.send();
	}

	// cure-afvalbeheer via dseparate download of ICS file (old method)

	function readCureAfvalbeheer() {
	
		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				var aNode = xmlhttp.responseText;

				// read specific waste collection dates

				if (wasteCollector == "5") {  //katwijk.nl
					i = aNode.indexOf("DTSTAMP");
				}
				else {
					i = aNode.indexOf("DTSTART");
				}

				if (i > 0) {
					if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
				}

				if ( i > 0 ) {
					while (i > 0) {
						j = aNode.indexOf("SUMMARY", i);

						if ((wasteCollector == "7") || (wasteCollector == "8")) {  //dar.nl or cranendock.nl
							if (wasteCollector == "7") {   //dar.nl
								wasteType = wasteTypeDarNL(aNode.substring(j+23, j+28));
							} else {
								wasteType = wasteTypeCureAfvalbeheer(aNode.substring(j+23, j+29));
							}
							cureAfvalbeheerDates.push(aNode.substring(i+19, i+23) + "-" + aNode.substring(i+23, i+25) + "-" + aNode.substring(i+25, i+27) + "," + wasteType);
						} else {
							if ((wasteCollector == "16") || (wasteCollector == "20") || (wasteCollector == "39")) {   //meerlanden.nl
								wasteType = wasteTypeMeerlanden(aNode.substring(j+8, j+11));   //also for circulus-berkel.nl
							} else {
								if (wasteCollector == "30") {   //meppel.nl
									wasteType = wasteTypeCureAfvalbeheer(aNode.substring(j+23, j+29));
								} else {
									wasteType = wasteTypeCureAfvalbeheer(aNode.substring(j+8, j+14));
								}
							}
							cureAfvalbeheerDates.push(aNode.substring(i+8, i+12) + "-" + aNode.substring(i+12, i+14) + "-" + aNode.substring(i+14, i+16) + "," + wasteType);
						}

						if (wasteCollector == "5") {  //katwijk.nl
							i = aNode.indexOf("DTSTAMP", i + 10);
						}
						else {
							i = aNode.indexOf("DTSTART", i + 10);
						}

						if (i > 0) {
							if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
						}
					}
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);

				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "file:///root/waste/waste_calendar.ics", true);
		xmlhttp.send();
	}

	function wasteTypeDrimmelen(shortName) {
		switch (shortName) {
			case "GFT": return 3;
			case "Pap": return 2;
			case "Pla": return 1;
			case "Res": return 0;
			default: break;
		}
		return "?";
	}

	function readDrimmelen() {
	
		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var DrimmelenDates = [];
		var xmlhttp = new XMLHttpRequest(); 
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) { 
					var aNode = xmlhttp.responseText;

					i = aNode.indexOf("DTSTART;VALUE=DATE:");
					if ( i > 0 ) {
						while (i > 0) {
							j = aNode.indexOf("SUMMARY", i); 
							wasteType = wasteTypeDrimmelen(aNode.substring(j+27, j+30)); 
							DrimmelenDates.push(aNode.substring(i+19, i+23) + "-" + aNode.substring(i+23, i+25) + "-" + aNode.substring(i+25, i+27) + "," + wasteType);
								// Get next event
							i = aNode.indexOf("DTSTART;VALUE=DATE:", i + 19);
						}
					}
					var tmp = WastecollectionJS.sortArray2(DrimmelenDates, extraDates); 

					for (i = 0; i < tmp.length; i++) {
						wasteDatesString = wasteDatesString + tmp[i] + "\n";
					}
					writeWasteDates();
				}
			}
		}
		xmlhttp.open("GET", "https://drimmelen.nl/trash-removal-calendar/ical/" + wasteZipcode + "/" + wasteHouseNr, true);
		xmlhttp.send();

	} 

	function readCureAfvalbeheerNew() {

		var i = 0;
		var j = 0;
		var k = 0;
		wasteDatesString = "";
		var wasteType = "";
		var cureAfvalbeheerDates = [];
		var toDay = new Date();

		var xmlhttp = new XMLHttpRequest();

		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var aNode = xmlhttp.responseText;

					// read specific waste collection dates check DATE format

					i = aNode.indexOf("DTSTART");
					if (i > 0) {
						if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
					}

					if ( i > 0 ) {
						while (i > 0) {
							j = aNode.indexOf("SUMMARY", i);
							k = aNode.indexOf("\n", j);

							if (wasteCollector == "7") {  //dar.nl
								wasteType = wasteTypeDarNL(aNode.substring(j+8, j+13));
							} else {
								if ((wasteCollector == "16") || (wasteCollector == "18") || (wasteCollector == "39")) {   //meerlanden.nl or zrd.nl
									wasteType = wasteTypeMeerlanden(aNode.substring(j+8, j+11));
								} else {
									if (wasteCollector == "12") {   //rmn.nl
										wasteType = wasteTypeRmn(aNode.substring(j+8, j+11));
									} else {
										if (wasteCollector == "23") {  // alphenaandenrijn.nl
											wasteType = wasteTypeMeerlanden(aNode.substring(j+8, j+11));
										} else {
											if (wasteCollector == "27") { //venlo.nl  (split Restafval/pmd)
												wasteType = wasteTypeCureAfvalbeheer(aNode.substring(j+23, k-1));
												if (aNode.substring(j+23, j+36) == "Restafval/PMD") {
													wasteType = "0"; // Restafval
													cureAfvalbeheerDates.push(aNode.substring(i+8, i+12) + "-" + aNode.substring(i+12, i+14) + "-" + aNode.substring(i+14, i+16) + "," + wasteType);
													wasteType = "1"; // pmd
												}
											} else {
												if (wasteCollector == "40") { //spaarnelanden.nl  (split papier/pmd)
													wasteType = wasteTypeCureAfvalbeheer(aNode.substring(j+8, j+14));
													if (aNode.substring(j+8, j+14) == "Duobak") {
														wasteType = "2"; // papier
														cureAfvalbeheerDates.push(aNode.substring(i+8, i+12) + "-" + aNode.substring(i+12, i+14) + "-" + aNode.substring(i+14, i+16) + "," + wasteType);
														wasteType = "1"; // pmd
													}
												} else {
													wasteType = wasteTypeCureAfvalbeheer(aNode.substring(j+8, j+14));
												}
											}
										}
									}
								}
							}

							cureAfvalbeheerDates.push(aNode.substring(i+8, i+12) + "-" + aNode.substring(i+12, i+14) + "-" + aNode.substring(i+14, i+16) + "," + wasteType);

							i = aNode.indexOf("DTSTART", i + 10);
			
							if (i > 0) {
								if (aNode.substring(i, i+18) == "DTSTART;VALUE=DATE") i = i + 11;
							}

						}
					}	
				}
				var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);
				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		} 
		if (wasteCollector == "3") {
			xmlhttp.open("GET", "https://afvalkalender.cure-afvalbeheer.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "4") {
			xmlhttp.open("GET", "https://afvalkalender.cyclusnv.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "6") {
			xmlhttp.open("GET", "https://inzamelkalender.hvcgroep.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "7") {
			xmlhttp.open("GET", "https://afvalkalender.dar.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "12") {
			xmlhttp.open("GET", "https://inzamelschema.rmn.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "13") {
			xmlhttp.open("GET", "https://inzamelwijzer.suez.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "18") {
			xmlhttp.open("GET", "http://afvalkalender.zrd.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "23") {
			xmlhttp.open("GET", "https://afvalkalender.alphenaandenrijn.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "24") {
			xmlhttp.open("GET", "https://www.avalex.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "26") {
			xmlhttp.open("GET", "https://inzamelkalender.gad.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "27") {
			xmlhttp.open("GET", "https://www.venlo.nl/trash-removal-calendar/ical/" + wasteZipcode + "/" + wasteHouseNr, true);
		}
		if (wasteCollector == "29") {
			xmlhttp.open("GET", "https://www.veldhoven.nl/afvalkalender/" + toDay.getFullYear() + "/" + wasteZipcode + "-" + wasteHouseNr + ".ics", true);
		}
		if (wasteCollector == "37") {
			xmlhttp.open("GET", "https://inzamelkalender.stadswerk072.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "39") {
			xmlhttp.open("GET", "https://afvalkalender.purmerend.nl/ical/" + wasteICSId, true);
		}
		if (wasteCollector == "40") {
			xmlhttp.open("GET", "https://afvalwijzer.spaarnelanden.nl/ical/" + wasteICSId, true);
		}
		xmlhttp.send();
	}
                                               
	function readMijnafvalwijzer() {
	
		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var wasteCodeHTML = "";
		var cureAfvalbeheerDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var aNode = xmlhttp.responseText;

					// read specific waste collection dates

					i = aNode.indexOf("nameType");
					if ( i > 0 ) {
                                          j = aNode.indexOf("mededelingen",i);
                                          aNode = aNode.slice(i-1,j);
                                          i = aNode.indexOf("nameType");
						while (i > 0) {
	 						aNode = aNode.slice(i);
							j = aNode.indexOf('"', 12);
							wasteType = wasteTypeMijnafvalwijzer(aNode.substring(11, j));
							wasteCodeHTML = aNode.substring(11, j);
							if ((wasteCodeHTML == "rest- & gft-afval") || (wasteCodeHTML == "rest-gft") || (wasteCodeHTML == "restafval & gft") || (wasteCodeHTML == "restgft")) {   //split rest & gft in two dates
								wasteType = wasteTypeMijnafvalwijzer("restafval");
								i = aNode.indexOf("date");
								cureAfvalbeheerDates.push(aNode.substring(i+7, i+17) + "," + wasteType);
								wasteType = wasteTypeMijnafvalwijzer("gft");
								cureAfvalbeheerDates.push(aNode.substring(i+7, i+17) + "," + wasteType);
							} else {
								if ((wasteCodeHTML == "papier\\/pmd") || (wasteCodeHTML == "dhm")) {   //split papier and pmd in two dates
									wasteType = wasteTypeMijnafvalwijzer("papier");
									i = aNode.indexOf("date");
									cureAfvalbeheerDates.push(aNode.substring(i+7, i+17) + "," + wasteType);
									wasteType = wasteTypeMijnafvalwijzer("pmd");
									cureAfvalbeheerDates.push(aNode.substring(i+7, i+17) + "," + wasteType);
								} else {
									if (wasteCodeHTML == "gft en pmd") {   //split gft and pmd in two dates
										wasteType = wasteTypeMijnafvalwijzer("gft");
										i = aNode.indexOf("date");
										cureAfvalbeheerDates.push(aNode.substring(i+7, i+17) + "," + wasteType);
										wasteType = wasteTypeMijnafvalwijzer("pmd");
										cureAfvalbeheerDates.push(aNode.substring(i+7, i+17) + "," + wasteType);		
									} else {
										wasteType = wasteTypeMijnafvalwijzer(aNode.substring(11, j));
										i = aNode.indexOf("date");
										cureAfvalbeheerDates.push(aNode.substring(i+7, i+17) + "," + wasteType);
									}
								}
							}
							i = aNode.indexOf("nameType", 10);
						}
					}
					var tmp = WastecollectionJS.sortArray2(cureAfvalbeheerDates, extraDates);
					for (i = 0; i < tmp.length; i++) {
						wasteDatesString = wasteDatesString + tmp[i] + "\n";
					}
					writeWasteDates();
				}
			}
		}
		if (wasteCollector == "1") {
			xmlhttp.open("GET", "http://json.mijnafvalwijzer.nl/?method=postcodecheck&postcode=" + wasteZipcode + "&street=&huisnummer=" + wasteHouseNr + "&toevoeging=", true);
		}
		if (wasteCollector == "22") {
			xmlhttp.open("GET", "http://json.afvalstoffendienstkalender.nl/?method=postcodecheck&postcode=" + wasteZipcode + "&street=&huisnummer=" + wasteHouseNr + "&toevoeging=", true);
		}
		xmlhttp.send();
	}

	function readMijnafvalwijzerHTML() {

		var i = 0;
		var j = 0;
		var k = 0;
		var l = 0;
		var endList = 0;

		wasteDatesString = "";
		var wasteType = "";
		var wasteCodeHTML = "";
		var resultDates = [];
		var mijnAfvalwijzerDates = [];
		var wasteDateYMD = "";
		var wasteYear = "";

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var aNode = xmlhttp.responseText;

					// read specific waste collection dates

					i = aNode.indexOf("jaar-");
					j = aNode.indexOf('"', i);
					wasteYear = aNode.substring(i + 5,j);

					i = aNode.indexOf("#waste-", i);
					aNode = aNode.slice(i);
					i = 0;

					endList = aNode.indexOf("section");  //stop here

					if ( i < endList) {
						while (i < endList) {
							j = aNode.indexOf('"', i);
							wasteCodeHTML = aNode.substring(i + 7,j);
							j = aNode.indexOf('"' + wasteCodeHTML, i);

							k = aNode.indexOf('span-line-break', j);
							l = aNode.indexOf('<', k);

							resultDates =  aNode.substring(k + 1, l).split(" ");
	
							if (resultDates.length == 4) {
								wasteDateYMD = resultDates[3] + "-" + decodeMonth(resultDates[2]) + "-" + resultDates[1];
							} else {
								wasteDateYMD = wasteYear + "-" + decodeMonth(resultDates[2]) + "-" + resultDates[1];
							}

							if ((wasteCodeHTML == "rest- & gft-afval") || (wasteCodeHTML == "rest-gft") || (wasteCodeHTML == "restafval & gft") || (wasteCodeHTML == "restgft")) {   //split rest & gft in two dates
								wasteType = wasteTypeMijnafvalwijzer("restafval");
								i = aNode.indexOf("date");
								mijnAfvalwijzerDates .push(wasteDateYMD + "," + wasteType);
								wasteType = wasteTypeMijnafvalwijzer("gft");
								mijnAfvalwijzerDates .push(wasteDateYMD + "," + wasteType);
							} else {
								if ((wasteCodeHTML == "papier\\/pmd") || (wasteCodeHTML == "dhm")) {   //split papier and pmd in two dates
									wasteType = wasteTypeMijnafvalwijzer("papier");
									i = aNode.indexOf("date");
									mijnAfvalwijzerDates .push(wasteDateYMD + "," + wasteType);
									wasteType = wasteTypeMijnafvalwijzer("pmd");
									mijnAfvalwijzerDates .push(wasteDateYMD + "," + wasteType);		
								} else {
									wasteType = wasteTypeMijnafvalwijzer(wasteCodeHTML);
									i = aNode.indexOf("date");
									mijnAfvalwijzerDates .push(wasteDateYMD + "," + wasteType);
								}
							}

							i = aNode.indexOf("#waste-", l);
						}
					}

					var tmp = WastecollectionJS.sortArray2(mijnAfvalwijzerDates , extraDates);
					for (i = 0; i < tmp.length; i++) {
						wasteDatesString = wasteDatesString + tmp[i] + "\n";
					}
					writeWasteDates();
				}
			}
		}
		if (wasteCollector == "14") {
			xmlhttp.open("GET", "https://inzamelkalender.rova.nl/nl/" + wasteZipcode + "/" + wasteHouseNr, true);
		}
		if ((wasteCollector == "31") ||  (wasteCollector == "1")) {
			xmlhttp.open("GET", "https://www.mijnafvalwijzer.nl/nl/" + wasteZipcode + "/" + wasteHouseNr, true);
		}
		xmlhttp.send();
	}

	function readGroningen() {

		var i = 0;
		var j = 0;
		var k = 0;
		var l = 0;
		var n = 0;
		var o = 0;
		var endList = 0;
		var month = "00";
		var day = "00";

		wasteDatesString = "";
		var wasteType = "";
		var wasteCodeHTML = "";
		var resultDates = [];
		var mijnAfvalwijzerDates = [];
		var wasteDateYMD = "";
		var wasteYear = "";
		var toDay = new Date();

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var aNode = xmlhttp.responseText;

					// read specific waste collection dates

					i = aNode.indexOf('<table class="afvalwijzerData"');
					j = aNode.indexOf('</table', i);
                                        aNode = aNode.slice(i,j);

					wasteYear = toDay.getFullYear();

						// process kleding & textiel

					i = aNode.indexOf("<h2>Kleding, textiel en schoenen</h2>");

					if (i > 0 ) {
						for (var m = 1; m < 13; m++) {	// loop for all months
							month = "0" + m; 
							k = aNode.indexOf('td class="m-' + month.substring(month.length - 2) + '"', i);
							l = aNode.indexOf('</td', k);
							n = aNode.indexOf('<li>', k);
							if (n > 0 ) {	// at least one date found for this month
								while ((n < l) && (n > 0)) {
									o = aNode.indexOf('</li', n);
									if ((o > 0) && (o < l)) {
										day = "0" + aNode.substring(n + 4, o);
										mijnAfvalwijzerDates.push(wasteYear + "-" + month.substring(month.length - 2) + "-" + day.substring(day.length - 2) + ",5");
										n = aNode.indexOf('<li', o);									
									} else {
										n = l + 1;
									}									
								}
							}
						}
					}

						// process oud papier

					i = aNode.indexOf("<h2>Oud papier</h2>", k);

					if (i > 0 ) {
						for (var m = 1; m < 13; m++) {	// loop for all months
							month = "0" + m; 
							k = aNode.indexOf('td class="m-' + month.substring(month.length - 2) + '"', i);
							l = aNode.indexOf('</td', k);
							n = aNode.indexOf('<li>', k);
							if (n > 0 ) {	// at least one date found for this month
								while ((n < l) && (n > 0)) {
									o = aNode.indexOf('</li', n);
									if ((o > 0) && (o < l)) {
										day = "0" + aNode.substring(n + 4, o);
										mijnAfvalwijzerDates.push(wasteYear + "-" + month.substring(month.length - 2) + "-" + day.substring(day.length - 2) + ",2");
										n = aNode.indexOf('<li', o);									
									} else {
										n = l + 1;
									}									
								}
							}
						}
					}

						// process chemocar

					i = aNode.indexOf("<h2>Standplaats Chemokar</h2>", k);

					if (i > 0 ) {
						for (var m = 1; m < 13; m++) {	// loop for all months
							month = "0" + m; 
							k = aNode.indexOf('td class="m-' + month.substring(month.length - 2) + '"', i);
							l = aNode.indexOf('</td', k);
							n = aNode.indexOf('<li>', k);
							if (n > 0 ) {	// at least one date found for this month
								while ((n < l) && (n > 0)) {
									o = aNode.indexOf('</li', n);
									if ((o > 0) && (o < l)) {
										day = "0" + aNode.substring(n + 4, o);
										mijnAfvalwijzerDates.push(wasteYear + "-" + month.substring(month.length - 2) + "-" + day.substring(day.length - 2) + ",7");
										n = aNode.indexOf('<li', o);
									} else {
										n = l + 1;
									}									
								}
							}
						}
					}

					var tmp = WastecollectionJS.sortArray2(mijnAfvalwijzerDates , extraDates);
					for (i = 0; i < tmp.length; i++) {
						wasteDatesString = wasteDatesString + tmp[i] + "\n";
					}
					writeWasteDates();
				}
			}
		}
		xmlhttp.open("GET", "https://gemeente.groningen.nl/afvalwijzer/groningen/" + wasteZipcode + "/" + wasteHouseNr + "/" + toDay.getFullYear(), true);
		xmlhttp.send();
	}

	function readAfvalalert() {
	
		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var alertDates = [];

		var xmlhttp = new XMLHttpRequest();

		xmlhttp.onreadystatechange = function() {

			if (xmlhttp.readyState == XMLHttpRequest.DONE) {

				var aNode = xmlhttp.responseText;

				// read specific waste collection dates

				i = aNode.indexOf('"date"');

				if ( i > 0 ) {
					while (i > 0) {
						j = aNode.indexOf('"type"', i);
						wasteType = wasteTypeAfvalalert(aNode.substring(j+8, j+11));
						alertDates.push(aNode.substring(i+8, i+18) + "," + wasteType);
						i = aNode.indexOf('"date"', j);
					}
				}
				var tmp = WastecollectionJS.sortArray2(alertDates, extraDates);
				for (i = 0; i < tmp.length; i++) {
					wasteDatesString = wasteDatesString + tmp[i] + "\n";
				}
				writeWasteDates();
			}
		}
		xmlhttp.open("GET", "https://www.afvalalert.nl/kalender/" + wasteZipcode + "/" + wasteHouseNr, true);
		xmlhttp.send();
	}



	function readDeafvalapp() {
	
		var indexGFT = 0;
		var indexPAPIER = 0;
		var indexREST = 0;
		var indexPLASTIC = 0;	

		var i = 0;
		var j = 0;
		wasteDatesString = "";
		var wasteType = "";
		var fileDate = "";
		var lastGFTfileDate = "";
		var lastPAPIERfileDate = "";
		var lastPLASTICfileDate = "";
		var lastRESTfileDate = "";
		var deafvalappDates = [];

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var aNode = xmlhttp.responseText;

					// read start index of all wastetypes

					indexGFT = aNode.indexOf("GFT");
					indexPAPIER = aNode.indexOf("PAPIER");
					indexPLASTIC = aNode.indexOf("PLASTIC");
					if (indexPLASTIC < 0) indexPLASTIC = aNode.indexOf("PMD");
					if (indexPLASTIC < 0) indexPLASTIC = aNode.indexOf("PBP");
					indexREST = aNode.indexOf("REST");
					if (indexREST < 0) indexREST = aNode.indexOf("ZAK_BLAUW");


					// find first dates in the future of each type - GFT for 2 years
 
					if (indexGFT > -1) {
						i = aNode.indexOf(';', indexGFT);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_3")
							i = aNode.indexOf(';', i+1);
						}
					}
					indexGFT = aNode.indexOf("GFT", indexGFT + 10); //process second year block if available
					if (indexGFT > -1) {
						i = aNode.indexOf(';', indexGFT);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_3")
							i = aNode.indexOf(';', i+1);
						}
					}
					
					// find first dates in the future of each type - PAPIER

					if (indexPAPIER > -1) {
						i = aNode.indexOf(';', indexPAPIER);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_2")
							i = aNode.indexOf(';', i+1);
						}
					}
					indexPAPIER = aNode.indexOf("PAPIER", indexPAPIER + 10);
					if (indexPAPIER > -1) {
						i = aNode.indexOf(';', indexPAPIER);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_2")
							i = aNode.indexOf(';', i+1);
						}
					}
					
					// find first dates in the future of each type - PLASTIC

					if (indexPLASTIC > -1) {
						i = aNode.indexOf(';', indexPLASTIC);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_1")
							i = aNode.indexOf(';', i+1);
						}
					}
					var indexPLASTIC2 = aNode.indexOf("PLASTIC", indexPLASTIC  + 10);
					if (indexPLASTIC2 < 0) indexPLASTIC2 = aNode.indexOf("PMD", indexPLASTIC  + 10);
					if (indexPLASTIC2 < 0) indexPLASTIC2 = aNode.indexOf("PBP", indexPLASTIC  + 10);
					if (indexPLASTIC2 > -1) {
						i = aNode.indexOf(';', indexPLASTIC2);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_1")
							i = aNode.indexOf(';', i+1);
						}
					}
					
					// find first dates in the future of each type - REST

					if (indexREST > -1) {
						i = aNode.indexOf(';', indexREST);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_0")
							i = aNode.indexOf(';', i+1);
						}
					}
					var indexREST2 = aNode.indexOf("REST", indexREST + 10);
					if (indexREST2 < 0) indexREST2 = aNode.indexOf("ZAK_BLAUW", indexREST + 10);
					if (indexREST2 > -1) {
						i = aNode.indexOf(';', indexREST2);
						while (aNode.substring(i+7, i+9) == "20") {
							fileDate = aNode.substring(i+7, i + 11) + "-" + aNode.substring(i+4, i+6) + "-" + aNode.substring(i+1, i+3);
							deafvalappDates.push(fileDate + "_0")
							i = aNode.indexOf(';', i+1);
						}
					}
					

					// sort dates

					var tmp = WastecollectionJS.sortArray2(deafvalappDates, extraDates);

					for (i = 0; i < tmp.length; i++) {
						wasteDatesString = wasteDatesString + tmp[i] + "\n";
					}
					writeWasteDates();
				}
			}
		}
		xmlhttp.open("GET", "http://dataservice.deafvalapp.nl/dataservice/DataServiceServlet?service=OPHAALSCHEMA&land=NL&postcode=" + wasteZipcode + "&huisnr=" + wasteHouseNr + "&huisnrtoev=", true);
		xmlhttp.send();
	}

	function initWasteDates() {
		
		// add extra dates first
		var tmp = WastecollectionJS.sortArray(extraDates);
		wasteDatesString = "";
		for (var i = 0; i < tmp.length; i++) {
			wasteDatesString = wasteDatesString + tmp[i] + "\n";
		}
		writeWasteDates();
	}

	function writeWasteDates() {
   		var doc2 = new XMLHttpRequest();
   		doc2.open("PUT", "file:///var/volatile/tmp/wasteDates.txt");
   		doc2.send(wasteDatesString);

		// create ICS file for use in the calendar app when requested

		if (enableCreateICS) {
			var outputICS = "";
			var tmpICS = wasteDatesString.split("\n");

			for (var i = 0; i < tmpICS.length; i++) {
				if (tmpICS[i].length > 10) { 
					outputICS = outputICS + "BEGIN:VEVENT\r\n";
					outputICS = outputICS + "DTSTART;VALUE=DATE:" + tmpICS[i].substring(0,4) + tmpICS[i].substring(5,7) + tmpICS[i].substring(8,10) + "\r\n";
					outputICS = outputICS + "SUMMARY:" + wasteTypeFriendlyName(tmpICS[i].substring(11,12)) + "\r\n";
					outputICS = outputICS + "BEGIN:VEVENT\r\n";
				}
			}
   			var doc3 = new XMLHttpRequest();
   			doc3.open("PUT", "file:///var/volatile/tmp/wasteDates.ics");
   			doc3.send(outputICS);

		}
	}

	// write icondata to tmp file to for use in Thermostat App (optional)

	function writeWasteIconData() {
   		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///var/volatile/tmp/wasteDateIcon.txt");
   		doc3.send(wasteIcon);
	}

	function writeWasteIconData2() {
   		var doc4 = new XMLHttpRequest();
   		doc4.open("PUT", "file:///var/volatile/tmp/wasteDateIcon2.txt");
   		doc4.send(wasteIcon2);
	}

	function wasteTypeFriendlyName(wasteCode) {
		if (((wasteCode >= "0") && (wasteCode <= "9")) || (wasteCode == "!") || (wasteCode == "z") || (wasteCode == "?"))  {
			switch (wasteCode) {
				case "9" : return "Kunststoffen";
				case "8" : return "Groot vuil";
				case "7" : return "KGA";
				case "6" : return "Steen en puin";
				case "5" : return "Textiel";
				case "4" : return "Snoeiafval";
				case "3" : return "Groente/Fruit/Tuinafval";
				case "2" : return "Papier/karton";
				case "1" : return "Plastic/Metaal/Drankpakken";
				case "0" : return "Restafval";
				case "!" : return "BEST tas";
				case "z" : return "Reinigen container";
				case "?" : return "Onbekend";
				default: break;
			}
		} else {
			try {
				if (iconLabelsJson.hasOwnProperty(wasteCode)) {
					return iconLabelsJson [wasteCode];
				}
			} catch (e) {
				return "-";
			}
		}
	}

	function wasteIconURL(wasteCode) {
		if (wasteCustomIcons) 
			var wasteIconLocation = wasteExtraIconsURL
		else
			var wasteIconLocation = "file:///qmf/qml/apps/wastecollection/drawables/";

		if (((wasteCode >= "0") && (wasteCode <= "9")) || (wasteCode == "!")) {
			switch (wasteCode) {
				case "9" : return wasteIconLocation + "kunststofDim.png";
				case "8" : return wasteIconLocation + "grootvuilDim.png";
				case "7" : return wasteIconLocation + "kgaDim.png";
				case "6" : return wasteIconLocation + "puinDim.png";
				case "5" : return wasteIconLocation + "textielDim.png";
				case "4" : return wasteIconLocation + "snoeiafvalDim.png";
				case "3" : return wasteIconLocation + "gftDim.png";
				case "2" : return wasteIconLocation + "papierDim.png";
				case "1" : return wasteIconLocation + "pmdDim.png";
				case "0" : return wasteIconLocation + "restafvalDim.png";
				case "!" : return wasteIconLocation + "best.png";
				default: break;
			}
		} else {   //extra Icons
			return wasteExtraIconsURL + wasteCode + ".png";
		}
	}

	function readCollectedWasteDates(searchStrWasteIconHour, searchStrMidnight, reset) {

		var fileWasteDate = "";
		wasteIcon = "";
		wasteIcon2 = "";
		writeWasteIconData();
		writeWasteIconData2();
		if (reset == "yes") {
			wasteIconShow = false;
			wasteIcon2Show = false;
			wasteIconBackShow = false;
			wasteIcon2BackShow = false;
		}
		wasteDateNext = "";
		wasteDateNextType = "";
		wasteDateNext2 = "";
		wasteDateNext2Type = "";
		wasteDateNext3 = "";
		wasteDateNext3Type = "";
		wasteControlIcon = "qrc:/tsc/iconBack.png";
		wastecollectionListDates = "";
		var counter = 0;
		var i = 0;
		var wastefile= new XMLHttpRequest();
		wastefile.onreadystatechange = function() {
			if (wastefile.readyState == XMLHttpRequest.DONE) {
				var response = wastefile.responseText;
				for (i = 0; i < response.length/13; i++) {
					fileWasteDate = response.slice(i*13,i*13+10);

					if (counter > 2) {
						counter = counter + 1;
						if (counter < 20) {
							wastecollectionListDates = wastecollectionListDates + "  " + response.slice(i*13,i*13+10) + "   -   " + wasteTypeFriendlyName(response.slice(i*13+11,i*13+12))  + "\n";
						}
					}
					if (counter == 2) {
						counter = 3; 
						wasteDateNext3Type = wasteTypeFriendlyName(response.slice(i*13+11,i*13+12));
						wasteDateNext3 = formatWasteDate(response.slice(i*13,i*13+10));
						wastecollectionListDates = wastecollectionListDates + "  " + response.slice(i*13,i*13+10) + "   -   " + wasteDateNext3Type  + "\n";
					}
					if (counter == 1) {
						counter = 2;
						wasteDateNext2Type = wasteTypeFriendlyName(response.slice(i*13+11,i*13+12));
						wasteDateNext2 = formatWasteDate(response.slice(i*13,i*13+10));
						wastecollectionListDates = wastecollectionListDates + "  " + response.slice(i*13,i*13+10) + "   -   " + wasteDateNext2Type  + "\n";
						
						if ((response.slice(i*13+11,i*13+12) >= "A") && (response.slice(i*13+11,i*13+12) <= "Z")) {   // special dates, only switch at Midnight

							if (searchStrMidnight.localeCompare(fileWasteDate) == 0) {
								if (reset == "yes") {
									wasteIcon2Show = true;
									wasteIconShow = false;
								}
								wasteIcon2 = wasteIconURL(response.slice(i*13+11,i*13+12));
								writeWasteIconData2();
							}

						} else {  //switch at hour according to the settings

							if (searchStrWasteIconHour.localeCompare(fileWasteDate) == 0) {
								if (reset == "yes") {
									wasteIcon2Show = true;
									wasteIconShow = false;
								}
								wasteIcon2 = wasteIconURL(response.slice(i*13+11,i*13+12));
								writeWasteIconData2();
							}
						}
					}

					if (counter == 0) {

						if ((response.slice(i*13+11,i*13+12) >= "A") && (response.slice(i*13+11,i*13+12) <= "Z")) {   // special dates, only switch at Midnight

							if (searchStrMidnight.localeCompare(fileWasteDate) <= 0) {
								counter = 1;
								wasteDateNextType = wasteTypeFriendlyName(response.slice(i*13+11,i*13+12));
								wasteDateNext = formatWasteDate(response.slice(i*13,i*13+10));
								wastecollectionListDates = "  " + response.slice(i*13,i*13+10) + "   -   " + wasteDateNextType  + "\n";
								if (searchStrMidnight.localeCompare(fileWasteDate) == 0) {
									if (reset == "yes") {
										wasteIconShow = true;
									}
									wasteIcon = wasteIconURL(response.slice(i*13+11,i*13+12));
									writeWasteIconData();
								}
							}

						} else {  //switch at hour according to the settings

							if (searchStrWasteIconHour.localeCompare(fileWasteDate) <= 0) {
								counter = 1;
								wasteDateNextType = wasteTypeFriendlyName(response.slice(i*13+11,i*13+12));
								wasteDateNext = formatWasteDate(response.slice(i*13,i*13+10));
								wastecollectionListDates = "  " + response.slice(i*13,i*13+10) + "   -   " + wasteDateNextType  + "\n";
								if (searchStrWasteIconHour.localeCompare(fileWasteDate) == 0) {
									if (reset == "yes") {
										wasteIconShow = true;
									}
									wasteIcon = wasteIconURL(response.slice(i*13+11,i*13+12));
									writeWasteIconData();
								}
							}
						}
					}
				}
			}
		}
		wastefile.open("GET", "file:///var/volatile/tmp/wasteDates.txt", true);
		wastefile.send();
	}

	/// calculates miliseconds till next wasteIconHour from now
	function getMSecTill6oclock() {
		var now = new Date();
		var nowUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds(),now.getMilliseconds());
		var addaday = 0;
		if (now.getHours() >= wasteIconHour) {
			addaday = 1;
		}
		var sixOclock = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate() + addaday, wasteIconHour, 0, 0, 0);
		return sixOclock - nowUtc;
	}

	/// calculates miliseconds till 00:00:01 for update labels on the tile
	function getMSecTill12oclock() {
		var now = new Date();
		var nowUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds(),now.getMilliseconds());
		var twelveOclock = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 1, 0);
		return twelveOclock - nowUtc;
	}

	function decodeMonth(month) {

		switch (month) {
			case "januari": return "01";
			case "februari": return "02";
			case "maart": return "03";
			case "april": return "04";
			case "mei": return "05";
			case "juni": return "06";
			case "juli": return "07";
			case "augustus": return "08";
			case "september": return "09";
			case "oktober": return "10";
			case "november": return "11";
			case "december": return "12";
			default: break;
		}
		return "??";
	}

	function updateWasteIcon(reset) {

		var now = new Date( (new Date)*1 + 1000 * 3600 * (24 - wasteIconHour));
		var strMon = now.getMonth() + 1;
		if (strMon < 10) {
			strMon = "0" + strMon;
		}
		var strDay = now.getDate();
		if (strDay < 10) {
			strDay = "0" + strDay;
		}
		var searchDateStrIconHour = now.getFullYear() + "-" + strMon + "-" +  strDay;

		var now2 = new Date();
		var strMon2 = now2.getMonth() + 1;
		if (strMon2 < 10) {
			strMon2 = "0" + strMon2;
		}
		var strDay2 = now2.getDate();
		if (strDay2 < 10) {
			strDay2 = "0" + strDay2;
		}
		var searchDateStrMidNight = now2.getFullYear() + "-" + strMon2 + "-" +  strDay2;
		readCollectedWasteDates(searchDateStrIconHour, searchDateStrMidNight, reset);
		writeWasteIconData();
	}

	function restartTimerAfterConfigChange() {

		extraDates = [];
		readExtraDates();
		getExtraIconLabels();
		readWasteDates();
		wasteIconBackShow = false;
		wasteIcon2BackShow = false;
		datetimeTimerWasteMidNight.stop();
		datetimeTimerWasteMidNight.interval = 15000;	
		datetimeTimerWasteMidNight.restart();
		datetimeTimerWaste.stop();
		datetimeTimerWaste.interval = getMSecTill6oclock();
		var now = new Date();
		datetimeTimerWaste.restart();
	}

	Timer {
		id: datetimeTimerWaste
		repeat: true
		running: false
		interval: isNxt ? 20000 : 180000	//wait (1)20 sec after reboot before for triggering, after that only at wasteIconHour (default 18:00) daily

		onTriggered: {
			updateWasteIcon("yes");	//update data on tile
			readExtraDates();
			readWasteDates();	//get new calender update for display from next day onwards (although refresh once a day is a bit often maybe)
			interval = getMSecTill6oclock();
			datetimeTimerWasteMidNight.interval = getMSecTill12oclock();
			datetimeTimerWasteMidNight.start();
		}
	}

	Timer {
		id: datetimeTimerWasteMidNight
		repeat: true
		running: false
		onTriggered: {
			updateWasteIcon("no");	//update data on tile (labels vandaag, morgen, overmorgen), no reset of back arrow icons
			interval = getMSecTill12oclock(); 
		}
	}
}
