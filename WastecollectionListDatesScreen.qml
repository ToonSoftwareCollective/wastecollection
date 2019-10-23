import QtQuick 1.1
import qb.components 1.0

Screen {
	id: wastecollectionListDatesScreen
	screenTitle: "Komende afval ophaaldagen"

	onShown: {
		addCustomTopRightButton("Instellingen");
	}

	onCustomButtonClicked: {
		if (app.wastecollectionConfigurationScreen) {
			 app.wastecollectionConfigurationScreen.show();
		}
	}

	hasBackButton : true

	Rectangle {
		id: backgroundRect
		height: isNxt ? 500 : 388
		width: isNxt ? 550 : 440
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 13 : 10
			left: parent.left
			leftMargin: isNxt ? 250 : 200
		}
//		color: colors.contrastBackground

	       Flickable {
	            id: flickArea
	             anchors.fill: parent
	             contentWidth: backgroundRect.width / 2;
			contentHeight: backgroundRect.height
	             flickableDirection: Flickable.VerticalFlick
	             clip: true

	            
		 TextEdit{
	                  id: forecastText
	                   wrapMode: TextEdit.Wrap
	                   width:backgroundRect.width
	                   readOnly:true
//			  color: colors.taWarningBox

				font {
					family: qfont.bold.name
					pixelSize: isNxt ? 23 : 18
				}

	                   text:  app.wastecollectionListDates
	            }
	      }
	}
}
