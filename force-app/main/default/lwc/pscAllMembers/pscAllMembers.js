import { LightningElement, wire } from 'lwc';
import getTabToMemberSetting from '@salesforce/apex/PSCMembersCtrl.getSetting';
import { CurrentPageReference } from 'lightning/navigation';
export default class PscAllMembers  extends LightningElement {
    componentConfig = [];
    tabNameToMemberData = [];
    searchInput;
    memberNameKey = '';
    showSpinner = true;
    searchKeyMinLen = 2; // Minimum number of characters required in searchbox. This can be configured in Contribution_Team_Member record of PS Connect Settings metadata.
    searchResultsDefaultTab = 'All Members'; // This tab name should be present as a key (searchDefaultTab) in the Value__c field of Contribution_Team_Member record of PS Connect Settings metadata.
                                            // If this label is to be changed then change the key (searchDefaultTab) as well as the tabLabel.
    // This variable has the URL to redirect the user to a new page whcih has the component to display all team members associated to the Community.
    showAllMembersURL;
    showAllRecords = false; // This falg determines if all records are to be displayed.
    hideShowAllLink = true; // This flag determines if Show All link is display. If all records are displayed in the component then Show All link is hidden.
    displayMaxRecords = 16; // Default number of records to be displayed. This variable is updated with the value store in Custom metadata record Contribution_Team_Member of PS Connect Settings.\
    communityPageName;
    viewAllParam;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {

        if (currentPageReference) {
            this.communityPageName = currentPageReference.state?.name;
            this.viewAllParam = currentPageReference.state?.view;
        }
    }

    @wire(getTabToMemberSetting, {settingNameStr : 'Contribution_Team_Member'}) getTabToMembersData({ error, data }) {
        if (data) {
            if (data != undefined) {
                this.componentConfig = JSON.parse(data);
                this.tabNameToMemberData = this.componentConfig.tabs; 
                let urlPathWithNameParam = (this.componentConfig && this.componentConfig.urlPathWithCommNameParam && this.componentConfig.urlPathWithCommNameParam.length > 0 ? this.componentConfig.urlPathWithCommNameParam : '/ServicesCentral/s/community/community-members?name=');
                let urlParamViewAll = (this.componentConfig && this.componentConfig.urlParamViewAll ? this.componentConfig.urlParamViewAll : 'view');
                let urlParamViewAllValue = (this.componentConfig && this.componentConfig.urlParamViewAllValue ? this.componentConfig.urlParamViewAllValue : 'all');
                this.searchResultsDefaultTab = (this.componentConfig && this.componentConfig.searchDefaultTab && this.componentConfig.searchDefaultTab.length > 0 ? this.componentConfig.searchDefaultTab : this.searchResultsDefaultTab);
                this.searchKeyMinLen = (this.componentConfig && this.componentConfig.minLengthSearchInput && !isNaN(this.componentConfig.minLengthSearchInput) ? this.componentConfig.minLengthSearchInput : this.searchKeyMinLen);
                let displayAllRecords = this.viewAllParam == urlParamViewAllValue;
                this.displayMaxRecords = (this.componentConfig && this.componentConfig.maxRecordsInCompactMode != undefined ? (isNaN(this.componentConfig.maxRecordsInCompactMode) ? 0 : this.componentConfig.maxRecordsInCompactMode) : this.displayMaxRecords);
                this.showAllRecords = (displayAllRecords ? displayAllRecords : !(this.displayMaxRecords));
                this.hideShowAllLink = this.showAllRecords;
                this.showAllMembersURL = urlPathWithNameParam + this.communityPageName + '&' + urlParamViewAll + '=' + urlParamViewAllValue;
            }
        }
        if (error) {
            console.log("Error", error);
        }
    }

    handleMemberName(event) {
        this.searchInput = event.currentTarget.value;
    }

    handleSearch() {
        let element = this.template.querySelector('.search-input');
        if (this.searchInput && this.searchInput.length > 0 && this.searchInput.length < this.searchKeyMinLen) {
            element.setCustomValidity('Please enter at least '+ this.searchKeyMinLen + ' characters.');
        } else {
            element.setCustomValidity('');
        }
        element.reportValidity();

        if(this.searchInput && this.searchInput.length >= this.searchKeyMinLen) {
            let tabsetElement = this.template.querySelector('lightning-tabset');
            tabsetElement.activeTabValue = this.searchResultsDefaultTab;
            this.memberNameKey = this.searchInput;
        } else {
            this.memberNameKey = '';
        }
    }

    handleSelectTab() {
        this.memberNameKey = '';
    }

}