import { LightningElement, track } from 'lwc';
import getTree from '@salesforce/apex/SolutionFinderTree.getTree';
import getAssignments from '@salesforce/apex/SolutionFinderAssignments.getAssignments'; 
import saveAssignment from '@salesforce/apex/SolutionFinderAssignment.saveAssignment';

import { subscribe } from 'lightning/empApi';

const STATE_SEARCH = 'search';
const STATE_EDIT = 'edit';

export default class SolutionFinderAssignments extends LightningElement {
    @track isLoading = false;
    @track options;
    @track items;
    @track state = STATE_SEARCH;
    @track selectedUser;
    @track assignments = [];
    @track assignmentsByOptionName = {};

    connectedCallback() {
        this.initTree();
        this.subscribeToPlatformEvents();
    }

    get userId() {
        return this.selectedUser ? this.selectedUser.Id : null;
    }

    initTree() {
        getTree({})
            .then(results => {
                this.items = results.items;
            })
            .catch(error => {
                console.log("Error getting tree: " + error);
            })
    }

    initAssignments() {
        this.isLoading = true;
        getAssignments({ userId: this.userId })
            .then(results => {
                this.assignments = results;
                this.organizeAssignmentsByOptionName();
            })
            .catch(error => {
                console.log("Error getting assignments: " + error);
            })
    }

    organizeAssignmentsByOptionName() {
        var assignmentsByOptionName = {};
        for (var i = 0; i < this.assignments.length; i++) {
            assignmentsByOptionName[this.assignments[i].optionName] = this.assignments[i];
        }
        this.assignmentsByOptionName = assignmentsByOptionName;
        this.isLoading = false;
    }

    subscribeToPlatformEvents() {
        subscribe('/event/Solution_Finder_Event__e', -1, this.platformEventCallback.bind(this))
            .then(response => {
                // no action required
            })
            .catch(error => {
                console.log("Error subscribing to platform events: " + error);
            })
    }

    platformEventCallback(response) {
        this.initAssignments();
    }

    get displaySearch() {
        return this.state === STATE_SEARCH;
    }

    get displayEdit() {
        return this.state === STATE_EDIT;
    }

    get selectedUserName() {
        return this.selectedUser ? this.selectedUser.FirstName + " " + this.selectedUser.LastName : "";
    }

    handleUserSelected(event) {
        this.selectedUser = event.detail;
        this.initAssignments();
        this.state = STATE_EDIT;
    }

    handleChangeUser() {
        this.selectedUser = null;
        this.state = STATE_SEARCH;
    }

    handleRoleChange(event) {
        this.isLoading = true;
        var item = event.detail.item;
        var role = event.detail.role;
        if (item && role) {
            saveAssignment({ userId: this.userId, optionName: item.name, role: role })
                .then(results => {
                    this.initAssignments();
                })
                .catch(error => {
                    console.log("Error changing role: " + JSON.stringify(error));
                })
        }
    }
}