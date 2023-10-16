public with sharing class AssetController {

	public String contributorId {    get;set;    }

    public String contributorName  {    get;set;    }
    
    public String currencyCode  {    get;set;    }
    
    public Asset_Request__c ar {get;set;}
    
   	public List<Community_Contribution__c> contribs {get;set;}
   	
   	public Integer contribSize {get;set;}
   	
   	public Set<String> types {get;set;}
    
    public Integer error {get;set;}
    
    public AssetController(ApexPages.StandardController ctlr)
    {
        //get current rewards program id from custom settings
        String prgId = Util.getValue('CURRENT_REWARDS_PROGRAM');
    
        Community_Contributor__c c = [select Id, Name, CurrencyIsoCode, Points_Earned__c,Points_Redeemed__c, Points_Available__c from Community_Contributor__c 
                where User__c =: UserInfo.getUserId() and Community_Rewards_Program__c =: prgId];
        contributorId = c.Id;       
        contributorName = c.Name;
        currencyCode = c.CurrencyIsoCode;
        types = new Set<String>();		
       	ar = [Select Name, Asset_Due_Date__c, Status__c, Point_Value__c, Id, Community__c, Community_Leader__c, Assets_Needed__c 
        	From Asset_Request__c where Id=:ctlr.getId()];
        
        if (ar != null) {	
        	try {
        		contribs = [Select Id, Name, Type__c, Status__c, Community__c, Points_Awarded__c, CreatedDate, Asset_Request__c from 
	        		Community_Contribution__c where Asset_Request__c=:ar.Id and Community_Contributor__c=: contributorId
	        		order by CreatedDate desc];
	        	for (Community_Contribution__c cn : contribs) {
	        		System.debug('contrib type ' + cn.Type__c);
	        		types.add(cn.Type__c);
	        	}	        	
	        	System.debug('types in init ' + types); 
        	} catch (Exception e) {
        		contribSize = 0;
        		error=1;
        	}
        }
        
        if (contribs != null ) {
    		contribSize = contribs.size();
    	} else {
    		contribSize = 0;
    	}        
        
        signMeUp();
	}
	
	public PageReference signMeUp() {
        if (ar != null && ar.Status__c != 'Closed') {	        	
        	System.debug('error ' + error + contribSize);
        	PageReference pageRef = ApexPages.CurrentPage();  
        	if (ar.Assets_Needed__c.split(';').size() == types.size()) {        			     	
          		error=1;       			
        	}
        	if (Apexpages.currentPage().getParameters().get('success') == '1') {        		      	        		       		  
	        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,
		        	'Signup successful! Your Contribution records have been created for the assets you selected.');
				ApexPages.addMessage(myMsg);
				error = 0; 
        	}
			return pageRef;        	
        	   	
        } else {
        	PageReference pageRef = ApexPages.CurrentPage();
    	     	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
            	'ERROR: You are not allowed to sign up at this time. The Asset Request is closed. ');
          	ApexPages.addMessage(myMsg);
          	error=1;
       		return pageRef;
        }	
	}
	
	String[] assets = new String[]{};
                    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        String[] tmpString = ar.Assets_Needed__c.split(';');
		for(String s : tmpString) {
			System.debug('types ' + types);
			if (types != null && !types.contains(s)) {
				options.add(new SelectOption(s,s));
			}
		}
   		
        return options;
    }
        
    public String[] getAssets() {
        return assets;
    }
        
    public void setAssets(String[] assets) {
        this.assets = assets;
    }

	public PageReference signUp() {
		//create new contribution records
		String[] selectedAssets = getAssets();
		List<Community_Contribution__c> cls = new List<Community_Contribution__c>();
		RecordType[] recTypeId = [select Id from RecordType where Name = 'Bonus Contribution' and SObjectType = 'Community_Contribution__c'];
		for (String s : selectedAssets) {
			if (types != null && !types.contains(s)) {			
				cls.add(new Community_Contribution__c(Type__c=s, Status__c='Draft', Community_Contributor__c=contributorId, 
					Asset_Request__c=ar.Id, Community__c=ar.Community__c, Community_Leader__c=ar.Community_Leader__c,
					RecordTypeId=recTypeId[0].Id,Customer_Name__c='unknown'));					
			}
		}
		PageReference pageRef = new PageReference('/apex/SignMeUpPage?error=0&success=1&id='+ar.Id);
		if (cls.size() > 0) {
			insert cls; 			
			pageRef.setRedirect(true);
		}	
		return pageRef;

	}

}