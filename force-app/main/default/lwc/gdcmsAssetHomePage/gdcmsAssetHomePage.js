import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import SALESFORCE_LOGO_URL from "@salesforce/resourceUrl/GDC_MS_Logo";
import FORM_FACTOR from '@salesforce/client/formFactor';
import TEMPLATE_URL from '@salesforce/label/c.gdcms_asset_template_url';
import FAQ_URL from '@salesforce/label/c.gdcms_asset_faq_url';
export default class GdcmsAssetHomePage extends NavigationMixin(LightningElement) {
    salesforceLogo = SALESFORCE_LOGO_URL;
    currentPageReference = null;
    urlStateParameters = null;
    @api pageName
    isAssetAccelerators = false;
    isCheckAsset = false;
    isModalOpen_Create = false;
    /* Params from Url */
    urlId = null;
    urlLanguage = null;
    urlType = null;

    // Custom Labels
    label={
        TEMPLATE_URL,
        FAQ_URL
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
        }
    }
    get isMobileDevice() {
        return FORM_FACTOR === "Small" ? true : false;
    }
    setParametersBasedOnUrl() {
        this.urlId = this.urlStateParameters.id || null;
        this.urlLanguage = this.urlStateParameters.lang || null;
        this.urlType = this.urlStateParameters.type || null;
    }
    renderedCallback() {
        let a = window.location.pathname;
        let arr = a.split('/');
        let listOfAllNavItems = this.template.querySelectorAll('a');
        listOfAllNavItems.forEach(navItem => navItem.classList.remove('active'))


        if (a.includes('assets-accelerators') && !a.includes('check-asset-status')) {
            let publishAssets = this.template.querySelector('[data-id="Published Asset"]');
            publishAssets.classList.add('active');
        } else if (a.includes('check-asset-status')) {
            let checkStatus = this.template.querySelector('[data-id="Check the status"]');
            checkStatus.classList.add('active');
        }
    }
    openNav() {
        let Sidenav = this.template.querySelector(".mySidenav").style.width;
        let main = this.template.querySelector(".main").style.marginLeft;
        if (Sidenav == '250px' && main == '250px') {
            this.template.querySelector(".mySidenav").style.width = "0";
            this.template.querySelector(".main").style.marginLeft = "0";
        } else if (FORM_FACTOR === "Small") {
            this.template.querySelector(".mySidenav").style.width = "100%";
        }
        else {
            this.template.querySelector(".mySidenav").style.width = "250px";
            this.template.querySelector(".main").style.marginLeft = "250px";
        }
    }
    closeNav() {
        this.template.querySelector(".mySidenav").style.width = "0";
        this.template.querySelector(".main").style.marginLeft = "0";
    }
    connectedCallback() {
        if (this.pageName == 'Asset and Accelerators') {
            this.isAssetAccelerators = true;
        } else if (this.pageName == 'Check Asset Status') {
            this.isCheckAsset = true;
        }
    }

    show = false;
    map = new Map([
        ['Published Asset', 'Assets_and_Accelerators__c'],
        ['Submit your Idea', ''],
        ['Check the status', 'Check_Asset_Status__c'],
        ['Templates', ''],
        ['FAQ', '']
    ]);
    get navBarElements() {
        return [...this.map.keys()];
    }
    navigate(event) {
        this.template.querySelector(".mySidenav").style.width = "0";
        this.template.querySelector(".main").style.marginLeft = "0";
        let listOfAllNavItems = this.template.querySelectorAll('a');
        if (event.target.dataset.id == 'Published Asset' || event.target.dataset.id == 'Check the status') {
            let url = this.map.get(event.target.dataset.id);
            if (!url) {
                return;
            }
            listOfAllNavItems.forEach(navItem => navItem.classList.remove('active'))
            event.target.classList.add('active');
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: url
                },
            });
        } else if (event.target.dataset.id == 'Submit your Idea') {
            if (!this.isMobileDevice) {
                this.isModalOpen_Create = true;
                listOfAllNavItems.forEach(navItem => navItem.classList.remove('active'))
                event.target.classList.add('active');
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Create_Reusable_Asset__c'
                    },
                });
            }
        } else if (event.target.dataset.id == 'Templates') {
            const config = {
                type: 'standard__webPage',
                attributes: {
                    url: this.label.TEMPLATE_URL
                }
            };
            this[NavigationMixin.Navigate](config);
        } else if (event.target.dataset.id == 'FAQ') {
            const config = {
                type: 'standard__webPage',
                attributes: {
                    url: this.label.FAQ_URL
                }
            };
            this[NavigationMixin.Navigate](config);
        }
    }
    handleClick() {
        this.show = !this.show;
    }
    closeModalCreate() {
        this.isModalOpen_Create = false;
    }
}