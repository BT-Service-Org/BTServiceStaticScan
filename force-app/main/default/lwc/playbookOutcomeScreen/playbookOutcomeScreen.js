import { LightningElement, track, api,wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createOutcomeRecord from "@salesforce/apex/PlaybookController.createOutcomeRecord";

export default class PlaybookOutcomeScreen extends LightningElement {
    @track outcomeList = [];
    @track outcomeIdVsMethod = [];
    @api parentoutcomeList = [];
    @api parentoutcomeIdVsMethod = [];
    @api outcomeIndex;
    count = 0;
    recordTypeId=null;

    toggleCreateOutcomeModal;
    isLoading;
    outcomeName;
    outcomeTitle;
    outcomeDescription;
    toggleAddMethodModal;
    currentOutcomeForMethodAddition = -1;
    currentMethodsForSelectedOutcome;
    isInputValid;
    outcomeOrder;

    connectedCallback() {
        if (this.parentoutcomeList) {
            this.outcomeList = JSON.parse(JSON.stringify(this.parentoutcomeList));
            this.outcomeIdVsMethod = JSON.parse(JSON.stringify(this.parentoutcomeIdVsMethod));
        }
        this.count = this.outcomeList.length;
    }

    addOutcome() {
        this.count++;
        this.outcomeList.push({ indexNumber: "" + this.count, index: this.outcomeList.length });
        this.outcomeIdVsMethod.push({ outcomeId: null, outcomeOrder: null, methods: [] });
    }

    handleOrderChange(evt){
        let indexNumber = evt.target.dataset.index;
        if(this.outcomeList[indexNumber]!=null)
        {
            this.setOutcomeNumber(indexNumber,evt?.target?.value);
        }
    }

    setOutcomeNumber(indexNumber,outcomeOrder)
    {
        this.outcomeList[indexNumber]["outcomeOrder"] = outcomeOrder;
        this.outcomeIdVsMethod[indexNumber]["outcomeOrder"] = outcomeOrder;
    }

    handleOucomeSelection(evt) {
        let selectedRecordId = evt?.detail?.selectedRecord?.Id;
        let selectedRecordName = evt?.detail?.selectedRecord?.Name;
        let indexNumber = evt.detail.indexNumber;
        this.outcomeList[indexNumber]["recordId"] = selectedRecordId;
        if (this.outcomeIdVsMethod[indexNumber]) {
            this.outcomeIdVsMethod[indexNumber]["outcomeId"] = selectedRecordId;
            this.outcomeIdVsMethod[indexNumber]["outcomeName"] = selectedRecordName;
        } else {
            this.outcomeIdVsMethod.push({ outcomeId: selectedRecordId, methods: [] });
        }
    }

    removeOutcome(evt) {
        let arr = this.outcomeList.filter((eachOutcome) => evt.target.dataset.index != eachOutcome.index);
        arr.forEach((eachOutcome, index) => {
            eachOutcome.index = index;
        });

        let arrMap = this.outcomeIdVsMethod.filter((eachOutcome) => this.outcomeList[evt.target.dataset.index].recordId != eachOutcome.outcomeId);
        this.outcomeIdVsMethod = arrMap;

        this.outcomeList = arr;
    }

    @api handleSave() {
        debugger;

        const oEvent = new CustomEvent("outcomesupdate", {
            detail: { outcomeIdVsMethod: this.outcomeIdVsMethod, saveComplete: true, outcomeIndex: this.outcomeIndex}
        });
        this.dispatchEvent(oEvent);
        return true; // to be returning true if data is valid
    }

    handleCreateOutcomeModal(evt) {
        this.toggleCreateOutcomeModal = true;
    }

    handleCloseCreateOutcome(evt) {
        this.outcomeName = "";
        this.outcomeDescription = "";
        this.outcomeTitle = "";
        this.toggleCreateOutcomeModal = false;
    }

    handleCreateOutcomeRecord(evt) {

        let obj = {
            Name: this.outcomeName,
            Description__c: this.outcomeDescription,
            Title__c: this.outcomeTitle
        };

        debugger;
        this.isLoading = true;
        createOutcomeRecord({ name: obj.Name, description: obj.Description__c, title: obj.Title__c })
            .then((res) => {
                this.isLoading = false;
                this.outcomeName = "";
                this.outcomeDescription = "";
                this.outcomeTitle = "";
                const event = new ShowToastEvent({
                    title: "Outcome Saved!",
                    message: "New outcome has been created successfully",
                    variant: "success",
                    mode: "pester"
                });
                this.dispatchEvent(event);

                this.toggleCreateOutcomeModal = false;
            })
            .catch((err) => {
                console.error(err);
            });
    }

    handleChange(evt) {
        let element = evt?.target?.dataset?.element;
        if (element == "OutcomeName") {
            this.outcomeName = evt.target.value;
        } else if (element == "OutcomeTitle") {
            this.outcomeTitle = evt.target.value;
        } else if (element == "OutcomeDescription") {
            this.outcomeDescription = evt.target.value;
        }
    }

    handleCloseAddMethods() {
        this.toggleAddMethodModal = false;
    }

    handleJumpToStage()
    {
        this.handleDoneAddMethods();
        const oEvent = new CustomEvent("jumptostage",{
            detail: { outcomeIdVsMethod: this.outcomeIdVsMethod, saveComplete: true }
        });
        this.dispatchEvent(oEvent);
    }

    handleDoneAddMethods() {
        this.template.querySelector("c-playbook-add-method-screen[data-addmethod]").handleSave();
          if(this.isInputValid){
            this.toggleAddMethodModal = false;
          }
    }

    openAddMethodsModal(evt) {
        this.outcomeIdVsMethod[evt.target.dataset.index]["stageMethodOutcomes"]?.forEach((eachMethod, index) => {
            eachMethod.indexNumber = "" + index;
            eachMethod.index = index;
        });
        this.currentMethodsForSelectedOutcome = this.outcomeIdVsMethod[evt.target.dataset.index]["stageMethodOutcomes"];
        this.currentOutcomeForMethodAddition = evt.target.dataset.index;
        this.toggleAddMethodModal = true;
    }

    handleUpdateMethodsForOutcome(evt) {
        this.outcomeIdVsMethod[this.currentOutcomeForMethodAddition]["stageMethodOutcomes"] = evt.detail.methodList;
        this.isInputValid = evt.detail.isInputValid;
    }
}