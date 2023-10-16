import { LightningElement, api, wire, track } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getReusableAssetDetail from '@salesforce/apex/PSCReusableAssetDetailCtrl.getReusableAssetDetail';
import getReusableAssetRecordDetail from '@salesforce/apex/PSCReusableAssetDetailCtrl.getReusableAssetRecordDetail';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getUserFavorite from '@salesforce/apex/PSCFavoriteCtrl.getUserFavorite';
import ASSET_PRODUCT from '@salesforce/schema/Asset_Product__c';
import ASSET_INDUSTRY from '@salesforce/schema/Asset_Industry__c';
import ARTICLE_TAG from '@salesforce/schema/Article_Tags__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';

export default class PscReusableAssetDetail extends NavigationMixin(LightningElement) {
    @api recordId;

    @track assets;
    @track assetIndustries = [];
    @track assetProducts = [];
    @track assetBenefits = [];
    @track assetTags = [];
    @track targetAudience =[];
    @track addArticle;
    @track assetData;
    @track error;
    assetProductRecTypeId = '';
    assetIndustryRecTypeId = '';
    articleTagcRecTypeId = '';
    articleRoleFamilyRecType = '';
    curationIcon;
    crowdSource = PSC_IMAGES + '/images/crowd_source.png';
    verified = PSC_IMAGES + '/images/Verified.png';

    fav = false;
    favId;
    favData;


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && this.recordId == undefined) {
            this.recordId = currentPageReference.state?.recordId;
        }
    }

    @wire(getReusableAssetDetail, { recordId: '$recordId' })
    wiredArticleAdditionalDetails({ data, error }) {
        if (data) {
            this.addArticle = data;
            this.error = undefined;
        }
        else if (error) {
            this.error = error;
            this.addArticle = undefined;
        }
    }
    // Product RecId 
    @wire(getObjectInfo, { objectApiName: ASSET_PRODUCT })
    wiredArticleProductData({ data, error }) {
        if (data != null) {
            this.assetProductRecTypeId = data.defaultRecordTypeId;
        }
        else if (error) {
            console.error(error);
        }
    }

    // Industry RecId
    @wire(getObjectInfo, { objectApiName: ASSET_INDUSTRY })
    wiredArticleIndustryData({ data, error }) {
        if (data) {
            this.assetIndustryRecTypeId = data.defaultRecordTypeId;
        }
        else if (error) {
            console.error(error);
        }
    }

    // Article Tag RecId
    @wire(getObjectInfo, { objectApiName: ARTICLE_TAG })
    wiredArticleTagData({ data, error }) {
        if (data) {

            const recTyps = data.recordTypeInfos;
            this.articleRoleFamilyRecType =  Object.keys( recTyps ).find( recTyp => recTyps[ recTyp ].name === 'Role Family Relationship');
            this.articleTagcRecTypeId = Object.keys( recTyps ).find( recTyp => recTyps[ recTyp ].name === 'Tag Relationship');
        }
        else if (error) {
            console.error(error);
        }
    }

    @wire(getReusableAssetRecordDetail, { recordId: '$recordId' })
    wiredArticleDetails(wireResult) {
        const { data, error } = wireResult;
        this.assetData = wireResult;

        if (data) {
            this.assets = data[0];
            this.assetProducts = [];
            this.assetIndustries = [];
            this.assetTags = [];
            this.assetBenefits = [];
            this.targetAudience = [];
            // industries
            if (this.assets.Asset_Industries__r?.length) {
                this.assetIndustries = this.assets.Asset_Industries__r.map(item => {
                    if (item.Industry__r) {
                        return {
                            ...item,
                            itemName: item.Industry__r.Name
                        }
                    } else {
                        return { ...item };
                    }
                });

            }
            // products
            if (this.assets.Asset_Products__r?.length) {
                this.assetProducts = this.assets.Asset_Products__r.map(item => {
                    if (item.Product__r) {
                        return {
                            ...item,
                            itemName: item.Product__r.Name
                        }
                    } else {
                        return { ...item };
                    }
                });
            }

            // tags
            if (this.assets.Reusable_Asset_Tags__r?.length) {
                this.assets.Reusable_Asset_Tags__r.map(item => {
                    if (item.Tag__r) {
                        this.assetTags.push( {
                            ...item,
                            itemName: item.Tag__r.Name
                        })
                    } else if(item.Role_Family__r) {
                        this.targetAudience.push({
                            ...item,
                            itemName: item.Role_Family__r.Name

                        })
                    } else {
                        return { ...item };
                    }
                });
            }

            if (this.assets.Benefits__c) {
                var itemName = {};
                itemName = this.assets.Benefits__c.split(';');
                for (var items in itemName) {
                    this.assetBenefits.push({ itemName: itemName[items] });
                }
            }
            this.error = undefined;
            this.assetProducts.push({ add: true, title: "New Asset Product", categoryName: 'Add Product', recTypeId: this.assetProductRecTypeId, apiName: 'Asset_Product__c', typeProduct: true, desc: this.assets.Title, recId: this.recordId });
            this.assetIndustries.push({ add: true, title: "New Asset Industry", categoryName: 'Add Industry', recTypeId: this.assetIndustryRecTypeId, apiName: 'Asset_Industry__c', typeIndustry: true, desc: this.assets.Title, recId: this.recordId });
            this.assetTags.push({ add: true, title: "New Asset Tag", categoryName: 'Add Tag', recTypeId: this.articleTagcRecTypeId, apiName: 'Article_Tags__c', typeTag: true, desc: this.assets.Title, recId: this.recordId });
            this.targetAudience.push({ add: true, title: "Target Audience", categoryName: 'Add Target Audience', recTypeId: this.articleRoleFamilyRecType, apiName: 'Article_Tags__c', typeRole: true, desc: this.assets.Title, recId: this.recordId });
        }
        else if (error) {
            this.error = error;
            this.assets = undefined;
            console.log(error);
        }
    }

    connectedCallback() {
        getUserFavorite({ key: this.recordId })
            .then(result => {
                if (result) {
                    this.favData = true;
                    if (result !== undefined && result.length > 0) {
                        this.favId = result[0].Id;
                        this.fav = true;
                    }
                    else {
                        this.favId = undefined;
                        this.fav = false;
                    }

                }
            })
            .catch(error => {
                console.log('error->', error);
                this.error = error;
                this.favId = undefined;
            })
    }

    renderedCallback() {
        if (this.assets?.Asset_Indications__c) {
            if (this.assets?.Curation_Level__c == "Crowd Sourced") {
                this.curationIcon = this.crowdSource;
            } else if (this.assets?.Curation_Level__c == "Verified") {
                this.curationIcon = this.verified;

            } 
        }
    }


    handleBackClick() {
        window.history.back();
    }

    handleNavigateToUrl(event) {
        window.open(event.target.value, "_blank");
    }

    refreshAssetData() {
        refreshApex(this.assetData);
    }
}