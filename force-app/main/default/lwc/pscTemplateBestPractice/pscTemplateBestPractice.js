import { LightningElement , api , wire} from 'lwc';
import getTemplateData from '@salesforce/apex/PSCTemplateBestPracticeCtrl.getTemplateData';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';

export default class PscTemplateBestPractice extends LightningElement {
    @api recId;
    templateData;
    IconUrl = PSC_IMAGES + '/Icons/';

    bestPracticeIcon = PSC_IMAGES + '/Icons/icon-templates-resources-best-practice.png';
    linkIcon = PSC_IMAGES + '/Icons/icon-templates-resources-link.png';
    templateIcon = PSC_IMAGES + '/Icons/icon-templates-resources-template.png';
    toolIcon = PSC_IMAGES + '/Icons/icon-templates-resources-tool.png';
    videoIcon = PSC_IMAGES + '/Icons/icon-templates-resources-video.png';

    @wire(getTemplateData, { methodId: '$recId' })
    wiredTemplate({ error, data }) {
        if (data) {
            if (data !== undefined && data !== null) {
                this.templateData = data;
                this.templateData = this.templateData.map(file => {
                    return {
                        ...file,
                        fileIconUrl: this.IconUrl + file.linkLogo + '_60.png'
                    };
                })
            }
        }
        if(error){
            console.log('error->',error);
        }
    }
}