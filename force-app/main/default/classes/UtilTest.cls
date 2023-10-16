@isTest
public with sharing class UtilTest {
	
	public static Community_Rewards_Program__c crprg;

	public static User commUser;
	
	public static User commLeader;
	
	public static Community_Contributor__c cc;
	
	public static Product__c p1;
	
	public static Product__c p2;	
	
	public static Asset_Request__c ar;
	
	static PointsRedeemedExtension ext;
	
	static AssetController ac;
  	
  	static PageReference pref;
   
   
   	static {
   		Profile pl = [select Id from Profile where Name = 'Community Leaders'];
		Profile pu = [select Id from Profile where Name = 'Community Contributors'];
		
		commLeader = new User(username='salescloudleader@test.com',email='cl@salesforce.com',alias='scloud', profileId=pl.Id,
					lastName='luser',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US');
		Test.startTest();
		insert commLeader;
		
		commUser = new User(username='commuser@test.com',email='cu@salesforce.com',alias='cuser', profileId=pu.Id,
				lastName='cuser',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US');
		insert commUser;					
		Test.stopTest();
   	}

  	@isTest
  	public static void setupConfig() {
		
				
		crprg = new Community_Rewards_Program__c(Name='currProgram');
		insert crprg;
		
		p1 = new Product__c(Name='test product1', Points_Needed__c=50);
		
		p2 = new Product__c(Name='test product2', Points_Needed__c=100);
		
		List<Product__c> pls = new List<Product__c>();
		pls.add(p1);
		pls.add(p2);
		
		insert pls;
		
		ar = new Asset_Request__c(Community_Leader__c=commLeader.Id,Community__c='Service Cloud',
  				Title__c='test1', Assets_Needed__c='Template;Best Practices Document',Point_Value__c=100, Status__c='Open');
  		
  		insert ar;
				
		System.runAs( commUser ) { 
			
			System.assertEquals('', Util.getValue('test'));
			
			Community_Rewards_Config__c settings = Community_Rewards_Config__c.getInstance();
			List<Community_Rewards_Config__c> ls = new List<Community_Rewards_Config__c>();
			  
			if (settings == null) {
				settings = new Community_Rewards_Config__c();
			    settings.Name = 'CURRENT_REWARDS_PROGRAM';
			    settings.Value__c = crprg.Id;
				ls.add(settings);
				
				settings = new Community_Rewards_Config__c();
			    settings.Name = 'Sales Cloud';
			    settings.Value__c = '';
				ls.add(settings);
	
				settings = new Community_Rewards_Config__c();
			    settings.Name = 'MAX_CONTRIBUTIONS';
			    settings.Value__c = '8';
				ls.add(settings);
				
				settings = new Community_Rewards_Config__c();
			    settings.Name = 'MAX_POINTS';
			    settings.Value__c = '300';
				ls.add(settings);
				
				insert ls;
			}
		}
		
		System.assertEquals(Util.getValue('MAX_POINTS'),'300');   
		System.assertEquals(Util.getValue('MAX_CONTRIBUTIONS'),'8');
  	
  		cc = [select Id,User__c,Community_Rewards_Program__c from Community_Contributor__c where User__c=:commUser.Id ];
  		System.assertEquals(cc.User__c,commUser.Id);
  		//System.assertEquals(cc.Community_Rewards_Program__c,crprg.Id);
  	}

	@isTest
  	public static void createContrib() {
  		setupConfig();
  		
  		Approval.ProcessResult result1;
  		Approval.ProcessResult result2;
  		Approval.ProcessResult result3;
  		Approval.ProcessResult result4;
  		
  		Community_Contribution__c ccontrib3;
  		Community_Contribution__c ccontrib4;
  		
  		System.runAs( commUser ) {
  			Community_Contribution__c ccontrib1 = new Community_Contribution__c(title__c='test1', Community__c='Sales Cloud', Type__c='Template',
  					Application_Functional_Area__c='', Community_Contributor__c=cc.Id);
  			insert ccontrib1;
  			System.assertEquals(ccontrib1.Points_Awarded__c,null);
  			
  			result1 = submitContrib(ccontrib1);
  			
  			Community_Contribution__c ccontrib2 = new Community_Contribution__c(title__c='test1', Community__c='Sales Cloud', Type__c='Template',
  					Application_Functional_Area__c='', Community_Contributor__c=cc.Id);
  			insert ccontrib2;
  			System.assertEquals(ccontrib2.Points_Awarded__c,null);
  			result2 = submitContrib(ccontrib2);
  			
  			ccontrib3 = new Community_Contribution__c(title__c='test1', Community__c='Sales Cloud', Type__c='Template',
  					Application_Functional_Area__c='', Community_Contributor__c=cc.Id);
  			insert ccontrib3;
  			System.debug('contrib3 ' + ccontrib3);
  			result3 = submitContrib(ccontrib3);
  			
  			ccontrib4 = new Community_Contribution__c(title__c='test1', Community__c='Sales Cloud', Type__c='Template',
  					Application_Functional_Area__c='', Community_Contributor__c=cc.Id);
  			insert ccontrib4;
  			System.debug('contrib4 ' + ccontrib4);
  			result4 = submitContrib(ccontrib4);
  			
  			//sign up for asset request
  			pref = Page.SignMeUpPage;
	  		ApexPages.StandardController setCon = new ApexPages.StandardController(ar);
			ac = new AssetController(setcon);
									
			Test.setCurrentPage(pref);
			String[] assets = new String[]{'Template;Best Practices Document'};
			ac.setAssets(assets);
			ac.signUp();
  		}
  		
  		approveContrib(result1);
  		approveContrib(result2);
  		approveContrib(result3);	
  		approveContrib(result4);

		System.assertEquals([select Points_Awarded__c from Community_Contribution__c where Id=:ccontrib3.Id].Points_Awarded__c,50);
		
		System.runAs( commUser ) {
			//Test.startTest();
			redeemPoints();
			redeemPoints1();
			redeemPoints2();
			redeemPoints3();
			//Test.stopTest();
		}

 	}
 	
 	
  	private static Approval.ProcessResult submitContrib(Community_Contribution__c contrib) {
	  	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    	req1.setComments('Submitting request for approval.');
    	req1.setObjectId(contrib.Id);
    
    	// Submit the approval request for the account
    	Approval.ProcessResult result = Approval.process(req1);
    
    	// Verify the result 
       	System.assert(result.isSuccess());
    
    	System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
    	return result;
  	}
  	
  	private static void approveContrib(Approval.ProcessResult result) {                
        // Approve the submitted request 
    
        // First, get the ID of the newly created item 
    
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it 
    
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked 
    
        req2.setWorkitemId(newWorkItemIds.get(0));
	        
        // Submit the request for approval     
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results     
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
		  		
  	}
  	
  	private static void redeemPoints() {
  		pref = Page.ProductRedeemedSplashPage;
  		List<Product__c> prls = new List<Product__c>();
  		prls.add(p1);
  		prls.add(p2);
  		ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(prls);
		ext = new PointsRedeemedExtension(setcon);
		
		List<Product__c> pselected = new List<Product__c>();
		pselected.add(p1);
				
		Test.setCurrentPage(pref);
		System.assertEquals([select Points_Available__c from Community_Contributor__c where Id=:cc.Id].Points_Available__c,100);
		
		
		PageReference confirmPage = ext.step2();
		System.assertEquals(confirmPage.getUrl(), Page.ProductRedeemedConfirmationPage.getUrl());
				
				
  	}
  	
  	private static void redeemPoints1() {
  		pref = Page.ProductRedeemedConfirmationPage;
  		List<Product__c> prls = new List<Product__c>();
  		prls.add(p1);
  		prls.add(p2);
  		ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(prls);
  		List<Product__c> pselected = new List<Product__c>();
		pselected.add(p1);
		
  		setCon.setSelected(pselected);
		ext = new PointsRedeemedExtension(setcon);
		
		Test.setCurrentPage(pref);
		System.assertEquals([select Points_Available__c from Community_Contributor__c where Id=:cc.Id].Points_Available__c,100);
		
		ext.shipTo.Street='123';
		ext.shipTo.City='city';
		ext.shipTo.State='state';
		ext.shipTo.Country='cntry';
		ext.shipTo.zip='12345';
		 
		ext.submit();
		System.debug('**contrib record:'+cc);
		System.assertEquals(ext.getHideButtons(), true);
				
		
		
			
  	}
  	
	private static void redeemPoints2() {
  		pref = Page.ProductRedeemedConfirmationPage;
  		List<Product__c> prls = new List<Product__c>();
  		prls.add(p1);
  		prls.add(p2);
  		ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(prls);
  		List<Product__c> pselected = new List<Product__c>();
		pselected.add(p1);
		
  		setCon.setSelected(pselected);
		ext = new PointsRedeemedExtension(setcon);
		
		Test.setCurrentPage(pref);
		System.assertEquals([select Points_Available__c from Community_Contributor__c where Id=:cc.Id].Points_Available__c,100);
		
		ext.shipTo.Street='123';
		ext.shipTo.City='city';
		 
		ext.submit();
				
		
		
			
  	}

  	private static void redeemPoints3() {
  		pref = Page.ProductRedeemedSplashPage;
  		List<Product__c> prls = new List<Product__c>();
  		prls.add(p1);
  		prls.add(p2);
  		ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(prls);
  		List<Product__c> pselected = new List<Product__c>();
		pselected.add(p1);
		pselected.add(p2);
		
  		setCon.setSelected(pselected);
		ext = new PointsRedeemedExtension(setcon);
		
		Test.setCurrentPage(pref);
		System.assertEquals([select Points_Available__c from Community_Contributor__c where Id=:cc.Id].Points_Available__c,100);		
				 
		ext.step2();
		System.assertEquals(ext.getHideButtons(), true);
				
		
		
		System.assertEquals([select Points_Available__c from Community_Contributor__c where Id=:cc.Id].Points_Available__c,100);
		
  	}
}