public without sharing class sh_PresentationController {
   public String projectId1 {get; set;}
   public String practiceId1 {get; set;}
   public String offeringId {get; set;}
   public String domainVariable{get; set;}
   public String title{get; set;}
   public String showLocation {get; set;}
   
   public Boolean getShowTop() {
   	 if (showLocation == 'top') {
   	 	return (true);
   	 } else {
   	 	return (false);
   	 }
   }
   
   public List<PresentationInfo> getPresentationDto() {
       list<sh_keyPresentation__c> presentations = new list<sh_keyPresentation__c>();
	   list<sh_Offering__c> offerings;

       if (practiceId1 != null){
           presentations = [
                               SELECT Presentation_Name__c,Practice__c,Project__c, Description__c, Org62_File__c, Org62_File_URL__c, 
                               (
                                   SELECT id
                                   FROM Attachments
                               )
                               FROM sh_keyPresentation__c 
                               WHERE Practice__c =: practiceId1
                               order by Sequence__c
                           ];
           offerings =     [
                               SELECT Name, Practice__c, Offering_Name__c
                               FROM sh_Offering__c 
                               WHERE Practice__c =: practiceId1
                               order by Sequence__c
                           ];    
                                  
       } else if (projectId1 != null){
           presentations = [
                               SELECT Presentation_Name__c,Practice__c,Project__c, Description__c, Org62_File__c, Org62_File_URL__c, 
                               (
                                   SELECT id
                                   FROM Attachments
                               )
                               FROM sh_keyPresentation__c 
                               WHERE Project__c =: projectId1
                               order by Sequence__c
                           ];
       } else if (offeringId != null){
           presentations = [ 
                               SELECT Presentation_Name__c,Practice__c,Project__c, Description__c, Org62_File__c, Org62_File_URL__c, 
                               (
                                   SELECT id
                                   FROM Attachments
                               )
                               FROM sh_keyPresentation__c 
                               WHERE Offering__c =: offeringId
                               order by Sequence__c
                           ];
       } 
       
       
       List<PresentationInfo> pDto = new List<PresentationInfo>();
       for (sh_keyPresentation__c pres : presentations) {
         PresentationInfo pi = new PresentationInfo();
         pi.presentationName = pres.Presentation_Name__c;
         pi.description = pres.Description__c;
         pi.isOffering = false;
         if (pres.Attachments.size() > 0) {
            pi.attachmentId = pres.Attachments[0].Id;
         }
         pi.isOrg62Link = pres.Org62_File__c;
         pi.org62Link = pres.Org62_File_URL__c;
         pDto.add(pi);
       }   
       
       if(offerings != null && offerings.size() > 0){
   		for (sh_Offering__c pres : offerings) {
	         PresentationInfo pi = new PresentationInfo();
	         pi.presentationName = pres.Name;
	         pi.isOffering = true;
	         pi.presentationUniqueName = pres.Offering_Name__c;
	         pDto.add(pi);
	       }   	
       }
       
       return (pDto);
   }
   
   public sh_PresentationController() { 
     domainVariable= sh_URLUtility.GetPrefix();
   }

   public class PresentationInfo {
     public String presentationName {get; set;}
     public String description {get; set;}
     public String attachmentId {get; set;}
     public Boolean isOffering {get; set;}
     public Boolean isOrg62Link {get; set;}
     public String org62Link {get; set;}
     public String presentationUniqueName {get; set;}
   } 
}