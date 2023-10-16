import { LightningElement, api, track } from 'lwc';

export default class PscMultiSelectLookup extends LightningElement {
    @api recordList = [];
    @api searchFieldName;
    @api label;
    @api required;
    @api placeholder;
    @api showHelpText;
    @api helpText;
    @track searchRecords = [];
    @track selectedRecords = [];
    @track messageFlag = false;
    @track isSearchLoading = false;
    
    @track searchKey;
    delayTimeout;
    
    searchField() {
        const selectedRecordIds = [];
        this.selectedRecords.forEach(ele=>{
            selectedRecordIds.push(ele.Id);
        })
        if(this.searchKey){
            this.searchRecords = this.recordList.filter((item) => (item[this.searchFieldName]?.toLowerCase()?.includes(this.searchKey.toLowerCase()) && !selectedRecordIds.includes(item.Id)));
            this.isSearchLoading = false;
            const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
            const clsList = lookupInputContainer.classList;
            clsList.add('slds-is-open');
            if (this.searchKey.length > 0 && this.searchRecords.length == 0) {
                this.messageFlag = true;
            } else {
                this.messageFlag = false;
            }
        }
    }
    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Do not update the reactive property as long as this function is
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
            this.searchField();
        }, 300);
    }
    // method to toggle lookup result section on UI 
    toggleResult(event) {
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                this.searchField();
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');
                break;
        }
    }
    setSelectedRecord(event) {
        const recId = event.target.dataset.id;
        let newsObject = this.searchRecords.find(data => data.Id === recId);
        this.selectedRecords.push(newsObject);
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        let selRecords = this.selectedRecords;
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        const selectedEvent = new CustomEvent('selected', { detail: { selRecords }, });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    removeRecord(event) {
        let selectRecId = [];
        for (let i = 0; i < this.selectedRecords.length; i++) {
            if (event.detail.name !== this.selectedRecords[i].Id)
                selectRecId.push(this.selectedRecords[i]);
        }
        this.selectedRecords = [...selectRecId];
        let selRecords = this.selectedRecords;
        const selectedEvent = new CustomEvent('selected', { detail: { selRecords }, });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}