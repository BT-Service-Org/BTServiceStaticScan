import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import listViewId from '@salesforce/apex/GDC_MS_QuestionAnswerFormController.getListViewId';
// import assignPermission from '@salesforce/apex/GDC_MS_WorkIntakePermissionSetAssignment.assignPermissions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isguest from '@salesforce/user/isGuest';
import intakeImage from '@salesforce/resourceUrl/GDC_MS_Intake_Form';
import titleLabel from '@salesforce/label/c.gdcms_work_intake_form_title';
import loginMessage from '@salesforce/label/c.gdcms_login_message';

export default class GdcmsIntakeForm extends NavigationMixin(LightningElement) {

        @api objectApiName;
        @track listId = '';
        intakeImage = intakeImage;
        title = titleLabel;

        connectedCallback() {
                listViewId({ objectApiName: this.objectApiName })
                        .then((data) => {
                                this.listId = data.Id;
                        })
                        .catch((error) => {
                                console.log('error', error);
                        })
        }


        handleClick(event) {

                let obj = {};
                obj.action = "navigate";
                obj.url = window.location.href + 'gdc-ms-work-intake-form/' + this.objectApiName + '/' + this.listId;

                sessionStorage.clear();
                sessionStorage.setItem('gdcMicrosite', JSON.stringify(obj));

                console.log('@@isguest::', isguest);
                console.log('@@ this.listId::', this.listId);

                if (isguest) {
                        const event = new ShowToastEvent({
                                title: 'Alert!',
                                variant: 'warning',
                                message: loginMessage + ' {0}',
                                messageData: [
                                        {
                                                url: '/login',
                                                label: 'LOGIN'
                                        },
                                ],
                                mode: 'Sticky'
                        });
                        this.dispatchEvent(event);
                }
                else {
                        this[NavigationMixin.Navigate]({
                                type: 'standard__objectPage',
                                attributes: {
                                        objectApiName: this.objectApiName,
                                        actionName: 'list'
                                },
                                state: {
                                        filterName: this.listId
                                }
                        });
                }
        }

}