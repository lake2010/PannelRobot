import QtQuick 1.1
import "../../../ICCustomElement"
import "../../configs/AxisDefine.js" as AxisDefine
import "ExtentActionDefine.js" as ExtentActionDefine

ExtentActionEditorBase {
    id:axisFlyConfigs
    width: content.width + 20
    height: content.height
    property alias axis: axisFlyAxisSel.configValue
    property alias pos1: axisFlyPos1.configValue
    property alias pos2: axisFlyPos2.configValue
    property alias speed: axisFlySpeed.configValue
    property alias num: aixsFlyNum.configValue
    property alias delay: delayEdit.configValue

    function configsCheck(){
        return axisFlyAxisSel.configValue >= 0;
    }

    Column{
        id:content
        spacing: 4
        ICComboBoxConfigEdit{
            id:axisFlyAxisSel
            z:2
            configName: qsTr("Axis Sel")
            configNameWidth: 100
            popupHeight: 150
            items: AxisDefine.usedAxisNameList();
            function onAxisDefinesChanged(){
                configValue = -1;
                items = AxisDefine.usedAxisNameList();
            }

            Component.onCompleted: {
                AxisDefine.registerMonitors(axisFlyAxisSel);
            }
        }

        Row{
            spacing: 20
            ICConfigEdit{
                id:axisFlyPos1
                configName: qsTr("AxisFly Pos1")
                configNameWidth: axisFlyAxisSel.configNameWidth
                configAddr: "s_rw_0_32_3_1300"
                configValue: "0.000"
                unit: {
                    return axisFlyAxisSel.configValue >= 0 ? AxisDefine.axisInfos[axisFlyAxisSel.configValue].unit :
                                                             "";
                }
            }
            ICButton{
                id:setInAxisFlyPos1
                text:qsTr("Set In")
                height: axisFlyPos1.height
                onButtonClicked: {
                    if(axisFlyAxisSel.configValue >=0)
                        axisFlyPos1.configValue = (panelRobotController.statusValue(AxisDefine.axisInfos[axisFlyAxisSel.configValue].jAddr) / 1000).toFixed(3);
                }
            }
        }
        Row{
            spacing: 20
            ICConfigEdit{
                id:axisFlyPos2
                configName: qsTr("AxisFly Pos2")
                configNameWidth: axisFlyAxisSel.configNameWidth
                configAddr: "s_rw_0_32_3_1300"
                configValue: "0.000"
                unit: axisFlyPos1.unit
            }
            ICButton{
                id:setInAxisFlyPos2
                text:qsTr("Set In")
                height: axisFlyPos2.height
                onButtonClicked: {
                    if(axisFlyAxisSel.configValue >=0)
                        axisFlyPos2.configValue = (panelRobotController.statusValue(AxisDefine.axisInfos[axisFlyAxisSel.configValue].jAddr) / 1000).toFixed(3);
                }

            }
        }
        ICConfigEdit{
            id:axisFlySpeed
            configName: qsTr("AxisFly Speed")
            configNameWidth: axisFlyAxisSel.configNameWidth
            configAddr: "s_rw_0_32_1_1200"
            configValue: "80.0"
            unit: qsTr("%")
        }
        ICConfigEdit{
            id:aixsFlyNum
            configName: qsTr("AxisFyl Num")
            configNameWidth: axisFlyAxisSel.configNameWidth
            configValue: "1"
            unit: qsTr("Times")
        }
        ICConfigEdit{
            id:delayEdit
            configName: qsTr("Delay")
            configNameWidth: axisFlyAxisSel.configNameWidth
            configValue: "0.00"
            configAddr: "s_rw_0_32_2_1100"
            unit: qsTr("s")
        }
    }
    Component.onCompleted: {
        bindActionDefine(ExtentActionDefine.extentPENQIANGAction);
    }
}
