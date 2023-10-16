import { LightningElement,api,wire } from 'lwc';
import getPageAttributes from '@salesforce/apex/PSCPageViewService.getPageAttributes';
import { CurrentPageReference } from 'lightning/navigation';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';
import PSC_IMAGES from '@salesforce/resourceUrl/pscImages';
import { refreshApex } from '@salesforce/apex';
import userId from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTRIBUTION_TEAM_OBJECT from '@salesforce/schema/Contribution_Team__c';
import becomeMemberSlack from '@salesforce/apex/PSCPageViewService.becomeMemberSlack';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PscPageHeader extends LightningElement {
    userId = userId;
    @api imageUrl;
    @api pageTitle;
    @api pageDesc;
    @api isCommunity;
    userIsMember = false;
    urlName;
    pageHeaderData;
    contributionMemberRecId;
    communityId;
    conTeamCOPRecTypeID;
    channelId;
    //userJoinRequestSuccess = false;

    @wire(getPageAttributes, { key: '$urlName' }) 
    getPageAttributes(result) {
        this.pageHeaderData = result;
        console.log(this.pageHeaderData);
        if (result.data) {
            this.pageTitle = result.data.Page_Title__c;
            this.pageDesc = result.data.Page_Description__c;
            this.imageUrl = result.data.Title_Background_URL__c;
            this.communityId = result.data.Id;
            this.contributionMemberRecId = undefined;
            this.channelId = result.data.Channel_Id__c;
            this.userIsMember = false;
            if(result.data.hasOwnProperty('Contribution_Teams__r')){
                this.userIsMember = true;
                this.contributionMemberRecId = result.data.Contribution_Teams__r[0].Id;
            }

        } else if (result.error) {
            console.error(result.error)
        }
    }

    @wire(getObjectInfo, { objectApiName: CONTRIBUTION_TEAM_OBJECT })
    wireConTeam({ data, error }) {
        if (data) {
            const recTyps = data.recordTypeInfos;
            this.conTeamCOPRecTypeID =  Object.keys( recTyps ).find( recTyp => recTyps[ recTyp ].name === 'Community of Practice');
        }
        else if (error) {
            console.error(error);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlName = currentPageReference.state?.name;
        }
    }

    connectedCallback() {
        if (this.imageUrl) {
            this.imageUrl = PSC_IMAGES + this.imageUrl;
        }
    }

    // onLeaveCommunity(){
    //     console.log('this.contributionMemberRecId->',this.contributionMemberRecId);
    //     deleteRecord(this.contributionMemberRecId)
    //     .then(() => {
    //         refreshApex(this.pageHeaderData);
    //     })
    //     .catch(error => {
    //         console.log(error);
    //     });
    // }
    
    onJoinCommunity(){
        becomeMemberSlack({userId:this.userId,pageSlackId:this.channelId})
        .then(result=>{
            //this.userJoinRequestSuccess = true;
            refreshApex(this.pageHeaderData);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Success! You have been invited to join our channel in Slack. You will receive an invitation shortly.',
                    variant: 'success'
                })
            );
        })
        .catch(error=>{
            console.log('error->',error);
        })
        // let fields = { 
        //     'Community__c': this.communityId, 
        //     'psc_Role__c': 'Member',
        //     'psc_Team_Member__c': this.userId,
        //     'RecordTypeId': this.conTeamCOPRecTypeID
        // };
        // const recordInput = { 'apiName': 'Contribution_Team__c', fields };
        // console.log(recordInput);
        // createRecord(recordInput)
        // .then(() => {
        //     refreshApex(this.pageHeaderData);
        // })
        // .catch(error => {
        //     console.log(error);
        // });
    }
}