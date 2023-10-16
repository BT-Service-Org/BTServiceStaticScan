import { LightningElement, api, wire, track } from 'lwc';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import getArticleDetail from '@salesforce/apex/PSCKnowledgeDetailCtrl.getArticleDetail';
import getArticleRecordDetail from '@salesforce/apex/PSCKnowledgeDetailCtrl.getArticleRecordDetail';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ARTICLE_PRODUCT from '@salesforce/schema/Article_Product__c';
import ARTICLE_INDUSTRY from '@salesforce/schema/Article_Industry__c';
import ARTICLE_TAG from '@salesforce/schema/Article_Tags__c';
import ARTICLE_ROLES from '@salesforce/schema/Article_Roles__c';
import getUserFavorite from '@salesforce/apex/PSCFavoriteCtrl.getUserFavorite';
import { refreshApex } from '@salesforce/apex';

export default class PSCKnowledgeDetail extends LightningElement {
    @api recordId;

    @track article;
    @track articleIndustries = [];
    @track articleRoles = [];
    @track articleProducts = [];
    @track articleMethods = [];
    @track articleTags = [];
    @track addArticle;
    @track error;
    @track articleData;
    authorTitle = 'Author';
    resourceLinkTitle = '';
    heart_blank = PSC_IMAGES + '/Icons/heart_blank.png';
    heart_fill = PSC_IMAGES + '/Icons/heart_fill.png';
    crowdSource = PSC_IMAGES + '/images/crowd_source.png';
    verified = PSC_IMAGES + '/images/Verified.png';
    certified = PSC_IMAGES + '/images/certified.png';
    theSalesforceWay = PSC_IMAGES + '/images/theSalesforceWay.png';
    articleProductRecTypeId = '';
    articleIndustrycRecTypeId = '';
    articleTagcRecTypeId = '';
    articleRoleFamilyRecType='';

    curationIcon;

    fav = false;
    favId;
    favData;
    curationLevel;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && this.recordId == undefined) {
            this.recordId = currentPageReference.state?.recordId;
        }
    }
    // Product RecId 
    @wire(getObjectInfo, { objectApiName: ARTICLE_PRODUCT })
    wiredArticleProductData({ data, error }) {
        if (data != null) {
            this.articleProductRecTypeId = data.defaultRecordTypeId;
        }
        else if (error) {
            console.error(error);
        }
    }

    // Industry RecId
    @wire(getObjectInfo, { objectApiName: ARTICLE_INDUSTRY })
    wiredArticleIndustryData({ data, error }) {
        if (data) {
            this.articleIndustrycRecTypeId = data.defaultRecordTypeId;
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

    @wire(getArticleDetail, { recordId: '$recordId' })
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

    @wire(getArticleRecordDetail, { recordId: '$recordId' })
    wiredArticleDetails(result) {
        this.articleData = result;
        if (result.data) {
            if (result.data !== null && result.data !== undefined) {
                this.articleIndustries = [];
                this.articleProducts = [];
                this.articleRoles = [];
                this.articleTags = [];
                this.article = JSON.parse(JSON.stringify(result.data[0]));
                if (this.article.Body__c != undefined) {
                    this.article.Body__c = this.article.Body__c.replaceAll("/ServicesCentral/articles", "/ServicesCentral/s/article");
                }

                if (this.article.Article_Links__r != undefined) {
                    this.resourceLinkTitle = this.article.Article_Links__r.length > 1 ? 'Resources' : 'Resource'
                }
                if (this.article.Additional_Author__r && this.article.Additional_Author__r.FirstName) {
                    this.authorTitle = 'Author(s)'
                }

                // industries
                if (this.article.Article_Industries__r?.length) {
                    this.articleIndustries = this.article.Article_Industries__r.map(item => {
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
                if (this.article.Article_Products__r?.length) {
                    this.articleProducts = this.article.Article_Products__r.map(item => {
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

                // Methods
                if (this.article.Article_Methods__r?.length) {
                    this.articleMethods = this.article.Article_Methods__r.map(item => {
                        if (item.Method__r) {
                            return {
                                ...item,
                                Link_Text__c: item.Method__r.Name,
                                Link_Url__c: '/ServicesCentral/s/method?methodnumber=' + item.Method__r.Method_Number__c
                            }
                        } else {
                            return { ...item };
                        }
                    });
                }

                // tags and family roles
                if (this.article.Article_Tags__r?.length) {
                  this.article.Article_Tags__r.map(item => {
                        if (item.Tag__r) {
                            this.articleTags.push( {
                                ...item,
                                itemName: item.Tag__r.Name
                            })
                        } else if(item.Role_Family__r) {
                            this.articleRoles.push({
                                ...item,
                                itemName: item.Role_Family__r.Name

                            })
                        }
                        else {
                            return { ...item };
                        }
                    });
                }

                this.curationLevel = this.article?.Curation_Level__c;
                this.error = undefined;
            }
            this.articleProducts.push({ add: true, title: "New Article Product", categoryName: 'Add Product', recTypeId: this.articleProductRecTypeId, apiName: 'Article_Product__c', typeProduct: true, desc: this.article.Title, recId: this.recordId });
            this.articleIndustries.push({ add: true, title: "New Article Industry", categoryName: 'Add Industry', recTypeId: this.articleIndustrycRecTypeId, apiName: 'Article_Industry__c', typeIndustry: true, desc: this.article.Title, recId: this.recordId });
            this.articleRoles.push({ add: true, title: "Target Audience", categoryName: 'Add Target Audience', recTypeId: this.articleRoleFamilyRecType, apiName: 'Article_Tags__c', typeRole: true, desc: this.article.Title, recId: this.recordId });
            this.articleTags.push({ add: true, title: "New Article Tag", categoryName: 'Add Tag', recTypeId: this.articleTagcRecTypeId, apiName: 'Article_Tags__c', typeTag: true, desc: this.article.Title, recId: this.recordId });
        }
        else if(result.error){
            console.log('error->',result.error);
        }
    }

    refreshArticleData() {
        refreshApex(this.articleData);
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
            });
    }

    renderedCallback() {
        if (this.article?.Article_Indications__c) {
            if (this.article?.Curation_Level__c == "Crowd Sourced") {
                this.curationIcon = this.crowdSource;
            } else if (this.article?.Curation_Level__c == "Verified") {
                this.curationIcon = this.verified;

            } else if (this.article?.Curation_Level__c == "Certified") {
                this.curationIcon = this.certified;
            }
        }
    }

    handleBackClick() {
        window.history.back();
    }
}