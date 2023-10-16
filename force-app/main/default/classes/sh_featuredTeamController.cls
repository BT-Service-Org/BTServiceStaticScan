public without sharing class sh_featuredTeamController{
 
   public sh_Project__c project {get; set;}
   public String domainVariable{get; set;}

   public sh_featuredTeamController(){
     domainVariable= sh_URLUtility.GetPrefix();
   }

   public list< sh_Bio__c > getBios(){
       
       list< sh_Bio__c > bios = [
                                           SELECT id,Name, Bio_Name__c, Bio_Link__c, Bio_Title__c
                                           FROM sh_Bio__c
                                           WHERE id in (
                                               SELECT Bio__c
                                               FROM sh_projectTeam__c
                                               WHERE Project__c =: project.id
                                           )
                                        ];
       return bios;                                
   }
}