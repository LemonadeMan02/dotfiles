// SearchField.qml
import QtQuick
import "../../services"


Rectangle {
  id: root

  property alias text: input.text
  property string placeholder: ""
  property string icon: ""

  // Navigazione e conferma: la lista sta fuori, quindi i tasti che la
  // riguardano escono di qui come segnali.
  signal accepted()
  signal cancelled()
  signal moveUp()
  signal moveDown()

  function forceFocus() { input.forceActiveFocus() }
  function clear()      { input.text = "" }

  implicitHeight: 40
  radius: Theme.radiusS
  antialiasing: true
  color: Theme.surfaceSolid

  Text {
    id: iconText
    anchors.left: parent.left
    anchors.leftMargin: Theme.spacingM
    anchors.verticalCenter: parent.verticalCenter
    text: root.icon
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconXs
    color: Theme.foregroundDim
  }

  TextInput {
    id: input

    anchors.left: iconText.right
    anchors.leftMargin: Theme.spacingM
    anchors.right: parent.right
    anchors.rightMargin: Theme.spacingM
    anchors.verticalCenter: parent.verticalCenter

    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    font.weight: Theme.weightNormal

    selectByMouse: true
    selectionColor: Theme.accent
    selectedTextColor: Theme.onAccent

    // TextInput non ha un placeholder: e' un Text sotto, visibile quando
    // il campo e' vuoto. TextField di Controls lo darebbe, ma insieme a
    // tutto il template da disattivare.
    Text {
      anchors.fill: parent
      verticalAlignment: Text.AlignVCenter
      visible: input.text === ""
      text: root.placeholder
      color: Theme.muted
      font: input.font
    }

    onAccepted: root.accepted()

    Keys.onEscapePressed: root.cancelled()
    Keys.onUpPressed:     root.moveUp()
    Keys.onDownPressed:   root.moveDown()

    // Tab si comporta come freccia giu': e' l'abitudine da terminale.
    Keys.onTabPressed:    root.moveDown()
  }
}
