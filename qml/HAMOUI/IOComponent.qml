import QtQuick 1.1
import "configs/IODefines.js" as IODefines
import "AppSettings.js" as UISettings
import "../ICCustomElement"
Rectangle {
    QtObject{
        id:pData
        property string currentLanguage: UISettings.AppSettings.prototype.currentLanguage()
        property variant ioViewsInfo: []
    }

    Row{
        id:menuContainer
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        z:1
        ICButton{
            id:prev
            text: qsTr("Prev")
            width: 40
            onButtonClicked: {
                var currentTypeInfo = pData.ioViewsInfo[ioType.currentIndex];
                var cur = ioContaner.currentIndex;
                --cur;
                if(cur < currentTypeInfo.start)
                    cur = currentTypeInfo.start + currentTypeInfo.count - 1;
                ioContaner.setCurrentIndex(cur)
            }

        }

        ICComboBox{
            id:ioType
            items: [qsTr("Input"), qsTr("Output"), qsTr("EuInput"), qsTr("EuOutput")]
            currentIndex: 0
            onCurrentIndexChanged: {
                ioContaner.setCurrentIndex(pData.ioViewsInfo[currentIndex].start);
            }
        }

        ICButton{
            id:next
            text: qsTr("Next")
            width: 40
            onButtonClicked: {
                var currentTypeInfo = pData.ioViewsInfo[ioType.currentIndex];
                var cur = ioContaner.currentIndex;
                ++cur;
                if(cur >= currentTypeInfo.start + currentTypeInfo.count)
                    cur = currentTypeInfo.start;
                ioContaner.setCurrentIndex(cur)
            }

        }
    }
    ICStackContainer{
        id:ioContaner
        anchors.top: menuContainer.bottom
        anchors.topMargin: 10
        function ioDefinesToViewDefines(defs){
            var ret = [];
            var def;
            for(var i = 0 ; i < defs.length; ++i){
                def = defs[i]
                ret[i] = {"pointNum":def.pointName,
                    "index":i,
                    "descr":def.descr[pData.currentLanguage]
                };
            }
            return ret;
        }

        function generatePageBaseDefines(defs,type){
            var ioView = Qt.createComponent('IOComponentView.qml');
            var ret = [];
            if (ioView.status == Component.Ready){
                var pageCount = Math.ceil(defs.length / 8);
                for(var i = 0; i < pageCount; ++i){
                    ret[i] = ioView.createObject(ioContaner,
                                                 {"ioDefines":ioDefinesToViewDefines(defs.slice(i * 8, (i + 1) * 8)), "type":type})
                }
            }
            return ret;
        }

        function appendPagesToContainer(pages, pageType, start){
            var ret = pData.ioViewsInfo;
            ret[pageType] = {"start":start, "count":pages.length};
            pData.ioViewsInfo = ret;
            for(var i = 0; i < pages.length; ++i){
                ioContaner.addPage(pages[i]);
            }
        }

        Component.onCompleted: {
            var xDefs = IODefines.xDefines;
            var yDefs = IODefines.yDefines;
            var euxDefs = IODefines.euxDefines;
            var euyDefs = IODefines.euyDefines;

            var pages = generatePageBaseDefines(xDefs, IODefines.IO_TYPE_INPUT);
            var lastLength = pages.length;
            appendPagesToContainer(pages, 0, 0);

            pages = generatePageBaseDefines(yDefs, IODefines.IO_TYPE_OUTPUT);
            appendPagesToContainer(pages, 1, lastLength);
            lastLength += pages.length;

            pages = generatePageBaseDefines(euxDefs, IODefines.IO_TYPE_INPUT);
            appendPagesToContainer(pages, 2, lastLength);
            lastLength += pages.length;

            pages = generatePageBaseDefines(euyDefs, IODefines.IO_TYPE_OUTPUT);
            appendPagesToContainer(pages, 3, lastLength);

            ioContaner.setCurrentIndex(0)
        }
    }
}