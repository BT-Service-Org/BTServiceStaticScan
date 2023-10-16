public without sharing class sh_OfferingController {
   public String offeringName {get; set;}
   public String domainVariable{get; set;}
   public String staticImageId {get; set;}
   public sh_Offering__c offering {get; set;}
   
   //public project
 
   public sh_OfferingController() {
     domainVariable= sh_URLUtility.GetPrefix();

     Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
   
   // Get Project Name
   if (UrlParameterMap.containsKey('name')){
     offeringName = UrlParameterMap.get('name');
   } 
   offering = [select   Name, Excerpt__c,
	              HTML_Content_1__c,
	              HTML_Content_2__c,
	              Offering_Name__c,
	              BackgroundImageName__c,
	              Content__c,
	              Overview_Video_JS_Vidyard__c,
              	 (
                     SELECT id, Name
                     FROM Attachments
                     WHERE Name = 'StaticImage.png'
               	 )
	           from  sh_Offering__c 
	           where  Offering_Name__c = :offeringName
	           limit  1]; 
           
            if(offering.Attachments.size() > 0){
                 staticImageId = offering.Attachments[0].Id; 
            }
             
   }  
}