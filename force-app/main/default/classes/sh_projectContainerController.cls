public without sharing class sh_projectContainerController{
 
     public sh_Project__c containerProject {get; set;}
     public sh_Project__c project {get; set;}
     public String domainVariable{get; set;}
   public sh_projectContainerController(){
     domainVariable= sh_URLUtility.GetPrefix();
     System.debug('domainVar is '+ domainVariable);

   }
    
   
   public list<string> getTypes(){
   if(containerProject.Type__c<>null)
       return containerProject.Type__c.split(';');
   else
       return new list<String>();
   }

   public list<string> getIndustries(){
      if(containerProject.Industry__c<>null)
          return containerProject.Industry__c.split(';');
      else
          return new list<String>();
   }
   
   public list<sh_Practice__c> getPractices(){
       
       list<sh_Practice__c> practices = [
                                           SELECT id, Name, Practice_Name__c
                                           FROM sh_Practice__c
                                           WHERE id in (
                                               SELECT Practice__c
                                               FROM sh_practiceProject__c
                                               WHERE Project__c =: containerProject.id
                                           )
                                        ];
       return practices;                                
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