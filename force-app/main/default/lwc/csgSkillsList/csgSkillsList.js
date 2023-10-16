import { LightningElement, track, wire, api} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getAllUserSkillsList from '@salesforce/apex/CSGSkillsListController.getAllUserSkillsList';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/PA_Onboarding__c.Name';
import CANDIDATE_FIELD from '@salesforce/schema/PA_Onboarding__c.Candidate__c';

const columns = [
    { label: 'Skill', fieldName: 'skillName' },
    { label: 'Skill Rating', fieldName: 'expertiseRating', type: 'text', sortable: true }
];

const fields = [NAME_FIELD, CANDIDATE_FIELD];

export default class CsgSkillsList extends NavigationMixin(LightningElement) {
    @track userSkills = [];
    @track columns = columns;
    @track tableLoadingState = true;
    @track skillsCount = 0;
    @track isCurrentUser = false;
    @api recordId;
    userId = USER_ID;
    sortTemp = [];
    @track sortedBy;
    @track sortDirection;
    @wire(CurrentPageReference)
    pageRef;
    @wire(getRecord, { recordId: '$recordId', fields })
    onBoarding;

    get testCurrentUser(){
        const currentUserId = this.userId,
            candidateUserId = getFieldValue(this.onBoarding.data, CANDIDATE_FIELD);
        if(currentUserId === candidateUserId){
            return true;
        }
        return false;
    }

    updateColumnSorting(event) {        
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        console.log(fieldName + " : " + sortDirection);
        //asc
        if(sortDirection === 'asc'){
            this.userSkills = [...this.userSkills.sort((a, b) => (a.expertiseRating > b.expertiseRating) ? 1 : -1)];            
        } else {
            this.userSkills = [...this.userSkills.sort((a, b) => (a.expertiseRating > b.expertiseRating) ? -1 : 1)];    
        }
    }    
    
    navigateToSkillsApp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                'apiName': 'CSG_Skills_App'
            },
            state: {
                'c__foobar1':'fooBazz,fooBuzz,buzzFoo,bazzFoo'
            }
        });
    }

    testDataUpdate() {
        this.userSkills = [
            {"skillName":"fooBar0", "expertiseRating":"fooBuzz0"},
            {"skillName":"fooBar1", "expertiseRating":"fooBuzz1"},
            {"skillName":"fooBar2", "expertiseRating":"fooBuzz2"}
        ]
    }
//DEFAULT TO NOT SET
    async connectedCallback() {
       getAllUserSkillsList({onboardingRecordId: this.recordId})
        .then(result => {
            this.sortTemp = result;
            this.userSkills = result.sort((a, b) => (a.expertiseRating > b.expertiseRating) ? -1 : 1);
            this.tableLoadingState = false;
        })
        .catch(error => {
            this.error = error;
        });
    }
}