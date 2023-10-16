import { LightningElement, wire, track} from 'lwc';
import getLearningResourceRecs from '@salesforce/apex/SKillsModalPopupController.getAllLearningResourceRecs';
import NoLearnResourceMsg from '@salesforce/label/c.CSG_No_Learn_Resource_Msg';

const columns = [
    { label: 'Type', fieldName: 'Type', sortable: true,initialWidth:160},
    { label: 'Category', fieldName: 'Category', sortable: true,initialWidth:160 },
  
    { label: 'Skill Name', fieldName: 'skilllink',type:'url' ,sortable: true,
        typeAttributes: {label: { fieldName: 'SkillName' }, target: '_blank'}
    },
    { label: 'Learning Resource Name', fieldName: 'lrLink',type:'url' ,sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
    },
    //{ label: 'Duration', fieldName: 'Duration', sortable: true, initialWidth:135,},
    { label: 'Source', fieldName: 'Source', sortable: true, },
    { label: 'Link', fieldName: 'courselink', type: 'url',sortable: true, },
    { label: 'Description', fieldName: 'desc',sortable: true, }
];

export default class LearningResourcelistView extends LightningElement {
    @track sortBy;
    @track sortDirection;
    @track defaultsortDirection = 'asc';
    @track showLoading = true;
    @track data = [];
    @track intialdata = [];
    columns = columns;
    @track showData = false;
    @track isEmpty = false;
    @track resMsg = false;
    searchKey ;
    @track NoLRMsg = NoLearnResourceMsg;
    @wire(getLearningResourceRecs)
    lrRecs(result) {
       
        this.data = [];
        this.resMsg = false;
        this.isEmpty = false;
        this.refreshlrRecs = result;
        if (result.data) {
           
            let tempRecords = result.data;
            tempRecords = tempRecords.map( row => {
                return { ...row,Name: row.Learning_Resource__r.Name, Source: row.Learning_Resource__r.Source__c,
                    Duration: row.Learning_Resource__r.Duration__c ,Link: '/'+row.Learning_Resource__c,
                    Type: row.CSGProfileSkill__r.Type__c, Category: row.CSGProfileSkill__r.Category__c,
                    SkillName: row.CSGProfileSkill__r.Name,
                    skilllink: '/'+row.CSGProfileSkill__c, desc: row.Learning_Resource__r.Description__c,
                    courselink: row.Learning_Resource__r.Link__c};
            })
            this.data = tempRecords;
            
            if(this.data){
               
                this.data.forEach(item => item['lrLink'] = item['Link'] );
              
            }
                
            console.log('@@@@@'+JSON.stringify( this.data));
            this.error = undefined;
            this.showLoading = false;
            this.showData = true;
            if(this.data.length > 0){
                this.isEmpty = false;
            }else{
                this.isEmpty = true;
                
            }
            this.intialdata = this.data;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
            this.showLoading = false;
            this.showData = true;
            this.isEmpty = true;
            this.resMsg = false;
        }else{
            this.isEmpty = true;
           
        }
        
        
    }
    sortLDT(event) {        
        let fieldName = event.detail.fieldName;
        fieldName = fieldName === 'lrLink' ? 'Name' : fieldName;
        fieldName = fieldName === 'skilllink'? 'SkillName': fieldName;
        this.sortBy = fieldName;    
       
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
        this.sortBy = event.detail.fieldName;;
   }  
   sortData(fieldname, direction) {  
  
    try {    
         let parseData = JSON.parse(JSON.stringify(this.data));
         let keyValue = (a) => {
             return a[fieldname];
         };

         let isReverse = direction === this.defaultsortDirection ? 1: -1;
         parseData.sort((x, y) => {
            if(!keyValue(x)){
                return 1 * isReverse;
                
            }
            //Check if the compareTo value is blank
            else if(!keyValue(y)){
                return -1 * isReverse;
            }
            if( keyValue(x) > keyValue(y)){
                return (1 * isReverse);
            }else if(keyValue(y) > keyValue(x)){
                return (-1 * isReverse);
            }else{
                return 0;
            }
            
                             
                             
        });
         this.data = parseData;
        } catch (errorMsg) {
            console.log ('error occured inside sortData() method.See actual system message <' + errorMsg.message + '>');
        }
    } 

    handleKeyChange(event){
        this.searchKey = event.target.value;
        let results = [];
        if(this.searchKey != '' && this.searchKey != null){


            this.data = this.searchTable(this.searchKey,this.intialdata,results);
        }else{
            this.data = this.intialdata;
        }
        if(this.data != null && this.data.length > 0){
            this.resMsg = false;
        }
        else{
            this.resMsg = true;
        }
        
    }

    searchTable(searchKey,intialdata,results){
        
        results = intialdata
            .filter( r => ( r.Type != null  && r.Type.toLowerCase().includes(searchKey.toLowerCase()) )|| ( r.Category != null && r.Category.toLowerCase().includes(this.searchKey.toLowerCase())) 
            || ( r.Category != null && r.Category.toLowerCase().includes(searchKey.toLowerCase())) 
            ||( r.SkillName != null && r.SkillName.toLowerCase().includes(searchKey.toLowerCase())) 
            || ( r.Name != null && r.Name.toLowerCase().includes(searchKey.toLowerCase())) 
            || ( r.Duration != null && r.Duration.toLowerCase().includes(searchKey.toLowerCase()))
            || ( r.Source != null && r.Source.toLowerCase().includes(searchKey.toLowerCase()))
            );

            return results;
    }


}