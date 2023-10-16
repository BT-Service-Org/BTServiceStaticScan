import { api, LightningElement, wire } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import getSitecontent from '@salesforce/apex/GDC_MS_SiteContentUtil.getSitecontent';
import CustomStyleSheet from '@salesforce/resourceUrl/gdcmsStaticContentCustomStyleSheet';
import fetchplaceholderValues from '@salesforce/apex/GDC_MS_SiteContentUtil.fetchplaceholderValues';

export default class GdcmsStaticContentBlock extends LightningElement {
   @api ContentId;
   @api externalContentId;
   richtext = '<p class="about-us-para"> The Global Delivery Centre (GDC) are the delivery arm of Professional Service, that is in the midst of hyper-growth. Starting from 400 consultants at the beginning of FY22, are on track to achieve 1200 headcount at the close of FY23, with projections for 2000+ consultants by FY24.</p>'
   allContent = [];
   displayAccordion = false;
   accordionHeading;
   siteConData =[];
   placeholderData;
   connectedCallback() {
      //console.log('externalContentId' + this.externalContentId);
      this.ContentId = this.ContentId ? this.ContentId : this.externalContentId;
      //console.log('ContentId' + this.ContentId);
      Promise.all([
         loadStyle(this,CustomStyleSheet)
      ]);
   }
   
   @wire(getSitecontent, { SiteContentId: '$ContentId' })
   wiredSiteContent({ data, error }) {
      if (data) {
         this.allContent = data;
         this.displayAccordion = this.allContent[0].gdc_ms_ParentId__r.gdc_ms_Contains_Accordion__c;
         this.accordionHeading = this.allContent[0].gdc_ms_ParentId__r.gdc_ms_Accordion_Heading__c;
      
         this.siteConData = [...this.allContent];
      } else if (error) {
         console.error(JSON.stringify(error));
      }
   }

    @wire(fetchplaceholderValues, { sitecontentData: '$siteConData' })
    wiredplaceholderValues({data,error}){
        if(data)
         {
            this.placeholderData = data;
            let conData = JSON.parse(JSON.stringify(this.allContent));
            this.allContent = conData.map(con=>{
            this.placeholderData.forEach(pData=>{
                  if(pData.gdc_ms_Site_Content__c===con.Id && con.gdc_ms_Body_Content__c)
                  {
                  con.gdc_ms_Body_Content__c = con.gdc_ms_Body_Content__c.replaceAll(pData.gdc_ms_Placeholder_Key__c, pData.gdc_ms_Placeholder_Value__c);
                 
                  }
               })
               return con;
            })
           
         }else if (error) {
         console.error(JSON.stringify(error));
         }
}
  
}