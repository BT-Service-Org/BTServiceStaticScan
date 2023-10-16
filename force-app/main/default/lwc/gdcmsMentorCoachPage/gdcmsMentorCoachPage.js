import { LightningElement } from 'lwc';
import mentorshipResource from '@salesforce/resourceUrl/GDC_MS_Mentorship_Program';
import { NavigationMixin } from 'lightning/navigation';

export default class GdcmsMentorCoachPage extends NavigationMixin(LightningElement) {

        mentorshipProgramResource = mentorshipResource;

        handleClick(event) {
                this[NavigationMixin.Navigate]({
                        "type": "standard__webPage",
                        "attributes": {
                                "url": "https://docs.google.com/presentation/d/1oSJjTcs1qIFI_4WK8U0SoL2gYVS9ihsSogCZkXzXr8U/embed?authuser=0"
                        }
                });
        }
}