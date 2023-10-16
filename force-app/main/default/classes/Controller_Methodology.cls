public with sharing class Controller_Methodology {
    final string METHODOLOGY = 'Methodology';
    final string MOBILE = 'Mobile';    
    public String phase{get;set;}
    public  integer counterReq{get;set;}
    public  integer counterOpt{get;set;}
    public  integer counterMob{get;set;}
    public integer list_size{get;set;}  
    public integer total_size_req{get;set;}
    public integer total_size_opt{get;set;}
    public integer total_size_mob{get;set;}
    public list< ContentVersion > contentList{get;set;}
    
    public boolean showContent{get;set;}
    public Controller_Methodology(){
        
        list_size = (integer)Methodology_Content__c.getInstance('Content').Page_Size__c;
        showContent = false;
        counterMob = 0;
        total_size_mob = [select count() from ContentVersion where IsLatest = true and Category__c =: MOBILE];
    
    }
    
    //Slect Phase
    public void ChangeMethodology(){
        counterReq = 0;
        counterOpt = 0;
        
        phase = ApexPages.currentPage().getParameters().get('phase');
        showContent = true;
        total_size_req = [select count() from ContentVersion where IsLatest = true and Category__c =: METHODOLOGY and Required__c = true and Phase__c =: phase ];
        total_size_opt = [select count() from ContentVersion where IsLatest = true and Category__c =: METHODOLOGY and Required__c = false and Phase__c =: phase ];
        
    }
   
   //Get Key Deliverable 
   public list<ContentVersion> getRequiredContent() {
      
      return [select Id, Title, ContentDocumentId, Phase__c, Required__c from ContentVersion where Category__c =: METHODOLOGY and IsLatest = true and Required__c = true and Phase__c =: phase limit :list_size offset :counterReq];
   }
   
   //Get Optional Content
   public list<ContentVersion> getOptionalContent() {
      
      return [select Id, Title, ContentDocumentId, Phase__c, Required__c from ContentVersion where Category__c =: METHODOLOGY and IsLatest = true and Required__c = false and Phase__c =: phase limit :list_size offset :counterOpt];
   }
   
   //Get Mobile Content
   public list<ContentVersion> getMobileContent() {
      
      return [select Id, Title, ContentDocumentId from ContentVersion where Category__c =: MOBILE and IsLatest = true limit :list_size offset :counterMob];
   }
   
    
    public PageReference reqPrevious() { 
       counterReq -= list_size;
       return null;
    }

    public PageReference reqNext() { 
        counterReq += list_size;
        return null;
    }
    
    /* Start: Pagination Methods for Key Deliverable */
    public Boolean getReqDisablePrevious() { 
        if (counterReq>0) return true; else return false;
    }

    public Boolean getReqDisableNext() { 
        if (counterReq + list_size < total_size_req) return true; else return false;
    }
    
    public PageReference optPrevious() { 
       counterOpt -= list_size;
       return null;
    }

    /* Start: Pagination Methods for Optional Content */
    public PageReference optNext() { 
        counterOpt += list_size;
        return null;
    }
    
    public Boolean getOptDisablePrevious() { 
        if (counterOpt>0) return true; else return false;
    }

    public Boolean getOptDisableNext() { 
        if (counterOpt + list_size < total_size_opt) return true; else return false;
    }
    
    /* Start: Pagination Methods for Mobile Content */
    public PageReference mobPrevious() { 
       counterMob -= list_size;
       return null;
    }

    public PageReference mobNext() { 
        counterMob += list_size;
        return null;
    }
    
    public Boolean getMobDisablePrevious() { 
        if (counterMob>0) return true; else return false;
    }

    public Boolean getMobDisableNext() { 
        if (counterMob + list_size < total_size_mob) return true; else return false;
    }
    
    
}