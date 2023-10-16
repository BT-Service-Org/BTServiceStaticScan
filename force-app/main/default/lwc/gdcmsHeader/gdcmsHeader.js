import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SALESFORCE_LOGO_URL from "@salesforce/resourceUrl/GDC_MS_Logo";
import basePath from '@salesforce/community/basePath';
import getNavigationMenuItems from '@salesforce/apex/GDC_MS_NavigationMenuItems.getNavigationMenuItems';
import { subscribe, MessageContext } from 'lightning/messageService';
import FORM_FACTOR from '@salesforce/client/formFactor';
import GDCMS from '@salesforce/messageChannel/gdcms__c';

import isguest from '@salesforce/user/isGuest';

import updateTeamMemberRecord from '@salesforce/apex/GDC_MS_TM_LoginUpdate.updateTeamMemberRecord';
export default class GdcmsHeader extends NavigationMixin(LightningElement) {
    salesforceLogo=SALESFORCE_LOGO_URL;
    isActiveSet;

    @track menuItems= [];
	error;
	@track map1 = new Map();
	arr1= [];
    
    pageName;
    //show = false;
    
    get isDesktopDevice() {
        if (FORM_FACTOR === "Large") {
            return true;
        }
        return false; 
    }

    @wire(getNavigationMenuItems)
	wiredMenuItems({ error, data }) {
        if (data) {
            this.menuItems = data.map((item, index) => {
                return {
                        target: item.Target,
                        id: index,
                        label: item.Label,
                        type: item.Type,
                    };
                });
            this.error = undefined;					
        }else if (error) {
            this.error = error;
            this.menuItems = [];
            console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
        for(var i = 0; i < this.menuItems.length; i++) {
            this.map1.set(this.menuItems[i].label,this.menuItems[i])
            this.arr1.push(this.menuItems[i].label);
        }
        this.arr1 = JSON.parse(JSON.stringify(this.arr1))
    }

    get navBarElements(){
        return this.arr1;
    }
    
    // handleClick() {
    //     if(this.show === false) {
    //         this.template.querySelector('img').classList.remove('rotateToClose');
    //         this.template.querySelector('img').classList.add('rotateToOpen');
    //         this.show = !this.show;
    //         setTimeout(()=> {
    //             let activeTab= this.template.querySelector(`[data-id='${this.pageName}']`)
    //             activeTab.classList.add('activeMobile')
    //         }, 100);
            
    //     }
    //     else if(this.show === true){
    //         this.template.querySelector('img').classList.remove('rotateToOpen');
    //         this.template.querySelector('img').classList.add('rotateToClose');
    //         this.template.querySelector('ul').classList.toggle('menuClose');
    //         setTimeout(()=> {
    //             this.show = !this.show;
    //         }, 500)
            
    //     }     
    // }

    navigate(event){
        if(this.map1.get(event.target.dataset.id)){
            console.log('Current page', this.map1.get(event.target.dataset.id));
            let	url= this.map1.get(event.target.dataset.id).target
            let type= this.map1.get(event.target.dataset.id).type
            console.log('Current page', url);
            if (type === 'InternalLink') {
                const pageName = basePath + url;
                this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                        url: pageName
                }
                });
            } else if (type === 'ExternalLink') {
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: url
                    }
                });
            }        
        }
        // if(this.isDesktopDevice === false) {
        //     this.template.querySelector('img').classList.remove('rotateToOpen');
        //     this.template.querySelector('img').classList.add('rotateToClose');
        //     this.template.querySelector('ul').classList.toggle('menuClose');
        // }
        // setTimeout(()=> {
        //     this.show = !this.show;
        // }, 500)
    }

    @wire(MessageContext)
	messageContext;

	subscribeToMessageChannel() {
		this.subscription = subscribe(
		  this.messageContext,
		  GDCMS,
		  (message) => this.handleMessage(message)
		);
	  }
      
      handleMessage(message) {
		this.pageName = message.pageName;
        //if(this.isActiveSet){
            this.setActiveTab(this.pageName)
        //}
	  }

      renderedCallback(){
        if(this.isActiveSet){
            return;
        }
        if(this.pageName && this.template.querySelectorAll('a') && this.template.querySelectorAll('a').length){
            this.setActiveTab(this.pageName);            
        }
      }

      setActiveTab(pageName){
        let listOfAllNavItems = this.template.querySelectorAll('a');
        listOfAllNavItems.forEach(navItem => navItem.classList.remove('active'));
        let activeTab= this.template.querySelector(`[data-id='${pageName}']`);
        if(activeTab) {
            activeTab?.classList.add('active');
            this.isActiveSet = true;
        }
        else {
            this.isActiveSet = false;
        }
        
      }

	  connectedCallback() {
        console.log('isGuest::', isguest);
          console.log('this.isconnected', this.isConnected);
          if(!this.subscription) {
            this.subscribeToMessageChannel();
          }
		
        if (isguest == false) {
            updateTeamMemberRecord()
                .then((result) => {
                    if (result) {
                        console.log('Team Member :::: ' + result);
                    }
                })
                .catch((error) => {
                    console.log('The time stamp is not updated :: ' + JSON.stringify(error));
                });
        }

	  }
}