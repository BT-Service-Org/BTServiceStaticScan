@istest
private class Controller_Methodology_Test {
  static testMethod void testMethodology() { 
    Methodology_Content__c mc = new Methodology_Content__c( name='Content',Page_Size__c = 2);
    insert mc;
    list<ContentVersion> contentList = new list<ContentVersion>();
    for(integer i=0;i<6;i++){
      contentList.add(new ContentVersion(ContentURL='http://www.google.com/', Title = 'Google.com'))  ;
    }
                                      
    insert contentList  ;
    
    
     contentList = [SELECT ContentDocumentId FROM ContentVersion where Id in :contentList]; 
     ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace limit 1]; 
     list<ContentWorkspaceDoc> workspaceDocList =new list<ContentWorkspaceDoc>(); 
     for(integer i=0;i<contentList.size();i++){
       workspaceDocList.add(new ContentWorkspaceDoc(ContentWorkspaceId = testWorkspace.Id,ContentDocumentId = contentList[i].ContentDocumentId));
     }  
     
     insert workspaceDocList;
     
     for(integer i=0;i<contentList.size();i++){
       contentList[i].Phase__c ='Prepare';
       if(i<3){
         contentList[i].Required__c =true;
       }
       else{
         contentList[i].Required__c =false;
       }
     }
     update contentList;
      
    PageReference pageRef = Page.Methodology;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('phase','Prepare');
        Controller_Methodology controller = new Controller_Methodology();
        controller.ChangeMethodology();
        system.assertEquals(controller.getRequiredContent().size(),2);
        system.assertEquals(controller.getReqDisableNext(),false);
        system.assertEquals(controller.getReqDisablePrevious(),true);  
        controller.reqNext();
        controller.reqPrevious();
        
    system.assertEquals(controller.getOptionalContent().size(),2);
        system.assertEquals(controller.getOptDisableNext(),false);
        system.assertEquals(controller.getOptDisablePrevious(),true);  
        controller.optNext();
        controller.optPrevious();
    
                  
  }
}