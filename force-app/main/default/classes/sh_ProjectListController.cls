public without sharing class sh_ProjectListController{

   public String userId {get; set;}
   public String practiceId {get; set;}
   public String domainVariable{get; set;}


    public sh_ProjectListController(){
        domainVariable= sh_URLUtility.GetPrefix();
        System.debug('domainVar is '+ domainVariable);
    }
   public List<ProjectInfo> getProjectData() {
       list<sh_Project__c> projects = new list<sh_Project__c>();
       system.debug('>>>>>>> In sh_ProjectListController constructor: ' + practiceId);

       if (practiceId != null){
           projects = [
                               SELECT id,Project_Name__c,Name,Year__c, Sequence__c, LastModifiedById, 
                               (
                                   SELECT id,Name
                                   FROM Attachments
                                   WHERE Name =: 'ThumbnailImage'
                               )
                               FROM sh_Project__c 
                               WHERE id in (
                                               SELECT Project__c
                                               FROM sh_practiceProject__c
                                               WHERE Practice__c =: practiceId
                                           )
                               Order by CreatedDate desc
                           ];
       } else if (userId != null){
           projects = [
                               SELECT id,Project_Name__c,Name,Year__c, Sequence__c, LastModifiedById, 
                               (
                                   SELECT id,Name
                                   FROM Attachments
                                   WHERE Name =: 'ThumbnailImage'

                               )
                               FROM sh_Project__c 
                               WHERE id in (
                                               SELECT Project__c
                                               FROM sh_projectTeam__c
                                               WHERE Bio__c =: userId
                                           )
                               Order by CreatedDate desc
                           ];
       } 
       
       List<ProjectInfo> projectData = new List<ProjectInfo>();
       for (sh_Project__c projectObj : projects) {
          ProjectInfo proInfo = new ProjectInfo();
         proInfo.Name = projectObj.Name;
         proInfo.projectName = projectObj.Project_Name__c;
         if (projectObj.Attachments.size() > 0) {
           proInfo.thumbnailId = projectObj.Attachments[0].Id;
         }
         proInfo.Year = projectObj.Year__c;
         
         projectData.add(proInfo);
       }  
       
     return (projectData);
   }
       
   public class ProjectInfo {
     public String projectName {get; set;}
     public String Name {get; set;}
     public String Year {get; set;}
     public String sequence {get; set;}
     public String thumbnailId {get; set;}


   } 

}