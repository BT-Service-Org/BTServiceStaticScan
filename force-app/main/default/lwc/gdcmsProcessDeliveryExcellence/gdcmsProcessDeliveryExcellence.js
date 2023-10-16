import { LightningElement, api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';


export default class GdcmsProcessDeliveryExcellence extends NavigationMixin(LightningElement) {

	@api header;
	@api buttonLink;
	@api aboutTheInfo;
	@api ownerInfo
	OwnerObject;
	activeSectionName = undefined;

	@wire(CurrentPageReference)
    currentPageReference;
	isSet = false;

	openQuipDocInNewTab() {
		// Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.buttonLink
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
	}

	connectedCallback() {
		this.OwnerObject = [];
		if(!!this.ownerInfo) {
			this.showOwnerComponent();
		}

	}

	renderedCallback(){
		if(this.isSet) return;

		const accordion = this.template.querySelector('.example-accordion');
		if(!accordion) return;

		if(this.currentPageReference?.state?.c__id === this.header){
			accordion.activeSectionName = [...'A'];
			this.isSet = true;
			setTimeout(()=> {
                let target = this.template.querySelector(`[data-id="scrollTo"]`);
                target.scrollIntoView({behavior: "smooth"});
				
            },750)
		}
	}

	showOwnerComponent() {

		let ownerNameAndLinkObject = this.ownerInfo.split(';');

		for(let i = 0; i < ownerNameAndLinkObject.length; i++) {
			let tempObj =  ownerNameAndLinkObject[i].split('@');
			this.OwnerObject.push({
				label: tempObj[0],
				url: tempObj[1]
			});
		}
	}
	

}