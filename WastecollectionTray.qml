import QtQuick 1.1
import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: wastecollectionSystrayIcon
	property string objectName: "wastecollectionTray"

	visible: app.enableSystray
	posIndex: 8000

	onClicked: {
		stage.openFullscreen(app.wastecollectionListDatesScreenUrl);
	}

	Image {
		id: imgwastecollection
		anchors.centerIn: parent
		source: "./drawables/waste_icon.png"
	}

}
