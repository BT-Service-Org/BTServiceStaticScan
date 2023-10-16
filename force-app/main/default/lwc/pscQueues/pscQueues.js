import { LightningElement, wire, track } from 'lwc';
import getQueueData from '@salesforce/apex/PSCQueuesComponentCtrl.getGroupMemberData';
import deleteGroupMember from '@salesforce/apex/PSCQueuesComponentCtrl.deleteGroupMember';
import addGroupMember from '@salesforce/apex/PSCQueuesComponentCtrl.addGroupMember';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import USER_COMPETENCIES from '@salesforce/schema/UserCompetencies__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const actions = [
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'User Name', fieldName: 'userName' },
    { label: 'Email', fieldName: 'userEmail' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
export default class PscQueues extends LightningElement {
    @track comboboxGroupData = [];
    @track queueMembersData = [];
    @track groupMembersData = [];
    @track usersData = [];
    columns = columns;
    recordId = '';
    selectedGroupId = '';
    selectedGroupValue = '';
    showerror = false;
    errorMessage = '';
    showSpinner = false;

    @wire(getQueueData)
    getQueueData(result) {
        const { data, error } = result;
        this.groupMembersData = result;

        if (data) {
            this.comboboxGroupData = data.map(queue => {
                this.queueMembersData.push(
                    {
                        groupName: queue.groupName,
                        groupId: queue.groupId,
                        members: queue.groupMemberWrapperList ? queue.groupMemberWrapperList : []
                    }
                )
                return {
                    label: queue.groupName,
                    value: queue.groupName
                }
            });

            if (this.selectedGroupId) {
                this.usersData = [];
                this.queueMembersData.forEach(data => {
                    if (data.groupName == this.selectedGroupValue) {
                        this.usersData = data.members;
                        this.selectedGroupId = data.groupId;
                    }
                });
            }
        }
        if (error) {
            console.log("Error", error);
        }

    }

    @wire(getObjectInfo, { objectApiName: USER_COMPETENCIES })
    wiredArticleTagData({ data, error }) {
        if (data) {
            this.recordId = data.defaultRecordTypeId;
        }


    }
    handleChange(event) {
        this.selectedGroupValue = event.detail.value;
        this.usersData = [];
        this.showerror = false;
        this.handleReset();
        if (this.queueMembersData.length) {
            this.queueMembersData.forEach(data => {
                if (data.groupName == this.selectedGroupValue) {
                    this.selectedGroupId = data.groupId;
                    if (data.members.length) {
                        this.usersData = data.members;

                    }
                    else {
                        this.showerror = true;
                        this.errorMessage = "Selected group has no members"
                    }
                }

            });

        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
        }
    }

    deleteRow(row) {
        const { groupMemberRecId } = row;
        this.showSpinner = true;

        deleteGroupMember({ groupMemberId: groupMemberRecId }).then(result => {
            setTimeout(() => {
                refreshApex(this.groupMembersData);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Removed Successfully',
                        message: 'User removed from group',
                        variant: 'success'
                    })
                );
                this.showSpinner = false;
            }, 4000);
        }).catch(e => {
            console.error(e)

        })
    }

    onSubmit(event) {
        event.preventDefault();
        let fields = event.detail.fields;
        let found = false;
        this.showerror = false;
        let userData = {};
        userData.userId = fields['User__c'];
        this.usersData.forEach(user => {
            if (userData.userId == user.userId) {
                found = true;
            }
        });

        if (!found) {
            this.showSpinner = true;
            addGroupMember({ userId: userData.userId, groupId: this.selectedGroupId }).then(result => {

                setTimeout(() => {
                    refreshApex(this.groupMembersData);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Added Successfully',
                            message: 'User Added in group',
                            variant: 'success'
                        })
                    );
                    this.showSpinner = false;
                }, 4000)
            });
            this.handleReset();
        } else {
            this.showerror = true;
            this.errorMessage = 'User already exist in Member Group';
        }
    }

    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }


}