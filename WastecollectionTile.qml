import QtQuick 2.1
import qb.components 1.0


Tile {
	id: wastecollectionTile

	property bool dimState: screenStateController.dimmedColors
	bgColor: app.scriptUpdateAvailable ? "#FF0000" : "#FFFFFF"

	onClicked: {
		if (app.wastecollectionConfigurationScreen && app.scriptUpdateAvailable) {
			 app.wastecollectionConfigurationScreen.show();
		} else {
			if (app.wastecollectionListDatesScreen) app.wastecollectionListDatesScreen.show();
		}
	}

	Image {
		id: wasteIconzzBig
		source: app.wasteIcon
		anchors {
			baseline: parent.top
			baselineOffset: 10
			horizontalCenter: parent.horizontalCenter
		}
		cache: false
       		visible: dimState ? app.wasteIconShow : false		// only show if one icon
	}

	Image {
		id: wasteIconzzBigBack
		source: "qrc:/tsc/collectContainerDim.png"
		anchors {
			baseline: parent.top
			baselineOffset: 10
			horizontalCenter: parent.horizontalCenter
		}
		cache: false
       		visible: dimState ? app.wasteIconBackShow : false	// only show if one icon and container needs to be collected
	}	

	Image {
		id: wasteIconzzSmall1
		height: isNxt ? 125 : 100
		width: isNxt ? 125 : 100
		source: app.wasteIcon
		anchors {
			baseline: parent.top
			baselineOffset: 10
			left: parent.left
			leftMargin: 10
		}
		cache: false
       		visible: dimState ? app.wasteIcon2Show : false		// only show if two icons
	}

	Image {
		id: wasteIconzzSmall2
		height: isNxt ? 125 : 100
		width: isNxt ? 125 : 100
		source: app.wasteIcon2
		anchors {
			baseline: parent.top
			baselineOffset: 10
			right: parent.right
			rightMargin: 10
		}
		cache: false
       		visible: dimState ? app.wasteIcon2Show : false		// only show if two icons

	}

	Image {
		id: wasteIconzzSmall1Back
		height: isNxt ? 125 : 100
		width: isNxt ? 125 : 100
		source: "qrc:/tsc/collectContainerDim.png"
		anchors {
			baseline: parent.top
			baselineOffset: 10
			left: parent.left
			leftMargin: 10
		}
		cache: false
       		visible: dimState ? app.wasteIcon2BackShow : false	// only show if one icon and two containers needs to be collected
	}

	Image {
		id: wasteIconzzSmall2Back
		height: isNxt ? 125 : 100
		width: isNxt ? 125 : 100
		source: "qrc:/tsc/collectContainerDim.png"
		anchors {
			baseline: parent.top
			baselineOffset: 10
			right: parent.right
			rightMargin: 10
		}
		cache: false
       		visible: dimState ? app.wasteIcon2BackShow : false	// only show if one icon and two containers needs to be collected
	}

	Image {
		id: wasteIconHide
		source: app.wasteControlIcon
		anchors {
			baseline: parent.top
			right: parent.right
		}
		cache: false
       		visible: dimState ? false : (app.wasteIconShow || app.wasteIcon2Show) // only show in non-dim state if icons are displayed in dimstate
		MouseArea {
			id: hideIcon
			anchors.fill: parent
			onClicked: {
				if (app.wasteIconShow) {
					if (app.wasteIconBackShow) {
						app.wasteIconBackShow = false;
						app.wasteIconShow = false;
					} else {
						app.wasteIconBackShow = true;
						app.wasteControlIcon = "qrc:/tsc/iconHide.png";
					}
				}
				if (app.wasteIcon2Show) {
					if (app.wasteIcon2BackShow) {
						app.wasteIcon2BackShow = false;
						app.wasteIcon2Show = false;
					} else {
						app.wasteIcon2BackShow = true;
						app.wasteControlIcon = "qrc:/tsc/iconHide.png";
					}
				}
			}
		}
	}

	Text {
		id: tiletitle
		text: "Afvalkalender"
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 30 : 24
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 25 : 20
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       		visible: !dimState
	}

	Text {
		id: wastedatenext
		text: app.wasteDateNext
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 62 : 50
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       	visible: !dimState
	}

	Text {
		id: wastedatenexttype
		text: app.wasteDateNextType
		anchors {
			baseline: wastedatenext.bottom
			baselineOffset: isNxt ? 13 : 10
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 18 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        	visible: !dimState
	}

	Text {
		id: wastedatenext2
		text: app.wasteDateNext2
		anchors {
			baseline: wastedatenexttype.bottom
			baselineOffset: isNxt ? 25 : 20
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       	visible: !dimState
	}

	Text {
		id: wastedatenext2type
		text: app.wasteDateNext2Type
		anchors {
			baseline: wastedatenext2.bottom
			baselineOffset: isNxt ? 13 : 10
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 18 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        	visible: !dimState
	}

	Text {
		id: wastedatenext3
		text: app.wasteDateNext3
		anchors {
			baseline: wastedatenext2type.bottom
			baselineOffset: isNxt ? 25 : 20
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       	visible: !dimState
	}

	Text {
		id: wastedatenext3type
		text: app.wasteDateNext3Type
		anchors {
			baseline: wastedatenext3.bottom
			baselineOffset: isNxt ? 13 : 10
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 18 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        	visible: !dimState
	}
}
