import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SALESFORCE_LOGO_URL from "@salesforce/resourceUrl/GDC_MS_Logo";
import basePath from '@salesforce/community/basePath';
import getNavigationMenuItems from '@salesforce/apex/GDC_MS_NavigationMenuItems.getNavigationMenuItems';

export default class GdcmsHeader extends NavigationMixin(LightningElement) {
    salesforceLogo=SALESFORCE_LOGO_URL;
    isActiveSet;

    @track menuItems= [];
	error;
	@track map1 = new Map();
	@api arr1= [];
    
    @api pageName;
    show = false;

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
    
    handleClick() {
        if(this.show === false) {
            this.template.querySelector('img').classList.remove('rotateToClose');
            this.template.querySelector('img').classList.add('rotateToOpen');
            this.show = !this.show;
            setTimeout(()=> {
                let activeTab= this.template.querySelector(`[data-id='${this.pageName}']`)
                activeTab.classList.add('activeMobile')
            }, 100);
            
        }
        else if(this.show === true){
            this.template.querySelector('img').classList.remove('rotateToOpen');
            this.template.querySelector('img').classList.add('rotateToClose');
            this.template.querySelector('ul').classList.toggle('menuClose');
            setTimeout(()=> {
                this.show = !this.show;
            }, 500)
            
        }     
    }

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
        this.template.querySelector('img').classList.remove('rotateToOpen');
        this.template.querySelector('img').classList.add('rotateToClose');
        this.template.querySelector('ul').classList.toggle('menuClose');
        setTimeout(()=> {
            this.show = !this.show;
        }, 500)
    }

}