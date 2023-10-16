public without sharing class sh_ProjectController {
   public String projectName {get; set;}
   public String domainVariable{get; set;}
   public String staticImageId {get; set;}
   public sh_Project__c project {get; set;}
   
   //public project
 
   public sh_ProjectController() {
     domainVariable= sh_URLUtility.GetPrefix();

     Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
   
   // Get Project Name
   if (UrlParameterMap.containsKey('name')){
     projectName = UrlParameterMap.get('name');
   } else {
   	  //Just use a default page
      projectName='csg-analytics';
   }  
   
   project = [select   Name,
              HTML_Content_1__c,
              HTML_Content_2__c,
              Project_Name__c,
              Project_Info__c,
              Excerpt__c,
              BackgroundImageName__c,
              Client__c,
              Content__c,
              Industry__c,
              Quote_Author__c,
              Quote_Content__c,
              ThumbnailImageId__c,
              Title__c,
              Type__c,
              VideoBGImageId__c,
              Year__c,
              Overview_Video_JS_Vidyard__c,
              Customer_Story_Link__c,
               (
                     SELECT id, Name
                     FROM Attachments
                     WHERE Name = 'StaticImage.png'
               )
            from  sh_Project__c 
           where  Project_Name__c = :projectName
           limit  1]; 
           
            if(project.Attachments.size() > 0){
                 staticImageId = project.Attachments[0].Id; 
            }
             
   }  
}