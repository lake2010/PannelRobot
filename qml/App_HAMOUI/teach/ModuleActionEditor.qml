import QtQuick 1.1
import "Teach.js" as Teach

import "../../utils/utils.js" as Utils

import "../../ICCustomElement"
import "ProgramFlowPage.js" as ProgramFlowPage


Item {
    function setModuleSelections(moduleNames){
        moduleSel.items = moduleNames;
        moduleSel.configValue = -1;
    }
    function setFlagSelections(flags){
        flags.splice(0, 0, qsTr("Next Line"));
        callBackSel.items = flags;
        callBackSel.configValue = -1;
    }

    function createActionObjects(){
        var ret = [];
        if(moduleSel.configValue < 0) return ret;
        var mID = (Utils.getValueFromBrackets(moduleSel.configText()));
        var fID = (callBackSel.configValue <= 0 ? -1 : Utils.getValueFromBrackets(callBackSel.configText()));
        ret.push(Teach.generateCallModuleAction(mID, fID));
        return ret;
    }

    Column{
        spacing: 10
        ICComboBoxConfigEdit{
            id:moduleSel
            configName: qsTr("Call Module")
            z:2
            configNameWidth: 100
            inputWidth: 200
            popupHeight: 100

        }
        ICComboBoxConfigEdit{
            id:callBackSel
            configName: qsTr("Return To Flag")
            configNameWidth: 100
            inputWidth: 200
            popupHeight: 100

        }
    }
    onVisibleChanged: {
        if(visible){
            setFlagSelections(Teach.flagsDefine.flagNameList(ProgramFlowPage.currentEditingProgram));
            setModuleSelections(Teach.functionManager.functionsStrList());
        }
    }
}
