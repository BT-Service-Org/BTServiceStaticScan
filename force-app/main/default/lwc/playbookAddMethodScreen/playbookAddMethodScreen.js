import { LightningElement, api, track } from "lwc";
import fetchDefaultRecord from "@salesforce/apex/PlaybookLookupController.fetchDefaultRecord";

export default class PlaybookAddMethodScreen extends LightningElement {
    @track methodList = [];
    @api parentmethodList = [];
    @track toggleAddMethodOutcomeModal=false;
    currentMethodId;
    currentMethodOutcomeIndex;
    currentOutcomeId;
    count = 0;

    connectedCallback() {
        if (this.parentmethodList) {
            this.methodList = JSON.parse(JSON.stringify(this.parentmethodList));
        }
        this.count = this.methodList.length;
    }

    addMethod() {
        this.count++;
        this.methodList.push({ indexNumber: "" + this.count, index: this.methodList.length });
    }

    //event firing from child playbook method outcome screen to toggle the screen and add outcome
    addMethodOutcome(evt)
    {
        this.toggleAddMethodOutcomeModal = false;
        this.methodList[evt.detail.index]["outcomeId"]=evt.detail.selectedOutcome;
        this.methodList[evt.detail.index]["outcomeName"]=evt.detail.selectedOutcomeName;
        this.methodList[evt.detail.index]["methodOutcomeId"]=evt.detail.methodOutcomeId;
    }

    removeMethod(evt) {
        let arr = this.methodList.filter((eachMethod) => evt.target.dataset.index != eachMethod.index);
        arr.forEach((eachMethod, index) => {
            eachMethod.index = index;
        });
        this.methodList = arr;
    }

    handleChange(evt) {
        let elementName = evt?.target?.dataset?.element;
        let value = evt?.target?.value;
        if (elementName == "OrderNumber") {
            this.methodList[evt.target.dataset.index]["orderNumber"] = value;
        }
    }

    handleMethodUpdate(evt) {
        this.methodList[evt.detail.indexNumber]["methodId"] = evt?.detail?.selectedRecord?.Id;
        this.methodList[evt.detail.indexNumber]["methodName"] = evt?.detail?.selectedRecord?.Name;
    }

    @api handleSave() {
        let isInputValid = this.isInputValid();
        
        const oEvent = new CustomEvent("methodsupdate", {
            detail: { methodList: this.methodList, saveComplete: true, isInputValid:  isInputValid}
        });
        this.dispatchEvent(oEvent);
        return true; // to be returning true if data is valid
    
    }

    isInputValid(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.orderNumber');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    // To jump into add method outcome screen
    openAddMethodOutcomeModal(evt)
    {
        this.currentMethodId = this.methodList[evt.target.dataset.index]["methodId"];
        this.currentOutcomeId = this.methodList[evt.target.dataset.index]["methodOutcomeId"];
        this.currentMethodOutcomeIndex = evt.target.dataset.index;
        this.toggleAddMethodOutcomeModal = true;
    }
    closeMethodOutcome()
    {
        this.toggleAddMethodOutcomeModal = false;
    }
}