import { LightningElement, track, wire } from 'lwc';
import getPicklistValuesForUi from '@salesforce/apex/GDC_SlotBookingFiltersController.getPicklistValuesForUi';
import getInterviewersBasedOnFilters from '@salesforce/apex/GDC_SlotBookingFiltersController.getInterviewersBasedOnFilters';
import getFutureHiringEvents from '@salesforce/apex/GDC_SlotBookingFiltersController.getFutureHiringEvents';
import createNewHiringEvent from '@salesforce/apex/GDC_SlotBookingFiltersController.createNewHiringEvent';
import deleteHiringEvents from '@salesforce/apex/GDC_SlotBookingFiltersController.deleteHiringEvents';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Hiring Event Date', fieldName: 'ActivityDate' }
];

export default class GdcSlotBookingFilters extends LightningElement {
    @track filters = {
        jobPosting : '',
        hiringManager : '',
        skill : ''
    }

    @track columns = COLUMNS;
    @track postingOptions = [];
    @track hiringManagerOptions = [];
    @track skillOptions = [];
    @track interviewerOptions = [];
    @track selectedInterviewers = [];
    showCalendar = false;
    disableCheckSlotsButton = false;
    showSpinner = true;
    showInterviewers = false;
    showHiringEventModal = false;
    @track existingHiringEvents = [];
    showExistingHiringEvents = false;
    showDelete = false;
    @track hiringEvtDate = null;
    @track hiringEvtsSelected = [];
    // @track allSlots = [];

    get minDate() {
        let date = new Date();
        return date.toISOString();
    }

    @wire(getPicklistValuesForUi)
    uiPicklistVals({
        error,
        data
    }) {
        if (data) {
            this.showSpinner = false;
            this.hiringManagerOptions = [...data.hiringManagerOptions];
            this.postingOptions = [...data.postingOptions];
            this.skillOptions = [...data.skillOptions];
            this.interviewerOptions = [...data.interviewerOptions];
            if(!this.hiringManagerOptions.length) {
                this.showToastMessage('Error', 'error', 'No Hiring managers present');
                return;
            } else if(!this.interviewerOptions.length) {
                this.showToastMessage('Error', 'error', 'No Interviewers present for the selected criteria');
                return;
            }
            this.filters = {
                jobPosting : this.postingOptions[0].value,
                hiringManager : this.hiringManagerOptions.map(opt => opt.value).join(';'),
                skill : this.skillOptions[0].value,
            }
            this.showInterviewers = true;
            this.selectedInterviewers = this.interviewerOptions.map(opt => opt.value);
            
        }else if (error) {
            this.showSpinner = false;
            console.error(error);
        }
    }
    
    handleFilterChange(event) {
        const filterName = event.target.name;
        if(event.target.nodeName == 'C-GDC-MULTI-SELECT-PICKLIST'){
            let managers = event.detail.values;
            managers = [...managers];
            if(!managers.length) {
                managers = this.hiringManagerOptions.map(opt => opt.value);
            }
            this.filters[filterName] = managers.join(';')
        }else{
            this.filters[filterName] = event.target.value;
        }
        
        this.showCalendar = false;
        if(this.template.querySelector('c-multi-select-picklist') != null) {
            this.template.querySelector('c-multi-select-picklist').clear();
        }
        this.showSpinner = true;
        this.showInterviewers = false;
        // this.allSlots = [];
        getInterviewersBasedOnFilters({
            stringifiedFilters: JSON.stringify(this.filters)
        }).then(result => {
            this.showSpinner = false;
            this.selectedInterviewers = [];
            if(!result.length) {
                this.showToastMessage('Error', 'error', 'No Interviewers present for the selected criteria');
                this.interviewerOptions = [];
                this.disableCheckSlotsButton = true;
                return;
            }
            console.log(JSON.stringify(result));
            this.interviewerOptions = [...result];
            this.disableCheckSlotsButton = false;
            this.showInterviewers = true;
            this.selectedInterviewers = this.interviewerOptions.map(opt => opt.value);
        }).catch(err => {
            this.showSpinner = false;
            this.selectedInterviewers = [];
            this.interviewerOptions = [];
            this.disableCheckSlotsButton = true;
            this.showToastMessage('Error', 'error', err.body.message);

        })
    }

    refreshCalendar() {
        const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (!allValid) {
            return;
        }
        this.showSpinner = true;
        window.setTimeout(() => {
            this.showSpinner = false;
            this.showCalendar = true;
        },1000);
        
    }

    handleInterviewerChange(e) {
        const values = e.detail.values;
        console.log('values**' + JSON.stringify(values));
        this.selectedInterviewers = [...values];
        if(!this.selectedInterviewers.length) {
            this.selectedInterviewers = this.interviewerOptions.map(opt => opt.value);
        }
        console.log('selectedInterviewers**'+ this.selectedInterviewers);
        this.showCalendar = false;
    }

    showToastMessage(title, variant, message) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }

    createHiringEvent() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (!allValid) {
            return;
        }
        this.showSpinner = true;
        createNewHiringEvent({
            evtDate: this.hiringEvtDate
        }).then(result=> {
            this.showSpinner = false;
            this.closeModal();
            this.hiringEvtDate = null;
            this.showToastMessage('Success', 'success', 'Hiring Event created successfully!');
        }).catch(err=> {
            console.log(err);
            this.showSpinner = false;
            this.showToastMessage('Error', 'error', err.body.message);
            
        })
        
    }

    openHiringEventModal() {
        this.showHiringEventModal = true;
        this.getHiringEventsFromApex();
    }
    closeModal() {
        this.showHiringEventModal = false;
        this.showExistingHiringEvents = false;
        this.showDelete =false;
        this.hiringEvtsSelected = [];
    }
    
    getHiringEventsFromApex() {
        this.showSpinner = true;
        getFutureHiringEvents()
        .then(result => {
            this.existingHiringEvents = [...result];
            if(this.existingHiringEvents.length) {
                this.showExistingHiringEvents = true;
            }
            this.showSpinner = false;
        }).catch(err => {
            this.showSpinner = false;
            console.log(err);
        })
    }

    handleHiringEvtDateChange(e) {
        const inputCmp = this.template.querySelector('.dateinput');
        const existingevt = this.existingHiringEvents.find(evt => evt.ActivityDate === e.target.value);
        if(existingevt !== undefined && existingevt !== null) {
            inputCmp.setCustomValidity('A Hiring Event on this date already exists');
        }else {
            inputCmp.setCustomValidity('');
            this.hiringEvtDate = e.target.value;
        }
        inputCmp.reportValidity();
    }

    handleCheckboxChange(e) {
        console.log(e.target.checked);
        if(e.target.checked) {
            this.hiringEvtsSelected.push(e.target.dataset.id);
        } else {
            const index = this.hiringEvtsSelected.indexOf(e.target.dataset.id);
            if (index > -1) {
                this.hiringEvtsSelected.splice(index, 1); // 2nd parameter means remove one item only
            }
        }
        if(this.hiringEvtsSelected.length) {
            this.showDelete = true;
        }else {
            this.showDelete = false;
        }
        console.log(JSON.stringify(this.hiringEvtsSelected));
    }

    deleteSelectedEvents() {
        this.showSpinner = true;
        deleteHiringEvents({
            evtIds: this.hiringEvtsSelected
        }).then(result=> {
            this.showSpinner = false;
            this.closeModal();
            this.showToastMessage('Success', 'success', 'Selected Hiring Events deleted successfully!');
        }).catch(err => {
            this.showSpinner = false;
            this.showToastMessage('Error', 'error', err.body.message);
        })
    }

}