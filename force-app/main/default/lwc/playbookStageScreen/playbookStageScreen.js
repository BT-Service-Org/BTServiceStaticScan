import { LightningElement, track, api } from "lwc";
import getPlaybookDetails from "@salesforce/apex/PlaybookController.getPlaybookDetails";
import savePlaybookDetails from "@salesforce/apex/PlaybookController.savePlaybookDetails";
// import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { FlowNavigationFinishEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from "lightning/flowSupport";

export default class PlaybookStageScreen extends NavigationMixin(LightningElement) {
    @track stageArray = [];
    count = 0;
    @api recordId;
    @api playbookName;
    @api playbookDescription;
    @api playbookContractType;
    isLoading;
    showToast;
    @track currentOutcome;

    daysWeeksOptions = [
        { value: "Days", label: "Days" },
        { value: "Weeks", label: "Weeks" }
    ];

    toggleAddOutcomes;
    currentStageIndexForOutcome = -1;
    currentOutcomeList;
    currentOutcomeMap;
    toggleViewSummary;

    loadPlaybookDetails() {
        getPlaybookDetails({ playbookId: this.recordId })
            .then((res) => {
                let response = JSON.parse(res);
                let arr = response.stages;
                arr.forEach((eachItem, index) => {
                    eachItem.indexNumber = "" + index;
                    eachItem.index = "" + index;
                    eachItem.label = "Stage " + (index + 1);
                });
                this.stageArray = arr;
                this.count = this.stageArray.length;
                this.isLoading = false;
            })
            .catch((e) => {
                alert(JSON.stringify(e));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: JSON.stringify(e),
                        variant: "error"
                    })
                );
            });
    }

    connectedCallback() {
        // const event = new ShowToastEvent({
        //     title: 'Ttitle',
        //     message: 'Message',
        //     variant: 'success',
        //     mode: 'dismissable'
        // });
        // this.dispatchEvent(event);
        if (this.recordId) {
            this.isLoading = true;
            this.loadPlaybookDetails();
        }
    }

    addStage() {
        this.count++;
        this.stageArray.push({ indexNumber: "" + this.count,MandatoryStage: false });
        this.updateLabelAndIndex();
    }

    handleChange(evt) {
        debugger;
        let index = parseInt(evt.target.dataset.index);
        let elementName = evt.target.dataset.element;
        let type = evt.target.type;
        if (index >= 0) {
            this.stageArray[index][elementName] = evt.target.type == 'checkbox' ? evt.target.checked : evt.target.value ;
        }
        /* if (index >= 0) {
            this.stageArray[index][elementName] = evt.target.value ? evt.target.value : evt.target.checked ? true : evt.target.checked;
        } */
    }

    handleDeleteStage(evt) {
        debugger;
        let index = parseInt(evt.target.dataset.index);
        let newArray = [];
        newArray = this.stageArray.filter((eachStage) => eachStage.index != index);
        this.stageArray = newArray;
        this.updateLabelAndIndex();
    }

    updateLabelAndIndex() {
        this.stageArray.forEach((eachStage, index) => {
            eachStage.label = "Stage " + (index + 1);
            eachStage.index = "" + index;
        });
    }

    handleOpenAddOutcomes(evt) {
        let outcomeList = [];
        let outcomeVsStageMethodOutcomeIds = [];
        this.currentOutcome = evt.target.dataset.index;

        this.stageArray[evt.target.dataset.index]?.outcomeVsStageMethodOutcomeIds?.forEach((eachOutcome, index) => {
            outcomeList.push({ indexNumber: "" + index, index: index, recordId: eachOutcome.outcomeId, outcomeOrder: eachOutcome.outcomeOrder});
            outcomeVsStageMethodOutcomeIds.push(eachOutcome);
        });

        this.currentOutcomeList = outcomeList;
        this.currentOutcomeMap = outcomeVsStageMethodOutcomeIds;

        this.currentStageIndexForOutcome = parseInt(evt.target.dataset.index);

        this.toggleAddOutcomes = true;
    }

    handleCloseAddOutcomes() {
        this.toggleAddOutcomes = false;
    }

    handleDoneAddOutcomes() {
        this.template.querySelector("c-playbook-outcome-screen[data-outcome]").handleSave();
        this.toggleAddOutcomes = false;
    }

    handleOutcomeSelection(evt) {
        debugger;
        this.currentStageIndexForOutcome = evt.detail.outcomeIndex;
        this.stageArray[this.currentStageIndexForOutcome]["outcomeVsStageMethodOutcomeIds"] = evt.detail.outcomeIdVsMethod;
        this.currentStageIndexForOutcome = -1;
    }

    jumpToStage(evt)
    {
        this.stageArray[this.currentStageIndexForOutcome]["outcomeVsStageMethodOutcomeIds"] = evt.detail.outcomeIdVsMethod;
        this.currentStageIndexForOutcome = -1;
        this.handleDoneAddOutcomes();
    }

    toastMessage;

    handleSave() {
        this.isLoading = true;
        let request = { playbookId: this.recordId, playbookName: this.playbookName, playbookDescription: this.playbookDescription, playbookContractType: this.playbookContractType, stages: this.stageArray };
        savePlaybookDetails({ wrapperString: JSON.stringify(request) })
            .then((res) => {
                this.recordId = res;

                this.variant = "success";
                this.toastMessage = "Playbook has been modified/created successfully";
                this.isLoading = false;
                this.showToast = true;
                setTimeout(() => {
                    this.showToast = false;
                }, 3000);
                this.loadPlaybookDetails();
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                
            })
            .catch((e) => {
                this.variant = "error";
                this.toastMessage = e?.body?.message;
                this.showToast = true;
                setTimeout(() => {
                    this.showToast = false;
                }, 3000);
                this.isLoading = false;
            });
    }

    closeToast() {
        this.showToast = false;
    }

    handlePrevious() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    variant;
    get toastClass() {
        if (this.variant == "success") {
            return "slds-notify slds-notify_toast slds-theme_success";
        } else if (this.variant == "error") {
            return "slds-notify slds-notify_toast slds-theme_error";
        }
    }

    handleOpenViewSummary() {
        this.toggleViewSummary = true;
    }

    handleCloseViewSummary(_evt) {
        this.toggleViewSummary = false;
    }

}