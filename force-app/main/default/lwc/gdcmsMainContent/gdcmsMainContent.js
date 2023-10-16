import { LightningElement } from "lwc";
// import BACKGROUND_IMAGE_URL from "@salesforce/resourceUrl/landingPageBackground";
import ICONS from "@salesforce/resourceUrl/GDCIcons";
import TILES from "@salesforce/resourceUrl/GDCTiles";
import IMAGES from "@salesforce/resourceUrl/GDCBannerImages";
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import getTeamMemberCount from '@salesforce/apex/GDC_MS_HeadCount.getTeamMemberCount';

export default class GdcmsMainContent extends NavigationMixin(LightningElement) {
  //content = [1, 2, 3, 4, 5];
  // backgroundImageUrl = BACKGROUND_IMAGE_URL;
  //isImageSet = false;

  location = ICONS + '/GDCIcons/icon_location.png';
  project = ICONS + '/GDCIcons/icon_projects.png';
  region = ICONS + '/GDCIcons/icon_regions.png';
  team = ICONS + '/GDCIcons/icon_team.png';

  asset = TILES + "/GDCTiles/assets.png";
  enab = TILES + "/GDCTiles/enablement.png";
  engage = TILES + "/GDCTiles/engagement.png";
  process = TILES + "/GDCTiles/processes.png";
  story = TILES + "/GDCTiles/stories.png";
  gdcteam = TILES + "/GDCTiles/team.png";

  journeyimg = IMAGES +"/Journey.png";
  client_serviced = IMAGES +"/Client_Serviced.png";
  cardContent = ['GDC Team', 'Employee Engagement', 'Asset Repository', 'Process & Delivery Excellence', 'Success Stories'];
  teamMemberCount = 0;
  
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



  // setBackgroundImage() {
  //   const elem = this.template.querySelector(".image-holder");
  //   elem.style.backgroundImage = `url(${this.backgroundImageUrl})`;
  // }

  // renderedCallback() {
  //   if (!this.isImageSet) {
  //     this.setBackgroundImage();
  //     this.isImageSet = true;
  //   }
  // }
}