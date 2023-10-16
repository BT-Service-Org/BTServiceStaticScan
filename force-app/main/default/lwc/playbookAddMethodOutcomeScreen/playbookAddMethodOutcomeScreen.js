import { LightningElement,api,track } from 'lwc';
import getMethodOutcomes from "@salesforce/apex/PlaybookController.getMethodOutcomes";

export default class PlaybookAddMethodOutcomeScreen extends LightningElement {
    @api currentMethodId;
    @api currentMethodOutcomeIndex;
    @track listMethodOutcomes = [];
    @api selectedOutcome;
    @api index;
    outcomeName;
    methodOutcomeId;

    connectedCallback()
    {
        this.queryMethodOutcomes();
    }

    handleMethodOutcomeUpdate(evt)
    {
        this.currentMethodId = evt?.detail?.selectedRecord?.Id;
        this.queryMethodOutcomes();
    }

    queryMethodOutcomes()
    {
        getMethodOutcomes({ recordId: this.currentMethodId})
        .then((result) => {
            if (result != null) {
                this.listMethodOutcomes = result.Method_Outcomes__r;
                if(this.selectedOutcome !== undefined)
                {
                    this.setLockedValues();
                }
                else{
                    this.unlockValues();
                }
                console.log('this.listMethodOutcomes');
                console.log(this.listMethodOutcomes);
            }
        })
        .catch((error) => {
            this.error = error;
            this.selectedRecord = {};
        });
    }
    handleCloseAddMethodOutcome(evt)
    {
        const oEvent = new CustomEvent("closeaddmethodoutcome");
        this.dispatchEvent(oEvent);
    }

    handleOnBoxChecked(evt)
    {
        let value = evt?.target?.value;
        this.selectedOutcome = value;
        console.log(value);
    }

    unlockValues()
    {
        this.selectedOutcome = undefined;
        for(const rec in this.listMethodOutcomes)
        {
            this.listMethodOutcomes[rec]["checked"]=false;
        }
    }

    setLockedValues()
    {
        for(const rec in this.listMethodOutcomes)
        {
            console.log('this.listMethodOutcomes[rec]["Id"]!=this.selectedOutcome');
            console.log(this.selectedOutcome);
            console.log(this.listMethodOutcomes[rec]["Id"]);
            if(this.listMethodOutcomes[rec]["Id"]!=this.selectedOutcome)
            {
                this.listMethodOutcomes[rec]["checked"]=false;
            }
            else{
                this.listMethodOutcomes[rec]["checked"]=true;
            }
        }
    }

    get getSelectedOutcome()
    {
        return selectedOutcome;
    }

    handleDoneAddMethodOutcomes(evt)
    {
        for(const rec in  this.listMethodOutcomes)
        {
            if(this.listMethodOutcomes[rec]["Id"]==this.selectedOutcome)
            {
                this.outcomeName = this.listMethodOutcomes[rec].Outcome__r.Name;
                this.methodOutcomeId = this.listMethodOutcomes[rec].Id;
            }
        }
        const methodOutcomeEvent = new CustomEvent("selectoutcome", {
            detail: { selectedOutcomeName: this.outcomeName, selectedOutcome: this.selectedOutcome, index: this.currentMethodOutcomeIndex, methodOutcomeId: this.methodOutcomeId }
        });
        this.dispatchEvent(methodOutcomeEvent);
    }
}