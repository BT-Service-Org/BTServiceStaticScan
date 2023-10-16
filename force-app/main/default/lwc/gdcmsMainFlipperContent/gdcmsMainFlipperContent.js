import { LightningElement } from 'lwc';
import ICONS from "@salesforce/resourceUrl/GDCIcons";
import TILES from "@salesforce/resourceUrl/GDCTiles";
import IMAGES from "@salesforce/resourceUrl/GDCBannerImages";
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getTeamMemberCount from '@salesforce/apex/GDC_MS_HeadCount.getTeamMemberCount';

export default class GdcmsMainFlipperContent extends LightningElement {
    location = ICONS + '/GDCIcons/icon_location.png';
  project = ICONS + '/GDCIcons/icon_projects.png';
  region = ICONS + '/GDCIcons/icon_regions.png';
  team = ICONS + '/GDCIcons/icon_team.png';

  asset = TILES + "/GDCTiles/assets.png";
  enab = TILES + "/GDCTiles/enablement.png";
  engage = TILES + "/GDCTiles/engagement.png";
  process = TILES + "/GDCTiles/processes.png";
  story1 = TILES + "/GDCTiles/stories1.png";
  story2 = TILES + "/GDCTiles/stories2.png";
  gdcteam = TILES + "/GDCTiles/team.png";

  journeyimg = IMAGES +"/Journey.png";
  client_serviced = IMAGES +"/Client_Serviced.png";
  cardContent = ['GDC Team', 'Employee Engagement', 'Asset Repository', 'Process & Delivery Excellence', 'Success Stories'];
  teamMemberCount = 0;
 
  richtext='<iframe src="https://docs.google.com/presentation/d/1ArV_yHAeBgD2gqE7hLj-gJ8TJ-p-hiYfei9ia1N05Bo/embed?slide=id.g13d15dbb557_0_0"  frameborder="0" allowfullscreen="" width="100%" height="600px" src="https://docs.google.com/presentation/d/1iH4FPz0VSYeoa7QGq8EEAV6ns1e6X5OVW6BNECYzciA/embed?authuser=0"></iframe>';

  connectedCallback(){
    this.getCount();
  }

  

  getCount() {
    getTeamMemberCount()
    .then(result => {
        this.teamMemberCount = result;
    })
    .catch(error => {
      if (error && error.body && error.body.message) {
        this.showToast('error', error.body.message);
      }
    });
  }

  showToast(type, message) {
    const event = new ShowToastEvent({
        variant: type,
        message: message,
    });
    this.dispatchEvent(event);
  }

  navigate(event){
    const url= event.target.dataset.id
    const pageName = basePath + url;
    //console.log(pageName)

    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
          url: pageName
      }
    }); 
  }

  navigateExternal(event){
    const url= event.target.dataset.id
    const pageName = url;

    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
          url: pageName
      }
    }); 
  }
}