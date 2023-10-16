import { LightningElement, track, wire } from 'lwc';
import search from '@salesforce/apex/SolutionFinderUserSearch.search'
import getSearchResultColumns from '@salesforce/apex/SolutionFinderUserSearch.getSearchResultColumns'

const DELAY = 300;

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' }
];

const staticColumns = [
    {"type":"text","label":"First Name","fieldName":"FirstName", typeAttributes: { rowActions: actions, menuAlignment: 'left' } },
    {"type":"text","label":"Last Name","fieldName":"LastName"},
    {"type":"text","label":"Email","fieldName":"Email"},
    {"type":"text","label":"SAML Federation ID","fieldName":"FederationIdentifier"}
];

export default class SolutionFinderUserSearch extends LightningElement {
    @track searchCriteria;
    @track columns = staticColumns;
    @track userList = [];
    @track showError = false;
    @track isSearching = false;
  
    connectedCallback() {
        //this.initColumns();
    }

    renderedCallback() {
        this.template.querySelector('[data-id="input"]').focus();
    }

    initColumns() {
        getSearchResultColumns()
            .then(results => {
                this.columns = results;
            })
            .catch(error => {
                console.log("Error getting columns: " + error);
            })
    }

    get usersFound() {
        return this.userList && this.userList.length > 0;
    }
  
    handleInputChange(event) {
      this.showError = false;
      const SEARCH_CRITERIA = event.target.value;
      window.clearTimeout(this.delayTimeout);
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.delayTimeout = setTimeout(() => {
        if (SEARCH_CRITERIA.length < 3) {
          this.showError = true;
        } else {
          this.search = SEARCH_CRITERIA;
          this.updateUsers();
        }
      }, DELAY);
    }

    updateUsers() {
        this.isSearching = true;
        search({ "searchCriteria": this.search })
            .then(results => {
                this.userList = results;
                this.isSearching = false;
            })
            .catch(error => {
                console.log("Error searching for users: " + JSON.stringify(error));
                this.isSearching = false;
            })
    }

    handleRowSelection(event) {
        const ROW = event.detail.row;
        if (event.detail && event.detail.selectedRows && event.detail.selectedRows.length > 0) {
            let selectedRow = event.detail.selectedRows[0];
            this.dispatchEvent(new CustomEvent('selected', { detail: selectedRow }));
        }
    }
  }