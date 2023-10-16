import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import GDCMS from '@salesforce/messageChannel/gdcms__c';
import BACKGROUND_IMAGE_URL from "@salesforce/resourceUrl/GDCBannerImages";// 5MB - 10 Images
import { NavigationMixin } from 'lightning/navigation';
// import getPageImageFile from '@salesforce/apex/GDC_MS_PageImage.getPageImageFile';

export default class GdcmsPageName extends NavigationMixin(LightningElement) {
	@api pageName;
	@api gdcBannerText;
	@api gdcImageRelativePath;
	@api showImage;
	@api imageHeight

	backgroundImageUrl;
	isImageSet = false;


		@wire(MessageContext)
		messageContext;

		connectedCallback(){
			const payload = { 
					pageName: this.pageName
				};

				publish(this.messageContext, GDCMS, payload);
		if (sessionStorage.getItem('gdcMicrosite')) {
			var obj = JSON.parse(sessionStorage.getItem('gdcMicrosite'));
			if (obj.action == "navigate") {
				this.navigateToUrl(obj.url);
				//window.open(obj.url, '_self');
				sessionStorage.clear();
			}
		}
		}

	
		setBackgroundImage() {
			
			if(!!this.gdcImageRelativePath) {
				this.backgroundImageUrl = BACKGROUND_IMAGE_URL + this.gdcImageRelativePath;
			}
			else {
				this.backgroundImageUrl = BACKGROUND_IMAGE_URL + '/banner1.jpeg';
			}
			
			const elem = this.template.querySelector(".image-holder");

			if(elem) {
				let eleTest = this.template.querySelector(".container");
				eleTest.style.setProperty('--imageheight', this.imageHeight +'px');
				console.log(eleTest, eleTest);
				elem.style.backgroundImage = `url(${this.backgroundImageUrl})`;
			}
			
		}
	
		renderedCallback() {
			if (!this.isImageSet) {
			this.setBackgroundImage();
			this.isImageSet = true;
			}

			// const payload = { 
			// 	pageName: this.pageName
			// };

			// publish(this.messageContext, GDCMS, payload);
		}
	navigateToUrl(objurl) {
		this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
				url: objurl
			}
		});
	}
}