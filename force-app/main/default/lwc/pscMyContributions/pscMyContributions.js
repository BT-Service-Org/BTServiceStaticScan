import { LightningElement, api, track , wire} from 'lwc';
import getContainerData from '@salesforce/apex/PSCArticlesContainerController.getContainerData';
import getPageAttributes from '@salesforce/apex/PSCPageViewService.getPageAttributes';
import PSC_BANNER from '@salesforce/resourceUrl/pscAssets';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import { CurrentPageReference } from 'lightning/navigation';
export default class PscMyContributions extends LightningElement {
    @api maxNoOfResults;
    @api containerTitle;
    @api viewType;
    @track records;
    showFooter;
    @track recordsToDisplay=[];
    index = 0;
    contributionTitle = '';
    contributionDescription = '';
    contributionUrl = '';
    imageIndex = 1;
    nextDisabled = false;
    prevDisabled = false;
    showLastPage = false;
    showContent = false;
    isListView = false;
    showViewAll = false;
    showSlackUrl = false;
    backgroundUrl_1 = PSC_BANNER + '/profile_banner/tile1.png';
    backgroundUrl_2 = PSC_BANNER + '/profile_banner/tile2.png';
    backgroundUrl_3 = PSC_BANNER + '/profile_banner/tile3.png';
    backgroundUrl_4 = PSC_BANNER + '/profile_banner/tile4.png';
    slack_logo = PSC_IMAGES + '/Logo/slack-logo.png';
    imageUrl = PSC_BANNER + '/profile_banner/tile1.png';
    detailPageUrl ;
    communitySlackUrl='';
    tileHeader = this.containerTitle;
    container_type='';
    card_type='';
    key;
    pageName;
    userIsMember = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.key = currentPageReference.state?.name;
        }
    }

    @wire(getPageAttributes,{key:'$key'})
    getPageAttributes({data,error}) {
        if(data) {
            this.communitySlackUrl = data?.Slack_Channel_Link__c;
            this.userIsMember = data?.hasOwnProperty('Contribution_Teams__r')?true:false;
        }
    }


    connectedCallback() {
       
       this.card_type= this.containerTitle == 'Recent Questions' ? 'carousel-card':'carousel-content';
        this.getPageData();
        this.isListView = this.viewType == "Tile View" ? false : true;
    }

    get getBackgroundImage() {
        return `background-image:url("${this.imageUrl}");background-size: 100% 100%;
        background-repeat: no-repeat;
        height: auto;border-top-left-radius: 8px;
        border-top-right-radius: 8px;`;
    }

    getPageData() {
        getContainerData({ name: this.containerTitle, maxNoOfResults: parseInt(this.maxNoOfResults) ,key: this.key})
            .then(result => {
                this.records = result.tileData;
                let sourceName = result?.additionaldata1;
                let userName = result?.additionaldata2;
                this.pageName = this.records.length ? this.records[0].resourceType : '';
                this.detailPageUrl = "/ServicesCentral/s/global-search/%40uri#sort=relevancy&f:@gkcsource=" + sourceName + "&f:@community_name=" + "[" + this.pageName + "]" + "&f:@sfasked_by__rname=" + "[" +userName+ "]";
         
                this.error = undefined;
                this.records.sort((a, b) => a.recordLastUpdateDate && b.recordLastUpdateDate ? new Date(b.recordLastUpdateDate) - new Date(a.recordLastUpdateDate) : '');
                if (this.isListView) {
                    if (this.records.length > parseInt(this.maxNoOfResults)) {
                        this.showViewAll = true;
                    }
                    this.recordsToDisplay = this.records.slice(0, parseInt(this.maxNoOfResults));

                } else {
                    this.showViewAll = true;
                    this.recordsToDisplay = this.records.slice(0, parseInt(this.maxNoOfResults));
                }
                if (this.containerTitle == 'My Questions' || this.containerTitle == 'Recent Questions') {
                    this.showSlackUrl = true;
                    this.showViewAll = false;
                }
                if (this.records.length > this.maxNoOfResults) {
                    this.recordsToDisplay.push({
                        title: "Show all " + this.containerTitle,
                        showLastPage: true
                    })
                }

                this.dataUpdate();

            })
            .catch(error => {
                console.error('error->', error);
            })
    }

    nextBannerHandler() {
        this.index++;
        this.dataUpdate();
        this.imageIndex++;
        this.imageIndex = this.imageIndex > 3 ? 0 : this.imageIndex;
        this.flag = false;

    }
    prevBannerHandler() {
        this.index--;
        this.dataUpdate();
        this.imageIndex--;
        this.imageIndex = this.imageIndex < 1 ? 1 : this.imageIndex;
    }

    dataUpdate() {
        this.updateNavigation(this.index);

        if (this.recordsToDisplay.length) {
            this.showContent = true;
            this.contributionTitle = this.recordsToDisplay[this.index].title;
            this.contributionDescription = this.recordsToDisplay[this.index].body;
            this.contributionUrl = this.recordsToDisplay[this.index].navigationURL;
            this.status = this.recordsToDisplay[this.index]?.status;
            this.imageUrl = this.imageIndex == 1 ? this.backgroundUrl_1 : this.imageIndex == 2 ? this.backgroundUrl_2 : this.imageIndex == 3 ? this.backgroundUrl_3 : this.backgroundUrl_4;
            this.showLastPage = this.recordsToDisplay[this.index]?.showLastPage;
        } else {
            this.showContent = false;
            this.prevDisabled = true;
            this.nextDisabled = true;
        }

    }

    updateNavigation(index) {
        if (this.recordsToDisplay.length == 1) {
            this.prevDisabled = true;
            this.nextDisabled = true;
        } else if (index > 0 && index < this.recordsToDisplay.length - 1) {
            this.prevDisabled = false;
            this.nextDisabled = false;
        } else if (index >= this.recordsToDisplay.length - 1) {
            this.nextDisabled = true;
            this.prevDisabled = false;
        } else if (index == 0 && this.recordsToDisplay.length > 1) {
            this.nextDisabled = false;
            this.prevDisabled = true;
        }
    }
}