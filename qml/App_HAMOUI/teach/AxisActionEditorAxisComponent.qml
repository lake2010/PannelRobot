import QtQuick 1.1
import "../../ICCustomElement"
import "Teach.js" as Teach

Row{
    id:axis
    property string axisName: ""
    property alias psName:ps.items
    property bool posvisible: pos.visible
    property bool psvisible: ps.visible
    property int axisDefine: 0
    property int editorWidth: 80
    property alias rangeAddr: pos.bindConfig
    property alias angle: pos.text
    property alias unit: pos.unit

    function getAxisActionInfo(){
        if(!box.isChecked) return null;
        var ret = {};
        if(pos.visible) {
            ret.pos = pos.text;
            ret.speed = speed.text
        }
        else if(ps.visible) ret.ps = ps.currentIndex;
        ret.delay = delay.text
        return ret;
    }

    spacing: 10
    visible: {
        return axisDefine != Teach.kAxisType_NoUse &&
                axisDefine != Teach.kAxisType_Reserve
    }

    ICCheckBox{
        id:box
        text: axisName
        width: 50
    }
    ICLineEdit{
        id:pos
        width: editorWidth + 25
        visible: axisDefine == Teach.kAxisType_Servo
        bindConfig: rangeAddr
        unit: qsTr("deg")

    }
    ICComboBox{
        id:ps
        width: editorWidth
        visible: axisDefine == Teach.kAxisType_Pneumatic
    }
    ICLineEdit{
        id:speed
        inputWidth: editorWidth - 20
        visible: axisDefine == Teach.kAxisType_Servo
        unit: qsTr("%")
        text: "80.0"
        bindConfig: "s_rw_0_32_1_1200"
    }
    ICLineEdit{
        id:delay
        inputWidth: editorWidth - 15
        unit: qsTr("s")
        text:"0.00"
        bindConfig: "s_rw_0_32_2_1100"
    }

    onVisibleChanged: {
        if(!visible){
            box.setChecked(false);
        }
    }
}
