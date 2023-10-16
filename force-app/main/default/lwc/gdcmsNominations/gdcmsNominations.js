import { LightningElement,track} from 'lwc';
import getNominations from '@salesforce/apex/GDC_MS_NominationController.getNominations';
import getWinners from '@salesforce/apex/GDC_MS_NominationController.getWinners';
import updateWinner from '@salesforce/apex/GDC_MS_NominationController.updateWinner';
import removeWinner from '@salesforce/apex/GDC_MS_NominationController.removeWinner';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GdcmsNominations extends LightningElement {
    selectedAwardCategory;
    defaultRecordTypeId;
    selectedWinnerAwardCategory;
    selectedWinnerPeriod;
    selectedGroupLeader;
    selectedGroupWinnerLeader;
    searchWinnerText;
    @track nominationList;
    @track winnerlist;
    AllwinnerList;
    selectedPeriod;
    show = false;
    checkedBoxesIds=[];
    removedWinnerIds=[];
    @track filteredData;
    winnerLoaded = false;
    loaded = false;

    get periodOptions() {
        return [
            { label: 'Q1', value: 'Q1' },
            { label: 'Q2', value: 'Q2' },
            { label: 'Q3', value: 'Q3' },
            { label: 'Q4', value: 'Q4' },
        ];
    }
    get groupleaderOptions() {
        return [
            { label: 'Manu Dhir', value: 'Manu Dhir' },
            { label: 'Manpreet Singh', value: 'Manpreet Singh' },
            { label: 'Mohammad Mushfique', value: 'Mohammad Mushfique' },
            { label: 'Deepali Puri', value: 'Deepali Puri' },
        ];
    }
    get awardCategoryOptions(){
        return [
            {label:'Trailblazer Award',value:'Trailblazer Award'},
            {label:'Customer Success Team Award',value:'Customer Success Team Award'},
            {label:'Achievers Award',value:'Achievers Award'}
        ]
    }
    get isSmallDevice() {
        return FORM_FACTOR === "Small" ? true : false;
     }

     connectedCallback(){
        this.fetchNominationList();
    }
    fetchNominationList(){
        getNominations().then(result => {
            console.log(JSON.stringify(result));
            if(result){
                console.log('inside if '+JSON.stringify(result));
                this.nominationList  = result;
                this.filteredData = [...this.nominationList];
                this.show = true;
                this.loaded = true;
                console.log('inside if loaded= '+this.loaded);
                console.log('inside if loaded= '+this.winnerLoaded);
            }
        }).catch(error => {
            this.loaded = false;
            this.show = false;
            const event = new ShowToastEvent({
                title: 'ERROR!',
                message: 'Error in Fetching Nomination List! Please contact System Administrator',
                variant: 'error',
                mode:'sticky'
            });
            this.dispatchEvent(event);
            console.log('Error '+JSON.stringify(error));
        })
    }
    handleTabClickedNominee(){
        console.log('Nomiee tab clicked')
        this.fetchNominationList();
        this.resetSearchedResultFilters();
    }
    handleTabClicked(){
        getWinners().then(result => {
            if(result){
                this.AllwinnerList = result;
                this.winnerlist = [...this.AllwinnerList];
                this.winnerLoaded = true;
                this.resetSearchedResultWinnerFilters();
            }
        }).catch(error => {
            this.winnerLoaded = true;
            const event = new ShowToastEvent({
                title: 'ERROR!',
                message: 'Error in Fetching Nomination List! Please contact System Administrator',
                variant: 'error',
                mode:'sticky'
            });
            this.dispatchEvent(event);
            console.log('Error '+JSON.stringify(error));
        })
    }

   resetSearchedResultWinnerFilters(){
        this.selectedWinnerAwardCategory = undefined;
        this.selectedWinnerPeriod = undefined;
        this.selectedGroupWinnerLeader = undefined;
        this.winnerlist = [...this.AllwinnerList];
   }
   handleGroupLeaderWinnerChange(event){
        this.selectedGroupWinnerLeader = event.detail.value;
        if(this.selectedGroupWinnerLeader != undefined)
            this.isApplyFilterDisabled = false
        this.handleApplyWinnerFilter();
   }
   handleWinnerAwardCategoryChange(event){
        this.selectedWinnerAwardCategory = event.detail.value;
        if(this.selectedWinnerAwardCategory != undefined)
            this.isApplyFilterDisabled = false
        this.handleApplyWinnerFilter();
    }
    handleWinnerPeriodChange(event){
        this.selectedWinnerPeriod = event.detail.value;
        if(this.selectedWinnerPeriod!=undefined)
            this.isApplyFilterDisabled = false
        this.handleApplyWinnerFilter();
    }
    initiateWinnerSearchOnEnter(event) {
        if (event.code == 'Enter' && this.searchText != undefined) {
           this.handleApplyWinnerFilter();
        }
    }

    handleApplyWinnerFilter(){
        this.winnerLoaded = false;
        //this.winnerlist = [...this.AllwinnerList];
        let localList = this.AllwinnerList;

        if(this.selectedWinnerAwardCategory!== undefined){
            let tempData = [];
            tempData = localList.filter(e => e.gdc_ms_AwardCategory__c?.toLowerCase() === this.selectedWinnerAwardCategory?.toLowerCase());
            localList = [...tempData];
             //this.winnerlist = [...tempData]
        }
        if(this.selectedWinnerPeriod!== undefined){
            let tempData = [];
            tempData = localList.filter(e => e.gdc_ms_Quarter__c?.toLowerCase() === this.selectedWinnerPeriod?.toLowerCase());
            localList = [...tempData];
            //this.winnerlist = [...tempData]
         }
         if(this.selectedGroupWinnerLeader!== undefined){
            let tempData = [];
            tempData = localList.filter(e => e.GDC_MS_GroupLeader__c?.toLowerCase()===this.selectedGroupWinnerLeader?.toLowerCase());
            localList = [...tempData];
            //this.winnerlist = [...tempData]
         }
         this.winnerlist = [...localList];
         if (localList.length <= 0) {
            this.winnerLoaded = true;
            console.log('result found in filter'+this.show);
         } else {
            this.winnerLoaded = true;
            this.winnerlist = [...localList];
            console.log('result found in filter'+this.show);
         }
    }
    get winnerShow(){
        return this.winnerlist.length<=0 ? false : true;
    }
    get isDataAvailable() {
        return this.filteredData.length<=0 ? false : true;
    }
    resetSearchedResultFilters() {
        console.log('nominationlist '+JSON.stringify(this.nominationList));
        this.filteredData = [...this.nominationList];
        this.selectedAwardCategory = undefined;
        this.selectedPeriod = undefined;
        this.selectedGroupLeader = undefined;
        this.searchText = undefined;
    }
    handleGroupLeaderChange(event){
        this.selectedGroupLeader = event.detail.value;
        if (this.selectedGroupLeader != undefined)
           this.isApplyFilterDisabled = false;
        this.handleApplyFilters();
    }
    handleAwardCategoryChange(event) {
        this.selectedAwardCategory = event.detail.value;
        if (this.selectedAwardCategory != undefined)
           this.isApplyFilterDisabled = false;
        this.handleApplyFilters();
    }
    handlePeriodChange(event) {
        this.selectedPeriod = event.detail.value;
        if (this.selectedPeriod != undefined)
           this.isApplyFilterDisabled = false;
        this.handleApplyFilters();
    }
    initiateSearchOnEnter(event) {
        if (event.code == 'Enter' && this.searchText != undefined) {
           this.handleApplyFilters();
        }
    }

    handleNominationSearch(event) {
        this.searchText = event.target.value;
        if (this.searchText != undefined)
           this.isApplyFilterDisabled = false;
        this.handleApplyFilters();
    }

    handleApplyFilters(){
        this.loaded = false;
        //this.filteredData = [...this.nominationList];
        let localList = this.nominationList;
        if (this.selectedAwardCategory !== undefined) {
            let tempData = [];
            tempData = localList.filter(e=>e.gdc_ms_AwardCategory__c?.toLowerCase() === this.selectedAwardCategory?.toLowerCase());
            localList = [...tempData];
            //this.filteredData = [...tempData]
         }
         if(this.selectedPeriod!== undefined){
            let tempData = [];
            tempData = localList.filter(e => e.gdc_ms_Quarter__c?.toLowerCase() === this.selectedPeriod?.toLowerCase());
            localList = [...tempData];
            //this.filteredData = [...tempData]
         }
         if(this.selectedGroupLeader!== undefined){
            let tempData = [];
            tempData = localList.filter(e => e.GDC_MS_GroupLeader__c?.toLowerCase()===this.selectedGroupLeader?.toLowerCase());
            localList = [...tempData];
            //this.filteredData = [...tempData]
         }
         this.filteredData = [...localList];

         if (this.filteredData.length <= 0) {
            this.loaded = true;
            console.log('result found in filter'+this.show);
         } else {
            this.loaded = true;
            console.log('result found in filter'+this.show);

         }

         this.loaded = true;
    }

    recordSelected(event) {
        const recordId = event.detail;
        if(recordId)
            this.checkedBoxesIds.push(recordId);
    }
    recordDiselected(event) {
        console.log('called remove nomination list');
        const payload = event.detail;
        if(payload){
            let arr = this.checkedBoxesIds.filter(e=>e!==payload);
            this.checkedBoxesIds = [...arr];
        }
    }
    handleMarkedWinner(event){
        console.log('checkBoxlist '+this.checkedBoxesIds)
        updateWinner({recordIds:this.checkedBoxesIds}).then((result) => {
            if(result=='successful') {
                /*let newarr  =[];
                newarr = this.filteredData.filter(e=>!this.checkedBoxesIds.includes(e.Id));
                console.log('newList '+newarr);
                this.filteredData=[...newarr];
                this.nominationList=[...newarr];*/
                location.reload();
                const evt = new ShowToastEvent({
                    title: 'Winner',
                    message: 'Nominations updated successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Winner',
                message: 'Something Went wrong. Please contact administrator',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        })
    }
    recordDiselectFromRemoveLst(event){
        console.log('called remove list');
        const payload = event.detail;
        if(payload){
           let arr =  this.removedWinnerIds.filter(e=>e !== payload);
           this.removedWinnerIds = [...arr];
        }
        console.log('removed '+this.removedWinnerIds)
    }

    recordRemovedFromWinner(event){
        const recordId  = event.detail;
        if(recordId)
            this.removedWinnerIds.push(recordId);

    }
    handleDiselectWinner(event){
        console.log('checkBoxlist '+this.removedWinnerIds)
        removeWinner({recordIds:this.removedWinnerIds}).then((result) => {
            if(result=='successful') {
                /*let newarr  =[];
                newarr = this.winnerlist.filter(e=>!this.removedWinnerIds.includes(e.Id));
                console.log('newList '+newarr);
                this.AllwinnerList=[...newarr];
                this.winnerlist=[...newarr];*/
                location.reload();
                const evt = new ShowToastEvent({
                    title: 'Removed',
                    message: 'Nominee removed from the list successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Winner',
                message: 'Something Went wrong. Please contact administrator',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        })
    }
}