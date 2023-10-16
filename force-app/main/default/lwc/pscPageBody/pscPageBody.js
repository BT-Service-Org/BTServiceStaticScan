import { LightningElement, track, wire } from 'lwc';
import getPageSections from '@salesforce/apex/PSCPageViewService.getPageSections';
import { CurrentPageReference } from 'lightning/navigation';

export default class PscPageBody extends LightningElement {

    @track pageSections = [];
    @track pageName = '';
    authorName = '';
    lastModifiedDate = '';
    @track pageId;//GKC-1355
    isPageTypeCommunity = false;
    pageType = '';
    @track featureContent = [];


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.pageName = currentPageReference.state?.name;
        }
    }

    @wire(getPageSections, { key: '$pageName' }) getPageSections({ data, error }) {
        if (data) {
            this.pageSections = data.map(section => {
                if (section.Page__r) {
                    this.isPageTypeCommunity = section.Page__r.Type__c == 'Community Page' ? true : false;
                    this.pageType = this.isPageTypeCommunity ? 'community_page' : '';
                    this.pageId = section?.Page__c;
                    if (section.Page__r.Author__r != undefined) {
                        if (section.Page__r?.Author__r?.FirstName && section.Page__r?.Author__r.LastName) {
                            this.authorName = section.Page__r.Author__r.FirstName + " " + section.Page__r.Author__r.LastName
                        } else if (section.Page__r?.Author__r.LastName) {
                            this.authorName = section.Page__r.Author__r.LastName;
                        } else if (section.Page__r?.Author__r.FirstName) {
                            this.authorName = section.Page__r.Author__r.FirstName;
                        }
                    }
                    this.lastModifiedDate = section.Page__r.Last_Published__c ? section.Page__r.Last_Published__c : '';
                }

                return {
                    ...section,
                    isTextEditor: section.Type__c == "Rich Text Editor" ? true : false,
                    isTextEditorWithImage: section.Type__c == "Rich Text Editor With Image" ? true : false,
                    isImageCard: section.Type__c == "Image Card List" ? true : false,
                    isVideoSection: section.Type__c == "Video" ? true : false,
                    isFeaturedContent: section.Type__c == "Featured Content" ? true : false,

                    size: section.Section_Width__c == '25%' ? '3' : section.Section_Width__c == '33%' ? '4' : section.Section_Width__c == '50%' ? '6' : section.Section_Width__c == '75%' ? '9' : '12',
                    alignRight: section.Align_Image__c == 'Right' ? true : false,
                    alignLeft: section.Align_Image__c == 'Left' ? true : false,
                    alignDefault: section.Align_Image__c == 'Left' ? false : section.Align_Image__c == 'Right' ? false : true,
                    imagewidth: section.Image_Width__c == '25%' ? 'image25' : section.Image_Width__c == '33%' ? 'image33' : section.Image_Width__c == '50%' ? 'image50' : 'imagedefault',
                    isImageWidth: section.Image_Width__c == '25%' ? true: section.Image_Width__c == '33%' ? true: section.Image_Width__c == '50%' ? true : false,
                    contentwidth: section.Image_Width__c == '25%' ? 'content75' : section.Image_Width__c == '33%' ? 'content65' : section.Image_Width__c == '50%' ? 'content50' : 'contentDefault',
                    contentFont: section.Section_Width__c == '25%' ? 'contentfont25' : section.Section_Width__c == '33%' ? 'contentfont50' : section.Section_Width__c == '50%' ? 'contentfont50' : section.Section_Width__c == '75%' ? 'contentfont75' : 'contentfont100',
                    videoUrl: this.getVideoUrl(section.VideoUrl__c)
                }

            });
        } else if (error) {
            console.log(error);
        }
    }

    // Check the video format url and replace it with embed url if url is for youtube

    getVideoUrl(videoUrl) {
        if (videoUrl !== undefined && videoUrl.includes('youtube')) {
            return videoUrl.replace('https://www.youtube.com/watch?v=', 'https://www.youtube.com/embed/');
        }
        else if (videoUrl !== undefined && videoUrl.includes('https://youtu.be/')) {
            return videoUrl.replace('https://youtu.be/', 'https://www.youtube.com/embed/');
        }
        return videoUrl;
    }
}