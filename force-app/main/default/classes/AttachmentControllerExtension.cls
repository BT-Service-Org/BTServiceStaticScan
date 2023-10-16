public with sharing class AttachmentControllerExtension{
  public AttachmentControllerExtension(ApexPages.StandardController controller) {
		this.preworkRec =(Academy_Prework__c)controller.getRecord();
  }
  
  public Academy_Prework__c preworkRec {get; private set;}
  public  Document document {
    get {
      if (document == null)
        document = new Document();
      return document;
    }
    set;
  }
 
  public PageReference uploadMindMap() {
  	String dtString = Datetime.now().format('MM-dd-yyyy-hh_mm_ss');
 	Attachment atchMnt = new Attachment(ParentId=preworkRec.Id,Name='MindMap-'+dtString,Description='Mind Map'+dtString,Body=document.body);
    try {
      insert atchMnt;
      preworkRec.Mind_Map_Status__c=5;
      update preWorkRec;
    } catch (DMLException e) {
      System.debug('>>>>>>>>>> Exception uploading document - '+e.getMessage());
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      return null;
    } finally {
      document.body = null; // clears the viewstate
      document = new Document();
    }
 
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
    return new PageReference('/'+preworkRec.Id);
  }
  
 
}