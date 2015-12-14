import QtQuick 1.1
import "../../ICCustomElement"
import '..'

Item {
    function showMenu(){
        for(var i = 0; i < pages.length; ++i){
            pages[i].visible = false;
        }

        menu.visible = true;
    }
    property variant pages: []
    QtObject{
        id:pData
        property variant useNoUseText: [qsTr("NoUse"), qsTr("Use")]
    }

    Grid{
        id:menu
        x:6
        columns: 4
        spacing: 20
        CatalogButton{
            id:productMenuBtn
            text: qsTr("Product")
            icon: "../images/product.png"
            y:10
            x:10
            onButtonClicked: {
                productPage.visible = true;
                menu.visible = false;
            }
        }
        CatalogButton{
            id:valveSettingsMenuBtn
            text: qsTr("Valve Settings")
            icon: "../images/product.png"
            onButtonClicked: {
                valveSettings.visible = true;
                menu.visible = false;
            }
        }
    }

    ICSettingConfigsScope{
        id:productPage
        visible: false
        width: parent.width
        height: parent.height
        y:10
        x:10
        //        color: "green"
        //        width: parent.width
        //        height: parent.height
        //        anchors.fill: parent
        //        anchors.top: parent.top
        //        anchors.bottom: parent.bottom
        Row{
            spacing: 10
            Column{
                ICComboBoxConfigEdit{
                    id:program0
                    width: 120
                    height: 32
                    configName: qsTr("Program0")
                    configAddr: "m_rw_0_1_0_357"
                    items: pData.useNoUseText
                    z:10
                }
                ICComboBoxConfigEdit{
                    id:program1
                    width: 120
                    height: 32
                    configName: qsTr("Program1")
                    configAddr: "m_rw_1_1_0_357"
                    items: pData.useNoUseText
                    z:9

                }
                ICComboBoxConfigEdit{
                    id:program2
                    width: 120
                    height: 32
                    configName: qsTr("Program2")
                    configAddr: "m_rw_2_1_0_357"
                    items: pData.useNoUseText
                    z:8

                }
                ICComboBoxConfigEdit{
                    id:program3
                    width: 120
                    height: 32
                    configName: qsTr("Program3")
                    configAddr: "m_rw_3_1_0_357"
                    items: pData.useNoUseText
                    z:7

                }
                ICComboBoxConfigEdit{
                    id:program4
                    width: 120
                    height: 32
                    configName: qsTr("Program4")
                    configAddr: "m_rw_4_1_0_357"
                    items: pData.useNoUseText
                    z:6

                }
                ICComboBoxConfigEdit{
                    id:program5
                    width: 120
                    height: 32
                    configName: qsTr("Program5")
                    configAddr: "m_rw_5_1_0_357"
                    items: pData.useNoUseText
                    z:5

                }
                ICComboBoxConfigEdit{
                    id:program6
                    width: 120
                    height: 32
                    configName: qsTr("Program6")
                    configAddr: "m_rw_6_1_0_357"
                    items: pData.useNoUseText
                    z:4

                }
                ICComboBoxConfigEdit{
                    id:program7
                    width: 120
                    height: 32
                    configName: qsTr("Program7")
                    configAddr: "m_rw_7_1_0_357"
                    items: pData.useNoUseText
                    z:3

                }
                ICComboBoxConfigEdit{
                    id:program8
                    width: 120
                    height: 32
                    configName: qsTr("Program8")
                    configAddr: "m_rw_8_1_0_357"
                    items: pData.useNoUseText
                    z:2

                }

            }
        }
    }

    ValveSettings{
        id:valveSettings
        visible: false
        width: parent.width
        height: parent.height
        y:10
        x:10
    }

    Component.onCompleted: {
        var ps = [];
        ps.push(productPage);
        pages = ps;
    }

}
