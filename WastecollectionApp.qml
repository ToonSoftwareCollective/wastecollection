import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
import "wastecollectionProvider.js" as WastecollectionProviderJS

/// Application to manage retrieve the list of date for the waste bin collection
/// Actual display is handled via the ThermostatApp.qml and/or via the Tile

App {
	id: wastecollectionApp

	property string wasteCollector : "10"
			//possible values for now: 	1: "mijnafvalwijzer.nl"
			//				2: "deafvalapp.nl"
			//				3: "prezero.nl"
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
			//				41: "RAD Hoeksewaard"
			//				42: "mijnblink.nl"
			//				43 : ACV groep Veenedaal e.o.
			//				0: "overig (handmatig)"
			//		
	property string wasteZipcode : "72030"	// or PC variable for iok.be / limburg.net
	property string wasteHouseNr : "2"
	property string wasteStreet : "223"
	property string wasteCity : ""
	property string wasteStreetName : ""
	property string wasteICSId: "0"

    	signal wasteVersionCheckSignal(string actionArgument)

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
	property string wasteFullICSUrl 
	property variant addressJson
	property string wasteExtraDatesURL
	property string wasteExtraIconsURL
	property bool wasteDataRetrieved
	property variant iconLabelsJson : {}
	property bool scriptUpdateAvailable : false 
	property variant wasteSettingsJson : {
		'Afvalverwerker': "",
		'Postcode': "",
		'Huisnummer': "",
		'Straatnummer': "",
		'Gemeente': "",
		'Straatnaam': "",
		'ICSnummer': "",
		'DisplayIconVanafUur': "",
		'ExtraDatumsFile': "",
		'ExtraDatumsIconsFolder': "",
		'CustomIcons' : "No",
		'ThermostaatIcon' : "Yes",
		'TrayIcon' : "No",
		'CreateICS' : "No",
		'wasteFullICSUrl' : "https://"
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
			"Gemeente": wasteCity,
			"Straatnaam": wasteStreetName,
			"ICSnummer" : wasteICSId,
			"DisplayIconVanafUur" : wasteIconHour,
			"ExtraDatumsFile" : wasteExtraDatesURL,
			"ExtraDatumsIconsFolder" : wasteExtraIconsURL,
			"CustomIcons" : strCustomIcons,
			"ThermostaatIcon" : strThermostatMod,
			"CreateICS" : strCreateICS,
			"TrayIcon" : strSystray,
			"ICSUrl" : wasteFullICSUrl
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
						var tmp = WastecollectionProviderJS.sortArray2(extraDates, []);
						for (i = 0; i < tmp.length; i++) {
							wasteDatesString = wasteDatesString + tmp[i] + "\n";
						}
						WastecollectionProviderJS.writeWasteDates(wasteDatesString, []);
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
		if (wasteSettingsJson ['Huisnummer']) wasteHouseNr = wasteSettingsJson ['Huisnummer'];
		if (wasteSettingsJson ['Straatnummer']) wasteStreet = wasteSettingsJson ['Straatnummer'];
		if (wasteSettingsJson ['Postcode']) wasteZipcode = wasteSettingsJson ['Postcode'];
		if (wasteSettingsJson ['ICSnummer']) wasteICSId = wasteSettingsJson ['ICSnummer'];
		if (wasteSettingsJson ['Afvalverwerker']) wasteCollector = wasteSettingsJson ['Afvalverwerker'];
		if (wasteSettingsJson ['ExtraDatumsFile']) wasteExtraDatesURL = wasteSettingsJson ['ExtraDatumsFile'];
		if (wasteSettingsJson ['ExtraDatumsIconsFolder']) wasteExtraIconsURL = wasteSettingsJson ['ExtraDatumsIconsFolder'];
		if (wasteSettingsJson ['DisplayIconVanafUur']) wasteIconHour = wasteSettingsJson ['DisplayIconVanafUur'];
		if (wasteSettingsJson ['CreateICS']) enableCreateICS = (wasteSettingsJson ['CreateICS'] == "Yes");
		if (wasteSettingsJson ['ThermostaatIcon']) enableThermostatMod = (wasteSettingsJson ['ThermostaatIcon'] == "Yes");
		if (wasteSettingsJson ['CustomIcons']) wasteCustomIcons = (wasteSettingsJson ['CustomIcons'] == "Yes");
		if (wasteSettingsJson ['TrayIcon']) enableSystray = (wasteSettingsJson ['TrayIcon'] == "Yes");
		if (wasteSettingsJson ['ICSUrl']) wasteFullICSUrl = wasteSettingsJson ['ICSUrl'];
		if (wasteSettingsJson ['Gemeente']) wasteCity = wasteSettingsJson ['Gemeente'];
		if (wasteSettingsJson ['Straatnaam']) wasteStreetName = wasteSettingsJson ['Straatnaam'];

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

		wasteDataRetrieved = false;
		WastecollectionProviderJS.readCalendar(wasteZipcode, wasteHouseNr, extraDates, enableCreateICS, wasteICSId, wasteStreet, wasteStreetName, wasteCity, wasteFullICSUrl) ; 
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

	function formatDate(date) {
    		var d = new Date(date),
        	month = '' + (d.getMonth() + 1),
        	day = '' + d.getDate(),
        	year = d.getFullYear();
		if (month.length < 2) month = '0' + month;
		if (day.length < 2) day = '0' + day;
		return [year, month, day].join('-');
	}


	function initWasteDates() {
		
		// add extra dates first
		wasteDatesString = "";
		for (var i = 0; i < extraDates.length; i++) {
			wasteDatesString = wasteDatesString + extraDates[i] + "\n";
		}
		writeWasteDates(wasteDatesString, []);
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
			tscsignals.tscSignal("wastecollection", "perform javascript version check");
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
