import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import GDCBANNERIMAGES from '@salesforce/resourceUrl/GDCEnablementImages'

export default class GdcmsEnablement extends NavigationMixin(LightningElement)  {

    // suirrelImageUrl = GDCBANNERIMAGES + '/animated-loop-squirrel.gif';
    // flyingDroneImageUrl = GDCBANNERIMAGES + '/HootieFlyingDrone.gif';
    // codeyTypingImageUrl = GDCBANNERIMAGES + '/Codey_PR_typing_500x500.gif';
    // astroImageUrl = GDCBANNERIMAGES + '/Codey_PR_typing_500x500.gif';
    peoplrImageUrl = GDCBANNERIMAGES + '/people.jpg';

    openDocInNewTab(event) {
        let url =  event.target.getAttribute("data-href") || '#';
		// Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
	}
}