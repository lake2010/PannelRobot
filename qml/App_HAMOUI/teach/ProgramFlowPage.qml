import QtQuick 1.1
import "../../ICCustomElement"
import "Teach.js" as Teach
import "../Theme.js" as Theme
import "../../utils/utils.js" as Utils
import "ProgramFlowPage.js" as PData
import "../configs/Keymap.js" as Keymap
import "../ShareData.js" as ShareData


Rectangle {
    property int mode: ShareData.knobStatus
    function showActionEditorPanel(){
        if(!actionEditorFrame.visible)
            programListView.contentY += actionEditorFrame.height;
        else
            programListView.contentY -= actionEditorFrame.height;

        actionEditorFrame.visible = !actionEditorFrame.visible;
    }

    function onInsertTriggered(){
        var cI = programListView.currentIndex;
        if(cI < 0)return;
        if(actionEditorContainer.isMenuShow()) return;
        var actionObjects = actionEditorContainer.currentPage().createActionObjects();
        if(actionObjects.length == 0) return;
        var model = currentModel();
        for(var i = 0; i < actionObjects.length; ++i){
            if(actionObjects[i].action === Teach.actions.ACT_FLAG){
                Teach.pushFlag(actionObjects[i].flag);
            }

            model.insert(cI++, new Teach.ProgramModelItem(actionObjects[i], Teach.actionTypes.kAT_Normal));
        }
        repaintProgramItem(model)
//        var msg = {"programModel":model}
//        repaintThread.sendMessage(msg);
    }

    function onDeleteTriggered(){
        var cI = programListView.currentIndex;
        if(cI < 0)return;
        var model = currentModel();
        if(cI >= model.count - 1) return;
        var actionObject = model.get(cI).mI_ActionObject;
        if(actionObject.action === Teach.actions.ACT_FLAG){
            Teach.delFlag(actionObject.flag);
        }
        model.remove(cI);
        repaintProgramItem(model);
    }

    function onUpTriggered(){
        var cI = programListView.currentIndex;
        if(cI < 1)return;
        var model = currentModel();
        if(cI >= model.count - 1) return;
        var cIAction = currentModelData().mI_ActionObject;
        var cIPAction = model.get(cI - 1).mI_ActionObject;


//        if(cIAction.action === Teach.actions.F_CMD_SYNC_START){
//            if(!Teach.isSyncAction(cIPAction))
//                model.set(cI - 1, {"mI_ActionType":Teach.actionTypes.kAT_SyncStart});
//        }else if(cIAction.action === Teach.actions.F_CMD_SYNC_END){
//            if(!Teach.isSyncAction(cIPAction))
//                model.set(cI - 1, {"mI_ActionType":Teach.actionTypes.kAT_Normal});
//        }else if(cIPAction.action === Teach.actions.F_CMD_SYNC_START){
//            model.set(cI, {"mI_ActionType":Teach.actionTypes.kAT_Normal});
//        }else if(cIPAction.action === Teach.actions.F_CMD_SYNC_END){
//            model.set(cI, {"mI_ActionType":Teach.actionTypes.kAT_SyncStart});
//        }

        model.move(cI, cI -1, 1);
        if(Teach.isSyncAction(cIAction) ||
                Teach.isSyncAction(cIPAction)){
            repaintProgramItem(model);
        }
    }

    function onDownTriggered(){
        var cI = programListView.currentIndex;
        if(cI < 0)return;
        var model = currentModel();
        if(cI >= model.count - 2) return;
        var cIAction = currentModelData().mI_ActionObject;
        var cINAction = model.get(cI + 1).mI_ActionObject;
//        if(cIAction.action === Teach.actions.F_CMD_SYNC_START){
//            if(!Teach.isSyncAction(cINAction))
//                model.set(cI + 1, {"mI_ActionType":Teach.actionTypes.kAT_Normal});
//        }else if(cIAction.action === Teach.actions.F_CMD_SYNC_END){
//            if(!Teach.isSyncAction(cINAction))
//                model.set(cI + 1, {"mI_ActionType":Teach.actionTypes.kAT_SyncStart});
//        }else if(cINAction.action === Teach.actions.F_CMD_SYNC_START){
//            model.set(cI, {"mI_ActionType":Teach.actionTypes.kAT_SyncStart});
//        }else if(cINAction.action === Teach.actions.F_CMD_SYNC_END){
//            model.set(cI, {"mI_ActionType":Teach.actionTypes.kAT_Normal});
//        }
        model.move(cI, cI  + 1, 1);
        if(Teach.isSyncAction(cIAction) ||
                Teach.isSyncAction(cINAction)){
            repaintProgramItem(model);
        }

    }

    function onEditConfirm(actionObject){
        currentModelData().mI_ActionObject = actionObject;
        if(mode === Keymap.KNOB_AUTO){
            if(panelRobotController.fixProgramOnAutoMode(editing.currentIndex,
                                                         programListView.currentIndex,
                                                         JSON.stringify(actionObject))){
                if(editing.currentIndex === 0)
                    panelRobotController.saveMainProgram(modelToProgram(0));
                else
                    panelRobotController.saveSubProgram(modelToProgram(editing.currentIndex));

            }
        }
    }

    function modelToProgram(which){
        var model = PData.programs[which];
        var ret = [];
        for(var i = 0; i < model.count; ++i){
            ret.push(model.get(i).mI_ActionObject);
        }
        return JSON.stringify(ret);
    }

    function onSaveTriggered(){
        var errno;
        if(editing.currentIndex == 0){
            errno = panelRobotController.saveMainProgram(modelToProgram(0));
            if(! errno){
                panelRobotController.sendMainProgramToHost();
            }
        }else{
            errno = panelRobotController.saveSubProgram(editing.currentIndex, modelToProgram(editing.currentIndex));
            if(! errno){
                panelRobotController.sendSubProgramToHost(editing.currentIndex);
            }
        }
        if(errno !== 0){
            tipBox.show(Teach.ccErrnoToString(errno));
        }
    }

    //    function saveProgram(which){

    //    }

    function currentModel(){
        return PData.programs.length == 0?  mainProgramModel: PData.programs[editing.currentIndex];
    }

    function currentModelData() {
        return currentModel().get(programListView.currentIndex);
    }

    function currentModelStep(){
        return panelRobotController.statusValue(PData.stepAddrs[editing.currentIndex]);
    }

    function currentModelRunningActionInfo(){
        var ret = panelRobotController.currentRunningActionInfo(editing.currentIndex);
        var info = JSON.parse(ret);
        return info;
    }

    //    function setCurrentModelData(actionObject){
    //        currentModel().set(programListView.currentIndex,
    //                           new Teach.ProgramModelItem(actionObject));
    //    }

    WorkerScript{
        id:repaintThread
        source: "repaintProgram.js"
    }

    Column{
        id:container
        width: 792
        height: 420
        spacing: 2
        Rectangle{
            id:programViewContainer
            x:2
            width: parent.width
            height: actionEditorFrame.visible ? container.height / 2 : container.height
            color: Theme.defaultTheme.BASE_BG

            Row{
                id:programSelecterContainer
                spacing: 10
                y:2
                z:1
                //                height: 24
                Text {
                    text: qsTr("Editing")
                    anchors.verticalCenter: parent.verticalCenter
                }
                ICComboBox{
                    id:editing
                    z:100
                    items: [qsTr("main"),
                        qsTr("Sub-1"),
                        qsTr("Sub-2"),
                        qsTr("Sub-3"),
                        qsTr("Sub-4"),
                        qsTr("Sub-5"),
                        qsTr("Sub-6"),
                        qsTr("Sub-7"),
                        qsTr("Sub-8")
                    ]
                    currentIndex: 0
                    onCurrentIndexChanged: {
                        programListView.model = PData.programs[currentIndex];
                    }
                }
            }

            Rectangle{
                id:programListContainer
                anchors.top: programSelecterContainer.bottom
                anchors.topMargin: 4
                //        anchors.bottom: parent.bottom
                border.width: 1
                border.color: "black"
                //                width: actionEditorFrame.visible ? container.width / 2 : container.width
                width: parent.width
                height: parent.height - programSelecterContainer.height - container.spacing
                color: "gray"
                //        visible: false
                ListModel{
                    id:mainProgramModel
                }
                ListModel{
                    id:sub1ProgramModel
                }
                ListModel{
                    id:sub2ProgramModel
                }
                ListModel{
                    id:sub3ProgramModel
                }
                ListModel{
                    id:sub4ProgramModel
                }
                ListModel{
                    id:sub5ProgramModel
                }
                ListModel{
                    id:sub6ProgramModel
                }
                ListModel{
                    id:sub7ProgramModel
                }
                ListModel{
                    id:sub8ProgramModel
                }

                Row{
                    id:toolBar
                    function showModify(){
                        modifyEditor.y = toolBar.y + toolBar.height + 30;
                        var actionObject = currentModelData().mI_ActionObject;
                        modifyEditor.openEditor(actionObject, Teach.actionObjectToEditableITems(actionObject));
                    }
                    z: 1
                    height: 30
                    spacing: 4
                    anchors.right: programListView.right
                    anchors.rightMargin: 2
                    y: visible ? programListView.currentItem.y - programListView.contentY + 2 : 0

                    onYChanged: {
                        if(!editBtn.visible){
                            modifyEditor.visible = false;
                            return;
                        }
                        if(modifyEditor.visible){
                            showModify();
                        }
                    }
                    visible: {
                        if(programListView.currentItem == null) return false;
                        return programListView.currentItem.y >= programListView.contentY;
                    }
                    ICButton{
                        id:moveUpBtn
                        height: parent.height
                        width: 40
                        text: qsTr("UP")
                        visible: {
                            return  mode === Keymap.KNOB_AUTO ? false : (programListView.currentIndex > 0) && (programListView.currentIndex < programListView.count - 1)
                        }
                    }
                    ICButton{
                        id:moveDWBtn
                        height: parent.height
                        width: 40
                        text: qsTr("DW")
                        visible: {
                            return  mode === Keymap.KNOB_AUTO ? false :
                                                                (programListView.currentIndex < programListView.count - 2)
                        }
                    }

                    ICButton{
                        id:editBtn
                        height: parent.height
                        width: 40
                        text: qsTr("Edit")
                        onButtonClicked: toolBar.showModify()


                        visible: {
                            return Teach.actionObjectToEditableITems(currentModelData().mI_ActionObject).length !== 0
                        }

                    }
                    ICButton{
                        id:commentToggleBtn
                        width: 40
                        height: parent.height
                        text: qsTr("C/UC")
                        onButtonClicked: {
                            var modelObject = currentModelData();
                            //                            if(modelObject.commentedObject.action == Teach.actions.ACT_COMMENT) return;
                            if(modelObject.mI_ActionObject.action == Teach.actions.ACT_COMMENT){
                                if(modelObject.mI_ActionObject.commentAction == null)
                                    return;
                            }

                            if(modelObject.mI_ActionObject.action == Teach.actions.ACT_COMMENT){
                                //                                var cO = Teach.generateCommentAction(Teach.actionToString(modelObject.actionObject), modelObject.actionObject);
                                modelObject.mI_ActionObject = modelObject.mI_ActionObject.commentAction;
                            }
                            else{
                                modelObject.mI_ActionObject = Teach.generateCommentAction(Teach.actionToString(modelObject.mI_ActionObject), modelObject.mI_ActionObject);
                            }

                        }
                        visible: {
                            return  mode === Keymap.KNOB_AUTO ? false :
                                                                programListView.currentIndex < programListView.count - 1
                        }
                    }
                    ICButton{
                        id:delBtn
                        height: parent.height
                        width: 40
                        text: qsTr("Del")
                        visible: {
                            return  mode === Keymap.KNOB_AUTO ? false :
                                                                programListView.currentIndex < programListView.count - 1
                        }

                    }
                }

                ListView{
                    id:programListView
                    y:2
                    model: mainProgramModel
                    width: parent.width
                    height: parent.height - 2
                    spacing:2
                    clip: true
                    delegate: ProgramListItem{
                        x:1
                        width: programListView.width - x
                        height: 30
                        isCurrent: ListView.isCurrentItem
                        isComment: mI_ActionObject.action === Teach.actions.ACT_COMMENT
                        isRunning: mI_IsActionRunning
                        lineNum: index
                        text: "     " + Teach.actionToString(mI_ActionObject)
                        actionType: mI_ActionType
                        MouseArea{
                            anchors.fill: parent
                            onPressed: {
                                programListView.currentIndex = index;
                            }
                        }
                    }

                    Timer{
                        id:refreshTimer
                        interval: 50
                        running: parent.visible
                        repeat: true
                        onTriggered: {
                            //                            if(mode !== ShareData.knobStatus){
                            //                                mode = ShareData.knobStatus;
                            //                            }
                            //                            console.log(mode, Keymap.KNOB_AUTO)
                            if(!panelRobotController.isAutoMode()) return;
                            var cStep = currentModelStep();
                            //                            var cStep = Utils.getRandomNum(0, 10);
                            var lastRunning = PData.lastRunning;
                            //                            console.log(cStep, lastRunning.model, lastRunning.step, lastRunning.items)
                            if(editing.currentIndex !== lastRunning.model ||
                                    cStep !== lastRunning.step)
                            {
                                var i;
                                var lastModel = PData.programs[lastRunning.model];
                                var setStopObject = {"isActionRunning":false};
                                for(i = 0; i < lastRunning.items.length; ++i){
                                    lastModel.set(lastRunning.items[i], setStopObject);
                                }

                                var cRunning = {"model":editing.currentIndex,"step":cStep};
                                var cModel = currentModel();
                                var uiRunningSteps = currentModelRunningActionInfo();
                                //                                var uiRunningSteps = panelRobotController.hostStepToUILines(editing.currentIndex, cStep);
                                var setRunningObject = {"isActionRunning":true};
                                for(i = 0; i < uiRunningSteps.length; ++i){
                                    cModel.set(uiRunningSteps[i], setRunningObject);
                                }
                                cRunning.items = uiRunningSteps;
                                //                                console.log(cRunning.items)
                                PData.lastRunning = cRunning;
                            }

                        }
                    }

                    //                    delegate: Rectangle{
                    //                        x:1
                    //                        width: parent.width - x
                    //                        height: 30
                    //                        Text{
                    //                            text:{
                    //                                if(actionObject.action != Teach.actions.ACT_COMMENT)
                    //                                    return index;
                    //                                return "#" + index;
                    //                            }

                    //                            width: 35
                    //                            anchors.left: parent.left
                    //                            anchors.verticalCenter: parent.verticalCenter
                    //                            horizontalAlignment: Text.AlignRight
                    //                        }
                    //                        Text {
                    //                            text:"             " + Teach.actionToString(actionObject)
                    //                            width: programListView.width
                    //                            anchors.verticalCenter: parent.verticalCenter
                    //                        }
                    //                        color: {
                    //                            if(ListView.isCurrentItem){
                    //                                return "lightsteelblue"
                    //                            }
                    //                            else if(actionObject.action === Teach.actions.ACT_COMMENT)
                    //                            {
                    //                                return "gray"
                    //                            }
                    //                            else{
                    //                                return index % 2 == 1 ? "cyan" : "yellow"
                    //                            }
                    //                        }

                    //                        MouseArea{
                    //                            anchors.fill: parent
                    //                            onClicked: {
                    //                                programListView.currentIndex = index;
                    ////                                console.log(programListView.contentY, programListView.currentItem.y)
                    //                            }
                    //                        }
                    //                    }
                }

            }
        }
        Rectangle{
            id:actionEditorFrame
            //            visible: false
            width: container.width
            height: container.height / 2
            //            y:2
            x:2

            //            anchors.left: programViewContainer.right
            //            anchors.right: container.right
            border.width: 1
            border.color: "black"
            ICButton{
                id:insertBtn
                x:2
                y:21
                width: 80
                height: 32
                text: qsTr("Insert")
            }

            ICButton{
                id:actionMenuBtn
                x:insertBtn.x
                y:insertBtn.y + 126
                width: insertBtn.width
                height: insertBtn.height
                text: qsTr("Menu")
            }
            Rectangle{
                id:splitLine
                width: 1
                y:2
                height:parent.height -3
                anchors.left: insertBtn.right
                anchors.leftMargin: 5
                color: "gray"
            }

            ICStackContainer{
                function showMenu() { setCurrentIndex(0);}
                //                function showAxis() { setCurrentIndex(1);}
                //                function showOutput() { setCurrentIndex(2);}
                function isMenuShow() { return currentIndex == 0;}
                id:actionEditorContainer
                width: parent.width - insertBtn.width - anchors.leftMargin
                height: parent.height
                anchors.left: insertBtn.right
                anchors.leftMargin: 10
            }
            Component.onCompleted: {
                var editor = Qt.createComponent('ProgramActionMenu.qml');
                var actionMenuObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('AxisActionEditor.qml');
                var axisEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('OutputActionEditor.qml')
                var outputEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('WaitActionEditor.qml')
                var waitEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('CheckActionEditor.qml')
                var checkEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('ConditionActionEditor.qml')
                var conditionEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('SyncActionEditor.qml')
                var syncEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('CommentActionEditor.qml')
                var commentEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('SearchActionEditor.qml')
                var searchEditorObject = editor.createObject(actionEditorContainer);
                editor = Qt.createComponent('PathActionEditor.qml')
                var pathEditorObject = editor.createObject(actionEditorContainer);

                actionEditorContainer.addPage(actionMenuObject);
                actionEditorContainer.addPage(axisEditorObject);
                actionEditorContainer.addPage(outputEditorObject);
                actionEditorContainer.addPage(waitEditorObject);
                actionEditorContainer.addPage(checkEditorObject);
                actionEditorContainer.addPage(conditionEditorObject);
                actionEditorContainer.addPage(syncEditorObject);
                actionEditorContainer.addPage(commentEditorObject);
                actionEditorContainer.addPage(searchEditorObject);
                actionEditorContainer.addPage(pathEditorObject);


                actionEditorContainer.showMenu();
                actionMenuObject.axisMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(1)});
                actionMenuObject.outputMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(2)});
                actionMenuObject.waitMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(3)});
                actionMenuObject.checkMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(4)});
                actionMenuObject.conditionMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(5)});
                actionMenuObject.syncMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(6)});
                actionMenuObject.commentMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(7)});
                actionMenuObject.searchMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(8)});
                actionMenuObject.pathMenuTriggered.connect(function(){actionEditorContainer.setCurrentIndex(9)});


                axisEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);
                outputEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);
                waitEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);
                checkEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);
                conditionEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);
                syncEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);
                commentEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);
                searchEditorObject.backToMenuTriggered.connect(actionEditorContainer.showMenu);

                actionMenuBtn.buttonClicked.connect(actionEditorContainer.showMenu);
                insertBtn.buttonClicked.connect(onInsertTriggered);
            }
        }
    }

    ICDialog{
        id:tipBox
        anchors.centerIn: container
        z: 100
    }
    ActionModifyEditor{
        id:modifyEditor
        z:3
        x: 10

    }

    //TODO:Use WorkerScript to implement this function
    function repaintProgramItem(programModel, start, end){
        var l = programModel.count;
        start = start || 0;
        end = end || l;

        if(start >= l || end > l)
            return;
        var step;
        var at;
        var isSyncStart = false;
        for(var i = start; i < end; ++i){
            step = programModel.get(i).mI_ActionObject;
            if(step.action === Teach.actions.F_CMD_SYNC_START){
                at = Teach.actionTypes.kAT_SyncStart;
                isSyncStart = true;
            }
            else if(step.action === Teach.actions.F_CMD_SYNC_END){
                at = Teach.actionTypes.kAT_SyncEnd;
                isSyncStart = false;
            }
            else
                at = Teach.actionTypes.kAT_Normal;
            if(isSyncStart)
                at = Teach.actionTypes.kAT_SyncStart;
            programModel.setProperty(i, "mI_ActionType", at);
        }
    }

    function updateProgramModels(){
        var program = JSON.parse(panelRobotController.mainProgram());
        var i,j;
        var step;
        var at;
        var isSyncStart = false;
        Teach.definedPoints.clear();
        for(i = 0; i < 9; ++i){
            PData.programs[i].clear();
            program = JSON.parse(panelRobotController.programs(i));
            for(var p = 0; p < program.length; ++p){
                step = program[p]
                if(Teach.canActionUsePoint(step)){
                    Teach.definedPoints.parseActionPoints(step);
                }

                if(step.action === Teach.actions.ACT_FLAG){
                    Teach.pushFlag(step.flag);
                }else if(step.action === Teach.actions.F_CMD_SYNC_START){
                    at = Teach.actionTypes.kAT_SyncStart;
                    isSyncStart = true;
                }
                else if(step.action === Teach.actions.F_CMD_SYNC_END){
                    at = Teach.actionTypes.kAT_SyncEnd;
                    isSyncStart = false;
                }
                else
                    at = Teach.actionTypes.kAT_Normal;
                if(isSyncStart)
                    at = Teach.actionTypes.kAT_SyncStart;
                PData.programs[i].append(new Teach.ProgramModelItem(step, at));
            }
        }
    }

    onVisibleChanged: {
        actionEditorFrame.visible = false;
        programListView.contentY = 0;
    }

    Component.onCompleted: {
        PData.programs.push(mainProgramModel);
        PData.programs.push(sub1ProgramModel);
        PData.programs.push(sub2ProgramModel);
        PData.programs.push(sub3ProgramModel);
        PData.programs.push(sub4ProgramModel);
        PData.programs.push(sub5ProgramModel);
        PData.programs.push(sub6ProgramModel);
        PData.programs.push(sub7ProgramModel);
        PData.programs.push(sub8ProgramModel);


        updateProgramModels();
        panelRobotController.moldChanged.connect(updateProgramModels);
        modifyEditor.editConfirm.connect(onEditConfirm);
        delBtn.buttonClicked.connect(onDeleteTriggered);
        moveUpBtn.buttonClicked.connect(onUpTriggered);
        moveDWBtn.buttonClicked.connect(onDownTriggered);
    }

}
