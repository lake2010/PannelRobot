import QtQuick 1.1
import "configs/IODefines.js" as IODefines
import "Theme.js" as Theme
import "."

Item {

    property variant valves: []

    QtObject{
        id:pData
        property variant pointUIs: []
    }

    Grid{
        id:pointsContainer
        columns: 2
        spacing: 20
        flow:Grid.TopToBottom
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.topMargin: 10

    }

    onValvesChanged:  {
        var yDefineItemClass = Qt.createComponent("YDefineItem.qml");
        var uis = [];
        for(var i = 0; i < valves.length; ++i){
//            var ioinfo = IODefines.getValveItemFromValveName(valves[i]);

            uis.push(yDefineItemClass.createObject(pointsContainer, {"valveName":valves[i]}));
        }
        pData.pointUIs = uis;
    }

    Timer {
        id: refreshTimer
        interval: 50
        running: visible
        repeat: true
        onTriggered: {
            var yItems = pData.pointUIs;
            var yItem;
            var valve;
            var valveStatus = {};
            for(var i = 0; i < yItems.length; ++i){
                yItem = yItems[i];
                valve = yItem.valve;

                valveStatus.y1 = panelRobotController.isOutputOn(valve.y1Point, valve.y1Board);
                valveStatus.x1 = panelRobotController.isInputOn(valve.x1Point, valve.x1Board);
                valveStatus.y2 = panelRobotController.isOutputOn(valve.y2Point, valve.y2Board);
                valveStatus.x2 = panelRobotController.isInputOn(valve.x2Point, valve.x2Board);
                yItem.valveStatus = valveStatus;
            }
//            pData.pointUIs = yItems;

            //            update(y0, 0 + ioStart)
            //            update(y1, 1 + ioStart)
            //            update(y2, 2 + ioStart)
            //            update(y3, 3 + ioStart)
            //            update(y4, 4 + ioStart)
            //            update(y5, 5 + ioStart)
            //            update(y6, 6 + ioStart)
            //            update(y7, 7 + ioStart)

            //            update(y8, 8 + ioStart)
            //            update(y9, 9 + ioStart)
            //            update(y10, 10 + ioStart)
            //            update(y11, 11 + ioStart)
            //            update(y12, 12 + ioStart)
            //            update(y13, 13 + ioStart)
            //            update(y14, 14 + ioStart)
            //            update(y15, 15 + ioStart)
        }
    }
    onVisibleChanged: {
        if (visible)
            refreshTimer.start()
        else
            refreshTimer.stop()
    }
}
