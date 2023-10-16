import { LightningElement, api, wire } from 'lwc';
//wire Method
import fetchUsers from '@salesforce/apex/GDC_MS_DeactivateMembers.fetchUsers';
import fetchInactiveUsers from '@salesforce/apex/GDC_MS_DeactivateMembers.fetchInactiveUsers';

// Apex call
import idToDeactivate from '@salesforce/apex/GDC_MS_DeactivateMembers.idToDeactivate';
import idToActivate from '@salesforce/apex/GDC_MS_DeactivateMembers.idToActivate';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class GdcmsDeactivateMembers extends LightningElement {
    availableUsers; availableInactiveUsers;
    searchString;
    initialRecords;
    selectedOptionsList = []; selectedInactiveOptionList;
    options = [];
    selected = [];
    allSelected = [];

    get disableButton() {
        return !(this.selectedOptionsList && this.selectedOptionsList.length);
    }
    get disableInactiveUserButton() {
        return !(this.selectedInactiveOptionList && this.selectedInactiveOptionList.length);
    }

    /* @wire(fetchUsers)
     wiredRecs({error,data}) 
     {
         if (data) {
           //  console.log("Records are" + JSON.stringify(data));
             this.availableUsers = data;
             this.initialRecords = data;
         } else if (error) {
             console.log("Error" + JSON.stringify(error));
         }
     }*/
    fetchUser() {
        fetchUsers()
            .then(data => {
                this.availableUsers = data;
                //this.initialRecords = data;
                this.filter();
            })
            .catch(error => {
                console.log("Error" + JSON.stringify(error));
            })

    }
    connectedCallback() {
        this.fetchUser();
    }
    @wire(fetchInactiveUsers)
    wiredInactiveRecs({ error, data }) {
        if (data) {
            //  console.log("Records are" + JSON.stringify(data));
            this.availableInactiveUsers = data;
        } else if (error) {
            console.log("Error" + JSON.stringify(error));
        }
    }

    filter(event) {
        const optToVal = (option) => option.value
        let filter = ''
        if (event) {
            filter = event.target.value
        }
        filter = new RegExp(filter, 'ig');
        this.options = this.availableUsers.filter(option => filter.test(option.label))
        const shownOptions = new Set(this.options.map(optToVal))
        this.selected = this.selectedOptionsList.filter(selected => shownOptions.has(selected))
    }

    handleFilter(event) {

        const optToVal = (option) => option.value
        const shownOptions = new Set(
            this.options.map(optToVal)
        )
        const hiddenOptions = new Set(
            this.availableUsers.map(optToVal).filter(value => !shownOptions.has(value))
        )
        const hiddenSelected = this.selectedOptionsList.filter(value => hiddenOptions.has(value))
        const shownSelected = event.target.value
        this.selectedOptionsList = [...shownSelected, ...hiddenSelected]
        console.log("Selected Options are" + JSON.stringify(this.selectedOptionsList));

    }

    handleUsersChange(event) {
        this.selectedOptionsList = event.detail.value;
        //console.log("Selected Options are" + JSON.stringify(this.selectedOptionsList));
    }
    handleInactiveUsersChange(event) {
        this.selectedInactiveOptionList = event.detail.value;
        // console.log("Selected Options are" + JSON.stringify(this.selectedInactiveOptionList));
    }
    // handleSearchChange(event) {
    //     this.searchString = event.detail.value;
    // }
    handleSearch(event) {
        this.searchString = event.detail.value;
        // console.log("Search String is" + this.searchString);
        if (this.searchString) {
            this.availableUsers = this.initialRecords;
            if (this.availableUsers) {
                let recs = [];
                for (let rec of this.availableUsers) {
                    if (rec.label.toLowerCase().includes(this.searchString.toLowerCase())) {
                        recs.push(rec);
                    }
                }
                //console.log("Matched Users are" + JSON.stringify(recs));
                this.availableUsers = recs;
            }
        } else {
            this.availableUsers = this.initialRecords;
        }
    }
    handleDeactivate() {
        // console.log('deactivate list'+JSON.stringify(this.selectedOptionsList));
        idToDeactivate({ uId: this.selectedOptionsList })
            .then(data => {
                let flag;
                let names = '';
                let datatest = JSON.parse(data);
                // console.log('success'+JSON.stringify(JSON.parse(data)));
                datatest.forEach(element => {

                    if (element.Id == null) {
                        flag = true;
                        names = names ? names + "," + element : element;
                        //names = names + "," +element;
                    }
                    else {
                        flag = false;
                        names = names ? names + "," + element.Name : element.Name;
                    }
                });
                if (flag == true) {
                    const event = new ShowToastEvent({
                        title: 'Please Unselect from selected Users ' + names,
                        message: 'Cannot Deactivate ' + names + ',having subordinates',
                        variant: 'Error',

                    });
                    this.dispatchEvent(event);
                }
                else {
                    const event = new ShowToastEvent({
                        title: 'User Deactivated Successfully ',
                        message: '',
                        variant: 'Success',

                    });
                    this.dispatchEvent(event);
                }
            })
            .catch(error => {
                console.log('Error' + JSON.stringify(error));
            })
    }
    handleActivate() {
        idToActivate({ uId: this.selectedInactiveOptionList })
            .then(data => {
                //console.log('Data Updated'+JSON.stringify(data));
                const event = new ShowToastEvent({
                    title: 'User Activated Successfully ',
                    message: '',
                    variant: 'Success',

                });
                this.dispatchEvent(event);
            })
            .catch(error => {
                console.log('error' + JSON.stringify(error));
            })
    }

}