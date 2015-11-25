import QtQuick 1.1
import "../../ICCustomElement"
import "PointEdit.js" as PData
import "Teach.js" as Teach
import "../configs/AxisDefine.js" as AxisDefine
import "../../utils/utils.js" as Utils


Item {
    property bool isEditorMode: false
    property variant points: []
    function createPoint(name, point){
        return {"pos":point, "pointName":name};
    }

    function usedMotorCount(){
        var ret = 0;
        if(motor0.isChecked)
            ++ret;
        if(motor1.isChecked)
            ++ret;
        if(motor2.isChecked)
            ++ret;
        if(motor3.isChecked)
            ++ret;
        if(motor4.isChecked)
            ++ret;
        if(motor5.isChecked)
            ++ret;
        return ret;
    }

    function getPoints(){
        var ret = [];
        var mP;
        for(var i = 0; i < pointViewModel.count; ++i){
            mP = Utils.cloneObject(pointViewModel.get(i));
            ret.push(createPoint(mP.pointName, mP.pos));
        }
        return ret;
    }

    function getSpeed(){
        return speed.configValue;
    }

    function getDelay(){
        return delay.configValue;
    }

    function refreshSelectablePoisnts(points){
        selReferenceName.items = points;
    }

    function isPoseMode(){
        return poseMode.isChecked;
    }

    function clearPoints(){
        pointViewModel.clear();
    }

    onVisibleChanged: {
        if(visible){
            refreshSelectablePoisnts(Teach.definedPoints.pointNameList());
            if(!isEditorMode){
                clearPoints();
            }
        }
    }

    onPointsChanged: {
        pointViewModel.clear();
        for(var i = 0; i < points.length; ++i){
            pointViewModel.append(createPoint(points[i].pointName, points[i].pos));
        }
    }

    width: 710
    height: 200

    Row{
        id:leftCommandContainer
        spacing: 6
        ICButton{
            id:setIn
            text: qsTr("Set In")
            width: PData.commandBtnWidth
            onButtonClicked: {
//                console.log("clicked");
//                console.log(panelRobotController.getConfigValueText("c_ro_0_32_0_900"));
                motor0.configValue = panelRobotController.statusValueText("c_ro_0_32_3_900");
                motor1.configValue = panelRobotController.statusValueText("c_ro_0_32_3_904");
                motor2.configValue = panelRobotController.statusValueText("c_ro_0_32_3_908");
                motor3.configValue = panelRobotController.statusValueText("c_ro_0_32_3_912");
                motor4.configValue = panelRobotController.statusValueText("c_ro_0_32_3_916");
                motor5.configValue = panelRobotController.statusValueText("c_ro_0_32_3_920");
            }
        }
        ICButton{
            id:setZero
            text: qsTr("Zero")
            width: PData.commandBtnWidth
            onButtonClicked: {
                motor0.configValue = 0;
                motor1.configValue = 0;
                motor2.configValue = 0;
                motor3.configValue = 0;
                motor4.configValue = 0;
                motor5.configValue = 0;
            }
        }
        ICButton{
            id:add
            text: qsTr("Add")
            width: PData.commandBtnWidth
            onButtonClicked: {
                pointViewModel.append(pointViewModel.createModelItem());
            }
        }

        ICCheckBox{
            id:poseMode
            text:qsTr("Is Pose")
        }
    }

    Grid{
        id:motorSettingContainer
        rows:3
        columns: 2
        spacing: 6
        flow: Grid.TopToBottom
        anchors.top: leftCommandContainer.bottom
        anchors.topMargin: 6
        ICCheckableLineEdit{
            id:motor0
            configName: AxisDefine.axisInfos[0].name
            configAddr: "s_rw_0_32_3_1000"
            inputWidth: PData.axisEditWidth
        }
        ICCheckableLineEdit{
            id:motor1
            configName: AxisDefine.axisInfos[1].name
            configAddr: "s_rw_0_32_3_1001"
            inputWidth: PData.axisEditWidth


        }
        ICCheckableLineEdit{
            id:motor2
            configName: AxisDefine.axisInfos[2].name
            configAddr: "s_rw_0_32_3_1002"
            inputWidth: PData.axisEditWidth

        }
        ICCheckableLineEdit{
            id:motor3
            configName: AxisDefine.axisInfos[3].name
            configAddr: "s_rw_0_32_3_1003"
            inputWidth: PData.axisEditWidth


        }
        ICCheckableLineEdit{
            id:motor4
            configName: AxisDefine.axisInfos[4].name
            configAddr: "s_rw_0_32_3_1004"
            inputWidth: PData.axisEditWidth


        }
        ICCheckableLineEdit{
            id:motor5
            configName: AxisDefine.axisInfos[5].name
            configAddr: "s_rw_0_32_3_1005"
            inputWidth: PData.axisEditWidth


        }
    }
    Rectangle{
        id:leftHorSplitLine
        height: 1
        width: 332
        anchors.top: motorSettingContainer.bottom
        anchors.topMargin: 2
        color: "gray"
    }

    ICButtonGroup{
        id:pointModeContainer
        layoutMode: 1
        anchors.top: leftHorSplitLine.bottom
//        anchors.topMargin: 1

        spacing: 2
        isAutoSize: false
        height: newReferenceName.height + selReferenceName.height + 2* spacing
        ICCheckableLineEdit{
            id:newReferenceName
            configName: qsTr("New Point:")
            configNameWidth: 120
            inputWidth: 180
            isNumberOnly: false
        }

        ICCheckableComboboxEdit{
            id:selReferenceName
            configName: qsTr("Select Point:")
            configNameWidth: 120
            inputWidth: newReferenceName.inputWidth
            popupMode: 1
            z: 2
        }
    }

    Row{
        id:speedAndDelayContainer
        spacing: 6
        anchors.top: pointModeContainer.bottom
        anchors.topMargin: 2
        visible: !isEditorMode
        ICConfigEdit{
            id:speed
            configName: qsTr("Speed")
            configAddr: "s_rw_0_32_1_1200"
            unit: qsTr("%")
            inputWidth: PData.speedEditWidth

        }
        ICConfigEdit{
            id:delay
            configName: qsTr("Delay")
            configAddr: "s_rw_0_32_2_1100"
            unit: qsTr("s")
            inputWidth: PData.delayEditWidth
        }
    }

    Rectangle{
        id:middleVercSplitLine
        width: 1
        height: 200
        color: "gray"
        anchors.left: motorSettingContainer.right
        anchors.leftMargin: 6
    }

    Row{
        id:rightCommandContainer
        spacing: 6
        anchors.left: middleVercSplitLine.right
        anchors.leftMargin: 2
        ICButton{
            id:insert
            text: qsTr("Insert")
            width: PData.commandBtnWidth
            onButtonClicked: {
                pointViewModel.insert(pointView.currentIndex, pointViewModel.createModelItem());
            }
        }
        ICButton{
            id:del
            text: qsTr("Del")
            width: PData.commandBtnWidth
            onButtonClicked: {
                pointViewModel.remove(pointView.currentIndex);
            }
        }
    }
    Rectangle{
        id:pointViewContainer
        x:rightCommandContainer.x
        height: 172
        anchors.top: rightCommandContainer.bottom
        anchors.topMargin: 2
        width: 355
        border.width: 1
        border.color: "black"
        ListView{
            id:pointView
            width: parent.width
            height: parent.height

            ListModel{
                id:pointViewModel

                function itemText(point, name){

                    var ret = "";
                    if(name.length !== 0){
                        ret = name + "(";
                    }

                    var m;
                    for(var i = 0; i < 6; ++i){
                        m = "m" + i;
                        if(point.hasOwnProperty(m)){
                            ret += AxisDefine.axisInfos[i].name + ":" + point[m] + ","
                        }
                    }
                    ret = ret.substr(0, ret.length - 1);
                    if(name.length !== 0){
                        ret += ")";
                    }
                    return ret;
                }

                function createModelItem(){
                    var ret = {};

                    if(motor0.isChecked)
                        ret.m0 = motor0.configValue;
                    if(motor1.isChecked)
                        ret.m1 = motor1.configValue;
                    if(motor2.isChecked)
                        ret.m2 = motor2.configValue;
                    if(motor3.isChecked)
                        ret.m3 = motor3.configValue;
                    if(motor4.isChecked)
                        ret.m4 = motor4.configValue;
                    if(motor5.isChecked)
                        ret.m5 = motor5.configValue;
                    var pointName = "";
                    if(newReferenceName.isChecked){
                        var point = Teach.definedPoints.addNewPoint(newReferenceName.configValue,
                                                        ret);
                        pointName = point.name;
                        refreshSelectablePoisnts(Teach.definedPoints.pointNameList());
                    }else if(selReferenceName.isChecked){
                        ret = Teach.definedPoints.getPoint(selReferenceName.configText).point;
                        pointName = selReferenceName.configText;
                    }

                    return createPoint(pointName, ret);
                }
            }
            model: pointViewModel
            highlight: Rectangle {x:1;y:1;width: pointView.width -1;height: 24; color: "lightsteelblue"; }

            delegate: Text {
                text:pointViewModel.itemText(model.pos, model.pointName)
                wrapMode: Text.Wrap
                width: pointView.width
                height: 24
                verticalAlignment: Text.AlignVCenter
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        pointView.currentIndex = index;
                    }
                }

            }
        }
    }

}