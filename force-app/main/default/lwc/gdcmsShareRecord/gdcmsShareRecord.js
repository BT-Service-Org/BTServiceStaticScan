import { api, LightningElement,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchUser from '@salesforce/apex/GDCMSUserSearch.searchUser';
import assignPermissionSet from '@salesforce/apex/GDCMSUserSearch.assignPermissionSet';
import workIntakeShare from '@salesforce/apex/GDCMSWorkIntakeShare.workIntakeShare';
export default class GdcmsShareRecord extends LightningElement {

    @api recordId;

    @track searchKey = '';
    @track userIds = [];
    @track selectedUsers = [];
    @track inFocus = true;

    accessType_Value = '';

    get options() {
        return [
            { label: 'Read', value: 'Read' },
            { label: 'Read & Edit', value: 'Edit' }
        ];
    }
    typingTimer;
    userLoadState = {
        resultsFound: false,
        data: undefined,
        error: undefined,
        isLoading : undefined
      };

    handleSearch(event){
        this.inFocus = true;
        let strValue = event.target.value;

        if(strValue.length < 3) return

        clearTimeout(this.typingTimer);
        const searchKey = event.target.value
        this.typingTimer = setTimeout(() => {
            this.searchKey = searchKey;
            this.userLoadState.isLoading = true;
            this.userLoadState.resultsFound = false;
        }, 200)
    }

    handleOnBlur(){
        this.inFocus = false;
    }

    get showDropdown() {
        return this.userLoadState.resultsFound;
    }

    get showUsers() {
        return this.selectedUsers?.length > 0;
    }

    @wire(searchUser, { searchKey: '$searchKey' })
    userData({ data, error }) {
        if (data) {
            this.userLoadState = {
                resultsFound: data.length>0,
                data,
                isLoading : false
            }
        }
        else if(error) {
            this.userLoadState = {
                resultsFound: false,
                error,
                isLoading : false
              };
        }
     }

     handleCancel() {
        this.userLoadState = {
            resultsFound: false
        };
        this.searchKey = '';
     }
    handleSelection(event) {
        let userId = event.currentTarget.dataset.id;
        let userName = event.currentTarget.dataset.name;
        if(!this.userIds.includes(userId)) {
            let obj ={ id:userId, name:userName}
            this.selectedUsers.push(obj);
            this.userIds.push(userId);
        }
        this.userLoadState = {
            resultsFound: false,
            data: [],
            error: undefined
          };
        this.searchKey = '';
        setTimeout(()=>this.template.querySelector('lightning-input').focus(),200)
    }

    handleRemove(event) {
        let userId = event.currentTarget.dataset.id;
        for(let i = 0;i<this.selectedUsers.length;i++) {
            if(this.selectedUsers[i].id === userId) {
                this.selectedUsers.splice(i,1);
                break;
            }
        }
        if(this.userIds.includes(userId)) {
            let index = this.userIds.findIndex(x => x === userId);
            this.userIds.splice(index,1);
        }
    }

    async handleShare() {
        if(!this.selectedUsers.length > 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Select atleast one user',
                variant: 'info'
            });
            this.dispatchEvent(event);

        } else {
            let accessType = await this.validateAccessType();
            if (!accessType) {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Select the access type for the selected users',
                    variant: 'info'
                });
                this.dispatchEvent(event);
            } else {
                assignPermissionSet({ userIdList: this.userIds })
                .then(result => {
                    //this.lstIdsFailed = result;
                    let boolAssign = result;
                    if(!boolAssign) {
                        const event = new ShowToastEvent({
                            title:'Error',
                            message: 'PS Assignment Failed',
                            variant: 'Error'
                        });
                        this.dispatchEvent(event);
                    } else {
                        workIntakeShare({ userIdList: this.userIds, recordId: this.recordId , accessType : this.accessType_Value })
                        .then(result => {
                            this.lstIdsFailed = result;
                            if(this.lstIdsFailed.length === 0) {
                                const event = new ShowToastEvent({
                                    title:'Success',
                                    message: 'Shared Successfully',
                                    variant: 'Success'
                                });
                                this.dispatchEvent(event);
                            } else if (this.lstIdsFailed.length > 0){
                                message = 'Unable to share with ';
                                for (useridfailed in this.lstIdsFailed) {
                                    for(user in this.selectedUsers) {
                                        if(user.id === useridfailed.Id) {
                                            console.log('ids matched');
                                            message += 'user.name ,';
                                        }
                                    }
                                }
                                const event = new ShowToastEvent({
                                    title:'Error',
                                    message: message.slice(0, -2),
                                    variant: 'Success'
                                });
                                this.dispatchEvent(event);

                            }

                        })
                        .catch(error => {
                            console.log('error');
                        });

                    }
                    let message = '';
                    let variant;

                    this.userIds = [];
                    this.selectedUsers = [];
                    this.searchKey = '';
                    this.accessType_Value = '';
                    const event = new ShowToastEvent({
                        message: message,
                        variant: variant
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    console.log('error');
                });
            }

        }

    }

    async validateAccessType() {
        let accessTypeValue = this.template.querySelector('lightning-combobox');
        this.accessType_Value = accessTypeValue.value;
        if (this.accessType_Value) {
            return true;
        } else {
            return false;
        }
    }
}