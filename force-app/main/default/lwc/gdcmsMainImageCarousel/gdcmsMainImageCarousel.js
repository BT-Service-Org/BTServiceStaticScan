import { LightningElement,wire } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import CustomStyleSheet from '@salesforce/resourceUrl/gdcmsCarouselCustomStyleSheet';
import getActiveSuccessStories from '@salesforce/apex/GDC_MS_DisplaySuccessStoryController.getActiveSuccessStories';

export default class GdcmsMainImageCarousel extends LightningElement {
    allContent=[];
    hasdata=false;
    connectedCallback(){
        Promise.all([
            loadStyle(this,CustomStyleSheet)
        ]);
    }
    @wire(getActiveSuccessStories)
    wiredSuccessStories({ data, error }) {
       if (data) {
          if(data.length){
            this.hasdata = true;
          }
          this.allContent = data;
       } else if (error) {
          console.error(JSON.stringify(error));
       }
    }
}